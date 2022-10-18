`define NULL_CHAR 8'h00

// Parameter definition
localparam LOWERCASE_A_CHAR = 8'h61;
localparam LOWERCASE_Z_CHAR = 8'h7A;
localparam Q = 8'd225;
localparam P = 8'd227;

// The submodule that performs the operation of key-pair generation (mode = 2'b01)
module public_key_gen_mod(
     input  clk
    ,input  rst_n 
    ,input  selection               // Control variable that activates the circuit
    ,input  [7:0] secret_key        // The secret key that is used as input to calculate the public key
    ,output reg [7:0] public_key    // The public key calculated as Pk = (Sk+q) modp
    ,output reg pkg_ready           // The output bit indicating when the output (the public key) is ready
);

//---------------------------------------------------------------------------
// VARIABLES
//---------------------------------------------------------------------------

// Submodule variables definition
/*
Definition of sum variable -> sum = secret_key + Q
Borderline cases: secret_key = 0 -> sum = 225
                  secret_key = 226 (can be equal at most to P - 1 = 226) -> sum = 451
*/
reg [8:0] sum; // ranges from 225 to 451
/*
Definition of result variable -> sum modp
Borderline cases: sum = 227 -> result = 0
                  sum = 226 -> result = 226
                  sum = 451 -> result = 224
result is on 9 bits, the public key will be the least significant 8 bits
*/
reg [8:0] result; // ranges from 0 to 226

//---------------------------------------------------------------------------
// LOGIC DESIGN
//---------------------------------------------------------------------------

always @ (*) begin
    // selection worth 1 if mode is 2'b01
    if(selection == 1'b1) begin
        sum = secret_key + Q;
        // The result of the sum is a number less than 227, it is not necessary to calculate modp
        if(sum >= 9'b000000001 && sum < P) begin
            result = sum;
            pkg_ready = 1'b1; 
        end
        // the result of the sum is a number greater than or equal to 227, it is necessary to calculate modp
        else begin
            result = sum - P;
            pkg_ready = 1'b1;
        end
        public_key = result[7:0];
    end
    // This is the case when the circuit was not selected, mode != 2'b01
    else begin
        result = 9'h0;
        sum = 9'h0;
        public_key = `NULL_CHAR;
        pkg_ready = 1'b0;
    end
end

endmodule

// The submodule that performs the operation of encryption (mode = 2'b10)
module encryption_mod(
     input  clk
    ,input rst_n 
    ,input  selection               // Control variable that activates the circuit
    ,input  [7:0] plaintext         // The plaintext input we want to encrypt
    ,input  [7:0] public_key        // The public key that we will use to encrypt the plaintext
    ,output reg [7:0] ciphertext    // The output ciphertext calculated as C[i] = (P[i] - Pk) modp
    ,output reg enc_ready           // The output bit indicating when the output (the ciphertext) is ready
);
//---------------------------------------------------------------------------
// VARIABLES
//---------------------------------------------------------------------------

// Submodule variables definition
/*
Definition of sub variable -> sub = plaintext - public_key
Borderline cases: plaintext = 97 (lowercase A) public_key = 226 (Max value) -> sub = -129
                  plaintext = 122 (lowercase Z) public_key = 0 (Min value) -> sub = 122

To avoid errors we also consider cases with plaintext other than lowercase letters, 
the wire that checks the plaintext value ensures that invalid output is not generated.
*/
reg signed [8:0] sub;
reg[8:0] result;

//---------------------------------------------------------------------------
// LOGIC DESIGN
//---------------------------------------------------------------------------

always @ (*) begin
    // selection worth 1 if mode is 2'b10
    if(selection) begin
        sub = plaintext - public_key;
        // The sub is negative number
        if (sub < $signed(9'd0))begin                           
            result = sub + $signed(P);
            ciphertext = result[7:0];
            enc_ready = 1'b1;
        end
        // The sub is between 0 and 227
         else if (sub >= 9'd0 && sub < 9'd227) begin
            result = sub;
            ciphertext = result[7:0];
            enc_ready = 1'b1;
        end
        // The sub is between 227 and 256
        else begin
            result = sub - P;
            ciphertext = result[7:0];
            enc_ready = 1'b1;
        end       
    end
    // This is the case when the circuit was not selected, mode != 2'b10
    else begin
        sub = 9'h0;
        result = 9'h0;
        ciphertext = `NULL_CHAR;
        enc_ready = 1'b0;
    end
end

endmodule

// The submodule that performs the operation of decryption (mode = 2'b11)
module decryption_mod (
     input clk
    ,input rst_n
    ,input selection            // Control variable that activates the circuit
    ,input [7:0] ciphertext     // The ciphertext input we want to decrypt
    ,input [7:0] secret_key     // The public key that we will use to decrypt the ciphertext
    ,output reg [7:0] plaintext // The output plaintext calculated as P[i] = (C[i] + Sk + Q) modp
    ,output reg dec_ready       // The output bit indicating when the output (the plaintext) is ready
    /*
    The output reporting that the ciphertext given as input was invalid. 
    Its value is calculated after finding the corresponding plaintext 
    and verifying that it was a lowercase letter.
    */
    ,output reg err_invalid_ctxt_char 
);

//---------------------------------------------------------------------------
// VARIABLES
//---------------------------------------------------------------------------

// Submodule variables definition
/*
MAX_VALUE is the parameter indicating the maximum value that the sum can assume
ciphertext = 255 secret_key = 226 Q = 225 -> ciphertext + secret_key + Q = 706
To avoid errors we also consider cases with secret_key between 227 and 255,
the wire that checks the secret_key value ensures that invalid output is not generated.
255 + 255 + 225 = 735
*/
localparam MAX_VALUE = 10'd735;
reg[9:0] sum;
reg[9:0] result;

//---------------------------------------------------------------------------
// LOGIC DESIGN
//---------------------------------------------------------------------------

always @ (*) begin
    // selection worth 1 if mode is 2'b11
    if(selection) begin
        sum = ciphertext + secret_key + Q;
        // The sum is between 681 (227 * 3) and 735
        if(sum >= 10'h2A9 && sum <= MAX_VALUE) begin
            result = sum - 10'h2A9;
        end
        // The sum is between 454 (227 * 2) and 680
        else if (sum >= 10'h1C6 && sum < 10'h2A9) begin
            result = sum - 10'h1C6;
        end
        // The sum is between 227 and 453
         else if (sum >= 10'hE3 && sum < 10'h1C6) begin
            result = sum - 10'hE3;
        end
        // The sum is lower than 227
        else begin
            result = sum;
        end
        plaintext = result[7:0];

        // The resulting plaintext is a lowercase letter
        if(plaintext >= LOWERCASE_A_CHAR && plaintext <= LOWERCASE_Z_CHAR) begin
            dec_ready = 1'b1;
            err_invalid_ctxt_char = 1'b0;
        end
        // The resulting plaintext is not a lowercase letter
        else begin
            err_invalid_ctxt_char = 1'b1;
            dec_ready = 1'b0;
            plaintext = `NULL_CHAR;
        end
    end
     // This is the case when the circuit was not selected, mode != 2'b11
    else begin
        result = 10'h0;
        sum = 10'h0;
        err_invalid_ctxt_char = 1'b0;
        plaintext = `NULL_CHAR;
        dec_ready = 1'b0;
    end
end

endmodule

// Top-level module

module sae (
     input clk
    ,input rst_n
    ,input [1:0] mode               // The mode selected by the user
    ,input [7:0] data_input         // The data input provided by the user, may be a plaintext or a ciphertext depending on the mode chosen
    ,input [7:0] key_input          // The key input provided by the user, may be a secret key or a public key depending on the mode chosen
    ,output reg [7:0] data_output   // The output of the module, can be a public key, a plaintext or a ciphertext depending on the mode chosen
    ,input inputs_valid             // The user-supplied bit that indicates when inputs are valid and can be sampled by the module
    ,output reg output_ready        // The output bit indicating when the output is ready
    ,output err_invalid_ptxt_char   // The output bit indicating that the plaintext is invalid
    ,output err_invalid_seckey      // The output bit indicating that the secret key is invalid
    ,output err_invalid_ctxt_char   // The output bit indicating that the ciphertext is invalid
);

// Support variable that samples the value of inputs_valid, allows to avoid errors due to timing and input variations
reg in_valid;
// Register in which the value of data_input is sampled
reg [7:0] data;
// Register in which the value of key_input is sampled
reg [7:0] key;
// Variable that enters input to key-pair generation and decryption submodules
reg [7:0]secret_key;
// Variable that enters input to encryption submodule
reg [7:0]public_key;
// Variable that enables selection for the key-pair generation submodule
reg pkg_sel;
// Output wire indicating when the output of the key-pair generation submodule is ready
wire pkg_ready;
// Output wire indicating the output of the key-pair generation submodule
wire [7:0] pkg_output;
// Variable that enables selection for the encryption submodule
reg enc_sel;
// Output wire indicating when the output of the encryption submodule is ready
wire enc_ready;
// Output wire indicating the output of the encryption submodule
wire [7:0] enc_output;
// Variable that enables selection for the decryption submodule
reg dec_sel;
// Output wire indicating when the output of the decryption submodule is ready
wire dec_ready;
// Output wire indicating the output of the decryption submodule
wire [7:0] dec_output;
/*
Variables that take the value of data and go into the input 
to the encryption or decryption submodule depending on the mode
*/
reg [7:0] ciphertext;
reg [7:0] plaintext;

public_key_gen_mod public_key_gen (
    .clk                    (clk)
    ,.rst_n                 (rst_n)
    ,.selection             (pkg_sel)
    ,.secret_key            (secret_key)
    ,.public_key            (pkg_output)
    ,.pkg_ready             (pkg_ready)
);

encryption_mod encryption(
    .clk                    (clk)
    ,.rst_n                 (rst_n)
    ,.selection             (enc_sel)
    ,.plaintext             (plaintext)
    ,.public_key            (public_key)
    ,.ciphertext            (enc_output)
    ,.enc_ready             (enc_ready)
);

decryption_mod decryption(
    .clk                    (clk)
    ,.rst_n                 (rst_n)
    ,.selection             (dec_sel)
    ,.ciphertext            (ciphertext)
    ,.secret_key            (secret_key)
    ,.plaintext             (dec_output)
    ,.dec_ready             (dec_ready)
    ,.err_invalid_ctxt_char (err_invalid_ctxt_char)
);


/* 
err_invalid_seckey is worth 1 when the mode is 2'b01 or 2'b11 and the key is 0 or greater than 226
err_invalid_ptxt_char is worth 1 when the mode is 2'b10 and the plaintext is not a lowercase letter
Checking on in_valid avoids having errors in the transition phase of the inputs, which would block the whole circuit
*/
assign err_invalid_seckey = (mode[0] == 1'b1) && (key < 1 || key > P - 1) && in_valid == 1'b1;
assign err_invalid_ptxt_char = (mode == 2'b10) && (data < LOWERCASE_A_CHAR || data > LOWERCASE_Z_CHAR) && in_valid == 1'b1;

/*
This block always allows the sampled values to be assigned to the correct variables 
(which will be the input to the submodules) depending on the mode received
*/
always @(*) begin
    // Assignment occurs only if there are no errors in the input data and if in_valid is 1
    if(!err_invalid_seckey && !err_invalid_ptxt_char && !inputs_valid) begin
        case(mode)
        // Key-pair generation
        2'b01: begin
            ciphertext = `NULL_CHAR;
            plaintext = `NULL_CHAR;
            secret_key = key; 
            public_key = `NULL_CHAR;
            pkg_sel = 1'b1; 
            enc_sel = 1'b0; 
            dec_sel = 1'b0;
            end
        // Encryption
        2'b10: begin 
            ciphertext = `NULL_CHAR;
            plaintext = data;
            secret_key = `NULL_CHAR;
            public_key = key; 
            pkg_sel = 1'b0; 
            enc_sel = 1'b1; 
            dec_sel = 1'b0;     
            end
        // Decryption
        2'b11: begin 
            ciphertext = data; 
            plaintext = `NULL_CHAR;
            secret_key = key; 
            public_key = `NULL_CHAR;
            pkg_sel = 1'b0; 
            enc_sel = 1'b0; 
            dec_sel = 1'b1;   
            end
        // 2'b00 -> no action
        default: begin 
            ciphertext = `NULL_CHAR;
            plaintext = `NULL_CHAR;
            secret_key = `NULL_CHAR;
            public_key = `NULL_CHAR;
            pkg_sel = 1'b0; 
            enc_sel = 1'b0; 
            dec_sel = 1'b0;
            end
        endcase
    end
    // This is the case when the inputs are invalid
    else begin
        ciphertext = `NULL_CHAR;
        plaintext = `NULL_CHAR;
        secret_key = `NULL_CHAR;
        public_key = `NULL_CHAR;
        pkg_sel = 1'b0; 
        enc_sel = 1'b0; 
        dec_sel = 1'b0;
    end
end

/*
This block always allows you to reset output_ready to 0 when the mode changes (we have a new input)
*/
always @(mode) begin
    output_ready <= 1'b0;
end

// This is the always block that allows the input and output values to be sampled at each clock
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		data <= `NULL_CHAR;
		key <= `NULL_CHAR;
        in_valid <= 1'b0;
	end
    else begin
        // If there are no errors, the value of in_valid is sampled from that of inputs_valid
        if(!err_invalid_seckey && !err_invalid_ptxt_char) begin
            in_valid <= inputs_valid;
        end
        /*
        In the presence of errors, the value of in_valid remains stable so that it does not go to 0. 
        If it went to 0, the err_invalid_seckey and err_invalid_ptxt_char errors would not be flagged, 
        leading to calculations being performed with invalid values.
        */
        else begin
            in_valid <= in_valid;
        end
		if(inputs_valid) begin
			data <= data_input;
			key <= key_input;
		end
		else begin
			data <= data;
			key <= key;
		end
        case(mode)
        2'b01: begin
            output_ready <= pkg_ready;
            data_output <= pkg_output;
        end
        2'b10: begin
            output_ready <= enc_ready;
            data_output <= enc_output;
        end
        2'b11: begin
            output_ready <= dec_ready;
            data_output <= dec_output;
        end
        default: begin
            output_ready <= 1'b0;
            data_output <= `NULL_CHAR;
        end
        endcase
        end
end
endmodule
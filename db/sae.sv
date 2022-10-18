`define NULL_CHAR 8'h00

localparam LOWERCASE_A_CHAR = 8'h61;
localparam LOWERCASE_Z_CHAR = 8'h7A;
localparam Q = 8'd225;
localparam P = 8'd227;

module public_key_gen_mod(
     input  clk
    ,input  rst_n 
    ,input  selection   // 2'b01 è la modalità per decifrare
    ,input  [7:0] secret_key
    ,output reg [7:0] public_key
    ,output reg pkg_ready
);
//---------------------------------------------------------------------------
// VARIABLES
//---------------------------------------------------------------------------

localparam P_MAX = 9'b111000011; /*451*/


reg [8:0] sum;  // va da 1 a 451
reg [8:0] result; // va da 1 a 224
// reg tmp_output_ready;
// reg [7:0] tmp_public_key;

//---------------------------------------------------------------------------
// LOGIC DESIGN
//---------------------------------------------------------------------------


always @ (*) begin

    if(selection == 1'b1) begin
        sum = secret_key + Q;
        if(sum >= 9'b000000001 && sum < P) begin
            result = sum;
            pkg_ready = 1'b1; 
        end
        else begin
            result = sum - P;
            pkg_ready = 1'b1;
        end
        public_key = result[7:0];
    end
    else begin
        result = 9'h0;
        sum = 9'h0;
        public_key = `NULL_CHAR;
        pkg_ready = 1'b0;
    end
end

/*
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		pkg_ready <= 1'b0;
		public_key <= `NULL_CHAR;
	end
    else begin
		if(tmp_output_ready) begin
			pkg_ready <= 1'b1;
			public_key <= tmp_public_key;
		end
		else begin
			pkg_ready <= 1'b0;
		    public_key <= `NULL_CHAR;
		end
	end
end

*/

endmodule

module encryption_mod(
     input  clk
    ,input rst_n 
    ,input  selection   // 2'b10 è la modalità per cifrare
    ,input  [7:0] plaintext
    ,input  [7:0] public_key
    ,output reg [7:0] ciphertext
    ,output reg enc_ready
);
//---------------------------------------------------------------------------
// VARIABLES
//---------------------------------------------------------------------------

reg signed [8:0] sub;  // va da -227 a +256
reg[8:0] result;
// reg[7:0] temp_ciphertext;
// reg tmp_output_ready;

//---------------------------------------------------------------------------
// LOGIC DESIGN
//---------------------------------------------------------------------------

always @ (*) begin
    if(selection) begin
        sub = plaintext - public_key;
        if (sub < $signed(9'd0))begin                            //-227<= sub <0
            result = sub + $signed(P);
            ciphertext = result[7:0];
            enc_ready = 1'b1;
        end
         else if (sub >= 9'd0 && sub < 9'd227) begin     // 0 <= sub <= 227
            result = sub;
            ciphertext = result[7:0];
            enc_ready = 1'b1;
        end
        else begin     // 228<= sub <=256
            result = sub - P;
            ciphertext = result[7:0];
            enc_ready = 1'b1;
        end
       
    end
    else begin
        sub = 9'h0;
        result = 9'h0;
        ciphertext = `NULL_CHAR;
        enc_ready = 1'b0;
    end
end

/*
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		enc_ready <= 1'b0;
		ciphertext <= `NULL_CHAR;
	end
    else begin
		if(tmp_output_ready) begin
			enc_ready <= 1'b1;
            ciphertext <= temp_ciphertext; 
           
		end
		else begin
			enc_ready <= 1'b0;            
			ciphertext <= `NULL_CHAR;
		end
	end
end
*/

endmodule

module decryption_mod (
     input clk
    ,input rst_n
    ,input selection // 2'b11 è la modalità per decifrare
    ,input [7:0] ciphertext
    ,input [7:0] secret_key
    ,output reg [7:0] plaintext
    ,output reg dec_ready
    ,output reg err_invalid_ctxt_char
);

//---------------------------------------------------------------------------
// VARIABLES
//---------------------------------------------------------------------------

localparam MAX_VALUE = 10'd735;

reg[9:0] sum;
reg[9:0] result;
//reg [7:0] tmp_plaintext;
//reg tmp_output_ready;

//---------------------------------------------------------------------------
// LOGIC DESIGN
//---------------------------------------------------------------------------

// assign err_invalid_seckey = secret_key < 1 || secret_key > P - 1;


/*  SOLUZIONE CON OPERATORE MODULO -> Megafunction lpm_divide in QUARTUS

always @ (*) begin

    if(!err_invalid_seckey && mode == 2'b11) begin
        tmp_plaintext = (ciphertext + secret_key + Q) % P;
        tmp_output_ready = 1'b1; 
    end
    else begin
        tmp_plaintext = `NULL_CHAR;
        tmp_output_ready = 1'b0;
    end
end
*/

// SOLUZIONE CON SOTTRAZIONE PER IL MODULO
always @ (*) begin

    if(/* !err_invalid_seckey  && */ selection) begin

        sum = ciphertext + secret_key + Q;

        if(sum >= 10'h2A9 && sum <= MAX_VALUE) begin
            result = sum - 10'h2A9;
        end
        else if (sum >= 10'h1C6 && sum < 10'h2A9) begin
            result = sum - 10'h1C6;
        end
         else if (sum >= 10'hE3 && sum < 10'h1C6) begin
            result = sum - 10'hE3;
        end
        else begin
            result = sum;
        end

        plaintext = result[7:0];

        // Il plaintext ottenuto è una lettera minuscola
        if(plaintext >= LOWERCASE_A_CHAR && plaintext <= LOWERCASE_Z_CHAR) begin
            dec_ready = 1'b1;
            err_invalid_ctxt_char = 1'b0;
        end
        else begin
            // Il plaintext ottenuto non è una lettera minuscola
            err_invalid_ctxt_char = 1'b1;
            dec_ready = 1'b0;
            plaintext = `NULL_CHAR;
        end
    end
    else begin
        result = 10'h0;
        sum = 10'h0;
        err_invalid_ctxt_char = 1'b0;
        plaintext = `NULL_CHAR;
        dec_ready = 1'b0;
    end
end

/*

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		dec_ready <= 1'b0;
		plaintext <= `NULL_CHAR;
	end
    else begin
		if(tmp_output_ready) begin
			dec_ready <= 1'b1;
			plaintext <= tmp_plaintext;
		end
		else begin
			dec_ready <= 1'b0;
			plaintext <= `NULL_CHAR;
		end
	end
end

*/

endmodule

// Top-level module

module sae (
     input clk
    ,input rst_n
    ,input [1:0] mode
    ,input [7:0] data_input
    ,input [7:0] key_input
    ,output reg [7:0] data_output
    ,input inputs_valid
    ,output reg output_ready
    ,output err_invalid_ptxt_char
    ,output err_invalid_seckey
    ,output err_invalid_ctxt_char
);

reg in_valid;
reg [7:0] data;
reg [7:0] key;
reg [7:0]secret_key;
reg [7:0]public_key;
reg pkg_sel;
wire pkg_ready;
wire [7:0] pkg_output;
reg enc_sel;
wire enc_ready;
wire [7:0] enc_output;
reg dec_sel;
wire dec_ready;
wire [7:0] dec_output;
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

assign err_invalid_seckey = (mode[0] == 1'b1) && (key < 1 || key > P - 1);
assign err_invalid_ptxt_char = (mode == 2'b10) && (data_input < LOWERCASE_A_CHAR || data_input > LOWERCASE_Z_CHAR) && in_valid == 1'b1;

always @(*) begin
    if(!err_invalid_seckey && !err_invalid_ptxt_char && !inputs_valid) begin
        case(mode)
        2'b01: begin
            ciphertext = `NULL_CHAR;
            plaintext = `NULL_CHAR;
            secret_key = key; 
            public_key = `NULL_CHAR;
            pkg_sel = 1'b1; 
            enc_sel = 1'b0; 
            dec_sel = 1'b0;
            //output_ready = pkg_ready;
            //data_output =  pkg_output;
            end
        2'b10: begin 
            ciphertext = `NULL_CHAR;
            plaintext = data;
            secret_key = `NULL_CHAR;
            public_key = key; 
            pkg_sel = 1'b0; 
            enc_sel = 1'b1; 
            dec_sel = 1'b0;     
            //output_ready = enc_ready; 
            //data_output = enc_output;
            end
        2'b11: begin 
            ciphertext = data; 
            plaintext = `NULL_CHAR;
            secret_key = key; 
            public_key = `NULL_CHAR;
            pkg_sel = 1'b0; 
            enc_sel = 1'b0; 
            dec_sel = 1'b1;   
            //output_ready = dec_ready; 
            //data_output = dec_output;
            end
        default: begin 
            ciphertext = `NULL_CHAR;
            plaintext = `NULL_CHAR;
            secret_key = `NULL_CHAR;
            public_key = `NULL_CHAR;
            pkg_sel = 1'b0; 
            enc_sel = 1'b0; 
            dec_sel = 1'b0;
            //output_ready = 1'b0;
            //data_output = `NULL_CHAR;
            end
        endcase
    end
    else begin
        ciphertext = `NULL_CHAR;
        plaintext = `NULL_CHAR;
        secret_key = `NULL_CHAR;
        public_key = `NULL_CHAR;
        pkg_sel = 1'b0; 
        enc_sel = 1'b0; 
        dec_sel = 1'b0;
        //output_ready = 1'b0;
        //data_output = `NULL_CHAR;
    end
end

always @(mode) begin
    output_ready <= 1'b0;
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		data <= `NULL_CHAR;
		key <= `NULL_CHAR;
        in_valid <= 1'b0;
	end
    else begin
        in_valid <= inputs_valid;
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
/* 𝑃[𝑖]=(𝐶[𝑖]+ 𝑆𝐾 +𝑞)𝑚𝑜𝑑𝑝 */

`define NULL_CHAR 8'h00

module decryption (
     input clk
    ,input rst_n
    ,input [1:0] mode // 2'b11 è la modalità per decifrare
    ,input [7:0] ciphertext
    ,input [7:0] secret_key
    ,output reg [7:0] plaintext
    ,output reg output_ready
    ,output err_invalid_seckey
    ,output reg err_invalid_ctxt_char
);

//---------------------------------------------------------------------------
// VARIABLES
//---------------------------------------------------------------------------

localparam LOWERCASE_A_CHAR = 8'h61;
localparam LOWERCASE_Z_CHAR = 8'h7A;
localparam MAX_VALUE = 10'd735;
localparam Q = 8'd225;
localparam P = 8'd227;

reg[9:0] sum;
reg[9:0] result;
reg [7:0] tmp_plaintext;
reg tmp_output_ready;

//---------------------------------------------------------------------------
// FUNCTIONS
//---------------------------------------------------------------------------

function reg inbetween(input low, value, high); 
    begin
        inbetween = value >= low && value <= high;
    end
endfunction


//---------------------------------------------------------------------------
// LOGIC DESIGN
//---------------------------------------------------------------------------

assign err_invalid_seckey = secret_key < 1 || secret_key > P - 1;


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

    if(!err_invalid_seckey && mode == 2'b11) begin
        /* NON VA BENE PERCHÈ QUARTUS NON SUPPORTA CASE INSIDE
        case (ciphertext + secret_key + Q) inside                                   // il massimo valore della somma è 255 + 255 + 225 = 735
        [10'h2A9 : 10'h2DF]: tmp_plaintext = ciphertext + secret_key + Q - 10'h2A3;  // sottraggo 3 volte il modulo 227
        [10'h1C6 : 10'h2A8]: tmp_plaintext = ciphertext + secret_key + Q - 10'h1C2;  // sottraggo 2 volte il modulo 227
        [10'hE3 : 10'h1C5]:  tmp_plaintext = ciphertext + secret_key + Q - 10'hE1;   // sottraggo 1 volta il modulo 227
        default:           tmp_plaintext = (ciphertext + secret_key + Q);           // la somma è minore di 227
        endcase
        */
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
        tmp_plaintext = result[7:0];
        // Il plaintext ottenuto è una lettera minuscola
        if(tmp_plaintext >= LOWERCASE_A_CHAR && tmp_plaintext <= LOWERCASE_Z_CHAR) begin
            tmp_output_ready = 1'b1;
            err_invalid_ctxt_char = 1'b0;
        end
        else begin
            // Il plaintext ottenuto non è una lettera minuscola
            err_invalid_ctxt_char = 1'b1;
            tmp_output_ready = 1'b0;
            tmp_plaintext = `NULL_CHAR;
        end
    end
    else begin
        result = 10'h0;
        sum = 10'h0;
        err_invalid_ctxt_char = 1'b0;
        tmp_plaintext = `NULL_CHAR;
        tmp_output_ready = 1'b0;
    end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		output_ready <= 1'b0;
		plaintext <= `NULL_CHAR;
	end
    else begin
		if(tmp_output_ready && !err_invalid_seckey) begin
			output_ready <= 1'b1;
			plaintext <= tmp_plaintext;
		end
		else begin
			output_ready <= 1'b0;
			plaintext <= `NULL_CHAR;
		end
	end
end

endmodule
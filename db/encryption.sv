/*C[i]=(P[i]-Pk)mod p*/
`define NULL_CHAR 8'h00

module encryption(
     input  clk
    ,input rst_n 
    ,input  [1:0] mode   // 2'b10 è la modalità per decifrare
    ,input  [7:0] Plaintext
    ,input  [7:0] Public_key
    ,output [7:0] Char_ciphertext
    ,output reg C_ready
    ,output reg err_invalid_ptxt
);
//---------------------------------------------------------------------------
// VARIABLES
//---------------------------------------------------------------------------

localparam LOWERCASE_A_CHAR = 8'h61;
localparam LOWERCASE_Z_CHAR = 8'h7A;
localparam P = 8'd227;

reg[7:0] sub;  // va da -227 a +256
reg[7:0] result;
reg tmp_C_ready;

//---------------------------------------------------------------------------
// LOGIC DESIGN
//---------------------------------------------------------------------------
assign err_invalid_ptxt =  (Plaintext >= LOWERCASE_A_CHAR) &&
                            (Plaintext <= LOWERCASE_Z_CHAR);
p_par = 8'b11100011;/*227*/

always @ (*) begin
    if(!err_invalid_ptxt && mode == 2'b10) begin
        sub = Plaintext - Public_key;
        if(sub >=8'b00011101  && sub < 8'b00000000) begin           //-227<= sub <0
            result = sub + p_par;
            tmp_C_ready = 1'b1;
        end
        else if (sub >=8'b11100100 && sub <= 8'b11111111 ) begin     // 228<= sub <=256
            result = sub - p_par;
            tmp_C_ready = 1'b1;
        end
        else if (sub >=8'b00000000 && sub <= 8'b11100011 ) begin     // 0 <= sub <= 227
            result = sub;
            tmp_C_ready = 1'b1;
        end
    end
    else begin
        result = 8'b00000000;
        sub = 8'b00000000;
        err_invalid_ptxt = 1'b0;
        Char_ciphertext = `NULL_CHAR;
        tmp_C_ready = 1'b0;
    end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		C_ready <= 1'b0;
		Char_ciphertext <= `NULL_CHAR;
	end
    else begin
		if(tmp_C_ready && !err_invalid_ptxt) begin
			C_ready <= 1'b1;
		end
		else begin
			C_ready <= 1'b0;
			Char_ciphertext <= `NULL_CHAR;
		end
	end
end
endmodule

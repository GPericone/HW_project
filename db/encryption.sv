/*C[i]=(P[i]-Pk)mod p*/
`define NULL_CHAR 8'h00

module encryption(
     input  clk
    ,input rst_n 
    ,input  [1:0] mode   // 2'b10 è la modalità per decifrare
    ,input  [7:0] Plaintext
    ,input  [7:0] Public_key
    ,output reg [7:0] Char_ciphertext
    ,output reg C_ready
    ,output reg err_invalid_ptxt
);
//---------------------------------------------------------------------------
// VARIABLES
//---------------------------------------------------------------------------

localparam LOWERCASE_A_CHAR = 8'h61;
localparam LOWERCASE_Z_CHAR = 8'h7A;
localparam p_par = 9'b011100011; /*227*/

reg signed [8:0] sub;  // va da -227 a +256
reg[7:0] result;
reg[8:0] temporaneo;
reg tmp_C_ready;

//---------------------------------------------------------------------------
// LOGIC DESIGN
//---------------------------------------------------------------------------
assign err_invalid_ptxt =  (Plaintext < LOWERCASE_A_CHAR) ||
                            (Plaintext > LOWERCASE_Z_CHAR);

always @ (*) begin
    if(!err_invalid_ptxt && mode == 2'b10) begin
        sub = Plaintext - Public_key;
        if (sub < 9'd0)begin                            //-227<= sub <0
            temporaneo = sub + p_par;
            result = temporaneo[7:0];
            tmp_C_ready = 1'b1;
        end
         else if (sub >= 9'd0 && sub <= 9'd227 ) begin     // 0 <= sub <= 227
            temporaneo = sub;
            result = temporaneo[7:0];
            tmp_C_ready = 1'b1;
        end
        else begin     // 228<= sub <=256
            temporaneo = sub - p_par;
            result = temporaneo[7:0];
            tmp_C_ready = 1'b1;
        end
       
    end
    else begin
        result = `NULL_CHAR;
        sub = 9'b000000000;
        temporaneo = 9'b000000000 ;
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
            Char_ciphertext <= result; 
           
		end
		else begin
			C_ready <= 1'b0;            
			Char_ciphertext <= `NULL_CHAR;
		end
	end
end
endmodule

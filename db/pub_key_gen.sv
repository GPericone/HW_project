/*Pk=(Sk+q)modp*/
`define NULL_CHAR 8'h00

module public_key_gen(
     input  clk
    ,input rst_n 
    ,input  [1:0] mode   // 2'b01 è la modalità per decifrare
    ,input  [7:0] Secret_key
    ,output reg [7:0] Public_key
    ,output reg P_K_ready
    ,output reg err_invalid_seckey
);
//---------------------------------------------------------------------------
// VARIABLES
//---------------------------------------------------------------------------

localparam p_par = 8'b11100011;//9'b011100011;/*227*/
localparam p_max = 9'b111000011; /*451*/
localparam q_par = 8'b011100001; /*225*/

reg [8:0] sum;  // va da 1 a 451
reg [8:0] result; // va da 1 a 224
reg tmp_P_K_ready;
reg [7:0] tmp_publicKey;


//---------------------------------------------------------------------------
// LOGIC DESIGN
//---------------------------------------------------------------------------

assign err_invalid_seckey = secret_key < 8'b00000001 || secret_key > {p_par - 8'b00000001};//p_par - 9'b000000001;

always @ (*) begin

    if(!err_invalid_seckey && mode == 2'b01) begin
        sum = secret_key + q_par;
        if(sum >= 9'b000000001 && sum <={1'b0 , p_par}) begin
            result = sum;
            tmp_P_K_ready = 1'b1; 
        end
        else if(sum > 9'b000000001 && sum <= p_max) begin
            result = sum - {1'b0 , p_par};
            tmp_P_K_ready = 1'b1;
        end
        tmp_publicKey = result[7:0];
    end
    else begin
        result = 9'b000000000;
        sum = 9'b000000000;
        err_invalid_seckey= 1'b0;
        tmp_publicKey = `NULL_CHAR;
        tmp_P_K_ready = 1'b0;
    end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		P_K_ready <= 1'b0;
		Public_key <= `NULL_CHAR;
	end
    else begin
		if(tmp_P_K_ready && !err_invalid_seckey) begin
			P_K_ready <= 1'b1;
			Public_key <= tmp_publicKey;
		end
		else begin
			P_K_ready <= 1'b0;
		    Public_key <= `NULL_CHAR;
		end
	end
end
endmodule
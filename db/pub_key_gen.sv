/*Pk=(Sk+q)modp*/
module encryption(clk,rst_n,Q_par,Secret_key,Public_key,P_K_ready);
input              clk, rst_n;
input         [7:0] Q_par;
input         [7:0] Secret_key;
output        [7:0] Public_key;
output              P_K_ready;

reg [7:0] PUBLIC_KEY;  assign Public_key = PUBLIC_KEY;
reg P_K_READY;         assign P_K_ready = P_K_READY;

reg [7:0] SECRET_KEY;
reg [7:0] Q_PAR;
reg [8:0] COMPUTE;

reg [1:0] STAR;               assign S0=0, S1=1, S2=2;

p_par = 8'B11100011;/*227*/
P_K_ready = 0;

always @(rst_n==0)#1    begin  
                            STAR <= S0; 
                            P_K_READY <= 0;
                            COMPUTE <= 9'B000000000;
                            PUBLIC_KEY <= 8'B00000000;
                            SECRET_KEY <= 8'B00000000;
                            Q_PAR <= 8'B00000000;
                        end
always @ (posedge clk) if (rst_n == 1 & mode == 2'B01) #3
    casex (STAR)
        S0: begin SECRET_KEY <= Secret_key; Q_PAR <= Q_par; STAR <= (Secret_key == 8'B00000000 || Q_par == 8'B00000000)? S0 : S1; end
        S1: begin COMPUTE <= (SECRET_KEY[7:0] + Q_par[7:0]); STAR <= S2; end
        S2: begin PUBLIC_KEY <= (COMPUTE [8:0] - p_par); STAR <=S3; end  /*qui faccio il modulo grazie alla sottrazione*/
        S3: begin PUBLIC_KEY <= PUBLIC_KEY[7:0]; P_K_READY <=1; end   /* riporto public_key su 8 bit  */

    endcase

endmodule



  /*
module key_pair_generation(
    input            clk
  ,input            rst_n
  ,input      [7:0] q_par
  ,input      [7:0] secret_key
  ,input      [1:0] mode
  ,input      [7:0] p_par
  ,output reg       P_K_ready
  ,output reg [7:0] Public_key
)

wire somma_key_pair_generation; 

assign somma_key_pair_generation = secret_key + q_par;
q_par = 225; 
p_par = 227;
P_K_ready = 0;

always @ (*)
if(secret_key > 1 && secret_key < (p_par - 1))begin
    Public_key = somma_key_pair_generation % p_par;
    P_K_ready = 1;
else (
    P_K_ready = 0;
)
end
endmodule
*/








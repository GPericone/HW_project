/*C[i]=(P[i]-Pk)mod p*/
module encryption(clk,rst_n,Plaintext,Public_key,mode,Char_ciphertext,C_ready);
input              clk, rst_n; 
input         [7:0] Plaintext;
input         [7:0] Public_key;
output        [7:0] Char_ciphertext;
output              C_ready;

reg [7:0] CHAR_CIPHERTEXT;  assign Char_ciphertext = CHAR_CIPHERTEXT;
reg C_READY;                assign C_ready = C_READY;
reg [7:0] PUBLIC_KEY;
reg [7:0] PLAINTEXT;
reg [7:0] COMPUTE;


reg [1:0] STAR;               assign S0=0, S1=1, S2=2;

p_par = 8'B11100011;/*227*/
C_ready = 0;

always @(rst_n==0)#1    begin  
                            STAR <= S0; 
                            C_READY <= 0;
                            COMPUTE <= 8'B00000000;
                            CHAR_CIPHERTEXT <= 8'B00000000;
                            PUBLIC_KEY <= 8'B00000000;
                            PLAINTEXT <= 8'B00000000;
                        end
always @ (posedge clk) if (rst_n == 1 & mode == 2'B10) #3
    casex (STAR)
        S0: begin PUBLIC_KEY <= Public_key; PLAINTEXT <= Plaintext; STAR <= (Public_key == 8'B00000000 || Plaintext == 8'B00000000)? S0 : S1; end
        S1: begin COMPUTE <= (PLAINTEXT[7:0] - PUBLIC_KEY[7:0]); STAR <= S2; end
        S2: begin CHAR_CIPHERTEXT <= (COMPUTE [7:0] - p_par); C_READY <=1; end      /*qui faccio il modulo grazie alla sottrazione*/
    endcase

endmodule




/*
always @ (*)
// xP controllo se effettivamente ho una chiave pub. nuova
// Xm guardare Pub_key_gen.sv per variabili mancanti, visto che questo pezzo di codice va unito all'altro
if(!P_K_ready)begin
    Char_ciphertext = diff_encryption % p_par;
    C_ready = 1; 
else (
    C_ready = 0;
)
end
*/
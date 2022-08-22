module decryption_tb_checks;

reg clk = 1'b0;
always #10 clk = !clk;

reg rst_n = 1'b1;

localparam NUL_CHAR = 8'h00;

reg [1:0] mode = 2'b11;
reg [7:0] ciphertext = NUL_CHAR;
reg [7:0] secret_key = NUL_CHAR;
wire err_invalid_seckey;
wire [7:0] plaintext;
wire output_ready;
wire err_invalid_ctxt_char;

/*

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

*/

decryption sae_dec (
    .clk                    (clk)
    ,.rst_n                 (rst_n)
    ,.mode                  (mode)
    ,.ciphertext            (ciphertext)
    ,.secret_key            (secret_key)
    ,.plaintext             (plaintext)
    ,.output_ready          (output_ready)
    ,.err_invalid_seckey    (err_invalid_seckey)
    ,.err_invalid_ctxt_char (err_invalid_ctxt_char)
);

initial begin
    // Test iniziale, tutti i dati corretti
    @(posedge clk);
    ciphertext = 8'h7F; // ciphertext di b
    secret_key = 8'hc8; // 200

    @(posedge clk);
    @(posedge clk);		
	$display("CIPHERTEXT: %c - SECRET KEY: %h - PLAINTEXT: %c", ciphertext, secret_key, plaintext);

    $stop;

end

endmodule
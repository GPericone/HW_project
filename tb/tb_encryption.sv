// -----------------------------------------------------------------------------
// ---- Testbench for file encryption
// -----------------------------------------------------------------------------

module encryption;

    reg clk = 1'b0;
    always #5 clk = !clk;

    reg rst_n = 1'b0;

    localparam NUL_CHAR = 8'h00;

    reg [1:0] mode = 2'b10;
    reg [7:0] Plaintext = NUL_CHAR; 
    reg [7:0] Public_key = NUL_CHAR;
    wire [7:0] Char_ciphertext;
    wire err_invalid_ptxt;
    wire  C_ready;



    encryption sae_dec(
     .clk                       (clk)
    ,.rst_n                     (rst_n)
    ,.mode                      (mode)
    ,.Plaintext                 (Plaintext)
    ,.Public_key                (Public_key)
    ,.Char_ciphertext           (Char_ciphertext)
    ,.C_ready                   (C_ready)
    ,.err_invalid_ptxt          (err_invalid_ptxt)
    );


    initial begin
        // Test iniziale, tutti i dati corretti
        @(posedge clk);
        Public_key = 8'hc8; // 200
        Plaintext = 8'h7F; // ciphertext di b

        @(posedge clk);
        @(posedge clk);		
        $display("CIPHERTEXT: %c -PUBLIC KEY: %h - PLAINTEXT: %c", Char_ciphertext, Public_key, Plaintext);

        $stop;

    end

endmodule
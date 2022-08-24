// -----------------------------------------------------------------------------
// ---- Testbench for file pub_key_generator
// -----------------------------------------------------------------------------

module pub_key_gen_tb_checks;

    reg clk = 1'b0;
    always #5 clk = !clk;

    reg rst_n = 1'b0;

    localparam NUL_CHAR = 8'h00;

    reg [1:0] mode = 2'b01;
    reg [7:0] Secret_key = NUL_CHAR; 
    wire [7:0] Public_key;
    wire err_invalid_seckey;
    wire  P_K_ready;

    public_key_gen sae_dec(
     .clk                       (clk)
    ,.rst_n                     (rst_n)
    ,.mode                      (mode)
    ,.Secret_key                (Secret_key)
    ,.Public_key                (Public_key)
    ,.P_K_ready                 (P_K_ready)
    ,.err_invalid_seckey        (err_invalid_seckey)
    );


    initial begin
        // Test iniziale, tutti i dati corretti
        @(posedge clk);
        secret_key = 8'hc8; // 200

        @(posedge clk);
        @(posedge clk);		
        $display("SECRET KEY: %h - PUBLICKEY: %h", Secret_key, Public_key);

        $stop;

    end

endmodule
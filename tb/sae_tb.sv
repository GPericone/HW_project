module sae_tb_checks;

    reg clk = 1'b0;
    always #5 clk = !clk;
  
    reg rst_n = 1'b0;
    initial #12.8 rst_n = 1'b1;

    reg [1:0] mode_w;
    reg [7:0] data_input_w;
    reg [7:0] key_input_w;
    reg inputs_valid_w;
    wire output_ready_w;
    wire [7:0] data_output_w;
    wire err_invalid_ptxt_char_w;
    wire err_invalid_seckey_w;
    wire err_invalid_ctxt_char_w;

    sae sae_walt(
     .clk                       (clk)
    ,.rst_n                     (rst_n)
    ,.mode                      (mode_w)
    ,.data_input                (data_input_w)
    ,.key_input                 (key_input_w)
    ,.inputs_valid              (inputs_valid_w)
    ,.data_output               (data_output_w)
    ,.output_ready              (output_ready_w)
    ,.err_invalid_ptxt_char     (err_invalid_ptxt_char_w)
    ,.err_invalid_seckey        (err_invalid_seckey_w)
    ,.err_invalid_ctxt_char     (err_invalid_ctxt_char_w)
    );

    reg [1:0] mode_j;
    reg [7:0] data_input_j;
    reg [7:0] key_input_j;
    reg inputs_valid_j;
    wire output_ready_j;
    wire [7:0] data_output_j;
    wire err_invalid_ptxt_char_j;
    wire err_invalid_seckey_j;
    wire err_invalid_ctxt_char_j;

    sae sae_jesse(
     .clk                       (clk)
    ,.rst_n                     (rst_n)
    ,.mode                      (mode_j)
    ,.data_input                (data_input_j)
    ,.key_input                 (key_input_j)
    ,.inputs_valid              (inputs_valid_j)
    ,.data_output               (data_output_j)
    ,.output_ready              (output_ready_j)
    ,.err_invalid_ptxt_char     (err_invalid_ptxt_char_j)
    ,.err_invalid_seckey        (err_invalid_seckey_j)
    ,.err_invalid_ctxt_char     (err_invalid_ctxt_char_j)
    );

    int FILE;

	initial begin
        @(posedge rst_n);
    
        @(posedge clk);
        FILE = $open("tv/privatekey_w.txt", "r");
        if (FILE)  
            $display("File was opened successfully : %0d", FILE);
        else    
            $display("File was NOT opened successfully : %0d", FILE);
        $fgets(key_input_w, FILE);
        $write("Private key loaded");
    end

endmodule

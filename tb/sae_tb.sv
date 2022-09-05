// -----------------------------------------------------------------------------
// ---- Testbench for top_level module
// -----------------------------------------------------------------------------
module sae_tb;
    reg clk = 1'b0;         // set the clock to 0
    reg rst_n = 1'b0;       // set the reset register to 0

    reg [1:0] output_ready;
    wire [7:0] data_output;
    wire err_invalid_ptxt_char;
    wire err_invalid_seckey;
    wire err_invalid_ctxt_char;

    sae sae_mod(
     .clk                       (clk)
    ,.rst_n                     (rst_n)
    ,.mode                      (mode)
    ,.data_input                (data_input)
    ,.key_input                 (key_input)
    ,.inputs_valid              (inputs_valid)
    ,.data_output               (data_output)
    ,.output_ready              (output_ready)
    ,.err_invalid_ptxt_char     (err_invalid_ptxt_char)
    ,.err_invalid_seckey        (err_invalid_seckey)
    ,.err_invalid_ctxt_char     (err_invalid_ctxt_char)
    );

    always #10 clk = !clk;   // set the clock time

	initial begin
		@(posedge clk) rst_n = 1'b1;
	end

    //simulation begin
	initial begin

    end

endmodule

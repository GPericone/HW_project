module corner_cases_checks.sv;

    reg clk = 1'b0;
    always #5 clk = !clk;
  
    reg rst_n = 1'b0;
    initial #12.8 rst_n = 1'b1;

    reg [1:0] mode;
    reg [7:0] data_input;
    reg [7:0] key_input;
    reg inputs_valid;
    wire output_ready;
    wire [7:0] data_output;
    wire err_invalid_ptxt_char;
    wire err_invalid_seckey;
    wire err_invalid_ctxt_char;

    sae sae_corner(
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

    // Initialize variables for test cases
    reg [7:0] expected_data_output;
    reg expected_output_ready;
    reg expected_err_invalid_ptxt_char;
    reg expected_err_invalid_seckey;
    reg expected_err_invalid_ctxt_char;

    initial begin
        @(posedge rst_n);
        @(posedge clk);

        // Test case 1: Generate public key with private key == 1
        mode = 2'b01;
        data_input = 8'h00;
        key_input = 8'h01;
        inputs_valid = 1'b1;
        expected_data_output = 8'hE2;
        expected_output_ready = 1'b1;
        expected_err_invalid_ptxt_char = 1'b0;
        expected_err_invalid_seckey = 1'b0;
        expected_err_invalid_ctxt_char = 1'b0;

        @(posedge clk);
        inputs_valid_w = 1'b0;

        wait(output_ready == 1'b1);
        
        // Check outputs of test case 1
        assert(data_output == expected_data_output)
          else $error("Test case 1: Unexpected data_output value");
        assert(output_ready == expected_output_ready)
          else $error("Test case 1: Unexpected output_ready value");
        assert(err_invalid_ptxt_char == expected_err_invalid_ptxt_char)
          else $error("Test case 1: Unexpected err_invalid_ptxt_char value");
        assert(err_invalid_seckey == expected_err_invalid_seckey)
          else $error("Test case 1: Unexpected err_invalid_seckey value");
        assert(err_invalid_ctxt_char == expected_err_invalid_ctxt_char)
          else $error("Test case 1: Unexpected err_invalid_ctxt_char value");
        $display("Test case 1: PASSED");

        mode_w = 2'b00;
        @(posedge clk);

        // Test case 2: Generate public key with private key == 226
        mode = 2'b01;
        data_input = 8'h00;
        key_input = 8'hE2;
        inputs_valid = 1'b1;
        expected_data_output = 8'hE0;
        expected_output_ready = 1'b1;
        expected_err_invalid_ptxt_char = 1'b0;
        expected_err_invalid_seckey = 1'b0;
        expected_err_invalid_ctxt_char = 1'b0;

        @(posedge clk);
        inputs_valid_w = 1'b0;

        wait(output_ready == 1'b1);
        
        // Check outputs of test case 2
        assert(data_output == expected_data_output)
          else $error("Test case 2: Unexpected data_output value");
        assert(output_ready == expected_output_ready)
          else $error("Test case 2: Unexpected output_ready value");
        assert(err_invalid_ptxt_char == expected_err_invalid_ptxt_char)
          else $error("Test case 2: Unexpected err_invalid_ptxt_char value");
        assert(err_invalid_seckey == expected_err_invalid_seckey)
          else $error("Test case 2: Unexpected err_invalid_seckey value");
        assert(err_invalid_ctxt_char == expected_err_invalid_ctxt_char)
          else $error("Test case 2: Unexpected err_invalid_ctxt_char value");
        $display("Test case 2: PASSED");

        mode_w = 2'b00;
        @(posedge clk);


        // Test case 3: Encrypt plaintext character "a"
        mode = 2'b10;
        data_input = 8'h61; // lowercase "a"
        key_input = 8'hE2;
        inputs_valid = 1'b1;
        expected_data_output = 8'h62;
        expected_output_ready = 1'b1;
        expected_err_invalid_ptxt_char = 1'b0;
        expected_err_invalid_seckey = 1'b0;
        expected_err_invalid_ctxt_char = 1'b0;

        @(posedge clk);
        inputs_valid_w = 1'b0;

        wait(output_ready == 1'b1);

        // Check outputs of test case 3
        assert(data_output == expected_data_output)
        else $error("Test case 3: Unexpected data_output value");
        assert(output_ready == expected_output_ready)
        else $error("Test case 3: Unexpected output_ready value");
        assert(err_invalid_ptxt_char == expected_err_invalid_ptxt_char)
        else $error("Test case 3: Unexpected err_invalid_ptxt_char value");
        assert(err_invalid_seckey == expected_err_invalid_seckey)
        else $error("Test case 3: Unexpected err_invalid_seckey value");
        assert(err_invalid_ctxt_char == expected_err_invalid_ctxt_char)
        else $error("Test case 3: Unexpected err_invalid_ctxt_char value");
        $display("Test case 3: PASSED");

         // Test case 4: Encrypt plaintext character "z"
        mode = 2'b10;
        data_input = 8'h7A; // lowercase "z"
        key_input = 8'hE2;
        inputs_valid = 1'b1;
        expected_data_output = 8'h7B;
        expected_output_ready = 1'b1;
        expected_err_invalid_ptxt_char = 1'b0;
        expected_err_invalid_seckey = 1'b0;
        expected_err_invalid_ctxt_char = 1'b0;

        @(posedge clk);
        inputs_valid_w = 1'b0;

        wait(output_ready == 1'b1);

        // Check outputs of test case 4
        assert(data_output == expected_data_output)
          else $error("Test case 4: Unexpected data_output value");
        assert(output_ready == expected_output_ready)
          else $error("Test case 4: Unexpected output_ready value");
        assert(err_invalid_ptxt_char == expected_err_invalid_ptxt_char)
          else $error("Test case 4: Unexpected err_invalid_ptxt_char value");
        assert(err_invalid_seckey == expected_err_invalid_seckey)
          else $error("Test case 4: Unexpected err_invalid_seckey value");
        assert(err_invalid_ctxt_char == expected_err_invalid_ctxt_char)
          else $error("Test case 4: Unexpected err_invalid_ctxt_char value");
        $display("Test case 4: PASSED");

         // Test case 5: Decrypt ciphertext of character "z"
        mode = 2'b11;
        data_input = 8'h7B;
        key_input = 8'h01;
        inputs_valid = 1'b1;
        expected_data_output = 8'h7A;
        expected_output_ready = 1'b1;
        expected_err_invalid_ptxt_char = 1'b0;
        expected_err_invalid_seckey = 1'b0;
        expected_err_invalid_ctxt_char = 1'b0;
        #10;

        // Check outputs of test case 5
        assert(data_output == expected_data_output)
          else $error("Test case 5: Unexpected data_output value");
        assert(output_ready == expected_output_ready)
          else $error("Test case 5: Unexpected output_ready value");
        assert(err_invalid_ptxt_char == expected_err_invalid_ptxt_char)
          else $error("Test case 5: Unexpected err_invalid_ptxt_char value");
        assert(err_invalid_seckey == expected_err_invalid_seckey)
          else $error("Test case 5: Unexpected err_invalid_seckey value");
        assert(err_invalid_ctxt_char == expected_err_invalid_ctxt_char)
          else $error("Test case 5: Unexpected err_invalid_ctxt_char value");
        $display("Test case 5: PASSED");

        // Test case 6: Check invalid plaintext character
        key_input = 8'hE2;
        inputs_valid = 1'b1;
        expected_data_output = 8'h00;
        expected_output_ready = 1'b0;
        expected_err_invalid_ptxt_char = 1'b1;
        expected_err_invalid_seckey = 1'b0;
        expected_err_invalid_ctxt_char = 1'b0;
        
        @(posedge clk);
        inputs_valid_w = 1'b0;

        wait(output_ready == 1'b1 || err_invalid_ctxt_char == 1'b1 || err_invalid_ptxt_char == 1'b1 || err_invalid_seckey == 1'b1);

        // Check outputs of test case 6
        assert(data_output == expected_data_output)
          else $error("Test case 6: Unexpected data_output value");
        assert(output_ready == expected_output_ready)
          else $error("Test case 6: Unexpected output_ready value");
        assert(err_invalid_ptxt_char == expected_err_invalid_ptxt_char)
          else $error("Test case 6: Unexpected err_invalid_ptxt_char value");
        assert(err_invalid_seckey == expected_err_invalid_seckey)
          else $error("Test case 6: Unexpected err_invalid_seckey value");
        assert(err_invalid_ctxt_char == expected_err_invalid_ctxt_char)
          else $error("Test case 6: Unexpected err_invalid_ctxt_char value");
        $display("Test case 6: PASSED");

    end
   
endmodule
module sae_tb_checks;

    reg clk = 1'b0;
    always #5 clk = !clk;
  
    reg rst_n = 1'b0;
    initial #12.8 rst_n = 1'b1;

    /*
    We define two instances to test the functionality of the SAE module, as stated in the specification. 
    We refer to the figure in the specification and create one instance of the module for Walt and one for Jesse.
    */

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
    reg [7:0] PTXT_W [$];
    reg [7:0] CTXT_W [$];
    reg [7:0] PTXT_J [$];
    reg [7:0] CTXT_J [$];
    string char_w;
    string char_w2;
    string char_j;
    string char_j2;

	initial begin
        @(posedge rst_n);
    
        //-------------------------------------------------------------------
        // WALT GENERATES THE PUBLIC KEY
        //-------------------------------------------------------------------
        
        @(posedge clk);
        FILE = $fopen("tv/privatekey_w.txt", "rb");
        if (FILE) begin
            $display("File privatekey_w was opened successfully : %0d", FILE);
        end
        else begin 
            $display("File privatekey_w was NOT opened successfully : %0d", FILE);
            $finish;
        end
        if($fscanf(FILE, "%b", key_input_w) == 1)begin
            $display("Walt's private key was successfully loaded");
        end
        else begin
            $display("Walt's private key was NOT loaded correctly");
            $finish;
        end
        $fclose(FILE);

        mode_w = 2'b01;
        data_input_w = 8'd0;
        inputs_valid_w = 1'b1;
        @(posedge clk);
        inputs_valid_w = 1'b0;
        @(posedge clk);
        #3 while (output_ready_w != 1'b1) begin
            if(err_invalid_seckey_w == 1'b1) begin
                $display("Walt's secret key has an invalid value");
                $finish;
            end
            $display("Walt's public key is NOT yet ready");
        end
        $display("Walt's public key was generated");
        FILE = $fopen("tv/publickey_j.txt", "wb");
        if (FILE) begin
            $display("File publickey_j was opened successfully : %0d", FILE);
        end
        else begin 
            $display("File publickey_j was NOT opened successfully : %0d", FILE);
            $finish;
        end

        $fdisplay(FILE, "%b", data_output_w);
        $fclose(FILE);

        mode_w = 2'b00;
        @(posedge clk);

        //-------------------------------------------------------------------
        // JESSE GENERATES THE PUBLIC KEY
        //-------------------------------------------------------------------

        FILE = $fopen("tv/privatekey_j.txt", "rb");
        if (FILE) begin
            $display("File privatekey_j was opened successfully : %0d", FILE);
        end
        else begin
            $display("File privatekey_j was NOT opened successfully : %0d", FILE);
            $finish;
        end  
        if($fscanf(FILE, "%b", key_input_j) == 1) begin
            $display("Jesse's private key was successfully loaded");
        end
        else begin
            $display("Jesse's private key was NOT loaded correctly");
            $finish;
        end
        $fclose(FILE);

        mode_j = 2'b01;
        data_input_j = 8'd0;
        inputs_valid_j = 1'b1;
        @(posedge clk);
        inputs_valid_j = 1'b0;
        @(posedge clk);
        #3 while (output_ready_j != 1'b1) begin
            if(err_invalid_seckey_j == 1'b1) begin
                $display("Jesse's secret key has an invalid value");
                $finish;
            end
            $display("Jesse's public key is NOT yet ready");
        end
        $display("Jesse's public key was generated");
        FILE = $fopen("tv/publickey_w.txt", "wb");
        if (FILE) begin
            $display("File publickey_w was opened successfully : %0d", FILE);
        end
        else begin
            $display("File publickey_w was NOT opened successfully : %0d", FILE);
            $finish;
        end 
        $fdisplay(FILE, "%b", data_output_j);
        $fclose(FILE);

        mode_j = 2'b00;
        @(posedge clk);

        //-------------------------------------------------------------------
        // WALT ENCRYPTS THE PLAINTEXT
        //-------------------------------------------------------------------

        FILE = $fopen("tv/publickey_w.txt", "rb");
        if (FILE)  begin
            $display("File publickey_w was opened successfully : %0d", FILE);
        end
        else begin
            $display("File publickey_w was NOT opened successfully : %0d", FILE);
            $finish;
        end
        if($fscanf(FILE, "%b", key_input_w) == 1) begin
            $display("Jesse's public key was successfully loaded");
        end
        else begin
            $display("Jesse's public key was NOT loaded correctly");
            $finish;
        end
        $fclose(FILE);

        FILE = $fopen("tv/plaintext_w.txt", "r");
        if (FILE)  begin
            $display("File plaintext_w was opened successfully : %0d", FILE);
        end
        else begin
            $display("File plaintext_w was NOT opened successfully : %0d", FILE);
            $finish;
        end
        while($fscanf(FILE, "%c", char_w) == 1) begin
            data_input_w = int'(char_w);
            mode_w = 2'b10;
            inputs_valid_w = 1'b1;
            @(posedge clk);
            inputs_valid_w = 1'b0;
            @(posedge clk);
            #3 while(output_ready_w != 1'b1) begin
                if(err_invalid_ptxt_char_w == 1'b1) begin
                    $display("An invalid character was inserted in the plaintext");
                    $finish;
                end
            end
            CTXT_W.push_back(data_output_w);
        end
        $fclose(FILE);

        FILE = $fopen("tv/ciphertext_j.txt", "w");
        if (FILE) begin
            $display("File ciphertext_j was opened successfully : %0d", FILE);
        end
        else begin
            $display("File ciphertext_j was NOT opened successfully : %0d", FILE);
            $finish;
        end

        foreach(CTXT_W[i]) begin
            $fwrite(FILE, "%c", CTXT_W[i]);
        end
        $fclose(FILE);

        mode_w = 2'b00;
        @(posedge clk);

        //-------------------------------------------------------------------
        // JESSE DECRYPTS THE CIPHERTEXT
        //-------------------------------------------------------------------

        FILE = $fopen("tv/privatekey_j.txt", "rb");
        if (FILE) begin
            $display("File privatekey_j was opened successfully : %0d", FILE);
        end
        else begin
            $display("File privatekey_j was NOT opened successfully : %0d", FILE);
            $finish;
        end
        if($fscanf(FILE, "%b", key_input_j) == 1) begin
            $display("Jesse's private key was successfully loaded");
        end
        else begin
            $display("Jesse's private key was NOT loaded correctly");
            $finish;
        end
        $fclose(FILE);

        FILE = $fopen("tv/ciphertext_j.txt", "r");
        if (FILE) begin
            $display("File ciphertext_j was opened successfully : %0d", FILE);
        end
        else begin
            $display("File ciphertext_j was NOT opened successfully : %0d", FILE);
            $finish;
        end
        while($fscanf(FILE, "%c", char_j) == 1) begin
            data_input_j = int'(char_j);
            mode_j = 2'b11;
            inputs_valid_j = 1'b1;
            @(posedge clk);
            inputs_valid_j = 1'b0;
            @(posedge clk);
            #3 while(output_ready_j != 1'b1) begin
                if(err_invalid_ctxt_char_j == 1'b1) begin
                    $display("An invalid character was inserted in the ciphertext");
                    $finish;
                end
            end
            PTXT_J.push_back(data_output_j);
        end
        $fclose(FILE);

        FILE = $fopen("tv/plaintext_j.txt", "w");
        if (FILE) begin
            $display("File plaintext_j was opened successfully : %0d", FILE);
        end
        else begin
            $display("File plaintext_j was NOT opened successfully : %0d", FILE);
            $finish;
        end
        foreach(PTXT_J[i]) begin
            $fwrite(FILE, "%c", PTXT_J[i]);
        end
        $fclose(FILE);

        PTXT_J.delete();

        mode_j = 2'b00;
        @(posedge clk);

        //-------------------------------------------------------------------
        // I CHECK THAT THE ORIGINAL PLAINTEXT AND THE PLAINTEXT OBTAINED BY DECRYPTION MATCH
        //-------------------------------------------------------------------

        FILE = $fopen("tv/plaintext_w.txt", "r");
        if (FILE) begin
            $display("File plaintext_w was opened successfully : %0d", FILE);
        end
        else begin
            $display("File plaintext_w was NOT opened successfully : %0d", FILE);
            $finish;
        end
        while($fscanf(FILE, "%c", char_w2) == 1) begin
            PTXT_W.push_back(int'(char_w2));
        end
        $fclose(FILE);

        FILE = $fopen("tv/plaintext_j.txt", "r");
        if (FILE) begin
            $display("File plaintext_j was opened successfully : %0d", FILE);
        end
        else begin
            $display("File plaintext_j was NOT opened successfully : %0d", FILE);
            $finish;
        end
        while($fscanf(FILE, "%c", char_j2) == 1) begin
            PTXT_J.push_back(int'(char_j2));
        end
        $fclose(FILE);

        if(PTXT_J == PTXT_W) begin
            $display("Plaintexts MATCH!");
        end
        else begin
            $display("Plaintexts NOT match");
        end
    end
endmodule

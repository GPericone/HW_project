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
        if (FILE)  
            $display("File was opened successfully : %0d", FILE);
        else    
            $display("File was NOT opened successfully : %0d", FILE);
        $fscanf(FILE, "%b", key_input_w);
        $display("Private key loaded");
        $fclose(FILE);
        mode_w = 2'b01;
        data_input_w = 8'd0;
        inputs_valid_w = 1'b1;
        @(posedge clk);
        inputs_valid_w = 1'b0;
        @(posedge clk);
        #3 if (output_ready_w == 1'b1) begin
            FILE = $fopen("tv/publickey_j.txt", "wb");
            $fwrite(FILE, "%b", data_output_w);
            $fclose(FILE);
        end
        else
            $write("Output non ready yet");

        mode_w = 2'b00;
        @(posedge clk);

        //-------------------------------------------------------------------
        // JESSE GENERATES THE PUBLIC KEY
        //-------------------------------------------------------------------

        FILE = $fopen("tv/privatekey_j.txt", "rb");
        if (FILE)  
            $display("File was opened successfully : %0d", FILE);
        else    
            $display("File was NOT opened successfully : %0d", FILE);
        $fscanf(FILE, "%b", key_input_j);
        $display("Private key loaded");
        $fclose(FILE);
        mode_j = 2'b01;
        data_input_j = 8'd0;
        inputs_valid_j = 1'b1;
        @(posedge clk);
        inputs_valid_j = 1'b0;
        @(posedge clk);
        #3 if (output_ready_j == 1'b1) begin
            FILE = $fopen("tv/publickey_w.txt", "wb");
            $fwrite(FILE, "%b", data_output_j);
            $fclose(FILE);
        end
        else
            $write("Output non ready yet");

        mode_j = 2'b00;
        @(posedge clk);

        //-------------------------------------------------------------------
        // WALT ENCRYPTS THE PLAINTEXT
        //-------------------------------------------------------------------

        FILE = $fopen("tv/publickey_w.txt", "rb");
        if (FILE)  
            $display("File was opened successfully : %0d", FILE);
        else    
            $display("File was NOT opened successfully : %0d", FILE);
        $fscanf(FILE, "%b", key_input_w);
        $display("Public key loaded");
        $fclose(FILE);
        FILE = $fopen("tv/plaintext_w.txt", "r");
        while($fscanf(FILE, "%c", char_w) == 1) begin
            data_input_w = int'(char_w);
            mode_w = 2'b10;
            inputs_valid_w = 1'b1;
            @(posedge clk);
            inputs_valid_w = 1'b0;
            @(posedge clk);
        // CONTROLLO CHE NON CI SIANO ERRORI
            #3 if (output_ready_w == 1'b1)
                CTXT_W.push_back(data_output_w);
            else
               $write("Output non ready yet"); 
        end
        $fclose(FILE);

        FILE = $fopen("tv/ciphertext_j.txt", "w");
        foreach(CTXT_W[i])
            $fwrite(FILE, "%c", CTXT_W[i]);
        $fclose(FILE);

        mode_w = 2'b00;
        @(posedge clk);

        //-------------------------------------------------------------------
        // JESSE DECRYPTS THE CIPHERTEXT
        //-------------------------------------------------------------------

        FILE = $fopen("tv/privatekey_j.txt", "rb");
        if (FILE)  
            $display("File was opened successfully : %0d", FILE);
        else    
            $display("File was NOT opened successfully : %0d", FILE);
        $fscanf(FILE, "%b", key_input_j);
        $display("Public key loaded");
        $fclose(FILE);
        FILE = $fopen("tv/ciphertext_j.txt", "r");
        if (FILE)  
            $display("File was opened successfully : %0d", FILE);
        else    
            $display("File was NOT opened successfully : %0d", FILE);
        while($fscanf(FILE, "%c", char_j) == 1) begin
            data_input_j = int'(char_j);
            mode_j = 2'b11;
            inputs_valid_j = 1'b1;
            @(posedge clk);
            inputs_valid_j = 1'b0;
            @(posedge clk);
        // CONTROLLO CHE NON CI SIANO ERRORI
            #3 if (output_ready_j == 1'b1)
                PTXT_J.push_back(data_output_j);
            else
               $write("Output non ready yet"); 
        end
        $fclose(FILE);

        FILE = $fopen("tv/plaintext_j.txt", "w");
        foreach(PTXT_J[i])
            $fwrite(FILE, "%c", PTXT_J[i]);
        $fclose(FILE);

        PTXT_J.delete();

        mode_j = 2'b00;
        @(posedge clk);

        //-------------------------------------------------------------------
        // I CHECK THAT THE ORIGINAL PLAINTEXT AND THE PLAINTEXT OBTAINED BY DECRYPTION MATCH
        //-------------------------------------------------------------------

        FILE = $fopen("tv/plaintext_w.txt", "r");
        while($fscanf(FILE, "%c", char_w2) == 1) begin
            PTXT_W.push_back(int'(char_w2));
        end
        $fclose(FILE);
        FILE = $fopen("tv/plaintext_j.txt", "r");
        while($fscanf(FILE, "%c", char_j2) == 1) begin
            PTXT_J.push_back(int'(char_j2));
        end
        $fclose(FILE);
        foreach(PTXT_W[i])
            if(PTXT_J[i] != PTXT_W[i])
                $display("I plaintext non coincidono: %c %c", PTXT_J[i], PTXT_W[i]);
        $display("I plaintext coincidono");

        if(PTXT_J == PTXT_W)
            $display("I plaintext coincidono");
    end
endmodule

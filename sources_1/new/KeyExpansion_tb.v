`timescale 1ns/1ps

module KeyExpansion_tb();

    // DUT inputs
    reg clk;
    reg rst_n;
    reg start;
    reg [127:0] key_in;

    // DUT outputs
    wire done;
    wire [1407:0] round_key;

    // Instantiate DUT
    KeyExpansion dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .key_in(key_in),
        .done(done),
        .round_key(round_key)
    );

    // Clock generation: 10 ns period
    initial clk = 0;
    always #5 clk = ~clk;

    // Test vector: AES-128 test key (FIPS-197 example)
    // Key = 0x2b7e151628aed2a6abf7158809cf4f3c
    initial begin
        // Initialize signals
        rst_n = 0;
        start = 0;
        key_in = 128'h2b7e151628aed2a6abf7158809cf4f3c;

        // Wait a few cycles, then release reset
        #20;
        rst_n = 1;
        #20;

        // Start key expansion
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;

        // Wait until done is asserted
        wait (done == 1);
        #10;

        // Display result
        $display("\n=== Key Expansion Complete ===");
        $display("Input Key: %h", key_in);
        $display("Round Keys (Flattened):");
        $display("%h", round_key);

        display_round_keys(round_key);

        $finish;
    end

    task display_round_keys(input [1407:0] rk);
        integer round;
        reg [127:0] key_round;
        begin
            $display("\n--- Round Keys ---");
            for (round = 0; round < 11; round = round + 1) begin
                key_round = rk[(11-round)*128-1 -: 128]; // Extract per round
                $display("Round %0d key: %h", round, key_round);
            end
        end
    endtask

endmodule

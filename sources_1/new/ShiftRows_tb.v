module ShiftRows_tb;
reg  [127:0] state_in;   // 128-bit AES input state
wire [127:0] state_out;  // 128-bit AES output after ShiftRows


ShiftRows uut (.state_in(state_in),.state_out(state_out));

// --------------------------------------------------------
// Task: display_state
// Prints 128-bit AES state in byte-wise hexadecimal order
// For readability in console output.
// --------------------------------------------------------
task display_state;
    input [127:0] data;
    integer i;
    begin
        $write("[ ");
        // Print bytes from MSB (byte 15) to LSB (byte 0)
        for (i = 15; i >= 0; i = i - 1)
            $write("%02x ", data[8*i +: 8]); // print one byte in hex
        $write("]");
    end
endtask

initial begin
    $display("\n==== AES ShiftRows Test ====\n");

    // ----------------------------------------------------
    // Test Case 1: Sequential Bytes (Simple Verification)
    // ----------------------------------------------------
    // This vector helps visualize how each row shifts.
    // Input bytes: 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
    // Expected Output (after ShiftRows):
    // 00 05 0A 0F 04 09 0E 03 08 0D 02 07 0C 01 06 0B
    // ----------------------------------------------------
    state_in = 128'h000102030405060708090A0B0C0D0E0F;
    #10; // Wait for combinational propagation
    $display("Input : ");  display_state(state_in);  $display("");
    $display("Output: ");  display_state(state_out); $display("\n");

    // ----------------------------------------------------
    // Test Case 2: AES Example Input
    // ----------------------------------------------------
    // Taken from standard AES test vector documentation.
    // Input:  D4 27 11 AE E0 BF 98 F1 B8 B4 5D E5 1E 41 52 30
    // Expected Output after ShiftRows:
    // D4 BF 5D 30  E0 B4 52 AE  B8 41 11 F1  1E 27 98 E5
    // ----------------------------------------------------
    state_in = 128'hD42711AEE0BF98F1B8B45DE51E415230;
    #10;
    $display("Input : ");  display_state(state_in);  $display("");
    $display("Output: ");  display_state(state_out); $display("\n");

    // ----------------------------------------------------
    // End of simulation
    // ----------------------------------------------------
    $display("==== Test Completed ====\n");
    $finish;
end
endmodule 

module Part3Combine();

// Instantiate MixColumn Module
reg  [31:0] In_Array;
wire [31:0] Out_Array;
MixColumn MIX (.In_Array(In_Array), .Out_Array(Out_Array));

// Instantiate Shift Row Module
reg  [127:0] state_in;   // 128-bit AES input state
wire [127:0] state_out;  // 128-bit AES output after ShiftRows
ShiftRows ROW (.state_in(state_in),.state_out(state_out));

// Instantiate S-Box
reg [7:0] byteIn;
wire [7:0] byteOut;
sBox SBOX (.byteIn(byteIn), .byteOut(byteOut));


// Testbench control variables
integer i;
reg [7:0] temp_bytes [0:15]; // Stores a temporary byte-by-byte AES state
reg [7:0] shifted_bytes [0:15]; // To hold shiftrows output bytes
integer col;

initial begin
    $display("AES Part 3 Combined Testbench");
    
    // Step 1: Initialize AES input state (example pattern)
    state_in = 128'h00112233445566778899aabbccddeeff;
    In_Array = 32'hd4bf5d30;
    byteIn   = 8'h53;
    
    // Step 2: Wait for combinational propagation
    #10;
    $display("Initial SBox Input: %02x, Output: %02x", byteIn, byteOut);
    
    // Step 3: Apply S-Box substitution to all bytes
    $display("\nSubstituting bytes of input state");
    for (i = 0; i < 16; i = i + 1) begin
        byteIn = state_in[8*i +: 8];
        #5;
        temp_bytes[i] = byteOut;
        $display("Byte %0d in: %02x | out: %02x", i, byteIn, byteOut);
    end
    
    // Step 4: Reassemble substituted bytes into new state
    state_in = {temp_bytes[15], temp_bytes[14], temp_bytes[13], temp_bytes[12],
                temp_bytes[11], temp_bytes[10], temp_bytes[9],  temp_bytes[8],
                temp_bytes[7],  temp_bytes[6],  temp_bytes[5],  temp_bytes[4],
                temp_bytes[3],  temp_bytes[2],  temp_bytes[1],  temp_bytes[0]};
    
    // Step 5: Apply ShiftRows (combinational)
    #10;
    $display("\nAfter ShiftRows");
    $display("ShiftRows Input : %032x", state_in);
    $display("ShiftRows Output: %032x", state_out);
    
    // Extract ShiftRows output into bytes for MixColumns step
    for (i = 0; i < 16; i = i + 1)
        shifted_bytes[i] = state_out[8*i +: 8];
    
    // Step 6: Apply MixColumns (on one 32-bit column)
    #10;
    $display("\nMixColumns Output");
    for (col = 0; col < 4; col = col + 1) begin
        // Each column = 4 bytes (rows 0-3 in that column)
        In_Array = { shifted_bytes[col+12], shifted_bytes[col+8],
                     shifted_bytes[col+4],  shifted_bytes[col+0] };

        #10;
        $display("Column %0d Input : %08x", col, In_Array);
        $display("Column %0d Output: %08x\n", col, Out_Array);
    end
    
    #20;
    $display("\nTest Completed.");
    $finish;
end
endmodule

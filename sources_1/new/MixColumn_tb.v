module MixColumn_tb();

reg  [31:0] In_Array;
wire [31:0] Out_Array;

MixColumn DUT (.In_Array(In_Array), .Out_Array(Out_Array));

initial begin

    $display("Starting AES MixColumns test...");
    $display("In | Out");

    // Tests taken from Wikipedia Page for Mix Columns
    // Input: 63 47 a2 f0
    // Expected: 5d e0 70 bb
    In_Array = 32'h6347A2F0;
    #10;
    $display("%h | %h", In_Array, Out_Array);

    // Input: f2 0a 22 5c
    // Expected: 9f dc 58 9d
    In_Array = 32'hF20A225C;
    #10;
    $display("%h | %h", In_Array, Out_Array);

    // Input: 01 01 01 01
    // Expected: 01 01 01 01
    In_Array = 32'h01010101;
    #10;
    $display("%h | %h", In_Array, Out_Array);

    // Input: c6 c6 c6 c6
    // Expected: c6 c6 c6 c6
    In_Array = 32'hC6C6C6C6;
    #10;
    $display("%h | %h", In_Array, Out_Array);
    
    // Input: d4 d4 d4 d5
    // Expected: d5 d5 d7 d6
    In_Array = 32'hD4D4D4D5;
    #10;
    $display("%h | %h", In_Array, Out_Array);
    
    // Input: 2d 26 31 4c
    // Expected: 4d 7e bd f8
    In_Array = 32'h2D26314C;
    #10;
    $display("%h | %h", In_Array, Out_Array);

    $display("Test completed.");
    $finish;
end
endmodule 

`timescale 1ns / 1ps

// Verilog 4-bit Full Adder Test Bench
// For Part 1 of Hardware Security Project
// By: Caleb McCants and Md. Tanjimur Rahman

module Adder_tb();
    
    reg [3:0] a;
    reg [3:0] b;
    reg carry_in;
	wire carry_out;
	wire [3:0] sum;
	integer i, j, k;
    
    Adder DUT (.a(a), .b(b), .carry_in(carry_in), .carry_out(carry_out), .sum(sum));
    
 
initial begin
    $display("Starting exhaustive test of 4-bit Adder...");
    $display(" A  |  B  | Cin | Cout | Sum  |  {Cout, Sum}");

    for (k = 0; k <= 1; k = k + 1) begin
        carry_in = k;
        for (j = 0; j < 16; j = j + 1) begin
            b = j;
            for (i = 0; i < 16; i = i + 1) begin
                a = i;
                #1;
                $display("%2d  | %2d  |  %1b  |   %1b   | %2d   |   %2d", 
                         a, b, carry_in, carry_out, sum, {carry_out, sum});
            end
        end
    end

    $display("Test completed.");
    $finish;
end
endmodule

module MixColumn(
    input  [31:0] In_Array,
    output [31:0] Out_Array
);
    wire [7:0] a [3:0];
    wire [7:0] b [3:0]; // = 2 * a
    wire [7:0] c [3:0]; // = 3 * a = (2 * a) ^ a
    
    assign {a[3], a[2], a[1], a[0]} = In_Array;

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : mix
            assign b[i] = (a[i][7] == 1'b1) ? ((a[i] << 1) ^ 8'h1B) : (a[i] << 1);
            assign c[i] = b[i] ^ a[i];
        end
    endgenerate

    assign Out_Array[31:24] = b[3] ^ c[2] ^ a[1] ^ a[0]; // 2*a3 + 3*a2 + a1 + a0
    assign Out_Array[23:16] = a[3] ^ b[2] ^ c[1] ^ a[0]; // a3 + 2*a2 + 3*a1 + a0
    assign Out_Array[15:8]  = a[3] ^ a[2] ^ b[1] ^ c[0]; // a3 + a2 + 2*a1 + 3*a0
    assign Out_Array[7:0]   = c[3] ^ a[2] ^ a[1] ^ b[0]; // 3*a3 + a2 + a1 + 2*a0
endmodule

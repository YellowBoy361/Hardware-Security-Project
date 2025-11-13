//============================================================
// AES S-box (Substitution Box)
// Purely combinational, synthesizable version
// Compatible with KeyExpansion module
//============================================================
module sBox (
    input  wire [7:0]  byteIn,
    output reg  [7:0]  byteOut
);
    reg [7:0] sbox [0:255];

    initial begin
        $readmemh("sbox.mem", sbox);
    end

    always @(*) begin
        byteOut = sbox[byteIn];
    end
endmodule
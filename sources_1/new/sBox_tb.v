module sBox_tb();
    reg [7:0] byteIn;
    reg [7:0] byteOut;
    integer i;

    reg [7:0] sbox [0:255];

    initial begin
        $readmemh("sbox.mem", sbox);
        $display("Starting exhaustive listing of AES S-Box...");
        $display("In | Out");
        for (i = 0; i < 256; i = i + 1) begin
            byteIn = i;
            byteOut = sbox[byteIn]; // direct assignment
            $display("%3d | 0x%2h", byteIn, byteOut);
        end
        $display("Test completed.");
        $finish;
    end
endmodule
`timescale 1ns/1ps
module KeyExpansion(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire [127:0] key_in,
    output reg         done,
    output reg [1407:0] round_key  // Flattened 11 round keys
);

    // 44 words storage (32-bit each)
    reg [31:0] w [0:43];
    reg [5:0]  i; // 0..43

    // temp registers
    reg [31:0] rotword_reg;    
    reg        rot_pending;    

    // S-box memory
    reg [7:0] sbox [0:255];
    initial $readmemh("sbox.mem", sbox);

    // rcon table
    reg [31:0] Rcon [0:9];
    initial begin
        Rcon[0]=32'h01000000; Rcon[1]=32'h02000000; Rcon[2]=32'h04000000;
        Rcon[3]=32'h08000000; Rcon[4]=32'h10000000; Rcon[5]=32'h20000000;
        Rcon[6]=32'h40000000; Rcon[7]=32'h80000000; Rcon[8]=32'h1B000000;
        Rcon[9]=32'h36000000;
    end

    // FSM states
    parameter IDLE       = 2'b00,
              COMPUTE    = 2'b01,
              WAIT_SBOX  = 2'b10,
              DONE_STATE = 2'b11;

    reg [1:0] state;

    // synchronous FSM
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state       <= IDLE;
            done        <= 1'b0;
            i           <= 6'd0;
            rot_pending <= 1'b0;
            rotword_reg <= 32'h0;
            round_key   <= 0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 1'b0;
                    if (start) begin
                        // load initial key words
                        w[0] <= key_in[127:96];
                        w[1] <= key_in[95:64];
                        w[2] <= key_in[63:32];
                        w[3] <= key_in[31:0];
                        i <= 6'd4;
                        rot_pending <= 1'b0;
                        state <= COMPUTE;
                    end
                end

                COMPUTE: begin
                    if (i < 44) begin
                        if ((i % 4) == 0) begin
                            // RotWord + SubWord + Rcon
                            rotword_reg <= { w[i-1][23:0], w[i-1][31:24] };
                            rot_pending <= 1'b1;
                            state <= WAIT_SBOX;
                        end else begin
                            // simple case: w[i] = w[i-4] ^ w[i-1]
                            w[i] <= w[i-4] ^ w[i-1];
                            i <= i + 1;
                        end
                    end else begin
                        state <= DONE_STATE;
                    end
                end

                WAIT_SBOX: begin
                    // SubWord using S-box memory
                    w[i] <= w[i-4] ^ {sbox[rotword_reg[31:24]], sbox[rotword_reg[23:16]], sbox[rotword_reg[15:8 ]], sbox[rotword_reg[7 :0 ]] } ^ Rcon[(i/4) - 1];
                    rot_pending <= 1'b0;
                    i <= i + 1;
                    state <= COMPUTE;
                end

                DONE_STATE: begin
                    done <= 1'b1;

                    // Flatten all 11 round keys into round_key
                    round_key <= { 
                        {w[0], w[1], w[2], w[3]},
                        {w[4], w[5], w[6], w[7]},
                        {w[8], w[9], w[10], w[11]},
                        {w[12], w[13], w[14], w[15]},
                        {w[16], w[17], w[18], w[19]},
                        {w[20], w[21], w[22], w[23]},
                        {w[24], w[25], w[26], w[27]},
                        {w[28], w[29], w[30], w[31]},
                        {w[32], w[33], w[34], w[35]},
                        {w[36], w[37], w[38], w[39]},
                        {w[40], w[41], w[42], w[43]}
                    };
                end
            endcase
        end
    end

endmodule
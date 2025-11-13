module AES (
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire [127:0] plaintext,
    input wire [127:0] key,
    output reg [127:0] ciphertext,
    output reg done
);

    // Internal variables.
    reg [3:0] round;
    reg [1:0] state_fsm;
    reg [127:0] state;
    wire[1407:0] round_keys;
    wire keyexp_done;
    wire [127:0] subbytes_out, shiftrows_out, mixcolumns_out, addkey_out;
    wire [127:0] current_round_key;

    // Key Expansion Instantiation
    KeyExpansion KEY (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .key_in(key),
        .done(keyexp_done),
        .round_key(round_keys)
    );

    // Creating the 16 S-boxes
    wire [7:0] sbox_in  [15:0];
    wire [7:0] sbox_out [15:0];

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : SBOX_LOOP
            assign sbox_in[i] = state[127 - 8*i -: 8];
            sBox SBOX (
                .byteIn(sbox_in[i]),
                .byteOut(sbox_out[i])
            );
            assign subbytes_out[127 - 8*i -: 8] = sbox_out[i];
        end
    endgenerate

    // ShiftRows Instantiation
    ShiftRows SHIFT (
        .state_in(subbytes_out),
        .state_out(shiftrows_out)
    );

    // MixColumns Instantiation
    wire [31:0] mix_in  [3:0];
    wire [31:0] mix_out [3:0];

    assign {mix_in[3], mix_in[2], mix_in[1], mix_in[0]} = shiftrows_out;

    generate
        for (i = 0; i < 4; i = i + 1) begin : MIX_LOOP
            MixColumn MIX (
                .In_Array(mix_in[i]),
                .Out_Array(mix_out[i])
            );
        end
    endgenerate

    assign mixcolumns_out = {mix_out[3], mix_out[2], mix_out[1], mix_out[0]};

    // Round Key selection
    // round_keys[1407:0] = round0, round1, ..., round10
    // initial AddRoundKey uses round0
    // round 1-9 use mixcolumns
    // round 10 (last) skips mixcolumns
    assign current_round_key = round_keys[1407 - 128*(round+1) -: 128];

    // Select data going into AddRoundKey
    wire [127:0] round_input =
        (round == 9) ? shiftrows_out : mixcolumns_out;

    // KeyAddition Instantiation
    KeyAddition ADD (
        .state_in(round_input),
        .round_key(current_round_key),
        .state_out(addkey_out)
    );

    // FSM States
    parameter IDLE   = 2'd0;
    parameter EXPAND = 2'd1;
    parameter ENCRYPT= 2'd2;
    parameter DONE   = 2'd3;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_fsm   <= IDLE;
            round       <= 0;
            state       <= 128'd0;
            ciphertext  <= 128'd0;
            done        <= 1'b0;
        end else begin
            case (state_fsm)
                IDLE: begin
                    done <= 1'b0;
                    if (start)
                        state_fsm <= EXPAND;
                end

                EXPAND: begin
                    if (keyexp_done) begin
                        // Initial AddRoundKey (round key 0)
                        state <= plaintext ^ round_keys[1407 -: 128];
                        round <= 0;
                        state_fsm <= ENCRYPT;
                    end
                end

                ENCRYPT: begin
                    if (round < 10) begin
                        state <= addkey_out;
                        round <= round + 1;
                    end else begin
                        ciphertext <= state;
                        done <= 1'b1;
                        state_fsm <= DONE;
                    end
                end

                DONE: begin
                    done <= 1'b1; // Hold result until reset
                end
            endcase
        end
    end
endmodule
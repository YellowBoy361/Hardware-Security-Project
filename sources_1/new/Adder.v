module Adder(
    input [3:0] a,
    input [3:0] b,
    input carry_in,
    output carry_out,
    output [3:0] sum
);

assign {carry_out, sum} = a + b + carry_in;
endmodule

// Synthesis of UART and Adder.
module UART_Adder(
    input i_Reset,
    input i_Clock,
    input i_Rx_Serial,
    output o_Tx_Serial,
    output [2:0] Current_State
);

// UART_transmit Variables
reg i_Tx_DV = 0;
reg [7:0] i_Tx_Byte = 0;
wire o_Tx_Active = 0;
wire o_Tx_Done = 0;

// UART_recieve Variables
wire o_Rx_DV = 0;
wire [7:0] o_Rx_Byte = 0;

// Adder Variables
reg [3:0] a = 0;
reg [3:0] b = 0;
reg carry_in = 0;
wire carry_out = 0;
wire [3:0] sum = 0;

// Additional state machine variables
reg [7:0] result_byte = 0;
reg transmit_stage = 0; // 0 = send sum, 1 = send carry
reg rx_data_ready = 0;
reg [7:0] rx_data_buffer = 0;

// Instantiate UART_receiver
UART_receive #(.CLKS_PER_BIT(1042)) UART_RX (
    .i_Clock(i_Clock),
    .i_Rx_Serial(i_Rx_Serial),
    .o_Rx_DV(o_Rx_DV),
    .o_Rx_Byte(o_Rx_Byte)
);

// Instantiate UART_transmitter
UART_transmit #(.CLKS_PER_BIT(1042)) UART_TX (
    .i_Clock(i_Clock),
    .i_Tx_DV(i_Tx_DV),
    .i_Tx_Byte(i_Tx_Byte),
    .o_Tx_Active(o_Tx_Active),
    .o_Tx_Serial(o_Tx_Serial),
    .o_Tx_Done(o_Tx_Done)
);

// Instantiate Adder
Adder ADD (
    .a(a),
    .b(b),
    .carry_in(carry_in),
    .carry_out(carry_out),
    .sum(sum)
);

// State Variables
parameter Idle = 3'b000;
parameter Begin = 3'b001;
parameter Receive_A = 3'b010;
parameter Receive_B = 3'b011;
parameter Compute = 3'b100;
parameter Transmit = 3'b101;
parameter Wait = 3'b110;
parameter Finish = 3'b111;

reg [2:0] State = Idle; // Initial State

// State Machine
always @ (posedge i_Clock) begin
    if (i_Reset) begin
        a <= 0;
        b <= 0;
        carry_in <= 0;
        i_Tx_DV <= 0;
        i_Tx_Byte <= 0;
        transmit_stage <= 0;
        State <= Idle;
    end else begin
        case (State)

            Idle: begin
                i_Tx_DV <= 0;
                transmit_stage <= 0;
                State <= Begin;
            end

            Begin: begin
                if (rx_data_ready) begin
                    State <= Receive_A;
                end
            end
            
            Receive_A: begin
                a <= rx_data_buffer[3:0];
                carry_in <= rx_data_buffer[4];
                State <= Receive_B;
            end
            
            Receive_B: begin
                if (rx_data_ready) begin
                    b <= rx_data_buffer[3:0];
                    State <= Compute;
                end
            end

            Compute: begin
                // Computation is combinational, so result is ready immediately
                // Prepare first transmission (sum)
                result_byte <= {3'b000, carry_out, sum}; // Pack carry_out and sum into byte
                transmit_stage <= 0;
                State <= Transmit;
            end

            Transmit: begin
                if (!o_Tx_Active && !i_Tx_DV) begin
                    // Start transmission
                    i_Tx_Byte <= result_byte;
                    i_Tx_DV <= 1;
                    State <= Wait;
                end
            end

            Wait: begin
                // Clear the transmit data valid flag
                i_Tx_DV <= 0;

                // Wait for transmission to complete
                if (o_Tx_Done) begin
                    State <= Finish;
                end
            end

            Finish: begin
                // Transmission complete, return to idle
                State <= Idle;
            end

            default: State <= Idle;
        endcase
    end
end

always @(posedge i_Clock) begin
    if (o_Rx_DV) begin
        rx_data_ready <= 1;
        rx_data_buffer <= o_Rx_Byte;
    end else if (State == Receive_A || State == Receive_B) begin
        // Clear flag after consuming
        rx_data_ready <= 0;
    end
end

assign Current_State = State;
endmodule
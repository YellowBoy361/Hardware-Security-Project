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
    input Reset,
    input Clock,
    input i_Rx_Serial,
    output o_Tx_Serial,
    output [2:0] CurrentState
//    output [3:0] CurrentA,
//    output [3:0] CurrentB
);

// UART_transmit Variables
reg transmitStart;
reg [7:0] transmitData;
wire transmitActive;
wire transmitDone;

// UART_recieve Variables
wire receiveStart;
wire [7:0] receiveData;

// Adder Variables
reg [3:0] a;
reg [3:0] b;
reg carry_in;
wire carry_out;
wire [3:0] sum;

reg [1:0] byte_count;

// Instantiate UART_receiver
uart_rx #(.CLKS_PER_BIT(10416)) UART_RX (
    .i_Clock(Clock),
    .i_Rx_Serial(i_Rx_Serial),
    .o_Rx_DV(receiveStart),
    .o_Rx_Byte(receiveData)
);

// Instantiate UART_transmitter
uart_tx #(.CLKS_PER_BIT(10416)) UART_TX (
    .i_Clock(Clock),
    .i_Tx_DV(transmitStart),
    .i_Tx_Byte(transmitData),
    .o_Tx_Active(transmitActive),
    .o_Tx_Serial(o_Tx_Serial),
    .o_Tx_Done(transmitDone)
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
parameter Receive = 3'b001;
parameter Pause = 3'b010;
parameter Compute = 3'b011;
parameter Transmit = 3'b100;
parameter Wait = 3'b101;

reg [2:0] State = Idle; // Initial State

// State Machine
always @ (posedge Clock) begin
    if (Reset) begin
        a <= 4'b0;
        b <= 4'b0;
        carry_in <= 1'b0;
        transmitStart <= 1'b0;
        transmitData <= 8'b0;
        State <= Idle;
    end else begin
        case (State)
            Idle: begin
                transmitStart <= 0;
                State <= Receive;
            end
            
            Receive: begin
                if (receiveStart) begin
                    if (byte_count == 0) begin
                        a <= receiveData[3:0];
                        carry_in <= receiveData[4];
                        byte_count <= 1;
                    end else begin
                        b <= receiveData[3:0];
                        byte_count <= 0;
                        State <= Pause;
                    end
                end
            end
            
            Pause: begin
                State <= Compute;
            end

            Compute: begin
                transmitData <= {3'b000, carry_out, sum}; // Pack carry_out and sum into byte
                State <= Transmit;
            end

            Transmit: begin
                transmitStart <= 1;
//                transmitData <= receiveData; // Echo Data Recieved
                State <= Wait;
            end

            Wait: begin
                transmitStart <= 0;
                if (transmitDone) begin
                    State <= Idle;
                end
            end
        endcase
    end
end

assign CurrentState = State;
//assign CurrentA = a;
//assign CurrentB = b;
endmodule

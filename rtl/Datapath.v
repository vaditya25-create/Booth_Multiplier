`timescale 1ns / 1ps

//=====================================================
// Module : datapath
//
// Description:
// Datapath for the Booth Multiplier. It performs the
// arithmetic operations required by Booth's algorithm
// under the control of the FSM.
//
// Components:
// - Accumulator Register (A)
// - Multiplicand Register (M)
// - Multiplier Register (Q)
// - Booth Bit Register (Q_1)
// - Iteration Counter
// - Arithmetic Right Shifter
//
// The controller generates the control signals, while
// the datapath executes the multiplication.
//=====================================================

module datapath #(
    parameter N = 4
)(
    input  wire clk,
    input  wire reset,

    //=================================================
    // Control Signals from Controller
    //=================================================
    input  wire load,
    input  wire add,
    input  wire sub,
    input  wire shift,

    //=================================================
    // Inputs
    //=================================================
    input  wire signed [N-1:0] multiplicand,
    input  wire signed [N-1:0] multiplier,

    //=================================================
    // Status Signals to Controller
    //=================================================
    output wire [1:0] booth_bits,
    output wire       last_cycle,

    //=================================================
    // Final Product
    //=================================================
    output wire signed [(2*N)-1:0] product
);

    //=================================================
    // Internal Registers
    //=================================================
    reg signed [N-1:0] A;
    reg signed [N-1:0] M;
    reg signed [N-1:0] Q;
    reg                Q_1;

    reg [$clog2(N+1)-1:0] count;

    //=================================================
    // Status Outputs
    //=================================================
    assign booth_bits = {Q[0], Q_1};
    assign last_cycle = (count == 1);

    // Product is always the concatenation of A and Q
    assign product = {A, Q};

    //=================================================
    // Datapath Sequential Logic
    //=================================================
    always @(posedge clk or posedge reset)
    begin

        if (reset)
        begin
            A     <= 0;
            M     <= 0;
            Q     <= 0;
            Q_1   <= 0;
            count <= 0;
        end

        else
        begin

            //=========================================
            // Load Registers
            //=========================================
            if (load)
            begin
                A     <= 0;
                M     <= multiplicand;
                Q     <= multiplier;
                Q_1   <= 0;
                count <= N;
            end

            //=========================================
            // Add Multiplicand
            //=========================================
            else if (add)
            begin
                A <= A + M;
            end

            //=========================================
            // Subtract Multiplicand
            //=========================================
            else if (sub)
            begin
                A <= A - M;
            end

            //=========================================
            // Arithmetic Right Shift
            //=========================================
            else if (shift)
            begin
                Q_1   <= Q[0];
                Q     <= {A[0], Q[N-1:1]};
                A     <= {A[N-1], A[N-1:1]};
                count <= count - 1;
            end

        end

    end

endmodule

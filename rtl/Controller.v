`timescale 1ns / 1ps

//=====================================================
// Module : controller
//
// Description:
// Finite State Machine (FSM) controller for the Booth
// Multiplier. The controller generates the control
// signals required by the datapath to perform signed
// multiplication using Booth's algorithm.
//
// State Flow:
// IDLE -> LOAD -> OPERATE -> SHIFT -> DONE
//=====================================================

module controller #(
    parameter N = 4
)(
    input  wire       clk,
    input  wire       reset,
    input  wire       start,

    // Status signals from datapath
    input  wire       last_cycle,
    input  wire [1:0] booth_bits,

    // Control signals to datapath
    output reg        load,
    output reg        add,
    output reg        sub,
    output reg        shift,
    output reg        done
);

    //=====================================================
    // State Encoding
    //=====================================================
    localparam IDLE    = 3'b000,
               LOAD    = 3'b001,
               OPERATE = 3'b010,
               SHIFT   = 3'b011,
               DONE    = 3'b100;

    reg [2:0] state, next_state;

    //=====================================================
    // State Register
    //=====================================================
    always @(posedge clk or posedge reset)
    begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    //=====================================================
    // Next State Logic
    //=====================================================
    always @(*)
    begin
        next_state = state;

        case (state)

            IDLE:
            begin
                if (start)
                    next_state = LOAD;
            end

            LOAD:
                next_state = OPERATE;

            OPERATE:
                next_state = SHIFT;

            SHIFT:
            begin
                if (last_cycle)
                    next_state = DONE;
                else
                    next_state = OPERATE;
            end

            DONE:
                next_state = IDLE;

            default:
                next_state = IDLE;

        endcase
    end

    //=====================================================
    // Output Logic
    //=====================================================
    always @(*)
    begin

        // Default Outputs
        load  = 1'b0;
        add   = 1'b0;
        sub   = 1'b0;
        shift = 1'b0;
        done  = 1'b0;

        case (state)

            //=============================================
            // Load Registers
            //=============================================
            LOAD:
                load = 1'b1;

            //=============================================
            // Booth Decision Logic
            //=============================================
            OPERATE:
            begin
                case (booth_bits)

                    2'b01:
                        add = 1'b1;

                    2'b10:
                        sub = 1'b1;

                    default:
                        ;   // 00 and 11 -> No Operation

                endcase
            end

            //=============================================
            // Arithmetic Right Shift
            //=============================================
            SHIFT:
                shift = 1'b1;

            //=============================================
            // Multiplication Complete
            //=============================================
            DONE:
                done = 1'b1;

            default:
                ;

        endcase

    end

endmodule

`timescale 1ns / 1ps

//=====================================================
// Module : booth_multiplier_top
//
// Description:
// Top-level module for the Booth Multiplier.
// It instantiates the Controller and Datapath,
// connecting them through control and status signals.
//
// Modules:
// - Controller : Generates FSM-based control signals
// - Datapath   : Executes Booth multiplication
//=====================================================

module booth_multiplier_top #(
    parameter N = 4
)(
    input  wire clk,
    input  wire reset,
    input  wire start,

    input  wire signed [N-1:0] multiplicand,
    input  wire signed [N-1:0] multiplier,

    output wire signed [(2*N)-1:0] product,
    output wire done
);

    //=================================================
    // Internal Control Signals
    //=================================================
    wire load;
    wire add;
    wire sub;
    wire shift;

    //=================================================
    // Internal Status Signals
    //=================================================
    wire [1:0] booth_bits;
    wire       last_cycle;

    //=================================================
    // Controller Instance
    //=================================================
    controller #(
        .N(N)
    ) u_controller (

        .clk(clk),
        .reset(reset),
        .start(start),

        .last_cycle(last_cycle),
        .booth_bits(booth_bits),

        .load(load),
        .add(add),
        .sub(sub),
        .shift(shift),
        .done(done)

    );

    //=================================================
    // Datapath Instance
    //=================================================
    datapath #(
        .N(N)
    ) u_datapath (

        .clk(clk),
        .reset(reset),

        .load(load),
        .add(add),
        .sub(sub),
        .shift(shift),

        .multiplicand(multiplicand),
        .multiplier(multiplier),

        .booth_bits(booth_bits),
        .last_cycle(last_cycle),

        .product(product)

    );

endmodule

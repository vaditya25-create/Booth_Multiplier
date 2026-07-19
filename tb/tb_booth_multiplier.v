`timescale 1ns / 1ps

//=====================================================
// Module : tb_booth_multiplier
//
// Description:
// Self-checking testbench for the Booth Multiplier.
// Applies multiple signed test cases and compares
// the DUT output with the expected multiplication
// result.
//=====================================================

module tb_booth_multiplier;

    parameter N = 4;

    //=================================================
    // Testbench Signals
    //=================================================
    reg clk;
    reg reset;
    reg start;

    reg signed [N-1:0] multiplicand;
    reg signed [N-1:0] multiplier;

    wire signed [(2*N)-1:0] product;
    wire done;

    //=================================================
    // Device Under Test (DUT)
    //=================================================
    booth_multiplier_top #(
        .N(N)
    ) dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .multiplicand(multiplicand),
        .multiplier(multiplier),
        .product(product),
        .done(done)
    );

    //=================================================
    // Clock Generation (100 MHz)
    //=================================================
    always #5 clk = ~clk;

    //=================================================
    // Test Task
    //=================================================
    task run_test;

        input signed [N-1:0] a;
        input signed [N-1:0] b;

        reg signed [(2*N)-1:0] expected;

        begin

            expected = a * b;

            multiplicand = a;
            multiplier   = b;

            // Start multiplication
            start = 1'b1;
            @(posedge clk);
            start = 1'b0;

            // Wait until multiplication completes
            wait(done);

            // Check result
            if (product == expected)
                $display("PASS : %4d x %4d = %4d", a, b, product);
            else
                $display("FAIL : %4d x %4d | Expected = %4d | Got = %4d",
                          a, b, expected, product);

            @(posedge clk);

        end

    endtask

    //=================================================
    // Test Sequence
    //=================================================
    initial
    begin

        // Initialize signals
        clk = 0;
        reset = 1;
        start = 0;

        multiplicand = 0;
        multiplier   = 0;

        // Apply reset
        #20;
        reset = 0;

        // Test Cases
        run_test( 3,  2);
        run_test( 5, -3);
        run_test(-4,  2);
        run_test(-3, -2);
        run_test( 7,  0);
        run_test( 0,  6);
        run_test( 4,  4);

        #50;

        $display("==========================================");
        $display(" Booth Multiplier Simulation Completed");
        $display("==========================================");

        $finish;

    end

endmodule

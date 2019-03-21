`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The University of Edinburgh
// Engineer: Juozas Pazera s1554371
// 
// Create Date: 25.02.2019 10:42:09
// Design Name: 
// Module Name: CarParameterSelector
// Project Name: IR_interface
// Target Devices: Digilent Basys 3 Board
// Tool Versions: 
// Description: This module takes an input from a user on which car color is selected
//              and ouputs right parameters to generate a pulse sequence to control that
//              car.
// 
// Dependencies: Generic_counter module
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CarParameterSelector(
    input CLK,
    input [1:0] CarSelectIn,
    output [7:0] StartBurstSize,
    output [5:0] CarSelectBurstSize,
    output [5:0] GapSize,
    output [5:0] AssertBurstSize,
    output [4:0] DeAssertBurstSize,
    output FrequencyTrigger,
    output FrequencyPulse,
    output [1:0] SelectedCar
    );
    
    
    wire TRIGGER_10Hz;
    wire TRIGGER_36kHz;
    wire TRIGGER_37_5kHz;
    wire TRIGGER_40kHz;
    reg PULSE_10Hz = 0;
    reg PULSE_36kHz = 0;
    reg PULSE_37_5kHz = 0;
    reg PULSE_40kHz = 0;
    reg [1:0] CAR_SELECT;
    reg FREQ_TRIGGER;
    reg PULSE;
    reg [7:0] START_BURST_SIZE;
    reg [5:0] CAR_SELECT_BURST_SIZE;
    reg [5:0] GAP_SIZE;
    reg [5:0] ASSERT_BURST_SIZE;
    reg [4:0] DE_ASSERT_BURST_SIZE;
    
    //Generic counter modules to generate pulses at different frequencies for the cars     
    //Need to generate at double the car operating frequency
    //This is due to the implementation used to generate a pulse in this module                      
    Generic_counter # (.COUNTER_WIDTH(11),
                      .COUNTER_MAX(1389) // ~ 72kHz with a negligible error
                      )
                      Counter_36kHz(
                      .CLK(CLK),
                      .RESET(1'b0),
                      .ENABLE(1'b1),
                      .TRIG_OUT(TRIGGER_36kHz)
                          );
    Generic_counter # (.COUNTER_WIDTH(11),
                      .COUNTER_MAX(1333) // ~ 75kHz with a negligible error
                      )
                      Counter_37_5kHz(
                      .CLK(CLK),
                      .RESET(1'b0),
                      .ENABLE(1'b1),
                      .TRIG_OUT(TRIGGER_37_5kHz)
                          );
                          
    Generic_counter # (.COUNTER_WIDTH(11),
                      .COUNTER_MAX(1250) // 80kHz 
                      )
                      Counter_40kHz(
                      .CLK(CLK),
                      .RESET(1'b0),
                      .ENABLE(1'b1),
                      .TRIG_OUT(TRIGGER_40kHz)
                          );
    
    // Following 3 always statements generate a pulse sequence at the cars operating frequency
    always @(posedge TRIGGER_40kHz) begin
        // Pulse at 40kHz
        PULSE_40kHz <= ~PULSE_40kHz;
    end
    
    always @(posedge TRIGGER_36kHz) begin
        // Pulse at 36kHz
        PULSE_36kHz <= ~PULSE_36kHz;
    end
        
    always @(posedge TRIGGER_37_5kHz) begin
        // Pulse at 37.5kHz
        PULSE_37_5kHz <= ~PULSE_37_5kHz;
    end
    
    // Assigning selected car value from input to a reg
    always @(posedge CLK) begin
        CAR_SELECT <= CarSelectIn;
    end
    
    
    always @ (posedge CLK) begin
        // Case statement that assigns right parameter values to registers depending on which car is selected
        case (CAR_SELECT)
            2'd0: begin //BLUE CAR
                START_BURST_SIZE <= 191;
                CAR_SELECT_BURST_SIZE <= 47;
                GAP_SIZE <= 25;
                ASSERT_BURST_SIZE <= 47;
                DE_ASSERT_BURST_SIZE <= 22;
                FREQ_TRIGGER <= TRIGGER_36kHz;
                PULSE <= PULSE_36kHz;
            end
            2'd1: begin //YELLOW CAR
                START_BURST_SIZE <= 88;
                CAR_SELECT_BURST_SIZE <= 22;
                GAP_SIZE <= 40;
                ASSERT_BURST_SIZE <= 44;
                DE_ASSERT_BURST_SIZE <= 22;
                FREQ_TRIGGER <= TRIGGER_40kHz;
                PULSE <= PULSE_40kHz;
            end
            2'd2: begin //GREEN CAR
                START_BURST_SIZE <= 88;
                CAR_SELECT_BURST_SIZE <= 44;
                GAP_SIZE <= 40;
                ASSERT_BURST_SIZE <= 44;
                DE_ASSERT_BURST_SIZE <= 22;
                FREQ_TRIGGER <= TRIGGER_37_5kHz;
                PULSE <= PULSE_37_5kHz;
            end
            2'd3: begin //RED CAR
                START_BURST_SIZE <= 192;
                CAR_SELECT_BURST_SIZE <= 24;
                GAP_SIZE <= 24;
                ASSERT_BURST_SIZE <= 48;
                DE_ASSERT_BURST_SIZE <= 24;
                FREQ_TRIGGER <= TRIGGER_36kHz;
                PULSE <= PULSE_36kHz;
            end
        endcase
    end
    
    assign StartBurstSize = START_BURST_SIZE;
    assign CarSelectBurstSize = CAR_SELECT_BURST_SIZE;
    assign GapSize = GAP_SIZE;
    assign AssertBurstSize = ASSERT_BURST_SIZE;
    assign DeAssertBurstSize = DE_ASSERT_BURST_SIZE;
    assign FrequencyTrigger = FREQ_TRIGGER;
    assign FrequencyPulse = PULSE;
    assign SelectedCar = CAR_SELECT;
    
endmodule

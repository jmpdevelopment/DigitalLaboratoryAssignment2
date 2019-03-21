`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.03.2019 12:04:18
// Design Name: IR_Interface_assignment 2
// Module Name: IR_driver
// Project Name: IR_Interface_assignment 2
// Target Devices: Digilent Basys 3 Board
// Tool Versions: 
// Description: This module ties up 7Segment display module, CarParameterSelector and IRTransmitterSM. 
// 
// Dependencies: SevenSegmentDisplay, CarParameterSelector, IRTransmitterSM modules
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module IR_driver(
    input CLK,
    input [1:0] CarSelectIn,
    output [1:0] CarSelectOut,
    output IRLed,
    input [7:0] BUS_ADDR,
    input [7:0] BUS_DATA,
    output [6:0] SegmentDisplayOut,
    output [3:0] SegmentDisplayAnodeActivate
);
    
    wire [7:0] START_BURST_SIZE;
    wire [5:0] CAR_SELECT_BURST_SIZE;
    wire [5:0] GAP_SIZE;
    wire [5:0] ASSERT_BURST_SIZE;
    wire [4:0] DE_ASSERT_BURST_SIZE;
    wire FREQUENCY_TRIGGER;
    wire FREQUENCY_PULSE;
    wire GENERATED_PACKET;
    wire [1:0] SELECTED_CAR;
    reg [3:0] COMMAND = 4'b0000;
    wire [3:0] ACTIVE_ANODE;
    wire [6:0] SEGMENT_DISPLAY_OUT;
    
    // listens when BUS_ADDR is changed to 10010000 which is predefined ADDR for IR_Transimitter and reads data from memory as a command
    always @(CLK, BUS_ADDR) begin
        if (BUS_ADDR == 8'b10010000)
            COMMAND <= BUS_DATA;
    end
    
    // CarParameterSelector outputs required Burst Sizes and Frequency given the selected car as an input
    CarParameterSelector # ()
        CarSelector (
            .CLK(CLK),
            .CarSelectIn(CarSelectIn),
            .StartBurstSize(START_BURST_SIZE),
            .CarSelectBurstSize(CAR_SELECT_BURST_SIZE),
            .GapSize(GAP_SIZE),
            .AssertBurstSize(ASSERT_BURST_SIZE),
            .DeAssertBurstSize(DE_ASSERT_BURST_SIZE),
            .FrequencyTrigger(FREQUENCY_TRIGGER),
            .FrequencyPulse(FREQUENCY_PULSE),
            .SelectedCar(SELECTED_CAR)
        );
    
    // IRTransmitterSM outputs generated pulse given the burst sizes from CarParameterSelector and COMMAND
    IRTransmitterSM # ()
        IRTransmitterSM (
            .CLK(CLK),
            .Command(COMMAND),
            .StartBurstSize(START_BURST_SIZE),
            .CarSelectBurstSize(CAR_SELECT_BURST_SIZE),
            .GapSize(GAP_SIZE),
            .AssertBurstSize(ASSERT_BURST_SIZE),
            .DeAssertBurstSize(DE_ASSERT_BURST_SIZE),
            .FrequencyTrigger(FREQUENCY_TRIGGER),
            .FrequencyPulse(FREQUENCY_PULSE),
            .IRLed(GENERATED_PACKET)
        );
        
    // given selected car display the first letter of the color of the car on seven segment display
    SevenSegmentDisplay # ()
        SevenSegmentDisplay(
            .CLK(CLK),
            .CarSelect(SELECTED_CAR),
            .ActiveAnode(ACTIVE_ANODE),
            .SegmentDisplayOut(SEGMENT_DISPLAY_OUT)
        );
    
    assign IRLed = GENERATED_PACKET; // generated packet to transmit via IR LED
    assign SegmentDisplayAnodeActivate = ACTIVE_ANODE;
    assign SegmentDisplayOut = SEGMENT_DISPLAY_OUT;
    assign CarSelectOut = SELECTED_CAR;
        
endmodule
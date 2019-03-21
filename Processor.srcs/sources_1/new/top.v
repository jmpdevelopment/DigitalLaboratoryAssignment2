`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.03.2019 09:31:30
// Design Name: IR_Interface_assignment 2
// Module Name: top
// Project Name: IR_interface
// Target Devices: Digilent Basys 3 Board
// Tool Versions: 
// Description: This module wires up Processor, RAM, ROM, Timer, and IR_driver modules. 
// 
// Dependencies: Processor, RAM, ROM, Timer, IR_driver modules
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top(

    input CLK,
    input RESET,
    input [1:0] CAR_SELECT_IN,
    output [1:0] CAR_SELECT_OUT,
    output IR_LED,
    output [6:0] SEGMENT_DISPLAY_OUT,
    output [3:0] SEGMENT_DISPLAY_ANODE_ACTIVE 
);
    
    wire [7:0] Bus_Data;
    wire [7:0] Bus_Addr;
    wire Bus_WE;
    wire [7:0] Rom_Address;
    wire [7:0] Rom_Data;
    wire [1:0] Bus_Interrupts_Rise;
    wire [1:0] Bus_Interrupts_Ack;
    
    
    Processor Processor_1(
        //Standard Signals
        .CLK(CLK),
        .RESET(RESET),
        //BUS Signals
        .BUS_DATA(Bus_Data),
        .BUS_ADDR(Bus_Addr),
        .BUS_WE(Bus_WE),
        // ROM signals
        .ROM_ADDRESS(Rom_Address),
        .ROM_DATA(Rom_Data),
        // INTERRUPT signals
        .BUS_INTERRUPTS_RAISE(Bus_Interrupts_Rise),
        .BUS_INTERRUPTS_ACK(Bus_Interrupts_Ack)
    );
     
     
    ROM ROM_1(
        //standard signals
        .CLK(CLK),
        //BUS signals
        .DATA(Rom_Data),
        .ADDR(Rom_Address)
    );
    
    RAM RAM_1(
        //standard signals
        .CLK(CLK),
        //BUS signals
        .BUS_DATA(Bus_Data),
        .BUS_ADDR(Bus_Addr),
        .BUS_WE(Bus_WE)
    );
    
    Timer # (.InitialIterruptRate(100))  Timer_1(
        //standard signals
        .CLK(CLK),
        .RESET(RESET),
        //BUS signals
        .BUS_DATA(Bus_Data),
        .BUS_ADDR(Bus_Addr),
        .BUS_WE(Bus_WE),
        .BUS_INTERRUPT_RAISE(Bus_Interrupts_Rise[1]),
        .BUS_INTERRUPT_ACK(Bus_Interrupts_Ack[1])
    );
    
    IR_driver IR_driver_1(
        .CLK(CLK),
        .CarSelectIn(CAR_SELECT_IN),
        .CarSelectOut(CAR_SELECT_OUT),
        .IRLed(IR_LED),
        .BUS_ADDR(Bus_Addr),
        .BUS_DATA(Bus_Data),
        .SegmentDisplayOut(SEGMENT_DISPLAY_OUT),
        .SegmentDisplayAnodeActivate(SEGMENT_DISPLAY_ANODE_ACTIVE)
    );

endmodule

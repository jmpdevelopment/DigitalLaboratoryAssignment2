`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The University of Edinburgh
// Engineer: Juozas Pazera s1554371
// 
// Create Date: 25.02.2019 12:17:58
// Design Name: 
// Module Name: 7SegmentDisplay
// Project Name: IR_interface
// Target Devices: Digilent Basys 3 Board
// Tool Versions: 
// Description: This module takes an input on which car is selected and shows the first letter of the car color
//              on 7 Segment display
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module SevenSegmentDisplay(
    input CLK,
    input [1:0] CarSelect,
    output [3:0] ActiveAnode,
    output [6:0] SegmentDisplayOut 
    );
    
    reg [3:0] ACTIVE_ANODE;
    reg [6:0] SEGMENT_DISPLAY_OUT;
    
    // Checks which car is selected at every positive edge of the clock and lights up right LEDs
    always @ (posedge CLK) begin
            case (CarSelect)
                2'd0: begin //BLUE car
                    ACTIVE_ANODE = 4'b1110;
                    SEGMENT_DISPLAY_OUT = 7'b1100000;
                end
                2'd1: begin //YELLOW car
                    ACTIVE_ANODE = 4'b1110;
                    SEGMENT_DISPLAY_OUT = 7'b1000100;
                end
                2'd2: begin //GREEN car
                    ACTIVE_ANODE = 4'b1110;
                    SEGMENT_DISPLAY_OUT = 7'b0100001;
                end
                2'd3: begin //RED car
                    ACTIVE_ANODE = 4'b1110;
                    SEGMENT_DISPLAY_OUT = 7'b1111010;
                end
            endcase
    end
    
    assign ActiveAnode = ACTIVE_ANODE;
    assign SegmentDisplayOut = SEGMENT_DISPLAY_OUT;
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The University of Edinburgh
// Engineer: Juozas Pazera s1554371
// 
// Create Date: 28.10.2017 15:10:26
// Design Name: 
// Module Name: Generic_counter
// Project Name: 
// Target Devices: Digilent Basys 3 Board
// Tool Versions: 
// Description: This is a generic counter module used to generate different frequency impulses from 100 MHz internal clock
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Generic_counter(
    CLK,
    RESET,
    ENABLE,
    TRIG_OUT,
    COUNT
    );
    
    
    parameter COUNTER_WIDTH = 4;
    parameter COUNTER_MAX = 9;
    
    input CLK;
    input RESET;
    input ENABLE;
    output TRIG_OUT;
    output [COUNTER_WIDTH-1:0] COUNT;
    
    reg [COUNTER_WIDTH-1:0] count_value = 0;
    reg Trigger_out;
    
    // Counter counts up to the given specific value incrementing at the speed of internal clock (100MHz for Basys 3 board).
    // Once it reaches given count value it gives out a trigger impulse
    // This allows to create lower frequency clocks than the internal one
    always@(posedge CLK) begin
        if (RESET)
            count_value <= 0;
        else begin
            if(ENABLE) begin
                if(count_value==COUNTER_MAX)
                    count_value <= 0;
                else
                    count_value <= count_value + 1;
             end
          end
      end
      
      always@(posedge CLK) begin
           if(RESET)
               Trigger_out <= 0;
           else begin
                if (ENABLE && (count_value == COUNTER_MAX))
                    Trigger_out <= 1;
                else 
                    Trigger_out <= 0;
           end
      end
      
      assign COUNT = count_value;
      assign TRIG_OUT = Trigger_out;
      
endmodule

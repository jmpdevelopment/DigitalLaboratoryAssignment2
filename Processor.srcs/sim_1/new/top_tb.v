`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.03.2019 09:46:36
// Design Name: 
// Module Name: top_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_tb(

    );
    
    
    reg CLK;
    reg RESET;
    reg [1:0] CAR_SELECT_IN;
    
    top uut(
    
    .CLK(CLK),
    .RESET(RESET),
    .CAR_SELECT_IN(CAR_SELECT_IN)
    
        );
        
        initial begin
        RESET = 0;
        CLK = 0;
        CAR_SELECT_IN = 2'b00;
       
        forever #5 CLK = ~CLK;
        
        end
        
        initial begin
         #100
               RESET = 1;
               #20
               RESET = 0;
        end
    
    
endmodule

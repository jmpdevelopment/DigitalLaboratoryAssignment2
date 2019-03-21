`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The University of Edinburgh
// Engineer: LI YUCHUAN
// 
// Create Date: 12.02.2019 11:49:23
// Design Name: Wrapper
// Module Name: Wrapper
// Project Name: VGA_Interface
// Target Devices: BASY3
// Tool Versions: Vivado 2015.2
// Description: 
// This module is a wrapper for connecting VGA_Sig_Gen and Frame Buffer and give 
// external input for Frame Buffer as a simulation of Microprocessor.This module also
// includes a counter for changing color.
//
// VGA_Interface
// Basic function: 1. Display chequered image on VGA display.
//                 2. Color changes every one second. 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Wrapper(
    input               RESET,
    input               A_WE,                       //Connect to button W19 as write enable siganl 
    input               CLK,                        //Connect to W5 as a 100MHz clock signal
    input        [15:0] CONFIG_COLOURS,             //Connect to 16 switches as color input
    //VGA Port interface                            
    output wire         VGA_HS,                     //Horizontal synchronisation signal
    output wire         VGA_VS,                     //Vertical synchronisation signal
    output wire   [7:0] COLOUR                      //Connect to 8 bit VGA color ([7:6]Blue,[5:3]Green,[2:0]Red)
    );
/**************************************************************************************************************************/     
       //wires to Frame Buffer
       reg             A_DATA_IN;                     //Pixel Data in                   
       //wires for connection of VGA and Frame Buffer
       wire            B_DATA_OUT;                    //Data output from read port                  
       wire            DPR_CLK;                       //Depressed 25MHz clock signal
       wire     [14:0] VGA_ADDR;                      //7bit vertical address + 8 bit honrizontal address
       wire     [6:0]  ADDRV;                         //Vertical address
       wire     [7:0]  ADDRH;                         //Horizontal address
       //wires for changing color every second
       reg             Change_Color=1;
       wire            Color_CLK;                     // 1Hz clock   


/**************************************************************************************************************************/        
       // Instantiate Frame Buffer
       VGA_Sig_Gen VGA(
                  
           .CONFIG_COLOURS(CONFIG_COLOURS),
           .VGA_ADDR(VGA_ADDR),                       
           .VGA_HS(VGA_HS),
           .VGA_VS(VGA_VS),
           .VGA_COLOUR(COLOUR),
           .VGA_DATA(B_DATA_OUT),
           .DPR_CLK(DPR_CLK),                      
           .CLK(CLK)
       ); 
       
       // Instantiate VGA Interface 
       Frame_Buffer FB(
        
          .A_CLK(CLK),
          .A_ADDR(VGA_ADDR),
          .A_DATA_IN(A_DATA_IN),
          .A_WE(A_WE),
//        .A_DATA_OUT(VGA_DATA),
          .B_CLK(DPR_CLK),
          .B_ADDR(VGA_ADDR),
          .B_DATA(B_DATA_OUT)
       );   
       
      // Instantiate counter for changing color
      Generic_counter # (
           .COUNTER_WIDTH(27),
           .COUNTER_MAX(10**8))
            CounterColor(
           .CLK(CLK),
           .RESET(1'b0),
           .ENABLE_IN(1'b1),
           .TRIGER_OUT(Color_CLK)             //Provide a 1Hz clock
            );
/**************************************************************************************************************************/ 
        //Invert the back and front color every second    
        always@(posedge Color_CLK)begin
            Change_Color <= ~Change_Color;
        end
        
        //Get vertical and horizontal address individually
        assign ADDRV = VGA_ADDR[14:8];
        assign ADDRH = VGA_ADDR[7:0];
        
        /* Determine the input data that stores in corresponding memory bits. 
           Each memory bit corresponds to the address of 4*4 pixel.
           To display a chequered image, the addresses that have even x-axis and y-axis will display one color(back or front).
           The rest of other addresses will display another color.
        */
        always@(posedge CLK) begin
            if(RESET)                //Reset memory to all zero
                A_DATA_IN <=0;
            else begin
                if((ADDRV[0]==0)&&(ADDRH[0]==0))   //Check if the value of x-axis and y-axis addresses are both even numbers
                    A_DATA_IN <= Change_Color;
                else
                    A_DATA_IN <= ~Change_Color;
            end
        end
        

endmodule

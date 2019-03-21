`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.01.2019 11:37:36
// Design Name: VGA
// Module Name: VGA_Sig_Gen
// Project Name: VGA_Interface
// Target Devices: BASY3
// Tool Versions: Vivado 2015.2
// Description: VGA signal generator module, which reads consecutive pixel colours in raster pattern,
//              from 'Frame Buffer' module, and outputs the VGA signals through the proper FPGA pins
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module VGA_Sig_Gen(
    input                CLK,
    //Colour Configuration Interface
    input          [15:0]CONFIG_COLOURS,
    //Frame Buffer (Dual port memory) Interface
    input                VGA_DATA,
    output         [14:0]VGA_ADDR,
    output wire          DPR_CLK,    
    //VGA Port Interface
    output reg           VGA_HS,
    output reg           VGA_VS,
    output reg      [7:0]VGA_COLOUR
    );
/**************************************************************************************************************************/     

    /*
    Define VGA signal parameters.Horizontal and Vertical display time, pulse widths, front and bacnk porch widths
    */
    
        parameter HTs       = 800; //Total Horizontal Sync Pulse Time
        parameter HTpw      = 96;  //Horizontal Pulse Width Time
        parameter HTDisp    = 640; //Horizontal Display Time
        parameter HTbp      = 48;  //Horizontal Back porch Time
        parameter HTfp      = 16;  //Horizontal Front porch Time
        
        parameter Vs       = 521; //Total Vertical Sync Pulse Time
        parameter Vpw      = 2;  //Vertical Pulse Width Time
        parameter VDisp    = 480; //Vertical Display Time
        parameter Vbp      = 29;  //Vertical Back porch Time
        parameter Vfp      = 10;  //Vertical Front porch Time
        
/**************************************************************************************************************************/ 
 
        wire    [9:0]HCounter;
        wire    [9:0]VCounter;
        wire         VGA_CLK;
        wire         TriggerOut1;
        wire         TriggerOut2;

/**************************************************************************************************************************/ 
 
        //Change the clock to 25MHz to drive VGA display
           Generic_counter # (
                .COUNTER_WIDTH(2),
                .COUNTER_MAX(3)) 
                 Counter0(
                .CLK(CLK),
                .RESET(1'b0),
                .ENABLE_IN(1'b1),
                .TRIGER_OUT(VGA_CLK)
                ); 
            
        //Assign horizontal counter values for raster scan of display
           Generic_counter # (
               .COUNTER_WIDTH(10),
               .COUNTER_MAX(799))
                CounterHor(
               .CLK(CLK),
               .RESET(1'b0),
               .ENABLE_IN(VGA_CLK),
               .TRIGER_OUT(TriggerOut1),
               .COUNT(HCounter)
               ); 
         //Assign vertical counter values for raster scan of display
           Generic_counter # (
               .COUNTER_WIDTH(10),
               .COUNTER_MAX(520))
                CounterVer(
               .CLK(CLK),
               .RESET(1'b0),
               .ENABLE_IN(TriggerOut1),
               .TRIGER_OUT(TriggerOut2),
               .COUNT(VCounter)
               ); 
/**************************************************************************************************************************/ 
          //Create the address of the next pixel. Concatenate and tie the look ahead address to the frame buffer address
          assign DPR_CLK    = VGA_CLK;                          //Assign a depressed 25Hz clock for read port
          assign VGA_ADDR   = {VCounter[8:2], HCounter[9:2]};   //Decrease the resolution by neglect last 2-bits of address
          
          //Generate horizontal and vertical synchronisation signal
          always@(posedge CLK)begin
            if(HCounter < HTpw)
                VGA_HS <= 0;
            else
                VGA_HS <= 1;
          end
          
          always@(posedge CLK)begin
            if(VCounter < Vpw)
                VGA_VS <= 0;
            else
                VGA_VS <= 1;
          end
          
          /* Define a 640*480 area to show the image
             Determine two different colors which deicided by 1-bit VGA_DATA
          */
          always@(posedge CLK)begin
            if((HCounter < HTs-HTfp)&&(HCounter > HTpw+HTbp)&&(VCounter < Vs-Vfp)&&(VCounter > Vfp + Vpw)) begin  //Display image with in 640*480 area
                if(VGA_DATA==1)                         //Display 8 less significant bits of input color when memory value is 1
                    VGA_COLOUR <= CONFIG_COLOURS [7:0];
                else                                    //Display 8 most significant bits of input color when memory value is 0      
                    VGA_COLOUR <= CONFIG_COLOURS [15:8];
            end
            else begin
                VGA_COLOUR <= 0;
            end
          end
          
endmodule

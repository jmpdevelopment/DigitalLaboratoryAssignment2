`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.01.2019 10:45:02
// Design Name: Frame_Buffer
// Module Name: Frame_Buffer
// Project Name: VGA_Interface
// Target Devices: BASY3
// Tool Versions: Vivado 2015.2
// Description: A dual ported memory module which can be written to by an outside
//              module e.g a microprocessor. In this project, the 'Wrapper' module is used
//              as outside input source. The module is also read from by the 'VGA_Sig_Gen' module 
//              for VGA display.
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Frame_Buffer(
       //Port A - Read/Write
       input               A_CLK,
       input        [14:0] A_ADDR, // 8+7 bits = 15bits hence [14:0]
       input               A_DATA_IN, //Pixel Data in
       output reg          A_DATA_OUT,
       input               A_WE,   //Write Enable
       //Port B -Read Only
       input               B_CLK,
       input        [14:0] B_ADDR, //Pixel Data Out
       output reg          B_DATA 
       

       
     
    );
        // A 256 * 128 1-bit memory to hold frame data
        //the LSBs of the address correspond to the X axis, and the MSBs to the Y axis
        reg[0:0] Mem [2**15-1:0];
        
        //Port A -Read/Write e.g to be used by microprocessor
        always@(posedge A_CLK) begin
            if(A_WE)
                Mem[A_ADDR] <= A_DATA_IN;
                
            A_DATA_OUT <= Mem[A_ADDR];
        end
        
        //Port B - Read Only e.g. to be read from the VGA siganl generatormodule for display
        always@(posedge B_CLK) begin
            B_DATA <= Mem[B_ADDR];
        end

          
endmodule


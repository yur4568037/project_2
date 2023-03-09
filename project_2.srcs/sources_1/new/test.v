`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/08/2023 10:42:50 AM
// Design Name: 
// Module Name: test
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


module test(
    input clk,
    input [3:0] btn,
    input [3:0] sw,
    output [3:0] led,
    output led0_b,
    output led0_g,
    output led0_r
    );
    
    // usual led and buttons
    
    reg out_val, led3_val;
    assign led[1] = out_val;
    
    reg [31:0] counter = 0;
    always@(posedge clk)
    begin
        counter <= counter + 1;
        
        if(counter == 25_000_000)
            out_val <= 1;
        else if(counter == 50_000_000)
        begin
            out_val <= 0;
            counter <= 0; 
        end
    end
    
    assign led[0] = btn[0];
    assign led[2] = 1;
    assign led[3] = led3_val;
    
    
    // rgb led and switches
    
    reg [31:0] period [2:0];
    reg [31:0] limit [2:0];
    reg [31:0] rgb_counter [2:0];
    reg rgb_val [2:0];
    
    reg [31:0] lim_counter;
    integer lim_state [2:0];
    
    integer i, j;
    
    assign led0_b = rgb_val[0];
    assign led0_g = rgb_val[1];
    assign led0_r = rgb_val[2];
    
    initial
    begin
        period [0] = 200_000;   // 500 kHz
        period [1] = 200_000;
        period [2] = 200_000;
        
        limit [0] = 100_000;
        limit [1] = 100_000;
        limit [2] = 100_000;
        
        lim_state[0] = 0;
        lim_state[1] = 0;
        lim_state[2] = 0;
        
        /*
        rgb_val[0] = 1;
        rgb_val[1] = 1;
        rgb_val[2] = 1;
        */
    end
    
    // change led state
    always @ (posedge clk)
    /*
    begin
        if(sw[0])   rgb_val[0] <= 1;
        else        rgb_val[0] <= 0;
        
        for(i=1; i<3; i=i+1)
            if(sw[i])   rgb_val[i] <= 1;
            else        rgb_val[i] <= 0;    
    end
    */
    
    for(i=0; i<3; i=i+1)
    begin
        rgb_counter[i] <= rgb_counter[i] + 1;
        
        if(rgb_counter[i] >= period[i]) // period default == 200_000
        begin
            if(sw[i] > 0)
                rgb_val[i] <= 1;
            else
                rgb_val[i] <= 0;
                
            rgb_counter[i] <= 0;
        end
        
        if(rgb_counter[i] >= limit[i] && rgb_val[i] == 1)  // limit default == 100_000
        begin
            rgb_val[i] <= 0;
        end
    end
    
    
    
    // change limits with 200 kHz frequency
    always @ (posedge clk)
    begin
        lim_counter <= lim_counter + 1;
        
        //if(lim_counter >= 2500) // 40 kHz
        if(lim_counter >= 500) // 200 kHz
        begin
            lim_counter <= 0;
            
            if(sw[3] > 0)
            begin
                led3_val <= 1;
            
                for(j=0; j<3; j=j+1)
                begin
                    if(sw[j] > 0)
                    begin
                        // increment or decrement
                        if(lim_state[j] == 0)
                            if(limit[j] < period[j])    limit[j] <= limit[j] + 1;
                            else lim_state[j] <= 1;
                        else
                            if(limit[j] > 0)            limit[j] <= limit[j] - 1;
                            else lim_state[j] <= 0;
                    end
                    else
                        limit[j] <= 100_000;
                end
            end // if(sw[3] > 0)
            else
            begin
                led3_val <= 0;
            
                limit [0] <= 100_000;
                limit [1] <= 100_000;
                limit [2] <= 100_000;
            end
        end // if(lim_counter <= 2500) // 40 kHz
    end // always @ (posedge clk)
        
endmodule

`timescale 1ns/10ps
`define CYCLE 20
module tb();
reg clk, rst;
reg [15:0] message;
wire [31:0] out;
wire fft_valid;
initial begin     
     $dumpfile("FAS.fsdb");
     $dumpvars;   	 
     clk=1'b0;
     rst=1'b0;
     fir_valid=1'b0;
     #1 rst = 1'b1;
     #5 fft_d_in = 16'b 1111111111111111;
     #5 rst = 1'b0;
        fir_valid = 1;
     #(`CYCLE) fft_d_in = 16'b 0000000000000001;
     #(`CYCLE) fft_d_in = 16'b 0000000000000011;
     #(`CYCLE) fft_d_in = 16'b 0000000000000111;
     #(`CYCLE) fft_d_in = 16'b 0000000000001111;
     #(`CYCLE) fft_d_in = 16'b 0000000000011111;
     #(`CYCLE) fft_d_in = 16'b 0000000000111111;
     #(`CYCLE) fft_d_in = 16'b 0000000001111111;
     #(`CYCLE) fft_d_in = 16'b 0000000011111111;
     #(`CYCLE) fft_d_in = 16'b 0000000111111111;
     #(`CYCLE) fft_d_in = 16'b 0000001111111111;
     #(`CYCLE) fft_d_in = 16'b 0000011111111111;
     #(`CYCLE) fft_d_in = 16'b 0000111111111111;
     #(`CYCLE) fft_d_in = 16'b 0001111111111111;
     #(`CYCLE) fft_d_in = 16'b 0011111111111111;
     #(`CYCLE) fft_d_in = 16'b 0111111111111111;
     #2000 $finish;
end

always begin
  #(`CYCLE/2) clk=~clk;
end

FFTS1 ffts1(.clk(clk), .rst(rst), .fir_valid(fir_valid), .fft_d_in(message), .fft_valid(fft_valid), .fft_d_out(out));
endmodule

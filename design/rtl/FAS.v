module  FAS (data_valid, data, clk, rst, fir_d, fir_valid, fft_valid, done, freq,
 fft_d1, fft_d2, fft_d3, fft_d4, fft_d5, fft_d6, fft_d7, fft_d8,
 fft_d9, fft_d10, fft_d11, fft_d12, fft_d13, fft_d14, fft_d15, fft_d0);
input clk, rst;
input data_valid;
input signed [15:0]data; 

output fir_valid, fft_valid;
output signed [15:0]fir_d;
output signed [31:0]fft_d1, fft_d2, fft_d3, fft_d4, fft_d5, fft_d6, fft_d7, fft_d8;
output signed [31:0]fft_d9, fft_d10, fft_d11, fft_d12, fft_d13, fft_d14, fft_d15, fft_d0;
output done;
output [3:0] freq;


endmodule


module FFTS1(clk, rst, fir_valid, fft_d_in, fft_valid, fft_d_out);
    input clk, rst;
    input fir_valid;
    input signed [15:0]fft_d_in;

    output reg fft_valid;
    output reg signed [31:0]fft_d_out;

    reg [3:0] count_1, count_nxt;
    reg [4:0] count_2, count2_nxt;
    reg valid_1, valid_2;

    reg signed [15:0] buffer [0:7]; 
    reg signed [31:0] buffer2 [0:3];
    reg signed [15:0] out_1;


    always @(*) begin
        if (fir_valid || count_1) count_1_nxt = count_1+1;
        else if (count_1 == 15) count_1 = 0;
        else count_1_nxt = count_1;
    end
//stage1
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i=0; i<8; i=i+1) begin
                buffer[i] <= 0;
            end
            out_1 <= 0;
            count_1 <= 0;
            count_1_nxt <= 0;
            valid_1 <= 0;
        end
        else begin
            case(count_1) 
                0 : buffer[0] <= fft_d_in;
                1 : buffer[1] <= fft_d_in;
                2 : buffer[2] <= fft_d_in;
                3 : buffer[3] <= fft_d_in;
                4 : buffer[4] <= fft_d_in;
                5 : buffer[5] <= fft_d_in; 
                6 : buffer[6] <= fft_d_in;
                7 : buffer[7] <= fft_d_in;
                8 : begin
                    out_1 <= buffer[0] + fft_d_in; //x2[0]
                    buffer[0] <= buffer[0] - fft_d_in; //x2[8]   
                end
                9 : begin
                    out_1 <= buffer[1] + fft_d_in; //x2[1]
                    buffer[1] <= buffer[1] - fft_d_in; //x2[9]
                    valid_1 <= 1;
                end
                10: begin
                    out_1 <= buffer[2] + fft_d_in; //x2[2]
                    buffer[2] <= buffer[2] - fft_d_in; //x2[10]
                    valid_1 <= 0;
                end
                11: begin
                    out_1 <= buffer[3] + fft_d_in; //x2[3]
                    buffer[3] <= buffer[3] - fft_d_in; //x2[11]
                end
                12: begin
                    out_1 <= buffer[4] + fft_d_in; //x2[4]
                    buffer[4] <= buffer[4] - fft_d_in; //x2[12]
                end
                13: begin
                    out_1 <= buffer[5] + fft_d_in; //x2[5]
                    buffer[5] <= buffer[5] - fft_d_in; //x2[13]
                end
                14: begin
                    out_1 <= buffer[6] + fft_d_in; //x2[6]
                    buffer[6] <= buffer[6] - fft_d_in; //x2[14]
                end
                15: begin
                    out_1 <= buffer[7] + fft_d_in; //x2[7]
                    buffer[7] <= buffer[7] - fft_d_in; //x2[15]
                end
            endcase                
            count_1 <= count_1_nxt;
        end
    end

//stage2
always @(*) begin
        if (valid_1 || count_2) count_2_nxt = count_2+1;
        else if (count_2 == 19) count_2 = 0;
        else count_2_nxt = count_2;
    end
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for(i=0; i<4; i=i+1) begin
                buffer2[i] <= 0;
            end
            fft_d_out <=0;
            count_2 <= 0;
            count_2_nxt <= 0;
            valid_2 <= 0;
        end
        else begin
            case(count_2) 
                0 : begin
                    buffer2[0] <= {out_1, 16'h0}; //x2[0]
                end
                1 : begin 
                    buffer2[1] <= {out_1, 16'h0}; //x2[1]
                end
                2 : begin
                    buffer2[2] <= {out_1, 16'h0}; //x2[2]
                end
                3 : begin
                    buffer2[3] <= {out_1, 16'h0}; //x2[3]
                end
                4 : begin
                    fft_d_out <= {buffer2[0][31:16]+out_1, 16'h0};
                    buffer2[0] <= {buffer2[0][31:16]-out_1, 16'h0};        //y4
                    valid_2 <= 1;
                end
                5 : begin
                    fft_d_out <= {buffer2[1][31:16]+out_1, 16'h0};
                    buffer2[1] <= {buffer2[1][31:16]-out_1, 16'h0};         //y5
                    valid_2 <= 0;
                end

                6 : begin
                    fft_d_out <= {buffer2[2][31:16]+out_1, 16'h0};
                    buffer2[2] <= {buffer2[2][31:16]-out_1, 16'h0};         //y6
                end
                7 : begin
                    fft_d_out <= {buffer2[3][31:16]+out_1, 16'h0};
                    out_1 <= buffer[0];             //x2[8]
                    buffer2[3] <= {buffer2[3][31:16]-out_1, 16'h0};         //y7
                end
                8 : begin
                    fft_d_out <= buffer2[0];
                    out_1 <= buffer[1];             //x2[9]
                    buffer2[0] <= {out_1, 16'h0};            //x2[8]
                end
                9 : begin
                    fft_d_out <= buffer2[1];
                    out_1 <= buffer[2];             //x2[10]
                    buffer2[1] <= {out_1, 16'h0};            //x2[9]
                end
                10: begin
                    fft_d_out <= buffer2[2];
                    out_1 <= buffer[3];             //x2[11]
                    buffer2[2] <= {out_1, 16'h0};            //x2[10]
                end
                11: begin
                    fft_d_out <= buffer2[3];
                    out_1 <= buffer[4];             //x2[12]
                    buffer2[3] <= {out_1, 16'h0};            //x2[11]
                end
                12: begin
                    out_1 <= buffer[5];             //x2[13]
                    fft_d_out <= {buffer2[0][31:16], -out_1};
                    buffer2[0] <= {buffer2[0][31:16], out_1}; //y12
                end
                13: begin
                    out_1 <= buffer[6];             //x2[14]   
                    fft_d_out <= {buffer2[1][31:16], -out_1};
                    buffer2[1] <= {buffer2[1][31:16], out_1}; //y13     
                end
                14: begin
                    out_1 <= buffer[7];                //x2[15]
                    fft_d_out <= {buffer2[2][31:16], -out_1};
                    buffer2[2] <= {buffer2[2][31:16], out_1}; //y14   
                end
                15: begin
                    fft_d_out <= {buffer2[3][31:16], -out_1};
                    buffer2[3] <= {buffer2[3][31:16], out_1}; //y15 
                end
                16: begin
                    fft_d_out <= buffer2[0];
                end
                17: begin
                    fft_d_out <= buffer2[1];
                end
                18: begin
                    fft_d_out <= buffer2[2];
                end
                19: begin
                    fft_d_out <= buffer2[3];
                end
                default: begin
                    fft_d_out <= 32'h0;
                    valid_2 <= 0;
                end
            endcase                
            count_2 <= count_2_nxt;
            if (valid_2)        fft_valid <= 1;
            else                fft_valid <= 0;
        end
    end
endmodule

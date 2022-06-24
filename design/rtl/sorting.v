module SORTING(
    clk,
    rst_n,
    start_sorting,
    out_r,
    out_i,
    answer,
    seq
);

/*
*****************************
*    [0] output ->  [0]     * 
*    [1] output ->  [8]     *
*    [2] output ->  [4]     *
*    [3] output ->  [12]    *                                              
*    [4] output ->  [2]     *
*    [5] output ->  [10]    *
*    [6] output ->  [6]     *
*    [7] output ->  [14]    *
*    [8] output ->  [1]     *
*    [9] output ->  [9]     *
*    [10] output ->  [5]    *
*    [11] output ->  [13]   *
*    [12] output ->  [3]    *
*    [13] output ->  [11]   *                                              
*    [14] output ->  [7]    *
*    [15] output ->  [15]   *
*****************************
*/

integer               i, j, next_j;
input                 clk, rst_n, start_sorting;                  
reg                   sort, next_sort, finish, n_seq;
reg            [3:0]  count, next_count;
input  signed  [7:0] out_r;
input  signed  [7:0] out_i;
output reg signed  [7:0] answer;
output reg            seq;
reg    signed  [7:0] result[0:31];
reg    signed  [7:0] prev_out_r;
reg    signed  [7:0] prev_out_i;
reg    signed  [7:0] next_result_r[0:15];
reg    signed  [7:0] next_result_i[0:15];



always@(*) begin
    next_sort = sort;
    n_seq = seq;
    if(seq) begin
        next_j = j;
    end
    if(next_sort) begin
        next_count = count;
        case(next_count)
            4'd0 : begin
                next_result_r[0] = prev_out_r;
                next_result_i[0] = prev_out_i;
            end
            4'd1 : begin
                next_result_r[8] = prev_out_r;
                next_result_i[8] = prev_out_i;
            end
            4'd2 : begin
                next_result_r[4] = prev_out_r;
                next_result_i[4] = prev_out_i;
            end
            4'd3 : begin
                next_result_r[12] = prev_out_r;
                next_result_i[12] = prev_out_i;
            end
            4'd4 : begin
                next_result_r[2] = prev_out_r;
                next_result_i[2] = prev_out_i;
            end
            4'd5 : begin
                next_result_r[10] = prev_out_r;
                next_result_i[10] = prev_out_i;
            end
            4'd6 : begin
                next_result_r[6] = prev_out_r;
                next_result_i[6] = prev_out_i;
            end
            4'd7 : begin
                next_result_r[14] = prev_out_r;
                next_result_i[14] = prev_out_i;
            end
            4'd8 : begin
                next_result_r[1] = prev_out_r;
                next_result_i[1] = prev_out_i;
            end
            4'd9 : begin
                next_result_r[9] = prev_out_r;
                next_result_i[9] = prev_out_i;
            end
            4'd10 : begin
                next_result_r[5] = prev_out_r;
                next_result_i[5] = prev_out_i;
            end
            4'd11 : begin
                next_result_r[13] = prev_out_r;
                next_result_i[13] = prev_out_i;
            end
            4'd12 : begin
                next_result_r[3] = prev_out_r;
                next_result_i[3] = prev_out_i;
            end
            4'd13 : begin
                next_result_r[11] = prev_out_r;
                next_result_i[11] = prev_out_i;
            end
            4'd14 : begin
                next_result_r[7] = prev_out_r;
                next_result_i[7] = prev_out_i;
            end
            4'd15 : begin
                next_result_r[15] = prev_out_r;
                next_result_i[15] = prev_out_i;
                next_sort = 0;
                n_seq = 1'b1;
            end
        endcase
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        prev_out_r <= 0;
        prev_out_i <= 0;
        for (i = 0; i < 16; i = i+1) begin
            result[i] <= 0;
        end
        sort <= 0;
        j <= 0;
        answer <= 0;
        count <= 0;
        seq <= 0;
    end
    else begin
        prev_out_r <= out_r;
        prev_out_i <= out_i;
        seq <= n_seq;
        for (i = 0; i < 16; i = i+1) begin
            result[i] <= next_result_r[i];
            result[i+16] <= next_result_i[i];
        end
        sort <= next_sort;
        if(n_seq) begin
            answer <= result[j];
            j <= next_j + 1;
        end
        if(start_sorting)count <= next_count + 1;
    end
end

endmodule
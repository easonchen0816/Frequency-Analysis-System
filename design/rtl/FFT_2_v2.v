module FFT_2(
    input                   clk,
    input                   rst,
    input                   valid,
    input           [31:0]  d_in,
    output  reg             fft_valid,
    output  reg signed  [31:0]  fft_out
);

    // input
    wire   signed  [15:0]  d_in_real, d_in_imag;

    /////////////////////////// 1st stage signal ///////////////////////////

    // control signal
    reg                     valid_1;

    // counter
    reg             [3:0]   cnt_1, cnt_1_nxt;

    // real multiplier
    wire    signed  [15:0]  r_mul_A_1;
    reg     signed  [31:0]  r_mul_B_1;
    reg    signed  [47:0]  r_mul_Z_1;
    reg     signed  [47:0]  r_mul_Z_1_b;


    wire    signed  [15:0]  r_mul_A_2;
    reg     signed  [31:0]  r_mul_B_2;
    reg    signed  [47:0]  r_mul_Z_2;
    reg     signed  [47:0]  r_mul_Z_2_b;


    // imag multiplier
    wire    signed  [15:0]  i_mul_A_1;
    reg     signed  [31:0]  i_mul_B_1;
    reg    signed  [47:0]  i_mul_Z_1;
    reg     signed  [47:0]  i_mul_Z_1_b;


    wire    signed  [15:0]  i_mul_A_2;
    reg     signed  [31:0]  i_mul_B_2;
    reg    signed  [47:0]  i_mul_Z_2;
    reg     signed  [47:0]  i_mul_Z_2_b;


    // adder
    wire    signed  [47:0]  r_add_Z_1;
    wire    signed  [47:0]  i_add_Z_1;

    /////////////////////////// 2nd stage signal ///////////////////////////

    // control signal
    reg                     valid_2[0:2];

    // counter
    reg             [4:0]   cnt_2, cnt_2_nxt;

    // multiplier data
    reg     signed  [31:0]  r_data_2;
    reg     signed  [31:0]  i_data_2;

    // shift register
    reg     signed  [31:0]  rbuf_2[0:1], rbuf_2_nxt[0:1];
    reg     signed  [31:0]  ibuf_2[0:1], ibuf_2_nxt[0:1];
    integer                 i;

    // adder data
    wire    signed  [31:0]  r_add_A_2;
    wire    signed  [31:0]  r_add_B_2;
    wire    signed  [31:0]  r_add_Z_2;

    wire    signed  [31:0]  i_add_A_2;
    wire    signed  [31:0]  i_add_B_2;
    wire    signed  [31:0]  i_add_Z_2; 

    // subtract data
    wire    signed  [31:0]  r_sub_A_2;
    wire    signed  [31:0]  r_sub_B_2;
    wire    signed  [31:0]  r_sub_Z_2;

    wire    signed  [31:0]  i_sub_A_2;
    wire    signed  [31:0]  i_sub_B_2;
    wire    signed  [31:0]  i_sub_Z_2; 

    /////////////////////////// 3th stage signal ///////////////////////////

    // control signal
    reg                     valid_3[0:1];

    // counter
    reg             [4:0]   cnt_3, cnt_3_nxt;

    // data
    reg     signed  [31:0]  r_data_3;
    reg     signed  [31:0]  i_data_3;

    reg     signed  [31:0]  r_data_3_nxt;
    reg     signed  [31:0]  i_data_3_nxt;

    // shift register
    reg     signed  [31:0]  rbuf_3, rbuf_3_nxt;
    reg     signed  [31:0]  ibuf_3, ibuf_3_nxt;
    
    // adder data
    wire    signed  [31:0]  r_add_A_3;
    reg     signed  [31:0]  r_add_B_3;
    wire    signed  [31:0]  r_add_Z_3;

    wire    signed  [31:0]  i_add_A_3;
    reg     signed  [31:0]  i_add_B_3;
    wire    signed  [31:0]  i_add_Z_3; 

    // subtract data
    wire    signed  [31:0]  r_sub_A_3;
    reg     signed  [31:0]  r_sub_B_3;
    wire    signed  [31:0]  r_sub_Z_3;

    wire    signed  [31:0]  i_sub_A_3;
    reg     signed  [31:0]  i_sub_B_3;
    wire    signed  [31:0]  i_sub_Z_3;

    // output
    reg     signed  [31:0]  fft_out_nxt;


    parameter signed [31:0] W0_R = 32'h00010000;      //32'b00000000000000010000000000000000 The real part of the reference table about COS(x)+i*SIN(x) value , 0: 001
    parameter signed [31:0] W1_R = 32'h0000EC83;      //32'b00000000000000010002020010000102 The real part of the reference table about COS(x)+i*SIN(x) value , 1: 9.238739e-001
    parameter signed [31:0] W2_R = 32'h0000B504;      //32'b00000000000000010202010100000100 The real part of the reference table about COS(x)+i*SIN(x) value , 2: 7.070923e-001
    parameter signed [31:0] W3_R = 32'h000061F7;      //32'b00000000000000001020001000002002 The real part of the reference table about COS(x)+i*SIN(x) value , 3: 3.826752e-001
    parameter signed [31:0] W4_R = 32'h00000000;      //32'b00000000000000000000000000000000 The real part of the reference table about COS(x)+i*SIN(x) value , 4: 000
    parameter signed [31:0] W5_R = 32'hFFFF9E09;      //32'b00000000000000002010002000001001 The real part of the reference table about COS(x)+i*SIN(x) value , 5: -3.826752e-001
    parameter signed [31:0] W6_R = 32'hFFFF4AFC;      //32'b00000000000000020101020200000200 The real part of the reference table about COS(x)+i*SIN(x) value , 6: -7.070923e-001
    parameter signed [31:0] W7_R = 32'hFFFF137D;      //32'b00000000000000020001010020000201 The real part of the reference table about COS(x)+i*SIN(x) value , 7: -9.238739e-001
    parameter signed [31:0] W9_R = 32'hFFFF137D;      //32'b00000000000000020001010020000201 The real part of the reference table about COS(x)+i*SIN(x) value , 9: -9.238739e-001


    parameter signed [31:0] W0_I = 32'h00000000;      //32'b00000000000000000000000000000000 The imag part of the reference table about COS(x)+i*SIN(x) value , 0: 000
    parameter signed [31:0] W1_I = 32'hFFFF9E09;      //32'b00000000000000002010002000001001 The imag part of the reference table about COS(x)+i*SIN(x) value , 1: -3.826752e-001
    parameter signed [31:0] W2_I = 32'hFFFF4AFC;      //32'b00000000000000020101020200000200 The imag part of the reference table about COS(x)+i*SIN(x) value , 2: -7.070923e-001
    parameter signed [31:0] W3_I = 32'hFFFF137D;      //32'b00000000000000020001010020000201 The imag part of the reference table about COS(x)+i*SIN(x) value , 3: -9.238739e-001
    parameter signed [31:0] W4_I = 32'hFFFF0000;      //32'b00000000000000020000000000000000 The imag part of the reference table about COS(x)+i*SIN(x) value , 4: -01
    parameter signed [31:0] W5_I = 32'hFFFF137D;      //32'b00000000000000020001010020000201 The imag part of the reference table about COS(x)+i*SIN(x) value , 5: -9.238739e-001
    parameter signed [31:0] W6_I = 32'hFFFF4AFC;      //32'b00000000000000020101020200000200 The imag part of the reference table about COS(x)+i*SIN(x) value , 6: -7.070923e-001
    parameter signed [31:0] W7_I = 32'hFFFF9E09;      //32'b00000000000000002010002000001001 The imag part of the reference table about COS(x)+i*SIN(x) value , 7: -3.826752e-001
    parameter signed [31:0] W9_I = 32'h000061F7;      //32'b00000000000000001020001000002002 The imag part of the reference table about COS(x)+i*SIN(x) value , 9: 3.826752e-001

    assign d_in_real = d_in[31:16];
    assign d_in_imag = d_in[15: 0];


    // ************************************************************
    // ************************ 1st stage *************************
    // ************************************************************

    /////////////////////////// Counter ///////////////////////////

    always @(*) begin
        if (valid || cnt_1) cnt_1_nxt = cnt_1 + 1;
        else cnt_1_nxt = 0;
    end

    always @(posedge clk) begin
        if (rst) begin
            cnt_1 <= 0;
        end
        else begin
            cnt_1 <= cnt_1_nxt;
        end
    end


    /////////////////////////// Multiplier ///////////////////////////

    assign r_mul_A_1 = d_in_real;
    assign r_mul_A_2 = -d_in_imag;

    assign i_mul_A_1 = d_in_imag;
    assign i_mul_A_2 = d_in_real;

    always @(*) begin
        // real multiplier input
        case (cnt_1) 
            5:  r_mul_B_1 = W2_R;
            6:  r_mul_B_1 = W4_R;
            7:  r_mul_B_1 = W6_R;
            9:  r_mul_B_1 = W1_R;
            10: r_mul_B_1 = W2_R;
            11: r_mul_B_1 = W3_R;
            13: r_mul_B_1 = W3_R;
            14: r_mul_B_1 = W6_R;
            15: r_mul_B_1 = W9_R;
            default: r_mul_B_1 = {15'b0, 1'b1, 16'b0};
        endcase

        case (cnt_1) 
            5:  r_mul_B_2 = W2_I;
            6:  r_mul_B_2 = W4_I;
            7:  r_mul_B_2 = W6_I;
            9:  r_mul_B_2 = W1_I;
            10: r_mul_B_2 = W2_I;
            11: r_mul_B_2 = W3_I;
            13: r_mul_B_2 = W3_I;
            14: r_mul_B_2 = W6_I;
            15: r_mul_B_2 = W9_I;
            default: r_mul_B_2 = {15'b0, 1'b0, 16'b0};
        endcase

        // real multiplier output
        case (cnt_1) 
            5:  r_mul_Z_1 = (r_mul_A_1 << 2) + (r_mul_A_1 << 8) + (r_mul_A_1 << 10) + (r_mul_A_1 << 16) - (r_mul_A_1 << 12) - (r_mul_A_1 << 14); 
            6:  r_mul_Z_1 = 48'b0;
            7:  r_mul_Z_1 = -(r_mul_A_1 << 2) - (r_mul_A_1 << 8) - (r_mul_A_1 << 10) + (r_mul_A_1 << 12) + (r_mul_A_1 << 14) - (r_mul_A_1 << 16);
            9:  r_mul_Z_1 = -r_mul_A_1 + (r_mul_A_1 << 2) + (r_mul_A_1 << 7) - (r_mul_A_1 << 10) - (r_mul_A_1 << 12) + (r_mul_A_1 << 16);
            10: r_mul_Z_1 = (r_mul_A_1 << 2) + (r_mul_A_1 << 8) + (r_mul_A_1 << 10) + (r_mul_A_1 << 16) - (r_mul_A_1 << 12) - (r_mul_A_1 << 14);
            11: r_mul_Z_1 = -r_mul_A_1 - (r_mul_A_1 << 3) + (r_mul_A_1 << 9) - (r_mul_A_1 << 13) + (r_mul_A_1 << 15);
            13: r_mul_Z_1 = -r_mul_A_1 - (r_mul_A_1 << 3) + (r_mul_A_1 << 9) - (r_mul_A_1 << 13) + (r_mul_A_1 << 15);
            14: r_mul_Z_1 = -(r_mul_A_1 << 2) - (r_mul_A_1 << 8) - (r_mul_A_1 << 10) + (r_mul_A_1 << 12) + (r_mul_A_1 << 14) - (r_mul_A_1 << 16);
            15: r_mul_Z_1 = (r_mul_A_1) - (r_mul_A_1 << 2) - (r_mul_A_1 << 7) + (r_mul_A_1 << 10) + (r_mul_A_1 << 12) - (r_mul_A_1 << 16);
            default: r_mul_Z_1 = r_mul_A_1 << 16;
        endcase

        case (cnt_1) 
            5:  r_mul_Z_2 = -(r_mul_A_2 << 2) - (r_mul_A_2 << 8) - (r_mul_A_2 << 10) + (r_mul_A_2 << 12) + (r_mul_A_2 << 14) - (r_mul_A_2 << 16);
            6:  r_mul_Z_2 = -(r_mul_A_2 << 16);
            7:  r_mul_Z_2 = -(r_mul_A_2 << 2) - (r_mul_A_2 << 8) - (r_mul_A_2 << 10) + (r_mul_A_2 << 12) + (r_mul_A_2 << 14) - (r_mul_A_2 << 16);
            9:  r_mul_Z_2 = (r_mul_A_2) + (r_mul_A_2 << 3) - (r_mul_A_2 << 9) + (r_mul_A_2 << 13) - (r_mul_A_2 << 15);
            10: r_mul_Z_2 = -(r_mul_A_2 << 2) - (r_mul_A_2 << 8) - (r_mul_A_2 << 10) + (r_mul_A_2 << 12) + (r_mul_A_2 << 14) - (r_mul_A_2 << 16);
            11: r_mul_Z_2 = (r_mul_A_2) - (r_mul_A_2 << 2) - (r_mul_A_2 << 7) + (r_mul_A_2 << 10) + (r_mul_A_2 << 12) - (r_mul_A_2 << 16);
            13: r_mul_Z_2 = (r_mul_A_2) - (r_mul_A_2 << 2) - (r_mul_A_2 << 7) + (r_mul_A_2 << 10) + (r_mul_A_2 << 12) - (r_mul_A_2 << 16);
            14: r_mul_Z_2 = -(r_mul_A_2 << 2) - (r_mul_A_2 << 8) - (r_mul_A_2 << 10) + (r_mul_A_2 << 12) + (r_mul_A_2 << 14) - (r_mul_A_2 << 16);
            15: r_mul_Z_2 = -r_mul_A_2 - (r_mul_A_2 << 3) + (r_mul_A_2 << 9) - (r_mul_A_2 << 13) + (r_mul_A_2 << 15);
            default: r_mul_Z_2 = 48'b0;
        endcase

        // imag multiplier input
        case (cnt_1) 
            5:  i_mul_B_1 = W2_R;
            6:  i_mul_B_1 = W4_R;
            7:  i_mul_B_1 = W6_R;
            9:  i_mul_B_1 = W1_R;
            10: i_mul_B_1 = W2_R;
            11: i_mul_B_1 = W3_R;
            13: i_mul_B_1 = W3_R;
            14: i_mul_B_1 = W6_R;
            15: i_mul_B_1 = W9_R;
            default: i_mul_B_1 = {15'b0, 1'b1, 16'b0};
        endcase

        case (cnt_1) 
            5:  i_mul_B_2 = W2_I;
            6:  i_mul_B_2 = W4_I;
            7:  i_mul_B_2 = W6_I;
            9:  i_mul_B_2 = W1_I;
            10: i_mul_B_2 = W2_I;
            11: i_mul_B_2 = W3_I;
            13: i_mul_B_2 = W3_I;
            14: i_mul_B_2 = W6_I;
            15: i_mul_B_2 = W9_I;
            default: i_mul_B_2 = {15'b0, 1'b0, 16'b0};
        endcase

        // imag multiplier output 
        case (cnt_1) 
            5:  i_mul_Z_1 = (i_mul_A_1 << 1) + (i_mul_A_1 << 8) + (i_mul_A_1 << 10) + (i_mul_A_1 << 16) - (i_mul_A_1 << 12) - (i_mul_A_1 << 14); 
            6:  i_mul_Z_1 = 48'b0;
            7:  i_mul_Z_1 = -(i_mul_A_1 << 2) - (i_mul_A_1 << 8) - (i_mul_A_1 << 10) - (i_mul_A_1 << 12) + (i_mul_A_1 << 14) - (i_mul_A_1 << 16);
            9:  i_mul_Z_1 = -i_mul_A_1 + (i_mul_A_1 << 2) + (i_mul_A_1 << 7) - (i_mul_A_1 << 10) - (i_mul_A_1 << 12) + (i_mul_A_1 << 16);
            10: i_mul_Z_1 = (i_mul_A_1 << 1) + (i_mul_A_1 << 8) + (i_mul_A_1 << 10) + (i_mul_A_1 << 16) - (i_mul_A_1 << 12) - (i_mul_A_1 << 14);
            11: i_mul_Z_1 = -i_mul_A_1 - (i_mul_A_1 << 3) + (i_mul_A_1 << 9) - (i_mul_A_1 << 13) + (i_mul_A_1 << 15);
            13: i_mul_Z_1 = -i_mul_A_1 - (i_mul_A_1 << 3) + (i_mul_A_1 << 9) - (i_mul_A_1 << 13) + (i_mul_A_1 << 15);
            14: i_mul_Z_1 = -(i_mul_A_1 << 2) - (i_mul_A_1 << 8) - (i_mul_A_1 << 10) - (i_mul_A_1 << 12) + (i_mul_A_1 << 14) - (i_mul_A_1 << 16);
            15: i_mul_Z_1 = (i_mul_A_1) - (i_mul_A_1 << 2) - (i_mul_A_1 << 7) + (i_mul_A_1 << 10) + (i_mul_A_1 << 12) - (i_mul_A_1 << 16);
            default: i_mul_Z_1 = i_mul_A_1 << 16;
        endcase

        case (cnt_1) 
            5:  i_mul_Z_2 = -(i_mul_A_2 << 2) - (i_mul_A_2 << 8) - (i_mul_A_2 << 10) - (i_mul_A_2 << 12) + (i_mul_A_2 << 14) - (i_mul_A_2 << 16);
            6:  i_mul_Z_2 = -(i_mul_A_2 << 16);
            7:  i_mul_Z_2 = -(i_mul_A_2 << 2) - (i_mul_A_2 << 8) - (i_mul_A_2 << 10) - (i_mul_A_2 << 12) + (i_mul_A_2 << 14) - (i_mul_A_2 << 16);
            9:  i_mul_Z_2 = (i_mul_A_2) + (i_mul_A_2 << 3) - (i_mul_A_2 << 9) + (i_mul_A_2 << 13) - (i_mul_A_2 << 15);
            10: i_mul_Z_2 = -(i_mul_A_2 << 2) - (i_mul_A_2 << 8) - (i_mul_A_2 << 10) - (i_mul_A_2 << 12) + (i_mul_A_2 << 14) - (i_mul_A_2 << 16);
            11: i_mul_Z_2 = (i_mul_A_2) - (i_mul_A_2 << 2) - (i_mul_A_2 << 7) + (i_mul_A_2 << 10) + (i_mul_A_2 << 12) - (i_mul_A_2 << 16);
            13: i_mul_Z_2 = (i_mul_A_2) - (i_mul_A_2 << 2) - (i_mul_A_2 << 7) + (i_mul_A_2 << 10) + (i_mul_A_2 << 12) - (i_mul_A_2 << 16);
            14: i_mul_Z_2 = -(i_mul_A_2 << 2) - (i_mul_A_2 << 8) - (i_mul_A_2 << 10) - (i_mul_A_2 << 12) + (i_mul_A_2 << 14) - (i_mul_A_2 << 16);
            15: i_mul_Z_2 = -i_mul_A_2 - (i_mul_A_2 << 3) + (i_mul_A_2 << 9) - (i_mul_A_2 << 13) + (i_mul_A_2 << 15);
            default: i_mul_Z_2 = ++++++++++48'b0;
        endcase
    end

    // multiplier
    //assign  r_mul_Z_1 = r_mul_A_1 * r_mul_B_1;
    //assign  r_mul_Z_2 = r_mul_A_2 * r_mul_B_2;

    //assign  i_mul_Z_1 = i_mul_A_1 * i_mul_B_1;
    //assign  i_mul_Z_2 = i_mul_A_2 * i_mul_B_2;

    // adder
    assign  r_add_Z_1 = r_mul_Z_1_b + r_mul_Z_2_b;
    assign  i_add_Z_1 = i_mul_Z_1_b + i_mul_Z_2_b;


    /////////////////////////// Transfer ///////////////////////////

    always @(posedge clk) begin
        if (rst) begin
            valid_1 <= 0;
            r_mul_Z_1_b <= 0;
            r_mul_Z_2_b <= 0;
            i_mul_Z_1_b <= 0;
            i_mul_Z_2_b <= 0;
        end
        else begin
            valid_1 <= valid;
            r_mul_Z_1_b <= r_mul_Z_1;
            r_mul_Z_2_b <= r_mul_Z_2;
            i_mul_Z_1_b <= i_mul_Z_1;
            i_mul_Z_2_b <= i_mul_Z_2;
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            valid_2[0] <= 0;
            r_data_2 <= 0;
            i_data_2 <= 0;
        end
        else begin
            valid_2[0] <= valid_1;
            r_data_2 <= r_add_Z_1[39:8]+r_add_Z_1[39];
            i_data_2 <= i_add_Z_1[39:8]+i_add_Z_1[39];
        end
    end

    // ************************************************************
    // ************************ 2nd stage *************************
    // ************************************************************

    /////////////////////////// Counter ///////////////////////////

    always @(*) begin
        if (cnt_2 == 17) cnt_2_nxt = 0;
        else if (valid_2[0] || cnt_2) cnt_2_nxt = cnt_2 + 1;
        else cnt_2_nxt = 0;
    end

    always @(posedge clk) begin
        if (rst) begin
            cnt_2 <= 0;
        end
        else begin
            cnt_2 <= cnt_2_nxt;
        end
    end


    /////////////////////////// BF2 I ///////////////////////////

    // adder
    assign  r_add_Z_2 = rbuf_2[1] + r_data_2;
    assign  i_add_Z_2 = ibuf_2[1] + i_data_2;

    // subtractor
    assign  r_sub_Z_2 = rbuf_2[1] - r_data_2;
    assign  i_sub_Z_2 = ibuf_2[1] - i_data_2;

    always @(*) begin
        case (cnt_2[1])
            0: begin
                rbuf_2_nxt[0] = r_data_2;
                ibuf_2_nxt[0] = i_data_2;
            end
            1: begin
                rbuf_2_nxt[0] = r_sub_Z_2;
                ibuf_2_nxt[0] = i_sub_Z_2;
            end
        endcase
        rbuf_2_nxt[1] = rbuf_2[0];
        ibuf_2_nxt[1] = ibuf_2[0];
    end

    // buffer
    always @(posedge clk) begin
        if (rst) begin
            for (i=0; i<2; i=i+1) begin
                rbuf_2[i] <= 0;
                ibuf_2[i] <= 0;
            end
        end
        else begin
            for (i=0; i<2; i=i+1) begin
                rbuf_2[i] <= rbuf_2_nxt[i];
                ibuf_2[i] <= ibuf_2_nxt[i];
            end
        end
    end

    /////////////////////////// Transfer ///////////////////////////

    always @(*) begin
        case (cnt_2)
            4,5,8,9,12,13,16,17: begin
                r_data_3_nxt = rbuf_2[1];
                i_data_3_nxt = ibuf_2[1];
            end
            default: begin
                r_data_3_nxt = r_add_Z_2;
                i_data_3_nxt = i_add_Z_2;
            end

        endcase
    end

    always @(posedge clk) begin
        if (rst) begin
            for (i = 1; i<3; i= i+1) valid_2[i] <= 0;
            valid_3[0]  <= 0;
            r_data_3    <= 0;
            i_data_3    <= 0;
        end
        else begin
            for (i = 1; i<3; i= i+1) valid_2[i] <= valid_2[i-1];
            valid_3[0] <= valid_2[2];
            r_data_3    <= r_data_3_nxt;
            i_data_3    <= i_data_3_nxt;
        end
    end

    // ************************************************************
    // ************************ 3rd stage *************************
    // ************************************************************

    /////////////////////////// Counter ///////////////////////////

    always @(*) begin
        if (cnt_3 == 16) cnt_3_nxt = 0;
        else if (valid_3[0] || cnt_3) cnt_3_nxt = cnt_3 + 1;
        else cnt_3_nxt = 0;
    end

    always @(posedge clk) begin
        if (rst) begin
            cnt_3 <= 0;
        end
        else begin
            cnt_3 <= cnt_3_nxt;
        end
    end

    /////////////////////////// BF2 II ///////////////////////////

    // adder & subtractor
    always @(*) begin
        if (cnt_3[1:0] == 2'b11) begin
            r_add_B_3 = i_data_3;
            i_add_B_3 = -r_data_3;

            r_sub_B_3 = i_data_3;
            i_sub_B_3 = -r_data_3;
        end
        else begin
            r_add_B_3 = r_data_3;
            i_add_B_3 = i_data_3;

            r_sub_B_3 = r_data_3;
            i_sub_B_3 = i_data_3;
        end
    end

    assign  r_add_Z_3 = rbuf_3 + r_add_B_3;
    assign  i_add_Z_3 = ibuf_3 + i_add_B_3;

    assign  r_sub_Z_3 = rbuf_3 - r_sub_B_3;
    assign  i_sub_Z_3 = ibuf_3 - i_sub_B_3;

    always @(*) begin
        case (cnt_3[0])
            0: begin
                rbuf_3_nxt = r_data_3;
                ibuf_3_nxt = i_data_3;
            end
            1: begin
                rbuf_3_nxt = r_sub_Z_3;
                ibuf_3_nxt = i_sub_Z_3;
            end
        endcase
    end

    // buffer
    always @(posedge clk) begin
        if (rst) begin
            rbuf_3 <= 0;
            ibuf_3 <= 0;
        end
        else begin
            rbuf_3 <= rbuf_3_nxt;
            ibuf_3 <= ibuf_3_nxt;
        end
    end


    /////////////////////////// Transfer ///////////////////////////

    always @(*) begin
        if (cnt_3[0]) fft_out_nxt = {r_add_Z_3[23:8]+r_add_Z_3[23],i_add_Z_3[23:8]+i_add_Z_3[23]};
        else fft_out_nxt = {rbuf_3[23:8]+rbuf_3[23],ibuf_3[23:8]+ibuf_3[23]};
    end

    always @(posedge clk) begin
        if (rst) begin
            valid_3[1]  <= 0;
            fft_valid   <= 0;
            fft_out     <= 0;
        end
        else begin
            valid_3[1]  <= valid_3[0];
            fft_valid   <= valid_3[1];
            fft_out     <= fft_out_nxt;
        end
    end

endmodule
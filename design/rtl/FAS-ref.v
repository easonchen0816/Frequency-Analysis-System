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

    wire    [255:0] fir_par;

    FIR fir(.clk(clk), .rst(rst), .data(data), .data_valid(data_valid),
            .fir_d(fir_d), .fir_valid(fir_valid));

    SIPO sipo(.clk(clk), .rst(rst), .fir_d(fir_d), .fir_par(fir_par));


    FFT fft(.clk(clk), .rst(rst), .fir_valid(fir_valid), .fir_par(fir_par), .fft_valid(fft_valid), .fft_d1(fft_d1), .fft_d2(fft_d2), .fft_d3(fft_d3), .fft_d4(fft_d4), .fft_d5(fft_d5), .fft_d6(fft_d6), .fft_d7(fft_d7), .fft_d8(fft_d8),
            .fft_d9(fft_d9), .fft_d10(fft_d10), .fft_d11(fft_d11), .fft_d12(fft_d12), .fft_d13(fft_d13), .fft_d14(fft_d14), .fft_d15(fft_d15), .fft_d0(fft_d0));

    ANALYSIS analysis(.clk(clk), .rst(rst), .fft_valid(fft_valid), .fft_d1(fft_d1), .fft_d2(fft_d2), .fft_d3(fft_d3), .fft_d4(fft_d4), .fft_d5(fft_d5), .fft_d6(fft_d6), .fft_d7(fft_d7), .fft_d8(fft_d8),
            .fft_d9(fft_d9), .fft_d10(fft_d10), .fft_d11(fft_d11), .fft_d12(fft_d12), .fft_d13(fft_d13), .fft_d14(fft_d14), .fft_d15(fft_d15), .fft_d0(fft_d0), 
            .done(done), .freq(freq));

endmodule

module ANALYSIS(clk, rst, fft_valid, fft_d1, fft_d2, fft_d3, fft_d4, fft_d5, fft_d6, fft_d7, fft_d8,
            fft_d9, fft_d10, fft_d11, fft_d12, fft_d13, fft_d14, fft_d15, fft_d0, done, freq);
    input                   clk, rst, fft_valid;
    input   signed  [31:0]  fft_d1, fft_d2, fft_d3, fft_d4, fft_d5, fft_d6, fft_d7, fft_d8;
    input   signed  [31:0]  fft_d9, fft_d10, fft_d11, fft_d12, fft_d13, fft_d14, fft_d15, fft_d0;

    output  reg             done;
    output  reg     [3:0]   freq;

    wire            [32:0]  comp_1st[0:7];
    wire            [33:0]  comp_2nd[0:3];
    wire            [34:0]  comp_3rd[0:1];
    wire            [3:0]   freq_nxt;

    reg     signed  [31:0]  fft_d[0:15];
    reg             [31:0]  fft_sqr_real_nxt[0:15];
    reg             [31:0]  fft_sqr_real[0:15];
    reg             [31:0]  fft_sqr_imag_nxt[0:15];
    reg             [31:0]  fft_sqr_imag[0:15];
    reg             [31:0]  fft_add[0:15];
    reg                     valid_1;

    integer                 i;

    assign comp_1st[0] = (fft_add[0 ]>=fft_add[1 ])? {fft_add[0 ],1'b0} : {fft_add[1 ],1'b1};   // compare 0  >= 1 
    assign comp_1st[1] = (fft_add[2 ]>=fft_add[3 ])? {fft_add[2 ],1'b0} : {fft_add[3 ],1'b1};   // compare 2  >= 3 
    assign comp_1st[2] = (fft_add[4 ]>=fft_add[5 ])? {fft_add[4 ],1'b0} : {fft_add[5 ],1'b1};   // compare 4  >= 5 
    assign comp_1st[3] = (fft_add[6 ]>=fft_add[7 ])? {fft_add[6 ],1'b0} : {fft_add[7 ],1'b1};   // compare 6  >= 7 
    assign comp_1st[4] = (fft_add[8 ]>=fft_add[9 ])? {fft_add[8 ],1'b0} : {fft_add[9 ],1'b1};   // compare 8  >= 9 
    assign comp_1st[5] = (fft_add[10]>=fft_add[11])? {fft_add[10],1'b0} : {fft_add[11],1'b1};   // compare 10 >= 11
    assign comp_1st[6] = (fft_add[12]>=fft_add[13])? {fft_add[12],1'b0} : {fft_add[13],1'b1};   // compare 12 >= 13
    assign comp_1st[7] = (fft_add[14]>=fft_add[15])? {fft_add[14],1'b0} : {fft_add[15],1'b1};   // compare 14 >= 15

    assign comp_2nd[0] = (comp_1st[0]>=comp_1st[1])? {comp_1st[0],1'b0} : {comp_1st[1],1'b1};     // compare 0 ,1  >= 2 ,3
    assign comp_2nd[1] = (comp_1st[2]>=comp_1st[3])? {comp_1st[2],1'b0} : {comp_1st[3],1'b1};     // compare 4 ,5  >= 6 ,7
    assign comp_2nd[2] = (comp_1st[4]>=comp_1st[5])? {comp_1st[4],1'b0} : {comp_1st[5],1'b1};     // compare 8 ,9  >= 10,11
    assign comp_2nd[3] = (comp_1st[6]>=comp_1st[7])? {comp_1st[6],1'b0} : {comp_1st[7],1'b1};     // compare 12,13 >= 14,15

    assign comp_3rd[0] = (comp_2nd[0]>=comp_2nd[1])? {comp_2nd[0],1'b0} : {comp_2nd[1],1'b1};   //compare 0,1,2,3 >= 4,5,6,7
    assign comp_3rd[1] = (comp_2nd[2]>=comp_2nd[3])? {comp_2nd[2],1'b0} : {comp_2nd[3],1'b1};   //compare 8,9,10,11 >= 12,13,14,15

    assign freq_nxt = (comp_3rd[0]>=comp_3rd[1])? {1'b0,comp_3rd[0][0],comp_3rd[0][1],comp_3rd[0][2]} 
                                                            : {1'b1,comp_3rd[1][0],comp_3rd[1][1],comp_3rd[1][2]};

    always @(*) begin
        fft_d[0 ] = fft_d0 ;
        fft_d[1 ] = fft_d1 ;
        fft_d[2 ] = fft_d2 ;
        fft_d[3 ] = fft_d3 ;
        fft_d[4 ] = fft_d4 ;
        fft_d[5 ] = fft_d5 ;
        fft_d[6 ] = fft_d6 ;
        fft_d[7 ] = fft_d7 ;
        fft_d[8 ] = fft_d8 ;
        fft_d[9 ] = fft_d9 ;
        fft_d[10] = fft_d10;
        fft_d[11] = fft_d11;
        fft_d[12] = fft_d12;
        fft_d[13] = fft_d13;
        fft_d[14] = fft_d14;
        fft_d[15] = fft_d15;
    end

    always @(*) begin
        for (i=0; i<16; i=i+1) begin
            fft_sqr_real_nxt[i] = {{16{fft_d[i][31]}},fft_d[i][31:16]}*{{16{fft_d[i][31]}},fft_d[i][31:16]};
            fft_sqr_imag_nxt[i] = {{16{fft_d[i][15]}},fft_d[i][15:0 ]}*{{16{fft_d[i][15]}},fft_d[i][15:0 ]};
            fft_add[i] = fft_sqr_real[i] + fft_sqr_imag[i];
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            done <= 0;
            freq <= 0;
            valid_1 <=0;
            for (i=0; i<16; i=i+1) begin
                fft_sqr_real[i] <= 0;
                fft_sqr_imag[i] <= 0;
            end
        end
        else begin
            done <= valid_1;
            freq <= freq_nxt;
            valid_1 <= fft_valid;
            for (i=0; i<16; i=i+1) begin
                fft_sqr_real[i] <= fft_sqr_real_nxt[i][31:0];
                fft_sqr_imag[i] <= fft_sqr_imag_nxt[i][31:0];
            end
        end
    end
endmodule

module FFT(clk, rst, fir_valid, fir_par, fft_valid, fft_d1, fft_d2, fft_d3, fft_d4, fft_d5, fft_d6, fft_d7, fft_d8,
            fft_d9, fft_d10, fft_d11, fft_d12, fft_d13, fft_d14, fft_d15, fft_d0);
    input                   clk, rst, fir_valid;
    input           [255:0] fir_par;

    output  reg                 fft_valid;
    output  reg signed  [31:0]  fft_d1, fft_d2, fft_d3, fft_d4, fft_d5, fft_d6, fft_d7, fft_d8;
    output  reg signed  [31:0]  fft_d9, fft_d10, fft_d11, fft_d12, fft_d13, fft_d14, fft_d15, fft_d0;
    
    wire    signed  [15:0]  y[0:15];
    wire    signed  [47:0]  fft_1_real_nxt[0:15];
    wire    signed  [47:0]  fft_1_imag_nxt[8:15];
    wire    signed  [63:0]  fft_2_real_nxt[0:15];
    wire    signed  [63:0]  fft_2_imag_nxt[4:15];
    wire    signed  [63:0]  fft_3_real_nxt[0:15];
    wire    signed  [63:0]  fft_3_imag_nxt[2:15];
    wire    signed  [63:0]  fft_4_real_nxt[0:15];
    wire    signed  [63:0]  fft_4_imag_nxt[1:15];

    reg             [3:0]   counter_nxt;
    reg             [3:0]   counter;
    reg                     valid_1, valid_2, valid_3, valid_4;
    reg     signed  [31:0]  fft_1_real[0:15];
    reg     signed  [31:0]  fft_1_imag[8:15];
    reg     signed  [31:0]  fft_2_real[0:15];
    reg     signed  [31:0]  fft_2_imag[4:15];
    reg     signed  [31:0]  fft_3_real[0:15];
    reg     signed  [31:0]  fft_3_imag[2:15];

    integer                 i;

    parameter signed [31:0] W0_R = 32'h00010000;      //The real part of the reference table about COS(x)+i*SIN(x) value , 0: 001
    parameter signed [31:0] W1_R = 32'h0000EC83;      //The real part of the reference table about COS(x)+i*SIN(x) value , 1: 9.238739e-001
    parameter signed [31:0] W2_R = 32'h0000B504;      //The real part of the reference table about COS(x)+i*SIN(x) value , 2: 7.070923e-001
    parameter signed [31:0] W3_R = 32'h000061F7;      //The real part of the reference table about COS(x)+i*SIN(x) value , 3: 3.826752e-001
    parameter signed [31:0] W4_R = 32'h00000000;      //The real part of the reference table about COS(x)+i*SIN(x) value , 4: 000
    parameter signed [31:0] W5_R = 32'hFFFF9E09;      //The real part of the reference table about COS(x)+i*SIN(x) value , 5: -3.826752e-001
    parameter signed [31:0] W6_R = 32'hFFFF4AFC;      //The real part of the reference table about COS(x)+i*SIN(x) value , 6: -7.070923e-001
    parameter signed [31:0] W7_R = 32'hFFFF137D;      //The real part of the reference table about COS(x)+i*SIN(x) value , 7: -9.238739e-001

    parameter signed [31:0] W0_I = 32'h00000000;      //The imag part of the reference table about COS(x)+i*SIN(x) value , 0: 000
    parameter signed [31:0] W1_I = 32'hFFFF9E09;      //The imag part of the reference table about COS(x)+i*SIN(x) value , 1: -3.826752e-001
    parameter signed [31:0] W2_I = 32'hFFFF4AFC;      //The imag part of the reference table about COS(x)+i*SIN(x) value , 2: -7.070923e-001
    parameter signed [31:0] W3_I = 32'hFFFF137D;      //The imag part of the reference table about COS(x)+i*SIN(x) value , 3: -9.238739e-001
    parameter signed [31:0] W4_I = 32'hFFFF0000;      //The imag part of the reference table about COS(x)+i*SIN(x) value , 4: -01
    parameter signed [31:0] W5_I = 32'hFFFF137D;      //The imag part of the reference table about COS(x)+i*SIN(x) value , 5: -9.238739e-001
    parameter signed [31:0] W6_I = 32'hFFFF4AFC;      //The imag part of the reference table about COS(x)+i*SIN(x) value , 6: -7.070923e-001
    parameter signed [31:0] W7_I = 32'hFFFF9E09;      //The imag part of the reference table about COS(x)+i*SIN(x) value , 7: -3.826752e-001

    assign y[0 ] = fir_par[15 :0  ];
    assign y[1 ] = fir_par[31 :16 ];
    assign y[2 ] = fir_par[47 :32 ];
    assign y[3 ] = fir_par[63 :48 ];
    assign y[4 ] = fir_par[79 :64 ];
    assign y[5 ] = fir_par[95 :80 ];
    assign y[6 ] = fir_par[111:96 ];
    assign y[7 ] = fir_par[127:112];
    assign y[8 ] = fir_par[143:128];
    assign y[9 ] = fir_par[159:144];
    assign y[10] = fir_par[175:160];
    assign y[11] = fir_par[191:176];
    assign y[12] = fir_par[207:192];
    assign y[13] = fir_par[223:208];
    assign y[14] = fir_par[239:224];
    assign y[15] = fir_par[255:240];

    // stage 1
    assign fft_1_real_nxt[0 ] = y[0 ]+y[8 ];
    assign fft_1_real_nxt[1 ] = y[1 ]+y[9 ];
    assign fft_1_real_nxt[2 ] = y[2 ]+y[10];
    assign fft_1_real_nxt[3 ] = y[3 ]+y[11];
    assign fft_1_real_nxt[4 ] = y[4 ]+y[12];
    assign fft_1_real_nxt[5 ] = y[5 ]+y[13];
    assign fft_1_real_nxt[6 ] = y[6 ]+y[14];
    assign fft_1_real_nxt[7 ] = y[7 ]+y[15];    

    assign fft_1_real_nxt[8 ] = (y[0 ]-y[8 ])*W0_R;
    assign fft_1_real_nxt[9 ] = (y[1 ]-y[9 ])*W1_R;
    assign fft_1_real_nxt[10] = (y[2 ]-y[10])*W2_R;
    assign fft_1_real_nxt[11] = (y[3 ]-y[11])*W3_R;
    assign fft_1_real_nxt[12] = (y[4 ]-y[12])*W4_R;
    assign fft_1_real_nxt[13] = (y[5 ]-y[13])*W5_R;
    assign fft_1_real_nxt[14] = (y[6 ]-y[14])*W6_R;
    assign fft_1_real_nxt[15] = (y[7 ]-y[15])*W7_R;
    assign fft_1_imag_nxt[8 ] = (y[0 ]-y[8 ])*W0_I;
    assign fft_1_imag_nxt[9 ] = (y[1 ]-y[9 ])*W1_I;
    assign fft_1_imag_nxt[10] = (y[2 ]-y[10])*W2_I;
    assign fft_1_imag_nxt[11] = (y[3 ]-y[11])*W3_I;
    assign fft_1_imag_nxt[12] = (y[4 ]-y[12])*W4_I;
    assign fft_1_imag_nxt[13] = (y[5 ]-y[13])*W5_I;
    assign fft_1_imag_nxt[14] = (y[6 ]-y[14])*W6_I;
    assign fft_1_imag_nxt[15] = (y[7 ]-y[15])*W7_I;

    // stage 2
    assign fft_2_real_nxt[0 ] = fft_1_real[0 ]+fft_1_real[4 ];
    assign fft_2_real_nxt[1 ] = fft_1_real[1 ]+fft_1_real[5 ];
    assign fft_2_real_nxt[2 ] = fft_1_real[2 ]+fft_1_real[6 ];
    assign fft_2_real_nxt[3 ] = fft_1_real[3 ]+fft_1_real[7 ];

    assign fft_2_real_nxt[4 ] = (fft_1_real[0 ]-fft_1_real[4 ])*W0_R;
    assign fft_2_real_nxt[5 ] = (fft_1_real[1 ]-fft_1_real[5 ])*W2_R;
    assign fft_2_real_nxt[6 ] = (fft_1_real[2 ]-fft_1_real[6 ])*W4_R;
    assign fft_2_real_nxt[7 ] = (fft_1_real[3 ]-fft_1_real[7 ])*W6_R;
    assign fft_2_imag_nxt[4 ] = (fft_1_real[0 ]-fft_1_real[4 ])*W0_I;
    assign fft_2_imag_nxt[5 ] = (fft_1_real[1 ]-fft_1_real[5 ])*W2_I;
    assign fft_2_imag_nxt[6 ] = (fft_1_real[2 ]-fft_1_real[6 ])*W4_I;
    assign fft_2_imag_nxt[7 ] = (fft_1_real[3 ]-fft_1_real[7 ])*W6_I;

    assign fft_2_real_nxt[8 ] = (fft_1_real[8 ]+fft_1_real[12]);
    assign fft_2_real_nxt[9 ] = (fft_1_real[9 ]+fft_1_real[13]);
    assign fft_2_real_nxt[10] = (fft_1_real[10]+fft_1_real[14]);
    assign fft_2_real_nxt[11] = (fft_1_real[11]+fft_1_real[15]);
    assign fft_2_imag_nxt[8 ] = (fft_1_imag[8 ]+fft_1_imag[12]);
    assign fft_2_imag_nxt[9 ] = (fft_1_imag[9 ]+fft_1_imag[13]);
    assign fft_2_imag_nxt[10] = (fft_1_imag[10]+fft_1_imag[14]);
    assign fft_2_imag_nxt[11] = (fft_1_imag[11]+fft_1_imag[15]);

    assign fft_2_real_nxt[12] = (fft_1_real[8 ]-fft_1_real[12])*W0_R+(fft_1_imag[12]-fft_1_imag[8 ])*W0_I;
    assign fft_2_real_nxt[13] = (fft_1_real[9 ]-fft_1_real[13])*W2_R+(fft_1_imag[13]-fft_1_imag[9 ])*W2_I;
    assign fft_2_real_nxt[14] = (fft_1_real[10]-fft_1_real[14])*W4_R+(fft_1_imag[14]-fft_1_imag[10])*W4_I;
    assign fft_2_real_nxt[15] = (fft_1_real[11]-fft_1_real[15])*W6_R+(fft_1_imag[15]-fft_1_imag[11])*W6_I;
    assign fft_2_imag_nxt[12] = (fft_1_real[8 ]-fft_1_real[12])*W0_I+(fft_1_imag[8 ]-fft_1_imag[12])*W0_R;
    assign fft_2_imag_nxt[13] = (fft_1_real[9 ]-fft_1_real[13])*W2_I+(fft_1_imag[9 ]-fft_1_imag[13])*W2_R;
    assign fft_2_imag_nxt[14] = (fft_1_real[10]-fft_1_real[14])*W4_I+(fft_1_imag[10]-fft_1_imag[14])*W4_R;
    assign fft_2_imag_nxt[15] = (fft_1_real[11]-fft_1_real[15])*W6_I+(fft_1_imag[11]-fft_1_imag[15])*W6_R;

    // stage 3
    assign fft_3_real_nxt[0 ] = fft_2_real[0 ]+fft_2_real[2 ];
    assign fft_3_real_nxt[1 ] = fft_2_real[1 ]+fft_2_real[3 ];

    assign fft_3_real_nxt[2 ] = (fft_2_real[0 ]-fft_2_real[2 ])*W0_R;
    assign fft_3_real_nxt[3 ] = (fft_2_real[1 ]-fft_2_real[3 ])*W4_R;
    assign fft_3_imag_nxt[2 ] = (fft_2_real[0 ]-fft_2_real[2 ])*W0_I;
    assign fft_3_imag_nxt[3 ] = (fft_2_real[1 ]-fft_2_real[3 ])*W4_I;

    assign fft_3_real_nxt[4 ] = fft_2_real[4 ]+fft_2_real[6 ];
    assign fft_3_real_nxt[5 ] = fft_2_real[5 ]+fft_2_real[7 ];
    assign fft_3_imag_nxt[4 ] = fft_2_imag[4 ]+fft_2_imag[6 ];
    assign fft_3_imag_nxt[5 ] = fft_2_imag[5 ]+fft_2_imag[7 ];

    assign fft_3_real_nxt[6 ] = (fft_2_real[4 ]-fft_2_real[6 ])*W0_R+(fft_2_imag[6 ]-fft_2_imag[4 ])*W0_I;
    assign fft_3_real_nxt[7 ] = (fft_2_real[5 ]-fft_2_real[7 ])*W4_R+(fft_2_imag[7 ]-fft_2_imag[5 ])*W4_I;
    assign fft_3_imag_nxt[6 ] = (fft_2_real[4 ]-fft_2_real[6 ])*W0_I+(fft_2_imag[4 ]-fft_2_imag[6 ])*W0_R;
    assign fft_3_imag_nxt[7 ] = (fft_2_real[5 ]-fft_2_real[7 ])*W4_I+(fft_2_imag[5 ]-fft_2_imag[7 ])*W4_R;

    assign fft_3_real_nxt[8 ] = fft_2_real[8 ]+fft_2_real[10];
    assign fft_3_real_nxt[9 ] = fft_2_real[9 ]+fft_2_real[11];
    assign fft_3_imag_nxt[8 ] = fft_2_imag[8 ]+fft_2_imag[10];
    assign fft_3_imag_nxt[9 ] = fft_2_imag[9 ]+fft_2_imag[11];

    assign fft_3_real_nxt[10] = (fft_2_real[8 ]-fft_2_real[10])*W0_R+(fft_2_imag[10]-fft_2_imag[8 ])*W0_I;
    assign fft_3_real_nxt[11] = (fft_2_real[9 ]-fft_2_real[11])*W4_R+(fft_2_imag[11]-fft_2_imag[9 ])*W4_I;
    assign fft_3_imag_nxt[10] = (fft_2_real[8 ]-fft_2_real[10])*W0_I+(fft_2_imag[8 ]-fft_2_imag[10])*W0_R;
    assign fft_3_imag_nxt[11] = (fft_2_real[9 ]-fft_2_real[11])*W4_I+(fft_2_imag[9 ]-fft_2_imag[11])*W4_R;

    assign fft_3_real_nxt[12] = fft_2_real[12]+fft_2_real[14];
    assign fft_3_real_nxt[13] = fft_2_real[13]+fft_2_real[15];
    assign fft_3_imag_nxt[12] = fft_2_imag[12]+fft_2_imag[14];
    assign fft_3_imag_nxt[13] = fft_2_imag[13]+fft_2_imag[15];

    assign fft_3_real_nxt[14] = (fft_2_real[12]-fft_2_real[14])*W0_R+(fft_2_imag[14]-fft_2_imag[12])*W0_I;
    assign fft_3_real_nxt[15] = (fft_2_real[13]-fft_2_real[15])*W4_R+(fft_2_imag[15]-fft_2_imag[13])*W4_I;
    assign fft_3_imag_nxt[14] = (fft_2_real[12]-fft_2_real[14])*W0_I+(fft_2_imag[12]-fft_2_imag[14])*W0_R;
    assign fft_3_imag_nxt[15] = (fft_2_real[13]-fft_2_real[15])*W4_I+(fft_2_imag[13]-fft_2_imag[15])*W4_R;

    // stage 4
    assign fft_4_real_nxt[0 ] = fft_3_real[0]+fft_3_real[1];

    assign fft_4_real_nxt[1 ] = (fft_3_real[0 ]-fft_3_real[1 ])*W0_R;
    assign fft_4_imag_nxt[1 ] = (fft_3_real[0 ]-fft_3_real[1 ])*W0_I;

    assign fft_4_real_nxt[2 ] = fft_3_real[2 ]+fft_3_real[3 ];
    assign fft_4_imag_nxt[2 ] = fft_3_imag[2 ]+fft_3_imag[3 ];

    assign fft_4_real_nxt[3 ] = (fft_3_real[2 ]-fft_3_real[3 ])*W0_R+(fft_3_imag[3 ]-fft_3_imag[2 ])*W0_I;
    assign fft_4_imag_nxt[3 ] = (fft_3_real[2 ]-fft_3_real[3 ])*W0_I+(fft_3_imag[2 ]-fft_3_imag[3 ])*W0_R;

    assign fft_4_real_nxt[4 ] = fft_3_real[4 ]+fft_3_real[5 ];
    assign fft_4_imag_nxt[4 ] = fft_3_imag[4 ]+fft_3_imag[5 ];

    assign fft_4_real_nxt[5 ] = (fft_3_real[4 ]-fft_3_real[5 ])*W0_R+(fft_3_imag[5 ]-fft_3_imag[4 ])*W0_I;
    assign fft_4_imag_nxt[5 ] = (fft_3_real[4 ]-fft_3_real[5 ])*W0_I+(fft_3_imag[4 ]-fft_3_imag[5 ])*W0_R;

    assign fft_4_real_nxt[6 ] = fft_3_real[6 ]+fft_3_real[7 ];
    assign fft_4_imag_nxt[6 ] = fft_3_imag[6 ]+fft_3_imag[7 ];

    assign fft_4_real_nxt[7 ] = (fft_3_real[6 ]-fft_3_real[7 ])*W0_R+(fft_3_imag[7 ]-fft_3_imag[6 ])*W0_I;
    assign fft_4_imag_nxt[7 ] = (fft_3_real[6 ]-fft_3_real[7 ])*W0_I+(fft_3_imag[6 ]-fft_3_imag[7 ])*W0_R;

    assign fft_4_real_nxt[8 ] = fft_3_real[8 ]+fft_3_real[9 ];
    assign fft_4_imag_nxt[8 ] = fft_3_imag[8 ]+fft_3_imag[9 ];

    assign fft_4_real_nxt[9 ] = (fft_3_real[8 ]-fft_3_real[9 ])*W0_R+(fft_3_imag[9 ]-fft_3_imag[8 ])*W0_I;
    assign fft_4_imag_nxt[9 ] = (fft_3_real[8 ]-fft_3_real[9 ])*W0_I+(fft_3_imag[8 ]-fft_3_imag[9 ])*W0_R;

    assign fft_4_real_nxt[10] = fft_3_real[10]+fft_3_real[11];
    assign fft_4_imag_nxt[10] = fft_3_imag[10]+fft_3_imag[11];

    assign fft_4_real_nxt[11] = (fft_3_real[10]-fft_3_real[11])*W0_R+(fft_3_imag[11]-fft_3_imag[10])*W0_I;
    assign fft_4_imag_nxt[11] = (fft_3_real[10]-fft_3_real[11])*W0_I+(fft_3_imag[10]-fft_3_imag[11])*W0_R;

    assign fft_4_real_nxt[12] = fft_3_real[12]+fft_3_real[13];
    assign fft_4_imag_nxt[12] = fft_3_imag[12]+fft_3_imag[13];

    assign fft_4_real_nxt[13] = (fft_3_real[12]-fft_3_real[13])*W0_R+(fft_3_imag[13]-fft_3_imag[12])*W0_I;
    assign fft_4_imag_nxt[13] = (fft_3_real[12]-fft_3_real[13])*W0_I+(fft_3_imag[12]-fft_3_imag[13])*W0_R;

    assign fft_4_real_nxt[14] = fft_3_real[14]+fft_3_real[15];
    assign fft_4_imag_nxt[14] = fft_3_imag[14]+fft_3_imag[15];

    assign fft_4_real_nxt[15] = (fft_3_real[14]-fft_3_real[15])*W0_R+(fft_3_imag[15]-fft_3_imag[14])*W0_I;
    assign fft_4_imag_nxt[15] = (fft_3_real[14]-fft_3_real[15])*W0_I+(fft_3_imag[14]-fft_3_imag[15])*W0_R;

    always @(*) begin
        if (!fir_valid) counter_nxt = 0;
        else            counter_nxt = counter+1;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i=0; i<16; i=i+1) begin
                fft_1_real[i] <= 0;
                fft_2_real[i] <= 0;
                fft_3_real[i] <= 0;
            end
            for (i=8; i<16; i=i+1) begin
                fft_1_imag[i] <= 0;
            end
            for (i=4; i<16; i=i+1) begin
                fft_2_imag[i] <= 0;
            end
            for (i=2; i<16; i=i+1) begin
                fft_3_imag[i] <= 0;
            end
            fft_d0  <= 0;
            fft_d8  <= 0;
            fft_d4  <= 0;
            fft_d12 <= 0;
            fft_d2  <= 0;
            fft_d10 <= 0;
            fft_d6  <= 0;
            fft_d14 <= 0;
            fft_d1  <= 0;
            fft_d9  <= 0;
            fft_d5  <= 0;
            fft_d13 <= 0;
            fft_d3  <= 0;
            fft_d11 <= 0;
            fft_d7  <= 0;
            fft_d15 <= 0;
            counter <= 0;
        end
        else begin
            // stage 1
            for (i=0; i<8; i=i+1) begin
                fft_1_real[i] <= {{8{fft_1_real_nxt[i][15]}},fft_1_real_nxt[i][15:0],8'h0};
                fft_1_real[i+8] <= fft_1_real_nxt[i+8][39:8 ]+fft_1_real_nxt[i+8][39];
                fft_1_imag[i+8] <= fft_1_imag_nxt[i+8][39:8 ]+fft_1_imag_nxt[i+8][39];
            end
            // stage 2
            for (i=0; i<4; i=i+1) begin
                fft_2_real[i] <= fft_2_real_nxt[i][31:0];
                fft_2_real[i+4] <= fft_2_real_nxt[i+4][47:16]+fft_2_real_nxt[i+4][47];
                fft_2_imag[i+4] <= fft_2_imag_nxt[i+4][47:16]+fft_2_imag_nxt[i+4][47];
                fft_2_real[i+8] <= fft_2_real_nxt[i+8][31:0];
                fft_2_imag[i+8] <= fft_2_imag_nxt[i+8][31:0];
                fft_2_real[i+12] <= fft_2_real_nxt[i+12][47:16]+fft_2_real_nxt[i+12][47];
                fft_2_imag[i+12] <= fft_2_imag_nxt[i+12][47:16]+fft_2_imag_nxt[i+12][47];
            end
            // stage 3
            fft_3_real[0] <= fft_3_real_nxt[0][31:0];
            fft_3_real[1] <= fft_3_real_nxt[1][31:0];
            for (i=2; i<4; i=i+1) begin
                fft_3_real[i] <= fft_3_real_nxt[i][47:16]+fft_3_real_nxt[i][47];
                fft_3_imag[i] <= fft_3_imag_nxt[i][47:16]+fft_3_imag_nxt[i][47];
            end
            for (i=1; i<4; i=i+1) begin
                fft_3_real[4*i] <= fft_3_real_nxt[4*i][31:0];
                fft_3_imag[4*i] <= fft_3_imag_nxt[4*i][31:0];
                fft_3_real[4*i+1] <= fft_3_real_nxt[4*i+1][31:0];
                fft_3_imag[4*i+1] <= fft_3_imag_nxt[4*i+1][31:0];
                fft_3_real[4*i+2] <= fft_3_real_nxt[4*i+2][47:16]+fft_3_real_nxt[4*i+2][47];
                fft_3_imag[4*i+2] <= fft_3_imag_nxt[4*i+2][47:16]+fft_3_imag_nxt[4*i+2][47];
                fft_3_real[4*i+3] <= fft_3_real_nxt[4*i+3][47:16]+fft_3_real_nxt[4*i+3][47];
                fft_3_imag[4*i+3] <= fft_3_imag_nxt[4*i+3][47:16]+fft_3_imag_nxt[4*i+3][47];
            end
            // stage 4
            fft_d0  <= {fft_4_real_nxt[0][23:8],16'h0};
            fft_d8  <= {fft_4_real_nxt[1 ][39:24]+fft_4_real_nxt[1 ][39],fft_4_imag_nxt[1 ][39:24]+fft_4_imag_nxt[1 ][39]};
            fft_d4  <= {fft_4_real_nxt[2 ][23:8 ],fft_4_imag_nxt[2 ][23:8 ]};
            fft_d12 <= {fft_4_real_nxt[3 ][39:24]+fft_4_real_nxt[3 ][39],fft_4_imag_nxt[3 ][39:24]+fft_4_imag_nxt[3 ][39]};
            fft_d2  <= {fft_4_real_nxt[4 ][23:8 ],fft_4_imag_nxt[4 ][23:8 ]};
            fft_d10 <= {fft_4_real_nxt[5 ][39:24]+fft_4_real_nxt[5 ][39],fft_4_imag_nxt[5 ][39:24]+fft_4_imag_nxt[5 ][39]};
            fft_d6  <= {fft_4_real_nxt[6 ][23:8 ],fft_4_imag_nxt[6 ][23:8 ]};
            fft_d14 <= {fft_4_real_nxt[7 ][39:24]+fft_4_real_nxt[7 ][39],fft_4_imag_nxt[7 ][39:24]+fft_4_imag_nxt[7 ][39]};
            fft_d1  <= {fft_4_real_nxt[8 ][23:8 ],fft_4_imag_nxt[8 ][23:8 ]};
            fft_d9  <= {fft_4_real_nxt[9 ][39:24]+fft_4_real_nxt[9 ][39],fft_4_imag_nxt[9 ][39:24]+fft_4_imag_nxt[9 ][39]};
            fft_d5  <= {fft_4_real_nxt[10][23:8 ],fft_4_imag_nxt[10][23:8 ]};
            fft_d13 <= {fft_4_real_nxt[11][39:24]+fft_4_real_nxt[11][39],fft_4_imag_nxt[11][39:24]+fft_4_imag_nxt[11][39]};
            fft_d3  <= {fft_4_real_nxt[12][23:8 ],fft_4_imag_nxt[12][23:8 ]};
            fft_d11 <= {fft_4_real_nxt[13][39:24]+fft_4_real_nxt[13][39],fft_4_imag_nxt[13][39:24]+fft_4_imag_nxt[13][39]};
            fft_d7  <= {fft_4_real_nxt[14][23:8 ],fft_4_imag_nxt[14][23:8 ]};
            fft_d15 <= {fft_4_real_nxt[15][39:24]+fft_4_real_nxt[15][39],fft_4_imag_nxt[15][39:24]+fft_4_imag_nxt[15][39]};
        
            counter <= counter_nxt;
            if (counter == 15)  valid_1 <= 1;
            else                valid_1 <= 0;
            if (valid_1)        valid_2 <= 1;
            else                valid_2 <= 0;
            if (valid_2)        valid_3 <= 1;
            else                valid_3 <= 0;
            if (valid_3)        valid_4 <= 1;
            else                valid_4 <= 0;
            if (valid_4)        fft_valid <= 1;
            else                fft_valid <= 0;
        end
    end

endmodule



module SIPO(clk, rst, fir_d, fir_par);
    input                   clk, rst;
    input   signed  [15:0]  fir_d;

    output  reg     [255:0] fir_par;

    wire            [255:0] fir_par_nxt;

    assign fir_par_nxt = {fir_d, fir_par[255:16]};

    always @(posedge clk or posedge rst) begin
        if (rst) fir_par <= 0;
        else fir_par <= fir_par_nxt;
    end
endmodule

module FIR(clk, rst, data, data_valid, fir_d, fir_valid);
    input                   clk, rst, data_valid;
    input   signed  [15:0]  data;

    output  reg             fir_valid;
    output  signed  [15:0]  fir_d;

    wire    [35:0]  fir_mul_nxt[0:31];
    wire    [35:0]  fir_add_nxt[0:31];
    reg     [35:0]  fir_mul[0:31];
    reg     [35:0]  fir_add[0:31];
    reg     [4:0]   counter, counter_nxt;
    reg             valid_1;

    integer                 i;

    parameter signed [19:0] FIR_C00 = 20'hFFF9E ;     //The FIR_coefficient value 0: -1.495361e-003
    parameter signed [19:0] FIR_C01 = 20'hFFF86 ;     //The FIR_coefficient value 1: -1.861572e-003
    parameter signed [19:0] FIR_C02 = 20'hFFFA7 ;     //The FIR_coefficient value 2: -1.358032e-003
    parameter signed [19:0] FIR_C03 = 20'h0003B ;    //The FIR_coefficient value 3: 9.002686e-004
    parameter signed [19:0] FIR_C04 = 20'h0014B ;    //The FIR_coefficient value 4: 5.050659e-003
    parameter signed [19:0] FIR_C05 = 20'h0024A ;    //The FIR_coefficient value 5: 8.941650e-003
    parameter signed [19:0] FIR_C06 = 20'h00222 ;    //The FIR_coefficient value 6: 8.331299e-003
    parameter signed [19:0] FIR_C07 = 20'hFFFE4 ;     //The FIR_coefficient value 7: -4.272461e-004
    parameter signed [19:0] FIR_C08 = 20'hFFBC5 ;     //The FIR_coefficient value 8: -1.652527e-002
    parameter signed [19:0] FIR_C09 = 20'hFF7CA ;     //The FIR_coefficient value 9: -3.207397e-002
    parameter signed [19:0] FIR_C10 = 20'hFF74E ;     //The FIR_coefficient value 10: -3.396606e-002
    parameter signed [19:0] FIR_C11 = 20'hFFD74 ;     //The FIR_coefficient value 11: -9.948730e-003
    parameter signed [19:0] FIR_C12 = 20'h00B1A ;    //The FIR_coefficient value 12: 4.336548e-002
    parameter signed [19:0] FIR_C13 = 20'h01DAC ;    //The FIR_coefficient value 13: 1.159058e-001
    parameter signed [19:0] FIR_C14 = 20'h02F9E ;    //The FIR_coefficient value 14: 1.860046e-001
    parameter signed [19:0] FIR_C15 = 20'h03AA9 ;    //The FIR_coefficient value 15: 2.291412e-001
    parameter signed [19:0] FIR_C16 = 20'h03AA9 ;    //The FIR_coefficient value 16: 2.291412e-001
    parameter signed [19:0] FIR_C17 = 20'h02F9E ;    //The FIR_coefficient value 17: 1.860046e-001
    parameter signed [19:0] FIR_C18 = 20'h01DAC ;    //The FIR_coefficient value 18: 1.159058e-001
    parameter signed [19:0] FIR_C19 = 20'h00B1A ;    //The FIR_coefficient value 19: 4.336548e-002
    parameter signed [19:0] FIR_C20 = 20'hFFD74 ;     //The FIR_coefficient value 20: -9.948730e-003
    parameter signed [19:0] FIR_C21 = 20'hFF74E ;     //The FIR_coefficient value 21: -3.396606e-002
    parameter signed [19:0] FIR_C22 = 20'hFF7CA ;     //The FIR_coefficient value 22: -3.207397e-002
    parameter signed [19:0] FIR_C23 = 20'hFFBC5 ;     //The FIR_coefficient value 23: -1.652527e-002
    parameter signed [19:0] FIR_C24 = 20'hFFFE4 ;     //The FIR_coefficient value 24: -4.272461e-004
    parameter signed [19:0] FIR_C25 = 20'h00222 ;    //The FIR_coefficient value 25: 8.331299e-003
    parameter signed [19:0] FIR_C26 = 20'h0024A ;    //The FIR_coefficient value 26: 8.941650e-003
    parameter signed [19:0] FIR_C27 = 20'h0014B ;    //The FIR_coefficient value 27: 5.050659e-003
    parameter signed [19:0] FIR_C28 = 20'h0003B ;    //The FIR_coefficient value 28: 9.002686e-004
    parameter signed [19:0] FIR_C29 = 20'hFFFA7 ;     //The FIR_coefficient value 29: -1.358032e-003
    parameter signed [19:0] FIR_C30 = 20'hFFF86 ;     //The FIR_coefficient value 30: -1.861572e-003
    parameter signed [19:0] FIR_C31 = 20'hFFF9E ;     //The FIR_coefficient value 31: -1.495361e-003

    assign fir_mul_nxt[0 ]   = data*FIR_C00;
    assign fir_mul_nxt[1 ]   = data*FIR_C01;
    assign fir_mul_nxt[2 ]   = data*FIR_C02;
    assign fir_mul_nxt[3 ]   = data*FIR_C03;
    assign fir_mul_nxt[4 ]   = data*FIR_C04;
    assign fir_mul_nxt[5 ]   = data*FIR_C05;
    assign fir_mul_nxt[6 ]   = data*FIR_C06;
    assign fir_mul_nxt[7 ]   = data*FIR_C07;
    assign fir_mul_nxt[8 ]   = data*FIR_C08;
    assign fir_mul_nxt[9 ]   = data*FIR_C09;
    assign fir_mul_nxt[10]   = data*FIR_C10;
    assign fir_mul_nxt[11]   = data*FIR_C11;
    assign fir_mul_nxt[12]   = data*FIR_C12;
    assign fir_mul_nxt[13]   = data*FIR_C13;
    assign fir_mul_nxt[14]   = data*FIR_C14;
    assign fir_mul_nxt[15]   = data*FIR_C15;
    assign fir_mul_nxt[16]   = data*FIR_C16;
    assign fir_mul_nxt[17]   = data*FIR_C17;
    assign fir_mul_nxt[18]   = data*FIR_C18;
    assign fir_mul_nxt[19]   = data*FIR_C19;
    assign fir_mul_nxt[20]   = data*FIR_C20;
    assign fir_mul_nxt[21]   = data*FIR_C21;
    assign fir_mul_nxt[22]   = data*FIR_C22;
    assign fir_mul_nxt[23]   = data*FIR_C23;
    assign fir_mul_nxt[24]   = data*FIR_C24;
    assign fir_mul_nxt[25]   = data*FIR_C25;
    assign fir_mul_nxt[26]   = data*FIR_C26;
    assign fir_mul_nxt[27]   = data*FIR_C27;
    assign fir_mul_nxt[28]   = data*FIR_C28;
    assign fir_mul_nxt[29]   = data*FIR_C29;
    assign fir_mul_nxt[30]   = data*FIR_C30;
    assign fir_mul_nxt[31]   = data*FIR_C31;

    assign fir_add_nxt[0 ]   = fir_mul[0 ] + fir_add[1 ];
    assign fir_add_nxt[1 ]   = fir_mul[1 ] + fir_add[2 ];
    assign fir_add_nxt[2 ]   = fir_mul[2 ] + fir_add[3 ];
    assign fir_add_nxt[3 ]   = fir_mul[3 ] + fir_add[4 ];
    assign fir_add_nxt[4 ]   = fir_mul[4 ] + fir_add[5 ];
    assign fir_add_nxt[5 ]   = fir_mul[5 ] + fir_add[6 ];
    assign fir_add_nxt[6 ]   = fir_mul[6 ] + fir_add[7 ];
    assign fir_add_nxt[7 ]   = fir_mul[7 ] + fir_add[8 ];
    assign fir_add_nxt[8 ]   = fir_mul[8 ] + fir_add[9 ];
    assign fir_add_nxt[9 ]   = fir_mul[9 ] + fir_add[10];
    assign fir_add_nxt[10]   = fir_mul[10] + fir_add[11];
    assign fir_add_nxt[11]   = fir_mul[11] + fir_add[12];
    assign fir_add_nxt[12]   = fir_mul[12] + fir_add[13];
    assign fir_add_nxt[13]   = fir_mul[13] + fir_add[14];
    assign fir_add_nxt[14]   = fir_mul[14] + fir_add[15];
    assign fir_add_nxt[15]   = fir_mul[15] + fir_add[16];
    assign fir_add_nxt[16]   = fir_mul[16] + fir_add[17];
    assign fir_add_nxt[17]   = fir_mul[17] + fir_add[18];
    assign fir_add_nxt[18]   = fir_mul[18] + fir_add[19];
    assign fir_add_nxt[19]   = fir_mul[19] + fir_add[20];
    assign fir_add_nxt[20]   = fir_mul[20] + fir_add[21];
    assign fir_add_nxt[21]   = fir_mul[21] + fir_add[22];
    assign fir_add_nxt[22]   = fir_mul[22] + fir_add[23];
    assign fir_add_nxt[23]   = fir_mul[23] + fir_add[24];
    assign fir_add_nxt[24]   = fir_mul[24] + fir_add[25];
    assign fir_add_nxt[25]   = fir_mul[25] + fir_add[26];
    assign fir_add_nxt[26]   = fir_mul[26] + fir_add[27];
    assign fir_add_nxt[27]   = fir_mul[27] + fir_add[28];
    assign fir_add_nxt[28]   = fir_mul[28] + fir_add[29];
    assign fir_add_nxt[29]   = fir_mul[29] + fir_add[30];
    assign fir_add_nxt[30]   = fir_mul[30] + fir_add[31];
    assign fir_add_nxt[31]   = fir_mul[31];

    assign fir_d = fir_add_nxt[0][31:16]+fir_add_nxt[0][31];

    always @(*) begin
        if (!valid_1) counter_nxt = 0;
        else begin
            if (counter == 31) counter_nxt = counter;
            else counter_nxt = counter + 1;
            
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i=0; i<32; i=i+1) begin
                fir_mul[i] <= 0;
                fir_add[i] <= 0;
            end
            counter <= 0;
            valid_1 <= 0;
            fir_valid <= 0;
        end
        else begin
            for (i=0; i<32; i=i+1) begin
                fir_mul[i] <= fir_mul_nxt[i];
                fir_add[i] <= fir_add_nxt[i];
            end
            counter <= counter_nxt;
            valid_1 <= data_valid;
            if (counter == 31) fir_valid <= 1;
            else fir_valid <= 0;
        end
    end

endmodule
module testbench_all;

    parameter WIDTH = 8;
    parameter N = 2;

    reg [WIDTH-1:0] initial_data_send;
    reg clk, rst, start_send;
    wire tx1, rx1, busy_trans, valid, busy_rec, busy;
    wire [2*WIDTH-1:0] result_data_recv;

    reg [WIDTH-1:0] vec1[N - 1:0];
    reg [WIDTH-1:0] vec2[N - 1:0];
    reg [2*WIDTH-1:0] res[N-1:0];

    uart_transmitter 
    #(
        .IF(2),
        .UF(1)
    )
    transmitter
    (
        .data   (initial_data_send          ),
        .start  (start_send          ),
        .clock  (clk                ),
        .reset  (rst                ),
        .tx     (tx1    ),
        .busy   (busy_trans         )
    );

    main
    #(
        .N      (N      ), 
        .WIDTH  (WIDTH  )
    )
    main_module
    (
        .rx(tx1    ),
        .clk(clk                ),
        .rst(rst                ),
        .tx(rx1     ),
        .busy(busy              )
    );

    uart_receiver 
    #(
        .IF(2),
        .UF(1),
        .W(WIDTH*2),
        .Precision(0)
    )
    receiver
    (
        .rx     (rx1     ), 
        .clock  (clk                ), 
        .reset  (rst                ), 
        .data   (result_data_recv          ), 
        .valid  (valid              ), 
        .busy   (busy_rec           )

    );

    always #1
        clk = !clk;


    initial begin
        rst = 1;
        clk = 1;
        vec1[0] = 8'b00001101;
        vec1[1] = 8'b00000101;
        vec2[0] = 8'b00000001;
        vec2[1] = 8'b00000011;
        initial_data_send = vec1[0];
        start_send = 1;
        #3
        rst = 0;
        #1
        start_send = 0;
        #120

        #1
        initial_data_send = vec1[0];
        #1
        start_send = 1;
        #2
        start_send = 0;
        #120

        #1
        initial_data_send = vec1[1];
        #1
        start_send = 1;
        #2
        start_send = 0;
        #120

        #1
        initial_data_send = vec2[0];
        #1
        start_send = 1;
        #2
        start_send = 0;
        #120
        #1
        initial_data_send = vec2[1];
        #1
        start_send = 1;
        #2
        start_send = 0;
        #120

        

        #800
        $finish;
    end


    integer i = 0;
    always @*
  	if (valid) begin
  	    res[i] = result_data_recv;
            if (i == 0) begin
                $display("vector1: %d %d\n", vec1[1], vec1[0]);
                $display("vector2: %d %d\n", vec2[1], vec2[0]);
            end
            else if (i == 1) begin
                $display("result:  %d %d\n", res[1], res[0]);
            end
            i = i + 1;
        end
        
    initial begin 
        $dumpfile("dump.vcd");
        $dumpvars(1);
    end

endmodule



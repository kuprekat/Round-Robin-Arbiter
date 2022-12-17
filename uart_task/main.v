module main
#(parameter N = 8, parameter WIDTH = 8)
(
    input clk,
    input rst,
    input rx,
    output tx,
    output busy
);

    reg [2 * N - 1:0] counter; //count numbers that has been entered (two vectors with N elements)
    reg waiting, start, input_done;
    wire [WIDTH - 1:0] input_value; //one number of input vector
    reg [2 * WIDTH - 1:0] output_value; //one number of result vector
    wire [N * WIDTH - 1:0] vec1;
    wire [N * WIDTH - 1:0] vec2;
    reg [WIDTH - 1:0] read_vector[N * 2 - 1:0]; //reg to store the input

    wire [2 * N * WIDTH - 1:0] result_vec; //result of multiplication
    reg [2 * N * WIDTH - 1:0] result_tmp; //reg to store the result
    wire [2 * WIDTH - 1:0] result_to_send[N-1:0]; //wire to send the result
    
    wire valid_input, busy_res, busy_trans;


    uart_receiver 
    #(
        .IF(2),
        .UF(1),
        .Precision(0)
    )
    receiver
    (
        .rx     (rx         ), 
        .clock  (clk        ), 
        .reset  (rst        ), 
        .data   (input_value), 
        .valid  (valid_input   ), 
        .busy   (busy_res   )

    );

    uart_transmitter 
    #(
        .IF(2),
        .UF(1),
        .W(WIDTH*2)
    )
    transmitter
    (
        .data   (output_value  ),
        .start  (start  ),
        .clock  (clk        ),
        .reset  (rst        ),
        .tx     (tx         ),
        .busy   (busy_trans )
    );


    mul_vectors
    #(
        .N      (N      ), 
        .WIDTH  (WIDTH  )
    )
    mul_vec
    (
        .vec1(vec1),
        .vec2(vec2),
        .result(result_vec)
    );


    genvar i;
    generate 
        for (i = 0; i < 2 * N; i = i + 1)
            if (i < N)
            	assign vec1[(i + 1) * WIDTH - 1:i * WIDTH] = read_vector[i];
            else
            	assign vec2[((i - N) + 1) * WIDTH - 1:(i - N) * WIDTH] = read_vector[i];
    endgenerate
    
    generate 
        for (i = 0; i < N; i = i + 1)
            assign result_to_send[i] = result_tmp[(i + 1) * 2 * WIDTH - 1:i * 2 * WIDTH];
     endgenerate
    
    
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter <= 0;
            result_tmp <= 0;
            start <= 0;
            waiting <= 1;
            input_done <= 0;
        end
        //result
        else if (!input_done && counter == N * 2) begin
            input_done <= 1;
            result_tmp <= result_vec;
            counter <= 0;
        end
        //reading vectors
        else if (!input_done && valid_input && waiting) begin
            waiting <= 0;
            if (counter < N * 2) begin
                read_vector[counter] <= input_value;
                counter <= counter + 1;
            end
        end
        //invalid input
        else if (!input_done && !waiting && !valid_input) begin
        	waiting <= 1;
        end
        //transmit
        else if (input_done) begin
        	if (start) begin
        		start <= 0;
        	end
        	else if (counter < 2 * N && !busy_trans) begin
        		output_value <= result_to_send[counter];
        		counter <= counter + 1;
        		start <= 1;
        	end
        	else if (counter == 2 * N) begin
        		counter <= 0;
        		input_done <= 0;
        		waiting <= 1;
        		start <= 0;
        	end
        end
        
    end

endmodule

module TrafficLightController (
    input clk,
    input rst,
    input en,
    input [5:0] red_time_i,
    input [5:0] yellow_time_i,
    input [5:0] green_time_i,
    output logic red,
    output logic yellow,
    output logic green,
    output logic [5:0] left_time
);
    typedef enum logic [1:0] {
        IDLE, RED, YELLOW, GREEN
     } state_t;
    state_t cs, ns;

    logic [5:0] red_time, yellow_time, green_time;

    always_ff @(posedge clk or posedge rst) begin // state register
        if (rst) cs <= IDLE;
        else begin
            if (en) cs <= ns;
            else cs <= cs;
        end
    end

    always_comb begin // state transition
        case(cs)
            IDLE: begin
                if (en) ns = RED;
                else ns = IDLE;
            end
            RED: begin
                if (left_time == 'd1) ns = GREEN;
                else ns = RED;
            end
            YELLOW: begin
                if (left_time == 'd1) ns = RED;
                else ns = YELLOW;
            end
            GREEN: begin
                if (left_time == 'd1) ns = YELLOW;
                else ns = GREEN;
            end
            default: ns = IDLE;
        endcase
    end

    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            red_time <= 'd0;
            yellow_time <= 'd0;
            green_time <= 'd0;
        end
        else begin
            if (cs == IDLE && en) begin
                red_time <= red_time_i;
                yellow_time <= yellow_time_i;
                green_time <= green_time_i;
            end
        end
    end

    always_ff @( posedge clk or posedge rst ) begin
        if (rst) left_time <= 'd0;
        else begin
            if (en) begin
                if (cs == IDLE) left_time <= red_time_i;
                else if (cs == ns) left_time <= left_time - 'd1;
                else begin
                    case(ns)
                        RED: left_time <= red_time;
                        YELLOW: left_time <= yellow_time;
                        GREEN: left_time <= green_time;
                        default: left_time <= 'd0;
                    endcase
                end
            end
        end
    end

    assign red = (cs == RED);
    assign yellow = (cs == YELLOW);
    assign green = (cs == GREEN);

endmodule

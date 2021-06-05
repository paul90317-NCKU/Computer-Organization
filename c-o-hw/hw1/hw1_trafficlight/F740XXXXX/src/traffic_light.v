module traffic_light (
    input  clk,
    input  rst,
    input  pass,
    output R,
    output G,
    output Y
);

//write your code here
    //010 G
    //001 Y
    //100 R
    reg [10:0] counter;
    reg [2:0] state,next;
    reg [10:0] cycle[0:6];
    reg [2:0] light[0:6];
    initial begin
        counter<=11'd0;
        next<=3'd0;
        state<=3'd0;
        cycle[0]<=11'd1024;
        cycle[1]<=11'd128;
        cycle[2]<=11'd128;
        cycle[3]<=11'd128;
        cycle[4]<=11'd128;
        cycle[5]<=11'd512;
        cycle[6]<=11'd1024;
        light[0]<=3'b010;
        light[1]<=3'b000;
        light[2]<=3'b010;
        light[3]<=3'b000;
        light[4]<=3'b010;
        light[5]<=3'b001;
        light[6]<=3'b100;
    end
    always@(posedge clk or posedge rst)begin
        if(rst)begin
            counter<=11'd0;
            next<=3'd0;
        end
        else begin
            if (pass && state!=3'd0)begin
                counter<=11'd0;
                next<=3'd0;
            end
            else begin
                counter=counter+11'd1;
                if(counter==cycle[state])begin
                    counter<=11'd0;
                    if(next < 3'd6)begin
                        next<=state+3'd1;
                    end
                    else begin
                        next<=3'd0;
                    end
                end
            end
        end
    end
    always@(*)begin
        state<=next;
    end
    assign {R,G,Y}=light[state];
endmodule

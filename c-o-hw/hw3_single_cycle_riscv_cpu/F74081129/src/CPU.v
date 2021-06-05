// Please include verilog file if you write module in other file
module CPU(
    input             clk,
    input             rst,
    input      [31:0] data_out,
    input      [31:0] instr_out,
    output reg        instr_read,
    output reg        data_read,
    output reg [31:0] instr_addr,
    output reg [31:0] data_addr,
    output reg [3:0]  data_write,
    output reg [31:0] data_in
);

/* Add your design */
reg [31:0] register[0:31];
reg [31:0] pc;
wire [31:0] pc4;
reg [31:0] instruction;
reg [1:0] state;
reg fetch_instr_this;
reg fetch_instr_next;
initial begin
    register[0]<=0;
    instr_read<=1;
    data_read<=1;
    state<=0;
    fetch_instr_this<=0;
    fetch_instr_next<=0;
end
always@(posedge rst)begin
    state<=0;
end
assign pc4=pc+4;
wire [31:0] rs1;
wire [31:0] rs2;
wire [11:0] imm;
wire [19:0] imm_u;
wire [2:0] funct3;
wire [6:0] opcode;
wire [4:0] rd_addr;
wire [31:0] jump_addr;
wire [31:0] jr_addr;
wire [31:0] branch_addr;
wire [6:0] funct7;
assign rs1=register[instruction[19:15]];
assign rs2=register[instruction[24:20]];
assign imm=instruction[31:20];
assign imm_u=instruction[31:12];
assign jump_addr=$signed({imm_u[19],imm_u[7:0],imm_u[8],imm_u[18:9],1'b0})+$signed(pc);
assign branch_addr=$signed({imm[11],rd_addr[0],imm[10:5],rd_addr[4:1],1'b0})+$signed(pc);
assign jr_addr=$signed(rs1)+$signed(imm);
assign funct3=instruction[14:12];
assign opcode=instruction[6:0];
assign rd_addr=instruction[11:7];
assign funct7=instruction[31:25];

reg [63:0] rd_r;
reg [31:0] rd_i;
reg branch;

//cpu cycle
always@(posedge clk)begin
    if(state==0)begin
        state<=1;
        pc<=0;
        fetch_instr_this<=~fetch_instr_this;
    end
    else if(state==1)begin
        state<=2;
        fetch_instr_next<=~fetch_instr_next;
    end
    else if(state==2)begin
        //update
        //$display("pc: %h, instr: %h",pc,instruction);
        //state<=1;
        case(opcode)
            7'b1101111:begin
                pc<=jump_addr;
                fetch_instr_this<=~fetch_instr_this;
                state<=1;
            end
            7'b1100111:begin
                pc<={jr_addr[31:1],1'b0};
                fetch_instr_this<=~fetch_instr_this;
                state<=1;
            end
            7'b1100011:begin
                if(branch)begin
                    pc<=branch_addr;
                    fetch_instr_this<=~fetch_instr_this;
                    state<=1;
                end
                else begin
                    pc<=pc4;
                    fetch_instr_next<=~fetch_instr_next;
                end
            end
            default:begin
                pc<=pc4;
                fetch_instr_next<=~fetch_instr_next;
            end
        endcase
        case(opcode)
            //R type
            7'b0110011:begin
                if(funct7==7'b0000001 && funct3)begin
                    register[rd_addr]<=rd_r[63:32];
                end
                else begin
                    register[rd_addr]<=rd_r[31:0];
                end
            end
            //I type
            7'b0000011:begin
                case(instruction[14:12])
                    3'b010:register[rd_addr]<=data_out;
                    3'b000:register[rd_addr]<=$signed(data_out[7:0]);
                    3'b001:register[rd_addr]<=$signed(data_out[15:0]);
                    3'b100:register[rd_addr]<={24'd0,data_out[7:0]};
                    3'b101:register[rd_addr] <={16'd0,data_out[15:0]};
                endcase
            end
            7'b0010011:begin
                register[rd_addr]<=rd_i;
            end
            //U type
            //lui
            7'b0110111:register[rd_addr]<={imm_u,12'd0};
            //aupic
            7'b0010111:begin
                register[rd_addr]<={imm_u,12'd0}+pc;
            end
            //J type
            //jal
            //j
            7'b1101111:register[rd_addr]<=pc4;
            //jalr
            7'b1100111:register[rd_addr]<=pc4;
        endcase
    end
    else begin
        state<=2;
    end
end

always@(fetch_instr_next)begin
    /*if(pc<=32'h24)begin
        $display("pc: %h, instr: %h",pc,instr_out);
    end*/
    instruction<=instr_out;
    instr_addr<=pc4;
end

always@(fetch_instr_this)begin
    instr_addr<=pc;
end

always@(register[0])begin
    register[0]<=0;
end

//R type
always @(*)begin
    case(funct7)
        7'b0000000:begin
            case(funct3)
                3'b000:rd_r<=rs1+rs2;
                3'b001:rd_r<=rs1<<rs2[4:0];
                3'b010:rd_r<=$signed(rs1)<$signed(rs2);
                3'b011:rd_r<=rs1<rs2;
                3'b100:rd_r<=rs1^rs2;
                3'b101:rd_r<=rs1>>rs2[4:0];
                3'b110:rd_r<=rs1 | rs2;
                3'b111:rd_r<=rs1 & rs2;
            endcase
        end
        7'b0100000:begin
            case(funct3)
                3'b000:rd_r<=rs1-rs2;
                3'b101:rd_r<=$signed(rs1)>>>rs2[4:0];
            endcase
        end
        7'b0000001:begin
            case(funct3)
                3'b000:rd_r<=rs1*rs2;
                3'b001:rd_r<=$signed(rs1)*$signed(rs2);
                3'b011:rd_r<=rs1*rs2;
            endcase
        end
    endcase
end

//I type (load)
always@(*)begin
    if(opcode==7'b0000011)begin
        data_addr<=$signed(rs1)+$signed(imm);
        state<=3;
    end
end

//S type
wire [31:0] dp;
assign dp=$signed(rs1)+$signed({funct7,rd_addr});
always@(*)begin
    if(opcode==7'b0100011)begin
        data_addr<={dp[31:2],2'd0};
        case(funct3)
            3'b010:begin
                data_in<=rs2;
                data_write<=4'b1111;
            end
            3'b000:begin
                data_in<=rs2<<(8*dp[1:0]);
                data_write<=4'b0001<<dp[1:0];
            end
            3'b001:begin
                data_in<=rs2<<(8*dp[1:0]);
                data_write<=4'b0011<<dp[1:0];
            end
        endcase
    end
    else begin
        data_write<=0;
    end
end

//I type
always@(*)begin
    case(funct3)
        //addi
        3'b000:rd_i<=$signed(rs1)+$signed(imm);
        3'b010:rd_i<=$signed(rs1)<$signed(imm);
        3'b011:begin
            if(imm[11])begin
                rd_i<=rs1<{20'hfffff,imm};
            end
            else begin
                rd_i<=rs1<{20'd0,imm};
            end
        end
        3'b100:rd_i<=$signed(rs1)^$signed(imm);
        3'b110:rd_i<=$signed(rs1)|$signed(imm);
        3'b111:rd_i<=$signed(rs1)&$signed(imm);
        3'b001:rd_i<=rs1<<imm[4:0];
        3'b101:begin
            if(funct7==7'd0)begin
                rd_i<=rs1>>imm[4:0];
            end
            else begin
                //srai
                rd_i<=$signed(rs1)>>>imm[4:0];
            end
        end
    endcase
end

//B type
always@(*)begin
    case(funct3)
        3'b000:branch<=rs1==rs2;
        3'b001:branch<=rs1!=rs2;
        3'b100:branch<=$signed(rs1)<$signed(rs2);
        3'b101:branch<=$signed(rs1)>=$signed(rs2);
        3'b110:branch<=rs1<rs2;
        3'b111:branch<=rs1>=rs2;
    endcase
end

endmodule

# 5段流水CPU设计报告 #
* 学号：518021911058
* 姓名：沈瑜石
## 实验内容
1. 采用 Verilog 在 quartusⅡ中实现基本的具有 20 条 MIPS 指令的 5 段流水 CPU设计。
2. 利用实验提供的标准测试程序代码，完成仿真测试。
3. 采用 I/O 统一编址方式，即将输入输出的 I/O 地址空间，作为数据存取空间的一部分，实现 CPU 与外部设备的输入输出端口设计。实验中可采用高端地址。
4. 利用设计的 I/O 端口，通过 lw 指令，输入 DE2 实验板上的按键等输入设备信息。即将外部设备状态，读到 CPU 内部寄存器。
5. 利用设计的 I/O 端口，通过 sw 指令，输出对 DE2 实验板上的 LED 灯等输出设备的控制信号（或数据信息）。即将对外部设备的控制数据，从 CPU 内部的寄存器，写入到外部设备的相应控制寄存器（或可直接连接至外部设备的控制输入信号）。
6. 利用自己编写的程序代码，在自己设计的 CPU 上，实现对板载输入开关或按键的状态输入，并将判别或处理结果，利用板载 LED 灯或 7 段 LED 数码管显示出来。
7. 例如，将一路 4bit 二进制输入与另一路 4bit 二进制输入相加，利用两组分别 2 个LED 数码管以 10 进制形式显示“被加数”和“加数”，另外一组 LED数码管以 10 进制形式显示“和”等。（具体任务形式不做严格规定，同学可自由创意）。
8. 在实现 MIPS 基本 20 条指令的基础上，实现 Y86 相应的基本指令。
9. 在实验报告中，汇报自己的设计思想和方法；并以汇编语言的形式，提供以上两种指令集（MIPS 和 Y86）应用功能的程序设计代码，并提供程序主要流程图。

## 我的实现
## 顶层文件
```verilog
module pipelined_computer (resetn,clock,
sw, hex0_out, hex1_out, hex2_out, hex3_out, hex4_out, hex5_out);
// pc,inst,ealu,malu,walu);

input resetn, clock;
input [9:0] sw;
output [6:0] hex0_out, hex1_out, hex2_out, hex3_out, hex4_out, hex5_out;

wire [3:0] hex0, hex1, hex2, hex3, hex4, hex5;

//模块用于仿真输出的观察信号。缺省为 wire 型。
wire [31:0] pc,ealu,malu,walu;

wire mem_clock;

wire [31:0] bpc,jpc,npc,pc4,ins, inst;
wire [31:0] dpc4,da,db,dimm;
wire [31:0] epc4,ea,eb,eimm;
wire [31:0] mb,mmo;
wire [31:0] wmo,wdi;
wire [4:0] drn,ern0,ern,mrn,wrn;
//模块间互联，通过流水线寄存器传递结果寄存器号的信号线，寄存器号（32 个）为 5bit。
wire [3:0] daluc,ealuc;
//ID 阶段向 EXE 阶段通过流水线寄存器传递的 aluc 控制信号，4bit。
wire [1:0] pcsource;
//CU 模块向 IF 阶段模块传递的 PC 选择信号，2bit。
wire wpcir;
// CU 模块发出的控制流水线停顿的控制信号，使 PC 和 IF/ID 流水线寄存器保持不变。
wire dwreg,dm2reg,dwmem,daluimm,dshift,djal; // id stage
// ID 阶段产生，需往后续流水级传播的信号。
wire ewreg,em2reg,ewmem,ealuimm,eshift,ejal; // exe stage
//来自于 ID/EXE 流水线寄存器，EXE 阶段使用，或需要往后续流水级传播的信号。
wire mwreg,mm2reg,mwmem; // mem stage
//来自于 EXE/MEM 流水线寄存器，MEM 阶段使用，或需要往后续流水级传播的信号。
wire wwreg,wm2reg; // wb stage
//来自于 MEM/WB 流水线寄存器，WB 阶段使用的信号。

assign mem_clock = ~clock;

pipepc prog_cnt ( npc,wpcir,clock,resetn,pc );
//程序计数器模块，是最前面一级 IF 流水段的输入。

pipeif if_stage ( pcsource,pc,bpc,da,jpc,npc,pc4,ins,mem_clock ); // IF stage
//IF 取指令模块，注意其中包含的指令同步 ROM 存储器的同步信号，
//即输入给该模块的 mem_clock 信号，模块内定义为 rom_clk。// 注意 mem_clock。
//实验中可采用系统 clock 的反相信号作为 mem_clock（亦即 rom_clock）,
//即留给信号半个节拍的传输时间。

pipeir inst_reg ( pc4,ins,wpcir,clock,resetn,dpc4,inst ); // IF/ID 流水线寄存器
//IF/ID 流水线寄存器模块，起承接 IF 阶段和 ID 阶段的流水任务。
//在 clock 上升沿时，将 IF 阶段需传递给 ID 阶段的信息，锁存在 IF/ID 流水线寄存器
//中，并呈现在 ID 阶段。


pipeid id_stage ( mwreg,mrn,ern,ewreg,em2reg,mm2reg,dpc4,inst,
                  wrn,wdi,ealu,malu,mmo,wwreg,clock,resetn,
                  bpc,jpc,pcsource,wpcir,dwreg,dm2reg,dwmem,daluc,
                  daluimm,da,db,dimm,drn,dshift,djal ); // ID stage
//ID 指令译码模块。注意其中包含控制器 CU、寄存器堆、及多个多路器等。
//其中的寄存器堆，会在系统 clock 的下沿进行寄存器写入，也就是给信号从 WB 阶段
//传输过来留有半个 clock 的延迟时间，亦即确保信号稳定。
//该阶段 CU 产生的、要传播到流水线后级的信号较多。

pipedereg de_reg ( dwreg,dm2reg,dwmem,daluc,daluimm,da,db,dimm,drn,dshift,
                   djal,dpc4,clock,resetn,ewreg,em2reg,ewmem,ealuc,ealuimm,
                   ea,eb,eimm,ern0,eshift,ejal,epc4 ); // ID/EXE 流水线寄存器
//ID/EXE 流水线寄存器模块，起承接 ID 阶段和 EXE 阶段的流水任务。
//在 clock 上升沿时，将 ID 阶段需传递给 EXE 阶段的信息，锁存在 ID/EXE 流水线
//寄存器中，并呈现在 EXE 阶段。

pipeexe exe_stage ( ealuc,ealuimm,ea,eb,eimm,eshift,ern0,epc4,ejal,ern,ealu ); // EXE stage
//EXE 运算模块。其中包含 ALU 及多个多路器等。

pipeemreg em_reg ( ewreg,em2reg,ewmem,ealu,eb,ern,clock,resetn,
                   mwreg,mm2reg,mwmem,malu,mb,mrn); // EXE/MEM 流水线寄存器
//EXE/MEM 流水线寄存器模块，起承接 EXE 阶段和 MEM 阶段的流水任务。
//在 clock 上升沿时，将 EXE 阶段需传递给 MEM 阶段的信息，锁存在 EXE/MEM
//流水线寄存器中，并呈现在 MEM 阶段。

pipemem mem_stage ( mwmem,malu,mb,mem_clock,resetn,mmo, sw, hex0, hex1, hex2, hex3, hex4, hex5); // MEM stage
//MEM 数据存取模块。其中包含对数据同步 RAM 的读写访问。// 注意 mem_clock。
//输入给该同步 RAM 的 mem_clock 信号，模块内定义为 ram_clk。
//实验中可采用系统 clock 的反相信号作为 mem_clock 信号（亦即 ram_clk）,
//即留给信号半个节拍的传输时间，然后在 mem_clock 上沿时，读输出、或写输入。

pipemwreg mw_reg ( mwreg,mm2reg,mmo,malu,mrn,clock,resetn,
                   wwreg,wm2reg,wmo,walu,wrn); // MEM/WB 流水线寄存器
//MEM/WB 流水线寄存器模块，起承接 MEM 阶段和 WB 阶段的流水任务。
//在 clock 上升沿时，将 MEM 阶段需传递给 WB 阶段的信息，锁存在 MEM/WB
//流水线寄存器中，并呈现在 WB 阶段。

mux2x32 wb_stage ( walu,wmo,wm2reg,wdi ); // WB stage
//WB 写回阶段模块。事实上，从设计原理图上可以看出，该阶段的逻辑功能部件只
//包含一个多路器，所以可以仅用一个多路器的实例即可实现该部分。
//当然，如果专门写一个完整的模块也是很好的。

sevenseg sevenseg0(hex0, hex0_out);
sevenseg sevenseg1(hex1, hex1_out);
sevenseg sevenseg2(hex2, hex2_out);
sevenseg sevenseg3(hex3, hex3_out);
sevenseg sevenseg4(hex4, hex4_out);
sevenseg sevenseg5(hex5, hex5_out);

endmodule
```
## F阶段
```verilog
module pipeif(pcsource, pc, bpc, da, jpc, npc, pc4, ins, rom_clock);
input  [1:0]  pcsource;
input  [31:0] pc, bpc, da, jpc;
input         rom_clock;
output [31:0] npc, pc4, ins;

assign pc4 = pc + 4;

mux4x32 nextpc(pc4, bpc, da, jpc, pcsource, npc);
pipe_instmem instmem(pc, ins, rom_clock);
endmodule
```
* 根据 pc 从rom中取出对应的指令，ins。
* 根据 psource 取出合适的值放到npc中。可选的值有 pc+4（普通情况）。bpc 分支指令条件成立。da jr。jpc J型指令。
* 得到的 npc连到F阶段前的寄存器中，作为下一个周期的pc。
* ins和 pc+4同时传入D阶段。因为以后用的pc都是pc+4。
## D阶段
```verilog
module pipeid(mwreg, mrn, ern, ewreg, em2reg, mm2reg, dpc4, inst,
                    wrn, wdi, ealu, malu, mmo, wwreg, clock, resetn,
                    bpc, jpc, pcsource, wpcir, dwreg, dm2reg, dwmem, daluc,
                    daluimm, da, db, dimm, drn, dshift, djal);
input         mwreg, ewreg, em2reg, mm2reg, wwreg, clock, resetn;
input  [4:0]  mrn, ern, wrn;
input  [31:0] dpc4, inst, wdi, ealu, malu, mmo;
output        wpcir, dwreg, dm2reg, dwmem, daluimm, dshift, djal;
output [1:0]  pcsource;
output [3:0]  daluc;
output [4:0]  drn;
output [31:0] bpc, jpc, da, db, dimm;

// rsrtequ: 1 if 2 reg is equ, give to cu to judge whether jump
// sext: give by cu, whether should signed extend imm
// regrt: give by cu, which reg to return
wire          rsrtequ, regrt, sext;
wire   [1:0]  fwda, fwdb;
wire   [31:0] qa, qb;

wire   [5:0]  op = inst[31:26];
wire   [5:0]  func = inst[5:0];
wire   [4:0]  rs = inst[25:21];
wire   [4:0]  rt = inst[20:16];
wire   [4:0]  rd = inst[15:11];
wire   [15:0] imm = inst[15:0];
wire   [25:0] addr = inst[25:0];
wire   [31:0] sa = {27'b0, inst[10:6]}; // zero extend sa to 32 bits for shift instruction
wire          e = sext & inst[15]; // the bit to extend
wire   [15:0] imm_ext = {16{e}}; // high 16 sign bit when sign extend (otherwise 0)
wire   [31:0] boffset = {imm_ext[13:0], imm, 2'b00}; // branch addr offset
wire   [31:0] immediate = {imm_ext, imm}; // extend immediate to high 16

assign rsrtequ = da == db;
assign jpc = {dpc4[31:28], addr, 2'b00}; //j, jal, jr
assign bpc = dpc4 + boffset; // be, bne
assign dimm = op == 6'b000000 ? sa : immediate; // combine sa and immediate to one signal

pipe_cu cu(op, func, rs, rt, ern, mrn, rsrtequ, ewreg, em2reg, mwreg, mm2reg,
           wpcir, dwreg, dm2reg, dwmem, djal, daluimm, dshift, regrt, sext, pcsource, fwda, fwdb, daluc);

// read and write reg data.
regfile rf(rs, rt, wdi, wrn, wwreg, clock, resetn, qa, qb);

// select da and db
mux4x32 selecta(qa, ealu, malu, mmo, fwda, da);
mux4x32 selectb(qb, ealu, malu, mmo, fwdb, db);

mux2x5 selectrn(rd, rt, regrt, drn);
endmodule
```
* 分割指令的每一部分。
* 根据pc+4获得bpc，offset是加在下一条指令的pc上。
* 通过cu得到各种flag。
* 根据flag，用regfile模块读写31个通用寄存器。
* 根据flag选择da，db是否为刚读的值还是foward的值。
## cu
```verilog
module pipe_cu(op, func, rs, rt, ern, mrn, rsrtequ, ewreg, em2reg, mwreg, mm2reg,
               wpcir, wreg, m2reg, wmem, jal, aluimm, shift, regrt, sext, pcsource, fwda, fwdb, aluc);
input            rsrtequ, ewreg, em2reg, mwreg, mm2reg;
input      [4:0] rs, rt, ern, mrn;
input      [5:0] op, func;
output           wpcir, wreg, m2reg, wmem, jal, aluimm, shift, regrt, sext;
output     [1:0] pcsource;
output reg [1:0] fwda, fwdb;
output     [3:0] aluc;

wire r_type = op == 6'b000000;  // R type instruction
wire i_add = r_type & func == 6'b100000;
wire i_sub = r_type & func == 6'b100010;
wire i_and = r_type & func == 6'b100100;
wire i_or  = r_type & func == 6'b100101;
wire i_xor = r_type & func == 6'b100110;
wire i_sll = r_type & func == 6'b000000;
wire i_srl = r_type & func == 6'b000010;
wire i_sra = r_type & func == 6'b000011;
wire i_jr  = r_type & func == 6'b001000;
wire i_addi = op == 6'b001000; // I type
wire i_andi = op == 6'b001100;
wire i_ori  = op == 6'b001101;
wire i_xori = op == 6'b001110;
wire i_lw   = op == 6'b100011;
wire i_sw   = op == 6'b101011;
wire i_beq  = op == 6'b000100;
wire i_bne  = op == 6'b000101;
wire i_lui  = op == 6'b001111;
wire i_j    = op == 6'b000010; // J type
wire i_jal  = op == 6'b000011;

// Determine which instructions use rs/rt.
wire use_rs = i_add | i_sub | i_and | i_or | i_xor | i_jr | i_addi | i_andi | i_ori | i_xori
     | i_lw | i_sw | i_beq | i_bne;
wire use_rt = i_add | i_sub | i_and | i_or | i_xor | i_sll | i_srl | i_sra | i_sw | i_beq | i_bne;

// load/use hazard: when the next inst in E stage and will write the memory current inst will read.
wire load_use_hazard = ewreg & em2reg & (ern != 0) & ((use_rs & (ern == rs)) | (use_rt & (ern == rt)));

// When load/use hazard happens, stall F and D registers (stall PC),
// and generate a bubble to E register (by forbidding writing registers and memory).
assign wpcir = ~load_use_hazard;
assign wreg = (i_add | i_sub | i_and | i_or | i_xor | i_sll | i_srl | i_sra
               | i_addi | i_andi | i_ori | i_xori | i_lw | i_lui | i_jal) & ~load_use_hazard;
assign m2reg = i_lw;
assign wmem = i_sw & ~load_use_hazard;
assign jal = i_jal;
assign aluimm = i_addi | i_andi | i_ori | i_xori | i_lw | i_sw | i_lui;
assign shift = i_sll | i_srl | i_sra;
assign regrt = i_addi | i_andi | i_ori | i_xori | i_lw | i_lui;
assign sext = i_addi | i_lw | i_sw | i_beq | i_bne;

assign pcsource[1] = i_jr | i_j | i_jal;
assign pcsource[0] = (i_beq & rsrtequ) | (i_bne & ~rsrtequ) | i_j | i_jal;

assign aluc[3] = i_sra;
assign aluc[2] = i_sub | i_or | i_srl | i_sra | i_ori | i_beq | i_bne | i_lui;
assign aluc[1] = i_xor | i_sll | i_srl | i_sra | i_xori | i_lui;
assign aluc[0] = i_and | i_or | i_sll | i_srl | i_sra | i_andi | i_ori;

// Forwarding logic. when E or M stage write reg the same as will be used here.
// Forward priority: Look for E stage first, then M stage.
// Also, we should not forward r0.
always @(*)
  begin
    if (ewreg & ~em2reg & (ern != 0) & (ern == rs))
      fwda = 2'b01; // Forward from ealu.
    else if (mwreg & ~mm2reg & (mrn != 0) & (mrn == rs))
      fwda = 2'b10; // Forward from malu.
    else if (mwreg & mm2reg & (mrn != 0) & (mrn == rs))
      fwda = 2'b11; // Forward from mmo.
    else
      fwda = 2'b00; // Do not forward.
  end

always @(*)
  begin
    if (ewreg & ~em2reg & (ern != 0) & (ern == rt))
      fwdb = 2'b01; // Forward from ealu.
    else if (mwreg & ~mm2reg & (mrn != 0) & (mrn == rt))
      fwdb = 2'b10; // Forward from malu.
    else if (mwreg & mm2reg & (mrn != 0) & (mrn == rt))
      fwdb = 2'b11; // Forward from mmo.
    else
      fwdb = 2'b00; // Do not forward.
  end
endmodule
```
* 确定指令的种类
* 判断是否产生load/use hazard。因为写内存的M在解码D的两个阶段之后，上一条的load指令不能在此时取到正确的寄存器的值，所以要使F，D阶段stall。具体做法是把load_hazard设为1，这使得wpcir，wreg，wmem都为0。后者不让写内存和寄存器，前者不让dffe寄存器存。dffe仅用在F之前和D之前，所以下一阶段F，D会被stall，E被重复一次，M和W照常运行，但不能写内存和寄存器，但mmo就可以求出来，forward到D阶段。在下一阶段就可以正常运行了，因为多执行的一次M和W没有写内存，寄存器，所以不会改变状态。
```verilog
module dffe32(d, clk, clrn, e, q);
input      [31:0] d;
input             clk, clrn, e;
output reg [31:0] q;

always @(negedge clrn or posedge clk)
  if (clrn == 0)
    q <= 0;
  else if (e == 1)
    q <= d;
endmodule
```
* 根据指令的种类，设置各种flag：wreg（是否写寄存器），m2reg（是否读内存），wmem（是否写内存）。jal（是否是jal指令）。aluimm（alu的第二个参数是不是立即数）。shift（alu的第一个参数是否是shift立即数）。sext（是否符号扩展立即数）。regrt（返回到rt还是rd）。pcsource[2]（下一个周期npc怎么选）。aluc[2]（alu执行运算种类）。
* 这里用了mips的延迟槽机制（紧跟j，jal，jr，be，bne等改变pc的指令必定执行）。这里D阶段会根据da和db的值算出rsrtequ（而不是在E阶段求），从而知道是否跳转，然后根据指令种类得出pcsource。这时的F阶段并不知道，直接用了上一次求出的npc作为这次的pc，但是这次的pcscource会参与F阶段npc的运算，所以在下一次就会完成跳转。从而简化了跳转的hazard问题，但是汇编代码需要特殊改动。
* 对改变寄存器的值后两条指令内要用的指令，用forward解决，因为写回寄存器在W阶段，3阶段以后。因为这个时候期望的值就在E阶段的ealu，或者M阶段的malu（普通的写回）或mmo中（内存中读取，如果它还在E阶段就要用，就是load/use hazard了，要stall处理）。forward的具体做法是设置fwda,fwdb，并将ealu，malu，mmo传回，进行选择。
## E阶段
```verilog
module pipeexe(ealuc, ealuimm, ea, eb, eimm, eshift, ern0, epc4, ejal, ern, ealu);
input         ealuimm, eshift, ejal;
input  [3:0]  ealuc;
input  [4:0]  ern0;
input  [31:0] ea, eb, eimm, epc4;
output [4:0]  ern;
output [31:0] ealu;

wire [31:0] alua, alub, alur, pc8;

assign pc8 = epc4 + 4;
assign ern = ern0 | {5{ejal}};

mux2x32 selectalua(ea, eimm, eshift, alua);
mux2x32 selectalub(eb, eimm, ealuimm, alub);
alu al_unit(alua, alub, ealuc, alur);
mux2x32 selectalur(alur, pc8, ejal, ealu);
endmodule
```
* 根据flag选择参与运算的数。
* 让alu模块计算。
* 如果是jal指令，则结果是pc+8，因为jal不需要alu运算，但是要在R31中写跳转后没有执行的第一条指令，所以要用alu的结果作为W阶段的输入。因为用了延迟槽，所以是jal的下两条指令，pc4是下一条，所以+8。
## M阶段
```verilog
module pipemem(mwmem, malu, mb, ram_clock, resetn, mmo, sw, hex0, hex1, hex2, hex3, hex4, hex5);
input         mwmem, ram_clock, resetn;
input  [31:0] malu, mb;
input  [9:0]  sw;
output [31:0] mmo;
output [3:0]  hex0, hex1, hex2, hex3, hex4, hex5;

wire [31:0] mem_data;

pipe_datamem datamem(malu, mb, mmo, mwmem, ram_clock, resetn, sw, hex0, hex1, hex2, hex3, hex4, hex5);
endmodule
```
* 读写内存。读写IO。
* ram_clock在顶层文件被设为了clock取反，因为寄存器和内存都在时钟上升沿读写，这样内存会提前半个周期读写。因为访存M阶段寄存器不用做什么，所以半个周期就可以了。之后mem有一个半周期读写，可以让mmo的foward来得及做。

## 测试程序
### 加法程序
```mips
start:  j main_loop
    xor $0, $0, $0
transfer:   xor $3, $3, $3
transfer_loop:  addi $1, $1, -10
    sra $2, $1, 31
    bne $2, $0, transfer_end
    xor $0, $0, $0
    j transfer_loop
    addi $3, $3, 1
transfer_end:   jr $31
    addi $1, $1, 10
main_loop:  lw $1, 65472($0)
    sra $4, $1, 5
    andi $1, $1, 31
    jal transfer
    add $5, $1, $4
    sw $1, 65408($0)
    sw $3, 65412($0)
    jal transfer
    addi $1, $4, 0
    sw $1, 65416($0)
    sw $3, 65420($0)
    jal transfer
    addi $1, $5, 0
    sw $1, 65424($0)
    j main_loop
    sw $3, 65428($0)
```
* 从sw读取输入，分成两个5位的数，将它们和它们的和转为10进制，并在数码管上显示。
* j, jal, jr,bne 指令都有延迟槽，所以要把前面一条指令放到跳转指令后面，或者在后面加`xor $0, $0, $0`作为nop。

### hazard测试程序
```mips
start:  xor $10, $10, $10
    xor $11, $11, $11
    addi $10, $10, 65280
    addi $11, $11, 65408
    j main_loop
    xor $1, $1, $1
main_loop:  addi $1, $1, 12345
    sw $1, 0($10)    # forward from e_alul
    addi $2, $1, 1
    xor $0, $0, $0  # wait
    sw $2, 4($10)   # forward from m_alu
    lw $3, 0($10)
    sub $4, $1, $3  # load/use hazard
    bne $4 fail
    xor $0, $0, $0
    lw $4, 4($10)
    xor $0, $0, $0  # wait
    sub $5, $2, $4  # forward from mmo
    bne $5 fail
    xor $1, $1, $1
    j main_loop
    xor $1, $1, $1
fail:   addi $1, $1, 8
    sw $1, 0($11)
    j fail
    xor $1, $1, $1
```
* 测试了3种forward的情况，和load/use hazard。出错则输出1否则输出0。
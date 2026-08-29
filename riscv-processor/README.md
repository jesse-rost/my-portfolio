# RISC-V Single-Cycle & 5-Stage Pipelined Processor

Two complete implementations of a custom 32-bit RISC-V processor core written from scratch in VHDL, verified through self-checking simulation and synthesized on an Intel MAX 10 FPGA. The pipelined design implements full hazard resolution and is benchmarked against the single-cycle baseline using a hand-written assembly sorting program.

Built entirely using structural and dataflow VHDL hardware descriptions, the project demonstrates:

- RISC-V RV32I instruction set architecture implementation
- Five-stage instruction pipelining with pipeline register isolation
- Data hazard resolution through operand forwarding
- Load-use hazard detection and pipeline stalling
- Control hazard resolution through branch flushing
- Component-level functional verification with self-checking testbenches
- Post-synthesis timing analysis and quantitative performance comparison

---

# Overview

The project began as an ARMv4 single-cycle processor built for coursework. This repository is a ground-up RISC-V redesign of that datapath, followed by a pipelined implementation with complete hazard handling and a measured performance comparison between the two.

The system is structured as three development layers.

## 1. Instruction Set Architecture Redesign

- RISC-V RV32I instruction encoding replacing the ARM condition-code architecture
- Fixed-position register fields eliminating per-instruction field reinterpretation
- Multi-format immediate generation for I, S, B, U, and J instruction types
- Hardwired combinational control decoding from opcode, funct3, and funct7

## 2. Single-Cycle Baseline Implementation

- Program counter generation and instruction fetch
- Thirty-two register file with hardwired zero register
- ALU execution with signed comparison support
- Branch and jump target selection with subroutine call and return

## 3. Pipelined Implementation

- Four pipeline registers isolating five concurrent instruction stages
- Forwarding unit resolving register dependencies across EX/MEM and MEM/WB
- Hazard detection unit stalling on load-use dependencies
- Branch flush logic discarding wrong-path instructions on taken branches

Together these layers demonstrate the architectural tradeoff at the center of pipelined design: increased instruction latency and cycle count in exchange for a shorter critical path and higher clock frequency.

---

# System Architecture

```text
┌──────────────────────────────────────────────────────────────┐
│                    Pipelined Processor Core                  │
│  Hardwired Control │ Forwarding Unit │ Hazard Detection Unit │
└───────────────────────────────┬──────────────────────────────┘
                                │
                                ▼
┌──────────────────────────────────────────────────────────────┐
│                     Pipeline Stage Isolation                 │
│                                                              │
│    IF  ──║──  ID  ──║──  EX  ──║──  MEM  ──║──  WB           │
│       IF/ID     ID/EX     EX/MEM     MEM/WB                  │
│                                                              │
└───────────────────────────────┬──────────────────────────────┘
                                │
                                ▼
┌──────────────────────────────────────────────────────────────┐
│                  Hardware Submodules & Memories              │
│   Register File │ ALU │ Immediate Generator │ ROM │ RAM      │
└──────────────────────────────────────────────────────────────┘
```

## Supported Instruction Set

A twelve-instruction subset of RV32I, chosen to exercise every datapath pattern without redundancy.

| Format | Instructions | Datapath Pattern |
|---|---|---|
| R-type | `add` `sub` `and` `or` `slt` | Register-register arithmetic |
| I-type | `addi` `lw` `jalr` | Immediate arithmetic, memory read, register jump |
| S-type | `sw` | Memory write |
| B-type | `beq` | Conditional branch |
| J-type | `jal` | Unconditional jump with link |
| U-type | `lui` | Upper immediate load |

Adding further RV32I instructions requires only decoder entries, not datapath modification.

## Instruction Encoding

RISC-V places register fields at fixed bit positions across every instruction format. This is the property that makes the control unit and register file wiring straightforward, and it is the primary structural difference from the ARM design this project replaced.

```text
        31        25 24   20 19   15 14  12 11        7 6        0
       ┌────────────┬───────┬───────┬──────┬───────────┬─────────┐
R-type │   funct7   │  rs2  │  rs1  │funct3│  rd       │ opcode  │
       ├────────────┴───────┼───────┼──────┼───────────┼─────────┤
I-type │    imm[11:0]       │  rs1  │funct3│  rd       │ opcode  │
       ├────────────┬───────┼───────┼──────┼───────────┼─────────┤
S-type │  imm[11:5] │  rs2  │  rs1  │funct3│imm[4:0]   │ opcode  │
       ├────────────┼───────┼───────┼──────┼───────────┼─────────┤
B-type │imm[12,10:5]│  rs2  │  rs1  │funct3│imm[4:1,11]│ opcode  │
       ├────────────┴───────┴───────┴──────┼───────────┼─────────┤
U-type │           imm[31:12]              │  rd       │ opcode  │
       ├───────────────────────────────────┼───────────┼─────────┤
J-type │  imm[20,10:1,11,19:12]            │  rd       │ opcode  │
       └───────────────────────────────────┴───────────┴─────────┘
```

`rs1`, `rs2`, and `rd` never change position. Source register addresses can therefore be wired directly from the instruction word to the register file read ports with no multiplexing, and the sign bit of every immediate remains at bit 31 so sign-extension hardware is shared across formats.

Only the immediates are redistributed, and that redistribution is confined to a single component. Branch and jump immediates additionally omit bit zero — instruction addresses are always even — which the generator restores by concatenation, extending the reachable offset range by one bit at no encoding cost.

```vhdl
with OPCODE select
IMMR <= (31 downto 11 => INSTR(31)) & INSTR(30 downto 20)
            when B"0000011" | B"0010011" | B"1100111",              -- I-type
        (31 downto 12 => INSTR(31)) & INSTR(31 downto 25)
            & INSTR(11 downto 7)            when B"0100011",        -- S-type
        (31 downto 12 => INSTR(31)) & INSTR(7) & INSTR(30 downto 25)
            & INSTR(11 downto 8) & '0'      when B"1100011",        -- B-type
        INSTR(31 downto 12) & X"000"        when B"0110111",        -- U-type
        (31 downto 20 => INSTR(31)) & INSTR(19 downto 12) & INSTR(20)
            & INSTR(30 downto 21) & '0'     when B"1101111",        -- J-type
        X"00000000"                         when others;
```

The trailing `'0'` on the B-type and J-type cases is the implied zero bit, equivalent to a left shift by one.

## Hardware Platform

| Component | Purpose |
|---|---|
| Intel MAX 10 FPGA (10M50DAF484C7G) | Synthesis target |
| GHDL | Functional simulation |
| Intel Quartus Prime | Synthesis and timing analysis |

---

# Performance Results

Both designs were synthesized for the same device with identical top-level ports and clock constraints. Fmax is reported at the Slow 1200 mV 85 °C corner and is a timing-model estimate rather than a measured silicon result; the comparison is meaningful because both designs were analyzed identically.

| | Single-Cycle | Pipelined |
|---|---|---|
| Maximum clock frequency | 46.15 MHz | 78.96 MHz |
| Cycles (bubble sort benchmark) | 105 | 153 |
| Execution time | 2.28 µs | 1.94 µs |
| **Net speedup** | — | **1.17×** |

Pipelining raises the clock frequency by 1.71×, but the pipelined processor requires 48 additional cycles to complete the same program. Most of the frequency gain is consumed by that cycle overhead, leaving a net improvement of 17 percent.

## Where the Extra Cycles Go

The benchmark executes 106 dynamic instructions. In the single-cycle design that is 105 cycles measured to the final register write. The pipelined design adds:

| Source | Cycles |
|---|---|
| Pipeline fill | 4 |
| Load-use stalls (8 occurrences × 1 cycle) | 8 |
| Branch flushes (18 taken branches × 2 cycles) | 36 |
| **Total overhead** | **48** |

Branch flushing accounts for three quarters of the penalty. The bubble sort is unusually branch-dense: every loop iteration executes at least one conditional branch and one unconditional jump, and the inner loop body is only a handful of instructions long. With no branch prediction, each taken branch discards the two instructions already fetched behind it, so the processor spends a large fraction of its time refilling the pipeline.

This is the worst case for a pipeline of this design. A workload with longer straight-line stretches between branches would retain far more of the frequency advantage.

## Theoretical Ceiling Without Control Hazards

For a program with no taken branches and no load-use dependencies, the pipelined processor requires only the four-cycle fill:

```
single-cycle:  N cycles / 46.15 MHz
pipelined:     N + 4 cycles / 78.96 MHz
```

| Program length | Speedup |
|---|---|
| 40 instructions | 1.56× |
| 100 instructions | 1.65× |
| 1000 instructions | 1.70× |

As the program lengthens, the fixed fill cost amortizes and the speedup converges on the frequency ratio of 1.71×. That ratio is the ceiling for this implementation — not the textbook 5× — for the reasons below.

## Why the Frequency Gain Is 1.71× and Not 5×

The idealized five-stage speedup assumes that pipelining divides one long combinational path into five equal segments. Two effects prevent that here.

**Pipelining adds logic inside the stages it creates.** Forwarding multiplexers, hazard comparators, and flush control do not exist in the single-cycle design. Each is combinational logic inserted into a stage, so the longest stage after pipelining is considerably longer than one fifth of the original datapath. The critical path is not simply the single-cycle path divided by five; it is the worst stage *plus* the hazard machinery that stage now carries.

**The critical path runs through the forwarding network.** Post-synthesis timing analysis identifies the worst-case path as `MEMWB_RD_ADDR[0]` to `IDEX_RD2[22]`, a data delay of 12.606 ns against the 10 ns constraint. This is the MEM/WB forwarding route: the writeback destination address feeds the forwarding comparator, whose result selects `WB_DATA` through the forwarding multiplexer and into the execute stage. Registering the forwarding decision, or computing it a cycle earlier, would shorten this path.

Two further factors contribute. The instruction ROM is a thirty-nine-way selected assignment and the data memory is a signal array, so neither infers dedicated block RAM; both add combinational delay. The register file's write-first bypass places a comparator and multiplexer in series with every register read.

Taken together, the practical conclusion is that throughput on this benchmark is limited by control hazards rather than by clock frequency. Branch prediction, or resolving branches in the decode stage with a dedicated comparator, would recover more real performance than any further work on the critical path.

---

# Hazard Resolution

## Data Forwarding

Two multiplexers at the ALU inputs compare destination registers held in EX/MEM and MEM/WB against the source registers of the instruction in EX. On a match, the in-flight result routes directly to the ALU rather than waiting for writeback. EX/MEM takes priority, holding the more recent value.

```vhdl
ALU_A <= EXMEM_ALU_RESULT when (EXMEM_REGWR = '1'
                          and EXMEM_RD_ADDR /= "00000"
                          and EXMEM_RD_ADDR = IDEX_RS1_ADDR) else
         WB_DATA when (MEMWB_REGWR = '1'
                 and MEMWB_RD_ADDR /= "00000"
                 and MEMWB_RD_ADDR = IDEX_RS1_ADDR) else
         IDEX_RD1;
```

The MEM/WB path forwards `WB_DATA` rather than the raw ALU result, so that loads correctly forward their memory data rather than the computed address.

## Load-Use Stalling

Forwarding cannot resolve a load followed immediately by a consumer of its result, because the memory read has not completed when the ALU requires the value. The hazard unit detects this condition and stalls for one cycle.

```vhdl
STALL <= '1' when (IDEX_MEMRD = '1' and IDEX_RD_ADDR /= B"00000"
                   and (IDEX_RD_ADDR = A1 or IDEX_RD_ADDR = A2)) else '0';
```

The stall freezes the program counter and IF/ID register while injecting a bubble into ID/EX. Zeroing the bubble's `MEMRD` is also what clears the stall condition on the following cycle, making the stall self-releasing.

## Branch Flushing

Branches resolve in EX, by which point two subsequent instructions have already entered the pipeline. When `PCSRC` asserts, IF/ID and ID/EX are cleared, discarding both wrong-path instructions.

```vhdl
if RST = '0' or PCSRC = '1' then
    IFID_INST       <= (others => '0');
    IFID_PC_PLUS4   <= (others => '0');
    IFID_PC_CURRENT <= (others => '0');
elsif STALL = '0' then
    IFID_INST       <= INSTR;
    IFID_PC_PLUS4   <= PC_PLUS4;
    IFID_PC_CURRENT <= PC_CURRENT;
end if;
```

The same zeroing mechanism serves reset, stall bubbles, and branch flushes.

## Read-During-Write Bypass

A register read in ID targeting the same register being written in WB returns a stale value under a synchronous-write register file. The register file therefore implements a write-first bypass.

```vhdl
RD1 <= WD4 when (A1 = A3 and REGWR = '1' and A1 /= B"00000") else
       X0  when A1 = B"00000" else
       X1  when A1 = B"00001" else
       ...
```

Without this, any dependency spanning exactly three instructions silently produces a wrong result — a case that back-to-back dependency tests do not expose.

---

# Verification

Each component is exercised by a self-checking testbench using `assert` statements, so a clean simulation run means every check passed.

| Testbench | Coverage |
|---|---|
| `alu_tb.vhd` | All five operations, signed `slt`, zero flag |
| `regfile_tb.vhd` | Read, write, hold, reset, x0 behaviour |
| `imm_tb.vhd` | All six immediate formats, sign extension |
| `control_tb.vhd` | Control word for all twelve instructions |
| `regn_tb.vhd` | Load, hold, reset, synchronous behaviour |
| `scp_tb.vhd` / `pipelined_processor_tb.vhd` | Full-processor cycle-level traces |

The processor-level testbenches log per-cycle state — program counter, instruction in EX, register file reads, forwarding sources, ALU operands, and writeback — which is how the read-during-write and forwarding defects above were isolated.

Complete simulation traces for both implementations are in `docs/`. Each records per-cycle processor state and flags every register write, ending with the sorted array loaded back into `x25`–`x29`.

## Benchmark Program

`firmware/bubble_sort.s` sorts a five-element array in memory using a bubble sort with early exit on a swap-free pass. Written by hand within the twelve-instruction subset, comparisons are constructed from `slt` and `beq`, and loops from `beq` paired with `jal`.

```riscv
bubble_sort:
    lw   x17, 0(x15)
    add  x19, x15, x16
    lw   x18, 0(x19)
    beq  x17, x18, check_end
    slt  x20, x17, x18
    beq  x20, x0, swap_location
    j    check_end
```

The `lw x18, 0(x19)` followed immediately by a dependent `beq` produces a load-use hazard on every loop iteration, exercising the stall logic under real workload conditions. The program additionally covers chained data dependencies, taken and not-taken branches, and backward jumps.

```
input:  [2, 10, 6, 55, 33]
output: [2, 6, 10, 33, 55]
```

Both processors produce identical sorted output.

---

# Repository Layout

```text
riscv-processor/
│
├── docs/
│   ├── single_cycle_trace.log
│   └── pipelined_trace.log
│
├── firmware/
│   ├── bubble_sort.s
│   └── iRom.vhd
│
├── images/
│
├── single-cycle/
│   ├── src/
│   │   ├── scp.vhd
│   │   ├── alu.vhd
│   │   ├── control.vhd
│   │   ├── imm.vhd
│   │   ├── regfile.vhd
│   │   ├── regn.vhd
│   │   └── dmem.vhd
│   └── tb/
│
└── pipelined/
    ├── src/
    │   ├── pipelined_processor.vhd
    │   ├── alu.vhd
    │   ├── control.vhd
    │   ├── imm.vhd
    │   ├── regfile.vhd
    │   ├── regn.vhd
    │   └── dmem.vhd
    └── tb/
```

## Component Provenance

| Origin | Files |
|---|---|
| Carried over from the ARM project | `regn.vhd`, `dmem.vhd`, `iRom.vhd` |
| Adapted for RISC-V | `regfile.vhd`, `alu.vhd` |
| Written from scratch | `control.vhd`, `imm.vhd`, both top levels, all testbenches |

The register file was expanded to thirty-two registers with a hardwired zero register and write-first bypass. The ALU was re-encoded with signed set-less-than and a zero flag for branch comparison. Control decoding and immediate assembly were rewritten entirely, since these are where an instruction set architecture's identity resides.

The ARM design's condition-code register, barrel shifter, rotator, and generated multiplexer wrappers have no RISC-V counterpart and were removed.

---

# Building and Simulating

Requires [GHDL](https://github.com/ghdl/ghdl). All sources use VHDL-2008.

```bash
cd pipelined
ghdl -a --std=08 ../firmware/iRom.vhd
ghdl -a --std=08 src/*.vhd
ghdl -a --std=08 tb/pipelined_processor_tb.vhd
ghdl -e --std=08 tb_riscv
ghdl -r --std=08 tb_riscv
```

Component testbenches run identically — substitute the testbench file and its entity name.

To execute a different program, replace the machine-code entries in `firmware/iRom.vhd`. Addresses are word aligned and increment by four.

## Synthesis

Quartus projects target `10M50DAF484C7G` under a single clock constraint:

```tcl
create_clock -name CLK -period 10.000 [get_ports CLK]
```

For synthesis, both top levels are reduced to `CLK`, `RST`, `O_PC`, and `O_WBDATA`. Some observable output is required — with none, synthesis correctly determines that no logic affects anything externally visible and optimizes the entire design away. The simulation versions expose considerably more internal state, which exceeds the device pin count and is therefore trimmed before synthesis.

---

# Notes and Limitations

- Data memory is word addressed via `A(6 downto 2)`, discarding upper address bits. Programs using `lui` to construct a base address execute correctly, but the array occupies low memory regardless of the address written.
- `ebreak` is not implemented. Programs terminate in a spin loop.
- Instruction memory is read-only and populated at build time; no loader exists.
- Branch prediction is not implemented. The processor always fetches sequentially and flushes on a taken branch.

---

**Jesse Rost** 

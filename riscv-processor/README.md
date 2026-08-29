# RISC-V Processor — Single-Cycle and 5-Stage Pipelined

Two implementations of a RISC-V RV32I-subset processor written from scratch in VHDL, verified in
simulation with GHDL and synthesized with Intel Quartus Prime for an Intel MAX 10 FPGA.

The project began as an ARMv4 single-cycle processor built for coursework. This repository is a
ground-up RISC-V redesign of that datapath, followed by a pipelined implementation with full hazard
handling, and a measured performance comparison between the two.

---

## Results

Both designs were synthesized for the same device (`10M50DAF484C7G`, Intel MAX 10) with identical
top-level ports and clock constraints. Fmax is reported at the Slow 1200mV 85 °C corner.

| | Single-Cycle | Pipelined |
|---|---|---|
| Fmax | 46.15 MHz | 78.00 MHz |
| Cycles (bubble sort benchmark) | 136 | 145 |
| Execution time | 2.95 µs | 1.86 µs |
| **Speedup** | — | **1.59×** |

The pipelined processor executes nine more cycles than the single-cycle version — pipeline fill,
load-use stalls, and branch flushes all add cycles — but runs at 1.69× the clock frequency, for a
net throughput improvement of roughly 1.6×.

### Why not 5×?

The theoretical ceiling for a five-stage pipeline is not reached here, for reasons worth naming:

- **Branch resolution spans stages.** `PCSRC` is produced in EX from the ALU's zero flag and feeds
  the PC multiplexer in IF combinationally, within a single cycle. This path is not broken by any
  pipeline register, so it remains long even after pipelining. Resolving branches in ID with a
  dedicated comparator would be the highest-impact fix.
- **Memories synthesized into logic.** The instruction ROM is a 39-way `with…select` multiplexer and
  the data memory is a signal array; neither infers dedicated block RAM. Both add combinational
  delay to the fetch and memory stages.
- **Register file bypass.** The write-first read logic adds a comparator and multiplexer in series
  with every register read, lengthening the decode stage.

---

## Architecture

### Instruction set

A twelve-instruction subset of RV32I, chosen to cover every datapath pattern without redundancy:

| Format | Instructions |
|---|---|
| R-type | `add` `sub` `and` `or` `slt` |
| I-type | `addi` `lw` `jalr` |
| S-type | `sw` |
| B-type | `beq` |
| J-type | `jal` |
| U-type | `lui` |

This set exercises register-register arithmetic, immediate arithmetic, memory reads and writes,
conditional branching, and subroutine call and return. Adding further RV32I instructions requires
only decoder entries, not datapath changes.

### Pipeline stages

```
IF  →  ID  →  EX  →  MEM  →  WB
   IF/ID  ID/EX  EX/MEM  MEM/WB
```

Four pipeline registers carry instruction data and control signals forward, so that each stage
operates on its own instruction. Control signals are generated once in ID and travel with their
instruction until the stage that consumes them.

### Hazard handling

**Data hazards — forwarding.** Two multiplexers at the ALU inputs compare the destination registers
held in EX/MEM and MEM/WB against the source registers of the instruction in EX. On a match, the
in-flight result is routed directly to the ALU rather than waiting for writeback. EX/MEM takes
priority over MEM/WB, since it holds the more recent value. The MEM/WB path forwards `WB_DATA`
rather than the raw ALU result, so that loads forward their memory data correctly.

**Load-use hazards — stalling.** Forwarding cannot resolve a load followed immediately by a
consumer of its result, because the memory read has not completed when the ALU needs the value. The
hazard unit detects this case and stalls for one cycle: the PC and IF/ID register freeze, and a
bubble (all control signals zeroed) is injected into ID/EX. Zeroing the bubble's `MEMRD` is also
what clears the stall condition on the following cycle.

**Control hazards — flushing.** Branches resolve in EX, by which point two subsequent instructions
have already entered the pipeline. When `PCSRC` asserts, IF/ID and ID/EX are cleared, discarding
both wrong-path instructions. The same zeroing mechanism serves reset, stall bubbles, and flushes.

**Read-during-write.** A register read in ID that targets the same register being written in WB
returns a stale value with a synchronous-write register file. The register file therefore
implements a write-first bypass: when a read address matches the write address and the write is
enabled, the read port returns the incoming write data. Without this, any dependency spanning
exactly three instructions produces a wrong result.

---

## Verification

Each component is exercised by a self-checking testbench using `assert` statements, so a clean run
means every check passed.

| Testbench | Covers |
|---|---|
| `alu_tb.vhd` | All five operations, signed `slt`, zero flag |
| `regfile_tb.vhd` | Read, write, hold, reset, x0 behaviour |
| `imm_tb.vhd` | All six immediate formats, sign extension |
| `control_tb.vhd` | Control word for all twelve instructions |
| `regn_tb.vhd` | Load, hold, reset |
| `scp_tb.vhd` / `pipelined_processor_tb.vhd` | Full-processor cycle traces |

The processor-level testbenches log per-cycle state — PC, instruction in EX, register file reads,
forwarding sources, ALU operands, and writeback — which is how the read-during-write and forwarding
bugs above were isolated.

### Benchmark

`firmware/bubble_sort.s` sorts a five-element array in memory using a bubble sort with early exit
on a swap-free pass. Written by hand within the twelve-instruction subset, which means comparisons
are built from `slt` and `beq`, and loops from `beq` plus `jal`.

```
input:  [2, 10, 6, 55, 33]
output: [2, 6, 10, 33, 55]
```

The program exercises load-use hazards (`lw` followed immediately by a dependent instruction),
chained data dependencies, taken and not-taken branches, and backward jumps. Both processors
produce identical results.

---

## Repository layout

```
riscv-processor/
├── single-cycle/
│   ├── src/          scp.vhd, alu.vhd, control.vhd, imm.vhd,
│   │                 regfile.vhd, regn.vhd, dmem.vhd, iRom.vhd
│   └── tb/           component and processor testbenches
└── pipelined/
    ├── src/          pipelined_processor.vhd and shared components
    └── tb/           component and processor testbenches
```

Components fall into three categories. `regn.vhd`, `dmem.vhd`, and `iRom.vhd` were carried over
from the ARM project with minimal change. `regfile.vhd` and `alu.vhd` were adapted — the register
file expanded to 32 registers with a hardwired x0 and a write-first bypass, the ALU re-encoded with
signed `slt` and a zero flag. `control.vhd`, `imm.vhd`, and both top levels were written from
scratch, since control decoding and immediate assembly are where an ISA's identity lives.

The ARM design's condition-code register, barrel shifter, rotator, and generated multiplexer
wrappers have no RISC-V counterpart and were dropped.

---

## Building and simulating

Requires [GHDL](https://github.com/ghdl/ghdl). All files use VHDL-2008.

```bash
cd pipelined
ghdl -a --std=08 src/*.vhd
ghdl -a --std=08 tb/pipelined_processor_tb.vhd
ghdl -e --std=08 tb_riscv
ghdl -r --std=08 tb_riscv
```

Component testbenches run the same way — substitute the testbench file and its entity name.

To run a different program, replace the machine-code entries in `iRom.vhd`. Addresses are word
aligned and increment by four.

### Synthesis

Quartus projects target `10M50DAF484C7G` with a single clock constraint:

```tcl
create_clock -name CLK -period 10.000 [get_ports CLK]
```

Both top levels expose only `CLK`, `RST`, `O_PC`, and `O_WBDATA` for synthesis. Some observable
output is necessary — with none, synthesis correctly determines that no logic affects anything and
optimizes the entire design away.

---

## Notes and limitations

- The data memory is word addressed via `A(6 downto 2)`, so the upper address bits are discarded.
  Programs using `lui` to build a base address work correctly, but the array occupies low memory
  regardless of the address written.
- `ebreak` is not implemented. Programs terminate in a spin loop.
- Instruction memory is read-only and populated at build time; there is no loader.
- Branch prediction is not implemented. The processor always fetches sequentially and flushes on a
  taken branch.

---

**Jesse Rost** · Computer Engineering, Milwaukee School of Engineering
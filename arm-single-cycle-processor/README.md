# ARMv4 Single-Cycle Processor & System-on-Chip (SoC)

A real-time embedded hardware-software system featuring a custom 32-bit single-cycle CPU core architecture synthesized on an Intel MAX 10 FPGA. The application executes a bare-metal autonomous navigation program that tracks spatial trajectory bounds and drives a physical Digibot robotic platform through real-time memory-mapped peripheral interaction.

Built entirely using structural and dataflow VHDL hardware descriptions, the project demonstrates:

- Low-level computer architecture design
- Hardwired instruction decoding
- Multi-port register files
- Barrel shifter execution datapaths
- Memory-mapped I/O routing
- Bare-metal ARM assembly firmware development
- FPGA system integration without vendor soft-core IP

---

# Overview

The system is structured as a hierarchical digital architecture composed of three primary hardware integration layers.

## 1. Low-Level Hardware Submodules & Primitives

- Structural execution leaf components and arithmetic logic cells
- Multi-port register vectors and custom routing multiplexers
- Hardwired combinational opcode control decode matrices

## 2. Datapath Lifecycle Stages

- Program Counter generation and instruction fetch logic
- Register decode and operand extraction
- Immediate generation and ALU execution
- Branch target computation and status flag updates

## 3. System-Level SoC Integration

- CPU encapsulation and clock synchronization
- Memory-mapped peripheral routing
- Real-time hardware interfaces for switches, displays, sensors, and motor control

Together these layers provide deterministic single-cycle execution while maintaining a hardware architecture representative of real-world embedded processor design.

---

# System Architecture

```text
┌──────────────────────────────────────────────────────────────┐
│                  System Top-Level SoC Wrapper                │
│ Clock Synchronizer │ Address Decoder │ On-Chip Data RAM      │
└───────────────────────────────┬──────────────────────────────┘
                                │
                                ▼
┌──────────────────────────────────────────────────────────────┐
│                 Central Processing Unit (CPU) Core           │
│ Hardwired Control Unit │ CPSR Status Register                │
└───────────────────────────────┬──────────────────────────────┘
                                │
                                ▼
┌──────────────────────────────────────────────────────────────┐
│                  Datapath Lifecycle Stages                   │
│                                                              │
│  Instruction Fetch → Instruction Decode → Execute            │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

---

# Hardware Platform

| Component | Purpose |
|------------|----------|
| Intel MAX 10 FPGA (10M50DAF484C7G) | Target FPGA Platform |
| Digibot Rover | Physical autonomous robot |
| Infrared Sensors | Obstacle detection |
| DE10-Lite Switches | Runtime configuration |
| DE10-Lite LEDs | System status indication |
| 7-Segment Displays | Telemetry and debugging output |

---

# Software & Hardware Components

## Hardwired Control Unit (`control.vhd`)

The control unit is implemented entirely as combinational logic and decodes instruction bit fields into control signals within a single clock cycle.

### Features

- ARM condition code decoding
- Data-processing opcode selection
- CPSR flag update controls
- Memory read/write control generation
- Link register branch support

### Example Decode Logic

```vhdl
ALUSEL <= CMD when OPCODE=B"00" else
          X"4" when OPCODE=B"01" and PUBWL(2)='1' else
          X"2" when OPCODE=B"01" and PUBWL(2)='0' else
          X"D";
```

---

## Multi-Port Register File (`regfile.vhd`)

Implements sixteen 32-bit registers with:

- Three simultaneous read ports
- One write-back port
- Synchronous updates
- Active-low reset

### Example Register Update Logic

```vhdl
process(rst, clk)
begin
    if rising_edge(clk) then
        if rst = '0' then
            R2 <= X"00000000";
        elsif REGWR = '0' then
            if A4 = B"0010" then
                R2 <= WD4;
            end if;
        end if;
    end if;
end process;
```

---

## Autonomous Navigation Firmware (`digibot_square_navigation.s`)

The firmware directly controls the Digibot using memory-mapped I/O without an operating system.

### Features

- Sensor polling
- Obstacle detection
- Runtime distance measurement
- Turn calibration
- Display output
- Hardware alert generation

### Sensor Polling Example

```asm
count:
    LDR     R2, [R5]
    AND     R2, R2, #0x04
    CMP     R2, #0
    ADD     R4, #1
    BNE     measure_drive_time
    B       count
```

---

# Memory-Mapped I/O Subsystem (`addressdecoder.vhd`)

The address decoder routes CPU accesses to memory and peripherals.

### Example Address Decode

```vhdl
LD3 <= '0' when ADDR < X"0000001F"
               and MEMRD = '1'
               and MEMWR = '0'
       else '1';

LD2 <= '0' when ADDR = X"000000E8"
               and MEMRD = '1'
               and MEMWR = '0'
       else '1';
```

### Address Map

| Address | Function |
|----------|-----------|
| 0x00000000 - 0x0000001F | Data RAM |
| 0x000000E8 | 7-Segment Display |
| 0x000000F0 | Switch Inputs |

---

# Advanced Hardware Features

## ALU Signed Overflow Detection

The ALU computes overflow flags entirely in combinational logic.

```vhdl
V <= (not S(0) and not INTA(31) and not INTB(31) and INTF(31)) or
     (not S(0) and INTA(31) and INTB(31) and not INTF(31)) or
     (S(0) and not INTA(31) and INTB(31) and INTF(31)) or
     (S(0) and INTA(31) and not INTB(31) and not INTF(31));
```

Supports:

- Addition overflow detection
- Subtraction overflow detection
- Single-cycle flag generation

---

## Barrel Shifter & Rotator

Implements ARM-style operand shifting before ALU execution.

### Supported Operations

- Logical Shift Left (LSL)
- Logical Shift Right (LSR)
- Arithmetic Shift Right (ASR)
- Rotate Right (ROR)

### Example Rotation Logic

```vhdl
with ROT select
B <= NUM(29 downto 0) & B"00" when B"1111",
     NUM(5 downto 0) &
     B"000000000000000000000000" &
     NUM(7 downto 6) when B"0011",
     NUM when others;
```

---

## Seven-Segment Display Driver

### Hexadecimal Encoding

```vhdl
constant HEX0 : std_logic_vector(7 downto 0) := 8X"C0";
constant HEX1 : std_logic_vector(7 downto 0) := 8X"F9";
constant HEXA : std_logic_vector(7 downto 0) := 8X"88";
```

### Display Routing

```vhdl
with A(3 downto 0) select
SEG0 <= HEX0 when X"0",
        HEX1 when X"1",
        HEXA when X"A",
        HEXF when others;
```

---

# Repository Layout

```text
arm-single-cycle-processor/
│
├── docs/
│   └── digibot_demo.mp4
│
├── firmware/
│   └── digibot_square_navigation.s
│
└── src/
    ├── project2.qpf
    ├── project2.qsf
    │
    ├── system_top_level/
    │   ├── scpmod.bdf
    │   ├── scpmod.vhd
    │   ├── scp.bdf
    │   └── scp.vhd
    │
    ├── datapath_lifecycle_stages/
    │   ├── fetch.bdf
    │   ├── fetch.vhd
    │   ├── decode.bdf
    │   ├── decode.vhd
    │   ├── execute.bdf
    │   └── execute.vhd
    │
    └── hardware_submodules_and_primitives/
        ├── adder.vhd
        ├── addressdecoder.vhd
        ├── alu.vhd
        ├── busmux4to1.vhd
        ├── control.vhd
        ├── cpsr.vhd
        ├── dmem.vhd
        ├── extender.vhd
        ├── iRom.vhd
        ├── reg32.vhd
        ├── regn.vhd
        ├── regfile.vhd
        ├── rotator.vhd
        ├── seg7decode.vhd
        ├── shifter.vhd
        └── synchronizer.vhd
```

---

# Testing & Validation

## RTL Simulation

Verified using Quartus waveform simulations:

- Instruction fetch correctness
- Register write-back timing
- Branch target generation
- CPSR flag behavior
- Single-cycle execution timing

## System-Level Validation

Verified:

- MMIO routing
- Peripheral communication
- Motor control outputs
- Sensor sampling reliability
- Reset synchronization

## Physical Hardware Validation

Successfully demonstrated:

- Autonomous navigation
- Obstacle detection
- Real-time telemetry output
- Stable display operation
- Reliable FPGA deployment

---

# Learning Outcomes

This project provided experience with:

- Structural VHDL design
- Dataflow VHDL design
- Single-cycle CPU architecture
- Control unit implementation
- Register file design
- ARM assembly programming
- Memory-mapped I/O systems
- FPGA integration
- ALU flag generation
- Barrel shifter architecture
- Hardware debugging and validation

---

# Author

**Jesse Rost**

Course: CPE 1510 – Single-Cycle Processor Design Lab

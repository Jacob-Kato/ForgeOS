# ForgeCPU Architecture Reference

### System Specifications

* **Memory:** 64 locations (0-63).
* **Registers:** 2 general-purpose registers (`R0` and `R1`).
* **Program Counter (PC):** Tracks the current execution address.
* **Flag Register:** A single state flag used to store the result of the `COMP` (compare) instruction.
* **Instruction Format:** Instructions are structured as Python lists: `[Opcode, Arg1, Arg2, Mode]`. The length of the list adapts to the instruction being used.

> **Note on Opcodes:** The CPU reads opcodes visually structured as binary (e.g., `100`, `101`), but processes them natively as base-10 integers in Python. For example, `STORE` uses the integer `10`, not the binary value `0b010` (which would evaluate to `2`).
---
### Instruction Set Quick Reference

| Opcode | Mnemonic | Arguments (List Format) | Action |
| --- | --- | --- | --- |
| `0` | **LOAD (Imm)** | `[0, Reg, Value]` | Load an immediate value into a register. |
| `0` | **LOAD (Mem)** | `[0, Addr, Reg, 1]` | Load a value from memory into a register. |
| `1` | **ADD** | `[1, RegA, RegB]` | Add `RegB` to `RegA`, storing the result in `RegA`. |
| `10` | **STORE** | `[10, Reg, Addr]` | Store the value of a register into memory. |
| `11` | **COMP** | `[11, RegA, RegB]` | Compare two registers. Sets Flag to `True` if equal. |
| `100` | **JUMP** | `[100, Addr]` | Jump to memory address if Flag is `False` or `None`. |
| `101` | **HALT** | `[101]` | Stop execution. |

---

### Instruction Details

#### `LOAD` (Opcode: `0`)

Loads a value into a target register. The behavior changes depending on whether the `mode` argument is provided.

* **Immediate Mode (Load Value):** `[0, target_register, value]`
* *Effect:* Sets `target_register` to the provided integer `value`.
* *Example:* `[0, 0, 42]` sets `R0 = 42`.


* **Memory Mode (Load from Address):** `[0, source_address, target_register, 1]`
* *Effect:* Reads memory at `source_address` and stores it in `target_register`.
* *Example:* `[0, 15, 1, 1]` sets `R1 = memory[15]`.



#### `ADD` (Opcode: `1`)

Performs a bitwise addition of two registers.

* **Syntax:** `[1, target_register, source_register]`
* *Effect:* Adds the value of `source_register` to `target_register` and overwrites `target_register` with the sum.
* *Example:* `[1, 0, 1]` results in `R0 = R0 + R1`.



#### `STORE` (Opcode: `10`)

Saves a register's current value into memory.

* **Syntax:** `[10, source_register, target_address]`
* *Effect:* Writes the value of `source_register` into `memory[target_address]`.
* *Example:* `[10, 0, 63]` stores the value of `R0` into memory location `63`.



#### `COMP` (Opcode: `11`)

Compares the values of two registers to check for equality.

* **Syntax:** `[11, register_A, register_B]`
* *Effect:* If `register_A == register_B`, the internal Flag Register becomes `True`. Otherwise, it becomes `False`.
* *Example:* `[11, 0, 1]` compares `R0` and `R1`.



#### `JUMP` (Opcode: `100`)

A conditional "Jump If Not Equal" instruction.

* **Syntax:** `[100, target_address]`
* *Effect:* The CPU jumps to `target_address` **only if** the Flag Register is `False` or `None`. Once evaluated, the Flag Register is reset to `None`.
* *Note:* If executed without a preceding `COMP` instruction, this acts as an unconditional jump.
* *Example:* `[100, 5]` moves the Program Counter to address 5.



#### `HALT` (Opcode: `101`)

Terminates the program.

* **Syntax:** `[101]`
* *Effect:* Sets `self.halted = True`, stopping the execution loop safely.



---

### Example Program

Here is how a program looks when loaded into `ForgeCPU`. This program loads 5 into `R0`, 5 into `R1`, compares them, and halts.

```python
cpu = ForgeCPU()

program = [
    [0, 0, 5],     # Address 0: LOAD 5 into R0
    [0, 1, 5],     # Address 1: LOAD 5 into R1
    [11, 0, 1],    # Address 2: COMP R0 and R1 (Flag becomes True)
    [100, 10],     # Address 3: JUMP to 10 if Not Equal (Skipped because Flag is True)
    [101]          # Address 4: HALT
]

cpu.execute(program)

```


# ForgeCPU V0 Specification (Architecture Freeze)
---- 
# Goal

ForgeCPU V0 has exactly one purpose:

> Add two numbers and store the result.

Nothing more.

No loops.

No branches.

No subtraction.

No multiplication.

No stack.

No functions.

---

# Hardware

### Registers

Exactly **2** general-purpose registers.

```text
R0
R1
```

No others.

---

### Program Counter

Exactly one Program Counter.

Its only responsibility is remembering the address of the current instruction.

After every successful instruction:

```
PC = PC + 1
```

Until HALT.

No jumps exist yet.

---

### Memory

One flat memory space.

Memory stores:

* Instructions
* Data

There is no separation.

---

### ALU

Supports exactly one arithmetic operation:

```
ADD
```

Nothing else.

---

# Instruction Set

Exactly four instructions.

```
LOAD
ADD
STORE
HALT
```

---

# Instruction Behavior

## LOAD

Copies an immediate value into a register.

Example:

```
LOAD R0, 2
```

After execution:

```
R0 = 2
```

---

## ADD

```
ADD R0, R1
```

Means:

```
R0 = R0 + R1
```

R1 is unchanged.

---

## STORE

```
STORE R0, Address
```

Copies the contents of R0 into memory.

---

## HALT

Stops execution immediately.

---

# Execution Model

The CPU repeatedly performs:

```
Fetch

↓

Decode

↓

Execute

↓

Increment PC

↓

Repeat
```

Until HALT.

---

# CPU Philosophy

The CPU **never guesses**.

Every destination is explicit.

No hidden behavior.

No automatic register selection.

No automatic storing.

No automatic memory allocation.

---

# Error Handling

Invalid opcode:

```
STOP

Invalid Instruction
```

Nothing else.

---

# Reserved Features

These do **not** exist.

If you accidentally add them during implementation, remove them.

Branches

Stack

Function calls

Variables

Labels

Immediate arithmetic

Multiplication

Subtraction

Division

Interrupts

Caches

Pipelines

Multiple cores

Flags

Conditional execution

Floating point

---

# Python Constraints

I'm intentionally making these strict.

These are not to make your life difficult.

They're to force the architecture to stay visible.

### Constraint 1

Do **not** use Python's integer addition to implement the ALU.

When implementing `ADD`, use the logic-gate approach we derived earlier:

* XOR
* AND
* Carry propagation

In other words, build an adder, not `a + b`.

(We'll revisit whether to start with 8-bit or 16-bit values when you begin.)

---

### Constraint 2

The CPU must execute through an explicit **fetch → decode → execute** loop.

No shortcuts like "just run the program list."

---

### Constraint 3

Instructions should be represented as **machine instructions**, not Python function calls.

The emulator should feel like it's executing a CPU, not a Python program.

---

### Constraint 4

Every architectural component must have a corresponding implementation.

If the specification says there is a Program Counter, your emulator should have one.

If it says there are two registers, your emulator should have exactly two.

No hidden state.

---

### Constraint 5

The emulator must be debuggable.

After every instruction, you should be able to inspect:

* Program Counter
* R0
* R1
* Current instruction
* Memory (or at least the modified parts)

If something goes wrong, we want to be able to "pause the CPU" and inspect its state.

---

### Constraint 6

Do not optimize.

Make the code read like hardware.


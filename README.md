# ForgeOS

A hobby operating system written completely from scratch.

## Goals

- Learn x86-64 architecture
- Write my own assembler
- Write my own compiler
- Write my own bootloader
- Write my own kernel
- Eventually become self-hosting
--- 

## Target Hardware

- Samsung XE310XBA-K01US
- Intel Celeron N4000
- 4 GB RAM
- 32 GB eMMC

---

# ForgeOS v0 Initial Prototype 

- Booted under UEFI
- Exited boot services
- Tested CPU exception with div by zero
- was not debugged to verify if div zero was caught

# ForgeOS V0.1.0 -Interrupt structure

Status: In Development 

## New Features
- Implemented a 256-entry Interrupt Descriptor Table (IDT)
- Added assembly-generated ISR stub table
- Added C-based `idt_set_gate()` implementation
- Added `idt_init()` to populate every IDT entry
- Connected C kernel initialization with assembly startup
- Added IDTR descriptor and `lidt`
- Established QEMU + GDB debugging workflow
- Kernel now transitions:
  UEFI → efi_main → _start → kernel_main

### Current Goal
Verify that CPU exceptions correctly dispatch through the IDT into the ISR common stub.






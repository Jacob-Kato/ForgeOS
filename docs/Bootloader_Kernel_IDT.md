# Bootloader to Kernel IDT
--- 
## CPU State Transitions (cli vs sti)
* cli is **clear Interrupts** this disables the 
  CPU's ability to hear hardware signals
  * Usage in Bootloader: used right after **ExitBootServices**
    This prevents the CPU from attempting to handle Interrupts
    using UEFI functions that don't exist in memory
--- 
* sti **set Interrupts** opens the CPU to hearing 
  hardware signals.
    * Usage in the Kernel can ONLY BE executed after the Interrupt
      **Descriptor Table(IDT)** is fully mapped and loaded into the CPU
      via lidt.Loading sti before lidt causes a Triple Fault
--- 
## Memory Sections(.bss vs .data)
* **.data** Initialized data. Takes up physical disk space inside 
  the compiled binary file. Used for pre-calculated hardcoded 
  variables and structures
    * **Example** the 16 byte IDT Gate Descriptors
      and it has to be built here by using dw and
      dd keywords
--- 
* **.bss**(Block Started by symbol) this takes up no physical
  disk space in the binary
  Acts as a blueprint instruction to the bootloader/OS to
  reserve empty,zeroed-out RAM at runtime
    * **Example** reserving 4096 bytes for the mem_map_buffer
---   
## The Calling Conventions
* my efi_main allocates space using sub rsp, 48 to meet shadow 
  space and alignment rules before calling UEFI functions. Your 
  div_error_handler utilizes the save_state macro to push 15 
  registers directly to the stack.
* **Question**: When the CPU hardware jumps to div_error_handler during 
  a math fault, why are you completely ignoring Microsoft's 32-byte
  shadow space rule before pushing your 15 registers to   the stack?
--- 
## The Bitwise Scissors
* Your IDT table calculates a middle address segment using dw 
  ((div_error_handler >> 16) & 0xFFFF).
  In boot.nasm, you declare DEFAULT REL to ensure the code can
  run regardless of where UEFI loads it into memory.

* **Question**: If UEFI dynamically loads your kernel such that 
div_error_handler ends up at the physical RAM address 0x0000000100205000,
what exact hexadecimal value gets calculated and permanently stored 
inside that specific dw slot?
--- 
## The Three Halts
* Your bootloader utilizes a halt loop with hlt and jmp halt.
  Your kernel contains a .main_loop with hlt and jmp .main_loop.
  Your divide error handler contains a .panic loop with hlt and jmp .panic.

* Question: While the assembly instructions are identical, the CPU's physical
  capability to escape these loops is entirely different. What is the difference
  in the CPU's ability to escape the kernel's .main_loop versus the handler's .panic loop?

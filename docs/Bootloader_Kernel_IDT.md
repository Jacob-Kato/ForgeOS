# Bootloader to Kernel IDT
--- 
## CPU State Transitions (cli vs sti)
* cli is **clear Interrupts** this disables the 
  CPU's ability to hear hardware signals
  * Usage in Bootloader: used right after **ExitBootServices**
    This prevents the CPU from attempting to handle Interrupts
    using UEFI functions that don't exist in memory

* sti **set Interrupts** opens the CPU to hearing 
  hardware signals.
    * Usage in the Kernel can ONLY BE executed after the Interrupt
      **Descriptor Table(IDT)** is fully mapped and loaded into the CPU
      via lidt.Loading sti before lidt causes a Triple Fault




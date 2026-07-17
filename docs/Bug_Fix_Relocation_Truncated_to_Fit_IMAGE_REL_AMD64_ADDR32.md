## The Error
* When attempting to link the boot.o and kernel.o 
  object files into the final BOOTX64.EFI executable using GNU ld, 
  the build failed with the following architectural errors:
  Plaintext
--- 
kernel.o:kernel/kernel.nasm:(.text+0xe): relocation truncated to fit: IMAGE_REL_AMD64_ADDR32 against `.data'
kernel.o:kernel/kernel.nasm:(.text+0x1a): relocation truncated to fit: IMAGE_REL_AMD64_ADDR32 against `.data'
kernel.o:kernel/kernel.nasm:(.text+0x25): relocation truncated to fit: IMAGE_REL_AMD64_ADDR32 against `.data'
kernel.o:kernel/kernel.nasm:(.text+0x2d): relocation truncated to fit: IMAGE_REL_AMD64_ADDR32 against `.data'
--- 

## The Root Cause
* This error is caused by an architectural mismatch 
  between the NASM assembler and the 64-bit GNU linker.
  Because UEFI firmware can load the operating system 
  anywhere in physical RAM, the generated executable 
  must be entirely Position Independent. Without explicit 
  directives, NASM defaults to generating 32-bit absolute
  memory addresses for variable references.
  When the 64-bit GNU linker attempted to link these 32-bit
  absolute addresses into a 64-bit (AMD64) position-independent
  executable, it realized the 32-bit addresses were not large enough
  to safely map the memory space. The linker forcefully truncated
  the addresses and threw the IMAGE_REL_AMD64_ADDR32 error to prevent
  a memory corruption crash.
## The Solution
1. Enforce 64-bit Relative Addressing in the Assembler
  The NASM file containing the errors (kernel.nasm) was 
  missing the directives required to enforce 64-bit
  compilation and RIP-relative addressing. These were added to the absolute top of the file:
--- 
Code snippet
BITS 64
DEFAULT REL
--- 

2. Use Load Effective Address (LEA) for Position-Independent Pointers
Because the memory addresses are now relative rather than absolute, 
standard mov instructions can no longer be used to grab the address 
of a function or label. The code was updated to use lea (Load Effective Address) 
to dynamically calculate the position-independent pointer at runtime.

Before (Caused the truncation error):
Code snippet

mov rax, div_error_handler

After (Position-independent fix):
Code snippet

lea rax, [div_error_handler]

Recompiling with make after these changes resulted in a clean, error-free BOOTX64.EFI build.

ps - this almost made me give up : / (i love this )

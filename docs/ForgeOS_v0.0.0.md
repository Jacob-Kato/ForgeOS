# ForgeOS v0.0.0 Developer Journal

### Pointers

* Before you do anything find out if you are going to be booting
  in UEFI or BIOS that is very important don't be like me and just 
  dive in 

* Now that you have picked UEFI because I see no reason to pick BIOS.
  so how do you have UEFI boot your Kernel.

### Understanding UEFI

* UEFI(Unified Extensible Firmware Interface) this is the worker 
  that wakes up when you press the power button It initializes the
  hardware,performs platform checks, and eventually transfers control
  to an EFIapplication such as a bootloader.


### ------------     ----------- 
### |          |     |         |
### |   UEFI   | >>> |   OS    |
### |          |     |         |
### ------------     -----------


### How to escape the grasp of UEFI 

* Okay UEFI gives use function to use to escape are they easy to use 
  of course not first when calling a function you always have to 
  allocate exactly 48 bytes of empty space on the stack to guarantee
  that the 32 byte shadow space and 16 byte alignment rules are met 

  (`mov rbp,rsp`)
  (`sub rsp,48`)

* But you have to use **REL** (Relative addressing) because UEFI puts
  you in a random place in memory so if you hard code your address 
  then UEFI wont be able to find it 

  (`DEFAULT REL`)

#### now you have to get the Key to exit boot services

* you do this telling UEFI how big the buffer is.
  Then you give UEFI the buffer where its going
  write the memory map.
  Then you find where UEFI will drop the Key/password.
  Now these are all going to be address that you have to
  move to registers like **rcx,rdx,r8,r9,rax**.Before
  calling OFFSET_GET_MEMORY_MAP + rsi this will bulid the memory
  map if its successful than you move the img_handle to rcx and
  move mem_map_kay to rdx than call OFFSET_EXIT_BOOT_SERV + rsi 
  to exit the boot services

* and your .data and .bss section should look like this because
  These offsets correspond to fields in the UEFI System Table 
  and Boot Services structures defined by the UEFI specification.
  They allow the bootloader to call firmware functions such as
  GetMemoryMap() and ExitBootServices().

(`section .data`)
  (`OFFSET_BOOT_SERVICES equ 96`)
  (`OFFSET_GET_MEMORY_MAP equ 56`)
  (`OFFSET_EXIT_BOOT_SERV equ 24`) 

(`section .bss`)
(`img_handle     resq 1`)
(`sys_table      resq 1`)
(`boot_services  resq 1`)
(`mem_map_size   resq 1`)
(`mem_map_key    resq 1`)
(`mem_descr_size resq 1`)
(`mem_descr_ver  resq 1`)
(`mem_map_buffer resq 4096`)

## Lessons Learned

- Decide whether your operating system will boot with BIOS or UEFI before
  writing any code. They have completely different boot processes.

- UEFI applications must follow the Microsoft x64 calling convention,
  including 32 bytes of shadow space and 16-byte stack alignment.

- Always use RIP-relative addressing (`DEFAULT REL`). UEFI can load your
  program at different addresses each boot.

- Don't assume code works just because it compiles. Learn to use GDB and
  verify each stage of the boot process.
  
### What Went Wrong

When i would boot from my usb i got a (`Failed: Out of Resoures`) bug 
first i thought it was my linker so i made that more specific and
made sure that it would pack everything in my 4096 MB than that didn't
work so i thought that maybe there was something making it so that it went over the 4096 MB space. 

I almost quit but than i was looking at my Kernel file and i realized that i forgot the (`DEFAULT REL`) at the top 
i was so focused on the boot file that i never checked the Kernel file.

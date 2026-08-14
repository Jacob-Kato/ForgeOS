# Verify the Interrupt Stack-Frame Contract

I am going to walk through a divide-by-zero interrupt and map out the
stack frame as I go.

------------------------------------------------------------------------

## 1. The Interrupt

When an interrupt happens, it calls the ISR. For this example, we are
using divide by zero, so it calls the `ISR_NOERRCODE` macro, which is
for interrupts that don't have an error code.

------------------------------------------------------------------------

## 2. CPU Push and Program Push

  CPU      PROGRAM
  -------- ------------
  SS       ERROR_CODE
  RSP      Vector
  RFLAGS   
  CS       
  RIP      

The stack would look like this:

``` text
High addresses

[[ Vector     ]]  ← last push from ISR_NOERRCODE
sometime the cpu pushes the error code 
     VV
[[ ERROR_CODE ]]
[[ RIP        ]]
[[ CS         ]]
[[ RFLAGS     ]]
[[ RSP        ]]
[[ SS         ]]  ← first push
[[ start here ]]

Low memory addresses
```

Then we jump to `isr_common_stub` and call a macro that pushes 15
general-purpose registers.

We have to keep in mind that we need to stay **16-byte aligned** to meet
the Windows calling conventions.

### Stack Size So Far

CPU + `ISR_NOERRCODE` pushes:

``` text
5 + 2 × 8
```

Then, when we jump to the common stub, we push 15 registers on top of
that. So now:

``` text
7 + 15 × 8
```

------------------------------------------------------------------------

## 3. Pushing CR2

After pushing the 15 registers, we need to add `CR2` to the stack.

We copy `CR2` to `RAX` and push `RAX`. Now `CR2` is the latest thing we
pushed, so the very top and very bottom of the stack look like this:

``` text
------------
Latest push

[[ CR2        ]]
[[ RAX        ]]
[[ RBX        ]]
[[ RCX        ]]
[[ RDX        ]]
[[ ...        ]]
[[ ...        ]]
[[ ...        ]]
[[ Vector     ]]
[[ ERROR_CODE ]]
[[ RIP        ]]
[[ CS         ]]
[[ RFLAGS     ]]
[[ RSP        ]]
[[ SS         ]]
[[ start here ]]

Oldest push
------------
```

## 4. Total Stack Size

In total, this is **184 bytes** of memory.

It is aligned because:

``` text
7(from the ISR_NOERRCODE + CPU) + 16(Macro + cr2 ) * 8 = 184
184 % 16= 8 
```
## 5. ADD the 32 
now we need to call the exception_handler

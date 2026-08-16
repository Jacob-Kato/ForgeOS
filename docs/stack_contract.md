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
  RIP      ERROR_CODE
  CS       Vector
  RFLAGS   
      

The stack would look like this:

``` text
High addresses

[[ Vector     ]]  ← last push from ISR_NOERRCODE
sometime the cpu pushes the error code 
     VV
[[ ERROR_CODE ]]
[[ RIP        ]]
[[ CS         ]]
[[ RFLAGS     ]]  ← first push
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
(3 + 2) × 8 = 40
```

Then, when we jump to the common stub, we push 15 registers on top of
that. So now:

``` text
(5 + 15) × 8 = 160
```

------------------------------------------------------------------------

## 3. Pushing CR2

After pushing the 15 registers, we need to add `CR2` to the stack.

We copy `CR2` to `RAX` and push `RAX`. Now `CR2` is the latest thing we
pushed, so the very top and very bottom of the stack look like this:

``` text
------------
Latest push

[[ CR2        ]] -| 
[[ RAX        ]]  |
[[ RBX        ]]  |> PUSHA + cr2
[[ RCX        ]]  |
[[ RDX        ]] -|
[[ ...        ]]
[[ ...        ]]
[[ ...        ]] 
[[ Vector     ]] -|
[[ ERROR_CODE ]]  |
[[ RIP        ]]  |> CPU + ISR 
[[ CS         ]]  |
[[ RFLAGS     ]] -|
[[ start here ]]

Oldest push
------------
```

## 4. Total Stack Size

In total, this is **168 bytes** of memory.

``` text
(5(from the ISR_NOERRCODE + CPU) + 15(Macro + cr2 ) + 1(cr2 push)) * 8 = 168
168 % 16 = 8 
```
## 5. ADD the 32 bytes of shadow space + the 8 bytes padding
--------------------- 
------------ 

Now we need to call the exception_handler
but we need to be 16 bytes aligned and we need 32 bytes of shadow space
we are not 16 bytes aligned 

```text
Alignment Math 

Init RSP:
  RSP % 16 = 0

Exception:
  168 bytes
  RSP % 16 = 8
If 32:
  32 % 16 = 0
  8-0=8
  you take the remainder of the current
  stack and subtract it to get the alignment

If 40:
   40 % 16 = 8
  8-8 = 0
  now we are aligned
```
```

```
```


```
```
```

### Total Stack Size

```text
168 + 40 = 208
208  % 16 = 0

```
## 6. The Return

when we exit from the function before calling iretq
we need to remove the 32 shadow + the 8 bytes padding bytes to get back to  cr2 then add call 
the pop macro then skip the error code and Vector


```

```

```
```

# Verify the Interrupt stack-frame contract

I am going to be walking through a div by zero Interrupt and map out the frame as i go.

--- 
## 1. The Interrupt

when a Interrupt happens it call the isr for this example we are using div by zero so it call the ISR_NOERRCODE macro which is for Interrupt that don't have a error code.

---
## 2. CPU PUSH and Program push

| CPU   | PROGEAM |
| -------------- | --------------- |
| SS     | Item2.1 |
| RSP    | Item2.2 |
| RFLAGS | Item2.3 |
| CS     |


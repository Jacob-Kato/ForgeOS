# How I handle exception

## Divide by zero 
When a divide by zero error happends
i just halt the system and write all the registers to COM 1

## Invalid Opcode
When a invalid Opcode error happends
i first find out if it was intentional
or not if it was i write to the COM1 that 
it was a intentional error and i write all the
registers as well


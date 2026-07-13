.org 0x7C00
; this tells the assembler to start calculating all memory offset at x7C00

bits 16 ;this outputs 16-bit instructions from the code 

; i found that the processor will always think its in 16 bit mode 

main: ; this is a loop that stops the cpu from going any further

  hlt ;does this by halting the program but it only halts until the next

  ; interrupt but i need to make sure the program stays halted 
  
  ; that we have the label halt that has one instructions to jump back to it self 

.halt:

  jmp .halt

;this is where we add the 0AA55h sign for the UEFI 
;the desk i'm using is 512 so we want to place the sign in the last two bytes
time 510-($-$$) db 0 ;this $-$$ gives use the size of our program 

;if we take 510 - $-$$ we get the last two bytes in the program

dw 0AA55h 

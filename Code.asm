; -----------------------------------------------------------------------------------------
; -----------------------------------------------------------------------------------------
; Text Section.

section	.text

global _start       ;must be declared for using gcc

; -----------------------------------------------------------------------------------------
; Main
; BRYAN
_start:                     ; Think main
    
    mov     eax, msg        ; put message into eax
    call    sprtln          ; invoke strprtln, print message with new line
    
    mov     edx, 255        ; number of bytes to read
    mov     ecx, sinput     ; reserved space to store input
    mov     ebx, 0          ; file: stdin
    mov     eax, 3          ; system call number (sys_read)
    int     0x80            ; call kernel
    
    mov     eax, msg1_1     ; move msg1_1 into sprt argument (eax)
    call    sprt            ; call sprt
    mov     eax, sinput     ; move input into atoi argument (eax)
    call    atoi            ; call atoi (turn argument into integer)
    push    eax             ; preserve value of eax on the stack (save the limit)
    call    iprt            ; print the argument
    mov     eax, msg1_2     ; move msg1_2 into sprtln argument (eax)
    call    sprtln          ; call sprt
    
    mov     ecx, 0          ; counter

nextnumber:
    inc     ecx             ; increment our counter variable
    
.checkfizz:
    mov     edx, 0          ; clear the edx register, holds remainder after division
    mov     eax, ecx        ; mov the value of the counter into eax for division
    mov     ebx, 3          ; the number to divide in ebx
    div     ebx             ; divide eax by ebx (3)
    mov     edi, edx        ; mov remainder in edx into edi
    cmp     edi, 0          ; see if the remainder is zero
    jne     .checkbuzz      ; if the remainder is not equal to zero, jump to local label buzz
    mov     eax, fizz       ; else move the address of fizz string into eax for print
    call    sprt            ; call string printing function

.checkbuzz:
    mov     edx, 0          ; clear the edx register, holds remainder after division
    mov     eax, ecx        ; move the value of our counter into eax for division
    mov     ebx, 5          ; the number to divide in ebx
    div     ebx             ; divide eax by ebx (5)
    mov     esi, edx        ; move the remainder into esi
    cmp     esi, 0          ; see if the remainder is zero
    jne     .checkint       ; if the remainder is not equal to zero, mov to checkint
    mov     eax, buzz       ; put address of buzz string into eax
    call    sprt            ; call string printing function

.checkint:
    cmp     edi, 0          ; edi contains remainder (3)
    je      .continue       ; counter divides by 3 jump to continue
    cmp     esi, 0          ; esi contains remainder (5)
    je      .continue       ; counter divides by 5 jump to continue
    mov     eax, ecx        ; mov integer into eax
    call    iprt            ; call integer print

.continue:
    mov     eax, 0Ah        ; move ascii newline character into eax
    push    eax             ; push newline eax onto the stack
    mov     eax, esp        ; get stack pointer into arguments
    call    sprt            ; call sprint with newline
    pop     eax             ; pop stack pointer newline (get rid of)
    pop     eax             ; pop stack pointer of max
    cmp     ecx, eax        ; compare the counter to max
    push    eax             ; put max back on the stack
    jne     nextnumber      ; if not equal continue
    
    call    quit            ; exit program

; -----------------------------------------------------------------------------------------
; Utility functions.

; void exit             exit program
quit:
    mov     ebx, 0          ; return 0 status on exit - 'no errors'
    mov     eax, 1          ; system call number (sys_exit)
    int     0x80            ; call kernel
    ret

; int strlen            calculates the length of a string
; arg (ebx) msg         the string we want to calculate the length of
; ret (eax) strlen      returns length of string into eax address
; NAV
slen:
    push    ebx             ; Push the value of ebx onto the stack to preserve it
    mov     ebx, eax        ; move the address of eax into ebx

.nextchar:
    cmp     byte [eax], 0   ; compare byte pointed to by eax with zero (end of string delimeter)
    jz      .finished        ; if the comparison is not true, continue
    inc     eax             ; length increment
    jmp     .nextchar        ; loop back to this label
    
.finished:
    sub     eax, ebx        ; eax is at the end of the string now, subtract ebx (at start) to get                        ; segment count
    pop     ebx             ; pop the value from the stack back onto ebx
    ret                     ; return to where the function was called

; void sprt             prints a string to the terminal
; arg (eax) msg         the data string we want to print
; NAV
sprt:
    push    edx             ; preserve data in ebx
    push    ecx             ; preserve data in ecx
    push    ebx             ; preserve data in eax
    push    eax             ; push argument onto stack
    call    slen            ; invoke string length function call
    mov     edx, eax        ; put the length argument in
    pop     eax             ; get the argument back
    mov     ecx, eax        ; move data message
    mov     ebx, 1          ; File: stdout
    mov     eax, 4          ; system call number (sys_write)
    int     0x80            ; call kernel
    pop     ebx             ; retrieve ebx from the stack
    pop     ecx             ; retrieve ecx from the stack
    pop     edx             ; retrieve edx from the stack
    ret                     ; return to last point of execution

; void sprtln           prints a string to the terminal with new line
; arg (eax) msg         the message string we want to print
; NAV
sprtln:
    call    sprt            ; print message in arguments
    push    eax             ; Preserve eax on the stack
    mov     eax, 0Ah        ; move new line character (linefeed)
    push    eax             ; push linefeed onto stack so we can get the address
    mov     eax, esp        ; move the address of the current stack pointer into eax for printing
    call    sprt            ; print new line
    pop     eax             ; remove linefeed from stack
    pop     eax             ; restore original value of eax
    ret                     ; return to last point of execution

; void iprt             prints an integer to the terminal
; arg (eax) integer     the integer we want to print
; WILL
iprt:
    push    eax             ; preserve data in eax
    push    ecx             ; preserve data in ecx
    push    edx             ; preserve data in edx
    push    esi             ; preserve data in esi
    mov     ecx, 0          ; counter of how many bytes we need

.divideloop:
    inc     ecx             ; Increment byte counter
    mov     edx, 0          ; empty edx
    mov     esi, 10         ; mov 10 into esi
    idiv    esi             ; divide eax by esi
    add     edx, 48         ; convert the remainder stored in edx to ascii representation
    push    edx             ; push string representation of integer to stack
    cmp     eax, 0          ; check if there are digits
    jnz     .divideloop      ; continue to convert digits

.printloop:
    dec     ecx             ; count each byte to print
    mov     eax, esp        ; mov the stack pointer (esp) into eax for printing
    call    sprt            ; print the integer string representation in eax
    pop     eax             ; remove last character from the stack
    cmp     ecx, 0          ; check if there are digits
    jnz     .printloop       ; print other digits
    
    pop     esi             ; retrieve esi from the stack
    pop     edx             ; retrieve edx from the stack
    pop     ecx             ; retrieve exc from the stack
    pop     eax             ; retrieve eax from the stack
    ret

; void iprtln           prints an integer to the terminal with newline
; arg (eax) integer     the integer we want to print
; WILL
iprtln:
    call    iprt            ; call integer print function
    push    eax             ; preserve data in eax
    mov     eax, 0Ah        ; move newline into eax
    push    eax             ; store newline on the stack
    mov     eax, esp        ; move the address of the stack pointer into eax
    call    sprt            ; call sprint with the newline
    pop     eax             ; remove newline character from the stack
    pop     eax             ; restore eax from the stack
    ret

; int atoi              turns a string into an integer
; arg (eax) string     the string we want as an integer
; WILL
atoi:
    push    ebx             ; preserve data in ebx
    push    ecx             ; preserve data in ecx
    push    edx             ; preserve data in edx
    push    esi             ; preserve data in esi
    mov     esi, eax        ; mov address of eax into esi
    mov     eax, 0          ; initialise eax with decimal val 0
    mov     ecx, 0          ; initialise ecx with decimal val 0

.multiplyloop:
    xor     ebx, ebx        ; resets upper and lower bytes to be zero
    mov     bl, [esi+ecx]   ; move a signle byte into ebx register lower half
    cmp     bl, 48          ; compare ebx lower half value against ascii value of 1
    jl      .finished        ; jump if less than ascii value of 1 to finished
    cmp     bl, 57          ; compare ebx lower half value against ascii value of 9
    jg      .finished        ; jump if greater than ascii value of 9 to finished
    
    sub     bl, 48          ; turn the ascii into an integer
    add     eax, ebx        ; add the converted digit to eax
    mov     ebx, 10         ; mov decimal value of 10 into ebx
    mul     ebx             ; multiply eax by ebx to get place value
    inc     ecx             ; increment our counter register
    jmp     .multiplyloop    ; continue for other digits
    
.finished:
    cmp     ecx, 0          ; compare ecx register's value against decimal 0
    je      .restore         ; jump if equal to zero (no arguments)
    mov     ebx, 10         ; move decimal value of 10 into ebx
    div     ebx             ; divide eax by value in ebx

.restore:        
    pop     esi             ; restore esi from the stack
    pop     edx             ; restore edx from the stack
    pop     ecx             ; restore ecx from the stack
    pop     ebx             ; restore ebx from the stack
    ret

; -----------------------------------------------------------------------------------------
; -----------------------------------------------------------------------------------------
; Data section.
; NAV

section	.data

msg	    db	'Print fizzbuzz for how many numbers: ', 0h
msg1_1      db  'Printing fizzbuzz for ', 0h
msg1_2      db  ' numbers', 0h
fizz        db 'fizz', 0h
buzz        db 'buzz', 0h
fizzbuzz    db 'fizzbuzz', 0h

; -----------------------------------------------------------------------------------------
; -----------------------------------------------------------------------------------------
; BSS section.
; NAV

section .bss

sinput:     resb    255                         ; reserve 255 bytes in memory

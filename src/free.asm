; NOTE:
;
; if 0x80000000 & val is not 0, then is free
; else is used

section .text

global allocator_free

; rdi: unit pointer
; rsi: ptr to free
allocator_free:
  xor rax, rax         ; clear rax
  mov eax, [rdi]       ; get size of memory area in eax
  mov rbx, [rdi+8]     ; get in rbx memory pointer
  mov rcx, rsi         ; get in rcx the pointer to free
  ; eax and rbx are const
  ; rcx is ponter

  sub rcx, 4           ; set rcx to the header pointer
  mov edx, [rcx]       ; load in edx the header

  ; check if allready free (double free protection promise ;-) )
  mov edi, 0x80000000  ; load in edi bitmask to check if free
  and edi, edx         ; extract into edx if free or not
  cmp edi, 0           ; compare with 0
  je .L1               ; if is 0, then it needs to get free

  ; else we need to do nothing and can return here
  xor rax, rax
  ret

.L1:
  ; free now our pointer
  mov esi, 0x80000000  ; load in esi bitmask to make it free
  or esi, edx          ; set in esi the header with free bit set

  ; call here now allocator_merge_free
  xor rdi, rdi         ; clear rdi
  mov edi, esi         ; set rdi to first header
  mov rsi, rcx         ; set rsi to the pointer to free (at header position)

  xor rdx, rdx         ; clear rdx
  mov edx, eax         ; get size of memory area in edx
  add rdx, rbx         ; make rdx to pointer at the end of the allocation unit

  ; have now following calling configuration:
  ; rdi: header (isn't jet stored)
  ; rsi: the pointer to the header (rdi must be stored there in by callee)
  ; rdx: pointer to the end of the allocation unit
  call allocator_merge_free    ; call to check if can merge this block
                               ; and the next
  xor rax, rax         ; clear return value
  ret                  ; return to caller

global allocator_merge_free

; edi: the header
; rsi: pointer to store first header
; rdx: pointer to the end of allocation unit
allocator_merge_free:
  ; free registers:
  ; rax, rbx, rcx
  xor rax, rax         ; clear rax
  mov eax, 0x7FFFFFFF  ; set rax to bitmask to clear unused bit
  and eax, edi         ; get in eax absolute value of length of block
  add rax, 4           ; set rax to the length to skip to the next header
  add rax, rsi         ; set rax to the address to the next header

  cmp rax, rdx         ; compare the pointer to the (maybe) next header
  jl .L2               ; if is in the memory block, we can proceed

  ; if we break up
.L1:
  mov [rsi], edi       ; store header in rsi
  xor rax, rax         ; clear rax
  ret                  ; return to caller

.L2:
  ; if we get here, check if next header is free or not
  ; rax is pointer set to the header we are checking now if allocated
  mov ebx, 0x80000000  ; set bitmask to check if used or not
  mov ecx, [rax]       ; get in ecx the second header
  and ebx, ecx         ; extract in ebx the flag if used or not
  cmp ebx, 0           ; check if ebx is 0
  je .L1               ; if is 0, then it is used and we break up

  ; now set in edi the new size
  and edi, 0x7FFFFFFF  ; clear in edi flag
  and ecx, 0x7FFFFFFF  ; clear in ecx flag
  add edi, ecx         ; set in edi the sum of both blocks
  add edi, 4           ; add aswell the second header (not used anymore)
  or edi, 0x80000000   ; set unused flag
  mov [rsi], edi       ; store in rsi the header
  xor rax, rax         ; clear rax
  ret
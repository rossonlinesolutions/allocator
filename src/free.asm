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

global allocator_check_free

; rdi: unit pointer
allocator_check_free:
  push rbp             ; store stack base
  mov rbp, rsp         ; set stack base to stack pointer

  mov eax, [rdi]       ; get in eax total size
  sub eax, 4           ; set expected header length in eax
  mov ebx, eax         ; save eax in ebx
  or eax, 0x80000000   ; set free flag in eax
  push rax             ; store expected header in eax
  push 0               ; reserve stack to store in .L1 before-after headers
  mov rcx, [rdi+8]     ; get in rcx the memory block address
  push rdi             ; push on [rbp-24] the unit pointer
  mov ecx, [rcx]       ; get in ecx the first header

  ; first check if base is used, since if yes, no sense to keep searching
  mov edx, 0x80000000  ; get in edx bitmask to check if used
  and edx, ecx         ; get in edx the flag
  cmp edx, 0           ; check if edx is 0
  jne .Lstart          ; if is not null, we can continue

.Lfail:
  ; else return
  xor rax, rax         ; clear rax (0 as used)

  mov rsp, rbp         ; restore rsp
  pop rbp              ; load rbp
  ret                  ; return to caller

  ; if we get here, we try to merge blocks until we get the size in 
.Lstart:
  mov eax, [rbp-8]     ; load in eax expected header
  mov rbx, [rbp-24]    ; load in rbx unit pointer
  mov rbx, [rbx+8]     ; load in ebx current header
  mov ebx, [rbx]       ; get current header in ebx
  cmp eax, ebx         ; compare current header with new header
  jne .L1              ; if not equals, try to merge blocks

  mov rax, 1           ; if we get here, all success
  mov rsp, rbp         ; restore rsp
  pop rbp              ; load rbp
  ret                  ; return to caller

  ; if get here, try to merge blocks
.L1:
  mov [rbp-16], ebx    ; save current header from ebx

  ; prepare to call allocator_merge_free
  mov edi, ebx         ; 1. parameter: the current header

  mov rsi, [rbp-24]    ; get in rsi unit structure
  mov rdx, [rsi]       ; set in rdx the size of the memory block
  mov rsi, [rsi+8]     ; 2. parameter get in rsi the pointer to memory block
  add rdx, rsi         ; 3. parameter get in rdx pointer to end of block
  call allocator_merge_free ; try merging thoose blocks

  mov rsi, [rbp-24]    ; get in rsi unit structure
  mov rsi, [rsi+8]     ; get in rsi memory block pointer
  mov esi, [rsi]       ; get in esi the current header
  mov eax, [rbp-16]    ; load in eax the previous header
  cmp eax, esi         ; compare both headers
  je .Lfail            ; if are equals, nothing changed and no sense to continue

  jmp .Lstart          ; otherwise, return to loop start with check if ready



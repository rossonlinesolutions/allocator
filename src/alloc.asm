; NOTE:
;
; if 0x80000000 & val is not 0, then is free
; else is used
section .text

global allocator_alloc

; rdi: unit pointer
; rsi: size
allocator_alloc:
  xor rax, rax         ; clear rax
  mov eax, [rdi]       ; get size of memory area in eax
  mov rbx, [rdi+8]     ; get in rbx memory pointer
  mov ecx, esi         ; get allocation size in ebx
  mov rdx, rbx         ; set current searching pointer
  ; rax, rbx and rcx are const
  ; rdx is reserved as pointer counter

  ; rdi and rsi are used as temp registers now
  xor rsi, rsi         ; clear rsi
  xor rdi, rdi         ; clear rdi

.Lstart:
  mov rdi, rbx         ; set memory pointer in rdi
  add rdi, rax         ; set the limit of memory area in rdi
  cmp rdx, rdi         ; compare searching address with limit
  jl .L1               ; if is lower, continue in next

  ; if get here, nothing is found
  mov rax, 0
  ret

.L1:
  mov esi, [rdx]      ; get the header for the next block
  mov edi, 0x80000000 ; set bitmask to check if region is used
  and edi, esi        ; extract bit if is used
  cmp edi, 0          ; check it
  jne .L2             ; if is not null, make futher checks

.Lback:
  and esi, 0x7FFFFFFF ; get the absolute value in esi, without flag
  add rdx, 4          ; jump over the header in the current searching pointer
  add rdx, rsi        ; add the size of the memory block to the serching pointer
  jmp .Lstart         ; continue searching at the beginning of the loop

.L2:
  ; still have in esi the header for the block
  mov edi, 0x7FFFFFFF ; set absolute value mask in edi
  and edi, esi        ; get absolute value in edi
  cmp edi, eax        ; compare block size with required size
  jl .Lback           ; if the block is lower than the required size, prepare to get back

  ; have now:
  ; esi: block header
  ; edi: block size
  mov esi, edi        ; set the block header to the block size
  ;sub esi, 4          ; remove the next header size
  sub esi, eax        ; subtract absolute size with the required size

  mov [rdx], eax      ; set the new header

  cmp esi, 4          ; compare esi with 4
  jl .L3              ; don't create next header if not enough space

  add esi, eax
  mov [rdx], esi      ; in this case, set rdx to current block size

  ; and return
  mov rax, rdx        ; set return value to current pointer
  add rax, 4          ; skip header
  ret                 ; return to caller

.L3:
  ; divide header now here
  sub esi, 4          ; see uncommented instruction
  add rax, 4          ; add to block size the header
  add rax, rdx        ; set rax to the pointer to the new header
  or esi, 0x80000000  ; set free flag to new header
  mov [rax], esi      ; insert new header for the new created block after the one we will use

  mov rax, rdx        ; set as return value the current pointer
  add rax, 4          ; skip the header
  ret                 ; return to caller


; NOTE:
;
; if 0x80000000 & val is not 0, then is free
; else is used

section .text

global allocator_init

allocator_init:
  ; first prepare the header
  mov eax, [rdi]        ; get unit.size member
  sub eax, 4            ; subtract unit.size by the size of the header
  or eax, 0x80000000    ; set MSB to indicate area is free

  mov rbx, [rdi+4]      ; get the unit.ptr member
  mov [rbx], eax        ; set header at the pointer beginning
  ret                   ; return to caller
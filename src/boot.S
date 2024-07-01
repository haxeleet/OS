.section ".text.boot"

.globl _start

_start:
  // using only one core
  mrs   x0, mpidr_el1
  and   x0, x0, #0xFF
  cbz   x0, entry
  b loop

loop:
  b     loop

entry:
  // set stack
  ldr   x5, =_start
  mov   sp, x5

  // clear bss
  ldr   x5, =__bss_start
  ldr   w5, =__bss_size
1:cbz   w6, 2f
  str   xzr, [x5], #8
  sub   w6, w6, #1
  cbnz  w6, 1b

  // go to C kernel
  mov   x2, 0x100
2:bl    kernel_main

halt:
  wfe
  b halt

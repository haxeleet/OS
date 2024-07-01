#include "sysregs.h"

.section ".text.boot"

.globl _start

_start:
  // using only one core
  mrs   x0, mpidr_el1
  and   x0, x0, #0xFF
  cbz   x0, entry
  b halt

entry:
  // check current el
  mrs x0, CurrentEL
  lsr x0, x0, #2
  cmp x0, #3
  bne el2_entry

el3_entry:
  ldr	x0, =SCTLR_VALUE_MMU_DISABLED
  msr	sctlr_el1, x0

  ldr	x0, =HCR_VALUE
  msr	hcr_el2, x0

  ldr	x0, =SCR_VALUE
  msr	scr_el3, x0

  ldr	x0, =SPSR_VALUE
  msr	spsr_el3, x0

  adr	x0, el1_entry
  msr	elr_el3, x0

  eret
  b el1_entry

el2_entry:
  // enable CNTP for EL1
  mrs     x0, cnthctl_el2
  orr     x0, x0, #3
  msr     cnthctl_el2, x0
  msr     cntvoff_el2, xzr
  // enable AArch64 in EL1
  mov     x0, #(1 << 31)      // AArch64
  orr     x0, x0, #(1 << 1)   // SWIO hardwired on Pi3
  msr     hcr_el2, x0
  mrs     x0, hcr_el2
  // change execution level to EL1
  mov     x2, #0x3c4
  msr     spsr_el2, x2
  adr     x2, el1_entry
  msr     elr_el2, x2
  eret

el1_entry:
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

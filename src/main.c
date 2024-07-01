#include <stddef.h>
#include <stdint.h>
#include "uart.h"
#include "io.h"


#ifdef AARCH64
// arguments for AArch64
void kernel_main(uint64_t dtb_ptr32, uint64_t x1, uint64_t x2, uint64_t x3)
#else
	// arguments for AArch32
void kernel_main(uint32_t r0, uint32_t r1, uint32_t atags)
#endif
{
	// initialize UART for Raspi2
	uart_init(3);
	printf("Hel%co, %s World!\n", 'l', "kernel");
	printf("%d %d %d\n", 0, 254, -123);

	while (1)
		uart_putc(uart_getc());
}

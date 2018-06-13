.align 8
// Our interrupt vector table
csd_entry:
	b csd_reset
	b .
	b .
	b csd_prefetch_abort
	b csd_data_abort
	b .
	b csd_irq
	b .
.global main

csd_reset:

main:
	// Set VBAR (Vector Base Address Register) to my own interrupt vectors
    ldr     r0, =csd_entry
    mcr     p15, 0, r0, c12, c0, 0

	/* Disable MMU, if enabled */
	mrc	p15, 0, r0, c1, c0, 0		/* read CP15 register 1 */
	bic	r0, r0, #0x1			/* clear bit 0 */
	mcr	p15, 0, r0, c1, c0, 0		/* write value back */
	// memory initialized!

	mov r0, #1024
	rsb r0, #0		// r0 : -1024

	mov r2, #1024
	add r1, r2, #1024 // r1 : 2048
	add r1, r1, r2	// r1 : 3072
	mov r2, #0x400000 // 0x40_0000

	initialize:
		str r0, [r2], #4 // -1024 ~
		add r0, r0, #1
		sub r1, #1 // count down from 3072
		cmp r1, #0
		bne initialize

	/* figure.2 */
	ldr	r0,=csd_MMUTable
	orr	r0, r0, #0x5B
	mcr	15, 0, r0, c2, c0, 0

	/* Enable mmu, icahce and dcache */
	// read SCTLR (System Control Register) to r0
	mrc	p15, 0, r0, c1, c0, 0
	bic r0, r0, #(1<<12)  // I-bit = I$ disable
	bic r0, r0, #(1<<2)   // C-bit = $ disable
	orr r0, r0, #(1<<0)   // M-bit = MMU enable
	mcr	p15, 0, r0, c1, c0, 0	/* Enable cache and MMU */
	dsb					        /* dsb	allow the MMU to start up */
	isb					        /* isb	flush prefetch buffer */

	mov r0, #0x200000
	add r1, r0, #0x1000
	add r2, r0, #0x2000

	/* addition */
	mov r0, #0x200000
	mov r2, #1024
	add r1, r2, #1024
	add r1, r1, r2 // r1 : 3072
	mov r2, #0

	addition:
		cmp r1, #0
		subne r1, #1
		ldrne r3, [r0], #4
		addne r2, r2, r3 // r2 : final addition result
		bne addition

forever:
	nop
	b forever

// Normal Interrupt Service Routine
csd_irq:
	b .

csd_prefetch_abort:
	mrc p15, 0, r10, c6, c0, 2  // read IFAR to r10
	mrc p15, 0, r11, c5, c0, 1  // read IFSR to r11
	b .

csd_data_abort:
	mrc p15, 0, r10, c6, c0, 0  // read DFAR to r10
	mrc p15, 0, r11, c5, c0, 0  // read DFSR to r11
	b .

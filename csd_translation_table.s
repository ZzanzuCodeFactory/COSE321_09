.globl  csd_MMUTable
.section .csd_mmu_tbl,"a"

.globl  csd_MMUTable_lv2
.section .csd_mmu_tbl_lv2,"a"

csd_MMUTable_lv2:
// 1st entry
.set 	PAGE, 0x400000
.word	PAGE + 0x2
// 2nd entry
//.set	PAGE, PAGE + 0x1000	// figure.2
.set	PAGE, PAGE + 0x2000	// figure.3
.word	PAGE + 0x2

// 3rd entry
//.set	PAGE, PAGE +  0x1000 // figure.2
.set	PAGE, PAGE - 0x2000 // figure.3
.word	PAGE + 0x2


csd_MMUTable:
.set 	SECT, 0
.word	SECT + 0x15de6		/* S=b1 TEX=b101 AP=b11, Domain=b1111, C=b0, B=b1 */
.set	SECT, SECT + 0x100000
.word	SECT + 0x15de6		/* S=b1 TEX=b101 AP=b11, Domain=b1111, C=b0, B=b1 */
.word	csd_MMUTable_lv2 + 0x1e1
.end

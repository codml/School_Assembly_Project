	AREA code_area, CODE, READONLY
		ENTRY

float_number_series EQU 0x0450
sorted_number_series EQU 0x00018AEC
final_result_series EQU 0x00031190

;========== Do not change this area ===========

initialization
	LDR r0, =0xDEADBEEF				; seed for random number
	LDR r1, =float_number_series	
	LDR r2, =10000 				; The number of element in stored sereis
	LDR r3, =0x0EACBA90				; constant for random number

save_float_series
	CMP r2, #0
	BEQ ms_init
	BL random_float_number
	STR r0, [r1], #4
	SUB r2, r2, #1
	MOV r5, #0
	B save_float_series

random_float_number
	MOV r5, LR
	EOR r0, r0, r3
	EOR r3, r0, r3, ROR #2
	CMP r0, r1
	BLGE shift_left
	BLLT shift_right
	BX r5

shift_left
	LSL r0, r0, #1
	BX LR

shift_right
	LSR r0, r0, #1
	BX LR
	
;============================================

;========== Start your code here ===========	

ms_init
	LDR sp, =0x00050000
	LDR r0, =float_number_series
	LDR r2, =final_result_series
	
loop
	LDMIA r0!, {r3-r12}
	STMIA r2!, {r3-r12}
	CMP r0, r1
	BNE loop
	
	LDR r1, =sorted_number_series
	LDR r2, =final_result_series
	MOV r3, #0 ; p
	LDR r4, =9999 ; r
	BL merge_sort
	MOV pc, #0
	
merge_sort
	PUSH {r3-r6, lr}
	CMP r3, r4
	POPGE {r3-r6, pc}
	ADD r5, r3, r4 ; q
	MOV r5, r5, LSR #1 ; q = (p+r)/2
	MOV r6, r4 ; temp r
	MOV r4, r5 ; merge_sort(A, p, q)
	BL merge_sort
	MOV r4, r6 ; restore r
	ADD r7, r5, #1 ; r7 = q + 1
	MOV r6, r3 ; temp p
	MOV r3, r7 ; merge_sort (A, q+1, r)
	BL merge_sort
	MOV r3, r6 ; restore p
	BL merge
	POP {r3-r6, pc}
	
merge
	PUSH {lr}
	SUB r7, r5, r3 ; r7: n1
	ADD r7, r7, #1
	SUB r8, r4, r5 ; r8: n2
	MOV r9, #0 ; index for copy
	
L_loop
	CMP r9, r7
	ADDNE r10, r3, r9
	LDRNE r11, [r2, r10, LSL #2]
	STRNE r11, [r1, r9, LSL #2]
	ADDNE r9, r9, #1
	BNE L_loop
	
	MOV r9, #1
	
R_loop
	CMP r9, r8
	ADDLE r10, r5, r9
	ADDLE r12, r7, r9
	LDRLE r11, [r2, r10, LSL #2]
	STRLE r11, [r1, r12, LSL #2]
	ADDLE r9, r9, #1
	BLE R_loop
	
	LDR r9, =0x7fffffff
	STR r9, [r1, r7, LSL #2]
	ADD r10, r7, r8
	ADD r10, r10, #1
	STR r9, [r1, r10, LSL #2]
	
	MOV r9, #0 ; i
	ADD r10, r7, #1 ; j
	MOV r6, r3 ; k
	
cmp_loop
	CMP r6, r4
	POPGT {pc}
	LDR r11, [r1, r9, LSL #2] ; L[i]
	LDR r12, [r1, r10, LSL #2] ; R[j]
	ANDS r0, r11, r12
	BLMI minus_minus
	CMP r11, r12
	STRLE r11, [r2, r6, LSL #2]
	ADDLE r9, r9, #1
	STRGT r12, [r2, r6, LSL #2]
	ADDGT r10, r10, #1
	ADD r6, r6, #1
	B cmp_loop
	
minus_minus
	CMP r12, r11
	ADD pc, lr, #4 ; go to MOVLE pc, r11
	
exit
	END

;========== End your code here ===========
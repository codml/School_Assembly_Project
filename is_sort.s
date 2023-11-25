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
	BEQ is_init
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
	
is_init
	LDR r0, =10000
	LDR r1, =float_number_series
	LDR r2, =final_result_series
	LDR r3, [r1]
	STR r3, [r2] ; store float[0] into sort[0]
	MOV r3, #0 ; index i
	MOV r12, pc ; lr for is_init
	B for_outside
	MOV pc, #0
	
for_outside
	ADD r3, r3, #1 ; i++
	CMP r3, r0
	MOVEQ pc, r12
	LDR r6, [r1, r3, LSL #2] ; key = arr[i]
	MOV r4, r3 ; j = i
	MOV r11, pc ; lr for for_outside
	B for_inside
	STR r6, [r2, r5, LSL #2] ; arr[j+1] = key
	B for_outside
	
for_inside
	SUBS r4, r4, #1 ; j--
	ADD r5, r4, #1 ; j + 1
	MOVMI pc, r11
	LDR r7, [r2, r4, LSL #2] ; arr[j]
	ANDS r8, r6, r7
	BLMI minus_minus ; r6, r7 both negative
	CMPPL r7, r6
	MOVLE pc, r11
	STRGT r7, [r2, r5, LSL #2]
	B for_inside
	
minus_minus
	CMP r6, r7
	ADD pc, lr, #4 ; go to MOVLE pc, r11
	
exit
	END

;========== End your code here ===========
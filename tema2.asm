%include "include/io.inc"

extern atoi
extern printf
extern exit

%macro task4_M 1
	mov edx,[esp]
	shr edx,%1
	and edx,1 
	call write_lsb
%endmacro

; Functions to read/free/print the image.
; The image is passed in argv[1].
extern read_image
extern free_image
; void print_image(int* image, int width, int height);
extern print_image

; Get image's width and height.
; Store them in img_[width, height] variables.
extern get_image_width
extern get_image_height

section .data
	use_str db "Use with ./tema2 <task_num> [opt_arg1] [opt_arg2]", 10, 0

section .bss
    task:       resd 1
    img:        resd 1
    img_width:  resd 1
    img_height: resd 1

section .text
global main
main:
    ; Prologue
    ; Do not modify!
    push ebp
    mov ebp, esp

    mov eax, [ebp + 8]
    cmp eax, 1
    jne not_zero_param

    push use_str
    call printf
    add esp, 4

    push -1
    call exit

not_zero_param:
    ; We read the image. You can thank us later! :)
    ; You have it stored at img variable's address.
    mov eax, [ebp + 12]
    push DWORD[eax + 4]
    call read_image
    add esp, 4
    mov [img], eax

    ; We saved the image's dimensions in the variables below.
    call get_image_width
    mov [img_width], eax

    call get_image_height
    mov [img_height], eax

    ; Let's get the task number. It will be stored at task variable's address.
    mov eax, [ebp + 12]
    push DWORD[eax + 8]
    call atoi
    add esp, 4
    mov [task], eax

    ; There you go! Have fun! :D
    mov eax, [task]
    cmp eax, 1
    je solve_task1
    cmp eax, 2
    je solve_task2
    cmp eax, 3
    je solve_task3
    cmp eax, 4
    je solve_task4
    cmp eax, 5
    je solve_task5
    cmp eax, 6
    je solve_task6
    cmp eax, 7
    je solve_task7
    jmp done

solve_task1:
	push dword[img]
    call bruteforce_singlebyte_xor
    add esp,4
    jmp done
solve_task2:
    ; TODO Task2
    push dword[img]
    call bruteforce_singlebyte_xor
    add esp,4
    call task_2_function
    jmp done
solve_task3:
    ; TODO Task3
    mov eax, [ebp + 12]

	push eax				; argv[] -> stack

	push DWORD[eax+16]
	call atoi
	add esp,4

	mov edx,eax				;  edx : byte_id

	mov eax,[esp]			; eax : argv[] from stack
	add esp,4

	push edx				; byte_id -> stack
	push dword[eax+12]		; address_of_msg -> stack
	push dword[img]			; address_of_img -> stack

    call task_3_function
    add esp,12
    jmp done
solve_task4:
    ; TODO Task4
    mov eax, [ebp + 12]

    push eax				; argv[] -> stack

	push DWORD[eax+16]
	call atoi
	add esp,4

	mov edx,eax				;  edx : byte_id

	mov eax,[esp]			; eax : argv[] from stack
	add esp,4

	push edx				; byte_id -> stack
	push dword[eax+12]		; address_of_msg -> stack
	push dword[img]			; address_of_img -> stack

    call task_4_function
    add esp,12
    jmp done
solve_task5:
    ; TODO Task5


    mov eax, [ebp + 12]
    push eax

    push DWORD[eax+12]
    call atoi
    add esp,4

    mov edx,eax			; edx: byte_id
    mov eax,[esp]
    add esp,4

    push edx			; byte_id -> stack
    push dword[img]		; img -> stack

    call task_5_function
    add esp,8

    jmp done
solve_task6:
    ; TODO Task6

    push dword[img]
    call blur
    add esp,4
    jmp done
solve_task7:
    ; TODO Task7
    jmp done

    ; Free the memory allocated for the image.
done:
    push DWORD[img]
    call free_image
    add esp, 4

    ; Epilogue
    ; Do not modify!
    xor eax, eax
    leave
    ret
    
;					-------------- TASK 1 --------------
;					|           BRUTE FORCE            |
;					------------------------------------

bruteforce_singlebyte_xor:
	push ebp
	mov ebp,esp

	call clean_reg
	call size_image_to_ecx
	
	mov ebx,[ebp+8]				; ebx : adress_of_img from stack
	xor eax,eax					; eax: key

search_key:
	
	inc eax 					; next key
	cmp eax,256 				; test out of keys
	jz no_t_found
	mov edx,[ebx+4*ecx]			; edx: last char 
	xor edx,eax 				; edx: plain char
	cmp edx,'t'
	jz found_t
	jmp search_key

no_t_found:
	xor eax,eax					; starting over with the keys
	sub ecx,1

	cmp ecx,0 					; test if all the matrix was searched
	jz end_search
	jmp search_key 

found_t:

	mov edx,[ebx+4*(ecx-1)]		; search for every letter in the word
	xor edx,eax
	cmp edx,'n'
	jnz search_key
	
	mov edx,[ebx+4*(ecx-2)]
	xor edx,eax
	cmp edx,'e'
	jnz search_key
	
	mov edx,[ebx+4*(ecx-3)]
	xor edx,eax
	cmp edx,'i'
	jnz search_key

	mov edx,[ebx+4*(ecx-4)]
	xor edx,eax
	cmp edx,'v'
	jnz search_key

	mov edx,[ebx+4*(ecx-5)]
	xor edx,eax
	cmp edx,'e'
	jnz search_key

	mov edx,[ebx+4*(ecx-6)]
	xor edx,eax
	cmp edx,'r'
	jnz search_key

end_search:

	mov edx,[img_width]
	xor ebx,ebx
	push ecx

line_loop:						;	compute the line where the message is
	cmp ecx,edx
	jl end_line
	sub ecx,edx
	inc ebx
	jmp line_loop
end_line:

	mov edx,[esp]
	sub edx,ecx
	mov ecx,edx

	push ebx
	mov ebx,[img]

	cmp dword[task],1			;	skip the prnit because the function is also called in task 2
	jnz skip_print
	call print_task1

skip_print:

	mov ebx,[esp]
	add esp,4

	mov edx,eax
	xor eax,eax
	mov eax,ebx
	shl eax,8 						; save the key in eax in the format line|key
	mov al,dl 						; 

	leave
	ret

;					-------------- TASK 2 --------------
;					|             RE-ENCRYPT           |
;					------------------------------------

task_2_function:
	push ebp
	mov ebp,esp

	push eax					; line|key -> stack

	call size_image_to_ecx		; ecx : size_of_image , eax: 0
								; modifies eax and ebx

	mov ebx,[img]				; ebx : adress_of_image
	mov eax,[esp]				; eax : line|key from stack , stack : line|key

	shl eax,24					
	shr eax,24					; eax: key

	push ecx 					; size_of_image -> stack

	call decrypt_image			; requires that eax:key ebx:addres_of_image
								; modifies ecx and edx

	call compute_new_key		; requires that eax:key
								; modifies edx ebx

	mov eax,[esp+4]				; eax : line|old_key

	shr eax,8
	shl eax,18
	shr eax,18
	add eax,1					; eax : next_line

	mov ebx,[img]

	call print_proverb			; requires eax:next_line ebx:adress_of_image
								; modifies ecx

	mov eax,edx					; eax : new_key
	mov ecx,[esp]				; ecx : size_of_image from stack
	add esp,8

	call encrypt_image
	call clean_reg
	call disp_image

	leave
	ret

;					-------------- TASK 3 --------------
;					|              MORSE               |
;					------------------------------------

task_3_function:
	push ebp
	mov ebp,esp


	mov ebx,[ebp+8]				; ebx: adress_of_image
	mov ecx,[ebp+16]			; ecx: byte_id
	add ebx,ecx	
	add ebx,ecx	
	add ebx,ecx	
	add ebx,ecx					; ebx: start adress
								; ecx <=> free to use

	mov ecx,[eax+16]			; ecx: argv[4]
	mov edx,[ecx]
	mov ecx,edx					; ecx: *argv[4] /* stop character */

	mov eax,[ebp+12]			; eax: adress_of_msg

	mov edx,[eax]

morse_loop:

	mov edx,[eax] 				; edx: current_char
	cmp edx,0
	jz morse_loop_end
	cmp edx,ecx
	jz morse_loop_end

	call switch_morse

	add eax,1 					; next char
	jmp morse_loop

morse_loop_end:

	sub ebx,4
	mov dword[ebx],0 			; put the zero char

	call disp_image

	leave
	ret

;					-------------- TASK 4 --------------
;					|               LSB                |
;					------------------------------------

task_4_function:
	push ebp
	mov ebp,esp

	mov esi,[ebp+8]				; ecx: adress_of_img from stack
	mov ebx,[ebp+12]			; ebx: adress_of_msg
	mov edx,[ebp+16]			; edx: byte_id from stack

	dec edx

	times 4 add esi,edx			; ecx: start_adress

	mov edx,[eax+16]
	mov eax,[edx]			; eax: stop_char

	; ecx: start_adress
	; ebx: address_of_msg
	; eax: stop char

trav_msg:

	xor edx,edx
	mov dl,[ebx]

	cmp edx,eax 				; compare with the stop_char
	jz end_trav_msg

	push edx					; char -> stack

	mov edx,[esp] 				; the write_lsb funcion need only edx and ecx to be set
	shr edx,7					; write edx bit by bit in the image
	and edx,1 					; first bit first
	call write_lsb 				; and so on

	task4_M 6
	task4_M 5
	task4_M 4
	task4_M 3
	task4_M 2
	task4_M 1

	mov edx,[esp]
	and edx,1
	call write_lsb
	mov edx,[esp]

	cmp edx,0
	jz end_trav_msg

	add esp,4
	add ebx,1
	jmp trav_msg

end_trav_msg:

	call clean_reg
	call disp_image

	leave
	ret

;					-------------- TASK 5 --------------
;					|             LSB DECRYPT          |
;					------------------------------------

task_5_function:
	push ebp
	mov ebp,esp

	mov ecx,[ebp+12]			; ecx: byte_id
	mov ebx,[ebp+8]				; ebx: adress_of_img

	sub ecx,1
	times 4 add ebx,ecx 		; ebx: start_point


un_lsb_loop:

	xor edx,edx

	mov eax,[ebx]
	and eax,1
	or edx,eax
	add ebx,4

	mov ecx,7
loop_7:

	mov eax,[ebx]
	and eax,1
	shl edx,1
	or edx,eax
	add ebx,4

	loop loop_7

	cmp edx,0
	jz end_un_lsb_loop
	PRINT_CHAR edx
	jmp un_lsb_loop

end_un_lsb_loop:

	NEWLINE

	leave
	ret

;					-------------- TASK 6 --------------				666   666   666
;					|               BLUR               |				666   666   666
;					------------------------------------				666   666   666

blur:
	push ebp
	mov ebp,esp

	call size_image_to_ecx

	mov eax,ecx
	times 3 add eax,ecx

	times 4 sub eax,[img_width]

	mov edi,[img_width]		; edi: width


	mov esi,[ebp+8]			; esi: base
	add eax,esi

	push dword[esi+4*edi]
	mov ecx,1				; ecx: counter

	dec edi

stack_loop:

	push dword[esi+4*ecx]
	inc ecx
	cmp ecx,edi
	je end_stack_loop
	jmp stack_loop

end_stack_loop:

	inc edi

	times 4 add esi,edi 		; esi: line

blur_loop:

	mov ecx,1					; ecx: counter
	
blur_line:

	mov edx,[esi+4*ecx]			; final <- curent
	add edx,[esi+4*(ecx+1)]		; final += right

	add ecx,edi
	add edx,[esi+4*ecx]			; final += down
	sub ecx,edi

	inc ecx
	sub edi,ecx
	add edx,[esp+4*edi]			; final += left
	add edx,[esp+4*(edi-1)]		; final += up
	call div5_edx

	mov ebx,[esi+4*(ecx-1)]			; old_pixel
	mov dword[esi+4*(ecx-1)],edx 	; WRITE
	mov [esp+4*(edi-1)],ebx 		; old_pixel -> stack

	add edi,ecx
	dec ecx
	
	inc ecx 						; next char
	dec edi 						; stop at (img_width-1)
	cmp ecx,edi
	je end_blur_line
	inc edi
	jmp blur_line

end_blur_line:

	inc edi

	mov ebx,[esi+4*edi]
	mov [ebp-4],ebx

	times 4 add esi,edi

	cmp esi,eax
	je end_blur_loop
	jmp blur_loop

end_blur_loop:


	call clean_reg
	call disp_image

	dec edi
	add esp,edi 
	add esp,edi
	add esp,edi
	add esp,edi

	leave
	ret


;					------------------------------------
;					|            FUNCTIONS             |
;					------------------------------------

div5_edx: 			; divide edx by 5
	push  ebp
	mov ebp,esp

	push ecx
	xor  ecx,ecx

	cmp edx,5
	jl end_div5_loop

div5_loop:
	add ecx,1
	sub edx,5
	cmp edx,5
	jl end_div5_loop
	jmp div5_loop
end_div5_loop:
	mov edx,ecx
	
	mov ecx,[esp]
	add esp,4

	leave
	ret

size_image_to_ecx:		; put the size of the image in ecx
	push ebp
	mov ebp,esp

	mov eax,[img_width]
	mov ebx,[img_height]
	mul ebx
	mov ecx,eax					; ecx : size of image

	leave
	ret
                                                           

print_proverb:			; print the phrase in the image
	push ebp
	mov ebp,esp

	xor ecx,ecx

deline_loop:
	add ecx,[img_width]
	sub eax,1
	cmp eax,0
	jz end_deline_loop
	jmp deline_loop
end_deline_loop:
	mov eax,ecx

	mov dword[ebx+4*eax],'C'
	mov dword[ebx+4*(eax+1)],39
	mov dword[ebx+4*(eax+2)],'e'
	mov dword[ebx+4*(eax+3)],'s'
	mov dword[ebx+4*(eax+4)],'t'
	mov dword[ebx+4*(eax+5)],' '
	mov dword[ebx+4*(eax+6)],'u'
	mov dword[ebx+4*(eax+7)],'n'
	mov dword[ebx+4*(eax+8)],' '
	mov dword[ebx+4*(eax+9)],'p'
	mov dword[ebx+4*(eax+10)],'r'
	mov dword[ebx+4*(eax+11)],'o'
	mov dword[ebx+4*(eax+12)],'v'
	mov dword[ebx+4*(eax+13)],'e'
	mov dword[ebx+4*(eax+14)],'r'
	mov dword[ebx+4*(eax+15)],'b'
	mov dword[ebx+4*(eax+16)],'e'
	mov dword[ebx+4*(eax+17)],' '
	mov dword[ebx+4*(eax+18)],'f'
	mov dword[ebx+4*(eax+19)],'r'
	mov dword[ebx+4*(eax+20)],'a'
	mov dword[ebx+4*(eax+21)],'n'
	mov dword[ebx+4*(eax+22)],'c'
	mov dword[ebx+4*(eax+23)],'a'
	mov dword[ebx+4*(eax+24)],'i'
	mov dword[ebx+4*(eax+25)],'s'
	mov dword[ebx+4*(eax+26)],'.'
	mov dword[ebx+4*(eax+27)],0

	leave
	ret


compute_new_key:
	push ebp
	mov ebp,esp

	mov edx,eax
	shl edx,1
	add edx,3
	xor ebx,ebx
div_5:							; do the divisoin by 5
	cmp edx,5
	jl end_div_5
	add ebx,1
	sub edx,5
	jmp div_5
end_div_5:
	sub ebx,4					; ebx : new_key
	mov edx,ebx					; edx : new_key

	leave
	ret


decrypt_image:
	push ebp
	mov ebp,esp

decrpt_image:
	mov edx,[ebx+4*ecx]
	xor edx,eax
	mov dword[ebx+4*ecx],edx
	sub ecx,1
	cmp ecx,0
	jz decrypt_end
	jmp decrpt_image
decrypt_end:
	mov edx,[ebx]
	xor edx,eax
	mov dword[ebx],edx

	leave
	ret

encrypt_image:
	push ebp
	mov ebp,esp

loop_encrypt_image:
	mov edx,[ebx+4*ecx]
	xor edx,eax
	mov dword[ebx+4*ecx],edx
	sub ecx,1
	cmp ecx,0
	je end_encrypt_image
	jmp loop_encrypt_image
end_encrypt_image:
	mov edx,[ebx]
	xor edx,eax
	mov dword[ebx],edx

	leave
	ret


clean_reg:
	push ebp
	mov ebp,esp

	xor eax,eax
	xor ebx,ebx
	xor ecx,ecx
	xor edx,edx

	leave
	ret

print_task1:
	push ebp
	mov ebp,esp

string_loop:
	mov edx,[ebx+4*ecx]
	xor edx,eax
	cmp edx,0
	jz end_string
	PRINT_CHAR edx
	inc ecx
	jmp string_loop
end_string:
	NEWLINE
	PRINT_DEC 4,eax
	NEWLINE
	mov ebx,[ebp+8]
	PRINT_DEC 4,ebx
	NEWLINE

	leave
	ret

write_lsb:			; wirte the last byte of the current pixel with the value of edx
	push ebp
	mov ebp,esp

	cmp edx,0
	jz case_0
	jmp case_1
case_0:
	mov edx,0xfffffffe
	and [esi],edx
	jmp end_case

case_1:
	mov edx,1
	or [esi],edx
	jmp end_case

end_case:
	add esi,4 				; next pixel

	leave
	ret

disp_image:
	push ebp
	mov ebp,esp

	push dword[img_height]
	push dword[img_width]
	push dword[img]
	call print_image
	add esp,12

	leave
	ret

switch_morse:			; write the morse representation of the code
	push ebp
	mov ebp,esp

	cmp dl,'A'
	je morse_A
	cmp dl,'B'
	je morse_B
	cmp dl,'C'
	je morse_C
	cmp dl,'D'
	je morse_D
	cmp dl,'E'
	je morse_E
	cmp dl,'F'
	je morse_F
	cmp dl,'G'
	je morse_G
	cmp dl,'H'
	je morse_H
	cmp dl,'I'
	je morse_I
	cmp dl,'J'
	je morse_J
	cmp dl,'K'
	je morse_K
	cmp dl,'L'
	je morse_L
	cmp dl,'M'
	je morse_M
	cmp dl,'N'
	je morse_N
	cmp dl,'O'
	je morse_O
	cmp dl,'P'
	je morse_P
	cmp dl,'Q'
	je morse_Q
	cmp dl,'R'
	je morse_R
	cmp dl,'S'
	je morse_S
	cmp dl,'T'
	je morse_T
	cmp dl,'U'
	je morse_U
	cmp dl,'V'
	je morse_V
	cmp dl,'W'
	je morse_W
	cmp dl,'X'
	je morse_X
	cmp dl,'Y'
	je morse_Y
	cmp dl,'Z'
	je morse_Z
	cmp dl,44
	je morse_44		; comma
	cmp dl,32
	je morse_32		; blank
	cmp dl,'0'
	je morse_0
	cmp dl,'1'
	je morse_1
	cmp dl,'2'
	je morse_2
	cmp dl,'3'
	je morse_3
	cmp dl,'4'
	je morse_4
	cmp dl,'5'
	je morse_5
	cmp dl,'6'
	je morse_6
	cmp dl,'7'
	je morse_7
	cmp dl,'8'
	je morse_8
	cmp dl,'9'
	je morse_9
	jmp end_morse

morse_A:
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],32
	add ebx,4
	jmp end_morse
morse_B:
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],32
	add ebx,4
	jmp end_morse
morse_C:
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],32
	add ebx,4
	jmp end_morse
morse_D:
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],32
	add ebx,4
	jmp end_morse
morse_E:
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],32
	add ebx,4
	jmp end_morse
morse_F:
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],32
	add ebx,4
	jmp end_morse
morse_G:
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],32
	add ebx,4
	jmp end_morse
morse_H:
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],32
	add ebx,4
	jmp end_morse
morse_I:
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],32
	add ebx,4
	jmp end_morse
morse_J:
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],32
	add ebx,4
	jmp end_morse
morse_K:
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],32
	add ebx,4
	jmp end_morse
morse_L:
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],32
	add ebx,4
	jmp end_morse
morse_M:
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],32
	add ebx,4
	jmp end_morse
morse_N:
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],32
	add ebx,4
	jmp end_morse
morse_O:
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],32
	add ebx,4
	jmp end_morse
morse_P:
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],32
	add ebx,4
	jmp end_morse
morse_Q:
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],32
	add ebx,4
	jmp end_morse
morse_R:
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],32
	add ebx,4
	jmp end_morse
morse_S:
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],32
	add ebx,4
	jmp end_morse
morse_T:
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],32
	add ebx,4
	jmp end_morse
morse_U:
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],32
	add ebx,4
	jmp end_morse
morse_V:
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],32
	add ebx,4
	jmp end_morse
morse_W:
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],32
	add ebx,4
	jmp end_morse
morse_X:
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],32
	add ebx,4
	jmp end_morse
morse_Y:
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],32
	add ebx,4
	jmp end_morse
morse_Z:
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],32
	add ebx,4
	jmp end_morse
morse_44:
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],32
	add ebx,4
	jmp end_morse
morse_32:
	mov dword[ebx],124
	add ebx,4
	jmp end_morse
morse_1:
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],32
	add ebx,4
	jmp end_morse
morse_2:
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],32
	add ebx,4
	jmp end_morse
morse_3:
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],32
	add ebx,4
	jmp end_morse
morse_4:
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],32
	add ebx,4
	jmp end_morse
morse_5:
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],32
	add ebx,4
	jmp end_morse
morse_6:
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],32
	add ebx,4
	jmp end_morse
morse_7:
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],32
	add ebx,4
	jmp end_morse
morse_8:
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],32
	add ebx,4
	jmp end_morse
morse_9:
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],46
	add ebx,4
	mov dword[ebx],32
	add ebx,4
	jmp end_morse
morse_0:
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],45
	add ebx,4
	mov dword[ebx],32
	add ebx,4
	jmp end_morse

end_morse:

	leave
	ret
extrn printf : proc
extrn gets_s : proc
extrn strcmp : proc
extrn strncmp : proc
extrn strlen : proc
extrn exit : proc

.data
    prompt db "C##++ > ", 0
    fmt_out db "%s", 10, 0
    err_cmd db "C##++ Error: unknown command", 10, 0
    err_semi db "C##++ Error: missing semicolon ';'", 10, 0
    exit_cmd db "exit", 0
    cmd_mocal db "mocal ", 0
    cmd_print db "print(", 0

.data?
    buffer db 256 dup(?)
    var_name db 64 dup(?)
    var_val db 128 dup(?)
    has_var db ?

.code
main proc
    sub rsp, 40                 ; Shadow Space reservieren

    mov has_var, 0

repl_loop:
    ; Prompt ausgeben
    lea rcx, prompt
    call printf

    ; Input lesen (gets_s erwartet Puffer & Max-Länge)
    lea rcx, buffer
    mov rdx, 256
    call gets_s

    ; Exit prüfen
    lea rcx, buffer
    lea rdx, exit_cmd
    call strcmp
    test eax, eax
    jz exit_program

    call parse_code
    jmp repl_loop

exit_program:
    xor ecx, ecx
    call exit
main endp

parse_code proc
    sub rsp, 40

    lea rcx, buffer
    cmp byte ptr [rcx], 0
    je done

    ; Semikolon prüfen
    call strlen
    dec rax
    lea rcx, buffer
    cmp byte ptr [rcx + rax], ';'
    jne error_semicolon

    ; Semikolon entfernen
    mov byte ptr [rcx + rax], 0

    ; Check mocal
    lea rcx, buffer
    lea rdx, cmd_mocal
    mov r8, 6
    call strncmp
    test eax, eax
    jz handle_mocal

    ; Check print
    lea rcx, buffer
    lea rdx, cmd_print
    mov r8, 6
    call strncmp
    test eax, eax
    jz handle_print

    jmp error_unknown

handle_mocal:
    lea rsi, [buffer + 6]
    lea rdi, var_name

copy_var_name:
    lodsb
    cmp al, ' '
    je skip_to_val
    cmp al, '='
    je skip_equals
    stosb
    jmp copy_var_name

skip_to_val:
    lodsb
    cmp al, '='
    jne skip_to_val

skip_equals:
    lodsb
    cmp al, ' '
    je skip_equals

    cmp al, '"'
    je copy_string_val

    lea rdi, var_val
    stosb
copy_raw_val:
    lodsb
    cmp al, 0
    je save_var_done
    stosb
    jmp copy_raw_val

copy_string_val:
    lea rdi, var_val
copy_str_loop:
    lodsb
    cmp al, '"'
    je save_var_done
    cmp al, 0
    je save_var_done
    stosb
    jmp copy_str_loop

save_var_done:
    mov byte ptr [rdi], 0
    mov byte ptr [has_var], 1
    jmp done

handle_print:
    lea rsi, [buffer + 6]
    cmp byte ptr [rsi], '"'
    je print_literal_string

    cmp has_var, 0
    je error_unknown

    lea rcx, fmt_out
    lea rdx, var_val
    call printf
    jmp done

print_literal_string:
    inc rsi
    lea rdi, [buffer + 180]
    mov rbx, rdi
print_str_loop:
    lodsb
    cmp al, '"'
    je do_print
    cmp al, ')'
    je do_print
    cmp al, 0
    je do_print
    stosb
    jmp print_str_loop

do_print:
    mov byte ptr [rdi], 0
    lea rcx, fmt_out
    mov rdx, rbx
    call printf
    jmp done

error_semicolon:
    lea rcx, err_semi
    call printf
    jmp done

error_unknown:
    lea rcx, err_cmd
    call printf

done:
    add rsp, 40
    ret
parse_code endp

end
; MAC0216 - EP1: Algoritmo de hash em Linux NASM, 64-bits
; Autora: Ana Lívia Rüegger Saldanha


global _start


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .text

_start:
    ; Ler da entrada padrão a string, armazenando em 'entrada'
    mov     rsi,    entrada
    mov     rdx,    100001      ; Máximo de 100000 caracteres, +1 para o '\n'
    mov     rax,    SYS_READ
    mov     rdi,    STDIN
    syscall

    ; ---------------------------------------
    ; DEBUG: printar o que eu li do teclado
    ; mov     rax,    SYS_WRITE
    ; mov     rdi,    STDOUT
    ; mov     rsi,    entrada     ; rsi = endereço da string
    ; mov     rdx,    100001      ; rdx = tamanho da string
    ; syscall 
    ; ---------------------------------------

    ; Armazenar o tamanho da string lida em 'tamanho', lembrando que
    ; o último caractere lido é o '\n', que não deve ser considerado
    dec     rax
    mov     [tamanho],  al

    ; ---------------------------------------
    ; DEBUG: printar o tamanho da string lida
    ; add al, '0'         ; transformar em caractere - funciona até 9 apenas
    ; mov [debug], al     ; armazenar em debug para printar (precisa ser vetor?)
    ; mov     rax,    SYS_WRITE
    ; mov     rdi,    STDOUT
    ; mov     rsi,    debug
    ; mov     rdx,    1        ; tamanho da string
    ; syscall
    ; ---------------------------------------

    ;---------------------------------------------------------------------------
    ; Passo 1 - Ajuste do tamanho ----------------------------------------------
    ;---------------------------------------------------------------------------
    
    ; Calcular o tamanho da saída do passo 1, que é o tamanho da
    ; entrada + 16 - (tamanho % 16). obs: o dividendo já está em ax
    mov     bl,             16          ; valor em bl será o divisor (opernado)
    div     bl                          ; quociente em al, resto em ah
    mov     rdx,            16
    sub     dl,             ah          ; dl = 16 - (tamanho % 16)
    mov     rbx,            rdx         ; guardar para usar no preenchimento
    add     rdx,            [tamanho]
    mov     [tamanho_p1],   dl

    ; Realizar o preenchimento (padding)
    xor     rcx,    rcx         ; zerar RCX
    mov     cl,     [tamanho]
    
    preencher:
    mov     byte        [entrada + rcx],    bl
    inc     rcx
    cmp     rcx,        rdx
    jne     preencher

    ; ---------------------------------------
    ; DEBUG: printar a string com padding
    ; mov     rax,    SYS_WRITE
    ; mov     rdi,    STDOUT
    ; mov     rsi,    entrada         ; rsi = endereço da string
    ; mov     rdx,    [tamanho_p1]    ; rdx = tamanho da string
    ; syscall 
    ; ---------------------------------------

    ;---------------------------------------------------------------------------
    ; Passo 2 - Cálculo e concatenação dos XOR ---------------------------------
    ;---------------------------------------------------------------------------
    
    ; Encontrar n (número de blocos de 16 bytes)
    mov     rax,    [tamanho_p1]
    mov     bl,     16
    div     bl          ; quociente em al, resto em ah
    mov     [n],    al

    ; Calcular o tamanho da saída do passo 2, que é o tamanho do passo 1
    ; mais 16 bytes
    mov    rdx,             [tamanho_p1]
    add    rdx,             16
    mov    [tamanho_p2],    dl

    ; Preencher o espaço do novo bloco com zeros
    xor     rcx,    rcx             ; zerar rcx
    mov     cl,     [tamanho_p1]    ; começar no fim do passo 1
    
    novo_bloco:
    mov     byte        [entrada + rcx],    0
    inc     rcx
    cmp     rcx,        rdx     ; comparar com o tamanho do passo 2 (já em rdx)
    jne     novo_bloco

    ; 'novo_valor' ficará em rbx
    xor     rbx,    rbx     ; zerar rbx

    ; Loop externo: i varia [0, n] - (rcx)
    ; Loop interno: j varia [0, 16] - (rdx)
    mov     rcx,    0    ; inicializa i = 0

    laco_externo_p2:    ; i = rcx
    mov     rdx,    0   ; inicializa j = 0

    laco_interno_p2:    ; j = rdx

    ; Lembrando o uso dos registradores:
    ; rax: usar para calcular index
    ; rbx: novo_valor
    ; rcx: i (contador loop externo)
    ; rdx: j (contador loop interno)

    ; Preciso de i * 16 (lembrando que i está em rcx)
    mov     al,     16      ; al guarda o multiplicador
    mul     cl              ; rax = al * cl = i * 16

    ; Calcular index = saida_passo_1[i * 16 + j] ^ novo_valor
    ; lembrando: saida_passo_1[i * 16 + j] = [entrada + rax + rdx]
    ; guardarei o index em al
    mov     rbp,    rax     ; copiar rax para rbp, pois vou mexer no al
    mov     al,     [entrada + rbp + rdx]   ; al = saida_passo_1[i * 16 + j]
    xor     al,     bl      ; al = saida_passo_1[i * 16 + j] ^ novo_valor

    ; Novo valor = VETOR_MAGICO[index] ^ novo_bloco[j]
    ; Primeiro vou guar novo_bloco[j] em bl
    mov     rbp,    [tamanho_p1]
    mov     bl,     [entrada + rbp + rdx]
    ; XOR com VETOR_MAGICO[index] (index está em al)
    movzx   rax,    al  ; manter al, zerar os outros bytes de rax
    xor     bl,     [VETOR_MAGICO + rax]    ; novo_valor em bl
    ; Fazer: novo_bloco[j] = novo_valor
    mov     [entrada + rbp + rdx],      bl

    ; Burocracias do laço interno...
    inc     rdx
    cmp     rdx,    16
    jne     laco_interno_p2     ; se j < 16, continua o laço interno

    ; Burocracias do laço externo...
    inc     rcx
    cmp     rcx,    [n]
    jne     laco_externo_p2     ; se i < n, continua o laço externo

    ;---------------------------------------------------------------------------
    ; Passo 3 - Transformação dos n+1 blocos em apenas 3 blocos ----------------
    ;---------------------------------------------------------------------------


    ; Sair do programa
    mov     rax,    SYS_EXIT
    mov     rdi,    0
    syscall


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .bss

debug:          resb    1

entrada:        resb    100016
tamanho:        resb    1

; saida_p1:       resb    100000  ; não usado
tamanho_p1:     resb    1

; saida_p2:       resb    100016  ; não usado
tamanho_p2:     resb    1

n:              resb    1

saida_p3:       resb    48

hash:           resb    32  ; Saída em hex (16 bytes * 2 caracteres por byte)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .data

SYS_READ:       equ     0
SYS_WRITE:      equ     1
SYS_EXIT:       equ     60

STDIN:          equ     0
STDOUT:         equ     1

HEX_CHARS:      db      "0123456789ABCDEF"  ; Tabela de caracteres hexadecimais

VETOR_MAGICO:   db      122, 77, 153, 59, 173, 107, 19, 104, 123, 183, 75, 10, 114, 236, 106, 83, 117, 16, 189, 211, 51, 231, 143, 118, 248, 148, 218, 245, 24, 61, 66, 73, 205, 185, 134, 215, 35, 213, 41, 0, 174, 240, 177, 195, 193, 39, 50, 138, 161, 151, 89, 38, 176, 45, 42, 27, 159, 225, 36, 64, 133, 168, 22, 247, 52, 216, 142, 100, 207, 234, 125, 229, 175, 79, 220, 156, 91, 110, 30, 147, 95, 191, 96, 78, 34, 251, 255, 181, 33, 221, 139, 119, 197, 63, 40, 121, 204, 4, 246, 109, 88, 146, 102, 235, 223, 214, 92, 224, 242, 170, 243, 154, 101, 239, 190, 15, 249, 203, 162, 164, 199, 113, 179, 8, 90, 141, 62, 171, 232, 163, 26, 67, 167, 222, 86, 87, 71, 11, 226, 165, 209, 144, 94, 20, 219, 53, 49, 21, 160, 115, 145, 17, 187, 244, 13, 29, 25, 57, 217, 194, 74, 200, 23, 182, 238, 128, 103, 140, 56, 252, 12, 135, 178, 152, 84, 111, 126, 47, 132, 99, 105, 237, 186, 37, 130, 72, 210, 157, 184, 3, 1, 44, 69, 172, 65, 7, 198, 206, 212, 166, 98, 192, 28, 5, 155, 136, 241, 208, 131, 124, 80, 116, 127, 202, 201, 58, 149, 108, 97, 60, 48, 14, 93, 81, 158, 137, 2, 227, 253, 68, 43, 120, 228, 169, 112, 54, 250, 129, 46, 188, 196, 85, 150, 6, 254, 180, 233, 230, 31, 76, 55, 18, 9, 32, 82, 70
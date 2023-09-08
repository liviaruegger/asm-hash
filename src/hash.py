"""
MAC0216 - EP1
Ana Lívia Rüegger Saldanha
"""


# Constantes -------------------------------------------------------------------

VETOR_MAGICO = [
    122, 77, 153, 59, 173, 107, 19, 104, 123, 183, 75, 10, 114, 236, 106, 83,
    117, 16, 189, 211, 51, 231, 143, 118, 248, 148, 218, 245, 24, 61, 66, 73,
    205, 185, 134, 215, 35, 213, 41, 0, 174, 240, 177, 195, 193, 39, 50, 138,
    161, 151, 89, 38, 176, 45, 42, 27, 159, 225, 36, 64, 133, 168, 22, 247, 52,
    216, 142, 100, 207, 234, 125, 229, 175, 79, 220, 156, 91, 110, 30, 147, 95,
    191, 96, 78, 34, 251, 255, 181, 33, 221, 139, 119, 197, 63, 40, 121, 204,
    4, 246, 109, 88, 146, 102, 235, 223, 214, 92, 224, 242, 170, 243, 154, 101,
    239, 190, 15, 249, 203, 162, 164, 199, 113, 179, 8, 90, 141, 62, 171, 232,
    163, 26, 67, 167, 222, 86, 87, 71, 11, 226, 165, 209, 144, 94, 20, 219, 53,
    49, 21, 160, 115, 145, 17, 187, 244, 13, 29, 25, 57, 217, 194, 74, 200, 23,
    182, 238, 128, 103, 140, 56, 252, 12, 135, 178, 152, 84, 111, 126, 47, 132,
    99, 105, 237, 186, 37, 130, 72, 210, 157, 184, 3, 1, 44, 69, 172, 65, 7,
    198, 206, 212, 166, 98, 192, 28, 5, 155, 136, 241, 208, 131, 124, 80, 116,
    127, 202, 201, 58, 149, 108, 97, 60, 48, 14, 93, 81, 158, 137, 2, 227, 253,
    68, 43, 120, 228, 169, 112, 54, 250, 129, 46, 188, 196, 85, 150, 6, 254,
    180, 233, 230, 31, 76, 55, 18, 9, 32, 82, 70
]


# IMPLEMENTAÇÃO DO ALGORITMO DE HASH ===========================================

x = input()

### Passo 1 - Ajuste do tamanho ------------------------------------------------

tamanho = len(x)
saida_passo_1 = [ord(c) for c in x]

if tamanho % 16 != 0:
    saida_passo_1 += [16 - (tamanho % 16)] * (16 - (tamanho % 16))


### Passo 2 - Cálculo e concatenação dos XOR -----------------------------------

n = len(saida_passo_1) // 16

novo_bloco = [0] * 16
novo_valor = 0

for i in range(n):
    for j in range(16):
        index = saida_passo_1[i * 16 + j] ^ novo_valor
        novo_valor = VETOR_MAGICO[index] ^ novo_bloco[j]
        novo_bloco[j] = novo_valor

saida_passo_2 = saida_passo_1 + novo_bloco


### Passo 3 - Transformação dos n+1 blocos em apenas 3 blocos ------------------

saida_passo_3 = [0] * 48

for i in range(n + 1):
    for j in range(16):
        saida_passo_3[16 + j] = saida_passo_2[i * 16 + j]
        saida_passo_3[32 + j] = saida_passo_3[16 + j] ^ saida_passo_3[j]
    
    temp = 0
    for j in range(18):
        for k in range(48):
            temp = saida_passo_3[k] ^ VETOR_MAGICO[temp]
            saida_passo_3[k] = temp
        temp = (temp + j) % 256


### Passo 4 - Definição do hash como um valor em hexadecimal -------------------

saida = ""
for valor in saida_passo_3[:16]:
    valor_hex = hex(valor)[2:]
    if len(valor_hex) == 1:
        saida += "0"
    saida += valor_hex

print(saida)

# bitmath nvim plugin idea
isso é uma ideação para o desenvolvimento de um plugin do nvim para fazer mamtemárica rápida e representação de bits. É pensado para facilitar a vida de quem meche com low level.

## Software Design Document (SDD)
O `bit-repl.nvim` é um ambiente de execução (REPL) focado em **desenvolvedores de sistemas embarcados e firmware**. Ele transforma um buffer do Neovim em uma calculadora interativa que entende a sintaxe C, operadores lógicos e representações binárias complexas.

## 1. Filosofia de Design
* **Baixa Carga Cognitiva:** O usuário não deve aprender uma nova linguagem (usa sintaxe C/Lua).
* **Transparência de Bits:** O estado binário nunca é oculto; ele é a prioridade visual.
* **Isolamento de Estado:** Funciona como um scratchpad que não polui os arquivos do projeto.

## 2. Arquitetura do Sistema

O plugin será dividido em três camadas lógicas para garantir facilidade de manutenção:

### A. Camada de Buffer (UI/UX)
* **Buffer Epistêmico:** Um buffer do tipo `nofile` (não persistente no disco) que armazena o histórico da sessão.
* **Virtual Text Engine:** Utiliza a API de `extmarks` do Neovim para exibir resultados em tempo real ao lado de cada linha, sem modificar o texto original.
* **Toggle Mechanism:** Gerenciamento de janelas (`split` lateral) que preserva o estado da sessão mesmo quando fechado.
* Modelo de ui notebook: o usuário digita a operação esperada e o programa insere o texto logo abaixo

### B. Camada de Processamento (The Sanitizer)
Como o LuaJIT (motor do Neovim) não entende nativamente binários (`0b`) ou operadores como `<<`, esta camada atua como um transpilador:
1.  **Regex Parser:** Detecta `0b[01]+`, `0x[0-9A-F]+` e prefixos de cardinalidade (`8b`, `16b`, etc).
2.  **Variable Resolver:** Substitui nomes de variáveis pelos valores armazenados na "Tabela de Símbolos" da sessão.
3.  **Lua Converter:** Converte operadores C para funções da biblioteca `bit` do LuaJIT (ex: `&` vira `bit.band`).

### C. Camada de Formatação (The Mirror)
* **Cardinality Engine:** Calcula o padding de bits baseado no prefixo ou no valor (potências de 2).
* **Visual Aligner:** Gera strings de bits alinhadas verticalmente para operações binárias, facilitando a inspeção de máscaras.

## 3. Core Features (MVP)

| Feature | Descrição |
| :--- | :--- |
| **C-Syntax Math** | Operações padrão: `+`, `-`, `*`, `/`, `%`. |
| **Bitwise Logic** | Operações lógicas: `&`, `\|`, `^`, `~`, `<<`, `>>`. |
| **Representação 0b** | Suporte nativo para entrada e saída em binário. |
| **Cardinalidade** | Prefixos `8b`, `16b`, `32b` e `64b` para definir o bit-width visual. |
| **Registers/Variables** | Atribuição de variáveis (ex: `VAL = 0x10`) persistentes na sessão. |
| **Bit Mirror** | Exibição visual de operações empilhadas para validar máscaras. |
| **Hover Conversion** | Janela flutuante ao passar o cursor sobre números (Hex ↔ Dec ↔ Bin). |

## 4. Roadmap de Implementação

#### Fase 1: O "Container" (UI)
* [ ] Criar o comando `:BitRepl`.
* [ ] Implementar o buffer `nofile` com mapeamento de `Enter` para disparar o cálculo.
* [ ] **Inovação:** Criar a função `render_result(line, data)` usando `nvim_buf_set_extmark` com o parâmetro `virt_lines`.
* [ ] Configurar o namespace de `extmarks` para o Virtual Text.

#### Fase 2: O "Cérebro" (Parsing)
* [ ] **Sanitizer:** Função (regex) que limpa `0b` e converte `&, |, <<` para LuaJIT.
* [ ] **Variable Store:** Tabela Lua que guarda os valores atribuídos (ex: `REG = 10`).
* [ ] **Binary Resolver:** Lógica para identificar a "Cardinalidade" (ex: encontrar o `8b` e salvar a preferência de 8 bits).
* [ ] Integrar `pcall(loadstring)` para execução segura de expressões.
* [ ] Criar a **Tabela de Símbolos** para suporte a variáveis.

### Fase 3: Visualização (Cardinalidade & Mirror)
* [ ] Lógica de auto-promoção de bits (8 → 16 → 32).
* [ ] Implementar o formatador do **Bit Mirror** no Virtual Text.
* [ ] Suporte a números negativos (Two's Complement).

#### Fase 3: A "Estética" (Mirror & Formatação)
* [ ] Gerador de strings binárias com espaços (blocos de 4 bits).
* [ ] Lógica de alinhamento do Mirror (empilhamento de strings).

### Fase 4: Ergonomia (Hover & Extras)
* [ ] Implementar o Hover Inspector (Conversor instantâneo).
* [ ] Adicionar funções de conveniência: `swap16()`, `swap32()`, `u8()`, `u16()`.


## 5. Exemplo de Operação Alvo

**Entrada do Usuário:**
```c
A = 0xAA
MASK = 8b00001111
A & MASK
```

**Saída Esperada (Virtual Text):**
```text
A = 0xAA
  └─ Hex: 0xAA | Dec: 170 | Bin: 1010 1010
MASK = 0x0F
  └─ Hex: 0x0F | Dec: 15  | Bin: 0000 1111
A & MASK
  ├─ Hex: 0x0A | Dec: 10
  └─ Mirror: 1010 1010 (A)
           & 0000 1111 (MASK)
           = 0000 1010 (RES)
```


# notes

vou dividir o operador de divisão em 2: / para divisão normal e // para divisão inteira explícita. O programa deverá tratar a divisão com binarios ou hex sempre como divisão inteira 

pipeline de parsing:
    1. Normalização de literais e operadores específicos
        - encontra `0b[01]+` e transforma no valor decimal equivalente
        - encontra // e prepara a transpilação para math.floor(a / b)
    2. Transpilação de operadores infixos
        3. Transforma `A & B` em `bit.band(A, B)`
        4. regex não lida bem com parentesis aninhados, então coisas como `(A & C) | B` será um pesadelo
    3. A execução
        4. Passar a string final (`bit.bor(bit.band(A, C), B)`) para o loadstring
        5. Anexar a tabela de símbolos, onde A B e C estão guardados a essa função usando setfenv. O luaJIT faz o resto


Podemos até usar regex para substituir as strings binárias, mas para resolver a ordem das operações vamos ter que criar uma pequena ast com uma fase de lexer (tokenizer) e outra de parser, que consome os tokens e transforma em uma AST. o programa então vai interpretar esta AST, resolver as operações e trasnpilar em uma string. Vai ser ummini compilador mesmo



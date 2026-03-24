# bitmath.nvim

**bitmath.nvim** é um REPL (Read-Eval-Print Loop) de baixo nível integrado ao Neovim. Projetado para desenvolvedores de sistemas embarcados, drivers e engenharia reversa, o plugin elimina a necessidade de calculadoras externas ao fornecer um ambiente de cálculo de bits diretamente no editor.

## Funcionalidades Principais

* **Inferência de Cardinalidade**: Diferencia e preserva contextos de 8, 16 e 32 bits automaticamente.
* **Bit Mirror**: Visualização alinhada verticalmente para operações binárias, facilitando a inspeção de máscaras.
* **Sintaxe C-Standard**: Suporte a literais hexadecimais (`0x`), binários (`0b` ou `8b`) e decimais, além de operadores como `<<`, `>>`, `&`, `|`, `^`, `~`.
* **Persistência de Variáveis**: O estado da sessão é mantido, permitindo a definição de variáveis para uso em cálculos complexos.
* **Integração com Virtual Text**: Resultados exibidos via `extmarks` do Neovim, sem alterar o conteúdo real do buffer.

## Instalação

```lua
{
    dir = "~/caminho/para/bitmath.nvim",
    dev = true,
    config = function()
        require("bitmath").setup()
    end
}
```

## Como utilizar

1. Inicie o REPL com o comando `:BitRepl`. Uma janela lateral será aberta.
2. Digite sua expressão (ex: `A = 0xAA`).
3. Pressione `<CR>` (Enter). O comando funciona tanto no modo Normal quanto no modo de Inserção.
4. O resultado será exibido imediatamente abaixo da linha digitada.

### Atalhos no Buffer BitMath
* `<CR>`: Avalia a linha atual, exibe o resultado e avança para a próxima linha.
* `:BitRepl`: Abre ou fecha a janela do REPL (Toggle).

## O Bit Mirror

O diferencial técnico do plugin é a renderização do espelho de bits em operações binárias, garantindo o alinhamento perfeito dos operandos e do resultado.

**Exemplo de Saída:**
```text
A & MASK
  ├─ 10   | 0x0A
  └─ Mirror: 8b 1010 1010 (A)
           & 8b 0000 1111 (MASK)
           = 8b 0000 1010 (RES)
```

## Arquitetura e Implementação

O projeto foi construído seguindo fundamentos de engenharia de compiladores para garantir precisão e extensibilidade:
* **Recursive Descent Parser**: Implementação manual de um parser para lidar com precedência de operadores e expressões aninhadas.
* **Abstract Syntax Tree (AST)**: As expressões são convertidas em uma árvore lógica antes da avaliação, permitindo que a camada de UI inspecione os operandos e gere o Bit Mirror de forma inteligente.
* **LuaJIT Bit Library**: Utiliza a biblioteca nativa de baixo nível do Neovim para operações de manipulação de bits.

## Desenvolvimento Assistido por IA

Este projeto foi desenvolvido com o auxílio de modelos de Inteligência Artificial para a geração de código e aceleração da implementação. No entanto, é importante ressaltar que toda a arquitetura de software, a lógica de precedência do parser, o gerenciamento de memória dos buffers e a integração com a API C do Neovim foram revisadas, corrigidas e testadas manualmente por um humano.

A IA atuou como uma ferramenta de assistência técnica, enquanto a validação final, o debugging e a garantia de estabilidade foram realizados de forma autoral para assegurar que o plugin seja confiável em ambientes de produção.


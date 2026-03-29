# bitmath.nvim

**bitmath.nvim** is a low-level Read-Eval-Print Loop (REPL) environment integrated directly into Neovim. Designed for embedded systems developers, reverse engineers, driver authors, and anyone that frequetly googles "hex calculator" in the middle of coding. It eliminates the context switch of using external calculators by providing a nice-to-look-at hardware-accurate notebook-style bitwise math environment right in your editor.

## Key Features

* **Bus Width Awareness:** Automatically infers (`0b`) or explicitly forces data widths (`8b`, `16b`, `32b`). Overflows behave like physical registers.
* **The Bit Mirror:** Vertically aligns binary operations in virtual text, allowing instant visual inspection of bitmasks and shifts.
* **C-Standard Syntax:** Native support for hex (`0x`), binary, decimal literals, and standard operators (`<<`, `>>`, `&`, `|`, `^`, `~`, `-`).
 -- Separate into a "nice to have" instead of a front page feature: * **Hardware-Accurate Unary Ops:** Strictly separates arithmetic negation (`-`, 2's complement) from bitwise inversion (`~`, 1's complement) within the defined bus width.
* **State Persistence:** Assign and reuse variables across operations in the same session.

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    "JoaoNasMonteiro/bitmath.nvim",
    config = function()
        require("bitmath").setup()
    end
}
```

For local development/manual installation, prepend the plugin directory to your `runtimepath` in your `init.lua`.

## Usage

1. Open the REPL using the `:BitMath` command.
2. Type your expression (e.g., `MASK = 0xFF00`).
3. Press `<CR>` (in Normal or Insert mode) to evaluate and advance to the next line.
4. The result renders instantly as Virtual Text.

### Default Keymaps
* `<leader>bm`: Toggle BitMath window
* `<leader>be`: Show all variables in Memory

## The Bit Mirror

The core visual feature of the plugin. When executing binary operations, `bitmath.nvim` renders a perfectly aligned mirror of the operands, making mask validation effortless.

**Input:**
```c
REG = 0xDEAF
MSK = 16b1111111100000000
REG & MSK
```

**Output:**
```text
REG & MSK
  ├─ 57088 | 0xDF00
  └─ 16b 1101 1110 1010 1111
   & 16b 1111 1111 0000 0000
   = 16b 1101 1111 0000 0000
```

## Architecture

This plugin is built on compiler engineering fundamentals rather than naive string evaluation:
* **Recursive Descent Parser:** A custom lexer and parser handle operator precedence and nested expressions natively.
* **Abstract Syntax Tree (AST):** Expressions are compiled into a tree format, allowing the UI layer to intelligently extract operands for the Bit Mirror.
* **LuaJIT BitOp:** Leverages Neovim's native low-level bitwise library for performance and accuracy.

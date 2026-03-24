-- test_evaluator.lua

package.path = "../lua/?.lua;../lua/?/init.lua;" .. package.path
local parser = require("bitmath.parser")
local evaluator = require("bitmath.evaluator")

-- Uma função auxiliar para encapsular o pipeline completo
local function run(input)
	print("> " .. input)
	-- 1. Parsing
	local ast = parser.parse(input)
	-- 2. Avaliação
	local result = evaluator.evaluate(ast)
	print(string.format("  Dec: %d | Hex: %s | Bin: %s", result.value, result:to_hex_string(), result:to_bin_string())) -- 3. Impressão do resultado
end

-- Teste 1: Atribuição simples
run("A = 0x0F")

-- Teste 2: Operação lógica com shift (A árvore que testamos antes)
run("MASK = (A & 0xFF) << 2")

-- Teste 3: Recuperando o valor persistido
run("MASK + 1")

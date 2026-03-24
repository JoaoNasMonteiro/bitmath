-- test_lexer.lua

package.path = "../lua/?.lua;../lua/?/init.lua;" .. package.path

-- 2. Importamos o nosso módulo
local lexer = require("bitmath.lexer")

-- 3. A string de teste (o caso de uso complexo)
local input = "A = 0xAA & (10 << 2)"

print("Testando a entrada: " .. input)
print(string.rep("-", 40))

-- 4. Rodamos o lexer
local tokens = lexer.tokenize(input)

-- 5. Imprimimos o resultado de forma formatada (estilo hexdump/struct print do C)
for i, token in ipairs(tokens) do
	-- %02d   : Inteiro com 2 casas e zero à esquerda (ex: 01)
	-- %-12s  : String alinhada à esquerda com 12 espaços (padding)
	-- '%s'   : A string do valor entre aspas simples para visualizarmos espaços se houver
	print(string.format("[%02d] %-12s : '%s'", i, token.type, token.value))
end

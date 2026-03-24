-- test_parser.lua

package.path = "../lua/?.lua;../lua/?/init.lua;" .. package.path
local parser = require("bitmath.parser")

--- Função auxiliar para imprimir a AST (Tabelas aninhadas) de forma legível
local function print_ast(node, indent)
    indent = indent or ""
    if type(node) ~= "table" then
        print(indent .. tostring(node))
        return
    end

    print(indent .. "{")
    for k, v in pairs(node) do
        if type(v) == "table" then
            print(indent .. "  " .. k .. " = ")
            print_ast(v, indent .. "  ")
        else
            print(indent .. "  " .. k .. " = " .. tostring(v))
        end
    end
    print(indent .. "}")
end

-- Vamos testar a atribuição complexa descrita no seu escopo
local input = "MASK = (0x0F & A) << 2"
print("Testando Parsing de: " .. input)
print(string.rep("-", 40))

local ast = parser.parse(input)
print_ast(ast)

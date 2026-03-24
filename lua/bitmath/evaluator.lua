local bit = require("bit")
local BitNum = {}
BitNum.__index = BitNum
local function infer_cardinality(value)
	if value < 0 then
		return 32
	end
	if value <= 0xFF then
		return 8
	end
	if value <= 0xFFFF then
		return 16
	end
	return 32
end
function BitNum.new(value, explicit_cardinality)
	local self = setmetatable({}, BitNum)
	self.value = value
	self.cardinality = explicit_cardinality or infer_cardinality(value)
	return self
	local hex_digits = math.max(2, math.ceil(self.cardinality / 4))
	return string.format("0x%0" .. hex_digits .. "X", self.value)
function BitNum:to_bin_string(target_cardinality)
	local bits = {}
	local card = target_cardinality or self.cardinality
	for i = card - 1, 0, -1 do
		local mask = bit.lshift(1, i)
		if bit.band(self.value, mask) ~= 0 then
			table.insert(bits, "1")
		else
			table.insert(bits, "0")
		end
		if i % 4 == 0 and i ~= 0 then
			table.insert(bits, " ")
		end
	end
	return tostring(card) .. "b " .. table.concat(bits)
function M.evaluate(node)
	if not node then
		return nil
	end
		local val = tonumber(node.value)
		if not val then
			error("Erro de Execução: Literal inválido '" .. tostring(node.value) .. "'")
		end
		return BitNum.new(val)
	elseif node.type == "IdentifierNode" then
		local val = M.variables[node.name]
		if not val then
			error("Erro de Execução: Variável '" .. node.name .. "' não declarada.")
		end
		return val
	elseif node.type == "UnaryOpNode" then
		local operand = M.evaluate(node.operand)
		local res_val
		if node.operator == "-" then
			res_val = -operand.value
		elseif node.operator == "~" then
			res_val = bit.bnot(operand.value)
		else
			error("Erro de Execução: Operador unário desconhecido '" .. node.operator .. "'")
		return BitNum.new(res_val, operand.cardinality)
	elseif node.type == "BinaryOpNode" then
		local left = M.evaluate(node.left)
		local right = M.evaluate(node.right)
		local res_cardinality = math.max(left.cardinality, right.cardinality)
		local op = node.operator
		if op == "+" then
			res_val = left.value + right.value
		elseif op == "-" then
			res_val = left.value - right.value
		elseif op == "*" then
			res_val = left.value * right.value
		elseif op == "/" then
			res_val = left.value / right.value
		elseif op == "//" then
			res_val = math.floor(left.value / right.value)
		elseif op == "%" then
			res_val = left.value % right.value
		elseif op == "&" then
			res_val = bit.band(left.value, right.value)
		elseif op == "|" then
			res_val = bit.bor(left.value, right.value)
		elseif op == "^" then
			res_val = bit.bxor(left.value, right.value)
		elseif op == "<<" then
			res_val = bit.lshift(left.value, right.value)
		elseif op == ">>" then
			res_val = bit.rshift(left.value, right.value)
		else
			error("Erro de Execução: Operador binário desconhecido '" .. op .. "'")
		end
		return BitNum.new(res_val, res_cardinality)
		local right_val = M.evaluate(node.value_node)
		M.variables[node.variable] = right_val
		return right_val
	end
	error("Erro de Execução: Tipo de nó desconhecido '" .. tostring(node.type) .. "'")
end
return M

local lexer = require("bitmath.lexer")
local M = {}

local Parser = {}
Parser.__index = Parser

function Parser.new(tokens)
	local self = setmetatable({}, Parser)
	self.tokens = tokens
	self.pos = 1
	self.current_token = self.tokens[self.pos]
	return self
end

function Parser:advance()
	if self.current_token.type ~= lexer.TokenType.EOF then
		self.pos = self.pos + 1
		self.current_token = self.tokens[self.pos]
	end
end

function Parser:eat(expected_type)
	if self.current_token.type == expected_type then
		local token = self.current_token
		self:advance()
		return token
	else
		error("Erro de Sintaxe: Esperado " .. expected_type .. ", mas recebido " .. self.current_token.type)
	end
end

function Parser:parse_primary()
	local token = self.current_token
	if token.type == lexer.TokenType.NUMBER then
		self:eat(lexer.TokenType.NUMBER)
		return { type = "LiteralNode", value = token.value }
	elseif token.type == lexer.TokenType.IDENTIFIER then
		self:eat(lexer.TokenType.IDENTIFIER)
		return { type = "IdentifierNode", name = token.value }
	elseif token.type == lexer.TokenType.LPAREN then
		self:eat(lexer.TokenType.LPAREN)
		local node = self:parse_expression()
		self:eat(lexer.TokenType.RPAREN)
		return node
	end
	error("Erro de Sintaxe: Token inesperado '" .. token.value .. "'")
end

function Parser:parse_unary()
	local token = self.current_token
	if token.type == lexer.TokenType.OPERATOR and (token.value == "-" or token.value == "~") then
		self:eat(lexer.TokenType.OPERATOR)
		local operand_node = self:parse_unary()
		return {
			type = "UnaryOpNode",
			operator = token.value,
			operand = operand_node,
		}
	end
	return self:parse_primary()
end

function Parser:parse_factor()
	local left_node = self:parse_unary()
	local valid_ops = { ["*"] = true, ["/"] = true, ["//"] = true, ["%"] = true }
	while self.current_token.type == lexer.TokenType.OPERATOR and valid_ops[self.current_token.value] do
		local op = self.current_token.value
		self:eat(lexer.TokenType.OPERATOR)
		local right_node = self:parse_unary()
		left_node = {
			type = "BinaryOpNode",
			operator = op,
			left = left_node,
			right = right_node,
		}
	end
	return left_node
end

function Parser:parse_term()
	local left_node = self:parse_factor()
	while
		self.current_token.type == lexer.TokenType.OPERATOR
		and (self.current_token.value == "+" or self.current_token.value == "-")
	do
		local op = self.current_token.value
		self:eat(lexer.TokenType.OPERATOR)
		local right_node = self:parse_factor()
		left_node = { type = "BinaryOpNode", operator = op, left = left_node, right = right_node }
	end
	return left_node
end

function Parser:parse_shift()
	local left_node = self:parse_term()
	while
		self.current_token.type == lexer.TokenType.OPERATOR
		and (self.current_token.value == "<<" or self.current_token.value == ">>")
	do
		local op = self.current_token.value
		self:eat(lexer.TokenType.OPERATOR)
		local right_node = self:parse_term()
		left_node = { type = "BinaryOpNode", operator = op, left = left_node, right = right_node }
	end
	return left_node
end

function Parser:parse_bitwise_and()
	local left_node = self:parse_shift()
	while self.current_token.type == lexer.TokenType.OPERATOR and self.current_token.value == "&" do
		self:eat(lexer.TokenType.OPERATOR)
		local right_node = self:parse_shift()
		left_node = { type = "BinaryOpNode", operator = "&", left = left_node, right = right_node }
	end
	return left_node
end

function Parser:parse_bitwise_xor()
	local left_node = self:parse_bitwise_and()
	while self.current_token.type == lexer.TokenType.OPERATOR and self.current_token.value == "^" do
		self:eat(lexer.TokenType.OPERATOR)
		local right_node = self:parse_bitwise_and()
		left_node = { type = "BinaryOpNode", operator = "^", left = left_node, right = right_node }
	end
	return left_node
end

function Parser:parse_bitwise_or()
	local left_node = self:parse_bitwise_xor()
	while self.current_token.type == lexer.TokenType.OPERATOR and self.current_token.value == "|" do
		self:eat(lexer.TokenType.OPERATOR)
		local right_node = self:parse_bitwise_xor()
		left_node = { type = "BinaryOpNode", operator = "|", left = left_node, right = right_node }
	end
	return left_node
end

function Parser:parse_expression()
	return self:parse_bitwise_or()
end

function Parser:parse_statement()
	if self.current_token.type == lexer.TokenType.IDENTIFIER then
		local var_name = self.current_token.value
		local next_token = self.tokens[self.pos + 1]
		if next_token and next_token.type == lexer.TokenType.OPERATOR and next_token.value == "=" then
			self:eat(lexer.TokenType.IDENTIFIER)
			self:eat(lexer.TokenType.OPERATOR)
			local right_node = self:parse_expression()
			return {
				type = "AssignmentNode",
				variable = var_name,
				value_node = right_node,
			}
		end
	end
	return self:parse_expression()
end

local function normalize_literals(instr)
	local out_str = instr
	out_str = out_str:gsub("0b([01]+)", function(binary_str)
		return tostring(tonumber(binary_str, 2))
	end)
	return out_str
end

function M.parse(input)
	local clean_input = normalize_literals(input)
	local tokens = lexer.tokenize(clean_input)
	local parser = Parser.new(tokens)
	return parser:parse_statement()
end

return M

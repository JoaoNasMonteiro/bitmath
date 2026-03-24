local M = {}

M.TokenType = {
	NUMBER = "NUMBER",
	IDENTIFIER = "IDENTIFIER",
	OPERATOR = "OPERATOR",
	LPAREN = "LPAREN",
	RPAREN = "RPAREN",
	EOF = "EOF",
}

function M.tokenize(input)
	local tokens = {}
	local pos = 1
	local len = #input

	local function current()
		return input:sub(pos, pos)
	end

	local function advance()
		pos = pos + 1
	end

	local function is_space(c)
		return c:match("%s")
	end
	local function is_digit(c)
		return c:match("%d")
	end
	local function is_alpha(c)
		return c:match("[%a_]")
	end
	local function is_alnum(c)
		return c:match("[%w_]")
	end

	while pos <= len do
		local c = current()

		if is_space(c) then
			advance()
		elseif is_alpha(c) then
			local start_pos = pos
			while pos <= len and is_alnum(current()) do
				advance()
			end
			table.insert(tokens, { type = M.TokenType.IDENTIFIER, value = input:sub(start_pos, pos - 1) })
		elseif c == "0" and input:sub(pos + 1, pos + 1):lower() == "x" then
			local start_pos = pos
			advance()
			advance()
			while pos <= len and current():match("[%da-fA-F]") do
				advance()
			end
			table.insert(tokens, { type = M.TokenType.NUMBER, value = input:sub(start_pos, pos - 1) })
		elseif is_digit(c) then
			local start_pos = pos
			while pos <= len and is_digit(current()) do
				advance()
			end
			if current() == "b" then
				advance()
				while pos <= len and (current() == "0" or current() == "1") do
					advance()
				end
				table.insert(tokens, { type = M.TokenType.NUMBER, value = input:sub(start_pos, pos - 1) })
			else
				table.insert(tokens, { type = M.TokenType.NUMBER, value = input:sub(start_pos, pos - 1) })
			end
		elseif c == "(" then
			table.insert(tokens, { type = M.TokenType.LPAREN, value = "(" })
			advance()
		elseif c == ")" then
			table.insert(tokens, { type = M.TokenType.RPAREN, value = ")" })
			advance()
		else
			local next_c = input:sub(pos + 1, pos + 1)
			local double_op = c .. next_c
			if double_op == "<<" or double_op == ">>" or double_op == "//" then
				table.insert(tokens, { type = M.TokenType.OPERATOR, value = double_op })
				pos = pos + 2
			else
				table.insert(tokens, { type = M.TokenType.OPERATOR, value = c })
				advance()
			end
		end
	end

	table.insert(tokens, { type = M.TokenType.EOF, value = "" })
	return tokens
end

return M

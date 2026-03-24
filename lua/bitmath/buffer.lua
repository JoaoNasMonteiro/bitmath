local api = vim.api
local parser = require("bitmath.parser")
local evaluator = require("bitmath.evaluator")
local state = {
	bufnr = nil,
	winid = nil,
	ns_id = api.nvim_create_namespace("bitmath_repl"),
}
local function evaluate_current_line()
	local cursor = api.nvim_win_get_cursor(0)
	local row = cursor[1] - 1
	local line_text = api.nvim_buf_get_lines(state.bufnr, row, row + 1, false)[1]
	if not line_text or line_text:match("^%s*$") then
		return
	end
	local ast
	local success, result_or_err = pcall(function()
		ast = parser.parse(line_text)
		return evaluator.evaluate(ast)
	end)
	local virt_lines = {}
	if not success then
		virt_lines = { { { "  └─ Erro: " .. tostring(result_or_err), "DiagnosticError" } } }
	elseif result_or_err then
		local dec = tostring(result_or_err.value)
		local hex = result_or_err:to_hex_string()
		local is_mirror = false
		local target_node = ast
		if ast.type == "AssignmentNode" then
			target_node = ast.value_node
		end
		if target_node and target_node.type == "BinaryOpNode" then
			is_mirror = true
			local left_name = target_node.left.type == "IdentifierNode" and target_node.left.name or "VAL"
			local right_name = target_node.right.type == "IdentifierNode" and target_node.right.name or "VAL"
			local left_val = evaluator.evaluate(target_node.left)
			local target_card = result_or_err.cardinality
			local left_bin = left_val:to_bin_string(target_card)
			local right_bin = right_val:to_bin_string(target_card)
			local pad = string.rep(" ", 11)
			table.insert(mirror_lines, { { string.format("  └─ Mirror: %s (%s)", left_bin, left_name), "String" } })
			table.insert(mirror_lines, { { string.format("%s%2s %s (%s)", pad, op, right_bin, right_name), "String" } })
			table.insert(mirror_lines, { { string.format("%s = %s (RES)", pad, res_bin), "String" } })
			table.insert(virt_lines, { { string.format("  ├─ %-4s | %-6s", dec, hex), "Comment" } })
			for _, m_line in ipairs(mirror_lines) do
				table.insert(virt_lines, m_line)
			end
			table.insert(virt_lines, { { string.format("  └─ %-4s | %-6s | %s", dec, hex, bin), "Comment" } })
		end
	end
	if #virt_lines > 0 then
		api.nvim_buf_set_extmark(state.bufnr, state.ns_id, row, 0, {
			virt_lines = virt_lines,
			virt_lines_above = false,
		})
	end
	local line_count = api.nvim_buf_line_count(state.bufnr)
	if cursor[1] == line_count then
		api.nvim_buf_set_lines(state.bufnr, -1, -1, false, { "" })
	end
	api.nvim_win_set_cursor(0, { cursor[1] + 1, 0 })
local function setup_buffer()
	if not state.bufnr or not api.nvim_buf_is_valid(state.bufnr) then
		state.bufnr = api.nvim_create_buf(false, true)
		api.nvim_set_option_value("buftype", "nofile", { buf = state.bufnr })
		api.nvim_set_option_value("bufhidden", "hide", { buf = state.bufnr })
		api.nvim_set_option_value("swapfile", false, { buf = state.bufnr })
		api.nvim_set_option_value("filetype", "bitmath", { buf = state.bufnr })
		vim.keymap.set("n", "<CR>", evaluate_current_line, {
			buffer = state.bufnr,
			desc = "Avaliar linha no BitMath",
		})
	end
	return state.bufnr
function M.toggle_repl()
	if state.winid and api.nvim_win_is_valid(state.winid) then
		api.nvim_win_close(state.winid, true)
		state.winid = nil
		return
	vim.cmd("vsplit")
	vim.cmd("vertical resize 40")
	state.winid = api.nvim_get_current_win()
	api.nvim_win_set_buf(state.winid, bufnr)
	api.nvim_set_current_win(state.winid)
end
return M

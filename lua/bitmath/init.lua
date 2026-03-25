local evaluator = require("bitmath.evaluator")
local buffer = require("bitmath.buffer")
local config = require("bitmath.config")

local M = {}

M.toggle = function()
	buffer.toggle_repl()
end

M.show_env = function()
	local vars = evaluator.variables
	if vim.tbl_isempty(vars) then
		vim.api.nvim_echo({ { "BitMath: No Variables in Memory.", "WarningMsg" } }, false, {})
		return
	end

	local chunks = { { "--- BitMath Environment (Symbol Table) ---\n", "Title" } }

	for name, bitnum in pairs(vars) do
		local dec = tostring(bitnum.value)
		local hex = bitnum:to_hex_string()
		local bin = bitnum:to_bin_string()
		local line = string.format("%-10s = %-6s | %-8s | %s\n", name, dec, hex, bin)
		table.insert(chunks, { line, "String" })
	end

	vim.api.nvim_echo(chunks, false, {})
end

local function apply_commands()
	vim.api.nvim_create_user_command("BitMath", M.toggle, { desc = "Toggles BitMath REPL" })
	vim.api.nvim_create_user_command("BitEnv", M.show_env, { desc = "Shows Variables in Memory" })
end

local function apply_keymaps(opts)
	local maps = opts.keymaps or {}

	if type(maps.toggle_repl) == "string" and maps.toggle_repl ~= "" then
		vim.keymap.set("n", maps.toggle_repl, M.toggle, { desc = "Toggle BitMath REPL" })
	end

	if type(maps.show_env) == "string" and maps.show_env ~= "" then
		vim.keymap.set("n", maps.show_env, M.show_env, { desc = "Show BitMath Environment" })
	end
end

function M.setup(user_opts)
	local opts = vim.tbl_deep_extend("force", config.defaults, user_opts or {})

	apply_commands()
	apply_keymaps(opts)
end

return M

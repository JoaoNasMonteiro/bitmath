local M = {}
	vim.api.nvim_create_user_command("BitRepl", function()
		require("bitmath.buffer").toggle_repl()
	end, {})
end
return M

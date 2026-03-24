local M = {}

M.setup = function(opts)
    vim.api.nvim_create_user_command("Bitmath", function()
        require("bitmath.buffer").toggle_repl()
    end, {})
end

return M

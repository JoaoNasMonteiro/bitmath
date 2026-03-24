-- lua/bitmath/init.lua

local M = {}

M.setup = function(opts)
    -- Cria o comando de usuário :BitRepl
    vim.api.nvim_create_user_command("BitRepl", function()
        require("bitmath.buffer").toggle_repl()
    end, {})
end

return M

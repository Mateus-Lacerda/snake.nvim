-- auto‑carregado pelo Neovim
local game = require("snake_game")   -- lua/snake_game/init.lua

vim.api.nvim_create_user_command("SnakeGame", function(opts)
    -- permite passar opções on‑the‑fly:  :SnakeGame nerd_font=true
    local cfg = {}
    for _, kv in ipairs(opts.fargs) do
        local k, v = kv:match("([^=]+)=(.+)")
        if k then cfg[k] = (v == "true") or (v ~= "false" and v) end
    end

    if next(cfg) then
        game.setup(cfg)
    end

    game.start_game()
end, {
    nargs = "*",
    complete = function(_, _, _)
        -- completa nomes de opções
        return { "nerd_font=", "use_wasd=", "use_arrow_keys=" }
    end,
})

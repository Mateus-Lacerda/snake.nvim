local M = {}

-----------------------------------------------------------------------
-- LOCAL PATH HELPERS -------------------------------------------------
-----------------------------------------------------------------------
local function runtime_file(path)
    local files = vim.api.nvim_get_runtime_file(path, false)
    return (#files > 0) and files[1] or nil
end

local game_path = runtime_file("lua/snake_game/game.lua")
assert(game_path, "snake_game/game.lua not found in runtimepath")

-- dirname that works on all OS
local game_dir = vim.fn.fnamemodify(game_path, ":h")

-- folder to store user files (config / highscore)
local state_base = vim.fn.stdpath("state")
if state_base == "" or not vim.loop.fs_stat(state_base) then
    state_base = vim.fn.stdpath("data") -- fallback for Neovim 0.9
end
local user_dir = state_base .. "/snake_game"
vim.fn.mkdir(user_dir, "p") -- "p" = create parents

local CONFIG_FILE    = user_dir .. "/config.txt"
local HIGHSCORE_FILE = user_dir .. "/highscore.txt"

-----------------------------------------------------------------------
-- FLOATING TERMINAL --------------------------------------------------
-----------------------------------------------------------------------
local function create_floating_terminal()
    local buf         = vim.api.nvim_create_buf(false, true)

    local cols, lines = vim.o.columns, vim.o.lines
    local width       = math.floor(cols * 0.8)
    local height      = math.floor(lines * 0.8)
    local row         = math.floor((lines - height) / 2)
    local col         = math.floor((cols - width) / 2)

    local win         = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width    = width,
        height   = height,
        row      = row,
        col      = col,
        style    = "minimal",
        border   = "rounded",
    })

    vim.api.nvim_set_current_win(win)

    -- agora garantido: game_dir é um diretório válido
    vim.fn.jobstart({ "lua", game_path }, {
        cwd  = game_dir,
        term = true,
        env  = {
            SNAKE_CFG = CONFIG_FILE,
            SNAKE_HS  = HIGHSCORE_FILE,
        },
    })

    vim.cmd("startinsert")
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = buf, silent = true })
end

-----------------------------------------------------------------------
-- CONFIG -------------------------------------------------------------
-----------------------------------------------------------------------
function M.setup(cfg)
    local f = io.open(CONFIG_FILE, "w")
    if not f then
        vim.notify("SnakeGame: cannot write " .. CONFIG_FILE, vim.log.levels.ERROR)
        return
    end
    for k, v in pairs(cfg or {}) do
        f:write(k .. "=" .. tostring(v) .. "\n")
    end
    f:close()
end

function M.start_game()
    create_floating_terminal()
end

return M

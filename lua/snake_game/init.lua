local M = {}

-- 1. ache o game.lua dentro da runtimepath
local game_path = vim.api.nvim_get_runtime_file("lua/snake_game/game.lua", false)[1]
local game_dir  = vim.fn.fnamemodify(game_path, ":h")

-- 2. pasta do usuário para configs/saves
local user_dir  = vim.fn.stdpath("state") .. "/snake_game"
vim.fn.mkdir(user_dir, "p")   -- cria se não existir

-----------------------------------------------------------------------
-- FLOATING TERMINAL --------------------------------------------------
-----------------------------------------------------------------------
local function create_floating_terminal()
  local buf = vim.api.nvim_create_buf(false, true)

  local cols, lines = vim.o.columns, vim.o.lines
  local width  = math.floor(cols  * 0.8)
  local height = math.floor(lines * 0.8)
  local row    = math.floor((lines - height) / 2)
  local col    = math.floor((cols  - width)  / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width    = width,
    height   = height,
    row      = row,
    col      = col,
    style    = "minimal",
    border   = "rounded",
  })

  vim.api.nvim_set_current_win(win)

  -- cwd = game_dir (ex.: ~/.local/share/nvim/lazy/snake.nvim/lua/snake_game)
  vim.fn.jobstart({ "lua", game_path }, {
    cwd  = game_dir,
    term = true,
    env  = {            -- passa caminhos de usuário para o script lua
      SNAKE_CFG = user_dir .. "/config.txt",
      SNAKE_HS  = user_dir .. "/highscore.txt",
    },
  })

  vim.cmd("startinsert")
  vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = buf, silent = true })
end

-----------------------------------------------------------------------
-- CONFIG -------------------------------------------------------------
-----------------------------------------------------------------------
function M.setup(cfg)
  local path = user_dir .. "/config.txt"
  local f = io.open(path, "w")
  if not f then
    vim.notify("SnakeGame: cannot write " .. path, vim.log.levels.ERROR)
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

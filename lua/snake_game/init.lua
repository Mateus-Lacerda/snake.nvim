local M = {}

local game_path = vim.fn.stdpath("config") .. "/lua/snake_game/game.lua"
local game_dir  = vim.fn.fnamemodify(game_path, ":h")

local function create_floating_terminal()
  -- 1. buffer “rascunho”
  local buf = vim.api.nvim_create_buf(false, true)

  -- 2. janela flutuante
  local cols, lines = vim.o.columns, vim.o.lines
  local width  = math.floor(cols * 0.8)
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

  -- 3. torna o buffer corrente *antes* de jobstart()
  vim.api.nvim_set_current_win(win)

  -- 4. inicia o terminal no _mesmo_ buffer
  vim.fn.jobstart({ "lua", game_path }, {
    cwd  = game_dir,
    term = true,         -- precisa ser booleano
  })

  -- entra em modo insert
  vim.cmd("startinsert")

  -- mapeia <q> para fechar
  vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = buf, silent = true })
end

function M.setup(cfg)
  local f = io.open(game_dir .. "/config.txt", "w")
  if not f then
    vim.notify("SnakeGame: não consegui gravar config.txt", vim.log.levels.ERROR)
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

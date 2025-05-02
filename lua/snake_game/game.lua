local CONFIG     = os.getenv("SNAKE_CFG") or (debug.getinfo(1,"S").source:sub(2):match("(.*/)") .. "config.txt")
local HIGHSCORE  = os.getenv("SNAKE_HS")  or (debug.getinfo(1,"S").source:sub(2):match("(.*/)") .. "highscore.txt")


-- Description: This function clears the terminal screen.
local function clear()
    os.execute("clear")
end

function table.shallow_copy(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end

local function print_menu(score, nerd_font, highscore)
    print(string.format("   +%s+", string.rep('-', 36)))
    if nerd_font then
        print("   | Welcome to the Snake Game! 󱔎       |")
    else
        print("   | Welcome to the Snake Game!         |")
    end
    print(string.format("   +%s+", string.rep('-', 36)))
    print("   | Press 'q' to exit the game.        |")
    print(string.format("   +%s+", string.rep('-', 36)))
    print("   | Use h, j, k, l to navigate.        |")
    print(string.format("   +%s+", string.rep('-', 36)))
    print(string.format("   | Score: %d%s|", score, string.rep(" ", 28 - #tostring(score))))
    if score > highscore then
        highscore = score
    end
    print(string.format("   | Highscore: %d%s|", highscore, string.rep(" ", 24 - #tostring(highscore))))
end

-- Description: This function prints the grid layout.
-- Parameters:
-- game_state: A table containing the current state of the game.
-- Returns: None
local function print_grid(game_state, nerd_font, game_over, highscore)
    clear()
    print_menu(game_state.player_size, nerd_font, highscore)
    -- print(string.format("+%s+", string.rep('-', 36)))
    local boundary = {"+", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "+",}
    local line = {"|", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", "|",}
    local grid = {
        boundary,
        table.shallow_copy(line),
        table.shallow_copy(line),
        table.shallow_copy(line),
        table.shallow_copy(line),
        table.shallow_copy(line),
        table.shallow_copy(line),
        table.shallow_copy(line),
        table.shallow_copy(line),
        table.shallow_copy(line),
        table.shallow_copy(line),
        table.shallow_copy(line),
        table.shallow_copy(line),
        table.shallow_copy(line),
        table.shallow_copy(line),
        table.shallow_copy(line),
        table.shallow_copy(line),
        table.shallow_copy(line),
        table.shallow_copy(line),
        boundary,
    }
    -- Desenha a cauda do jogador
    local player_tail_symbol = "o"
    local player_symbol = "O"
    local apple_symbol = "@"
    if nerd_font then
        player_tail_symbol = ""
        player_symbol = "󱓻"
        apple_symbol = ""
    end
    for i = 1, #game_state.player_tail do
        local tail_segment = game_state.player_tail[i]
        grid[tail_segment.y + 1][tail_segment.x + 1] = player_tail_symbol
    end
    -- Desenha o jogador
    grid[game_state.player.y + 1][game_state.player.x + 1] = player_symbol
    -- Desenha a maçã
    grid[game_state.apple.y + 1][game_state.apple.x + 1] = apple_symbol

    for i = 1, #grid do
        for j = 1, #grid[i] do
            if game_over and i == 9 then
                print("|     Game Over! Press 'r' to restart.     |")
                goto continue
            else
                io.write(grid[i][j])
            end
        end
        io.write("\n")
        ::continue::
    end
end

local function set_raw_mode()
    os.execute("stty raw -echo") -- Configura o terminal no modo raw
end

local function reset_mode()
    os.execute("stty sane") -- Restaura o terminal para o estado padrão
end

local function get_input(use_wasd, use_arrow_keys, game_over)
    set_raw_mode()
    local input = io.read(1) -- Lê um único caractere
    reset_mode()

    if input == "q" then
        return input
    -- Vim-like keys
    elseif input == "k" then
        return "up"
    elseif input == "j" then
        return "down"
    elseif input == "l" then
        return "right"
    elseif input == "h" then
        return "left"
    -- wasd
    elseif input == "w" and use_wasd then
        return "up"
    elseif input == "s" and use_wasd then
        return "down"
    elseif input == "d" and use_wasd then
        return "right"
    elseif input == "a" and use_wasd then
        return "left"
    -- Arrow keys
    elseif input == "\27" and use_arrow_keys then
        local seq = io.read(2) -- Lê os próximos dois caracteres para teclas de seta
        if seq == "k" then
            return "up"
        elseif seq == "j" then
            return "down"
        elseif seq == "l" then
            return "right"
        elseif seq == "h" then
            return "left"
        end
    elseif input == "r" and game_over then
        return input
    end
    return nil -- Retorna nil para entradas não correspondentes
end

local function update_tail(game_state, inpt)
    if inpt == nil then
        return
    end
    for i = #game_state.player_tail, 2, -1 do
        game_state.player_tail[i] = game_state.player_tail[i - 1]
    end
    game_state.player_tail[1] = { x = game_state.player.x, y = game_state.player.y }
end

local function check_collision(game_state, inpt, game_over)
    if game_state.player.x < 1 then
        game_state.player.x = 41
    elseif game_state.player.x > 41 then
        game_state.player.x = 1
    end
    if game_state.player.y < 1 then
        game_state.player.y = 18
    elseif game_state.player.y > 18 then
        game_state.player.y = 1
    end
    update_tail(game_state, inpt)
    for i = 2, #game_state.player_tail do
        if game_state.player.x == game_state.player_tail[i].x and game_state.player.y == game_state.player_tail[i].y then
            game_over = true
            break
        end
    end
    if game_state.player.x == game_state.apple.x and game_state.player.y == game_state.apple.y then
        game_state.apple.x = math.random(1, 36)
        game_state.apple.y = math.random(1, 18)
        game_state.player_size = game_state.player_size + 1
        table.insert(game_state.player_tail, { x = game_state.player.x, y = game_state.player.y })
    end
    return game_over
end

local function init_game_state()
    return {
        player = { x = 1, y = 1 },
        player_size = 1,
        player_tail = {},
        apple = { x = math.random(1, 36), y = math.random(1, 18) },
    }
end

local function handle_movement(game_state, inpt)
    if inpt == "up" then
        game_state.player.y = game_state.player.y - 1
    elseif inpt == "down" then
        game_state.player.y = game_state.player.y + 1
    elseif inpt == "left" then
        game_state.player.x = game_state.player.x - 1
    elseif inpt == "right" then
        game_state.player.x = game_state.player.x + 1
    end
end

local function load_highscore()
    local file = io.open(HIGHSCORE, "r")
    if file then
        local score = file:read("*n")
        file:close()
        return score or 0
    else
        return 0
    end
end

local function save_highscore(score)
    local highscore = load_highscore()
    if score > highscore then
        highscore = score
    end
    local file = io.open(HIGHSCORE, "w")
    if file then
        file:write(tostring(highscore))
        file:close()
    else
        print("Error saving high score.")
    end
end

local function load_config()
    local config_file = io.open(CONFIG, "r")
    if not config_file then
        print("Error: Could not open config file.")
        return {}
    end
    local config_content = config_file:read("*a")
    config_file:close()
    local config = {}
    for line in config_content:gmatch("[^\r\n]+") do
        local key, value = line:match("([^=]+)=([^=]+)")
        if key and value then
            if value == "true" then
                config[key] = true
            elseif value == "false" then
                config[key] = false
            else
                config[key] = value
            end
        end
    end
    return config
end

local function main()
    local config = load_config()
    local game_state = init_game_state()
    local use_wasd = config.use_wasd or false
    local use_arrow_keys = config.use_arrow_keys or false
    local nerd_font = config.nerd_font or true
    local game_over = false
    local highscore = load_highscore()

    while true do
        print_grid(game_state, nerd_font, game_over, highscore)
        local inpt = get_input(use_wasd, use_arrow_keys, game_over)
        if inpt == "q" then
            save_highscore(game_state.player_size)
            print("Exiting...")
            os.exit()
        end
        if game_over then
            if inpt == "r" then
                save_highscore(game_state.player_size)
                highscore = load_highscore()
                game_state = init_game_state()
                game_over = false
            end
            goto continue
        end
        handle_movement(game_state, inpt)
        game_over = check_collision(game_state, inpt, game_over)
    ::continue::
    end
end

return main()

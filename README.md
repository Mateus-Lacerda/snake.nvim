# Snake Game Plugin for Neovim

This is a simple Snake Game plugin for Neovim. It allows you to play a classic snake game directly inside a floating terminal window in Neovim.

## Features

- Play Snake Game in a floating terminal.
- Minimalistic and distraction-free interface.
- Vim keybindings for navigation.
    - Use `h`, `j`, `k`, `l` to move the snake.
    - Use `w`, `a`, `s`, `d` to move the snake.
    - Use the arrow keys if you're a quitter.
    - Use `q` to quit the game.

> [!NOTE]
    [Nerd Fonts](https://www.nerdfonts.com/) are recommended for better visuals, but not required. \
    To play without Nerd Fonts, you need to set the `nerd_font` option to `false` in the configuration. \
    To use wasd keys, you need to set the `wasd` option to `true` in the configuration. \
    To use arrow keys, you need to set the `arrow_keys` option to `true` in the configuration.

## Installation

### Using `lazy.nvim`

```lua
{
    'Mateus-Lacerda/snake-game',
    config = function()
        require('snake_game').setup({
            nerd_font = true, -- Set to false if you don't want to use Nerd Fonts
        })
    end
}
```

### Using `packer.nvim`

```lua
use {
    'Mateus-Lacerda/snake-game',
    config = function()
        require('snake_game').setup({
            nerd_font = true, -- Set to false if you don't want to use Nerd Fonts
        })
    end
}
```

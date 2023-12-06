# clh.nvim
Execute code lenses from everywhere.

Code lenses are available at specific lines, such code lenses are run or debug an application or test. To avoid always jump back to the code lense position to execute a lens this plugin registered already executed lenses and makes those available from everywhere.

Note:
Actually just tested with scala-lang code lenses.

## Installation
lazy.nvim:
```lua
{
  'svschen/clh.nvim',
  -- Optional config
  opts = {
    history = {
      maxLength = 5
    },
    ui = {
      width = 0.9
    }
  } 
}
```

## Quick start
Re/define a keymap to either:
- register and run a code lens on a code lense
- execute the ui to select already registered code lenses otherwise

```lua
vim.keymap.set(
  "n",
  "<leader>cl",
  function()
    return require("clh").registerAndRunCodeLens() or require("telescope").extensions.clh.selectCodeLens()
  end,
  { desc = "Register and run or select code lens" })
```

## Options
```lua
require("clh").setup({
  -- code lense history config
  history = {
    -- set max registered code lenes
    maxLength = 10
  },
  -- select ui dialog config
  ui = {
    -- set the width
    width = 0.7,
    -- set the height
    height = 0.5
  }

})
```

## Integrations
Available integrations:
- [Telescope](https://github.com/nvim-telescope/telescope.nvim), to select registred lenses with ui.

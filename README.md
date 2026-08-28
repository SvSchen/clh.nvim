# clh.nvim
Execute code lenses from everywhere.

Code lenses are available at specific lines, such as **run** or **debug** an application or test. 
To avoid always jump back to the code lens position to execute a lens this plugin registered already executed lenses and makes those available from everywhere.
To register a specific code lens it is required to hook into the code lens picker, actually only snacks is supported. 
The selected code lens from the picker gets registered and can rerun from everywhere. 

Note:
Actually just tested with scala-lang code lenses.

## Installation
vim.pack:
```lua
vim.pack.add({ "https://github.com/folke/snacks.nvim", "https://github.com/svschen/clh.nvim" })
require("snacks").setup({
	picker = {
		sources = {
			codeLensesHistory = {
				layout = custom-layout,
			},
            select = {
				kinds = {
					codelens = {
						actions = {
							confirm = function(picker, item, action)
								picker:close()
								vim.schedule(function()
									local clh = require("clh")
									clh.registerAndRunCodeLens(item)
									clh.dapReplWindow()
								end)
							end,
						},
                    }
                }
            }
        ...
        }
    }
})

vim.keymap.set(
  "n",
  "<leader>cl",
  function()
	local clh = require("clh")
    return clh.runCodeLensPicker() or clh.ui()
  end,
  { desc = "Run code lens picker or select/run already registered code lens" })
```

## Options
```lua
require("clh").setup({
  -- code lens history config
  history = {
    -- set max registered code lenses
    maxLength = 10
  },
})
```

## Integrations
Available integrations:
- [Snacks.nvim](https://github.com/folke/snacks.nvim), to register and select already registered lenses.

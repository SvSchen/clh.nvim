local default = {
  -- code lense history config
  history = {
    -- set max registered code lenes
    maxLength = 10,
  },
  -- select ui dialog config
  ui = {
    -- set the width
    width = 0.7,
    -- set the height
    height = 0.5,
  },
}

local conf = default

local function config()
  return conf
end

local function setup(opts)
  conf = opts and vim.tbl_extend("force", default, opts) or opts
end

return {
  default = default,
  config = config,
  setup = setup,
}

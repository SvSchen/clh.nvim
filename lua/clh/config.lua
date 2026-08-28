local default = {
  -- code lens history config
  history = {
    -- set max registered code lenses
    maxLength = 10,
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

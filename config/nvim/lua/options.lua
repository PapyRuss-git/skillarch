vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

local local_bin = vim.fn.stdpath("config") .. "/.local/bin"
if vim.fn.isdirectory(local_bin) == 1 then
  vim.env.PATH = local_bin .. ":" .. vim.env.PATH
end

-- Keep older plugins quiet on Nvim 0.11+ until they switch to the new API.
do
  local validate = vim.validate

  vim.validate = function(name, value, validator, optional, message)
    if validator ~= nil or type(name) ~= "table" then
      return validate(name, value, validator, optional, message)
    end

    for field, spec in pairs(name) do
      local spec_value = spec[1]
      local spec_validator = spec[2]
      local spec_optional = spec[3]
      local spec_message = spec[4]

      if type(spec_optional) == "string" and spec_message == nil then
        validate(field, spec_value, spec_validator, false, spec_optional)
      else
        validate(field, spec_value, spec_validator, spec_optional, spec_message)
      end
    end
  end
end

local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.mouse = ""
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true
opt.clipboard = "unnamedplus"
opt.ignorecase = true
opt.smartcase = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.updatetime = 250
opt.undofile = true
opt.splitright = true
opt.splitbelow = true
opt.cursorline = true
opt.scrolloff = 8

vim.filetype.add({
  filename = {
    ["go.work"] = "gowork",
  },
})

-- Markdown comfort settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.conceallevel = 2
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en,fr"
  end,
})

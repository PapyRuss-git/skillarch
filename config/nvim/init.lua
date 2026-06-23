-- SkillArch Neovim Configuration
require("options")
require("bootstrap")
require("lazy").setup("plugins", {
  rocks = {
    enabled = false,
  },
})
require("keymaps")
require("transparency")

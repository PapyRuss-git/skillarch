return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    local install_dir = vim.fn.stdpath("config") .. "/.treesitter"
    vim.opt.rtp:prepend(install_dir)

    require("nvim-treesitter").setup({
      install_dir = install_dir,
      ensure_installed = {
        "bash",
        "javascript",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "rust",
        "tsx",
        "vim",
      },
      auto_install = false,
      highlight = {
        enable = true,
      },
      indent = {
        enable = true,
      },
    })

    vim.treesitter.language.register("bash", "zsh")
  end,
}

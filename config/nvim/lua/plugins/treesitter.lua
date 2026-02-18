return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup()
    vim.treesitter.language.register("bash", "zsh")
    ensure_installed = { "lua", "python", "javascript", "tsx", "vim", "bash", "rust" }
  end,
}

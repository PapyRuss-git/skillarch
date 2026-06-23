return {
  -- Live preview in browser
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = "markdown",
    build = "cd app && npm install",
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown Preview" },
    },
    init = function()
      vim.g.mkdp_auto_close = 0
    end,
  },
  -- In-buffer rendering (headings, checkboxes, tables, code blocks)
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = "markdown",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      heading = {
        icons = { "# ", "## ", "### ", "#### ", "##### ", "###### " },
      },
      checkbox = {
        unchecked = { icon = "☐ " },
        checked = { icon = "☑ " },
      },
    },
  },
}

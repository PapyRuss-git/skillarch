-- ============================================================
-- SkillArch Neovim Configuration (from scratch with lazy.nvim)
-- ============================================================

-- ── Options de base ──────────────────────────────────────────
vim.g.mapleader = " "
vim.g.maplocalleader = " "

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

-- ── Bootstrap lazy.nvim ──────────────────────────────────────
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ── Plugins ──────────────────────────────────────────────────
require("lazy").setup({

  -- Colorscheme Everforest
  {
    "sainnhe/everforest",
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.everforest_background = "hard"
      vim.g.everforest_better_performance = 1
      vim.cmd.colorscheme("everforest")
    end,
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup()
      vim.treesitter.language.register("bash", "zsh")
      ensure_installed = { "lua", "python", "javascript", "tsx", "vim", "bash", "rust" }
    end,
  },

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
    },
  },

  -- Lualine
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = { theme = "everforest" },
      })
    end,
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      -- Configure servers via vim.lsp.config (nvim 0.11+)
      local servers = { "lua_ls", "pyright", "ts_ls", "gopls", "rust_analyzer" }
      for _, server in ipairs(servers) do
        vim.lsp.config(server, { capabilities = capabilities })
      end
      -- lua_ls specific: suppress vim global warning
      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
          },
        },
      })
      vim.lsp.enable(servers)
    end,
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

  -- Git signs
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end,
  },

  -- Neo-tree
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle Neo-tree" },
    },
  },

  -- Autopairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup()
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

  -- Bindings helper
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {}
  },
  
  -- Indent blanking
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    -- On s'assure qu'Everforest est chargé AVANT ibl
    dependencies = { "sainnhe/everforest" }, 
    opts = {
      indent = {
        char = "│", -- Un trait continu plus élégant que le '|' par défaut
        tab_char = "│",
      },
      scope = {
        enabled = true,
        show_start = false,
        show_end = false,
        -- Everforest gère l'highlight par défaut, mais tu peux forcer 
        -- le trait du bloc actuel à être d'une couleur plus visible si tu veux
      },
      exclude = {
        filetypes = {
          "help",
          "alpha",
          "dashboard",
          "neo-tree",      -- Très important pour ne pas polluer l'arbre de fichiers
          "Trouble",
          "trouble",
          "lazy",          -- Le menu de lazy.nvim
          "mason",         -- Le menu de Mason
          "notify",
          "toggleterm",
        },
      },
    },
  },
})

-- ── LSP Keymaps ──────────────────────────────────────────────
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local map = function(keys, func, desc)
      vim.keymap.set("n", keys, func, { buffer = ev.buf, desc = desc })
    end
    map("gd", vim.lsp.buf.definition, "Go to definition")
    map("gr", vim.lsp.buf.references, "References")
    map("K", vim.lsp.buf.hover, "Hover documentation")
    map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
    map("<leader>ca", vim.lsp.buf.code_action, "Code action")
  end,
})

-- ── Transparence ─────────────────────────────────────────────
local function set_transparency()
  vim.cmd([[
    hi Normal guibg=NONE ctermbg=NONE
    hi NormalNC guibg=NONE ctermbg=NONE
    hi SignColumn guibg=NONE ctermbg=NONE
    hi StatusLine guibg=NONE ctermbg=NONE
    hi StatusLineNC guibg=NONE ctermbg=NONE
    hi VertSplit guibg=NONE ctermbg=NONE
    hi TabLine guibg=NONE ctermbg=NONE
    hi TabLineFill guibg=NONE ctermbg=NONE
    hi TabLineSel guibg=NONE ctermbg=NONE
    hi NeoTreeNormal guibg=NONE ctermbg=NONE
    hi NeoTreeNormalNC guibg=NONE ctermbg=NONE
    hi NeoTreeWinSeparator guibg=NONE ctermbg=NONE
    hi NeoTreeEndOfBuffer guibg=NONE ctermbg=NONE
    hi EndOfBuffer guibg=NONE ctermbg=NONE
  ]])
end

set_transparency()

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = set_transparency,
})

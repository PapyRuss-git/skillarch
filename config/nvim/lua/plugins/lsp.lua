return {
  "neovim/nvim-lspconfig",
  config = function()
    local function set_signature_highlights()
      local cursorline_nr = vim.api.nvim_get_hl(0, { name = "CursorLineNr", link = false })
      local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
      local bg = normal.bg or "NONE"

      vim.api.nvim_set_hl(0, "LspSignatureFloat", {
        fg = normal.fg,
        bg = bg,
      })

      vim.api.nvim_set_hl(0, "LspSignatureBorder", {
        fg = cursorline_nr.fg,
        bg = bg,
        bold = cursorline_nr.bold,
      })

      vim.api.nvim_set_hl(0, "LspSignatureTitle", {
        fg = cursorline_nr.fg,
        bg = bg,
        bold = true,
      })
    end

    set_signature_highlights()
    vim.schedule(set_signature_highlights)

    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = set_signature_highlights,
    })

    vim.api.nvim_create_autocmd("VimEnter", {
      once = true,
      callback = set_signature_highlights,
    })

    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
      vim.lsp.handlers.signature_help,
      {
        border = "rounded",
        focusable = false,
        close_events = { "BufHidden", "InsertLeave" },
        winhighlight = "NormalFloat:LspSignatureFloat,FloatBorder:LspSignatureBorder,FloatTitle:LspSignatureTitle",
      }
    )

    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    local server_order = { "lua_ls", "pyright", "ts_ls", "gopls", "rust_analyzer" }
    local server_configs = {
      lua_ls = {
        on_init = function(client)
          if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if
              path ~= vim.fn.stdpath("config")
              and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
            then
              return
            end
          end

          client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
            runtime = {
              version = "LuaJIT",
              path = {
                "lua/?.lua",
                "lua/?/init.lua",
              },
            },
            workspace = {
              checkThirdParty = false,
              library = {
                vim.env.VIMRUNTIME,
                vim.fn.stdpath("config"),
              },
            },
          })
        end,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
          },
        },
      },
      pyright = {},
      ts_ls = {
        filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
      },
      gopls = {
        filetypes = { "go", "gomod", "gowork" },
      },
      rust_analyzer = {},
    }

    local enabled_servers = {}

    for _, server in ipairs(server_order) do
      vim.lsp.config(server, vim.tbl_deep_extend("force", {
        capabilities = capabilities,
      }, server_configs[server]))

      local cmd = vim.lsp.config[server].cmd
      if type(cmd) == "table" and type(cmd[1]) == "string" and vim.fn.executable(cmd[1]) == 1 then
        table.insert(enabled_servers, server)
      end
    end

    if #enabled_servers > 0 then
      vim.lsp.enable(enabled_servers)
    end
  end,
}

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local signature_opts = {
      border = "rounded",
      focusable = false,
      silent = true,
      close_events = { "BufHidden", "InsertLeave" },
      winhighlight = "NormalFloat:LspSignatureFloat,FloatBorder:LspSignatureBorder,FloatTitle:LspSignatureTitle",
    }

    local function has_signature_help()
      for _, client in ipairs(vim.lsp.get_clients({ bufnr = ev.buf })) do
        if client:supports_method(vim.lsp.protocol.Methods.textDocument_signatureHelp) then
          return true
        end
      end
      return false
    end

    local function show_signature_help()
      if has_signature_help() then
        vim.lsp.buf.signature_help(signature_opts)
      end
    end

    local function trigger_signature(char)
      return function()
        vim.schedule(function()
          show_signature_help()
        end)
        return char
      end
    end

    local function maybe_signature_help()
      if vim.api.nvim_get_current_buf() ~= ev.buf or not has_signature_help() then
        return
      end

      local row, col = unpack(vim.api.nvim_win_get_cursor(0))
      local line = vim.api.nvim_buf_get_lines(ev.buf, row - 1, row, false)[1] or ""
      local prefix = line:sub(1, col):gsub("%s+$", "")

      if prefix:match("[%(,]$") then
        show_signature_help()
      end
    end

    local map = function(keys, func, desc)
      vim.keymap.set("n", keys, func, { buffer = ev.buf, desc = desc })
    end

    local imap = function(keys, func, desc)
      vim.keymap.set("i", keys, func, { buffer = ev.buf, desc = desc, expr = true })
    end

    local imap_call = function(keys, func, desc)
      vim.keymap.set("i", keys, func, { buffer = ev.buf, desc = desc })
    end

    map("gd", vim.lsp.buf.definition, "Go to definition")
    map("gr", vim.lsp.buf.references, "References")
    map("K", vim.lsp.buf.hover, "Hover documentation")
    map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
    map("<leader>ca", vim.lsp.buf.code_action, "Code action")
    map("<leader>sh", show_signature_help, "Signature help")
    imap_call("<C-k>", show_signature_help, "Signature help")

    imap("(", trigger_signature("("), "Trigger signature help")
    imap(",", trigger_signature(","), "Refresh signature help")

    vim.api.nvim_create_autocmd("TextChangedI", {
      buffer = ev.buf,
      callback = function()
        vim.schedule(maybe_signature_help)
      end,
    })
  end,
})

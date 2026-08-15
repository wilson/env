------------------------------------------
-- All keymaps not provided directly by packages
------------------------------------------
local M = {}
local utils = _G.require_and_setup("custom.utils", false)

function M.setup()
  vim.keymap.set('n', '<leader>w', vim.diagnostic.open_float, { noremap = true, silent = true, desc = "Show diagnostics float" })
  vim.keymap.set('n', '<leader>W', vim.diagnostic.setloclist, { noremap = true, silent = true, desc = "Show diagnostics list" })

  vim.keymap.set('n', '<leader>p', function()
    return 'A <esc>"' .. vim.v.register .. 'p'
  end, { expr = true, desc = "Paste at end of line with leading space" })

  vim.keymap.set('n', '<leader>bd', '<Cmd>w|bd<CR>', { desc = 'Write and delete buffer' })

  if utils and utils.is_gui_environment() then
    -- Map Cmd-w to close the current buffer
    vim.keymap.set(
      {'n', 'v', 'i'},
      '<D-w>',
      '<Cmd>bd<CR>',
      { desc = 'Delete buffer' }
    )
  end
end

-- Invoked on-attach by the LSP package.
function M.setup_lsp(bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }
  -- Add a description key to the map of options
  local function add_desc(desc)
    return vim.tbl_extend('force', opts, { desc = desc })
  end

  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, add_desc('Go to definition'))
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, add_desc('Hover documentation'))
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, add_desc('Rename symbol'))
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, add_desc('Code action'))
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, add_desc('Find references'))
  vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, add_desc('Format buffer'))
end

return M

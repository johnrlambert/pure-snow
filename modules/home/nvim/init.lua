vim.keymap.set("n", "<C-j>", "<C-w>j", { noremap = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { noremap = true })
vim.keymap.set("n", "<C-h>", "<C-w>h", { noremap = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { noremap = true })
-- ===========================
-- Minimal Neovim init.lua
--   • absolute line numbers
--   • Gruvbox colorscheme
--   • nvim-tree auto-opens; reveals current file / sets root to file's dir
--   • format-on-save for Python & Nix via Conform
-- No telescope, no treesitter, no LSP.
-- ===========================

-- ----- baseline options -----
vim.g.mapleader = " "
vim.o.termguicolors = true
vim.wo.number = true            -- absolute line numbers
vim.wo.relativenumber = false   -- ensure NOT relative
vim.o.signcolumn = "yes"
vim.o.clipboard = "unnamedplus"
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.smartindent = true
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.updatetime = 200
vim.o.timeoutlen = 400

-- Function to open a terminal with aider and add the current file
local function open_aider_and_add_file()
  -- Split the window and open a terminal running aider
  vim.cmd("split | terminal aider --watch-files")
  -- Add the current file to the Aider session
  vim.cmd("Aider add")
end

-- ----- your own keymaps -----
-- Bind F9 to open aider and add the current file
vim.keymap.set("n", "<F9>", open_aider_and_add_file, { noremap = true, silent = true, desc = "Open Aider and add file" })

-- paste your i3-style remaps here (this config adds only <leader>e for tree)

-- ----- Gruvbox -----
pcall(function()
  require("gruvbox").setup({
    contrast = "hard",         -- "soft" | "medium" | "hard"
    transparent_mode = false,
  })
  vim.cmd.colorscheme("gruvbox")
end)

-- ----- nvim-tree -----
pcall(function()
  require("nvim-tree").setup({
    sync_root_with_cwd = true,
    respect_buf_cwd = true,
    update_focused_file = {
      enable = true,
      update_root = true,
    },
    view = {
      width = 30,
      preserve_window_proportions = true,
    },
    renderer = {
      root_folder_label = false,
    },
    actions = {
      change_dir = { enable = true, global = false, restrict_above_cwd = false },
      open_file = { quit_on_open = false },
    },
    filters = {
      dotfiles = false,
    },
  })

  -- Toggle key (remove/change if you already use <leader>e)
  vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true, desc = "Toggle file tree" })

  -- Auto-open behavior on startup:
  -- - If Neovim starts on a directory: cd into it and open the tree.
  -- - If Neovim starts on a file: open the tree and reveal that file (do not steal focus).
  local function open_tree_on_start(data)
    -- no name, no file → just open the tree in cwd
    if data.file == "" or data.file == nil then
      require("nvim-tree.api").tree.open()
      return
    end

    local realpath = vim.fn.fnamemodify(data.file, ":p")
    if vim.fn.isdirectory(realpath) == 1 then
      vim.cmd.cd(realpath)
      require("nvim-tree.api").tree.open()
    else
      -- reveal current file; keep focus in the file window
      require("nvim-tree.api").tree.find_file({ open = true, focus = false })
    end
  end

  vim.api.nvim_create_autocmd("VimEnter", { callback = open_tree_on_start })
end)

-- ----- Conform: format-on-save (Python + Nix only) -----
pcall(function()
  require("conform").setup({
    format_on_save = { timeout_ms = 2000, lsp_fallback = false },
    formatters_by_ft = {
      python = { "ruff_format", "black" },
      nix    = { "nixfmt" },
    },
  })
  -- Optional manual format binding:
  -- vim.keymap.set("n", "<leader>fm", function() require("conform").format({ async = true }) end,
  --   { noremap = true, silent = true, desc = "Format buffer" })
end)
-- Snacks: no config needed, but this avoids warnings if a plugin checks for it
pcall(function() require("snacks").setup({opts={picker = {enable= true}}}) end)

-- nvim-aider minimal
pcall(function()
  require("nvim_aider").setup({
    -- sane defaults; nothing here touches your other mappings
    -- leave empty to use built-ins
  })

  -- Core commands (from the plugin README):
  -- :Aider           → open interactive command menu
  -- :Aider toggle    → toggle aider terminal
  -- :Aider send      → send text/selection
  -- :Aider buffer    → send current buffer
  -- :Aider add/drop  → add/drop file to session
  -- :Aider reset     → clear session
  -- :Aider health    → check plugin health

  -- Your explicit keys (non-intrusive)
  vim.keymap.set("n", "<leader>a/", "<cmd>Aider toggle<cr>", { silent = true, desc = "Aider: Toggle" })
  vim.keymap.set({ "n", "v" }, "<leader>as", "<cmd>Aider send<cr>", { silent = true, desc = "Aider: Send" })
  vim.keymap.set("n", "<leader>ab", "<cmd>Aider buffer<cr>", { silent = true, desc = "Aider: Send Buffer" })
  vim.keymap.set("n", "<leader>a+", "<cmd>Aider add<cr>", { silent = true, desc = "Aider: Add File" })
  vim.keymap.set("n", "<leader>a-", "<cmd>Aider drop<cr>", { silent = true, desc = "Aider: Drop File" })
  vim.keymap.set("n", "<leader>aR", "<cmd>Aider reset<cr>", { silent = true, desc = "Aider: Reset" })

  -- Optional: nvim-tree integration (plugin exposes these commands)
  -- Only active when you're in the tree buffer
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "NvimTree",
    callback = function()
      vim.keymap.set("n", "<leader>a+", "<cmd>AiderTreeAddFile<cr>",  { buffer = true, silent = true, desc = "Aider: Add from tree" })
      vim.keymap.set("n", "<leader>a-", "<cmd>AiderTreeDropFile<cr>", { buffer = true, silent = true, desc = "Aider: Drop from tree" })
    end,
  })
end)

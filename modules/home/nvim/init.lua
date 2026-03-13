vim.keymap.set("n", "<C-j>", "<C-w>j", { noremap = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { noremap = true })
vim.keymap.set("n", "<C-h>", "<C-w>h", { noremap = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { noremap = true })
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
  -- Get the current file path
  local current_file = vim.fn.expand("%:p")
  -- Split the window and open a terminal running aider with the current file
  vim.cmd("split | terminal aider --watch-files " .. current_file)
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
pcall(function() require("nvim-tree").setup({
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
      root_folder_label = true,
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
end)

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function(data)
    local directory = vim.fn.isdirectory(data.file) == 1

    if directory then
      vim.cmd.cd(data.file)
    end

    require("nvim-tree.api").tree.open({ current_window = false })
    vim.schedule(function()
      vim.cmd("wincmd p")
    end)
  end,
})
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

vim.g.orgmode = vim.g.orgmode or {}
require("orgmode").setup({
  org_agenda_files = { "~/chronofile/**/*" },
  org_default_notes_file = "~/chronofile/inbox.org",
})


-- Indent-based folding (great for CoffeeScript)
vim.o.foldmethod = "indent"
vim.o.foldenable = true

-- Start with folds CLOSED when you open a file
-- (0 = pretty aggressive; 1 = top-level open; tune if you like)
vim.o.foldlevel = 0
vim.o.foldlevelstart = 0

-- Helper: detect if current line is the START of a fold
local function is_fold_start(lnum)
  local cur = vim.fn.foldlevel(lnum)
  if cur <= 0 then return false end
  if lnum <= 1 then return cur > 0 end
  local prev = vim.fn.foldlevel(lnum - 1)
  return cur > prev
end

-- Tab toggles fold ONLY on fold-start lines
vim.keymap.set("n", "<Tab>", function()
  local lnum = vim.fn.line(".")
  if is_fold_start(lnum) then
    vim.cmd("normal! za")  -- toggle fold at cursor
  end
end, { silent = true, desc = "Toggle fold (only on fold start)" })


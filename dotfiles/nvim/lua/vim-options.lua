vim.opt.shiftwidth = 2

vim.opt.softtabstop = 2
vim.opt.tabstop = 2
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true
vim.opt.showmode = false

--  See `:help 'clipboard'`
vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true
-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.opt.confirm = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
-- vim.opt.list = true
-- vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
-- vim.opt.listchars = { trail = "·", nbsp = "␣" }

--- Custom
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.smarttab = true
vim.opt.smartindent = true
vim.cmd("set smarttab")
vim.cmd("set smartindent")
vim.cmd("set hidden")
vim.cmd("set incsearch")
vim.cmd("set encoding=utf-8")
vim.cmd("set autoread")
vim.cmd("set syntax=OFF")

vim.opt.termguicolors = true

-- KEY MAPS

vim.api.nvim_create_user_command("WQ", "wq", {})
vim.api.nvim_create_user_command("Wq", "wq", {})
vim.api.nvim_create_user_command("W", "w", {})
vim.api.nvim_create_user_command("Qa", "qa", {})
vim.api.nvim_create_user_command("Q", "q", {})

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
-- vim.keymap.set("n", "<A-Left>", "<C-w><C-h>", { desc = "Move focus to the left window" })
-- vim.keymap.set("n", "<A-Right>", "<C-w><C-l>", { desc = "Move focus to the right window" })
-- vim.keymap.set("n", "<A-Down>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
-- vim.keymap.set("n", "<A-Up>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Nvimtree file explorer auto close when it is the last one
vim.api.nvim_create_autocmd("BufEnter", {
	group = vim.api.nvim_create_augroup("NvimTreeClose", { clear = true }),
	pattern = "NvimTree_*",
	callback = function()
		local layout = vim.api.nvim_call_function("winlayout", {})
		if
			layout[1] == "leaf"
			and vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(layout[2]), "filetype") == "NvimTree"
			and layout[3] == nil
		then
			vim.cmd("confirm quit")
		end
	end,
})

-- vim.keymap.set("n", "<Leader>b", ":buffers<CR>:buffer<Space>", { desc = "List buffers" })
vim.keymap.set({ "v", "n", "x" }, "<leader>p", [["_dP]])
vim.keymap.set("n", "<C-W>z", "<C-W>o", { desc = "Zoom" })

vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "Q", "<nop>")
-- vim.keymap.set("n", "<C-Down>", "<Cmd>NvimTmuxNavigateDown<CR>", {})
-- vim.keymap.set("n", "<C-Up>", "<Cmd>NvimTmuxNavigateUp<CR>", {})
vim.keymap.set("n", "<C-Left>", "b", {})
vim.keymap.set("n", "<C-Right>", "e", {})

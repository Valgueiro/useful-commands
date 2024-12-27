return {
	"alexghergh/nvim-tmux-navigation",
	config = function()
		require("nvim-tmux-navigation").setup({})
		vim.keymap.set("n", "<M-h>", "<Cmd>NvimTmuxNavigateLeft<CR>", {})
		vim.keymap.set("n", "<M-j>", "<Cmd>NvimTmuxNavigateDown<CR>", {})
		vim.keymap.set("n", "<M-k>", "<Cmd>NvimTmuxNavigateUp<CR>", {})
		vim.keymap.set("n", "<M-l>", "<Cmd>NvimTmuxNavigateRight<CR>", {})
		vim.keymap.set("n", "<A-Left>", "<Cmd>NvimTmuxNavigateLeft<CR>", {})
		vim.keymap.set("n", "<A-Down>", "<Cmd>NvimTmuxNavigateDown<CR>", {})
		vim.keymap.set("n", "<A-Up>", "<Cmd>NvimTmuxNavigateUp<CR>", {})
		vim.keymap.set("n", "<A-Right>", "<Cmd>NvimTmuxNavigateRight<CR>", {})
	end,
}

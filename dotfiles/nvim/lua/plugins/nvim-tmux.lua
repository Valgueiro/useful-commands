return {
	"alexghergh/nvim-tmux-navigation",
	config = function()
		local nvim_tmux_nav = require("nvim-tmux-navigation")
		nvim_tmux_nav.setup({})
		vim.keymap.set("n", "<M-Left>", nvim_tmux_nav.NvimTmuxNavigateLeft, {})
		vim.keymap.set("n", "<M-Down>", nvim_tmux_nav.NvimTmuxNavigateDown, {})
		vim.keymap.set("n", "<M-Up>", nvim_tmux_nav.NvimTmuxNavigateUp, {})
		vim.keymap.set("n", "<M-Right>", nvim_tmux_nav.NvimTmuxNavigateRight, {})
	end,
}

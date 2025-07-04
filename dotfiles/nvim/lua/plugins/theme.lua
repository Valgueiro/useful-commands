-- return {}
-- return {
-- "catppuccin/nvim",
-- name = "catppuccin",
-- priority = 1000,
-- lazy = false,
-- config = function()
-- vim.cmd.colorscheme("catppuccin")
-- end,
-- }

return {
	"projekt0n/github-nvim-theme",
	lazy = false, -- make sure we load this during startup if it is your main colorscheme
	priority = 1000, -- make sure to load this before all the other start plugins
	config = function()
		require("github-theme").setup({})

		vim.cmd("colorscheme github_dark_default")
	end,
}

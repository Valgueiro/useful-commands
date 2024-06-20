return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
		{
			"s1n7ax/nvim-window-picker",
			version = "2.*",
			config = function()
				require("window-picker").setup({
					filter_rules = {
						include_current_win = false,
						autoselect_one = true,
						bo = {
							filetype = { "neo-tree", "neo-tree-popup", "notify" },
							buftype = { "terminal", "quickfix" },
						},
					},
				})
			end,
		},
	},
	config = function()
		require("neo-tree").setup({
			close_if_last_window = true,
			enable_git_status = true,
			filesystem = {
				filtered_items = {
					visible = true,
					hide_dotfiles = false,
					hide_gitignored = true,
				},
			},
		})
		vim.keymap.set("n", "<C-n>", ":Neotree filesystem reveal left toggle<CR>", {})

		vim.api.nvim_create_augroup("neotree", {})
		vim.api.nvim_create_autocmd("UiEnter", {
			desc = "Open Neotree automatically",
			group = "neotree",
			callback = function()
				if vim.fn.argc() == 0 then
					vim.cmd("Neotree toggle")
				end
			end,
		})
	end,
}

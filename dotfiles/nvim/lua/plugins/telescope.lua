return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8",
	event = "VimEnter",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ -- If encountering errors, see telescope-fzf-native README for installation instructions
			"nvim-telescope/telescope-fzf-native.nvim",

			-- `build` is used to run some command when the plugin is installed/updated.
			-- This is only run then, not every time Neovim starts up.
			build = "make",

			-- `cond` is a condition used to determine whether this plugin should be
			-- installed and loaded.
			cond = function()
				return vim.fn.executable("make") == 1
			end,
		},
		{ "nvim-telescope/telescope-ui-select.nvim" },
		-- Useful for getting pretty icons, but requires a Nerd Font.
		{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
	},
	config = function()
		local telescope = require("telescope")
		telescope.setup({
			-- You can put your default mappings / updates / etc. in here
			--  All the info you're looking for is in `:help telescope.setup()`
			--
			-- defaults = {
			--   mappings = {
			--     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
			--   },
			-- },
			pickers = {
				find_files = {
					hidden = true,
				},
			},
			extensions = {
				["ui-select"] = {
					require("telescope.themes").get_dropdown(),
				},
			},
		})

		pcall(telescope.load_extension, "fzf")
		pcall(telescope.load_extension, "ui-select")

		local builtin = require("telescope.builtin")
		vim.keymap.set("n", "<leader>p", builtin.find_files, { desc = "[P]Find Files" })
		vim.keymap.set("n", "<leader>s", builtin.live_grep, { desc = "[S]earch in all files" })
		vim.keymap.set("n", "<leader>b", builtin.buffers, { desc = "[B]uffers" })
		vim.keymap.set("n", "<leader>bd", ":bd<CR>", { desc = "[B]uffer [D]elete" })
	end,
}

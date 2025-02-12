return {
	"nvim-tree/nvim-tree.lua",
	dependencies = {
		"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
	},
	config = {
		sort = {
			sorter = "case_sensitive",
		},
		view = {
			width = 30,
		},
		renderer = {
			group_empty = false,
		},
		filters = {
			dotfiles = false,
			custom = { ".git" },
			exclude = { "gitrepos" },
		},
		update_focused_file = {
			enable = true,
			update_root = {
				enable = true,
				ignore_list = {},
			},
			ignore_list = {},
		},
	},
	keys = {
		{ "<C-n>", "<cmd>NvimTreeToggle<cr>", desc = "File Tree Toggle" },
	},
}

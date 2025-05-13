local function my_on_attach(bufnr)
	local api = require("nvim-tree.api")

	local function opts(desc)
		return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
	end

	-- default mappings
	api.config.mappings.default_on_attach(bufnr)

	-- custom mappings
	vim.keymap.set("n", "s", api.node.open.vertical, opts("Open: Vertical Split"))
	vim.keymap.set("n", "h", api.node.open.horizontal, opts("Open: Horizontal Split"))
end

return {
	"nvim-tree/nvim-tree.lua",
	dependencies = {
		"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
	},
	config = {
		on_attach = my_on_attach,
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
			custom = { "^.git$", "^.ansible$" },
			exclude = { "gitrepos", "requirements.txt" },
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

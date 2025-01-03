return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	opts = {
		ensure_installed = {
			"go",
			"groovy",
			"json",
			"json5",
			"kotlin",
			"yaml",
			"lua",
			"javascript",
			"python",
			"hcl",
			"yaml",
			"json",
			"gitignore",
			"bash",
			"markdown",
			"templ",
			"c_sharp",
		},

		highlight = {
			enable = true,

			-- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
			-- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
			-- the name of the parser)
			-- list of language that will be disabled
			disable = { "c", "rust" },
			additional_vim_regex_highlighting = false,
		},
		auto_install = true,
		indent = { enabled = true },
	},
	config = function(_, opts)
		require("nvim-treesitter.install").prefer_git = true
		---@diagnostic disable-next-line: missing-fields
		require("nvim-treesitter.configs").setup(opts)
		vim.api.nvim_command(":TSEnable highlight")
	end,
}

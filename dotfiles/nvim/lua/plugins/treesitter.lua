return {
	{
		"apple/pkl-neovim",
		lazy = true,
		ft = "pkl",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"L3MON4D3/LuaSnip",
		},
		build = function()
			require("pkl-neovim").init()
		end,
		config = function()
			-- Set up snippets.
			require("luasnip.loaders.from_snipmate").lazy_load()

			-- Configure pkl-lsp
			vim.g.pkl_neovim = {
				start_command = { "pkl-lsp" },
				pkl_cli_path = "/opt/homebrew/bin/pkl-lsp",
			}
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		dependencies = { "apple/pkl-neovim" },
		build = ":TSUpdate",
		opts = {
			ensure_installed = {
				"go",
				"groovy",
				"json",
				"json5",
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
				"pkl",
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
	},
}

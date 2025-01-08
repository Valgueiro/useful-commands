return {
	"folke/snacks.nvim",
	opts = {
		indent = { enabled = true },
		input = { enabled = true },
		quickfile = { enabled = true },
		notifier = { enabled = true },
		scope = { enabled = false },
		scroll = { enabled = true },
		statuscolumn = { enabled = true }, -- we set this in options.lua
		words = { enabled = true },
		dashboard = { enabled = false },
		bigfile = { enabled = true },
	},
	keys = {
		{
			"<leader>n",
			function()
				Snacks.notifier.show_history()
			end,
			desc = "Notification History",
		},
		{
			"<leader>un",
			function()
				Snacks.notifier.hide()
			end,
			desc = "Dismiss All Notifications",
		},
	},
}

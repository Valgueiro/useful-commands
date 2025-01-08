return {
	"folke/snacks.nvim",
	opts = {
		indent = { enabled = true },
		bigfile = { enabled = true },
		--- disable
		input = { enabled = false },
		quickfile = { enabled = false },
		notifier = { enabled = false },
		notify = { enabled = false },
		scope = { enabled = false },
		scroll = { enabled = false },
		statuscolumn = { enabled = false }, -- we set this in options.lua
		dashboard = { enabled = false },
		words = { enabled = false },
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

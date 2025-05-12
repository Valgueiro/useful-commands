return {
	{
		"github/copilot.vim",
		config = function()
			vim.keymap.set("i", "<C-A>", 'copilot#Accept("\\<CR>")', {
				expr = true,
				replace_keycodes = false,
				desc = "[A]ccept completion",
			})
			vim.g.copilot_no_tab_map = true
			vim.g.copilot_enabled = false
		end,
	},

	{
		"CopilotC-Nvim/CopilotChat.nvim",
		dependencies = {
			{ "github/copilot.vim" }, -- or zbirenbaum/copilot.lua
			{ "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
		},
		build = "make tiktoken", -- Only on MacOS or Linux
		opts = {
			-- See Configuration section for options
		},

		config = function()
			require("CopilotChat").setup({})
			vim.keymap.set("n", "<Leader>ch", "<cmd>CopilotChatOpen<cr>", { desc = "Open Chat" })
			vim.keymap.set("v", "<Leader>ch", "<cmd>CopilotChatExplain<cr>", { desc = "Explain" })

			vim.keymap.set("v", "<Leader>cf", "<cmd>CopilotChatFix<cr>", { desc = "Fix" })
			vim.keymap.set("v", "<Leader>co", "<cmd>CopilotChatOptimize<cr>", { desc = "Optimize" })
			vim.keymap.set("v", "<Leader>ct", "<cmd>CopilotChatTests<cr>", { desc = "Tests" })
		end,
	},
}

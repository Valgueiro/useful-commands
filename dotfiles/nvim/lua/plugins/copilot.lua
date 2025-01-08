return {
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
}

return {
	"tpope/vim-commentary",
	config = function()
		vim.keymap.set("n", "<Leader>;", ":norm gcc<CR>", { desc = "; comment" })
		vim.keymap.set("n", "<C-_>", ":norm gcc<CR>", { desc = "/ comment" })

		vim.keymap.set("v", "<Leader>;", ":norm gcc<CR>", { desc = "; comment" })
		vim.keymap.set("v", "<C-_>", ":norm gcc<CR>", { desc = "/ comment" })
	end,
}

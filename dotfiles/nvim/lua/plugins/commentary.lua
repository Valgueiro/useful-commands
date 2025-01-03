return {
	"tpope/vim-commentary",
	config = function()
		vim.keymap.set({ "n", "v" }, "<Leader>;", ":norm gcc<CR>", { desc = "; comment" })
		vim.keymap.set({ "n", "v" }, "<C-_>", ":norm gcc<CR>", { desc = "/ comment" })
	end,
}

return {
	"numToStr/Comment.nvim",
	opts = {},
	keys = {
		{ "<Leader>;", ":norm gcc<CR>", desc = "; comment", mode = { "n", "v" } },
	},
}
-- return {
-- 	"tpope/vim-commentary",
-- 	config = function()
-- 		vim.keymap.set({ "n", "v" }, "<Leader>;", ":norm gcc<CR>", { desc = "; comment" })
-- 	end,
-- }

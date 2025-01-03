return {
	"akinsho/bufferline.nvim",
	opts = {
		options = {
			mode = "buffer",
			number = "ordinal",
			indicator = {
				style = "underline",
			},
			right_mouse_command = nil,
			middle_mouse_command = "bdelete! %d",
			max_name_length = 22,
			tab_size = 22,
			diagnostics = "nvim_lsp",
			offsets = {
				{
					filetype = "neo-tree",
					text = "Nvim Tree",
					separator = true,
					text_align = "left",
				},
			},

			diagnostics_indicator = function(count, level)
				local icon = level:match("error") and " " or " "
				return " " .. icon .. count
			end,
		},
	},
}

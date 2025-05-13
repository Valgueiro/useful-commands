-- Required by nvim tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true

vim.loader.enable()
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

local opts = {}
require("vim-options")
require("lazy").setup("plugins", {
	ui = {
		-- If you are using a Nerd Font: set icons to an empty table which will use the
		-- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
		icons = {
			cmd = "⌘",
			config = "🛠",
			event = "📅",
			ft = "📂",
			init = "⚙",
			keys = "🗝",
			plugin = "🔌",
			runtime = "💻",
			require = "🌙",
			source = "📄",
			start = "🚀",
			task = "📌",
			lazy = "💤 ",
		},
	},
})

-- NvimTree file explorer changes
local api = require("nvim-tree.api")
local function open_nvim_tree(data)
	-- buffer is a directory
	local directory = vim.fn.isdirectory(data.file) == 1

	if not directory then
		return
	end

	-- change to the directory
	vim.cmd.cd(data.file)

	-- open the tree
	api.tree.open()
end

-- Only open automatically when it makes sense
vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })

-- Open new file when created
api.events.subscribe(api.events.Event.FileCreated, function(file)
	vim.cmd("edit " .. vim.fn.fnameescape(file.fname))
end)

-- Make :bd and :q behave as usual when tree is visible
vim.api.nvim_create_autocmd({ "BufEnter", "QuitPre" }, {
	nested = false,
	callback = function(e)
		local tree = require("nvim-tree.api").tree

		-- Nothing to do if tree is not opened
		if not tree.is_visible() then
			return
		end

		-- How many focusable windows do we have? (excluding e.g. incline status window)
		local winCount = 0
		for _, winId in ipairs(vim.api.nvim_list_wins()) do
			if vim.api.nvim_win_get_config(winId).focusable then
				winCount = winCount + 1
			end
		end

		-- We want to quit and only one window besides tree is left
		if e.event == "QuitPre" and winCount == 2 then
			vim.api.nvim_cmd({ cmd = "qall" }, {})
		end

		-- :bd was probably issued an only tree window is left
		-- Behave as if tree was closed (see `:h :bd`)
		if e.event == "BufEnter" and winCount == 1 then
			-- Required to avoid "Vim:E444: Cannot close last window"
			vim.defer_fn(function()
				-- close nvim-tree: will go to the last buffer used before closing
				tree.toggle({ find_file = true, focus = true })
				-- re-open nivm-tree
				tree.toggle({ find_file = true, focus = false })
			end, 10)
		end
	end,
})

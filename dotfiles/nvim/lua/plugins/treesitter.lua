return {
  "nvim-treesitter/nvim-treesitter", 
  build = ":TSUpdate",
  opts = {
    ensure_installed = {"go", "lua", "javascript", "python", "hcl", "yaml", "json", "gitignore", "bash", "markdown"},
    highlight = { enabled = true },
    auto_install = true,
    indent = { enabled = true },
  },
  config = function(_, opts)
    require('nvim-treesitter.install').prefer_git = true
    ---@diagnostic disable-next-line: missing-fields
    require('nvim-treesitter.configs').setup(opts)
  end
}

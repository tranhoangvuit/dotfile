vim.pack.add({
    {
        src = "https://github.com/nvim-treesitter/nvim-treesitter",
        version = "main",
    },
})

require("nvim-treesitter").setup({
    install_dir = vim.fn.stdpath("data") .. "/site",
})

local ensure_installed = {
    "bash",
    "c",
    "css",
    "go",
    "html",
    "javascript",
    "json",
    "lua",
    "luadoc",
    "markdown",
    "markdown_inline",
    "python",
    "query",
    "regex",
    "rust",
    "toml",
    "tsx",
    "typescript",
    "vim",
    "vimdoc",
    "yaml",
}

require("nvim-treesitter").install(ensure_installed)

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("nvim-treesitter-highlight", { clear = true }),
    callback = function(ev)
        local lang = vim.treesitter.language.get_lang(ev.match)
        if lang and pcall(vim.treesitter.start, ev.buf, lang) then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
    end,
})

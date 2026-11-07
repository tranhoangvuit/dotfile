-- Run :TSUpdate after nvim-treesitter is installed or updated
vim.api.nvim_create_autocmd("PackChanged", {
    callback = function(ev)
        local name, kind = ev.data.spec.name, ev.data.kind
        if name == "nvim-treesitter" and (kind == "install" or kind == "update") then
            if not ev.data.active then
                vim.cmd.packadd("nvim-treesitter")
            end
            vim.cmd("TSUpdate")
        end
    end,
})

vim.pack.add({
    {
        src = "https://github.com/nvim-treesitter/nvim-treesitter",
        version = "main",
    },
    "https://github.com/mks-h/treesitter-autoinstall.nvim",
})

require("nvim-treesitter").setup({
    install_dir = vim.fn.stdpath("data") .. "/site",
})

local ensure_installed = {
    "astro",
    "bash",
    "c",
    "cmake",
    "cpp",
    "css",
    "diff",
    "fish",
    "gitignore",
    "go",
    "graphql",
    "html",
    "http",
    "java",
    "javascript",
    "jsdoc",
    "json",
    "lua",
    "luadoc",
    "luap",
    "markdown",
    "markdown_inline",
    "php",
    "printf",
    "python",
    "query",
    "regex",
    "rust",
    "scss",
    "sql",
    "svelte",
    "toml",
    "tsx",
    "typescript",
    "vim",
    "vimdoc",
    "xml",
    "yaml",
}

require("nvim-treesitter").install(ensure_installed)

-- Install missing parsers on demand when opening other filetypes
require("treesitter-autoinstall").setup()

-- MDX has no parser of its own; render it with the Markdown one.
vim.filetype.add({
    extension = {
        mdx = "mdx",
    },
})
vim.treesitter.language.register("markdown", "mdx")

-- filetype -> parser overrides (tsx parser handles jsx nodes)
local ft_lang_override = {
    javascriptreact = "tsx",
    typescriptreact = "tsx",
}

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("nvim-treesitter-highlight", { clear = true }),
    callback = function(ev)
        local lang = ft_lang_override[ev.match] or vim.treesitter.language.get_lang(ev.match)
        if lang and pcall(vim.treesitter.start, ev.buf, lang) then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
    end,
})

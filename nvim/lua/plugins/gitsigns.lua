vim.pack.add({
	"https://github.com/lewis6991/gitsigns.nvim",
	"https://github.com/linrongbin16/gitlinker.nvim",
})

require("gitsigns").setup()
require("gitlinker").setup()

local gs = require("gitsigns")

-- Hunk navigation (keep built-in ]c/[c in diff mode)
vim.keymap.set("n", "]c", function()
	if vim.wo.diff then
		vim.cmd.normal({ "]c", bang = true })
	else
		gs.nav_hunk("next")
	end
end, { desc = "Next hunk" })
vim.keymap.set("n", "[c", function()
	if vim.wo.diff then
		vim.cmd.normal({ "[c", bang = true })
	else
		gs.nav_hunk("prev")
	end
end, { desc = "Prev hunk" })

vim.keymap.set("n", "<leader>gl", gs.blame_line, { desc = "Blame current line" })
vim.keymap.set("n", "<leader>gB", gs.blame, { desc = "Blame buffer" })
vim.keymap.set("n", "<leader>gd", gs.preview_hunk_inline, { desc = "Preview hunk inline" })
vim.keymap.set("n", "<leader>gh", gs.stage_hunk, { desc = "Toggle stage hunk" })
vim.keymap.set("n", "<leader>gs", function()
	if #(gs.get_hunks() or {}) > 0 then
		gs.stage_buffer()
	else
		gs.reset_buffer_index()
	end
end, { desc = "Toggle stage buffer" })

-- Open the file as of the commit that last touched the current line
vim.keymap.set("n", "<leader>go", function()
	local async = require("gitsigns.async")
	local cache = require("gitsigns.cache").cache

	async.run(function()
		local bufnr = vim.api.nvim_get_current_buf()
		local lnum = vim.api.nvim_win_get_cursor(0)[1]
		local bcache = cache[bufnr]
		if not bcache then
			return
		end

		bcache:get_blame(lnum)
		local blame = bcache.blame
		if not blame or not blame.entries or not blame.entries[lnum] then
			return
		end

		local info = blame.entries[lnum]
		local sha = info.commit.sha

		-- Uncommitted lines have an all-zero sha
		if tonumber("0x" .. sha:sub(1, 8)) == 0 then
			vim.notify("Line not committed yet", vim.log.levels.WARN)
			return
		end

		vim.cmd.tabnew()
		require("gitsigns.actions.diffthis").show(bufnr, sha, info.filename)
		async.schedule()
		pcall(vim.api.nvim_win_set_cursor, 0, { info.orig_lnum or lnum, 0 })
	end)
end, { desc = "Open file from blamed commit" })

-- Permalinks to the current line / selection
vim.keymap.set({ "n", "v" }, "<leader>gy", "<cmd>GitLink<cr>", { desc = "Copy git permalink" })
vim.keymap.set({ "n", "v" }, "<leader>gY", "<cmd>GitLink!<cr>", { desc = "Open git permalink" })

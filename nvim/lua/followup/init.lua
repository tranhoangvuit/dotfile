-- Follow-up: markdown todo lists, one per git project plus a global one.
--
-- Lists live in stdpath("data")/followup, outside the repos. Items are plain
-- markdown checkboxes:
--
--   - [ ] Reply to review @2026-11-10 [src/api.lua:42]
--
-- `@YYYY-MM-DD` is a due date (shorthands @today, @tomorrow, @+3, @+2w, @fri
-- are expanded on add / save) and a trailing `[path:line]` links back to code.
local M = {}

M.config = {
	dir = vim.fn.stdpath("data") .. "/followup",
	-- Notify about due / overdue items on startup
	notify_on_start = true,
}

local ns = vim.api.nvim_create_namespace("followup")
local DATE = "%d%d%d%d%-%d%d%-%d%d"
local TITLE = "Follow-up"

-- file -> { mtime, items } for lists not loaded in a buffer
local file_cache = {}
-- path -> git root (false when outside a repo)
local root_cache = {}
-- float window -> window it was opened from
local floats = {}

-- Dates

local function today()
	return os.date("%Y-%m-%d") --[[@as string]]
end

local function date_offset(days)
	local t = os.date("*t")
	return os.date("%Y-%m-%d", os.time({ year = t.year, month = t.month, day = t.day + days, hour = 12 }))
end

local weekdays = {
	sun = 1, mon = 2, tue = 3, wed = 4, thu = 5, fri = 6, sat = 7,
	sunday = 1, monday = 2, tuesday = 3, wednesday = 4, thursday = 5, friday = 6, saturday = 7,
}

--- Expand @today, @tomorrow, @+3 (days), @+2w (weeks), @mon..@sun (next one) into @YYYY-MM-DD
---@param text string
---@return string
local function expand_dates(text)
	return (
		text:gsub("@([%w%+]+)", function(word)
			local w = word:lower()
			if w == "today" then
				return "@" .. date_offset(0)
			elseif w == "tomorrow" or w == "tmr" then
				return "@" .. date_offset(1)
			end
			local n, unit = w:match("^%+(%d+)([dw]?)$")
			if n then
				return "@" .. date_offset(tonumber(n) * (unit == "w" and 7 or 1))
			end
			local wd = weekdays[w]
			if wd then
				local diff = (wd - os.date("*t").wday) % 7
				return "@" .. date_offset(diff == 0 and 7 or diff)
			end
		end)
	)
end

---@param due string
local function due_hl(due)
	local t = today()
	if due < t then
		return "DiagnosticError"
	elseif due == t then
		return "DiagnosticWarn"
	end
	return "DiagnosticHint"
end

-- Lists

---@param root? string git root, nil for the global list
local function list_file(root)
	if not root then
		return M.config.dir .. "/global.md"
	end
	return M.config.dir .. "/projects/" .. (root:gsub("/", "%%")) .. ".md"
end

---@param file string
---@return string? root
local function list_root(file)
	if vim.fs.basename(file) == "global.md" then
		return nil
	end
	return (vim.fs.basename(file):gsub("%.md$", ""):gsub("%%", "/"))
end

---@param root? string
local function list_name(root)
	return root and vim.fs.basename(root) or "global"
end

local function all_files()
	local files = { list_file(nil) }
	vim.list_extend(files, vim.fn.glob(M.config.dir .. "/projects/*.md", false, true))
	return vim.tbl_filter(function(f)
		return vim.uv.fs_stat(f) ~= nil
	end, files)
end

---@param file string
---@param root? string
local function ensure_file(file, root)
	if vim.uv.fs_stat(file) then
		return
	end
	vim.fn.mkdir(vim.fs.dirname(file), "p")
	local header = root and ("# " .. list_name(root) .. "\n\n<!-- " .. root .. " -->") or "# global"
	vim.fn.writefile(vim.split(header .. "\n", "\n"), file)
end

--- Git root for a buffer: the list's own root inside a list buffer, otherwise
--- the buffer's file (or cwd for special buffers).
---@param buf? integer
---@return string?
local function current_root(buf)
	buf = buf or 0
	if vim.b[buf].followup_file then
		local r = vim.b[buf].followup_root
		return r ~= "" and r or nil
	end
	local name = vim.api.nvim_buf_get_name(buf)
	local path = (vim.bo[buf].buftype == "" and name ~= "") and name or vim.fn.getcwd()
	if root_cache[path] == nil then
		root_cache[path] = vim.fs.root(path, ".git") or false
	end
	return root_cache[path] or nil
end

--- Loaded buffer for a list file (exact name match; list names contain `%`)
---@param file string
---@return integer?
local function list_buf(file)
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_name(buf) == file then
			return buf
		end
	end
end

-- Items

---@class followup.Item
---@field lnum integer
---@field done boolean
---@field text string
---@field due? string
---@field link_path? string
---@field link_line? integer

---@param line string
---@param lnum integer
---@return followup.Item?
local function parse_line(line, lnum)
	local mark, text = line:match("^%s*[-*] %[([ xX])%] (.*)$")
	if not mark then
		return nil
	end
	local link_path, link_line = text:match("%[([^%]]+):(%d+)%]%s*$")
	return {
		lnum = lnum,
		done = mark ~= " ",
		text = text,
		due = text:match("@(" .. DATE .. ")"),
		link_path = link_path,
		link_line = tonumber(link_line),
	}
end

---@param lines string[]
---@return followup.Item[]
local function parse_lines(lines)
	local items = {}
	for i, line in ipairs(lines) do
		items[#items + 1] = parse_line(line, i)
	end
	return items
end

--- Items of a list, read from its buffer when loaded (may hold unsaved edits)
---@param file string
---@return followup.Item[]
local function read_items(file)
	local buf = list_buf(file)
	if buf then
		return parse_lines(vim.api.nvim_buf_get_lines(buf, 0, -1, false))
	end
	local stat = vim.uv.fs_stat(file)
	if not stat then
		return {}
	end
	local mtime = stat.mtime.sec * 1e9 + stat.mtime.nsec
	local cached = file_cache[file]
	if cached and cached.mtime == mtime then
		return cached.items
	end
	local items = parse_lines(vim.fn.readfile(file))
	file_cache[file] = { mtime = mtime, items = items }
	return items
end

local function refresh_statusline()
	pcall(function()
		require("lualine").refresh()
	end)
end

-- List buffer

---@param buf integer
local function highlight(buf)
	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
	for i, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
		local item = parse_line(line, i)
		if item and item.done then
			vim.api.nvim_buf_set_extmark(buf, ns, i - 1, 0, { end_col = #line, hl_group = "Comment" })
		elseif item and item.due then
			local s, e = line:find("@" .. DATE)
			vim.api.nvim_buf_set_extmark(buf, ns, i - 1, s - 1, { end_col = e, hl_group = due_hl(item.due) })
		end
	end
end

---@param buf integer
local function save(buf)
	if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].modified then
		vim.api.nvim_buf_call(buf, function()
			vim.cmd("silent! write")
		end)
	end
end

---@param win integer
local function close_float(win)
	local origin = floats[win]
	floats[win] = nil
	if vim.api.nvim_win_is_valid(win) then
		save(vim.api.nvim_win_get_buf(win))
		vim.api.nvim_win_close(win, true)
	end
	if origin and vim.api.nvim_win_is_valid(origin) then
		vim.api.nvim_set_current_win(origin)
	end
end

--- Open the code location an item links to
---@param item followup.Item
---@param root? string
local function goto_link(item, root)
	if not item.link_path then
		vim.notify("No [path:line] link on this item", vim.log.levels.INFO, { title = TITLE })
		return
	end
	local path = item.link_path
	if not path:match("^[/~]") then
		path = (root or vim.fn.getcwd()) .. "/" .. path
	end
	local win = vim.api.nvim_get_current_win()
	if floats[win] then
		close_float(win)
	end
	vim.cmd.edit(vim.fn.fnameescape(vim.fn.expand(path)))
	pcall(vim.api.nvim_win_set_cursor, 0, { item.link_line, 0 })
	vim.cmd("normal! zz")
end

---@param buf integer
local function toggle_item(buf)
	local row = vim.api.nvim_win_get_cursor(0)[1]
	local line = vim.api.nvim_buf_get_lines(buf, row - 1, row, false)[1]
	local new
	if line:match("^%s*[-*] %[ %]") then
		new = line:gsub("%[ %]", "[x]", 1)
	elseif line:match("^%s*[-*] %[[xX]%]") then
		new = line:gsub("%[[xX]%]", "[ ]", 1)
	elseif vim.trim(line) ~= "" and not line:match("^%s*[#<]") then
		-- Turn a plain line into an item
		local indent, text = line:match("^(%s*)[-*]?%s*(.*)$")
		new = indent .. "- [ ] " .. text
	end
	if new then
		vim.api.nvim_buf_set_lines(buf, row - 1, row, false, { new })
	end
end

---@param buf integer
---@param above boolean
local function new_item(buf, above)
	local row = vim.api.nvim_win_get_cursor(0)[1]
	local indent = vim.api.nvim_buf_get_lines(buf, row - 1, row, false)[1]:match("^(%s*)[-*] %[") or ""
	local at = above and row - 1 or row
	vim.api.nvim_buf_set_lines(buf, at, at, false, { indent .. "- [ ] " })
	vim.api.nvim_win_set_cursor(0, { at + 1, 0 })
	vim.cmd("startinsert!")
end

---@param buf integer
local function setup_buffer(buf)
	if vim.b[buf].followup_ready then
		return
	end
	vim.b[buf].followup_ready = true
	-- Lists autosave on leave; skip conform's format-on-save for them
	vim.b[buf].disable_autoformat = true

	local function map(lhs, rhs, desc)
		vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = desc, nowait = true })
	end
	map("<CR>", function()
		toggle_item(buf)
	end, "Toggle todo")
	map("o", function()
		new_item(buf, false)
	end, "New todo below")
	map("O", function()
		new_item(buf, true)
	end, "New todo above")
	map("gd", function()
		local row = vim.api.nvim_win_get_cursor(0)[1]
		local item = parse_line(vim.api.nvim_buf_get_lines(buf, row - 1, row, false)[1], row)
		if item then
			goto_link(item, current_root(buf))
		end
	end, "Go to linked code")
	map("q", function()
		local win = vim.api.nvim_get_current_win()
		if floats[win] then
			close_float(win)
		else
			save(buf)
			vim.cmd("close")
		end
	end, "Close todo list")

	local group = vim.api.nvim_create_augroup("followup_buf_" .. buf, { clear = true })
	vim.api.nvim_create_autocmd("BufWritePre", {
		group = group,
		buffer = buf,
		callback = function()
			local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
			local expanded = vim.tbl_map(expand_dates, lines)
			if not vim.deep_equal(lines, expanded) then
				vim.api.nvim_buf_set_lines(buf, 0, -1, false, expanded)
			end
		end,
	})
	vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave" }, {
		group = group,
		buffer = buf,
		callback = function()
			save(buf)
		end,
	})
	vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "InsertLeave", "BufWritePost" }, {
		group = group,
		buffer = buf,
		callback = function()
			highlight(buf)
			refresh_statusline()
		end,
	})
	highlight(buf)
end

-- Public API

---@class followup.OpenOpts
---@field global? boolean open the global list
---@field file? string open this list file
---@field lnum? integer put the cursor on this line

--- Open a todo list in a floating window
---@param opts? followup.OpenOpts
function M.open(opts)
	opts = opts or {}
	local root
	if opts.file then
		root = list_root(opts.file)
	elseif not opts.global then
		root = current_root()
	end
	local file = opts.file or list_file(root)
	ensure_file(file, root)

	local buf = vim.fn.bufadd(file)
	vim.fn.bufload(buf)
	vim.bo[buf].buflisted = false
	vim.b[buf].followup_file = file
	vim.b[buf].followup_root = root or ""
	setup_buffer(buf)

	-- Reuse the float if this list is already open
	local win
	for w in pairs(floats) do
		if vim.api.nvim_win_is_valid(w) and vim.api.nvim_win_get_buf(w) == buf then
			win = w
		end
	end
	if win then
		vim.api.nvim_set_current_win(win)
	else
		local origin = vim.api.nvim_get_current_win()
		local width = math.min(100, math.floor(vim.o.columns * 0.7))
		local height = math.floor(vim.o.lines * 0.7)
		win = vim.api.nvim_open_win(buf, true, {
			relative = "editor",
			width = width,
			height = height,
			col = math.floor((vim.o.columns - width) / 2),
			row = math.floor((vim.o.lines - height) / 2),
			border = "rounded",
			title = " Todo · " .. list_name(root) .. " ",
			title_pos = "center",
			footer = " <CR> toggle · o add · gd go to code · q close ",
			footer_pos = "center",
		})
		floats[win] = origin
		vim.wo[win].conceallevel = 2
		vim.api.nvim_create_autocmd("WinClosed", {
			pattern = tostring(win),
			once = true,
			callback = function()
				floats[win] = nil
			end,
		})
	end
	if opts.lnum then
		pcall(vim.api.nvim_win_set_cursor, win, { opts.lnum, 0 })
	end
end

---@class followup.AddOpts
---@field global? boolean add to the global list
---@field link? boolean append a [path:line] link to the current cursor position

--- Link text for the current cursor position, relative to `root` when inside it
---@param root? string
---@return string?
local function cursor_link(root)
	local name = vim.api.nvim_buf_get_name(0)
	if name == "" or vim.bo.buftype ~= "" or vim.b.followup_file then
		return nil
	end
	local path = vim.fn.fnamemodify(name, ":p")
	if root and vim.startswith(path, root .. "/") then
		path = path:sub(#root + 2)
	else
		path = vim.fn.fnamemodify(path, ":~")
	end
	return "[" .. path .. ":" .. vim.fn.line(".") .. "]"
end

--- Append an item to the current project's list (or the global one)
---@param text string
---@param opts? followup.AddOpts
function M.add(text, opts)
	opts = opts or {}
	local root = not opts.global and current_root() or nil
	local link = opts.link and cursor_link(root)
	text = vim.trim(expand_dates(text or ""))
	if text == "" then
		return
	end
	if link then
		text = text .. " " .. link
	end

	local file = list_file(root)
	ensure_file(file, root)
	local line = "- [ ] " .. text
	local buf = list_buf(file)
	if buf then
		vim.api.nvim_buf_set_lines(buf, -1, -1, false, { line })
		vim.api.nvim_buf_call(buf, function()
			vim.cmd("silent! write")
		end)
	else
		vim.fn.writefile({ line }, file, "a")
	end
	vim.notify("Added to " .. list_name(root) .. ": " .. text, vim.log.levels.INFO, { title = TITLE })
	refresh_statusline()
end

--- Prompt for an item and add it
---@param opts? followup.AddOpts
function M.prompt(opts)
	opts = opts or {}
	-- Resolve list and link before the prompt takes focus
	local root = not opts.global and current_root() or nil
	local link = opts.link and cursor_link(root)
	vim.ui.input({ prompt = "Todo (" .. list_name(root) .. "): " }, function(input)
		if input and vim.trim(input) ~= "" then
			M.add(link and (input .. " " .. link) or input, { global = opts.global })
		end
	end)
end

--- Open items from every list, due ones first
---@return { item: followup.Item, file: string, root?: string }[]
local function open_items()
	local result = {}
	for _, file in ipairs(all_files()) do
		local root = list_root(file)
		for _, item in ipairs(read_items(file)) do
			if not item.done then
				result[#result + 1] = { item = item, file = file, root = root }
			end
		end
	end
	for i, entry in ipairs(result) do
		entry.order = i
	end
	table.sort(result, function(a, b)
		local da, db = a.item.due or "9999", b.item.due or "9999"
		if da ~= db then
			return da < db
		end
		return a.order < b.order
	end)
	return result
end

--- Pick from open items across all lists. <CR> opens the list at the item,
--- <C-g> jumps to the linked code.
function M.find()
	local items = {}
	for _, entry in ipairs(open_items()) do
		items[#items + 1] = {
			text = list_name(entry.root) .. " " .. entry.item.text,
			file = entry.file,
			pos = { entry.item.lnum, 0 },
			todo = entry.item,
			root = entry.root,
		}
	end
	if #items == 0 then
		vim.notify("No open todos", vim.log.levels.INFO, { title = TITLE })
		return
	end
	Snacks.picker({
		title = "Todos",
		items = items,
		format = function(entry)
			local ret = { { string.format("%-14s", list_name(entry.root)), "Directory" } }
			if entry.todo.due then
				ret[#ret + 1] = { entry.todo.due .. " ", due_hl(entry.todo.due) }
			end
			ret[#ret + 1] = { (entry.todo.text:gsub("%s*@" .. DATE, "")) }
			return ret
		end,
		preview = "file",
		confirm = function(picker, entry)
			picker:close()
			if entry then
				M.open({ file = entry.file, lnum = entry.pos[1] })
			end
		end,
		actions = {
			goto_link = function(picker, entry)
				picker:close()
				if entry then
					goto_link(entry.todo, entry.root)
				end
			end,
		},
		win = {
			input = {
				keys = { ["<c-g>"] = { "goto_link", mode = { "n", "i" } } },
			},
		},
	})
end

--- Notify about open items due today or overdue
---@param opts? { verbose?: boolean } also notify when nothing is due
function M.check_due(opts)
	local t = today()
	local overdue, due_today, lines = 0, 0, {}
	for _, entry in ipairs(open_items()) do
		local due = entry.item.due
		if due and due <= t then
			if due < t then
				overdue = overdue + 1
			else
				due_today = due_today + 1
			end
			if #lines < 10 then
				lines[#lines + 1] = string.format(
					"%s [%s] %s",
					due < t and "!" or "•",
					list_name(entry.root),
					(entry.item.text:gsub("%s*@" .. DATE, ""))
				)
			end
		end
	end
	if overdue + due_today == 0 then
		if opts and opts.verbose then
			vim.notify("Nothing due today", vim.log.levels.INFO, { title = TITLE })
		end
		return
	end
	local header = string.format("%d overdue, %d due today (<leader>nf to review)", overdue, due_today)
	vim.notify(header .. "\n" .. table.concat(lines, "\n"), vim.log.levels.WARN, { title = TITLE })
end

--- Remove completed items from the current list
function M.clean()
	local root = current_root()
	local file = list_file(root)
	if not vim.uv.fs_stat(file) then
		return
	end
	local buf = list_buf(file)
	local loaded = buf ~= nil
	local lines = loaded and vim.api.nvim_buf_get_lines(buf, 0, -1, false) or vim.fn.readfile(file)
	local kept = vim.tbl_filter(function(line)
		local item = parse_line(line, 0)
		return not (item and item.done)
	end, lines)
	if loaded then
		vim.api.nvim_buf_set_lines(buf --[[@as integer]], 0, -1, false, kept)
		save(buf --[[@as integer]])
	else
		vim.fn.writefile(kept, file)
	end
	vim.notify(("Removed %d done item(s) from %s"):format(#lines - #kept, list_name(root)), vim.log.levels.INFO, {
		title = TITLE,
	})
	refresh_statusline()
end

--- Open / overdue counts for the current project's list
---@return integer open, integer overdue
function M.counts()
	local t = today()
	local open, overdue = 0, 0
	for _, item in ipairs(read_items(list_file(current_root()))) do
		if not item.done then
			open = open + 1
			if item.due and item.due < t then
				overdue = overdue + 1
			end
		end
	end
	return open, overdue
end

--- lualine component: open item count, with overdue count when any
function M.lualine()
	return {
		function()
			local open, overdue = M.counts()
			return overdue > 0 and (" " .. open .. " !" .. overdue) or (" " .. open)
		end,
		cond = function()
			return (M.counts()) > 0
		end,
		color = function()
			local _, overdue = M.counts()
			return { fg = Snacks.util.color(overdue > 0 and "DiagnosticError" or "Special") }
		end,
	}
end

local subcommands = {
	open = function()
		M.open()
	end,
	global = function()
		M.open({ global = true })
	end,
	add = function(args)
		if args == "" then
			M.prompt()
		else
			M.add(args)
		end
	end,
	find = M.find,
	due = function()
		M.check_due({ verbose = true })
	end,
	clean = M.clean,
}

---@param opts? { dir?: string, notify_on_start?: boolean }
function M.setup(opts)
	M.config = vim.tbl_extend("force", M.config, opts or {})

	vim.api.nvim_create_user_command("Followup", function(cmd)
		local sub = cmd.fargs[1] or "open"
		local fn = subcommands[sub]
		if not fn then
			vim.notify("Unknown subcommand: " .. sub, vim.log.levels.ERROR, { title = TITLE })
			return
		end
		fn(table.concat(vim.list_slice(cmd.fargs, 2), " "))
	end, {
		nargs = "*",
		desc = "Todo lists (open | global | add [text] | find | due | clean)",
		complete = function(arglead, line)
			if #vim.split(line, "%s+") > 2 then
				return {}
			end
			return vim.tbl_filter(function(name)
				return vim.startswith(name, arglead)
			end, vim.tbl_keys(subcommands))
		end,
	})

	if M.config.notify_on_start then
		vim.api.nvim_create_autocmd("VimEnter", {
			group = vim.api.nvim_create_augroup("followup", { clear = true }),
			once = true,
			callback = function()
				vim.defer_fn(M.check_due, 1000)
			end,
		})
	end
end

return M

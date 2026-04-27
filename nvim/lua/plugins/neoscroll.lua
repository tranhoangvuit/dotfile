vim.pack.add({
    "https://github.com/karb94/neoscroll.nvim"
})

require('neoscroll').setup({
	hide_cursor = false,
	stop_eof = true,
	easing = 'quadratic',
	duration_multiplier = 0.30,
})

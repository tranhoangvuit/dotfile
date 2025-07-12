return {
	enabled = true,
	"folke/flash.nvim",
	opts = {
		search = {
			forward = true,
			multi_window = false,
			wrap = false,
			incremental = true,
		},
		modes = {
			char = {
				jump_labels = true,
				keys = { "f", "F", "t", "T" },
			},
		},
	},
}

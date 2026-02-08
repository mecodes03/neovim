return {
	"sourcegraph/amp.nvim",
	branch = "main",
	lazy = false,
	config = function()
		local amp_msg = require("amp.message")
		local create_user_cmd = vim.api.nvim_create_user_command

		-- Send a quick message to the agent
		create_user_cmd("AmpSend", function(opts)
			local message = opts.args
			if message == "" then
				print("Please provide a message to send")
				return
			end

			amp_msg.send_message(message)
		end, {
			nargs = "*",
			desc = "Send a message to Amp",
		})

		-- Send entire buffer contents
		create_user_cmd("AmpSendBuffer", function(_)
			local buf = vim.api.nvim_get_current_buf()
			local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
			local content = table.concat(lines, "\n")

			amp_msg.send_message(content)
		end, {
			nargs = "?",
			desc = "Send current buffer contents to Amp",
		})

		-- Add selected text directly to prompt
		create_user_cmd("AmpPromptSelection", function(opts)
			local lines = vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, false)
			local text = table.concat(lines, "\n") .. "\n\n"

			local amp_message = amp_msg
			amp_message.send_to_prompt(text)
		end, {
			range = true,
			desc = "Add selected text to Amp prompt",
		})

		-- Add file+selection reference to prompt
		create_user_cmd("AmpPromptRef", function(opts)
			local bufname = vim.api.nvim_buf_get_name(0)
			if bufname == "" then
				print("Current buffer has no filename")
				return
			end

			local relative_path = vim.fn.fnamemodify(bufname, ":.")
			local ref = "@" .. relative_path
			if opts.line1 ~= opts.line2 then
				ref = ref .. "#L" .. opts.line1 .. "-" .. opts.line2
			elseif opts.line1 > 1 then
				ref = ref .. "#L" .. opts.line1
			end

			amp_msg.send_to_prompt(ref .. "\n")
		end, {
			range = true,
			desc = "Add file reference (with selection) to Amp prompt",
		})

		local map = vim.keymap.set

		local function prompt_with_selection()
			local buf = vim.api.nvim_get_current_buf()
			local file_path = vim.api.nvim_buf_get_name(buf)
			local relative_path = vim.fn.fnamemodify(file_path, ":.")

			local start_line = vim.fn.line("'<")
			local end_line = vim.fn.line("'>")
			local lines = vim.api.nvim_buf_get_lines(buf, start_line - 1, end_line, false)
			local selected_text = table.concat(lines, "\n")

			local width = math.floor(vim.o.columns * 0.6)
			local height = math.floor(vim.o.lines * 0.3)
			local row = math.floor((vim.o.lines - height) / 2)
			local col = math.floor((vim.o.columns - width) / 2)

			local input_buf = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_set_option_value("buftype", "nofile", { buf = input_buf })

			local win = vim.api.nvim_open_win(input_buf, true, {
				relative = "editor",
				width = width,
				height = height,
				row = row,
				col = col,
				border = "rounded",
				title = " Prompt ",
				title_pos = "center",
			})

			-- vim.api.nvim_set_option_value("wrap", false, { win = win })
			-- vim.api.nvim_set_option_value("linebreak", true, { win = win })

			local function send()
				local prompt_lines = vim.api.nvim_buf_get_lines(input_buf, 0, -1, false)
				local prompt_text = vim.fn.trim(table.concat(prompt_lines, "\n"))

				vim.api.nvim_win_close(win, true)
				vim.api.nvim_buf_delete(input_buf, { force = true })
				vim.cmd("stopinsert")

				if prompt_text == "" then
					return
				end

				local message = string.format(
					"In file `%s` (lines %d-%d) \n code:\n\n```\n%s\n```\n\n%s",
					relative_path,
					start_line,
					end_line,
					selected_text,
					prompt_text
				)

				amp_msg.send_message(message)
			end

			local function close()
				vim.api.nvim_win_close(win, true)
				vim.api.nvim_buf_delete(input_buf, { force = true })
			end

			map("i", "<C-s>", send, { buffer = input_buf })
			map("n", "<C-s>", send, { buffer = input_buf })
			map("n", "<Esc>", close, { buffer = input_buf })
			map("n", "q", close, { buffer = input_buf })
			vim.cmd("startinsert")
		end



		local function implement_method_at_cursor()
			local buf = vim.api.nvim_get_current_buf()
			local file_path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":.")
			local cursor = vim.api.nvim_win_get_cursor(0)
			local row = cursor[1] - 1
			local col = cursor[2]

			local node = vim.treesitter.get_node({ bufnr = buf, pos = { row, col } })
			if not node then
				print("No treesitter node found at cursor")
				return
			end

			while node do
				local type = node:type()
				if type:match("function") or type:match("method") then
					break
				end
				node = node:parent()
			end

			if not node then
				print("No function/declaration found at cursor")
				return
			end

			local start_row, _, end_row, _ = node:range()
			local lines = vim.api.nvim_buf_get_lines(buf, start_row, end_row + 1, false)
			local text = table.concat(lines, "\n")

			local message = string.format(
				"In file `%s` (lines %d-%d) \n code:\n\n```\n%s\n```\n\ncomplete this. write the full implementation. (only if its not implemented already. if its implemented, DO NOTHING.).",
				file_path,
				start_row + 1,
				end_row + 1,
				text
			)

			amp_msg.send_message(message)
		end

		-- Normal mode
		map("n", "<leader>am", function()
			vim.ui.input({ prompt = "Amp > " }, function(input)
				if input then
					amp_msg.send_message(input)
				end
			end)
		end, { desc = "Amp: send prompt" })
		map("n", "<leader>ab", "<cmd>AmpSendBuffer<cr>", { desc = "Amp: send current buffer" })
		map("n", "<leader>ai", implement_method_at_cursor, { desc = "Amp: complete function at cursor" })

		-- add current file as @file ref to prompt (no selection needed)
		map("n", "<leader>af", function()
			local bufname = vim.api.nvim_buf_get_name(0)
			if bufname == "" then
				print("Current buffer has no filename")
				return
			end
			local ref = "@" .. vim.fn.fnamemodify(bufname, ":.")
			amp_msg.send_to_prompt(ref)
		end, { desc = "Amp: ref current file" })

		-- send diagnostic under cursor to Amp to fix
		map("n", "<leader>ad", function()
			local diagnostics = vim.diagnostic.get(0, { lnum = vim.api.nvim_win_get_cursor(0)[1] - 1 })
			if #diagnostics == 0 then
				print("No diagnostics at cursor")
				return
			end
			local file_path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.")
			local parts = {}
			for _, d in ipairs(diagnostics) do
				local severity = vim.diagnostic.severity[d.severity] or "UNKNOWN"
				table.insert(parts, string.format("[%s] %s", severity, d.message))
			end
			local message = string.format(
				"In file `%s` at line %d, fix these diagnostics:\n\n%s",
				file_path,
				vim.api.nvim_win_get_cursor(0)[1],
				table.concat(parts, "\n")
			)
			amp_msg.send_message(message)
		end, { desc = "Amp: fix diagnostic at cursor" })

		-- send stop/cancel to Amp
		map("n", "<leader>ac", function()
			amp_msg.send_message("stop")
		end, { desc = "Amp: stop/cancel" })

		-- Visual mode
		map("v", "<leader>ap", prompt_with_selection, { desc = "Amp: floating prompt win with selected text" })
		map("v", "<leader>ar", ":'<,'>AmpPromptRef<cr>", { desc = "Amp: ref selection" })
		map("v", "<leader>as", ":'<,'>AmpPromptSelection<cr>", { desc = "Amp: add selected text to prompt" })

		require("amp").setup({ auto_start = true, log_level = "info" })
	end
}

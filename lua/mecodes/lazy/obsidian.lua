return {
	"obsidian-nvim/obsidian.nvim",
	version = "*", -- use latest release, remove to use latest commit
	---@module 'obsidian'
	---@type obsidian.config

	lazy = true,
	opts = {
		legacy_commands = false, -- this will be removed in 4.0.0
		workspaces = {
			{
				name = "personal",
				path = "~/vault/personal",
				overrides = {
					notes_subdir = "notes",
					daily_notes = {
						-- Optional, if you keep daily notes in a separate directory.
						folder = "notes/daily",
						-- Optional, if you want to change the date format for the ID of daily notes.
						date_format = "%Y-%m-%d",
						-- Optional, if you want to change the date format of the default alias of daily notes.
						alias_format = "%B %-d, %Y",
						-- Optional, default tags to add to each new daily note created.
						default_tags = { "personal", "daily" },
						-- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
						template = nil
					},
				}
			},
			{
				name = "work",
				path = "~/vault/work",
				overrides = {
					notes_subdir = "notes",
					daily_notes = {
						-- Optional, if you keep daily notes in a separate directory.
						folder = "notes/daily",
						-- Optional, if you want to change the date format for the ID of daily notes.
						date_format = "%Y-%m-%d",
						-- Optional, if you want to change the date format of the default alias of daily notes.
						alias_format = "%B %-d, %Y",
						-- Optional, default tags to add to each new daily note created.
						default_tags = { "work", "daily" },
						-- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
						template = nil
					},
				}
			},
		},

		notes_subdir = "notes",
		-- use_advanced_uri = true,

		-- Optional, customize how note IDs are generated given an optional title.
		---@param title string|?
		---@return string
		note_id_func = function(title)
			-- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
			-- In this case a note with the title 'My new note' will be given an ID that looks
			-- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'
			local suffix = ""
			if title ~= nil then
				-- If title is given, transform it into valid file name.
				suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
			else
				-- If title is nil, just add 4 random uppercase letters to the suffix.
				for _ = 1, 4 do
					suffix = suffix .. string.char(math.random(65, 90))
				end
			end
			return tostring(os.time()) .. "-" .. suffix
		end,

		-- Optional, alternatively you can customize the frontmatter data.
		---@return table
		note_frontmatter_func = function(note)
			-- Add the title of the note as an alias.
			if note.title then
				note:add_alias(note.title)
			end

			local path = vim.api.nvim_buf_get_name(0)
			if path:find("/home/mecodes/vault/personal/notes/") or path:find("/home/mecodes/vault/personal/notes/") then
				note:add_tag("notes")
			end

			local out = { id = note.id, aliases = note.aliases, tags = note.tags }

			-- `note.metadata` contains any manually added fields in the frontmatter.
			-- So here we just make sure those fields are kept in the frontmatter.
			if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
				for k, v in pairs(note.metadata) do
					out[k] = v
				end
			end

			return out
		end,

		-- Optional, for templates (see below).
		templates = {
			folder = "templates",
			date_format = "%Y-%m-%d",
			time_format = "%H:%M",
			-- A map for custom variables, the key should be the variable and the value a function
			substitutions = {},
		},

		-- Optional, by default when you use `:ObsidianFollowLink` on a link to an external
		-- URL it will be ignored but you can customize this behavior here.
		---@param url string
		follow_url_func = function(url)
			-- Open the URL in the default web browser.
			-- vim.fn.jobstart({ "open", url }) -- Mac OS
			-- -- vim.fn.jobstart({"xdg-open", url})  -- linux
			-- -- vim.cmd(':silent exec "!start ' .. url .. '"') -- Windows
			vim.ui.open(url) -- need Neovim 0.10.0+
		end,
	},

	config = function(_, opts)
		local obsidian = require("obsidian")

		obsidian.setup(opts)

		local client = obsidian.get_client()
		local commands = require("obsidian.commands")
		local log = require("obsidian.log")
		local RefTypes = require("obsidian.search").RefTypes
		local util = require("obsidian.util")

		-- obsidian.nvim hardcodes `wsl-open` on WSL; replace the command to launch the Linux app directly.
		local function open_in_wsl_obsidian(path)
			if vim.fn.executable("obsidian") == 0 then
				log.err("'obsidian' executable was not found in WSL")
				return
			end

			path = tostring(client:vault_relative_path(path, { strict = true }))

			local encoded_vault = util.urlencode(client:vault_name())
			local encoded_path = util.urlencode(path)
			local uri

			if client.opts.use_advanced_uri then
				local line = vim.api.nvim_win_get_cursor(0)[1] or 1
				uri = ("obsidian://advanced-uri?vault=%s&filepath=%s&line=%i"):format(encoded_vault, encoded_path, line)
			else
				uri = ("obsidian://open?vault=%s&file=%s"):format(encoded_vault, encoded_path)
			end

			vim.fn.jobstart({ "obsidian", "--no-sandbox", uri }, {
				detach = true,
				on_exit = function(_, exit_code)
					if exit_code ~= 0 then
						log.err("obsidian command failed with exit code '%s'", exit_code)
					end
				end,
			})
		end

		pcall(vim.api.nvim_del_user_command, "ObsidianOpen")

		vim.api.nvim_create_user_command("ObsidianOpen", function(data)
			local search_term

			if data.args and data.args:len() > 0 then
				search_term = data.args
			else
				local cursor_link, _, ref_type = util.parse_cursor_link()
				if cursor_link ~= nil and ref_type ~= RefTypes.NakedUrl and ref_type ~= RefTypes.FileUrl then
					search_term = cursor_link
				end
			end

			if search_term then
				client:resolve_note_async_with_picker_fallback(search_term, function(note)
					vim.schedule(function()
						open_in_wsl_obsidian(note.path)
					end)
				end, { prompt_title = "Select note to open" })
				return
			end

			local bufname = vim.api.nvim_buf_get_name(0)
			local path = client:vault_relative_path(bufname, { strict = true })

			if path == nil then
				log.err("Current buffer '%s' does not appear to be inside the vault", bufname)
				return
			end

			open_in_wsl_obsidian(path)
		end, {
			nargs = "?",
			desc = "Open in the Obsidian app",
			complete = function(arg_lead, cmd_line, cursor_pos)
				return commands.complete_args_search(client, arg_lead, cmd_line, cursor_pos)
			end,
		})

		-- workspace switching
		vim.keymap.set("n", "<leader>wp", function()
			vim.cmd("ObsidianWorkspace personal")
			vim.fn.chdir("/home/mecodes/vault/personal")
			vim.cmd("e .")
		end, { desc = "Obsidian: personal vault" })

		vim.keymap.set("n", "<leader>ww", function()
			vim.cmd("ObsidianWorkspace work") -- fixed: was personal
			vim.fn.chdir("/home/mecodes/vault/work")
			vim.cmd("e .")
		end, { desc = "Obsidian: work vault" })

		-- open in obsidian app
		vim.keymap.set("n", "<leader>oo", function()
			vim.cmd("ObsidianOpen")
		end, { desc = "Obsidian: Open in app" })

		-- new note
		vim.keymap.set("n", "<leader>on", function()
			local title = vim.fn.input("Note Title > ")
			if title ~= "" then
				vim.cmd("ObsidianNew " .. title)
			end
		end, { desc = "Obsidian: New note" })

		-- quick switch
		vim.keymap.set("n", "<leader>os", function()
			vim.cmd("ObsidianQuickSwitch")
		end, { desc = "Obsidian: Quick switch" })

		-- search
		vim.keymap.set("n", "<leader>of", function()
			vim.cmd("ObsidianSearch")
		end, { desc = "Obsidian: Search" })

		-- today's daily note
		vim.keymap.set("n", "<leader>oj", function()
			vim.cmd("ObsidianToday")
		end, { desc = "Obsidian: Today's daily note" })

		-- yesterday's daily note
		vim.keymap.set("n", "<leader>oy", function()
			vim.cmd("ObsidianYesterday")
		end, { desc = "Obsidian: Yesterday's daily note" })

		-- open inbox
		vim.keymap.set("n", "<leader>oi", function()
			vim.cmd("e /home/mecodes/vault/personal/inbox/inbox.md")
		end, { desc = "Obsidian: Inbox" })

		-- paste image
		vim.keymap.set("n", "<leader>op", function()
			vim.cmd("ObsidianPasteImg")
		end, { desc = "Obsidian: Paste image" })

		-- follow link under cursor
		vim.keymap.set("n", "<leader>gl", function()
			vim.cmd("ObsidianFollowLink")
		end, { desc = "Obsidian: Follow link", noremap = true })

		-- backlinks
		vim.keymap.set("n", "<leader>ob", function()
			vim.cmd("ObsidianBacklinks")
		end, { desc = "Obsidian: Backlinks" })

		-- tags
		vim.keymap.set("n", "<leader>ot", function()
			vim.cmd("ObsidianTags")
		end, { desc = "Obsidian: Tags" })

		-- rename note
		vim.keymap.set("n", "<leader>or", function()
			local name = vim.fn.input("Rename to > ")
			if name ~= "" then
				vim.cmd("ObsidianRename " .. name)
			end
		end, { desc = "Obsidian: Rename note" })
	end,
}

return {
	"obsidian-nvim/obsidian.nvim",
	version = "*", -- use latest release, remove to use latest commit
	lazy = true,
	opts = {
		legacy_commands = false, -- this will be removed in 4.0.0
		new_notes_location = "notes",
		workspaces = {
			{
				name = "personal",
				path = "/home/mecodes/vault/personal",
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
						template = nil,
					},
				},
			},
			{
				name = "work",
				path = "/home/mecodes/vault/work",
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
						template = nil,
					},
				},
			},
		},
		note_id_func = function(title)
			local suffix = ""
			if title ~= nil then
				suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
			else
				for _ = 1, 4 do
					suffix = suffix .. string.char(math.random(65, 90))
				end
			end
			return tostring(os.time()) .. "-" .. suffix
		end,

		note_frontmatter = {
			func = function(note)
				if note.title then
					note:add_alias(note.title)
				end

				note:add_tag("notes")

				local out = { id = note.id, aliases = note.aliases, tags = note.tags }

				if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
					for k, v in pairs(note.metadata) do
						out[k] = v
					end
				end

				return out
			end,
		},
	},

	config = function(_, opts)
		require("obsidian").setup(opts)

		-- workspace switching
		vim.keymap.set("n", "<leader>wp", function()
			vim.cmd("Obsidian workspace personal")
			vim.fn.chdir("/home/mecodes/vault/personal")
			vim.cmd("e .")
		end, { desc = "Obsidian: personal vault" })

		vim.keymap.set("n", "<leader>ww", function()
			vim.cmd("Obsidian workspace work") -- fixed: was personal
			vim.fn.chdir("/home/mecodes/vault/work")
			vim.cmd("e .")
		end, { desc = "Obsidian: work vault" })

		-- open in obsidian app
		vim.keymap.set("n", "<leader>oo", function()
			vim.cmd("Obsidian open")
		end, { desc = "Obsidian: Open in app" })

		-- new note
		vim.keymap.set("n", "<leader>on", function()
			local title = vim.fn.input("Note Title > ")
			if title ~= "" then
				vim.cmd("Obsidian new " .. title)
			end
		end, { desc = "Obsidian: New note" })

		local builtin = require("telescope.builtin")

		-- quick switch
		vim.keymap.set("n", "<leader>sf", function()
			local cwd = vim.fn.getcwd()
			if cwd:find("/home/mecodes/vault") then
				vim.cmd("Obsidian quick_switch")
			else
				builtin.git_files()
			end
		end, { desc = "Obsidian: Quick switch" })

		-- search
		vim.keymap.set("n", "<leader>sg", function()
			local cwd = vim.fn.getcwd()
			if cwd:find("/home/mecodes/vault") then
				vim.cmd("Obsidian search")
			else
				builtin.git_files()
			end
		end, { desc = "Obsidian: Search", noremap = true })

		-- yesterday's daily note
		vim.keymap.set("n", "<leader>oy", function()
			vim.cmd("Obsidian yesterday")
		end, { desc = "Obsidian: Yesterday's daily note" })

		-- today's daily note
		vim.keymap.set("n", "<leader>oj", function()
			vim.cmd("Obsidian today")
		end, { desc = "Obsidian: Today's daily note" })

		-- tomorrow's daily note
		vim.keymap.set("n", "<leader>od", function()
			vim.cmd("Obsidian tomorrow")
		end, { desc = "Obsidian: Tomorrow's daily note" })

		-- open inbox
		vim.keymap.set("n", "<leader>oi", function()
			-- TODO: this should be conditional (open current workspace inbox.md file)
			vim.cmd("e /home/mecodes/vault/work/inbox.md")
		end, { desc = "Obsidian: Inbox" })

		-- paste image
		vim.keymap.set("n", "<leader>op", function()
			vim.cmd("Obsidian paste_img")
		end, { desc = "Obsidian: Paste image" })

		-- Link Note to Inline Text
		vim.keymap.set({ "v" }, "<leader>oli", function()
			vim.cmd("Obsidian link")
		end, { desc = "Obsidian: Link Note to Inline Visual Text", noremap = true })

		-- Create new Note and Link to Selected Text
		vim.keymap.set({ "v" }, "<leader>oln", function()
			local title = vim.fn.input("Note Title > ")
			vim.cmd("Obsidian link_new" .. " " .. title)
		end, { desc = "Obsidian: Create and Link Note to Inline Visual Text", noremap = true })

		-- extract note
		vim.keymap.set("v", "<leader>oe", function()
			vim.cmd("Obsidian extract_note")
		end, { desc = "Obsidian: Extract Note", noremap = true })

		-- backlinks
		vim.keymap.set("n", "<leader>ob", function()
			vim.cmd("Obsidian backlinks")
		end, { desc = "Obsidian: Backlinks" })

		-- tags
		vim.keymap.set("n", "<leader>ott", function()
			vim.cmd("Obsidian tags")
		end, { desc = "Obsidian: Tags" })

		-- tags
		vim.keymap.set("n", "<leader>otc", function()
			vim.cmd("Obsidian toc")
		end, { desc = "Obsidian: Table of contents" })

		-- rename note
		vim.keymap.set("n", "<leader>or", function()
			local name = vim.fn.input("Rename to > ")
			if name ~= "" then
				vim.cmd("Obsidian rename " .. name)
			end
		end, { desc = "Obsidian: Rename note" })
	end,
}

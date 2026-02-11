-- 配置先の想定: ~/.config/nvim/init.lua

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 任意プロバイダ（未使用なら警告を抑止）
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- 基本オプション（VSCode寄り）
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 200
vim.opt.termguicolors = true
-- 検索ハイライトは普段はオフ。必要時だけ点灯（Escで消す）
vim.opt.hlsearch = true
-- 余計なメッセージを抑制（term:// やファイル情報のエコーを非表示）
pcall(function()
	vim.opt.shortmess:append("F") -- ファイル情報メッセージを抑制（term://... 等）
end)

-- Diagnostics: show error codes and handy shortcuts
do
	-- extract diagnostic code from various servers
	local function code_of(d)
		local c = d and d.code
		if type(c) == "table" then
			c = c.code or c.name
		end
		if (not c) and d and d.user_data and d.user_data.lsp then
			c = d.user_data.lsp.code
		end
		return c
	end

	-- add [CODE] prefix in diagnostic float
	vim.diagnostic.config({
		float = {
			border = "rounded",
			focusable = true,
			format = function(d)
				local c = code_of(d)
				return c and ("[" .. tostring(c) .. "] " .. d.message) or d.message
			end,
		},
		severity_sort = true,
	})

	-- <leader>e: open line diagnostics float (always line scope)
	vim.keymap.set("n", "<leader>e", function()
		vim.diagnostic.open_float(0, { scope = "line", focus = true })
	end, { desc = "Diagnostics: Line float ([CODE] msg)" })

	-- <leader>ec: copy current line's top diagnostic (code: message)
	vim.keymap.set("n", "<leader>ec", function()
		local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
		local ds = vim.diagnostic.get(0, { lnum = lnum })
		if #ds == 0 then
			pcall(vim.notify, "No diagnostics on this line", vim.log.levels.INFO)
			return
		end
		table.sort(ds, function(a, b)
			return (a.severity or 4) < (b.severity or 4)
		end)
		local d = ds[1]
		local c = code_of(d)
		local text = c and (tostring(c) .. ": " .. d.message) or d.message
		vim.fn.setreg("+", text)
		vim.fn.setreg("*", text)
		pcall(vim.notify, "Copied diagnostic" .. (c and (" (" .. c .. ")") or ""), vim.log.levels.INFO)
	end, { desc = "Diagnostics: Copy current (code+message)" })

	-- <leader>ev: toggle inline virtual_text with [CODE]
	vim.keymap.set("n", "<leader>ev", function()
		local cfg = vim.diagnostic.config()
		local v = cfg.virtual_text
		local enabled = (v == true) or (type(v) == "table")
		if enabled then
			vim.diagnostic.config({ virtual_text = false })
			pcall(vim.notify, "Diagnostic virtual_text: off", vim.log.levels.INFO)
		else
			vim.diagnostic.config({
				virtual_text = {
					format = function(d)
						local c = code_of(d)
						return c and ("[" .. tostring(c) .. "] " .. d.message) or d.message
					end,
					spacing = 2,
				},
			})
			pcall(vim.notify, "Diagnostic virtual_text: on", vim.log.levels.INFO)
		end
	end, { desc = "Diagnostics: Toggle virtual_text ([CODE] msg)" })

	-- <leader>el: toggle virtual_lines (Neovim 0.11+)
	if vim.fn.has("nvim-0.11") == 1 then
		vim.keymap.set("n", "<leader>el", function()
			local cfg = vim.diagnostic.config()
			local v = cfg.virtual_lines
			local enabled = (v == true) or (type(v) == "table")
			if enabled then
				vim.diagnostic.config({ virtual_lines = false })
				pcall(vim.notify, "Diagnostic virtual_lines: off", vim.log.levels.INFO)
			else
				vim.diagnostic.config({
					virtual_lines = {
						format = function(d)
							local c = code_of(d)
							return c and ("[" .. tostring(c) .. "] " .. d.message) or d.message
						end,
					},
				})
				pcall(vim.notify, "Diagnostic virtual_lines: on", vim.log.levels.INFO)
			end
		end, { desc = "Diagnostics: Toggle virtual_lines ([CODE] msg)" })
	end
end

-- 追加の filetype 定義（LSPの unknown filetype 警告を解消）
pcall(function()
	vim.filetype.add({
		extension = {
			mdx = "markdown.mdx",
			tfvars = "terraform-vars",
		},
		filename = {
			["docker-compose.yaml"] = "yaml.docker-compose",
			["docker-compose.yml"] = "yaml.docker-compose",
			["compose.yaml"] = "yaml.docker-compose",
			["compose.yml"] = "yaml.docker-compose",
			["values.yaml"] = "yaml.helm-values",
			["values.yml"] = "yaml.helm-values",
		},
		pattern = {
			[".*%.gitlab%-ci%.ya?ml"] = "yaml.gitlab",
		},
	})
end)

-- MCP .env を読み込む（stdpath('config')/mcphub/.env）
local function load_env_file(path)
	local file = io.open(path, "r")
	if not file then
		return
	end
	for line in file:lines() do
		if not line:match("^%s*#") and line:match("%S") then
			local key, val = line:match("^%s*([A-Za-z_][A-Za-z0-9_]*)%s*=%s*(.*)%s*$")
			if key and val then
				-- 囲み引用符を除去
				val = val:gsub('^"(.*)"$', "%1")
				val = val:gsub("^'(.*)'$", "%1")
				vim.env[key] = val
			end
		end
	end
	file:close()
end
local mcphub_dir = vim.fn.stdpath("config") .. "/mcphub"
pcall(load_env_file, mcphub_dir .. "/.env")
if not vim.env.MCP_SERVERS_PATH or #vim.env.MCP_SERVERS_PATH == 0 then
	vim.env.MCP_SERVERS_PATH = mcphub_dir .. "/servers.json"
end

-- Terraform Cloud token aliases for Docker pass-through
if vim.env.TERRAFORM_CLOUD_TOKEN and (#vim.env.TERRAFORM_CLOUD_TOKEN > 0) then
	if not vim.env.TFE_TOKEN or #vim.env.TFE_TOKEN == 0 then
		vim.env.TFE_TOKEN = vim.env.TERRAFORM_CLOUD_TOKEN
	end
	if not vim.env.TF_TOKEN_app_terraform_io or #vim.env.TF_TOKEN_app_terraform_io == 0 then
		vim.env.TF_TOKEN_app_terraform_io = vim.env.TERRAFORM_CLOUD_TOKEN
	end
end

-- macOS: Homebrew のパスを Neovim 起動時に補強（Glow/markdown-preview などのCLI検出安定化）
pcall(function()
	if (vim.loop.os_uname().sysname or ""):match("Darwin") then
		local brew_paths = { "/opt/homebrew/bin", "/usr/local/bin" }
		local path = vim.env.PATH or ""
		local new = {}
		for _, p in ipairs(brew_paths) do
			if not path:find(p, 1, true) and vim.loop.fs_stat(p) then
				table.insert(new, p)
			end
		end
		if #new > 0 then
			vim.env.PATH = table.concat(new, ":") .. ":" .. path
		end
	end
end)

-- 便利: .env の再読み込みコマンドと MCP 設定ファイルへジャンプ
pcall(function()
	vim.api.nvim_create_user_command("McpEnvReload", function()
		pcall(load_env_file, mcphub_dir .. "/.env")
		vim.notify("MCP .env reloaded", vim.log.levels.INFO)
	end, {})
	vim.keymap.set("n", "<leader>ar", ":McpEnvReload<CR>", { desc = "AI/MCP: Reload .env" })
	vim.keymap.set("n", "<leader>as", function()
		vim.cmd("edit " .. (mcphub_dir .. "/servers.json"))
	end, { desc = "AI/MCP: Open servers.json" })
end)

-- Escで検索ハイライトを消す
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR><Esc>", { desc = "Clear search highlight" })

-- Git UI トグルを直結（lazyや他プラグインに依存しない内蔵terminal版）
do
	local git = require("config.git")
	vim.keymap.set("n", "<leader>gg", git.toggle_lazygit, { desc = "Git: Lazygit (tab toggle)" })
	vim.api.nvim_create_user_command("Lazygit", git.toggle_lazygit, { desc = "Lazygit (tab toggle)" })
end

-- lazy.nvim 設定をモジュール化
require("config.lazy")

-- 応急: 内蔵ターミナルでの Lazygit（toggleterm 不在時の代替）
vim.keymap.set("n", "<leader>gG", function()
	local cmd = "lazygit"
	if vim.fn.executable("lazygit") ~= 1 then
		cmd =
			[[bash -lc 'git status; echo; echo "Install lazygit with: brew install lazygit"; read -n1 -p "press any key to close..."']]
	end
	vim.cmd("tabnew")
	vim.fn.termopen(cmd)
	vim.cmd("startinsert")
end, { desc = "Git: Lazygit (builtin term)" })
-- コメント（Ctrl-/ は端末では届かない場合があるので WezTerm 側で送出を推奨）
pcall(function()
	local api = require("Comment.api")
	vim.keymap.set("n", "<C-/>", api.toggle.linewise.current, { desc = "Toggle comment" })
	vim.keymap.set("v", "<C-/>", function()
		api.toggle.linewise(vim.fn.visualmode())
	end, { desc = "Toggle comment" })
end)

-- Tokyonight スタイル切替（night/storm/moon）
-- Tokyonight: スタイル/透明度/イタリックのトグル
local tn_state = { style = "night", transparent = true, italic = { comments = true, keywords = false } }

local function apply_tokyonight(opts)
	local ok, tn = pcall(require, "tokyonight")
	if not ok then
		return
	end
	tn.setup(opts)
	vim.cmd.colorscheme("tokyonight")
end

local function set_tokyonight_style(style)
	tn_state.style = style
	apply_tokyonight({
		style = tn_state.style,
		transparent = tn_state.transparent,
		terminal_colors = true,
		styles = {
			comments = { italic = tn_state.italic.comments },
			keywords = { italic = tn_state.italic.keywords },
			functions = { bold = true },
			variables = {},
			sidebars = "dark",
			floats = "dark",
		},
		lualine_bold = true,
	})
	pcall(vim.notify, "Tokyonight style: " .. style, vim.log.levels.INFO)
end

local function toggle_tokyonight_transparent()
	tn_state.transparent = not tn_state.transparent
	set_tokyonight_style(tn_state.style)
	pcall(vim.notify, "Tokyonight transparent: " .. tostring(tn_state.transparent), vim.log.levels.INFO)
end

local function toggle_tokyonight_italics()
	tn_state.italic.comments = not tn_state.italic.comments
	tn_state.italic.keywords = not tn_state.italic.keywords
	set_tokyonight_style(tn_state.style)
	pcall(
		vim.notify,
		string.format("Tokyonight italics (comments/keywords): %s", tn_state.italic.comments and "on" or "off"),
		vim.log.levels.INFO
	)
end

vim.api.nvim_create_user_command("TokyonightNight", function()
	set_tokyonight_style("night")
end, {})
vim.api.nvim_create_user_command("TokyonightStorm", function()
	set_tokyonight_style("storm")
end, {})
vim.api.nvim_create_user_command("TokyonightMoon", function()
	set_tokyonight_style("moon")
end, {})
vim.api.nvim_create_user_command("Cobalt2Enable", function()
	vim.cmd.colorscheme("cobalt2")
	pcall(vim.notify, "Cobalt2 enabled", vim.log.levels.INFO)
end, {})
vim.api.nvim_create_user_command("TokyonightTransparentToggle", function()
	toggle_tokyonight_transparent()
end, {})
vim.api.nvim_create_user_command("TokyonightItalicsToggle", function()
	toggle_tokyonight_italics()
end, {})

vim.keymap.set("n", "<leader>un", function()
	set_tokyonight_style("night")
end, { desc = "Theme: Tokyonight Night" })
vim.keymap.set("n", "<leader>us", function()
	set_tokyonight_style("storm")
end, { desc = "Theme: Tokyonight Storm" })
vim.keymap.set("n", "<leader>um", function()
	set_tokyonight_style("moon")
end, { desc = "Theme: Tokyonight Moon" })
vim.keymap.set("n", "<leader>uc", function()
	vim.cmd.colorscheme("cobalt2")
end, { desc = "Theme: Cobalt2" })
vim.keymap.set("n", "<leader>ut", function()
	toggle_tokyonight_transparent()
end, { desc = "Theme: Transparent toggle" })
vim.keymap.set("n", "<leader>ui", function()
	toggle_tokyonight_italics()
end, { desc = "Theme: Italics toggle" })

-- Markdown プレビュー系ショートカット
vim.keymap.set("n", "<leader>mg", ":Glow<CR>", { desc = "Markdown: Glow preview" })
vim.keymap.set("n", "<leader>mp", ":MarkdownPreviewToggle<CR>", { desc = "Markdown: Preview toggle" })

-- GUI クライアント（neovide）使用時: フォント/透過/ぼかしを WezTerm に近づける
pcall(function()
	if vim.g.neovide then
		vim.o.guifont = "HackGen:h14"
		vim.g.neovide_transparency = 0.65
		vim.g.neovide_floating_blur_amount_x = 10
		vim.g.neovide_floating_blur_amount_y = 10
	end
end)

do
	local ok_cmp, cmp = pcall(require, "cmp")
	if ok_cmp then
		local ok_lspkind, lspkind = pcall(require, "lspkind")
		if ok_lspkind then
			-- VSCode風のアイコンを付与
			lspkind.init({ mode = "symbol_text", preset = "default" })
		end
		cmp.setup({
			snippet = {
				expand = function(args)
					pcall(function()
						require("luasnip").lsp_expand(args.body)
					end)
				end,
			},
			mapping = cmp.mapping.preset.insert({
				["<CR>"] = cmp.mapping.confirm({ select = false }),
				["<C-Space>"] = cmp.mapping.complete(),
				["<Tab>"] = cmp.mapping.select_next_item(),
				["<S-Tab>"] = cmp.mapping.select_prev_item(),
			}),
			sources = {
				{ name = "nvim_lsp" },
				{ name = "nvim_lsp_signature_help" },
				{ name = "path" },
				{ name = "buffer" },
			},
			formatting = ok_lspkind and {
				format = lspkind.cmp_format({
					mode = "symbol_text",
					menu = {
						nvim_lsp = "[LSP]",
						nvim_lsp_signature_help = "[Sig]",
						buffer = "[Buf]",
						path = "[Path]",
						luasnip = "[Snip]",
					},
					maxwidth = 50,
					ellipsis_char = "…",
				}),
			} or nil,
			preselect = cmp.PreselectMode.None,
			completion = { completeopt = "menu,menuone,noinsert" },
		})
		-- autopairs（括弧補完）と cmp の連携
		local ok_pairs, npairs = pcall(require, "nvim-autopairs")
		if ok_pairs then
			npairs.setup({})
			local ok_cap, cmp_autopairs = pcall(require, "nvim-autopairs.completion.cmp")
			if ok_cap then
				cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
			end
		end
	end
end

do
	local ok_pairs, npairs = pcall(require, "nvim-autopairs")
	if ok_pairs then
		npairs.setup({})
		local ok_cmp, cmp = pcall(require, "cmp")
		local ok_cap, cmp_autopairs = pcall(require, "nvim-autopairs.completion.cmp")
		if ok_cmp and ok_cap then
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end
	end
end

-- LSP設定（存在しない場合は静かにスキップ）
local ok_lspconfig, lspconfig = pcall(require, "lspconfig")
local ok_cnl, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
local capabilities = ok_cnl and cmp_nvim_lsp.default_capabilities() or {}
local on_attach = function(_, bufnr)
	local map = function(mode, lhs, rhs, desc)
		vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
	end
	map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
	map("n", "gr", vim.lsp.buf.references, "References")
	map("n", "K", vim.lsp.buf.hover, "Hover")
	map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
	map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
	map("n", "[d", vim.diagnostic.goto_prev, "Prev Diagnostic")
	map("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")
	map("n", "<leader>e", function()
		vim.diagnostic.open_float(0, { scope = "line", focus = true })
	end, "Line Diagnostics (line scope)")
end

-- 明示的に neodev を初期化（lua_ls 設定前に実行）
pcall(function()
	require("neodev").setup({ library = { types = true } })
end)

local ok_mlsp, mlsp = pcall(require, "mason-lspconfig")
if ok_mlsp then
	mlsp.setup({
		ensure_installed = {
			"terraformls",
			"yamlls",
			"jsonls",
			"dockerls",
			"bashls",
			"lua_ls",
			"helm_ls",
			"marksman",
		},
	})

	-- Mason のインストール先を自動的に使う共通ハンドラ（古いバージョンでも動くようフォールバック）
	local function setup_server(server)
		local opts = { capabilities = capabilities, on_attach = on_attach }
		if server == "yamlls" then
			local ok_ss, schemastore = pcall(require, "schemastore")
			local schemas = ok_ss and schemastore.yaml.schemas() or {}
			-- Add local schema mapping for Hugo config to silence YAML LS noise
			local cwd = vim.loop.cwd() or vim.fn.getcwd()
			local schema_path = (vim.fs and vim.fs.joinpath or function(...)
				return table.concat({ ... }, "/")
			end)(cwd, "schemas", "hugoblox.schema.json")
			if type(cwd) == "string" and vim.loop.fs_stat(schema_path) then
				table.insert(schemas, {
					fileMatch = {
						"config/_default/hugo.yaml",
					},
					url = ("file://%s"):format(schema_path),
				})
			end
			opts.settings = {
				yaml = {
					keyOrdering = false,
					validate = true,
					format = { enable = true },
					kubernetes = true,
					schemaStore = { enable = false, url = "" },
					schemas = schemas,
				},
			}
		elseif server == "jsonls" then
			local ok_ss, schemastore = pcall(require, "schemastore")
			opts.settings = {
				json = {
					validate = { enable = true },
					schemas = ok_ss and schemastore.json.schemas() or {},
				},
			}
		elseif server == "lua_ls" then
			-- neodev による型情報を前提にしつつ、明示的に設定を補強
			local runtime_files = vim.api.nvim_get_runtime_file("", true)
			opts.settings = {
				Lua = {
					runtime = { version = "LuaJIT" },
					diagnostics = {
						globals = { "vim" },
						-- 必要なら undefined-global を抑制: disable = { "undefined-global" },
					},
					workspace = {
						checkThirdParty = false,
						library = runtime_files,
					},
					completion = { callSnippet = "Replace" },
					hint = { enable = true },
					telemetry = { enable = false },
				},
			}
		end
		local cfg = rawget(lspconfig, server)
		if cfg and type(cfg.setup) == "function" then
			cfg.setup(opts)
		else
			-- Unknown name (e.g. non-LSP tool accidentally listed). Silently skip.
			return
		end
	end

	if ok_mlsp and type(mlsp.setup_handlers) == "function" then
		mlsp.setup_handlers({
			function(server)
				setup_server(server)
			end,
		})
	elseif ok_mlsp then
		for _, server in ipairs(mlsp.get_installed_servers()) do
			setup_server(server)
		end
	end

	-- close: if ok_mlsp then
end

-- Format on Save（VSCode: editor.formatOnSave = true 相当）
do
	local ok_conform, conform = pcall(require, "conform")
	if ok_conform then
		conform.setup({
			format_on_save = {
				lsp_fallback = true,
				timeout_ms = 2000,
			},
			formatters_by_ft = {
				lua = { "stylua" },
				terraform = { "terraform_fmt" },
				hcl = { "terraform_fmt" },
				yaml = { "yamlfmt", "prettierd", "prettier" },
				json = { "prettierd", "prettier" },
				jsonc = { "prettierd", "prettier" },
				-- Markdown は textlint --fix を優先し、その後 Prettier 系で整形
				markdown = { "textlint", "prettierd", "prettier" },
				sh = { "shfmt" },
			},
		})

		vim.keymap.set({ "n", "v" }, "<leader>f", function()
			local ok, conform = pcall(require, "conform")
			if ok then
				conform.format({ async = true, lsp_fallback = true })
			end
		end, { desc = "Format" })
	end
end

do
	local ok_lint, lint = pcall(require, "lint")
	if ok_lint then
		lint.linters_by_ft = lint.linters_by_ft or {}
		lint.linters_by_ft.markdown = { "textlint", "markdownlint" }
		lint.linters_by_ft.yaml = { "yamllint" }
		local lint_grp = vim.api.nvim_create_augroup("NvimLintOnSave", { clear = true })
		vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
			group = lint_grp,
			callback = function()
				local ft = vim.bo.filetype
				local names = lint.linters_by_ft[ft]
				if not names then
					return
				end
				local runnable = {}
				for _, name in ipairs(names) do
					local linter = lint.linters[name]
					if linter then
						local cmd = type(linter.cmd) == "function" and linter.cmd() or linter.cmd
						local exe = type(cmd) == "table" and cmd[1] or cmd
						if vim.fn.executable(exe) == 1 then
							table.insert(runnable, name)
						end
					end
				end
				if #runnable > 0 then
					lint.try_lint(runnable)
				end
			end,
		})
	end
end

-- 便利: 保存時に末尾空白削除（VSCode設定に準拠）
local trim_group = vim.api.nvim_create_augroup("TrimWhitespaceOnSave", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
	group = trim_group,
	pattern = "*",
	callback = function()
		-- Markdown のハード改行（行末2スペース）は保持
		if vim.bo.filetype == "markdown" or vim.bo.filetype == "mdx" then
			return
		end
		vim.cmd([[%s/\s\+$//e]])
	end,
})

-- Lua/設定系ではスペルチェックを自動無効化
local spell_group = vim.api.nvim_create_augroup("SpellPolicy", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	group = spell_group,
	pattern = { "lua", "vim", "vimdoc" },
	callback = function()
		vim.opt_local.spell = false
	end,
})

-- 診断の下線スタイルはカラースキーム（例: Tokyonight の undercurl）に委譲
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	group = spell_group,
	callback = function(args)
		local cfg = vim.fs.normalize(vim.fn.stdpath("config"))
		local file = vim.fs.normalize(vim.api.nvim_buf_get_name(args.buf))
		if file:find(cfg, 1, true) == 1 then
			vim.opt_local.spell = false
		end
	end,
})

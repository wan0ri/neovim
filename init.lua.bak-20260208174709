-- VSCode風 Neovim スターター（インフラ領域向け）
-- 配置先の想定: ~/.config/nvim/init.lua

vim.g.mapleader = " "
vim.g.maplocalleader = " "

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
-- Telescope VSCode風キーマップ
local tb = require("telescope.builtin")
vim.keymap.set("n", "<C-p>", tb.find_files, { desc = "Quick Open (files)" })
vim.keymap.set("n", "<leader>fa", function()
	tb.find_files({ no_ignore = true, hidden = true })
end, { desc = "Find files (ALL: hidden & gitignored)" })
vim.keymap.set("n", "<leader>ff", tb.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", tb.live_grep, { desc = "Search in files" })
vim.keymap.set("n", "<leader>fb", tb.buffers, { desc = "Find buffers" })
vim.keymap.set("n", "<leader>sp", tb.commands, { desc = "Command Palette" })

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
		vim.o.guifont = "MesloLGS NF:h14"
		vim.g.neovide_transparency = 0.65
		vim.g.neovide_floating_blur_amount_x = 10
		vim.g.neovide_floating_blur_amount_y = 10
	end
end)

local cmp = require("cmp")
local lspkind = require("lspkind")
-- VSCode風のアイコンを付与
lspkind.init({
	mode = "symbol_text",
	preset = "default",
})

cmp.setup({
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
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
	formatting = {
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
	},
	preselect = cmp.PreselectMode.None,
	completion = { completeopt = "menu,menuone,noinsert" },
})

-- autopairs（括弧補完）と cmp の連携
local ok_pairs, npairs = pcall(require, "nvim-autopairs")
if ok_pairs then
	npairs.setup({})
	local cmp_autopairs = require("nvim-autopairs.completion.cmp")
	cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
end

-- LSP設定
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()
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
	map("n", "<leader>e", vim.diagnostic.open_float, "Line Diagnostics")
end

-- 明示的に neodev を初期化（lua_ls 設定前に実行）
pcall(function()
	require("neodev").setup({ library = { types = true } })
end)

local mlsp = require("mason-lspconfig")
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
		opts.settings = {
			yaml = {
				keyOrdering = false,
				validate = true,
				format = { enable = true },
				kubernetes = true,
				schemaStore = { enable = false, url = "" },
				schemas = require("schemastore").yaml.schemas(),
			},
		}
	elseif server == "jsonls" then
		opts.settings = {
			json = {
				validate = { enable = true },
				schemas = require("schemastore").json.schemas(),
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

if type(mlsp.setup_handlers) == "function" then
	mlsp.setup_handlers({
		function(server)
			setup_server(server)
		end,
	})
else
	for _, server in ipairs(mlsp.get_installed_servers()) do
		setup_server(server)
	end
end

-- Format on Save（VSCode: editor.formatOnSave = true 相当）
require("conform").setup({
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
	require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format" })

-- Lint（markdownlint 等）
local lint = require("lint")
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

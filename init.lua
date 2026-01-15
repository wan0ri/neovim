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

-- MCP .env を読み込む（~/.config/mcphub/.env）
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
pcall(load_env_file, vim.fn.expand("~/.config/mcphub/.env"))

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
		pcall(load_env_file, vim.fn.expand("~/.config/mcphub/.env"))
		vim.notify("MCP .env reloaded", vim.log.levels.INFO)
	end, {})
	vim.keymap.set("n", "<leader>ar", ":McpEnvReload<CR>", { desc = "AI/MCP: Reload .env" })
	vim.keymap.set("n", "<leader>as", function()
		vim.cmd("edit ~/.config/mcphub/servers.json")
	end, { desc = "AI/MCP: Open servers.json" })
end)

-- Escで検索ハイライトを消す
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR><Esc>", { desc = "Clear search highlight" })

-- lazy.nvim bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    -- テーマ（Tokyonight を既定適用。VSCode/cobalt2 は切替用）
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        opts = {
            style = "night",
            transparent = false, -- 既定は不透明（必要時はトグルで透過）
            terminal_colors = true,
            styles = {
                comments = { italic = true },
                keywords = { italic = false },
                functions = { bold = true },
                variables = {},
                sidebars = "dark",
                floats = "dark",
            },
            lualine_bold = true,
        },
        config = function(_, opts)
            require("tokyonight").setup(opts)
            vim.cmd.colorscheme("tokyonight")
        end,
    },
    -- 背景透過をプラグインで管理（トグル/除外が容易）
    {
        "xiyaowong/nvim-transparent",
        config = function()
            require("transparent").setup({
                enable = false, -- 既定はOFF（必要時に <leader>uT でON）
                extra_groups = {
                    "NormalFloat", "FloatBorder", "Pmenu", "PmenuSel",
                    "TelescopeNormal", "TelescopeBorder", "TelescopePromptNormal",
                    "TelescopeResultsNormal", "TelescopePromptBorder", "TelescopeResultsBorder",
                    "NeoTreeNormal", "NeoTreeNormalNC", "WhichKeyFloat", "WhichKeyBorder",
                    "MsgArea", "SignColumn",
                },
                exclude = {},
            })
            vim.keymap.set("n", "<leader>uT", ":TransparentToggle<CR>", { desc = "UI: Transparent toggle" })
        end,
    },
    {
        "Mofiqul/vscode.nvim",
        config = function()
            require("vscode").setup({ transparent = false })
            -- vim.cmd.colorscheme("vscode") -- 必要時に手動で切替
        end,
    },
    -- Cobalt2 テーマ（切替用。既定では適用しない）
    { "rktjmp/lush.nvim" },
    { "tjdevries/colorbuddy.nvim" },
    {
        "lalitmee/cobalt2.nvim",
        lazy = false,
        priority = 999,
        config = function()
            -- cobalt2 を選んだ時だけ追加調整を適用
            local function apply_cobalt2_extras()
                local set = vim.api.nvim_set_hl
                local colors = {
                    cyan = "#9EFFFF",
                    yellow = "#FFC600",
                    orange = "#FF9D00",
                    green = "#A5FF90",
                    pink = "#FF6C99",
                    blue = "#22C7FF",
                    fg = "#E1EFFF",
                }
                set(0, "@string", { fg = colors.green })
                set(0, "@number", { fg = colors.orange })
                set(0, "@boolean", { fg = colors.orange })
                set(0, "@constant", { fg = colors.pink })
                set(0, "@keyword", { fg = colors.blue, italic = true })
                set(0, "@type", { fg = colors.cyan })
                set(0, "@type.builtin", { fg = colors.cyan, italic = true })
                set(0, "@function", { fg = colors.cyan, bold = true })
                set(0, "@method", { fg = colors.cyan })
                set(0, "@property", { fg = colors.yellow })
                set(0, "@field", { fg = colors.yellow })
                set(0, "@label", { fg = colors.yellow })
                set(0, "@variable", { fg = colors.fg })
                -- Terraform/HCL 強化（ある場合のみ適用）
                pcall(set, 0, "@attribute.hcl", { fg = colors.yellow })
                pcall(set, 0, "@property.hcl", { fg = colors.yellow })
                pcall(set, 0, "@type.terraform", { fg = colors.cyan })
                pcall(set, 0, "@property.terraform", { fg = colors.yellow })
            end

            -- 既定で cobalt2 を強制適用しない。
            -- cobalt2 を選択した時だけ上記調整をかける。
            if vim.g.colors_name == "cobalt2" then
                apply_cobalt2_extras()
            end
            vim.api.nvim_create_autocmd("ColorScheme", {
                pattern = "cobalt2",
                callback = apply_cobalt2_extras,
            })
        end,
    },

    -- Neovim Lua 開発補助（lua_ls に Neovim API 型情報を付与）
    {
        "folke/neodev.nvim",
        lazy = false,
        priority = 900,
        opts = {
            library = { types = true }, -- vim.*, luv.* の型情報
        },
    },

	-- Treesitter（基本の構文強調）
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				highlight = { enable = true, additional_vim_regex_highlighting = { "terraform", "hcl", "yaml" } },
				ensure_installed = {
					"lua",
					"vim",
					"vimdoc",
					"yaml",
					"json",
					"bash",
					"dockerfile",
					"hcl",
					"terraform",
				},
			})
		end,
	},

	-- カーソル周辺のコンテキスト（関数/ブロック名）をステッキーヘッダとして表示
	{
		"nvim-treesitter/nvim-treesitter-context",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("treesitter-context").setup({
				enable = true,
				max_lines = 3,
				multiline_threshold = 5,
				trim_scope = "outer",
				mode = "cursor",
				separator = "─", -- Cobalt2 に馴染む薄めのライン
			})

			-- 不要なバッファでは無効化
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "dashboard", "neo-tree", "help", "lazy", "mason", "gitcommit", "toggleterm" },
				callback = function()
					pcall(require("treesitter-context").disable)
				end,
			})

			-- 色味（背景はテーマに合わせる。境界線だけシアン）
			pcall(vim.api.nvim_set_hl, 0, "TreesitterContext", { default = true })
			pcall(vim.api.nvim_set_hl, 0, "TreesitterContextLineNumber", { default = true })
			pcall(vim.api.nvim_set_hl, 0, "TreesitterContextSeparator", { fg = "#22C7FF" })

			-- トグル/ジャンプ
			vim.keymap.set("n", "<leader>ct", ":TSContextToggle<CR>", { desc = "Context: toggle" })
			vim.keymap.set("n", "[c", function()
				pcall(require("treesitter-context").go_to_context)
			end, { desc = "Context: jump up" })
		end,
	},

	-- ウィンバー上にパンくず（関数/クラス/ファイル階層）を表示
	{
		"Bekaboo/dropbar.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("dropbar").setup({})

			-- パンくずから要素選択
			vim.keymap.set("n", "<leader>db", function()
				pcall(require("dropbar.api").pick)
			end, { desc = "Dropbar: pick" })

			-- 特定のバッファでは winbar を消す
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "dashboard", "neo-tree", "help", "lazy", "mason", "gitcommit", "toggleterm" },
				callback = function()
					vim.opt_local.winbar = nil
				end,
			})
		end,
	},

	-- VSCode風の下パネル・ターミナル
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		event = "VeryLazy",
		opts = {
			-- 画面下に30%の高さで表示（縦/横でサイズを出し分け）
			size = function(term)
				if term.direction == "horizontal" then
					return math.floor(vim.o.lines * 0.30)
				elseif term.direction == "vertical" then
					return math.floor(vim.o.columns * 0.40)
				end
				return 20
			end,
			open_mapping = [[<leader>`]], -- VSCode風トグル（Leader+`）
			direction = "horizontal",
			shade_terminals = true,
			start_in_insert = true,
			persist_mode = false,
			close_on_exit = true,
		},
        config = function(_, opts)
            -- ハイライトはテーマ（Tokyonight）の FloatBorder/NormalFloat に完全委譲
            require("toggleterm").setup(opts)

			-- Lazygit 連携（Git ルートで開くフロート端末）
			local Terminal = require("toggleterm.terminal").Terminal
			local has_lazygit = (vim.fn.executable("lazygit") == 1)
			local lazygit
			if has_lazygit then
				lazygit = Terminal:new({
					cmd = "lazygit",
					dir = "git_dir",
					direction = "float",
					hidden = true,
					float_opts = { border = "rounded" },
					on_open = function()
						vim.cmd("startinsert!")
					end,
				})
				function _LAZYGIT_TOGGLE()
					lazygit:toggle()
				end
			else
				function _LAZYGIT_TOGGLE()
					local ok = pcall(require, "neogit")
					if ok then
						require("neogit").open()
					else
						-- 最終フォールバック: フロート端末で git status
						local fallback = Terminal:new({
							cmd = 'bash -lc \'git status; echo; echo "Install lazygit with: brew install lazygit"; read -n1 -p "press any key to close..."\'',
							dir = "git_dir",
							direction = "float",
							hidden = true,
							float_opts = { border = "rounded" },
						})
						fallback:toggle()
					end
					vim.notify(
						"lazygit が見つかりません。brew install lazygit の実行を推奨します。",
						vim.log.levels.WARN
					)
				end
			end

			-- Codex CLI（MCP クライアント）をフロートで開く
			local codex = Terminal:new({
				cmd = "codex",
				dir = vim.loop.cwd(),
				direction = "float",
				hidden = true,
				float_opts = { border = "rounded" },
				on_open = function()
					vim.cmd("startinsert!")
				end,
			})
			function _CODEX_TOGGLE()
				codex:toggle()
			end

			-- 追加トグルキー
			vim.keymap.set("n", "<leader>tt", ":ToggleTerm<CR>", { desc = "Terminal: toggle (bottom)" })
			vim.keymap.set("n", "<leader>tv", ":ToggleTerm direction=vertical<CR>", { desc = "Terminal: vertical" })
			vim.keymap.set("n", "<leader>tf", ":ToggleTerm direction=float<CR>", { desc = "Terminal: float" })
			vim.keymap.set("n", "<leader>gg", "<cmd>lua _LAZYGIT_TOGGLE()<CR>", { desc = "Git: Lazygit toggle" })
			vim.keymap.set("n", "<leader>ac", "<cmd>lua _CODEX_TOGGLE()<CR>", { desc = "AI/MCP: Codex TUI" })

			-- ターミナル内からノーマルへ戻る
			vim.api.nvim_create_autocmd("TermOpen", {
				pattern = "*",
				callback = function()
					vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { buffer = 0 })
					vim.keymap.set("t", "jk", [[<C-\><C-n>]], { buffer = 0 })
					vim.opt_local.number = false
					vim.opt_local.relativenumber = false
					vim.opt_local.signcolumn = "no"
				end,
			})
		end,
	},

	-- j/k 長押し時に加速度的にスクロール
	{
		"rainbowhxch/accelerated-jk.nvim",
		event = "VeryLazy",
		config = function()
			require("accelerated-jk").setup({
				mode = "time_driven",
				enable_deceleration = true,
				acceleration_motions = { "h", "j", "k", "l" },
			})
			vim.keymap.set("n", "j", "<Plug>(accelerated_jk_j)")
			vim.keymap.set("n", "k", "<Plug>(accelerated_jk_k)")
			-- 折り返し移動を使う場合は下記に切替
			-- vim.keymap.set("n", "j", "<Plug>(accelerated_jk_gj)")
			-- vim.keymap.set("n", "k", "<Plug>(accelerated_jk_gk)")
		end,
	},

	-- ファイル検索/コマンドパレット
	{ "nvim-lua/plenary.nvim" },
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
	},
	{
		"nvim-telescope/telescope-fzf-native.nvim",
		build = "make",
		cond = function()
			return vim.fn.executable("make") == 1
		end,
		config = function()
			pcall(require("telescope").load_extension, "fzf")
		end,
	},

	-- エクスプローラ（VSCode Explorer相当）
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		config = function()
			require("neo-tree").setup({
				filesystem = {
					follow_current_file = { enabled = true },
					use_libuv_file_watcher = true,
					filtered_items = {
						visible = true, -- 隠し/無視ファイルを一覧に表示（薄く表示）
						show_hidden_count = true,
						hide_dotfiles = false, -- ドットファイルも表示
						hide_gitignored = false, -- .gitignore で無視されたファイルも表示
						never_show = { ".DS_Store" },
					},
				},
			})
			vim.keymap.set("n", "<C-b>", "<cmd>Neotree toggle<cr>")
			-- フォーカス移動系（閉じずに行き来）
			vim.keymap.set("n", "<leader>e", ":Neotree focus<CR>", { desc = "Explorer focus" })
			vim.keymap.set("n", "<leader>er", ":Neotree reveal<CR>", { desc = "Explorer reveal current" })
		end,
	},

    -- ステータスライン（診断/Git/情報を出し分け）
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            local function hl_fg(name)
                local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
                if ok and hl and hl.fg then
                    return string.format("#%06x", hl.fg)
                end
                return nil
            end
            local added = hl_fg("GitSignsAdd") or hl_fg("DiffAdd")
            local modified = hl_fg("GitSignsChange") or hl_fg("DiffChange")
            local removed = hl_fg("GitSignsDelete") or hl_fg("DiffDelete")
            require("lualine").setup({
                options = {
                    theme = "auto", -- 現在のカラースキームに追従
                    globalstatus = true,
                    component_separators = { left = "│", right = "│" },
                    section_separators = { left = "", right = "" },
                    disabled_filetypes = { statusline = { "dashboard", "neo-tree" } },
                },
                sections = {
                    lualine_a = { { "mode", icon = "" } },
                    lualine_b = {
                        { "branch", icon = "" },
                        {
                            "diff",
                            symbols = { added = " ", modified = " ", removed = " " },
                            colored = true,
                            -- 現在のハイライトから色を取得（なければテーマに委譲）
                            diff_color = (added or modified or removed) and {
                                added = added and { fg = added } or nil,
                                modified = modified and { fg = modified } or nil,
                                removed = removed and { fg = removed } or nil,
                            } or nil,
                        },
                    },
                    lualine_c = {
                        { "filename", path = 1, symbols = { modified = " [+]", readonly = " " } },
                    },
                    lualine_x = {
                        {
                            "diagnostics",
                            sources = { "nvim_diagnostic" },
                            sections = { "error", "warn", "info", "hint" },
                            symbols = { error = " ", warn = " ", info = " ", hint = " " },
                            colored = true,
                            update_in_insert = false,
                        },
                        { "encoding", cond = function() return vim.o.fileencoding ~= "utf-8" end },
                        { "fileformat" },
                        { "filetype" },
                    },
                    lualine_y = { { "progress" } },
                    lualine_z = { { "location" } },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { { "filename", path = 1 } },
                    lualine_x = { "location" },
                    lualine_y = {},
                    lualine_z = {},
                },
            })
        end,
    },

	-- Git 連携
	{ "lewis6991/gitsigns.nvim", config = true },
	-- Git UI/履歴（Git Graph 代替）
	{ "NeogitOrg/neogit", dependencies = { "nvim-lua/plenary.nvim" } },
	{ "sindrets/diffview.nvim" },
	{ "tpope/vim-fugitive" },

	-- コメントトグル（gc/gcc）
	{ "numToStr/Comment.nvim", config = true },

	-- which-key（キーチートシート）
	{
		"folke/which-key.nvim",
        config = function()
            local wk = require("which-key")
            wk.setup({})
            wk.add({
                { "<leader>u", group = "UI/Theme" },
				{ "<leader>un", desc = "Tokyonight: Night" },
				{ "<leader>us", desc = "Tokyonight: Storm" },
				{ "<leader>um", desc = "Tokyonight: Moon" },
				{ "<leader>uc", desc = "Cobalt2" },
				{ "<leader>ut", desc = "Tokyonight: Transparent toggle" },
				{ "<leader>ui", desc = "Tokyonight: Italics toggle" },
				{ "<leader>uT", desc = "Transparent: Toggle" },
				{ "<leader>a", group = "AI/MCP" },
				{ "<leader>ac", desc = "Codex TUI" },
				{ "<leader>as", desc = "Open servers.json" },
				{ "<leader>ar", desc = "Reload MCP .env" },
				{ "<leader>f", group = "検索/ファイル" },
				{ "<leader>ff", desc = "ファイルを開く" },
				{ "<leader>fa", desc = "全ファイル（隠し/無視含む）" },
				{ "<leader>fg", desc = "全文検索（ripgrep）" },
				{ "<leader>fb", desc = "バッファ一覧" },
				{ "<leader>sp", desc = "コマンドパレット" },

				{ "<leader>t", group = "ターミナル" },
				{ "<leader>tt", desc = "下パネル切替" },
				{ "<leader>tv", desc = "右パネル切替" },
				{ "<leader>tf", desc = "フロート切替" },

				{ "<leader>d", group = "ダッシュボード/パンくず/文脈" },
				{ "<leader>dd", desc = "ダッシュボードを開く" },
				{ "<leader>db", desc = "Dropbar メニュー" },
				{ "<leader>ct", desc = "Treesitter Context 切替" },

				{ "<leader>g", group = "Git" },
				{ "<leader>gg", desc = "Lazygit 切替" },

				{ "<leader>c", group = "Copilot" },
				{ "<leader>co", desc = "CopilotChat 開く" },
				{ "<leader>cc", desc = "CopilotChat プロンプト" },
                { "<leader>cq", desc = "CopilotChat 閉じる" },

                { "<leader>f", desc = "フォーマット" },
                { "<leader>m", group = "Markdown" },
                { "<leader>mg", desc = "Glow プレビュー" },
                { "<leader>mp", desc = "MarkdownPreview トグル" },
            })
        end,
    },

	-- インデントガイド（indent-rainbow代替）
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {
			indent = { char = "│" },
			scope = { enabled = true },
			exclude = {
				filetypes = {
					"dashboard",
					"neo-tree",
					"help",
					"lazy",
					"mason",
					"TelescopePrompt",
					"TelescopeResults",
					"gitcommit",
				},
				buftypes = { "terminal", "nofile", "prompt" },
			},
		},
	},

	-- カーリーブレース/コードブロックのチャンクを可視化
	{
		"shellRaining/hlchunk.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local function hl_fg(name)
				local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
				if ok and hl and hl.fg then
					return string.format("#%06x", hl.fg)
				end
				return nil
			end
			local function hlchunk_colors()
				-- 現在のテーマの代表色を参照
				local normal = hl_fg("Function") or hl_fg("Type") or "#7dcfff"
				local error = hl_fg("DiagnosticError") or hl_fg("Error") or "#bb9af7"
				return { normal = normal, error = error }
			end

			require("hlchunk").setup({
				chunk = {
					enable = true,
					use_treesitter = true,
					-- Tokyonight パレットに追従
					style = (function()
						local c = hlchunk_colors()
						return { { fg = c.normal }, { fg = c.error } }
					end)(),
					chars = {
						horizontal_line = "─",
						vertical_line = "│",
						left_top = "┌",
						left_bottom = "└",
						right_arrow = "─",
					},
					exclude_filetypes = {
						"dashboard",
						"neo-tree",
						"help",
						"lazy",
						"mason",
						"TelescopePrompt",
						"TelescopeResults",
						"gitcommit",
					},
				},
				indent = { enable = false }, -- indent-blankline と重複させない
				line_num = { enable = false },
				blank = { enable = false },
			})

			-- カラースキーム変更時にも追従
			vim.api.nvim_create_autocmd("ColorScheme", {
				group = vim.api.nvim_create_augroup("HlchunkTokyonightColors", { clear = true }),
				pattern = "*",
				callback = function()
					local c = hlchunk_colors()
					pcall(require("hlchunk").setup, { chunk = { style = { { fg = c.normal }, { fg = c.error } } } })
				end,
			})
		end,
	},

	-- LSP / 補完 / フォーマット
	{ "williamboman/mason.nvim", config = true },
	{ "williamboman/mason-lspconfig.nvim" },
	{ "neovim/nvim-lspconfig" },
	{ "hrsh7th/nvim-cmp" },
	{ "hrsh7th/cmp-nvim-lsp" },
	{ "hrsh7th/cmp-nvim-lsp-signature-help" },
	{ "hrsh7th/cmp-buffer" },
	{ "hrsh7th/cmp-path" },
	{ "L3MON4D3/LuaSnip" },
	{ "saadparwaiz1/cmp_luasnip" },
	{ "rafamadriz/friendly-snippets" },
	{ "onsails/lspkind.nvim" },
	{ "windwp/nvim-autopairs" },
	{ "b0o/SchemaStore.nvim" },
	{ "stevearc/conform.nvim" },
	{ "mfussenegger/nvim-lint" },

	-- スクロールバー（検索/診断/Git のマーク表示）
	{
		"petertriho/nvim-scrollbar",
		dependencies = { "lewis6991/gitsigns.nvim" },
		config = function()
			local ok, scrollbar = pcall(require, "scrollbar")
			if not ok then return end
			scrollbar.setup({
				excluded_filetypes = {
					"dashboard", "neo-tree", "help", "lazy", "mason", "TelescopePrompt", "TelescopeResults",
				},
				excluded_buftypes = { "terminal", "nofile", "prompt" },
			})
			pcall(function() require("scrollbar.handlers.search").setup() end)
			pcall(function() require("scrollbar.handlers.gitsigns").setup() end)
			pcall(function() require("scrollbar.handlers.diagnostic").setup() end)
		end,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		opts = {
			ensure_installed = {
				"prettierd",
				"prettier",
				"stylua",
				"shfmt",
				"yamlfmt",
				"yamllint",
				"markdownlint",
			},
			run_on_start = true,
			start_delay = 1500, -- ms
			integrations = { mason = true },
		},
	},

	-- インフラ特化（Terraform/Helm）
	{
		"hashivim/vim-terraform",
		config = function()
			-- 自動フォーマット有効化（terraform fmt）
			-- Conform.nvim の保存時フォーマットと二重実行を避けるため 0 に設定
			vim.g.terraform_fmt_on_save = 0
			vim.g.terraform_align = 1
		end,
	},
	{ "towolf/vim-helm" },

	-- Markdown（All in One / Table / Preview 代替）
	{ "dhruvasagar/vim-table-mode" },
	{ "ellisonleao/glow.nvim", config = true, cmd = "Glow" },
	-- マルチカーソル（VSCode風の複数選択）
	{ "mg979/vim-visual-multi" },
	{
		"iamcco/markdown-preview.nvim",
		ft = { "markdown" },
		cmd = { "MarkdownPreview", "MarkdownPreviewToggle", "MarkdownPreviewStop" },
		build = function()
			-- Node.js がある場合はビルドしてローカルに viewer を用意
			pcall(function() vim.fn["mkdp#util#install"]() end)
		end,
		init = function()
			-- 既定ブラウザで開く（デフォルト）。ローカルサーバは 127.0.0.1:xxxx
			vim.g.mkdp_open_to_the_world = 0
			vim.g.mkdp_auto_close = 0
			-- ページテーマはシステムに合わせる（light/dark 自動）
			vim.g.mkdp_theme = "auto"
		end,
	},

	-- Startup Dashboard
	{
		"nvimdev/dashboard-nvim",
		event = "VimEnter",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local db = require("dashboard")
			db.setup({
				theme = "hyper",
				config = {
					week_header = { enable = true },
					mru = { limit = 8 },
					shortcut = {
						{ desc = "Files", group = "Label", key = "f", action = "Telescope find_files" },
						{ desc = "Grep", group = "DiagnosticHint", key = "g", action = "Telescope live_grep" },
						{ desc = "NeoTree", group = "String", key = "e", action = "Neotree toggle" },
						{ desc = "Update", group = "Exception", key = "u", action = "Lazy sync" },
					},
					footer = function()
						return { "Happy hacking with Neovim." }
					end,
				},
			})
			vim.keymap.set("n", "<leader>dd", ":Dashboard<CR>", { desc = "Open dashboard" })
		end,
	},
	-- Copilot（インライン提案: copilot.vim、チャット: CopilotChat.nvim）
	-- CopilotChat は copilot.lua を利用するため、最小構成で同梱。
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		build = ":Copilot auth",
		config = function()
			require("copilot").setup({
				suggestion = { enabled = false }, -- インラインは copilot.vim を使う前提で無効
				panel = { enabled = false },
			})
		end,
	},
	{
		"github/copilot.vim",
		init = function()
			-- Tab 競合回避が必要な場合は下記を有効化
			-- vim.g.copilot_no_tab_map = true
			-- vim.keymap.set("i", "<C-]>", "copilot#Accept()", { expr = true, replace_keycodes = false, desc = "Copilot accept" })
		end,
	},
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "zbirenbaum/copilot.lua" },
		opts = {},
		keys = {
			{ "<leader>co", ":CopilotChatOpen<CR>", desc = "CopilotChat: Open" },
			{ "<leader>cc", ":CopilotChat<CR>", desc = "CopilotChat: Prompt" },
			{ "<leader>cq", ":CopilotChatClose<CR>", desc = "CopilotChat: Close" },
		},
	},
})

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
local tn_state = { style = "night", transparent = false, italic = { comments = true, keywords = false } }

local function apply_tokyonight(opts)
  local ok, tn = pcall(require, "tokyonight")
  if not ok then return end
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
  pcall(vim.notify, string.format("Tokyonight italics (comments/keywords): %s", tn_state.italic.comments and "on" or "off"), vim.log.levels.INFO)
end

vim.api.nvim_create_user_command("TokyonightNight", function() set_tokyonight_style("night") end, {})
vim.api.nvim_create_user_command("TokyonightStorm", function() set_tokyonight_style("storm") end, {})
vim.api.nvim_create_user_command("TokyonightMoon", function() set_tokyonight_style("moon") end, {})
vim.api.nvim_create_user_command("Cobalt2Enable", function()
  vim.cmd.colorscheme("cobalt2")
  pcall(vim.notify, "Cobalt2 enabled", vim.log.levels.INFO)
end, {})
vim.api.nvim_create_user_command("TokyonightTransparentToggle", function() toggle_tokyonight_transparent() end, {})
vim.api.nvim_create_user_command("TokyonightItalicsToggle", function() toggle_tokyonight_italics() end, {})

vim.keymap.set("n", "<leader>un", function() set_tokyonight_style("night") end, { desc = "Theme: Tokyonight Night" })
vim.keymap.set("n", "<leader>us", function() set_tokyonight_style("storm") end, { desc = "Theme: Tokyonight Storm" })
vim.keymap.set("n", "<leader>um", function() set_tokyonight_style("moon") end, { desc = "Theme: Tokyonight Moon" })
vim.keymap.set("n", "<leader>uc", function() vim.cmd.colorscheme("cobalt2") end, { desc = "Theme: Cobalt2" })
vim.keymap.set("n", "<leader>ut", function() toggle_tokyonight_transparent() end, { desc = "Theme: Transparent toggle" })
vim.keymap.set("n", "<leader>ui", function() toggle_tokyonight_italics() end, { desc = "Theme: Italics toggle" })

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
    lspconfig[server].setup(opts)
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
		markdown = { "prettierd", "prettier" },
		sh = { "shfmt" },
	},
})

vim.keymap.set({ "n", "v" }, "<leader>f", function()
	require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format" })

-- Lint（markdownlint 等）
local lint = require("lint")
lint.linters_by_ft = {
	markdown = { "markdownlint" },
	yaml = { "yamllint" },
}
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

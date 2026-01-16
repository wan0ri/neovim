return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  opts = {
    ensure_installed = {
      "prettierd","prettier","stylua","shfmt","yamlfmt","yamllint","markdownlint",
    },
    run_on_start = true,
    start_delay = 1500,
    integrations = { mason = true },
  },
}


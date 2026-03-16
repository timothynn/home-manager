##############################################################################
# home/editor/neovim.nix  [Home Manager module]
#
# Neovim — full Lua configuration with:
#   • Catppuccin Mocha theme
#   • Treesitter syntax highlighting
#   • LSP via Mason + nvim-lspconfig
#   • Autocompletion via nvim-cmp + LuaSnip
#   • Telescope fuzzy finder
#   • Git decorations (Gitsigns) + Neogit TUI
#   • File tree (nvim-tree), status line (lualine), buffer tabs (bufferline)
#   • Autopairs, which-key, indent guides, toggleterm
##############################################################################
{ pkgs, ... }:

{
  programs.neovim = {
    enable        = true;
    defaultEditor = true;
    viAlias       = true;
    vimAlias      = true;

    # ── Plugins ────────────────────────────────────────────────────────────
    plugins = with pkgs.vimPlugins; [
      # Theme
      catppuccin-nvim

      # Syntax / Treesitter
      (nvim-treesitter.withPlugins (p: with p; [
        tree-sitter-nix         tree-sitter-lua
        tree-sitter-python      tree-sitter-rust
        tree-sitter-typescript  tree-sitter-javascript
        tree-sitter-go          tree-sitter-bash
        tree-sitter-json        tree-sitter-yaml
        tree-sitter-toml        tree-sitter-markdown
        tree-sitter-markdown-inline
        tree-sitter-css         tree-sitter-html
        tree-sitter-c           tree-sitter-cpp
        tree-sitter-java        tree-sitter-sql
      ]))
      nvim-treesitter-context
      nvim-treesitter-textobjects

      # LSP
      nvim-lspconfig
      mason-nvim
      mason-lspconfig-nvim

      # Completion
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      luasnip
      cmp_luasnip
      friendly-snippets

      # Telescope
      telescope-nvim
      telescope-fzf-native-nvim
      plenary-nvim

      # Git
      gitsigns-nvim
      neogit
      diffview-nvim

      # File / icons
      nvim-tree-lua
      nvim-web-devicons

      # UI chrome
      lualine-nvim
      bufferline-nvim
      indent-blankline-nvim

      # Editing
      nvim-autopairs
      which-key-nvim
      comment-nvim
      toggleterm-nvim

      # Notifications / command UI
      nvim-notify
    ];

    # ── Full Lua configuration ─────────────────────────────────────────────
    initLua = ''
      -- ===========================================================================
      -- Options
      -- ===========================================================================
      local o = vim.opt

      o.number         = true
      o.relativenumber = true
      o.tabstop        = 2
      o.shiftwidth     = 2
      o.expandtab      = true
      o.smartindent    = true
      o.wrap           = false
      o.swapfile       = false
      o.backup         = false
      o.undofile       = true
      o.undodir        = vim.fn.expand("~/.local/state/nvim/undo")
      o.hlsearch       = false
      o.incsearch      = true
      o.termguicolors  = true
      o.scrolloff      = 8
      o.signcolumn     = "yes"
      o.updatetime     = 100
      o.cursorline     = true
      o.mouse          = "a"
      o.clipboard      = "unnamedplus"
      o.completeopt    = { "menu", "menuone", "noselect" }
      o.ignorecase     = true
      o.smartcase      = true
      o.splitbelow     = true
      o.splitright     = true
      o.showmode       = false       -- lualine handles this
      o.pumblend       = 10
      o.winblend       = 10

      vim.g.mapleader      = " "
      vim.g.maplocalleader = "\\"

      -- ===========================================================================
      -- Catppuccin theme
      -- ===========================================================================
      require("catppuccin").setup({
        flavour               = "mocha",
        background            = { light = "latte", dark = "mocha" },
        transparent_background = false,
        term_colors           = true,
        dim_inactive          = { enabled = true, shade = "dark", percentage = 0.15 },
        styles = {
          comments  = { "italic" },
          keywords  = { "bold" },
          functions = { "bold" },
        },
        integrations = {
          cmp             = true,
          gitsigns        = true,
          nvimtree        = true,
          telescope       = { enabled = true },
          treesitter      = true,
          which_key       = true,
          bufferline      = true,
          mason           = true,
          notify          = true,
          indent_blankline = { enabled = true },
          neogit          = true,
          diffview        = true,
          lsp_trouble     = true,
          mini            = { enabled = false },
        },
      })
      vim.cmd.colorscheme("catppuccin-mocha")

      -- ===========================================================================
      -- Keymaps
      -- ===========================================================================
      local map = vim.keymap.set

      -- Window navigation
      map("n", "<C-h>", "<C-w>h", { desc = "Move left" })
      map("n", "<C-j>", "<C-w>j", { desc = "Move down" })
      map("n", "<C-k>", "<C-w>k", { desc = "Move up" })
      map("n", "<C-l>", "<C-w>l", { desc = "Move right" })

      -- Resize with arrows
      map("n", "<C-Up>",    ":resize -2<CR>",          { silent = true })
      map("n", "<C-Down>",  ":resize +2<CR>",          { silent = true })
      map("n", "<C-Left>",  ":vertical resize -2<CR>", { silent = true })
      map("n", "<C-Right>", ":vertical resize +2<CR>", { silent = true })

      -- Buffer navigation
      map("n", "<Tab>",   "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
      map("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })
      map("n", "<leader>bd", "<cmd>bdelete<cr>",           { desc = "Close buffer" })

      -- File tree
      map("n", "<leader>e",  "<cmd>NvimTreeToggle<cr>",  { desc = "Toggle file tree" })
      map("n", "<leader>ef", "<cmd>NvimTreeFindFile<cr>", { desc = "Find file in tree" })

      -- Telescope
      local tb = "<cmd>Telescope "
      map("n", "<leader>ff", tb .. "find_files<cr>",             { desc = "Find files" })
      map("n", "<leader>fg", tb .. "live_grep<cr>",              { desc = "Live grep" })
      map("n", "<leader>fb", tb .. "buffers<cr>",                { desc = "Buffers" })
      map("n", "<leader>fh", tb .. "help_tags<cr>",              { desc = "Help tags" })
      map("n", "<leader>fr", tb .. "oldfiles<cr>",               { desc = "Recent files" })
      map("n", "<leader>fd", tb .. "diagnostics<cr>",            { desc = "Diagnostics" })
      map("n", "<leader>fs", tb .. "lsp_document_symbols<cr>",   { desc = "Symbols" })
      map("n", "<leader>fc", tb .. "git_commits<cr>",            { desc = "Git commits" })

      -- Git
      map("n", "<leader>gs", "<cmd>Neogit<cr>",                           { desc = "Neogit" })
      map("n", "<leader>gd", "<cmd>DiffviewOpen<cr>",                     { desc = "Diff view" })
      map("n", "<leader>gc", "<cmd>DiffviewClose<cr>",                    { desc = "Close diff" })
      map("n", "<leader>gp", function() require("gitsigns").preview_hunk() end, { desc = "Preview hunk" })
      map("n", "<leader>gb", function() require("gitsigns").blame_line() end,   { desc = "Blame line" })
      map("n", "]h",         function() require("gitsigns").next_hunk() end,    { desc = "Next hunk" })
      map("n", "[h",         function() require("gitsigns").prev_hunk() end,    { desc = "Prev hunk" })

      -- Terminal
      map("n", "<leader>tf", "<cmd>ToggleTerm direction=float<cr>",      { desc = "Float terminal" })
      map("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", { desc = "H terminal" })
      map("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>",   { desc = "V terminal" })

      -- Diagnostics
      map("n", "<leader>q",  vim.diagnostic.setloclist,    { desc = "Diagnostic list" })
      map("n", "[d",         vim.diagnostic.goto_prev,     { desc = "Prev diagnostic" })
      map("n", "]d",         vim.diagnostic.goto_next,     { desc = "Next diagnostic" })
      map("n", "<leader>do", vim.diagnostic.open_float,    { desc = "Open diagnostic" })

      -- Misc
      map("n", "<leader>w", "<cmd>w<cr>",   { desc = "Save" })
      map("n", "<leader>q", "<cmd>q<cr>",   { desc = "Quit" })
      map("n", "<Esc>",     "<cmd>noh<cr>", { desc = "Clear highlights" })

      -- ===========================================================================
      -- Treesitter
      -- ===========================================================================
      require("nvim-treesitter.configs").setup({
        highlight           = { enable = true, additional_vim_regex_highlighting = false },
        indent              = { enable = true },
        incremental_selection = {
          enable   = true,
          keymaps  = {
            init_selection    = "<C-space>",
            node_incremental  = "<C-space>",
            scope_incremental = "<C-s>",
            node_decremental  = "<M-space>",
          },
        },
        textobjects = {
          select = {
            enable    = true,
            lookahead = true,
            keymaps   = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
            },
          },
          move = {
            enable              = true,
            set_jumps           = true,
            goto_next_start     = { ["]m"] = "@function.outer", ["]]"] = "@class.outer" },
            goto_next_end       = { ["]M"] = "@function.outer", ["]["] = "@class.outer" },
            goto_previous_start = { ["[m"] = "@function.outer", ["[["] = "@class.outer" },
          },
        },
      })

      require("treesitter-context").setup({ enable = true, max_lines = 4 })

      -- ===========================================================================
      -- Mason + LSP
      -- ===========================================================================
      require("mason").setup({
        ui = {
          border = "rounded",
          icons  = {
            package_installed   = "✓",
            package_pending     = "➜",
            package_uninstalled = "✗",
          },
        },
      })

      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls", "nixd", "rust_analyzer",
          "ts_ls", "pyright",
          "jsonls", "yamlls", "bashls",
          "html", "cssls", "tailwindcss",
        },
        automatic_installation = true,
      })

      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local on_attach = function(_, bufnr)
        local opts = { buffer = bufnr, silent = true }
        map("n", "gd",         vim.lsp.buf.definition,    opts)
        map("n", "gD",         vim.lsp.buf.declaration,   opts)
        map("n", "gi",         vim.lsp.buf.implementation, opts)
        map("n", "gr",         "<cmd>Telescope lsp_references<cr>", opts)
        map("n", "K",          vim.lsp.buf.hover,         opts)
        map("n", "<leader>rn", vim.lsp.buf.rename,        opts)
        map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
        map("n", "<leader>fm", function() vim.lsp.buf.format({ async = true }) end, opts)
      end

      local lspconfig = require("lspconfig")
      local servers   = {
        "nixd", "rust_analyzer", "ts_ls", "pyright",
        "jsonls", "yamlls", "bashls", "html", "cssls", "tailwindcss",
      }

      for _, server in ipairs(servers) do
        lspconfig[server].setup({ capabilities = capabilities, on_attach = on_attach })
      end

      -- Lua LSP with vim globals
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        on_attach    = on_attach,
        settings     = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace   = { checkThirdParty = false },
            telemetry   = { enable = false },
          },
        },
      })

      -- Prettier diagnostic signs
      local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end

      vim.diagnostic.config({
        virtual_text   = true,
        update_in_insert = false,
        severity_sort  = true,
        float          = { border = "rounded", source = "always" },
      })

      -- ===========================================================================
      -- nvim-cmp (completion)
      -- ===========================================================================
      local cmp     = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        window = {
          completion    = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
          ["<C-f>"]     = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]     = cmp.mapping.abort(),
          ["<CR>"]      = cmp.mapping.confirm({ select = true }),
          ["<Tab>"]     = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"]   = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip",  priority = 750 },
          { name = "buffer",   priority = 500, keyword_length = 3 },
          { name = "path",     priority = 250 },
        }),
        formatting = {
          format = function(entry, item)
            local icons = {
              Text          = "󰉿", Method  = "󰆧", Function     = "󰊕",
              Constructor   = "", Field  = "󰜢",  Variable     = "󰀫",
              Class         = "󰠱", Interface = "", Module      = "",
              Property      = "󰜢", Unit    = "󰑭",  Value        = "󰎠",
              Enum          = "", Keyword   = "󰌋",  Snippet      = "",
              Color         = "󰏘", File    = "󰈙",  Reference    = "󰈇",
              Folder        = "󰉋", EnumMember = "", Constant    = "󰏿",
              Struct        = "󰙅", Event   = "",  Operator     = "󰆕",
              TypeParameter = "",
            }
            item.kind = string.format("%s %s", icons[item.kind] or "", item.kind)
            item.menu = ({
              nvim_lsp = "[LSP]",
              luasnip  = "[Snip]",
              buffer   = "[Buf]",
              path     = "[Path]",
            })[entry.source.name]
            return item
          end,
        },
      })

      -- ===========================================================================
      -- Telescope
      -- ===========================================================================
      local telescope = require("telescope")
      local actions   = require("telescope.actions")

      telescope.setup({
        defaults = {
          prompt_prefix   = "   ",
          selection_caret = "  ",
          path_display    = { "smart" },
          sorting_strategy = "ascending",
          layout_config   = {
            horizontal = { prompt_position = "top", preview_width = 0.55 },
            vertical   = { mirror = false },
            width      = 0.87,
            height     = 0.80,
          },
          mappings = {
            i = {
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["<Esc>"] = actions.close,
            },
          },
        },
      })
      telescope.load_extension("fzf")

      -- ===========================================================================
      -- Gitsigns
      -- ===========================================================================
      require("gitsigns").setup({
        signs = {
          add          = { text = "▎" },
          change       = { text = "▎" },
          delete       = { text = "" },
          topdelete    = { text = "‾" },
          changedelete = { text = "~" },
          untracked    = { text = "▎" },
        },
        current_line_blame = true,
        current_line_blame_opts = {
          virt_text         = true,
          virt_text_pos     = "eol",
          delay             = 800,
        },
      })

      -- ===========================================================================
      -- Neogit + Diffview
      -- ===========================================================================
      require("neogit").setup({
        integrations = { diffview = true },
        kind         = "split",
      })
      require("diffview").setup()

      -- ===========================================================================
      -- nvim-tree
      -- ===========================================================================
      require("nvim-tree").setup({
        view    = { width = 32 },
        filters = { dotfiles = false },
        renderer = {
          group_empty         = true,
          root_folder_label   = ":~:s?$?/..?",
          indent_markers      = { enable = true },
          icons = {
            glyphs = {
              default  = "󰈚",
              symlink  = "",
              folder   = {
                arrow_closed = "",
                arrow_open   = "",
                default      = "",
                open         = "",
                empty        = "",
                empty_open   = "",
                symlink      = "",
                symlink_open = "",
              },
            },
          },
        },
        git = { enable = true, ignore = false },
      })

      -- ===========================================================================
      -- Lualine
      -- ===========================================================================
      require("lualine").setup({
        options = {
          theme                  = "catppuccin",
          component_separators   = { left = "", right = "" },
          section_separators     = { left = "", right = "" },
          globalstatus           = true,
          disabled_filetypes     = { statusline = { "dashboard", "NvimTree" } },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })

      -- ===========================================================================
      -- Bufferline
      -- ===========================================================================
      require("bufferline").setup({
        options = {
          mode               = "buffers",
          separator_style    = "slant",
          diagnostics        = "nvim_lsp",
          diagnostics_indicator = function(_, _, diag)
            local icons = { error = " ", warning = " " }
            local ret   = (diag.error   and icons.error   .. diag.error   or "")
                       .. (diag.warning and icons.warning .. diag.warning or "")
            return vim.trim(ret)
          end,
          show_buffer_close_icons = true,
          show_close_icon         = false,
          offsets = {
            {
              filetype   = "NvimTree",
              text       = "  File Explorer",
              highlight  = "Directory",
              separator  = true,
            },
          },
        },
      })

      -- ===========================================================================
      -- Autopairs
      -- ===========================================================================
      require("nvim-autopairs").setup({ check_ts = true })
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

      -- ===========================================================================
      -- Which-key
      -- ===========================================================================
      require("which-key").setup({
        delay  = 300,
        preset = "modern",
      })

      -- Register top-level leader groups
      require("which-key").add({
        { "<leader>f", group = "Find / Telescope" },
        { "<leader>g", group = "Git" },
        { "<leader>t", group = "Terminal" },
        { "<leader>e", group = "Explorer" },
        { "<leader>d", group = "Diagnostics" },
      })

      -- ===========================================================================
      -- Comment.nvim
      -- ===========================================================================
      require("Comment").setup()

      -- ===========================================================================
      -- indent-blankline
      -- ===========================================================================
      require("ibl").setup({
        indent    = { char = "│", tab_char = "│" },
        scope     = { enabled = true },
        exclude   = { filetypes = { "dashboard", "NvimTree", "help" } },
      })

      -- ===========================================================================
      -- ToggleTerm
      -- ===========================================================================
      require("toggleterm").setup({
        size        = function(term)
          if term.direction == "horizontal" then return 16
          elseif term.direction == "vertical" then return math.floor(vim.o.columns * 0.35)
          end
        end,
        open_mapping = [[<c-\>]],
        direction    = "float",
        float_opts   = {
          border      = "curved",
          winblend    = 10,
        },
        shell        = vim.o.shell,
      })

      -- ===========================================================================
      -- nvim-notify
      -- ===========================================================================
      require("notify").setup({
        background_colour = "#1e1e2e",
        fps               = 60,
        render            = "wrapped-compact",
        stages            = "fade",
        timeout           = 3000,
      })
      vim.notify = require("notify")
    '';
  };
}

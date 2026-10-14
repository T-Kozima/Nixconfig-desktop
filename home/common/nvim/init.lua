-- 共通の Neovim 設定（デスクトップ・WSL で共有）
-- 最小構成。必要になったら少しずつ足していく。

-- <Space> をリーダーキーにする（他のマッピングより前に設定する必要がある）
vim.g.mapleader = " "

local opt = vim.opt

-- 表示
opt.number = true          -- 行番号
opt.relativenumber = true  -- 現在行からの相対行番号
opt.cursorline = true      -- カーソル行を強調
opt.termguicolors = true   -- 24bit カラー
opt.scrolloff = 8          -- カーソルの上下に最低8行を残してスクロール

-- インデント（スペース2つ。言語ごとに変えたい場合は ftplugin で上書き）
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true

-- 検索
opt.ignorecase = true      -- 小文字だけで検索したときは大文字小文字を区別しない
opt.smartcase = true       -- 大文字を含めたら区別する

-- その他
opt.clipboard = "unnamedplus"  -- OS のクリップボードと連携
opt.undofile = true            -- 閉じても undo 履歴を残す
opt.mouse = "a"

-- キーマップ
vim.keymap.set("n", "<leader>w", "<cmd>write<cr>", { desc = "保存" })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "検索ハイライトを消す" })

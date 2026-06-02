#!/usr/bin/env fish

# 💡 壁紙が保存されているディレクトリを指定（ご自身の環境に合わせて変更してください）
set WALLPAPER_DIR "$HOME/dotfiles/wallpapers/walls-catppuccin-mocha"
# 💡 切り替え間隔（秒）: 例として10分（600秒）
set INTERVAL 300

# ディレクトリが存在しない場合は終了
if not test -d "$WALLPAPER_DIR"
    echo "Directory not found: $WALLPAPER_DIR"
    exit 1
end

# 永遠にループして壁紙を切り替える
while true
    # ディレクトリ内の画像をランダムに1つ選ぶ
    set img (random choice $WALLPAPER_DIR/*)

    # 拡張子が画像のものだけを弾く簡易チェック（エラー回避）
    if string match -r -q '\.(jpg|jpeg|png|webp|gif)$' -- $img
        # awwwで壁紙を設定（アニメーション付き）
        awww img "$img" \
            --transition-type grow \
            --transition-pos 0.5,0.5 \
            --transition-step 90 \
            --transition-fps 60
    end

    # 指定秒数待機
    sleep $INTERVAL
end

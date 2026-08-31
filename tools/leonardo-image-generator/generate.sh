#!/bin/bash
# Leonardo Image Generator -簡単実行スクリプト

set -e

echo "🎨 Leonardo Image Generator"
echo "================================="

# スクリプトディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# .env ファイルの確認
if [ ! -f ".env" ]; then
    echo "❌ エラー: .env ファイルが見つかりません"
    echo "📝 作成手順："
    echo "   1. cp .env.example .env"
    echo "   2. .env を編集して LEONARDO_API_KEY を設定"
    exit 1
fi

# APIキーの確認
if ! grep -q "LEONARDO_API_KEY=" .env || grep "LEONARDO_API_KEY=your_api_key_here" .env > /dev/null; then
    echo "❌ エラー: LEONARDO_API_KEY が設定されていません"
    echo "📝 .env ファイルを編集してください"
    exit 1
fi

# 依存関係の確認
if ! python3 -c "import requests" 2>/dev/null; then
    echo "📦 依存関係をインストール中..."
    pip install -r requirements.txt
fi

# 引数の処理
CONFIG_FILE="${1:-assets_config.json}"
OUTPUT_DIR="${2:-./generated_assets}"

# 実行
echo "📋 設定ファイル: $CONFIG_FILE"
echo "📁 出力ディレクトリ: $OUTPUT_DIR"
echo ""
echo "⏳ 画像生成中..."
echo "================================="

python3 leonardo_generator.py --config "$CONFIG_FILE" --output "$OUTPUT_DIR"

echo ""
echo "✅ 完了！"
echo "📁 出力: $OUTPUT_DIR/"
echo "📊 結果: $OUTPUT_DIR/generation_results.json"

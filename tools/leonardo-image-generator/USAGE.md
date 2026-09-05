# 使用ガイド

Leonardo Image Generator の実践的な使用例

## クイックスタート（5分）

### 1. 環境構築

```bash
cd tools/leonardo-image-generator

# 環境ファイルを作成
cp .env.example .env

# .env を編集してAPIキーを設定
nano .env
# または
cat > .env << EOF
LEONARDO_API_KEY=your_api_key_here
LEONARDO_BASE_URL=https://api.leonardo.ai/v1
OUTPUT_DIR=./generated_assets
EOF
```

### 2. 依存関係をインストール

```bash
pip install -r requirements.txt
```

### 3. 画像を生成

**方法A: シェルスクリプト（最も簡単）**
```bash
./generate.sh
```

**方法B: Pythonコマンド**
```bash
python leonardo_generator.py --config assets_config.json
```

**方法C: 単一画像生成**
```bash
python leonardo_generator.py \
  --prompt "Beautiful chess board" \
  --filename "chess_board.png"
```

### 4. 出力確認

```bash
ls -la generated_assets/
cat generated_assets/generation_results.json
```

---

## 実例1: Chess Tactics Master

### ステップ1: 設定ファイルを準備

```bash
cp example_chess_config.json my_chess_assets.json
```

### ステップ2: 実行

```bash
python leonardo_generator.py --config my_chess_assets.json
```

### ステップ3: 結果を確認

```bash
# 生成されたファイルをチェック
ls -lh generated_assets/

# 結果サマリーを表示
jq . generated_assets/generation_results.json
```

### ステップ4: Flutter プロジェクトにコピー

```bash
# iOS/Android アセットフォルダへコピー
cp generated_assets/app_icon_*.png ../assets/images/

# ラッシュスクリーン画像をコピー
cp generated_assets/splash_*.png ../assets/splash/
```

---

## 実例2: カスタムプロジェクト用アセット生成

### 自分のプロジェクト用設定ファイルを作成

`my_app_config.json`:
```json
{
  "project": "My Custom App",
  "assets": [
    {
      "name": "App Icon",
      "filename": "my_app_icon.png",
      "width": 1024,
      "height": 1024,
      "guidance_scale": 7.0,
      "prompt": "Your custom prompt here"
    }
  ]
}
```

### 実行

```bash
python leonardo_generator.py --config my_app_config.json --output ./my_app_assets
```

---

## 実例3: Python スクリプト内での使用

```python
#!/usr/bin/env python3
from leonardo_generator import LeonardoGenerator

# 初期化
generator = LeonardoGenerator(env_file='.env')

# 単一画像生成
icon_path = generator.generate_image(
    prompt="Modern app icon design, flat style, professional",
    filename="icon.png",
    width=1024,
    height=1024
)

print(f"✅ Icon saved to: {icon_path}")

# 複数画像の一括生成
assets = [
    {
        'prompt': 'App splash screen, modern design',
        'filename': 'splash.png',
        'width': 1080,
        'height': 1920
    },
    {
        'prompt': 'Game board background',
        'filename': 'board.png',
        'width': 512,
        'height': 512
    }
]

results = generator.batch_generate(assets)

for filename, path in results.items():
    print(f"{filename}: {path}")
```

---

## 実例4: 複数プロジェクトでの共有利用

### セットアップ（一度だけ）

プロジェクトルートで：
```bash
# シンボリックリンクを作成（推奨）
ln -s ../../tools/leonardo-image-generator ./tools/leonardo-generator

# または手動でコピー
cp -r tools/leonardo-image-generator ../other_project/tools/
```

### 各プロジェクトで使用

```bash
cd my_project
./tools/leonardo-generator/generate.sh ./tools/leonardo-generator/example_chess_config.json
```

---

## 実例5: CI/CD パイプラインへの統合

### GitHub Actions ワークフロー例

`.github/workflows/generate-assets.yml`:
```yaml
name: Generate Assets

on:
  workflow_dispatch:
  push:
    paths:
      - 'tools/leonardo-image-generator/assets_config.json'

jobs:
  generate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Install dependencies
        run: |
          cd tools/leonardo-image-generator
          pip install -r requirements.txt
      
      - name: Generate images
        env:
          LEONARDO_API_KEY: ${{ secrets.LEONARDO_API_KEY }}
        run: |
          cd tools/leonardo-image-generator
          python leonardo_generator.py --config assets_config.json
      
      - name: Commit and push
        run: |
          git add generated_assets/
          git commit -m "🎨 Auto-generated assets"
          git push
```

### 使用方法：
1. GitHub Settings → Secrets → `LEONARDO_API_KEY` を設定
2. Actions タブで **"Generate Assets"** をトリガー
3. 自動生成された画像が自動コミット

---

## トラブルシューティング集

### Q: "LEONARDO_API_KEY が設定されていません"

**A:** .env ファイルを確認
```bash
cat .env
# 出力に以下が含まれていることを確認:
# LEONARDO_API_KEY=xxxxxxxxxxxx

# 設定されていなければ
echo "LEONARDO_API_KEY=your_key_here" >> .env
```

### Q: "エラー 401: Unauthorized"

**A:** APIキーが正しいか確認
```bash
# Leonardo.ai ダッシュボードで新しいキーを生成
# .env を更新
nano .env
```

### Q: 生成が遅い

**A:** 並列処理が不可なため、複数回実行を分割
```bash
# 少数のアセットに分けて実行
python leonardo_generator.py --config part1.json
python leonardo_generator.py --config part2.json
```

### Q: 画像品質が低い

**A:** プロンプトを改善
- より詳細な説明を追加
- "professional", "high quality" などのキーワードを追加
- `guidance_scale` を 8-10 に上げる

```json
{
  "prompt": "High quality professional chess board, detailed wooden texture, clear 8x8 grid, isolated on clean white background, 4K resolution",
  "guidance_scale": 8.5
}
```

---

## ベストプラクティス

✅ **推奨:**
- JSON設定ファイルで管理（再利用性が高い）
- 詳細でわかりやすいプロンプトを使用
- 複数回試して最良のものを選択
- `generated_assets/` は .gitignore に追加

❌ **非推奨:**
- .env をリポジトリにコミット
- APIキーをハードコード
- 詳細なプロンプトなしで生成

---

## パフォーマンスチューニング

### 高速化

```bash
# 小さいサイズから始める
python leonardo_generator.py --width 512 --height 512

# 品質を下げる（ただし品質が悪くなる）
# guidance_scale を 5 に下げる
```

### 品質向上

```bash
# より詳細なプロンプト
# guidance_scale を 9-12 に上げる
# ハイレゾリューションで生成（1024×1024以上）
```

---

## まとめ

| 用途 | コマンド |
|------|---------|
| 最初の実行 | `./generate.sh` |
| チェスアプリ用 | `python leonardo_generator.py --config example_chess_config.json` |
| カスタムアセット | `python leonardo_generator.py --config my_config.json` |
| 単一画像 | `python leonardo_generator.py --prompt "..." --filename "..."` |
| Python内での使用 | `from leonardo_generator import LeonardoGenerator` |

---

**次のステップ:**
1. ✅ APIキーを設定
2. ✅ 最初の画像生成テスト
3. ✅ チェスアプリ用アセット生成
4. ✅ Flutter プロジェクトに統合
5. ✅ CI/CD に組み込み

質問や問題があれば、README.md のトラブルシューティングを参照してください。

# 🎨 Leonardo Image Generator Tool

Leonardo.ai API を使用して、複数のプロジェクトで再利用可能な画像生成ツール

## 概要

このツールは以下を提供します：

- ✅ Leonardo.ai Phoenix 1.0 モデルを使用した高品質画像生成
- ✅ バッチ処理による複数アセットの自動生成
- ✅ JSON設定ファイルによる簡単な管理
- ✅ 複数プロジェクトでの再利用性
- ✅ CLI インターフェース

## セットアップ

### 1. Leonardo.ai APIキーの取得

1. https://leonardo.ai にアクセス
2. アカウント作成（メール/Google/Discord）
3. ダッシュボード → **Settings** → **API Keys**
4. **+ Create API Key** をクリックしてキーを生成
5. APIキーをコピー

### 2. 環境変数の設定

```bash
# .env ファイルを作成
cp .env.example .env

# APIキーを設定
echo "LEONARDO_API_KEY=your_api_key_here" >> .env
```

### 3. 依存関係のインストール

```bash
pip install -r requirements.txt
```

## 使用方法

### 設定ファイルから生成（推奨）

```bash
python leonardo_generator.py --config assets_config.json
```

**出力:**
- `generated_assets/` ディレクトリに画像が保存される
- `generation_results.json` に結果が記録される

### 単一画像の生成

```bash
python leonardo_generator.py \
  --prompt "Beautiful chess board" \
  --filename "chess_board.png" \
  --width 1024 \
  --height 1024
```

### カスタム出力ディレクトリを指定

```bash
python leonardo_generator.py \
  --config assets_config.json \
  --output ./my_assets
```

### カスタム .env ファイルを使用

```bash
python leonardo_generator.py \
  --config config.json \
  --env /path/to/.env
```

## 設定ファイル形式

`assets_config.json` の例：

```json
{
  "project": "My App",
  "description": "App assets",
  "assets": [
    {
      "name": "App Icon",
      "filename": "app_icon.png",
      "width": 1024,
      "height": 1024,
      "guidance_scale": 7.0,
      "prompt": "Modern app icon, minimalist design, professional"
    }
  ]
}
```

### パラメータ説明

| パラメータ | 説明 | デフォルト |
|-----------|------|----------|
| `name` | アセット名（情報用） | - |
| `filename` | 出力ファイル名 | - |
| `width` | 画像幅（ピクセル） | 1024 |
| `height` | 画像高さ（ピクセル） | 1024 |
| `guidance_scale` | ガイダンススケール（7-15推奨） | 7.0 |
| `prompt` | 画像生成プロンプト | - |

## Python API での使用

```python
from leonardo_generator import LeonardoGenerator

# 初期化
generator = LeonardoGenerator()

# 単一画像生成
path = generator.generate_image(
    prompt="Beautiful chess board",
    filename="board.png",
    width=1024,
    height=1024
)

# 複数画像一括生成
assets = [
    {
        'prompt': 'App icon design',
        'filename': 'icon.png',
        'width': 1024,
        'height': 1024
    },
    {
        'prompt': 'Splash screen',
        'filename': 'splash.png',
        'width': 1080,
        'height': 1920
    }
]

results = generator.batch_generate(assets)
```

## 推奨プロンプト集

### アプリアイコン
```
Modern chess app icon, minimalist design with white and dark blue color scheme, 
elegant chess pieces, app store quality, professional, flat design, 
isolated on transparent background
```

### スプラッシュスクリーン
```
Chess board game splash screen, dark elegant theme, premium mobile UI design, 
modern interface, professional photography, [width]x[height] aspect ratio
```

### チェスボード
```
Professional chess board design, elegant wooden or marble texture, 
8x8 grid, high quality, isolated on clean background, premium quality
```

### ナビゲーションアイコン
```
Minimalist [icon_name] icon for mobile app, flat design, monochrome white color, 
modern style, consistent with material design
```

## トラブルシューティング

### ❌ "LEONARDO_API_KEY が設定されていません"

```bash
# .env ファイルを確認
cat .env

# APIキーを設定
export LEONARDO_API_KEY="your_api_key"
```

### ❌ "エラー 401: Unauthorized"

- APIキーが正しいか確認
- APIキーの有効期限を確認
- 新しいAPIキーを生成

### ❌ "タイムアウト"

```bash
# インターネット接続を確認
ping leonardo.ai

# max_wait を増やす（Python API 使用時）
generator.generate_image(prompt="...", filename="...", ...)
```

### ❌ 生成品質が低い

**解決策：**
1. プロンプトをより詳細にする
2. "professional", "high quality", "4K" などのキーワードを追加
3. `guidance_scale` を 7-15 の範囲で調整
4. 複数回実行して最良のものを選択

## 生成フロー

```
1. .env ファイルに APIキーを設定
   ↓
2. leonardo_generator.py を実行
   ↓
3. API に プロンプト送信
   ↓
4. 生成完了をポーリング（最大300秒）
   ↓
5. 画像をダウンロード
   ↓
6. generated_assets/ に保存
```

## パフォーマンス

- **生成時間**: 30-60秒/画像
- **レート制限**: リクエスト間隔 1-2秒推奨
- **最大待機時間**: 300秒（設定可能）

## 複数プロジェクトでの使用

### 方法1: シンボリックリンク
```bash
ln -s /path/to/leonardo-image-generator my_project/tools/
```

### 方法2: コピー
```bash
cp -r leonardo-image-generator ../my_project/tools/
```

### 方法3: Python パッケージ化
```python
# setup.py を追加して PyPI に公開
```

## セキュリティ

⚠️ **重要:**

- `.env` ファイルは絶対に公開リポジトリにコミットしない
- `.gitignore` に以下を追加：
  ```
  .env
  .env.local
  generated_assets/
  __pycache__/
  ```
- APIキーは環境変数で管理

## ライセンス

このツールは Chess Tactics Master プロジェクトの一部です

## 参考リンク

- [Leonardo.ai公式](https://leonardo.ai)
- [Leonardo.ai API ドキュメント](https://docs.leonardo.ai/reference/introduction)
- [Phoenix モデル](https://leonardo.ai/blog/phoenix-model)

## サポート

問題が発生した場合は、以下を確認してください：

1. `.env` ファイルが正しく設定されている
2. インターネット接続が正常
3. APIキーの有効性
4. Leonardo.ai ダッシュボードのAPI使用状況

---

**作成日**: 2026-08-31  
**バージョン**: 1.0.0

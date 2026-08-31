# 🎨 Leonardo Image Generator - ローカル実行引き継ぎ書

**Chess Tactics Master** アプリ用アセット自動生成ツール  
ローカル Claude Code での実行ガイド

---

## 📋 概要

Leonardo.ai Phoenix 1.0 モデルを使用して、Chess Tactics Master アプリに必要な UI/UX アセット画像を自動生成するツール。

### ツール構成
```
tools/leonardo-image-generator/
├── leonardo_generator.py         # メイン実行スクリプト
├── assets_config.json            # アセット定義ファイル
├── example_chess_config.json     # チェスアプリ設定例
├── requirements.txt              # Python依存関係
├── .env.example                  # 環境変数テンプレート
├── README.md                     # 詳細ドキュメント
├── USAGE.md                      # 実践例
├── GITHUB_ACTIONS.md             # CI/CD ガイド
└── generate.sh                   # シェルスクリプト
```

---

## 🔑 前提条件

### 1. Leonardo.ai アカウント
- https://leonardo.ai でアカウント作成
- メール/Google/Discord から選択可能
- 無料プランで開始可能

### 2. API キー取得
```
Leonardo.ai ダッシュボード → Settings → API Keys
→ + Create API Key → コピー
```

### 3. ローカル環境
- Python 3.8+
- pip (パッケージマネージャー)
- git

---

## ⚙️ セットアップ手順

### ステップ1: ツールディレクトリへ移動

```bash
cd tools/leonardo-image-generator
```

### ステップ2: .env ファイルを作成

```bash
cp .env.example .env
```

### ステップ3: APIキーを設定

テキストエディタで `.env` を開いて編集：

```bash
# .env
LEONARDO_API_KEY=your_actual_api_key_here
LEONARDO_BASE_URL=https://api.leonardo.ai/v1
OUTPUT_DIR=./generated_assets
```

**セキュリティ重要:**
- ❌ `.env` を GitHub にコミットしない
- ✅ `.gitignore` に追加済み（確認: `git check-ignore .env`）
- ✅ APIキーは環境変数で管理

### ステップ4: 依存関係をインストール

```bash
pip install -r requirements.txt
```

**インストール内容:**
- `python-dotenv` - 環境変数読み込み
- `requests` - HTTP通信
- `pillow` - 画像処理

---

## 🚀 実行方法

### 方法1: シェルスクリプト（最も簡単）

```bash
./generate.sh
```

**実行内容:**
- 環境ファイル確認
- 依存関係確認
- `assets_config.json` から読み込み
- 画像生成開始

### 方法2: Python コマンド（推奨）

```bash
# デフォルト設定で実行
python leonardo_generator.py --config assets_config.json

# カスタム出力ディレクトリ
python leonardo_generator.py --config assets_config.json --output ./my_assets

# 単一画像生成
python leonardo_generator.py \
  --prompt "Modern chess app icon" \
  --filename "icon.png" \
  --width 1024 \
  --height 1024
```

### 方法3: Python API（プログラマティック）

```python
from leonardo_generator import LeonardoGenerator

# 初期化
generator = LeonardoGenerator(env_file='.env')

# 単一画像生成
path = generator.generate_image(
    prompt="Beautiful chess board",
    filename="board.png",
    width=1024,
    height=1024
)

# 複数画像一括生成
assets = [
    {'prompt': '...', 'filename': 'icon1.png', 'width': 1024, 'height': 1024},
    {'prompt': '...', 'filename': 'icon2.png', 'width': 512, 'height': 512}
]
results = generator.batch_generate(assets)

# 結果を保存
generator.save_results(results)
```

---

## 📊 実行時間目安

| 項目 | 時間 |
|------|------|
| セットアップ | 30秒 |
| 依存関係インストール | 1-2分 |
| 1枚の画像生成 | 30-60秒 |
| 13枚一括生成 | 5-8分 |
| **合計（初回）** | **8-12分** |
| **合計（2回目以降）** | **5-8分** |

---

## 📁 生成ファイル構造

実行後、以下が自動生成されます：

```
generated_assets/
├── app_icon_1024x1024.png           # App icon
├── app_icon_512x512.png
├── app_icon_192x192.png
├── splash_android_1080x1920.png     # Android splash
├── splash_ios_1170x2532.png         # iOS splash
├── chess_board_standard.png         # Chess board
├── chess_pieces_white.png           # White pieces
├── chess_pieces_black.png           # Black pieces
├── icon_home.png                    # Navigation icons
├── icon_puzzle.png
├── icon_game.png
├── icon_profile.png
├── icon_settings.png
├── icon_leaderboard.png
├── feature_graphic_1242x2688.png    # Play Store graphic
└── generation_results.json          # 生成結果記録
```

### generation_results.json 形式

```json
{
  "app_icon_1024x1024.png": "/path/to/generated_assets/app_icon_1024x1024.png",
  "splash_android_1080x1920.png": "/path/to/generated_assets/splash_android_1080x1920.png",
  ...
}
```

---

## 🔧 カスタマイズ

### 設定ファイルを編集

`assets_config.json` の構造：

```json
{
  "project": "プロジェクト名",
  "description": "説明",
  "assets": [
    {
      "name": "表示名",
      "filename": "出力ファイル名.png",
      "width": 1024,
      "height": 1024,
      "guidance_scale": 7.0,
      "prompt": "画像説明プロンプト"
    }
  ]
}
```

### プロンプトのコツ

✅ **良いプロンプト例:**
```
Modern chess app icon, minimalist flat design, white and dark blue color scheme, 
elegant chess pieces in center, app store quality, professional, high resolution
```

❌ **悪いプロンプト例:**
```
chess icon
```

**効果的なプロンプト要素:**
- スタイル: "modern", "minimalist", "professional"
- 品質: "high quality", "professional", "4K"
- 技術: "flat design", "3D rendering"
- 詳細: 色、サイズ、配置など
- 用途: "app store", "mobile UI"

### guidance_scale の調整

- `7.0` (デフォルト) - バランス型
- `5.0` 以下 - より創造的（予測不可能）
- `10.0` 以上 - プロンプト重視（高品質）

```json
{
  "guidance_scale": 8.5,  // より高品質
  "prompt": "..."
}
```

---

## 📤 Flutter プロジェクトへの統合

### ステップ1: アセットフォルダに配置

```bash
# 生成されたファイルをアセットフォルダにコピー
cp generated_assets/*.png ../assets/images/
```

### ステップ2: pubspec.yaml に登録

```yaml
flutter:
  assets:
    - assets/images/app_icon_1024x1024.png
    - assets/images/splash_android_1080x1920.png
    - assets/images/splash_ios_1170x2532.png
    - assets/images/chess_board_standard.png
    - assets/images/chess_pieces_white.png
    - assets/images/chess_pieces_black.png
    - assets/images/icon_home.png
    - assets/images/icon_puzzle.png
    - assets/images/icon_game.png
    - assets/images/icon_profile.png
    - assets/images/icon_settings.png
    - assets/images/icon_leaderboard.png
    - assets/images/feature_graphic_1242x2688.png
```

### ステップ3: Flutter コードで使用

```dart
import 'package:flutter/material.dart';

class AppIconWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/app_icon_1024x1024.png',
      width: 100,
      height: 100,
    );
  }
}
```

---

## ⚠️ トラブルシューティング

### ❌ "ModuleNotFoundError: No module named 'dotenv'"

**解決:**
```bash
pip install python-dotenv
# または
pip install -r requirements.txt
```

### ❌ "LEONARDO_API_KEY が設定されていません"

**確認:**
```bash
cat .env
echo $LEONARDO_API_KEY  # 環境変数として設定されているか確認
```

**解決:**
```bash
# .env を編集して APIキーを設定
nano .env
# または
echo "LEONARDO_API_KEY=your_key_here" >> .env
```

### ❌ "エラー 401: Unauthorized"

**原因:**
- APIキーが無効
- APIキーが期限切れ
- APIキーの形式が間違っている

**解決:**
1. Leonardo.ai ダッシュボードで新しいキーを生成
2. `.env` を更新
3. 再実行

### ❌ "タイムアウト"

**原因:**
- ネットワーク接続の不安定
- Leonardo.ai API が過負荷

**解決:**
```bash
# インターネット接続を確認
ping leonardo.ai

# 再実行
python leonardo_generator.py --config assets_config.json
```

### ❌ 生成品質が低い

**原因:**
- プロンプトが不十分
- guidance_scale が低い

**解決:**
1. プロンプトを詳細にする
2. guidance_scale を 8-10 に上げる
3. 複数回実行して比較

```json
{
  "prompt": "より詳細で具体的なプロンプト",
  "guidance_scale": 8.5
}
```

---

## 🔐 セキュリティ チェックリスト

```bash
# ✅ .env がコミットされていないか確認
git status | grep .env

# ✅ .gitignore に .env が含まれているか
grep "\.env" .gitignore

# ✅ APIキーが安全に管理されているか
cat .env | grep LEONARDO_API_KEY

# ✅ 過去のコミットに APIキーが含まれていないか
git log --all --oneline | grep -i api
```

---

## 📚 参考ドキュメント

| ドキュメント | 内容 |
|-----------|------|
| `README.md` | 完全なセットアップと API仕様 |
| `USAGE.md` | 実践的な使用例 |
| `GITHUB_ACTIONS.md` | CI/CD パイプライン設定 |
| `example_chess_config.json` | チェスアプリ用の完全設定例 |

---

## 🎯 ワークフロー例

### 典型的な作業フロー

```bash
# 1. ツールディレクトリへ移動
cd tools/leonardo-image-generator

# 2. .env を確認（初回のみ設定）
cat .env

# 3. 画像生成実行
python leonardo_generator.py --config assets_config.json

# 4. 完了を待つ（5-8分）
# ログで進捗を確認

# 5. 生成ファイルを確認
ls -lh generated_assets/

# 6. Flutter プロジェクトにコピー
cp generated_assets/*.png ../assets/images/

# 7. Flutter アプリを更新
cd ..
flutter pub get
flutter run
```

### 繰り返し生成時

```bash
# 設定を編集
nano assets_config.json

# 再生成
python leonardo_generator.py --config assets_config.json

# 差分を確認
diff <(ls -1 generated_assets/) <previous_list.txt>
```

---

## 💡 ベストプラクティス

✅ **推奨:**
- 詳細でわかりやすいプロンプトを使用
- 複数回試して最良のものを選択
- 生成ファイルは `.gitignore` で除外
- `generation_results.json` で履歴を管理
- APIレート制限を守る（リクエスト間隔 1秒以上）

❌ **非推奨:**
- `.env` をリポジトリにコミット
- APIキーをハードコード
- 詳細なプロンプトなしで生成
- 生成ファイルを手動編集してコミット

---

## 📞 トラブル時の問い合わせ手順

問題が発生した場合：

1. **エラーメッセージをコピー**
   ```bash
   python leonardo_generator.py 2>&1 | tee error.log
   ```

2. **ログを確認**
   ```bash
   cat error.log
   ```

3. **チェックリスト確認**
   - .env ファイルが存在するか
   - APIキーが有効か
   - インターネット接続は正常か
   - Python/pip は正しくインストールされているか

4. **README.md のトラブルシューティング参照**
   ```bash
   cat README.md | grep -A 5 "エラー"
   ```

---

## 🔄 API 使用制限

Leonardo.ai の無料プランでの制限（参考）：

| 項目 | 制限 |
|------|-----|
| 月間生成数 | 150 画像 |
| 同時実行 | 1 ジョブ |
| 画像保持期間 | 30日 |
| 最大解像度 | 1024×1024 |

詳細は Leonardo.ai 公式ドキュメント参照

---

## 📝 記録管理

### 生成履歴を保存

```bash
# 生成結果をバックアップ
cp generated_assets/generation_results.json generation_results_$(date +%Y%m%d_%H%M%S).json

# 生成画像をアーカイブ
tar -czf generated_assets_$(date +%Y%m%d).tar.gz generated_assets/
```

### バージョン管理

```bash
# assets_config.json のバージョンを記録
git log --oneline assets_config.json | head -5
```

---

## ✨ まとめ

### クイックスタート（5分）

```bash
cd tools/leonardo-image-generator
cp .env.example .env
# .env を編集して APIキーを設定
pip install -r requirements.txt
python leonardo_generator.py --config assets_config.json
```

### 完了後

```bash
ls -lh generated_assets/
cp generated_assets/*.png ../assets/images/
cd ../.. && flutter run
```

---

**このツールにより、Chess Tactics Master アプリの高品質なアセット画像を効率的に生成できます。** 🎨

質問や問題があれば、README.md または USAGE.md を参照してください。

---

**最終更新**: 2026-08-31  
**バージョン**: 2.0.0  
**対象**: Leonardo.ai Phoenix 1.0 モデル

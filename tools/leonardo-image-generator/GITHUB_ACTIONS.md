# GitHub Actions で自動アセット生成

Leonardo Image Generator を GitHub Actions で自動実行するガイド

## セットアップ

### 1. GitHub Secrets に APIキーを設定

```
GitHub リポジトリ → Settings → Secrets and variables → Actions
→ New repository secret

Name: LEONARDO_API_KEY
Value: your_api_key_here
```

✅ 既に設定済み

### 2. ワークフローファイルが存在確認

```bash
ls -la .github/workflows/generate-leonardo-assets.yml
```

✅ `.github/workflows/generate-leonardo-assets.yml` が存在

---

## 実行方法

### **方法1: 手動トリガー（推奨）**

```
GitHub → Actions → "Generate Leonardo.ai Assets" → Run workflow
```

手順：
1. リポジトリの **Actions** タブを開く
2. 左から **"Generate Leonardo.ai Assets"** を選択
3. **Run workflow** をクリック
4. 完了を待つ（3-10分）
5. 自動コミット & プッシュされる

### **方法2: 設定ファイル変更で自動トリガー**

以下のいずれかのファイルを編集・プッシュすると自動実行：
- `tools/leonardo-image-generator/assets_config.json`
- `tools/leonardo-image-generator/example_chess_config.json`
- `.github/workflows/generate-leonardo-assets.yml`

```bash
# 例: 設定を編集して自動実行
nano tools/leonardo-image-generator/assets_config.json
git add .
git commit -m "Update asset config"
git push origin claude/phase-d-stage-3-device-testing-wgxbuo
# → ワークフローが自動実行
```

---

## ワークフローの仕組み

### **トリガー条件**

```yaml
on:
  workflow_dispatch:           # 手動実行（推奨）
  push:
    paths:                     # 自動実行
      - 'tools/leonardo-image-generator/assets_config.json'
      - 'tools/leonardo-image-generator/example_chess_config.json'
      - '.github/workflows/generate-leonardo-assets.yml'
```

### **実行ステップ**

1. ✅ リポジトリをチェックアウト
2. ✅ Python 3.11 をセットアップ
3. ✅ 依存関係をインストール
4. ✅ Leonardo.ai API で画像生成
5. ✅ 生成結果をサマリーに出力
6. ✅ 自動コミット & プッシュ

### **実行時間**

- セットアップ: 1-2分
- 画像生成: 3-8分（アセット数による）
- 合計: 5-10分

---

## 実行結果の確認

### **1. Actions ログを確認**

```
GitHub → Actions → "Generate Leonardo.ai Assets" 
→ 最新の実行 → ログを確認
```

出力例：
```
✅ 生成完了

生成されたアセット:
- ✅ app_icon_1024.png
- ✅ splash_android_1080x1920.png
- ✅ chess_board_1024x1024.png
- ... 他 13 ファイル
```

### **2. 生成されたファイルを確認**

```bash
# ローカルで確認
git pull origin claude/phase-d-stage-3-device-testing-wgxbuo
ls -la tools/leonardo-image-generator/generated_assets/

# または GitHub 上で
GitHub → Code → tools/leonardo-image-generator/generated_assets/
```

### **3. コミットメッセージで確認**

```bash
git log --oneline -5
# → 🎨 Auto-generated Leonardo.ai assets (13 files)
```

---

## トラブルシューティング

### ❌ ワークフロー実行エラー

**問題: "LEONARDO_API_KEY が見つかりません"**

```bash
# 確認方法
GitHub Settings → Secrets and variables → Actions
→ LEONARDO_API_KEY が存在することを確認
```

**解決:**
1. Secret を再作成
2. ワークフローを再実行

---

### ❌ "エラー 401: Unauthorized"

**問題: APIキーが無効または期限切れ**

```bash
# 解決方法
1. Leonardo.ai ダッシュボール → API Keys
2. 古いキーを削除
3. 新しいキーを生成
4. GitHub Secret を更新
5. ワークフローを再実行
```

---

### ❌ "タイムアウト"

**問題: 生成に時間がかかっている**

```bash
# ワークフロー実行時間制限を確認
timeout-minutes: 30  # 現在30分に設定

# 必要に応じて増やす（最大360分）
```

---

### ❌ "No changes to commit"

**問題: 前回と同じアセットが生成された**

→ これは正常です。重複生成を避けるため自動でスキップされます。

---

## カスタマイズ

### **別の設定ファイルを使用**

デフォルト: `assets_config.json`

別のファイルを使う場合：

```yaml
# .github/workflows/generate-leonardo-assets.yml を編集
run: |
  cd tools/leonardo-image-generator
  python leonardo_generator.py --config example_chess_config.json
```

---

### **出力ディレクトリを変更**

```yaml
run: |
  cd tools/leonardo-image-generator
  python leonardo_generator.py --config assets_config.json --output ./my_assets
```

---

### **環境変数を設定**

```yaml
env:
  LEONARDO_API_KEY: ${{ secrets.LEONARDO_API_KEY }}
  LEONARDO_BASE_URL: https://api.leonardo.ai/v1
  OUTPUT_DIR: ./generated_assets
```

---

## ベストプラクティス

✅ **推奨:**
- 手動トリガーを定期的に実行（週1回など）
- 設定変更時のみ自動実行
- 生成結果をレビューしてからマージ
- 成功時のアラート設定

❌ **非推奨:**
- 毎回全アセットを再生成（APIレート制限）
- 生成ファイルを手動で編集してコミット
- 複数ワークフローの同時実行

---

## スケジュール実行（オプション）

毎週金曜 10:00 に自動実行：

```yaml
# .github/workflows/generate-leonardo-assets.yml に追加
on:
  schedule:
    - cron: '0 10 * * 5'  # 毎週金曜 10:00 UTC
```

---

## GitHub Actions の制限

| 項目 | 制限 |
|------|-----|
| 実行時間 | 最大 360分 |
| ログサイズ | 16MB |
| ジョブ数 | 1000/日（Free プラン） |
| 同時実行 | 20 ジョブ |

---

## セキュリティ確認

✅ **安全性チェック:**

```bash
# Secrets が公開されていないか確認
git log --all --grep="LEONARDO_API_KEY" || echo "✅ Safety OK"

# ワークフロー内で Secrets が適切に使用されている
grep -n "secrets.LEONARDO_API_KEY" .github/workflows/generate-leonardo-assets.yml
```

✅ **ログに APIキーが出力されない設定:**

```yaml
env:
  LEONARDO_API_KEY: ${{ secrets.LEONARDO_API_KEY }}
# → GitHub Actions が自動でマスク処理
```

---

## まとめ

| 操作 | 方法 |
|------|-----|
| **初回実行** | Actions → Run workflow |
| **定期実行** | Actions → スケジュール設定 |
| **カスタム実行** | config.json 編集 → push |
| **デバッグ** | Actions → ログを確認 |

---

## トラブル時の問い合わせポイント

ワークフローが失敗した場合、以下を確認：

1. ✅ `LEONARDO_API_KEY` Secret が存在
2. ✅ Leonardo.ai APIキーが有効
3. ✅ ネットワーク接続（プロキシ設定）
4. ✅ ディスク容量（ubuntu-latest は十分）
5. ✅ Python 3.11 対応（requirements.txt 確認）

---

**次のステップ:**
1. ✅ Actions タブで "Generate Leonardo.ai Assets" を探す
2. ✅ "Run workflow" をクリック
3. ✅ 実行ログを確認
4. ✅ 自動コミットされたアセットを確認

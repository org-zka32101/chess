# 将棋式ランキングシステム ガイド
## Shogi Ranking System - Complete Guide

---

## 概要 | Overview

Chess Tactics Master では、ELO レーティングと将棋の段位システムを組み合わせたハイブリッドランキングシステムを採用しています。

**Hybrid System Benefits:**
- 🎯 **正確な技術測定**: ELO レーティングで正確にスキル差を計測
- 📊 **直感的な表示**: 将棋の段位で分かりやすくランクを表示
- 🏆 **進捗の可視化**: 次のランクまでの進行度をリアルタイムで確認
- 🎮 **ゲーム融合**: 各ゲーム後に自動更新

---

## ランク体系 | Rank System

### 級位 (Kyu Levels) - 初級者向け
初心者から中級者手前までの段階

| 級位 | ELO 範囲 | 説明 |
|------|---------|------|
| 20級 | < 500 | ビギナー - 最初の一歩 |
| 15級 | 500-600 | ビギナー - 基本学習中 |
| 10級 | 600-700 | 初心者 - 基本をマスター |
| 5級 | 700-800 | 初心者中級 - 戦術理解 |
| 3級 | 800-900 | 初心者上級 - 戦略構築 |
| 1級 | 900-1200 | 初心者上級 - 段への準備 |

### 段位 (Dan Levels) - 上級者向け
中級者から最高段階までの段階

| 段位 | ELO 範囲 | 説明 |
|------|---------|------|
| 1段 | 900-1000 | 初段 - 初級上級者 |
| 2段 | 1000-1100 | 初段 - 中級者入門 |
| 3段 | 1100-1200 | 初段 - 中級者 |
| 4段 | 1200-1400 | 中段者 - 上級者入門 |
| 5段 | 1400-1550 | 中段者 - 上級者 |
| 6段 | 1550-1750 | 高段者 - 上級者 |
| 7段 | 1750-1900 | 高段者 - エキスパート |
| 8段 | 1900+ | プロ棋士レベル - 最高段階 |

---

## ELO から将棋ランクへの変換
## ELO to Shogi Rank Conversion

### 計算方法 | Calculation Method

```
ELO レーティング → 将棋段位計算
  ↓
ShogiRankService.calculateRank(int eloRating)
  ↓
1. ELO を各段位のしきい値と比較
2. 該当する段位/級位を決定
3. ShogiRank オブジェクトを返却
```

### 例 | Examples

```dart
// 600 ELO → 10級
ShogiRankService.calculateRank(600)  
// Result: ShogiRank.kyu(10)
// Display: "10級"

// 1000 ELO → 2段
ShogiRankService.calculateRank(1000) 
// Result: ShogiRank.dan(2)
// Display: "2段"

// 1800 ELO → 7段
ShogiRankService.calculateRank(1800) 
// Result: ShogiRank.dan(7)
// Display: "7段"
```

---

## UI コンポーネント | UI Components

### 1. ShogiRankDisplay
ユーザーの段位を表示するウィジェット

**機能:**
- コンパクトモード: バッジ表示
- フルモード: 詳細説明付き表示
- 段位に応じた色分け
- カスタムテキストスタイル対応

**使用例:**
```dart
// フルモード表示
ShogiRankDisplay(
  rank: ShogiRank.dan(5),
  eloRating: 1550,
  compact: false,
)

// コンパクトモード表示
ShogiRankDisplay(
  rank: ShogiRank.dan(5),
  eloRating: 1550,
  compact: true,
)
```

### 2. ShogiRankProgressBar
次のランクまでの進行度を表示

**機能:**
- リニアプログレスバー表示
- 進行度パーセンテージ表示
- 段位に応じた色分け
- ラベルの有無選択可能

**使用例:**
```dart
ShogiRankProgressBar(
  currentRank: ShogiRank.dan(5),
  eloRating: 1550,
  showLabel: true,
)
```

### 3. ShogiRankComparison
2 人のプレイヤーの段位比較表示（対戦相手との比較に最適）

**機能:**
- 左右比較表示
- プレイヤー名表示
- 段位説明文表示
- 視覚的な対比

**使用例:**
```dart
ShogiRankComparison(
  player1Name: 'Alice',
  player1Rank: ShogiRank.dan(5),
  player2Name: 'Bob',
  player2Rank: ShogiRank.dan(6),
)
```

---

## ゲーム後の段位更新 | Rank Update After Game

### プロセス | Process

```
Game Completed
  ↓
1. ELO 変化を計算 (K-factor: 32)
2. 新しい ELO = 現在の ELO + ELO 変化
3. 新しい段位 = calculateRank(新しい ELO)
4. Firestore に更新
5. UI に反映
```

### 例 | Example

**ゲーム前:**
- プレイヤー A: 1500 ELO → 5段
- プレイヤー B: 1600 ELO → 6段

**ゲーム結果:** プレイヤー A が勝利

**ELO 変化:**
- A: +21 (予想外の勝利ボーナス)
- B: -21

**ゲーム後:**
- プレイヤー A: 1521 ELO → 5段 (進行度アップ)
- プレイヤー B: 1579 ELO → 6段 (進行度ダウン)

---

## 色の意味 | Color Meanings

### 級位の色
- **20-15級**: 薄緑（`#B7E4C7`）- ビギナー
- **10-5級**: 中緑（`#74C69D`）- 初心者
- **3-1級**: 濃緑（`#52B788`）- 初心者上級

### 段位の色
- **1-2段**: 青（`#1982C4`）- 初段
- **3-4段**: 紫（`#6A4C93`）- 中段
- **5段**: 紫（`#6A4C93`）- 中段者
- **6段**: 銅色（`#CD7F32`）- 高段者
- **7段**: 銀色（`#C0C0C0`）- エキスパート
- **8段**: 金色（`#FFD700`）- プロ棋士

---

## テスト | Tests

### ユニットテスト (50+ cases)
- `test/services/shogi_rank_service_test.dart`

**テスト項目:**
- ✅ ELO から段位への変換
- ✅ 段位閾値の検証
- ✅ 進行度計算
- ✅ JSON シリアライズ
- ✅ 表示名生成
- ✅ 説明テキスト生成
- ✅ 段位比較
- ✅ 段位の進行

### 統合テスト (12 cases)
- `integration_test/shogi_ranking_flow_test.dart`

**テスト項目:**
- ✅ プロフィール表示
- ✅ 段位バッジスタイル
- ✅ 進行度バー表示
- ✅ マッチング相手の段位表示
- ✅ ゲーム前の段位比較
- ✅ ゲーム結果での段位変更
- ✅ 段位履歴アクセス
- ✅ レスポンシブデザイン

---

## API リファレンス | API Reference

### ShogiRankService

#### calculateRank(int eloRating) → ShogiRank
ELO レーティングから将棋段位を計算

```dart
final rank = ShogiRankService.calculateRank(1500);
// Returns: ShogiRank.dan(5)
```

#### displayName(ShogiRank rank) → String
段位の表示名を取得（例: "5段", "3級"）

```dart
final name = ShogiRankService.displayName(ShogiRank.dan(5));
// Returns: "5段"
```

#### getDescription(ShogiRank rank) → String
段位の説明文を取得

```dart
final desc = ShogiRankService.getDescription(ShogiRank.dan(5));
// Returns: "中段者 - 上級者"
```

#### progressToNextRank(int eloRating, ShogiRank currentRank) → double
次のランクまでの進行度（0.0 ～ 1.0）を計算

```dart
final progress = ShogiRankService.progressToNextRank(1550, ShogiRank.dan(5));
// Returns: 0.5 (50% progress to next rank)
```

---

## ユーザー機能 | User Features

### プロフィール画面
- 現在の ELO レーティング表示
- 現在の将棋段位表示
- 次のランクまでの進行度
- 段位の説明文

### ゲーム結果画面
- ゲーム前の段位比較
- 獲得 ELO ポイント
- 新しい段位（段位上昇時）
- 進行度の更新

### ランキング画面
- ユーザーの段位別ソート
- プレイヤー比較機能
- 段位の色分け表示

---

## 開発者向けガイド | Developer Guide

### 新しい段位を追加する
`ShogiRankService` の閾値を修正：

```dart
static const int newThreshold = 2000;

if (eloRating >= newThreshold) {
  return ShogiRank.dan(9);
}
```

### カスタム色を追加する
`ShogiRankDisplay` の `_getRankColor()` メソッドを修正

### 段位説明を翻訳する
`ShogiRankService.getDescription()` に言語分岐を追加

---

## ベストプラクティス | Best Practices

### 段位の取得
```dart
// ✅ 正しい方法
final rank = ShogiRankService.calculateRank(eloRating);

// ❌ 避けるべき
// 直接段位オブジェクトを作成しない
```

### UI での表示
```dart
// ✅ 正しい方法 - 専用ウィジェットを使用
ShogiRankDisplay(rank: rank, eloRating: eloRating)

// ❌ 避けるべき
// 手動で表示名を生成しない
Text(ShogiRankService.displayName(rank))
```

### データベース保存
```dart
// ✅ 正しい方法 - JSON シリアライズ
'shogiRank': rank.toJson()

// ❌ 避けるべき
// 文字列で直接保存しない
'shogiRank': ShogiRankService.displayName(rank)
```

---

## FAQ

### Q: ELO と将棋段位の関係は？
A: ELO は正確な実数スコア、将棋段位はユーザーフレンドリーなレベル表示です。  
ELO 変化 → 自動的に段位も更新されます。

### Q: ランクは下がることもある？
A: はい。ELO レーティングが下がれば、段位も下がる可能性があります。  
ただし実装で段位の下降を制限することも可能です。

### Q: 段位の進行速度は？
A: ELO 変化とゲーム数に依存します。  
勝率 50% で安定している場合、段位の変更は数十ゲームごとです。

### Q: オフラインでも段位は計算される？
A: オンラインゲームの結果のみで更新されます。  
CPU との対戦では ELO/段位は更新されません。

---

## トラブルシューティング | Troubleshooting

### 段位が表示されない
- ✅ Firestore で shogiRank フィールドが存在するか確認
- ✅ コード生成が完了しているか確認（`dart run build_runner build`）
- ✅ 古いデータの場合、マイグレーション実行

### 進行度が100%で止まった
- ✅ ELO レーティングが更新されているか確認
- ✅ Firestore の同期状態を確認
- ✅ キャッシュをクリアしてリロード

---

## 技術仕様 | Technical Specifications

**ファイル構成:**
- `lib/src/services/shogi_rank_service.dart` - ロジック
- `lib/src/models/user.dart` - データモデル
- `lib/src/widgets/shogi_rank_display.dart` - UI コンポーネント
- `lib/src/providers/online_game_provider.dart` - 更新ロジック
- `test/services/shogi_rank_service_test.dart` - ユニットテスト
- `integration_test/shogi_ranking_flow_test.dart` - 統合テスト

**依存性:**
- Freezed - データクラスとシリアライズ
- Flutter Riverpod - 状態管理
- Cloud Firestore - データベース

**パフォーマンス:**
- 段位計算: O(1) - 定数時間
- UI 更新: 即座 - リアルタイム同期
- データベース: 段位ごとにキャッシュ可能

---

**Last Updated:** 2026-08-26  
**Status:** ✅ Production Ready  
**Coverage:** 50+ Unit Tests, 12 Integration Tests

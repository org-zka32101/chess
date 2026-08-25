# Chess Tactics Master - オンライン対局機能 詳細設計書

**版**: 1.0  
**作成日**: 2026-08-25  
**著者**: Design Team  
**ステータス**: 詳細設計フェーズ

---

## 目次
1. [プロジェクト概要](#プロジェクト概要)
2. [MVP Must 6 スコープ](#mvp-must-6-スコープ)
3. [データモデル](#データモデル)
4. [アーキテクチャ設計](#アーキテクチャ設計)
5. [Cloud Functions](#cloud-functions)
6. [実装フェーズ](#実装フェーズ)
7. [UI/UX 設計](#uiux-設計)
8. [統合ポイント](#統合ポイント)

---

## プロジェクト概要

### 既存機能（5機能）
| # | 機能名 | 概要 |
|---|--------|--------|
| 1 | 基本タクティクス学習 | パズル形式の戦術問題の解答 |
| 2 | ユーザー認証 | Firebase Auth による認証管理 |
| 3 | プログレス追跡 | ユーザーの学習進度、スコア管理 |
| 4 | CPU対局 | AI相手の対局シミュレーション |
| 5 | レーティングシステム | 個別レーティング計算・表示 |

### MVP Must 6: オンライン対局（新規）
ユーザー同士がリアルタイムで対局でき、マッチメイキング、リアルタイム同期、レーティング更新を備えた機能

---

## MVP Must 6 スコープ

### 機能範囲
```
┌─────────────────────────────────┐
│  オンライン対局機能（Phase C'） │
├─────────────────────────────────┤
│ [必須]                          │
│  • マッチメイキング（Rating） │
│  • リアルタイム盤面同期         │
│  • ゲームタイムアウト処理       │
│  • ドロップ/放棄処理            │
│  • 対人戦ELO計算                │
│  • ゲーム履歴記録               │
│                                 │
│ [オプション・Phase D以降]       │
│  • 友人招待機能                 │
│  • チャット機能                 │
│  • ゲーム観戦機能               │
│  • リプレイ・分析機能           │
└─────────────────────────────────┘
```

### 既存機能との統合箇所
| 既存機能 | 統合内容 | 連携方法 |
|---------|----------|--------|
| ユーザー認証 | マッチメイキング時の本人確認 | `/auth` から `uid` 取得 |
| プログレス追跡 | ゲーム結果の記録 | `userProgress` に対局結果追加 |
| レーティングシステム | 対人戦ELO更新 | 既存ELO計算式を拡張 |
| CPU対局 | ゲーム状態管理の再利用 | `gameState` スキーマを統一 |
| 基本認証・セッション | リアルタイム接続管理 | Firebase UID で認証 |

---

## データモデル

### Firestore コレクション設計

#### 1. `games` コレクション（アクティブ・対局）
**用途**: 現在進行中の対局、マッチング後のゲーム情報

```
collection: games
├── document: {gameId}
│   ├── gameId: string (auto-generated)
│   ├── type: "online_pvp" | "online_rapid" | "online_blitz"
│   ├── status: "matchmaking" | "active" | "completed" | "abandoned"
│   ├── createdAt: timestamp
│   ├── startedAt: timestamp (マッチング完了時刻)
│   ├── endedAt: timestamp | null
│   │
│   ├── [プレイヤー情報]
│   ├── whitePlayerId: string (Firebase UID)
│   ├── blackPlayerId: string (Firebase UID)
│   ├── whitePlayerName: string
│   ├── blackPlayerName: string
│   ├── whiteRating: number (マッチング時のレーティング)
│   ├── blackRating: number
│   │
│   ├── [ゲーム状態]
│   ├── pgn: string (PGN形式の全手数)
│   ├── currentFen: string (現在のボード状態)
│   ├── moves: array<{
│   │     moveNumber: number,
│   │     from: string (e2-e4形式),
│   │     to: string,
│   │     promotion?: string,
│   │     timestamp: timestamp,
│   │     playerId: string
│   │   }>
│   │
│   ├── [タイムコントロール]
│   ├── timeControl: "10min" | "5min" | "3min" (例)
│   ├── timeControlMs: number (ミリ秒)
│   ├── whiteTimeRemainingMs: number
│   ├── blackTimeRemainingMs: number
│   ├── lastMoveTimestamp: timestamp
│   ├── whiteLastActivityTimestamp: timestamp
│   ├── blackLastActivityTimestamp: timestamp
│   │
│   ├── [ゲーム結果]
│   ├── result: "white_win" | "black_win" | "draw" | null
│   ├── resultReason: "checkmate" | "resignation" | "timeout" | "draw_agreement" | "abandonment" | null
│   ├── abandonedBy: string | null (ドロップしたプレイヤーID)
│   │
│   ├── [レーティング変動]
│   ├── whiteRatingDelta: number | null
│   ├── blackRatingDelta: number | null
│   ├── whiteNewRating: number | null
│   └── blackNewRating: number | null
```

**インデックス設定**:
- `status, createdAt` (複合インデックス)
- `whitePlayerId, status`
- `blackPlayerId, status`

---

#### 2. `matchmakingQueue` コレクション（マッチメイキング待機中）
**用途**: マッチメイキング待機中のプレイヤー管理

```
collection: matchmakingQueue
├── document: {queueId}
│   ├── queueId: string (auto-generated)
│   ├── playerId: string (Firebase UID)
│   ├── playerName: string
│   ├── currentRating: number
│   ├── ratingRange: {
│   │     min: number,
│   │     max: number
│   │   }
│   ├── timeControlType: "10min" | "5min" | "3min"
│   ├── queuedAt: timestamp
│   ├── timeoutAt: timestamp (30秒後がデフォルト)
│   ├── priority: number (待機時間に基づいて計算)
│   ├── status: "waiting" | "matched" | "expired"
│   ├── matchedGameId: string | null
│   ├── matchedOpponentId: string | null
│   └── color: "white" | "black" | "random"
```

**インデックス設定**:
- `status, queuedAt`
- `currentRating, status`
- `timeControlType, status`

**実装時のシャード戦略**: Rating帯ごとにサブコレクションシャーディング
```
matchmakingQueue
├── rating_1000_1200/
│   └── {queueId}
├── rating_1200_1400/
│   └── {queueId}
└── rating_1400_1600/
    └── {queueId}
```

---

#### 3. `userPresence` コレクション（オンラインステータス）
**用途**: リアルタイムユーザープレゼンス管理

```
collection: userPresence
├── document: {playerId}  (Firebase UID)
│   ├── playerId: string
│   ├── isOnline: boolean
│   ├── lastSeenAt: timestamp
│   ├── currentActivity: "idle" | "matchmaking" | "in_game" | "studying"
│   ├── currentGameId: string | null
│   ├── connectionStatus: "connected" | "disconnected"
│   ├── deviceInfo: {
│   │     type: "web" | "ios" | "android",
│   │     lastActivity: timestamp
│   │   }
│   └── ttl: number (Firestore TTL機能で自動削除)
```

**Realtime Database ミラー**: オンラインステータスはRealtime DBでも同期
```
/presences/{playerId} (Realtime DB)
├── isOnline: boolean
├── lastSeenAt: number (Unix timestamp in ms)
├── currentGameId: string | null
└── connectionState: "connected" | "disconnected"
```

---

#### 4. `gameInvitations` コレクション（友人招待・オプション）
**用途**: Phase D 以降の招待機能向け

```
collection: gameInvitations
├── document: {invitationId}
│   ├── invitationId: string
│   ├── fromPlayerId: string
│   ├── toPlayerId: string
│   ├── toPlayerEmail: string
│   ├── status: "pending" | "accepted" | "declined" | "expired"
│   ├── timeControlType: "10min" | "5min" | "3min"
│   ├── createdAt: timestamp
│   ├── expiresAt: timestamp (24時間後)
│   ├── acceptedAt: timestamp | null
│   ├── associatedGameId: string | null
│   └── message: string (オプション)
```

---

#### 5. `gameHistory` サブコレクション（ユーザー毎のゲーム履歴）
**用途**: プレイヤー毎のゲーム履歴効率的取得

```
collection: users/{userId}/gameHistory
├── document: {gameId}
│   ├── gameId: string (参照: games/{gameId})
│   ├── opponentId: string
│   ├── opponentName: string
│   ├── opponentRating: number
│   ├── result: "win" | "loss" | "draw"
│   ├── ratingDelta: number
│   ├── newRating: number
│   ├── playedAt: timestamp
│   └── pgn: string
```

---

### Realtime Database 構造

**主要な役割**: リアルタイムの盤面同期とプレゼンス管理

```
/activeGames/{gameId}
├── currentFen: string
├── moves: [
│   {
│     moveNumber: number,
│     from: string,
│     to: string,
│     timestamp: number,
│     playerId: string
│   }
│ ]
├── whiteTimeRemainingMs: number
├── blackTimeRemainingMs: number
├── lastMoveTimestamp: number
├── lastUpdateTimestamp: number
└── status: "active" | "completed"

/presences/{playerId}
├── isOnline: boolean
├── lastSeenAt: number
├── currentGameId: string | null
└── connectionState: "connected" | "disconnected"

/gameChat/{gameId}  [Phase D以降]
└── messages: [
    {
      playerId: string,
      message: string,
      timestamp: number,
      isSystemMessage: boolean
    }
  ]
```

---

## アーキテクチャ設計

### 全体システム構成図

```
┌─────────────────────────────────────────────────────────────┐
│                        フロントエンド層                      │
│  (Web/iOS/Android)                                          │
│  • マッチメイキング画面                                       │
│  • オンライン対局画面                                         │
│  • プレイヤープロフィール                                     │
└──────────────────────┬──────────────────────────────────────┘
                       │
        ┌──────────────┼──────────────┐
        │              │              │
        ▼              ▼              ▼
   ┌─────────────┐ ┌──────────────┐ ┌──────────────┐
   │ Firebase    │ │ Realtime DB  │ │Cloud Storage │
   │ Auth        │ │              │ │ (Game PGN)   │
   │ Firestore   │ │ • activeGame │ │              │
   │             │ │ • presences  │ │              │
   │ • games     │ │ • chat (opt) │ │              │
   │ • users     │ │              │ │              │
   │ • queue     │ └──────────────┘ └──────────────┘
   └──────┬──────┘
          │
   ┌──────┴─────────────────────────┐
   │                                 │
   ▼                                 ▼
┌────────────────────────┐  ┌──────────────────────┐
│  Cloud Functions       │  │ Cloud Tasks          │
│  • matchmaking()       │  │ (タイムアウト処理)    │
│  • updateGameState()   │  │                      │
│  • finishGame()        │  │                      │
│  • updateRating()      │  │                      │
│  • handleTimeout()     │  │                      │
│  • presenceCleanup()   │  │                      │
└────────────────────────┘  └──────────────────────┘
```

---

### マッチメイキング戦略

#### フロー図

```
┌──────────────┐
│プレイヤーA    │ timeControl: 10min
│Rating: 1400  │ color: random
└──────┬───────┘
       │ Queue登録
       ▼
┌─────────────────────────────────┐
│matchmakingQueue に登録           │
├─────────────────────────────────┤
│ queuedAt: T                      │
│ rating: 1400                     │
│ ratingRange: [1250, 1550]       │
│ status: "waiting"                │
│ timeoutAt: T + 30s              │
└─────┬───────────────────────────┘
      │
      ▼ (リアルタイム watcher起動)
┌───────────────────────────────────┐
│matchmakingQueue の監視を開始       │
│ • 1秒ごとに Rating 昇順でスキャン │
│ • ratingRange 重複をチェック       │
│ • 最も古いプレイヤーを優先         │
└───┬─────────────────────────────┘
    │
    ▼ (10-15秒後)
┌──────────────────────────────────┐
│マッチング成功                     │
│• gameId 生成                      │
│• games コレクション作成            │
│• 両プレイヤーに gameId 通知        │
└──────────┬───────────────────────┘
           │
           ▼
┌─────────────────────────────────┐
│ゲーム開始                         │
│ • status: "active"               │
│ • startedAt: current time        │
│ • Realtime DBに同期開始          │
└─────────────────────────────────┘
```

#### マッチング条件

**Rating ベースマッチング**:
```javascript
// 基本的なマッチング条件（段階的に緩和）
{
  phase1: {
    duration: 5,      // 秒
    ratingRange: 50,  // ±50
  },
  phase2: {
    duration: 5,      // 秒
    ratingRange: 100, // ±100
  },
  phase3: {
    duration: 10,     // 秒
    ratingRange: 200, // ±200
  },
  phase4: {
    duration: 10,     // 秒
    ratingRange: 300, // ±300 (最終段階)
  }
}
```

**タイムコントロール マッチング**:
- 完全一致: 同じ timeControlType のみマッチ
- 例: "10min" は "5min" や "3min" とマッチしない

**優先度計算**:
```
priority = (currentTime - queuedAt) + (abs(myRating - opponentRating) * weight)
  where weight = 0.5 (待機時間を優先、Rating差は二次)
```

---

### リアルタイム同期戦略

#### Firestore vs Realtime DB の役割分担

| 用途 | Firestore | Realtime DB |
|-----|-----------|------------|
| 盤面状態 | 最終確定版 | リアルタイム同期 |
| 着手情報 | 永続記録 | ライブストリーム |
| 時間情報 | スナップショット | リアルタイム時間差分 |
| プレゼンス | スナップショット | ライブプレゼンス |
| ゲーム履歴 | 完全なログ | なし |

#### 盤面同期フロー

```
プレイヤーA: 着手実行 (e2-e4)
    ↓
[ローカル]
  • 盤面更新 (UI即座反映)
  • 時間コウント開始
    ↓
[Cloud Function: updateGameState]
  • 着手検証 (合法性チェック)
  • Firestore games/{gameId}/moves に記録
  • Realtime DB に最新 FEN 反映
  • whiteTimeRemainingMs を減少
  • checkmate/stalemate 判定
    ↓
[Realtime DB listener (プレイヤーB)]
  • 着手通知を受信 (100-200ms遅延)
  • ローカル盤面を更新
  • whiteTimeRemainingMs を反映
  • UI更新
```

#### タイムスタンプ管理

```
ゲーム状態では3つのタイムスタンプを管理：

1. Server timestamp (source of truth)
   ├── lastMoveTimestamp (最後の着手時刻)
   └── 目的: タイムアウト判定

2. Client-side prediction (フロントエンド)
   ├── ローカル時間カウント
   └── 目的: UI即座反映

3. Sync reconciliation (同期チェック)
   ├── 定期的(1秒毎)にサーバー時間と比較
   ├── ズレが大きい場合は再同期
   └── 目的: クライアントドリフト防止
```

---

### タイムアウト・ドロップ対策

#### タイムアウト処理

**検出方式**:
```
1. [Real-time check] (Realtime DB listener)
   • クライアント側でも時間経過を監視
   • timeRemaining < 0 になったら自動タイムアウト

2. [Server-side check] (Cloud Function)
   • 30秒ごとにアクティブゲームをスキャン
   • lastMoveTimestamp + timeControlMs の経過をチェック
   • 時間切れなら finishGame() をコール
```

**タイムアウト時の処理フロー**:
```
┌─────────────────┐
│タイムアウト検出  │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────┐
│ games/{gameId} の status を確認 │
│ • "active" なら処理続行         │
│ • すでに "completed" ならスキップ │
└────────┬────────────────────────┘
         │
         ▼
┌─────────────────────────────────┐
│ result = "timeout"              │
│ resultReason = "timeout"        │
│ abandonedBy = timeoutPlayerId   │
│ status = "completed"            │
│ endedAt = current time          │
└────────┬────────────────────────┘
         │
         ▼
┌──────────────────────────────┐
│ updateRating() を実行        │
│ (タイムアウトした側が負け扱い)│
└──────────────────────────────┘
```

#### 不正なドロップ検出

```
condition: 10秒以上の非応答かつ在線ステータスが lost

┌────────────────────────────────────────┐
│playerLastActivityTimestamp確認          │
│ • 現在時刻 - lastActivityTimestamp     │
│ • > 10秒かつ connectionState != "on"  │
└────────┬───────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────┐
│自動ドロップと判定                       │
│ • resultReason = "abandonment"         │
│ • abandonedBy = dropPlayerPlayerId     │
│ • rating更新 (負け扱い)                │
│ • penalty: -5 rating points           │
└────────────────────────────────────────┘
```

#### 再接続ハンドリング

```
┌────────────────────────┐
│プレイヤー再接続        │
└────────┬───────────────┘
         │
         ▼
┌────────────────────────────────────┐
│ gameState の一貫性チェック         │
│ • ローカル状態とサーバー状態の比較│
│ • 不一致の場合は自動修復           │
└────────┬───────────────────────────┘
         │
         ▼
┌────────────────────────────────────┐
│ Realtime DB から latest state 復帰│
│ • currentFen                       │
│ • whiteTimeRemainingMs             │
│ • blackTimeRemainingMs             │
│ • 全 moves の再播放                │
└────────┬───────────────────────────┘
         │
         ▼
┌────────────────────────────────────┐
│ UI復帰 - ゲーム継続                │
│ • タイムカウント再開               │
│ • 盤面再描画                       │
└────────────────────────────────────┘
```

---

## Cloud Functions

### 関数一覧と仕様

#### 1. `matchmakingWorker()` - マッチメイキング実行関数

**トリガー**: Cloud Tasks (定期実行, 1秒毎)

**入力**:
```typescript
{
  timeControlType: "10min" | "5min" | "3min"
}
```

**処理流れ**:
```
1. matchmakingQueue をRating順でクエリ (status="waiting")
2. 各time controlタイプごとに処理
3. プレイヤーペアを抽出 (Rating重複チェック)
4. マッチ条件をバリデーション
5. gameId を生成して games に新規ドキュメント作成
6. 両プレイヤーの queue status を "matched" に更新
7. matchedGameId を queue に記録
```

**疑似コード**:
```typescript
exports.matchmakingWorker = functions
  .runWith({ memory: "256MB", timeoutSeconds: 60 })
  .https.onRequest(async (req, res) => {
    const { timeControlType } = req.body;
    
    const queueSnapshot = await db.collection("matchmakingQueue")
      .where("status", "==", "waiting")
      .where("timeControlType", "==", timeControlType)
      .where("timeoutAt", ">", admin.firestore.Timestamp.now())
      .orderBy("timeoutAt", "asc") // 優先度順
      .limit(100)
      .get();
    
    const waitingPlayers = queueSnapshot.docs.map(doc => doc.data());
    
    // ペアリング
    for (let i = 0; i < waitingPlayers.length - 1; i += 2) {
      const playerA = waitingPlayers[i];
      const playerB = waitingPlayers[i + 1];
      
      if (isRatingMatch(playerA, playerB)) {
        await createGame(playerA, playerB, timeControlType);
        await updateQueueStatus(playerA.queueId, "matched");
        await updateQueueStatus(playerB.queueId, "matched");
      }
    }
    
    res.status(200).send("Matchmaking completed");
  });
```

**出力**: `{ success: true, matchedCount: number }`

---

#### 2. `updateGameState()` - ゲーム状態更新関数

**トリガー**: HTTP (フロントエンドから着手送信時)

**入力**:
```typescript
{
  gameId: string,
  playerId: string,
  moveData: {
    from: string,      // "e2"
    to: string,        // "e4"
    promotion?: string // "Q" | "R" | "B" | "N"
  },
  clientTimestamp: number
}
```

**処理流れ**:
```
1. gameId の存在確認
2. playerId が該当ゲームのプレイヤーか確認
3. gameStatus == "active" か確認
4. 着手の合法性チェック (chess.js)
5. タイムコントロール更新
6. Firestore games/{gameId}/moves に記録
7. currentFen を更新
8. checkmate/stalemate 判定
9. Realtime DB に最新状態をプッシュ
10. 相手プレイヤーに通知
```

**疑似コード**:
```typescript
exports.updateGameState = functions
  .runWith({ memory: "256MB", timeoutSeconds: 30 })
  .https.onCall(async (data, context) => {
    const { gameId, moveData, clientTimestamp } = data;
    const playerId = context.auth.uid;
    
    // ゲーム検証
    const gameDoc = await db.collection("games").doc(gameId).get();
    if (!gameDoc.exists || gameDoc.data().status !== "active") {
      throw new functions.https.HttpsError("not-found", "Game not found");
    }
    
    const game = gameDoc.data();
    if (game.whitePlayerId !== playerId && game.blackPlayerId !== playerId) {
      throw new functions.https.HttpsError("permission-denied", "Not a player");
    }
    
    // 着手検証
    const chess = new Chess(game.currentFen);
    const move = chess.move(moveData);
    if (!move) {
      throw new functions.https.HttpsError("invalid-argument", "Illegal move");
    }
    
    // タイムコントロール計算
    const timeRemaining = updateTimeControl(game, playerId, clientTimestamp);
    if (timeRemaining < 0) {
      // タイムアウト
      return await finishGame(gameId, playerId, "timeout");
    }
    
    // Firestore に着手記録
    await db.collection("games").doc(gameId).update({
      moves: admin.firestore.FieldValue.arrayUnion({
        moveNumber: game.moves.length + 1,
        from: moveData.from,
        to: moveData.to,
        timestamp: admin.firestore.Timestamp.now(),
        playerId
      }),
      currentFen: chess.fen(),
      [`${playerId === game.whitePlayerId ? "white" : "black"}TimeRemainingMs`]: timeRemaining,
      [`${playerId === game.whitePlayerId ? "white" : "black"}LastActivityTimestamp`]: admin.firestore.Timestamp.now()
    });
    
    // Realtime DB に同期
    const rtdb = admin.database();
    await rtdb.ref(`activeGames/${gameId}`).update({
      currentFen: chess.fen(),
      whiteTimeRemainingMs: ...,
      blackTimeRemainingMs: ...,
      lastMoveTimestamp: Date.now()
    });
    
    // ゲーム終了判定
    if (chess.game_over()) {
      return await finishGame(gameId, null, getDetermination(chess));
    }
    
    return { success: true, newFen: chess.fen() };
  });
```

**出力**: `{ success: true, newFen: string }`

---

#### 3. `finishGame()` - ゲーム終了・結果確定関数

**トリガー**: Cloud Function (updateGameState / handleTimeout から呼び出し)

**入力**:
```typescript
{
  gameId: string,
  result: "checkmate" | "resignation" | "timeout" | "draw_agreement" | "abandonment",
  resigningPlayerId?: string  // resignation / abandonment の場合のみ
}
```

**処理流れ**:
```
1. gameId の最終状態を取得
2. 結果を確定 (winner, loser)
3. result と resultReason を記録
4. status = "completed" に変更
5. endedAt = 現在時刻
6. updateRating() をコール
7. gameHistory にゲーム履歴を記録
8. 両プレイヤーに通知
9. Realtime DB の activeGames を削除
```

**疑似コード**:
```typescript
async function finishGame(gameId, result, resigningPlayerId = null) {
  const gameDoc = await db.collection("games").doc(gameId).get();
  const game = gameDoc.data();
  
  let winner, loser, ratingDelta;
  
  if (result === "checkmate") {
    const chess = new Chess(game.currentFen);
    winner = chess.turn() === "w" ? game.blackPlayerId : game.whitePlayerId;
    loser = chess.turn() === "w" ? game.whitePlayerId : game.blackPlayerId;
  } else if (result === "resignation" || result === "abandonment") {
    winner = resigningPlayerId === game.whitePlayerId ? game.blackPlayerId : game.whitePlayerId;
    loser = resigningPlayerId;
  } else if (result === "timeout") {
    // タイムアウトした側が負け
    ...
  } else if (result === "draw_agreement") {
    winner = null;
    loser = null;
  }
  
  // レーティング更新
  const ratingUpdate = await updateRating(game, winner, loser);
  
  // ゲーム完了
  await db.collection("games").doc(gameId).update({
    status: "completed",
    endedAt: admin.firestore.Timestamp.now(),
    result,
    [`${winner ? (winner === game.whitePlayerId ? "white" : "black") : "draw"}Win`]: true,
    whiteRatingDelta: ratingUpdate.whiteDelta,
    blackRatingDelta: ratingUpdate.blackDelta,
    whiteNewRating: ratingUpdate.whiteNew,
    blackNewRating: ratingUpdate.blackNew
  });
  
  // ゲーム履歴に記録
  await recordGameHistory(gameId, game, ratingUpdate);
  
  // Realtime DB から削除
  await admin.database().ref(`activeGames/${gameId}`).remove();
}
```

---

#### 4. `updateRating()` - レーティング更新関数

**トリガー**: finishGame() から呼び出し

**入力**:
```typescript
{
  gameId: string,
  whitePlayerId: string,
  blackPlayerId: string,
  result: "white_win" | "black_win" | "draw"
}
```

**ELO計算ロジック**:
```
公式: Ra' = Ra + K * (Sa - Ea)

where:
  Ra = プレイヤー A の現在レーティング
  K = K-ファクタ (rating 範囲に応じて 32/24/16)
    • rating >= 2400: K=16
    • rating >= 2000: K=24
    • rating < 2000: K=32
  Sa = 期待値
    • 1 (勝利)
    • 0 (敗北)
    • 0.5 (引き分け)
  Ea = 期待勝率
    • Ea = 1 / (1 + 10^((Rb - Ra)/400))

K-ファクタはオンラインレーティングでは調整可能
本実装では K=32 で統一（より変動を付ける）
```

**疑似コード**:
```typescript
function calculateELO(whiteRating, blackRating, result) {
  const K = 32; // オンライン対局向けの高変動性
  
  // 期待勝率
  const expectedWhite = 1 / (1 + Math.pow(10, (blackRating - whiteRating) / 400));
  const expectedBlack = 1 / (1 + Math.pow(10, (whiteRating - blackRating) / 400));
  
  // 実際の成績
  let Sa, Sb;
  if (result === "white_win") {
    Sa = 1; Sb = 0;
  } else if (result === "black_win") {
    Sa = 0; Sb = 1;
  } else { // draw
    Sa = 0.5; Sb = 0.5;
  }
  
  // 新レーティング
  const newWhiteRating = whiteRating + K * (Sa - expectedWhite);
  const newBlackRating = blackRating + K * (Sb - expectedBlack);
  
  return {
    whiteDelta: Math.round(newWhiteRating - whiteRating),
    blackDelta: Math.round(newBlackRating - blackRating),
    whiteNew: Math.round(newWhiteRating),
    blackNew: Math.round(newBlackRating)
  };
}
```

**出力**:
```typescript
{
  whiteDelta: number,
  blackDelta: number,
  whiteNew: number,
  blackNew: number
}
```

---

#### 5. `handleGameTimeout()` - タイムアウト検出関数

**トリガー**: Cloud Tasks (30秒毎)

**処理流れ**:
```
1. status = "active" のゲームを全て取得
2. 各ゲームについて:
   a. 現在時刻とlastMoveTimestamp を比較
   b. 経過時間 > timeControlMs なら処理
   c. finishGame(gameId, "timeout") をコール
```

**疑似コード**:
```typescript
exports.handleGameTimeout = functions
  .runWith({ memory: "256MB", timeoutSeconds: 60 })
  .pubsub.schedule("every 30 seconds").onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();
    const activeGames = await db.collection("games")
      .where("status", "==", "active")
      .get();
    
    for (const doc of activeGames.docs) {
      const game = doc.data();
      
      // white の時間確認
      if (game.whiteTimeRemainingMs <= 0) {
        await finishGame(doc.id, "timeout");
        continue;
      }
      
      // black の時間確認
      if (game.blackTimeRemainingMs <= 0) {
        await finishGame(doc.id, "timeout");
      }
    }
  });
```

---

#### 6. `presenceCleanup()` - プレゼンス自動クリーンアップ関数

**トリガー**: Cloud Tasks (5分毎)

**処理流れ**:
```
1. userPresence で lastSeenAt が30分以上前のドキュメントを削除
2. Realtime DB の presences も同期削除
3. 要件: TTL設定で自動削除も併用
```

**疑似コード**:
```typescript
exports.presenceCleanup = functions
  .runWith({ memory: "256MB", timeoutSeconds: 120 })
  .pubsub.schedule("every 5 minutes").onRun(async (context) => {
    const cutoffTime = admin.firestore.Timestamp.now();
    cutoffTime.setMinutes(cutoffTime.getMinutes() - 30);
    
    const stalePresences = await db.collection("userPresence")
      .where("lastSeenAt", "<", cutoffTime)
      .get();
    
    const batch = db.batch();
    for (const doc of stalePresences.docs) {
      batch.delete(doc.ref);
      // Realtime DB からも削除
      await admin.database().ref(`presences/${doc.id}`).remove();
    }
    
    await batch.commit();
  });
```

---

#### 7. `updateUserPresence()` - ユーザープレゼンス更新関数

**トリガー**: HTTP (クライアント接続/切断時)

**入力**:
```typescript
{
  action: "online" | "offline",
  currentGameId?: string
}
```

**処理**:
```typescript
exports.updateUserPresence = functions
  .runWith({ memory: "256MB", timeoutSeconds: 10 })
  .https.onCall(async (data, context) => {
    const playerId = context.auth.uid;
    const { action, currentGameId } = data;
    
    if (action === "online") {
      await db.collection("userPresence").doc(playerId).set({
        playerId,
        isOnline: true,
        currentActivity: currentGameId ? "in_game" : "idle",
        currentGameId: currentGameId || null,
        connectionStatus: "connected",
        lastSeenAt: admin.firestore.Timestamp.now()
      }, { merge: true });
      
      // Realtime DB にも反映
      await admin.database().ref(`presences/${playerId}`).set({
        isOnline: true,
        currentGameId: currentGameId || null,
        connectionState: "connected",
        lastSeenAt: Date.now()
      });
    } else {
      await db.collection("userPresence").doc(playerId).update({
        isOnline: false,
        connectionStatus: "disconnected",
        lastSeenAt: admin.firestore.Timestamp.now()
      });
      
      await admin.database().ref(`presences/${playerId}`).update({
        isOnline: false,
        connectionState: "disconnected",
        lastSeenAt: Date.now()
      });
    }
    
    return { success: true };
  });
```

---

### デプロイ・構成

**Cloud Tasks スケジュール**:
| Function | トリガー | 間隔 |
|---------|---------|------|
| matchmakingWorker | Cloud Tasks | 1秒 |
| handleGameTimeout | Pub/Sub | 30秒 |
| presenceCleanup | Pub/Sub | 5分 |

**環境変数**:
```env
CHESS_DB_NAME=chess-db          # Firestore DB
RTDB_URL=https://chess-*.rtdb.firebaseio.com
K_FACTOR=32
MATCHMAKING_TIMEOUT_SEC=30
GAME_TIMEOUT_THRESHOLD_SEC=60
```

---

## 実装フェーズ

### フェーズ全体の再構成

```
┌─────────────────────────────────────────────────────────────────┐
│                    Phase A: 基盤構築（既存）                    │
├─────────────────────────────────────────────────────────────────┤
│ • Firebase プロジェクト初期化                                   │
│ • Firestore & Realtime DB スキーマ設計                         │
│ • Firebase Authentication セットアップ                          │
│ • ユーザープロフィール管理                                       │
│ • 基本レーティング計算                                           │
└─────────────────────────────────────────────────────────────────┘
                          ↓ (3-4週間)

┌─────────────────────────────────────────────────────────────────┐
│                    Phase B: UI基盤（既存）                      │
├─────────────────────────────────────────────────────────────────┤
│ • フロントエンド初期化 (React / React Native)                  │
│ • 基本ナビゲーション構造                                         │
│ • ユーザー認証UI                                                 │
│ • プロフィール画面                                               │
└─────────────────────────────────────────────────────────────────┘
                          ↓ (2-3週間)

┌─────────────────────────────────────────────────────────────────┐
│              Phase C: CPU対局機能（既存）                       │
├─────────────────────────────────────────────────────────────────┤
│ • chess.js ライブラリ統合                                       │
│ • ゲーム状態管理                                                 │
│ • AI エンジン統合 (Stockfish等)                                 │
│ • ゲーム画面UI                                                   │
│ • ゲーム履歴記録                                                 │
└─────────────────────────────────────────────────────────────────┘
                          ↓ (4-5週間)

          ╔════════════════════════════════════════════╗
          ║  Phase C' & Phase C は並行実装も可能      ║
          ╚════════════════════════════════════════════╝

┌─────────────────────────────────────────────────────────────────┐
│          Phase C': オンライン対局（新規・本設計書）             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ Week 1-2: データモデル & Cloud Functions                       │
│  • matchmakingQueue コレクション作成                            │
│  • activeGames コレクション作成                                 │
│  • userPresence コレクション作成                                │
│  • matchmakingWorker() 実装                                      │
│  • updateGameState() 実装                                        │
│  • finishGame() 実装                                             │
│                                                                 │
│ Week 3: マッチメイキングUI実装                                 │
│  • マッチメイキング画面                                         │
│  • 待機中のアニメーション                                       │
│  • キャンセル機能                                               │
│  • 相手プレイヤー情報表示                                       │
│                                                                 │
│ Week 4: リアルタイム同期実装                                   │
│  • Realtime DB listener 実装                                    │
│  • 盤面リアルタイム更新                                         │
│  • 時間カウント実装                                             │
│  • タイムアウト処理                                             │
│                                                                 │
│ Week 5: テスト & 最適化                                         │
│  • 統合テスト                                                   │
│  • パフォーマンステスト                                         │
│  • 遅延環境テスト                                               │
│  • バグ修正                                                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                          ↓ (5-6週間)

┌─────────────────────────────────────────────────────────────────┐
│                   Phase D: UI/UX最適化                          │
├─────────────────────────────────────────────────────────────────┤
│ • オンライン対局UI改善                                          │
│ • ゲーム振り返し機能                                             │
│ • プレイヤーランキング                                           │
│ • 通知機能                                                       │
│ • ダークモード対応                                               │
└─────────────────────────────────────────────────────────────────┘
                          ↓ (3週間)

┌─────────────────────────────────────────────────────────────────┐
│                Phase E: 社会機能（オプション）                  │
├─────────────────────────────────────────────────────────────────┤
│ • 友人招待機能                                                   │
│ • インゲームチャット                                             │
│ • ゲーム観戦機能                                                 │
│ • リプレイ・分析機能                                             │
└─────────────────────────────────────────────────────────────────┘
                          ↓ (4週間)

┌─────────────────────────────────────────────────────────────────┐
│            Phase F: マネタイズ・最適化                          │
├─────────────────────────────────────────────────────────────────┤
│ • サブスクリプション実装                                         │
│ • 広告統合                                                       │
│ • A/B テスト                                                     │
│ • パフォーマンス最適化                                           │
│ • セキュリティ監査                                               │
└─────────────────────────────────────────────────────────────────┘
```

### Phase C' 詳細スケジュール

#### Week 1-2: バックエンド基盤

```
Day 1-2: データモデル実装
 ├── Firestore collections 作成
 │   ├── games
 │   ├── matchmakingQueue
 │   ├── userPresence
 │   └── gameHistory
 ├── インデックス定義
 └── Realtime DB 構造作成

Day 3: Cloud Functions 骨組み
 ├── プロジェクト構成
 ├── 依存関係インストール
 └── デプロイスクリプト作成

Day 4-5: matchmakingWorker 実装
 ├── キューの読み込みロジック
 ├── マッチング条件判定
 ├── ゲーム作成ロジック
 └── ユニットテスト

Day 6: updateGameState 実装
 ├── 着手検証 (chess.js)
 ├── 時間更新
 ├── 状態同期
 └── テスト

Day 7: finishGame & updateRating 実装
 ├── 結果判定ロジック
 ├── ELO計算
 ├── 履歴記録
 └── テスト

Day 8-10: その他の関数実装
 ├── handleGameTimeout
 ├── presenceCleanup
 ├── updateUserPresence
 └── 統合テスト

Day 11: バックエンド テスト & 修正
 ├── E2E テスト
 ├── 負荷テスト
 └── バグ修正
```

#### Week 3: マッチメイキングUI

```
Day 1-2: マッチメイキング画面デザイン
 ├── UI/UX コンポーネント設計
 ├── プロトタイプ作成
 └── デザイン検証

Day 3-4: マッチメイキングUI実装
 ├── React コンポーネント作成
 ├── State管理実装
 ├── アニメーション追加
 └── レスポンシブ対応

Day 5: 相手プレイヤー情報表示
 ├── プレイヤーカード表示
 ├── レーティング表示
 ├── 統計情報表示
 └── UI 統合

Day 6-7: キャンセル・エラーハンドリング
 ├── キャンセル機能実装
 ├── タイムアウト通知
 ├── エラーメッセージ
 └── テスト
```

#### Week 4: リアルタイム同期

```
Day 1-2: Realtime DB listener 実装
 ├── アクティブゲーム監視
 ├── 盤面更新リスナー
 ├── 状態変更トリガー
 └── テスト

Day 3-4: クライアントサイド同期
 ├── ローカル状態管理
 ├── サーバー状態との照合
 ├── 競合解決ロジック
 └── テスト

Day 5-6: 時間カウント実装
 ├── クライアント側時間管理
 ├── サーバー時間との同期
 ├── タイムアウト検出
 └── テスト

Day 7: 再接続ハンドリング
 ├── オフライン検出
 ├── 状態復帰ロジック
 ├── 再同期処理
 └── テスト
```

#### Week 5: テスト & 最適化

```
Day 1-2: ユニット・統合テスト
 ├── Cloud Functions テスト
 ├── API テスト
 ├── UI テスト
 └── バグ修正

Day 3-4: パフォーマンステスト
 ├── 負荷テスト (100同時接続)
 ├── レイテンシー測定
 ├── Firestore クエリ最適化
 └── 結果分析

Day 5: ネットワーク遅延テスト
 ├── 低速ネットワーク環境
 ├── パケットロス環境
 ├── 断続的接続
 └── 修正

Day 6-7: 本番前最終テスト
 ├── E2E テスト
 ├── セキュリティテスト
 ├── 本番環境チェック
 └── ドキュメント作成
```

---

## UI/UX 設計

### 1. マッチメイキング画面

```
┌────────────────────────────────┐
│  Chess Tactics Master          │
│  オンライン対局                  │
├────────────────────────────────┤
│                                │
│  ┌──────────────────────────┐  │
│  │ マッチメイキング中...    │  │
│  │ ⟲ (回転アニメーション)   │  │
│  └──────────────────────────┘  │
│                                │
│  待機時間: 15秒                │
│                                │
│  ┌──────────────────────────┐  │
│  │  時間帯                   │  │
│  │  ○ 10分（古典的）         │  │
│  │  ○ 5分（ラピッド）        │  │
│  │  ● 3分（ブリッツ）        │  │
│  └──────────────────────────┘  │
│                                │
│  ┌────────────────────────────┐│
│  │  [キャンセル]              ││
│  └────────────────────────────┘│
│                                │
└────────────────────────────────┘

状態遷移:
WAITING → MATCHED → GAME_START
  ↓
  CANCELLED / TIMEOUT
```

**要素**:
- 待機中アニメーション (Lottie or CSS animation)
- 待機時間カウントダウン
- タイムコントロール選択表示
- キャンセルボタン (赤色, prominent)
- プログレスバー (オプション)

**アクセシビリティ**:
- 音声通知 (マッチング成功時)
- スクリーンリーダー対応
- 高コントラスト対応

---

### 2. マッチング成功画面

```
┌────────────────────────────────┐
│  マッチング成功！               │
├────────────────────────────────┤
│                                │
│  対戦相手: AlexChess            │
│  ━━━━━━━━━━━━━━━━━━━━━━━━  │
│  レーティング: 1450  ◀ 1420 ▶ │
│  勝率: 52%           勝率: 48% │
│                                │
│  あなた: 白   vs   黒: 相手     │
│                                │
│  ┌────────────────────────────┐│
│  │  [ゲーム開始]  [キャンセル] ││
│  └────────────────────────────┘│
│                                │
└────────────────────────────────┘
```

**要素**:
- 相手プレイヤー名
- 相手レーティング (自分のレーティングとの差分表示)
- 相手勝率 / 統計
- 配色選択表示 (白/黒)
- ゲーム開始ボタン
- キャンセルボタン (小)

**ステータス**:
- マッチング成功後は 10秒以内にゲーム開始
- タイムアウト時は自動キャンセル

---

### 3. オンライン対局画面

```
┌────────────────────────────────────┐
│  AlexChess (黒)    Rating: 1450    │
│  ┌──────┐ 残り時間: 2:45           │
│  │ ◆◆◆ │                           │
│  │◆◆◆◆◆│                          │
│  │◆◆◆◆◆│                          │
│  │◆ ◆◆◆│                          │
│  │◆◆◆◆◆│                          │
│  │◆◆◆◆◆│                          │
│  │ ◆◆◆◆│                          │
│  └──────┘                           │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                    │
│  [盤面エリア (8x8)]                 │
│                                    │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│  あなた (白)       残り時間: 3:12  │
│  Rating: 1420                      │
│                                    │
│  最終手: e2-e4 (14秒前)             │
│                                    │
│  ┌─────────────────────────────┐  │
│  │  [投了]  [中止]  [引き分け]   │  │
│  └─────────────────────────────┘  │
│                                    │
│  着手履歴:                          │
│  1. e2-e4 e7-e5                   │
│  2. Nf3 Nc6                       │
│                                    │
└────────────────────────────────────┘
```

**レイアウト**:
- 上部: 相手プレイヤー情報 + 時間
- 中央: 8x8 チェスボード
- 下部: 自分の情報 + コントロール
- 右側: 着手履歴 (オプション)

**インタラクション**:
- ドラッグ&ドロップで着手
- タップで駒を選択
- ダブルタップで自動移動 (推奨マス)
- 長押しで駒情報表示

**時間表示**:
- 数字表示 (MM:SS)
- 色で警告 (残り1分で橙, 30秒で赤)
- 点滅アニメーション (5秒以下)

---

### 4. ゲーム終了画面

```
┌────────────────────────────────────┐
│  ゲーム終了                         │
├────────────────────────────────────┤
│                                    │
│  あなたが勝利しました！             │
│                                    │
│  ┌──────────────────────────────┐ │
│  │ Rating: 1420  →  1438  (+18) │ │
│  │                              │ │
│  │ AlexChess: 1450  →  1432 (-18)│ │
│  └──────────────────────────────┘ │
│                                    │
│  終了理由: チェックメイト            │
│                                    │
│  対局時間: 12分 34秒               │
│  あなたの着手数: 28                 │
│  相手の着手数: 27                   │
│                                    │
│  ┌────────────────────────────────┐│
│  │  [リプレイを見る]                ││
│  │  [再対局]  [メインに戻る]        ││
│  └────────────────────────────────┘│
│                                    │
└────────────────────────────────────┘
```

**表示項目**:
- 勝敗結果
- レーティング変動 (±表示)
- 対局の終了理由
- 対局統計 (時間, 着手数)
- PGN のエクスポート (オプション)

**アクション**:
- リプレイ (前の対局を再生)
- 再対局 (同じ相手と)
- 分析 (AI分析、Phase E以降)
- メイン画面に戻る

---

### 5. プレイヤープロフィール（拡張）

**オンライン対局統計タブ**:
```
┌────────────────────────────────┐
│  AlexChess                      │
│  レーティング: 1450             │
├────────────────────────────────┤
│  オンライン対局                  │
│                                │
│  対戦数:     42                │
│  勝 利:     24 (57%)           │
│  敗 北:     15 (36%)           │
│  引き分け:    3 (7%)            │
│                                │
│  最高レーティング: 1520          │
│  最低レーティング: 1320          │
│                                │
│  グラフ: Rating 推移 (30日)     │
│  ┌──────────────────────────────┐
│  │  ▲                            │
│  │  │  ▲  ▲ ▲                  │
│  │  │ ▲ ▲ ▲ ▲ ▲               │
│  │  │▲ ▲ ▲ ▲ ▲ ▲              │
│  │ ▲▲ ▲ ▲ ▲ ▲ ▲               │
│  └──────────────────────────────┘
│                                │
│  最近の対局: 2時間前             │
│                                │
└────────────────────────────────┘
```

---

### 6. 通知と警告

**タイムアウト警告**:
```
┌─────────────────────────────────┐
│ ⚠️  時間が残り30秒です             │
│                                 │
│ あなたの残り時間: 0:30           │
│ ┌───────────────────────────────┐│
│ │ ▓▓░░░░░░░░░░░░░░░░░░░░░░░░ ││
│ └───────────────────────────────┘│
│                                 │
│           [承知]                 │
└─────────────────────────────────┘
```

**相手との切断検出**:
```
┌─────────────────────────────────┐
│ ⟲ 相手が切断しました               │
│   再接続を待機中...               │
│                                 │
│ 待機時間: 2分 15秒                │
│ (3分でゲーム終了)                 │
│                                 │
│          [待機を中止]             │
└─────────────────────────────────┘
```

---

## 統合ポイント

### 既存機能との連携

#### 1. ユーザー認証との連携
```
認証流 → Profile作成 → マッチメイキング可能
  ↓
Firebase UID が matchmakingQueue のプレイヤーID
```

#### 2. プログレス追跡との統合
```
ゲーム終了
  ↓
gameHistory に記録
  ↓
users/{userId}/stats に統計更新
  ↓
プロフィール画面に表示
```

**スキーマ統一**:
```
gameState: {
  gameId: string,
  type: "cpu" | "online_pvp",
  ...共通フィールド
}
```

#### 3. レーティングシステムの拡張
```
既存: CPU対局レーティング (games_cpu_rating)
新規: オンライン対戦レーティング (rating_online)

プロフィール表示:
├── CPU レーティング: 1600
└── オンライン レーティング: 1420  ← 本設計で新規追加
```

#### 4. ゲーム分析機能との再利用
```
既存: CPU対局の PGN 保存
新規: オンライン対局の PGN 保存

分析エンジンは両方に対応可能
```

---

## セキュリティ考慮事項

### 1. Firestore セキュリティルール
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // ゲーム読み取り: プレイヤーのみ
    match /games/{gameId} {
      allow read: if request.auth.uid == resource.data.whitePlayerId
                   || request.auth.uid == resource.data.blackPlayerId;
      allow write: if false; // Cloud Functions のみ
    }
    
    // キュー書き込み: 認証済みユーザーのみ
    match /matchmakingQueue/{queueId} {
      allow create: if request.auth != null;
      allow read, delete: if request.auth.uid == resource.data.playerId;
      allow write: if false;
    }
    
    // プレゼンス: 自分のみ書き込み可
    match /userPresence/{userId} {
      allow read: if true; // 他ユーザーのステータスは見える
      allow write: if request.auth.uid == userId;
    }
  }
}
```

### 2. チート防止
- すべての着手検証は Cloud Functions で実行
- クライアント側の検証は UI/UX のためのみ
- PGN に全ての着手とタイムスタンプを記録

### 3. レーティング操作防止
- 同一ユーザーとの短時間の複数対局をトラッキング
- 疑わしい行動パターン検出
- ELO計算は サーバー側のみで実行

---

## パフォーマンス・スケーラビリティ

### 期待値
- 同時ゲーム数: 1,000+
- QPS (クエリ/秒): 500+
- p99 レイテンシ: < 200ms

### Firestore コスト最適化
```
読み取り最適化:
├── 複合インデックスの適切な使用
├── ページネーション実装
└── キャッシング戦略

書き込み最適化:
├── バッチ書き込み
├── Realtime DB へのオフロード
└── データ正規化
```

### Realtime DB 最適化
```
アクティブゲーム数に応じたシャーディング:
└── /activeGames/{gameId}
    └── 各ゲームは最大 5KB 以下
```

---

## まとめ

このオンライン対局機能は、既存の5つの機能を活かしつつ、リアルタイム対人戦を実現する包括的な設計です。

**主な特徴**:
✓ スケーラブルなマッチメイキング  
✓ 低レイテンシのリアルタイム同期  
✓ 堅牢なタイムアウト・ドロップ処理  
✓ 対人戦専用 ELO レーティング  
✓ Phase C と並行実装可能  

**推定開発期間**: 5-6週間  
**チームサイズ**: 2-3名 (バックエンド2名, フロントエンド1名推奨)

---

**版履歴**
| 版 | 日付 | 変更内容 |
|----|------|--------|
| 1.0 | 2026-08-25 | 初版作成 |


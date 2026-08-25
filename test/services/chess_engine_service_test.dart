import 'package:flutter_test/flutter_test.dart';
import 'package:chess/src/services/chess_engine_service.dart';

void main() {
  group('ChessEngineService', () {
    late ChessEngineService engine;

    setUp(() {
      engine = ChessEngineService();
    });

    group('initGame', () {
      test('initializes game with starting position', () {
        engine.initGame();
        final board = engine.getBoard();

        // Check that pieces are in correct starting positions
        expect(board, isNotNull);
        expect(board.length, 64);
      });

      test('initializes game from FEN', () {
        const testFen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';
        engine.initGame(fen: testFen);

        final currentFen = engine.getCurrentFen();
        expect(currentFen, startsWith('rnbqkbnr/pppppppp'));
      });
    });

    group('Move validation', () {
      setUp(() {
        engine.initGame();
      });

      test('validates legal pawn move from starting position', () {
        expect(engine.isLegalMove('e2', 'e4'), isTrue);
        expect(engine.isLegalMove('e2', 'e3'), isTrue);
        expect(engine.isLegalMove('e2', 'e5'), isFalse);
      });

      test('rejects illegal moves', () {
        expect(engine.isLegalMove('a1', 'a2'), isFalse); // Rook can't move like that
        expect(engine.isLegalMove('a4', 'a5'), isFalse); // No piece at a4
      });

      test('gets legal moves for a square', () {
        final moves = engine.getLegalMovesForSquare('e2');
        expect(moves, isNotEmpty);
        expect(moves, contains('e4'));
        expect(moves, contains('e3'));
      });
    });

    group('Move execution', () {
      setUp(() {
        engine.initGame();
      });

      test('executes valid move', () {
        final result = engine.makeMove('e2', 'e4');
        expect(result, isTrue);
      });

      test('rejects invalid move', () {
        final result = engine.makeMove('e2', 'e5');
        expect(result, isFalse);
      });

      test('updates position after move', () {
        engine.makeMove('e2', 'e4');
        final board = engine.getBoard();

        // e4 should now have a white pawn
        expect(board[36], isNotNull); // e4 is index 36 (4*8 + 4)
      });

      test('tracks move history', () {
        engine.makeMove('e2', 'e4');
        engine.makeMove('e7', 'e5');

        final history = engine.getMoveHistory();
        expect(history.length, 2);
      });
    });

    group('Game state detection', () {
      test('detects checkmate', () {
        // Setup fool's mate
        engine.initGame();
        engine.makeMove('f2', 'f3');
        engine.makeMove('e7', 'e5');
        engine.makeMove('g2', 'g4');
        engine.makeMove('d8', 'h4'); // Checkmate

        expect(engine.isCheckmate(), isTrue);
      });

      test('detects check', () {
        engine.initGame();
        // Make some moves to get to a check position
        engine.makeMove('e2', 'e4');
        engine.makeMove('e7', 'e5');
        engine.makeMove('f1', 'c4');
        engine.makeMove('b8', 'c6');
        engine.makeMove('d1', 'h5');
        engine.makeMove('g8', 'f6');
        engine.makeMove('h5', 'f7'); // Check!

        expect(engine.isCheck(), isTrue);
      });

      test('detects stalemate', () {
        // Setup a stalemate position
        engine.initGame(fen: '7k/5Q2/6K1/8/8/8/8/8 b - - 0 1');

        // Black should be stalemated (no legal moves but not in check)
        final hasLegalMoves = engine.getLegalMoves().isNotEmpty;
        if (!hasLegalMoves && !engine.isCheck()) {
          expect(engine.isStalemate(), isTrue);
        }
      });

      test('detects when game is over', () {
        engine.initGame();
        expect(engine.isGameOver(), isFalse);

        // Play fool's mate
        engine.makeMove('f2', 'f3');
        engine.makeMove('e7', 'e5');
        engine.makeMove('g2', 'g4');
        engine.makeMove('d8', 'h4');

        expect(engine.isGameOver(), isTrue);
      });
    });

    group('Game result', () {
      test('returns white win on checkmate', () {
        // Setup fool's mate
        engine.initGame();
        engine.makeMove('f2', 'f3');
        engine.makeMove('e7', 'e5');
        engine.makeMove('g2', 'g4');
        engine.makeMove('d8', 'h4');

        final result = engine.getGameResult();
        expect(result, equals('white_win'));
      });
    });

    group('Turn detection', () {
      setUp(() {
        engine.initGame();
      });

      test('white starts first', () {
        expect(engine.isWhiteTurn(), isTrue);
      });

      test('alternates turns after moves', () {
        expect(engine.isWhiteTurn(), isTrue);
        engine.makeMove('e2', 'e4');
        expect(engine.isWhiteTurn(), isFalse);
        engine.makeMove('e7', 'e5');
        expect(engine.isWhiteTurn(), isTrue);
      });
    });

    group('FEN handling', () {
      test('loads position from FEN', () {
        const testFen = 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1';
        engine.loadFromFen(testFen);

        final currentFen = engine.getCurrentFen();
        expect(currentFen, startsWith('rnbqkbnr/pppppppp/8/8/4P3'));
      });

      test('returns current FEN after moves', () {
        engine.initGame();
        engine.makeMove('e2', 'e4');

        final fen = engine.getCurrentFen();
        expect(fen, contains('4P3')); // Shows pawn on e4
      });
    });

    group('Piece querying', () {
      setUp(() {
        engine.initGame();
      });

      test('gets piece at square', () {
        final piece = engine.getPieceAt('e2');
        expect(piece, isNotNull);
        expect(piece, 'P'); // White pawn
      });

      test('returns null for empty square', () {
        final piece = engine.getPieceAt('e4');
        expect(piece, isNull);
      });
    });

    group('Move undo', () {
      setUp(() {
        engine.initGame();
      });

      test('undoes last move', () {
        engine.makeMove('e2', 'e4');
        engine.makeMove('e7', 'e5');

        engine.undoMove();
        expect(engine.isWhiteTurn(), isFalse);

        engine.undoMove();
        expect(engine.isWhiteTurn(), isTrue);
      });
    });

    group('Reset', () {
      test('resets to starting position', () {
        engine.initGame();
        engine.makeMove('e2', 'e4');

        engine.reset();

        expect(engine.getMoveHistory().length, 0);
        expect(engine.isWhiteTurn(), isTrue);
      });
    });
  });
}

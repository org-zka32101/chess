import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chess_lib;

/// Display captured pieces for both sides
class CapturedPieces extends StatelessWidget {
  final List<chess_lib.Piece> whiteCapturedPieces;
  final List<chess_lib.Piece> blackCapturedPieces;

  const CapturedPieces({
    Key? key,
    required this.whiteCapturedPieces,
    required this.blackCapturedPieces,
  }) : super(key: key);

  /// Get material value for a piece
  int _getMaterialValue(chess_lib.Piece piece) {
    switch (piece.type) {
      case chess_lib.PieceType.pawn:
        return 1;
      case chess_lib.PieceType.knight:
        return 3;
      case chess_lib.PieceType.bishop:
        return 3;
      case chess_lib.PieceType.rook:
        return 5;
      case chess_lib.PieceType.queen:
        return 9;
      case chess_lib.PieceType.king:
        return 0;
    }
  }

  /// Calculate total material value
  int _calculateMaterialValue(List<chess_lib.Piece> pieces) {
    return pieces.fold(0, (sum, piece) => sum + _getMaterialValue(piece));
  }

  /// Get symbol for display
  String _getSymbol(chess_lib.Piece piece) {
    return piece.type.symbol.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final whiteMaterial = _calculateMaterialValue(whiteCapturedPieces);
    final blackMaterial = _calculateMaterialValue(blackCapturedPieces);
    final materialDifference = (whiteMaterial - blackMaterial).abs();
    final isWhiteAdvantage = whiteMaterial > blackMaterial;

    return Column(
      children: [
        // Black captured pieces (displayed at top)
        if (blackCapturedPieces.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Wrap(
              spacing: 4,
              children: blackCapturedPieces.map((piece) {
                return Chip(
                  label: Text(_getSymbol(piece)),
                  avatar: CircleAvatar(
                    backgroundColor: Colors.grey[700],
                    child: Text(
                      _getSymbol(piece),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  backgroundColor: Colors.grey[300],
                );
              }).toList(),
            ),
          ),

        // Material advantage indicator
        if (materialDifference > 0)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isWhiteAdvantage ? Colors.grey[300] : Colors.grey[700],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isWhiteAdvantage ? '+$materialDifference' : '-$materialDifference',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isWhiteAdvantage ? Colors.black : Colors.white,
                ),
              ),
            ),
          ),

        // White captured pieces (displayed at bottom)
        if (whiteCapturedPieces.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Wrap(
              spacing: 4,
              children: whiteCapturedPieces.map((piece) {
                return Chip(
                  label: Text(_getSymbol(piece)),
                  avatar: CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    child: Text(
                      _getSymbol(piece),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  backgroundColor: Colors.grey[100],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

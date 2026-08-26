import 'package:freezed_annotation/freezed_annotation.dart';
import '../services/shogi_rank_service.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// Custom JSON converter for ShogiRank
class _ShogiRankConverter implements JsonConverter<ShogiRank, Object> {
  const _ShogiRankConverter();

  @override
  ShogiRank fromJson(Object json) {
    if (json is String) {
      return ShogiRankService.parseRank(json);
    }
    return ShogiRank.dan(1); // Default: 1st dan
  }

  @override
  Object toJson(ShogiRank value) => value.displayName();
}

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String uid,
    required String email,
    String? displayName,
    String? photoUrl,
    @Default(false) bool emailVerified,
    @Default(0) int rating,
    @Default(0) int onlineRating,
    @Default(0) int puzzlesSolved,
    @Default(0) int gamesPlayed,
    @Default(0) int wins,
    @Default(0) int losses,
    @Default(0) int draws,
    @_ShogiRankConverter() ShogiRank? shogiRank,
    DateTime? createdAt,
    DateTime? lastSignInAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

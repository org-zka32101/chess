import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

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
    DateTime? createdAt,
    DateTime? lastSignInAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

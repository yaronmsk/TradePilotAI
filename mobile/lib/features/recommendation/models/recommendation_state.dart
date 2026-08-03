import 'recommendation.dart';

enum RecommendationStatus { initial, analyzing, ready, error }

class RecommendationState {
  const RecommendationState({
    this.status = RecommendationStatus.initial,
    this.recommendation,
    this.errorMessage,
  });

  final RecommendationStatus status;
  final Recommendation? recommendation;
  final String? errorMessage;

  bool get isInitial => status == RecommendationStatus.initial;

  bool get isAnalyzing => status == RecommendationStatus.analyzing;

  bool get isReady => status == RecommendationStatus.ready;

  bool get hasError => status == RecommendationStatus.error;

  RecommendationState copyWith({
    RecommendationStatus? status,
    Recommendation? recommendation,
    String? errorMessage,
    bool clearRecommendation = false,
    bool clearError = false,
  }) {
    return RecommendationState(
      status: status ?? this.status,
      recommendation: clearRecommendation
          ? null
          : recommendation ?? this.recommendation,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

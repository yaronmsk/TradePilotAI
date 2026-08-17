import '../context/recommendation_analysis_context.dart';
import '../context/stock_behavior_profile.dart';
import 'recommendation.dart';

enum RecommendationStatus { initial, analyzing, ready, error }

class RecommendationState {
  const RecommendationState({
    this.status = RecommendationStatus.initial,
    this.recommendation,
    this.stockBehaviorProfile,
    this.analysisContext,
    this.errorMessage,
  });

  final RecommendationStatus status;
  final Recommendation? recommendation;
  final StockBehaviorProfile? stockBehaviorProfile;
  final RecommendationAnalysisContext? analysisContext;
  final String? errorMessage;

  bool get isInitial => status == RecommendationStatus.initial;

  bool get isAnalyzing => status == RecommendationStatus.analyzing;

  bool get isReady => status == RecommendationStatus.ready;

  bool get hasError => status == RecommendationStatus.error;

  RecommendationState copyWith({
    RecommendationStatus? status,
    Recommendation? recommendation,
    StockBehaviorProfile? stockBehaviorProfile,
    RecommendationAnalysisContext? analysisContext,
    String? errorMessage,
    bool clearRecommendation = false,
    bool clearStockBehaviorProfile = false,
    bool clearAnalysisContext = false,
    bool clearError = false,
  }) {
    return RecommendationState(
      status: status ?? this.status,
      recommendation: clearRecommendation
          ? null
          : recommendation ?? this.recommendation,
      stockBehaviorProfile: clearStockBehaviorProfile
          ? null
          : stockBehaviorProfile ?? this.stockBehaviorProfile,
      analysisContext: clearAnalysisContext
          ? null
          : analysisContext ?? this.analysisContext,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

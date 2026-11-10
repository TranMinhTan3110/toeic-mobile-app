import 'user_vocabulary_progress.dart';
import 'engagement_result_model.dart';

class UpdateProgressResult {
  final UserVocabularyProgress progress;
  final EngagementResultModel? engagement;

  UpdateProgressResult({
    required this.progress,
    this.engagement,
  });

  factory UpdateProgressResult.fromJson(Map<String, dynamic> json) {
    // Để an toàn với cả camelCase và PascalCase từ BE
    final progressData = json['progress'] ?? json['Progress'];
    final engagementData = json['engagement'] ?? json['Engagement'];

    return UpdateProgressResult(
      progress: UserVocabularyProgress.fromJson(progressData ?? {}),
      engagement: engagementData != null
          ? EngagementResultModel.fromJson(engagementData)
          : null,
    );
  }
}

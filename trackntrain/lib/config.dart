

class AppConfig{
  static const String aiUrl=String.fromEnvironment(
    'AI_INSIGHTS_URL',
    defaultValue: 'https://trackntrain-ai-insights.onrender.com/ai/meal-suggestion',
  );
  static const String deletionUrl=String.fromEnvironment(
    'USER_DELETION_URL',
    defaultValue: 'https://trackntrain-ai-insights.onrender.com/ai/delete-user',
  );
}
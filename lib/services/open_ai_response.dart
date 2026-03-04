class OpenAIResponse {
  final String content;
  final String model;

  OpenAIResponse({required this.content, required this.model});

  // Factory para converter o JSON da API em um objeto Dart
  factory OpenAIResponse.fromJson(Map<String, dynamic> json) {
    return OpenAIResponse(
      content: json['choices'][0]['message']['content'] ?? '',
      model: json['model'] ?? '',
    );
  }
}
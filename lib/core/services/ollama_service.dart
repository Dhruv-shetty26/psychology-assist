import 'dart:convert';
import 'dart:io';

class OllamaService {
  static const defaultQuantizedModel = 'llama3.2:1b-instruct-q4_K_M';

  final Uri endpoint;
  final String model;

  const OllamaService({
    required this.endpoint,
    this.model = defaultQuantizedModel,
  });

  Future<String> summarize({
    required String prompt,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final client = HttpClient()..connectionTimeout = timeout;
    try {
      final request = await client.postUrl(endpoint);
      request.headers.contentType = ContentType.json;
      request.write(
        jsonEncode({
          'model': model,
          'prompt': prompt,
          'stream': false,
          'options': {
            'temperature': 0.4,
            'num_predict': 220,
            'num_ctx': 2048,
          },
        }),
      );
      final response = await request.close().timeout(timeout);
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException('Ollama returned ${response.statusCode}: $body');
      }
      final data = jsonDecode(body) as Map<String, dynamic>;
      return data['response'] as String? ?? '';
    } finally {
      client.close(force: true);
    }
  }
}

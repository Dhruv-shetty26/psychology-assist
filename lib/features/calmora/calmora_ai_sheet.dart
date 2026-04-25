import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/app_state.dart';
import '../../core/services/ollama_service.dart';

class CalmoraAiSheet extends ConsumerStatefulWidget {
  const CalmoraAiSheet({super.key});

  @override
  ConsumerState<CalmoraAiSheet> createState() => _CalmoraAiSheetState();
}

class _CalmoraAiSheetState extends ConsumerState<CalmoraAiSheet> {
  final _controller = TextEditingController();
  final _endpoint = Uri.parse('http://10.16.209.73:8000/chat');
  String _chatHistory = 'CalmoraAI: Hello! I am CalmoraAI, your privacy-focused assistant. How can I support you today?\n\n';
  String _aiContext = 'You are Calmora, a concise mental wellness assistant. Be warm, practical, non-clinical, and suggest emergency help for crisis risk.\n\n';
  bool _loading = false;
  final String _selectedModel = OllamaService.defaultQuantizedModel;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<String> _queryOllama(String prompt) async {
    final ai = OllamaService(endpoint: _endpoint);
    return await ai.summarize(prompt: prompt);
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading) {
      return;
    }
    
    setState(() {
      _loading = true;
      _chatHistory += 'You: $text\n\n';
    });
    
    _controller.clear();

    try {
      _aiContext += 'User: $text\nCalmoraAI:';
      final response = await _queryOllama(_aiContext);
      
      final replyText = response.trim().isEmpty
          ? 'I could not generate a useful response. Try again in a moment.'
          : response.trim();
          
      _aiContext += ' $replyText\n\n';
      setState(() => _chatHistory += 'CalmoraAI: $replyText\n\n');
    } catch (_) {
      final mockResponse = _generateMockResponse(text);
      final errorNote = '(Quantized model is configured for $_selectedModel, but Ollama is not reachable. Start Ollama on port 8000 or update the endpoint.)';
      final fullReply = '$mockResponse\n\n$errorNote';
      
      _aiContext += ' $fullReply\n\n';
      setState(() => _chatHistory += 'CalmoraAI: $fullReply\n\n');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String _generateMockResponse(String userInput) {
    final input = userInput.toLowerCase();
    if (input.contains('sad') || input.contains('depressed')) {
      return 'I\'m sorry you\'re feeling down. Try a 4-7-8 breathing exercise: Inhale for 4 seconds, hold for 7, exhale for 8. If this persists, consider talking to a professional.';
    } else if (input.contains('anxious') || input.contains('worried')) {
      return 'Anxiety can be tough. Ground yourself by naming 5 things you can see, 4 you can touch, 3 you can hear, 2 you can smell, and 1 you can taste.';
    } else if (input.contains('happy') || input.contains('good')) {
      return 'That\'s great to hear! Keep nurturing positive moments. What\'s one thing that made you smile today?';
    } else if (input.contains('exercise') || input.contains('workout')) {
      return 'Physical activity is excellent for mental health. Even a 10-minute walk can boost your mood. What\'s your favorite way to move?';
    } else if (input.contains('sleep')) {
      return 'Good sleep is crucial. Try maintaining a consistent bedtime routine and avoiding screens an hour before bed.';
    } else {
      return 'Thanks for sharing. Remember, it\'s okay to not be okay. If you need immediate help, contact a crisis hotline. What\'s on your mind right now?';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.2),
            blurRadius: 40,
            spreadRadius: 4,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            decoration: BoxDecoration(
              color: isDark 
                  ? scheme.surface.withValues(alpha: 0.65)
                  : scheme.surface.withValues(alpha: 0.85),
              border: Border.all(
                color: scheme.primary.withValues(alpha: 0.25),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Stack(
              children: [
                // Glowing orb background effect
                Positioned(
                  top: -50,
                  right: -50,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  scheme.primary.withValues(alpha: 0.8),
                                  scheme.tertiary.withValues(alpha: 0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: scheme.primary.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CalmoraAI',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                    foreground: Paint()..shader = LinearGradient(
                                      colors: [scheme.primary, scheme.tertiary],
                                    ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                                  ),
                                ),
                                Text(
                                  'Privacy-Focused Chatbot',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: scheme.onSurface.withValues(alpha: 0.6),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(
                              Icons.close,
                              color: scheme.onSurface.withValues(alpha: 0.4),
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: scheme.onSurface.withValues(alpha: 0.05),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Response area
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 120, maxHeight: 250),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark 
                              ? Colors.black.withValues(alpha: 0.2)
                              : Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: scheme.onSurface.withValues(alpha: 0.05),
                          ),
                        ),
                        child: _loading
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: scheme.primary,
                                    strokeWidth: 3,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Mixing the masalas together for the perfect dish',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: scheme.onSurface.withValues(alpha: 0.5),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              )
                            : SingleChildScrollView(
                                child: Text(
                                  _chatHistory.trim(),
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    height: 1.6,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 20),
                      // Input
                      Container(
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _controller,
                          minLines: 1,
                          maxLines: 4,
                          style: theme.textTheme.bodyMedium,
                          decoration: InputDecoration(
                            hintText: 'Type your message...',
                            hintStyle: TextStyle(color: scheme.onSurface.withValues(alpha: 0.4)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: IconButton(
                                tooltip: 'Send securely',
                                onPressed: _send,
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: scheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ),
                          onSubmitted: (_) => _send(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

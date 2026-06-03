import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:provider/provider.dart';
import '../../services/firebase_service.dart';
import '../../core/theme.dart';

class VoiceSuggestionView extends StatefulWidget {
  const VoiceSuggestionView({super.key});

  @override
  State<VoiceSuggestionView> createState() => _VoiceSuggestionViewState();
}

class _VoiceSuggestionViewState extends State<VoiceSuggestionView> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isSpeechAvailable = false;
  String _transcriptionText = "";
  final TextEditingController _textController = TextEditingController();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  void _initSpeech() async {
    _isSpeechAvailable = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (errorNotification) {
        debugPrint('Speech Error: $errorNotification');
        setState(() => _isListening = false);
      },
    );
    setState(() {});
  }

  @override
  void dispose() {
    _speech.stop();
    _textController.dispose();
    super.dispose();
  }

  void _listen() async {
    if (!_isSpeechAvailable) {
      bool available = await _speech.initialize();
      if (!available) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reconocimiento de voz no disponible o sin permisos.')),
          );
        }
        return;
      }
      _isSpeechAvailable = true;
    }

    if (!_isListening) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) {
          setState(() {
            _transcriptionText = val.recognizedWords;
            _textController.text = _transcriptionText;
          });
        },
        listenOptions: stt.SpeechListenOptions(localeId: 'es_ES'),
      );
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _submitSuggestion() async {
    final textToSend = _textController.text.trim();
    if (textToSend.isEmpty) return;

    setState(() {
      _isUploading = true;
    });

    // Send to Firebase
    final firebaseService = context.read<FirebaseService>();
    await firebaseService.submitSuggestion(textToSend);

    setState(() {
      _isUploading = false;
      _transcriptionText = "";
      _textController.clear();
    });

    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.green),
              SizedBox(width: 8),
              Text("¡Gracias!"),
            ],
          ),
          content: const Text("Tu sugerencia ha sido recibida y será tomada en cuenta para mejorar la app."),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text("Cerrar", style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: const Text("Buzón de Sugerencias", style: TextStyle(color: AppTheme.darkPurple, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey.withValues(alpha: 0.1))),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.darkPurple, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppTheme.lightPurple,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.record_voice_over_rounded, size: 80, color: AppTheme.primaryColor),
              ),
              const SizedBox(height: 32),
              const Text(
                "Dinos cómo podemos mejorar",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.darkPurple, height: 1.2),
              ),
              const SizedBox(height: 12),
              const Text(
                "Toca el micrófono y empieza a hablar. Tu voz se convertirá en texto automáticamente.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 40),

              // Recording Button
              GestureDetector(
                onTap: _listen,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: EdgeInsets.all(_isListening ? 36 : 24),
                  decoration: BoxDecoration(
                    color: _isListening ? Colors.redAccent : AppTheme.primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_isListening ? Colors.redAccent : AppTheme.primaryColor).withValues(alpha: 0.3),
                        blurRadius: _isListening ? 30 : 15,
                        spreadRadius: _isListening ? 10 : 0,
                      )
                    ],
                  ),
                  child: Icon(
                    _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isListening ? "Escuchando... Toca para detener" : "Toca para empezar a hablar",
                style: TextStyle(
                  color: _isListening ? Colors.redAccent : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 40),

              // TextField for Transcription
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: AppTheme.darkPurple.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))],
                ),
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _textController,
                  maxLines: 5,
                  onChanged: (value) {
                    setState(() {}); // Rebuild to show the submit button if needed
                  },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Tu sugerencia aparecerá aquí, o si prefieres, simplemente escríbela...",
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),

              // Submit button
              if (_textController.text.isNotEmpty || _transcriptionText.isNotEmpty)
                _isUploading
                    ? const CircularProgressIndicator(color: AppTheme.primaryColor)
                    : ElevatedButton.icon(
                        onPressed: _submitSuggestion,
                        icon: const Icon(Icons.send_rounded),
                        label: const Text("Enviar Sugerencia"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                          elevation: 0,
                        ),
                      ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrServiceResult {
  const OcrServiceResult({required this.success, this.text, this.errorMessage});

  final bool success;
  final String? text;
  final String? errorMessage;
}

class OcrService {
  bool get isSupportedPlatform => !kIsWeb;

  Future<OcrServiceResult> extractText({required String imagePath}) async {
    if (!isSupportedPlatform) {
      return const OcrServiceResult(
        success: false,
        errorMessage:
            'OCR local ML Kit non disponible sur Flutter Web. Lance l application sur Android/iOS.',
      );
    }
    return _extractWithMlKit(imagePath);
  }

  Future<OcrServiceResult> _extractWithMlKit(String imagePath) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final result = await textRecognizer.processImage(inputImage);
      final extractedText = result.text.trim();

      if (extractedText.isEmpty) {
        return const OcrServiceResult(
          success: false,
          errorMessage: 'Aucun texte detecte sur cette image.',
        );
      }

      return OcrServiceResult(success: true, text: extractedText);
    } catch (_) {
      return const OcrServiceResult(
        success: false,
        errorMessage: 'Erreur lors du traitement OCR.',
      );
    } finally {
      await textRecognizer.close();
    }
  }
}

import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Supported languages for Voice Q&A
enum VoiceLanguage { english, hindi, kannada }

/// Kannada regional dialect zones
enum KannadaDialect {
  mysore, // Bengaluru, Mysore, Mandya, Hassan — standard literary Kannada
  northKarnataka, // Belgaum, Hubli, Dharwad, Gadag — Marathi-influenced
  coastal, // Mangalore, Udupi — Tulu-influenced
  hyderabadKarnataka, // Raichur, Bellary, Gulbarga, Bidar — Urdu-influenced
}

/// Service that manages TTS (text-to-speech) and STT (speech-to-text)
/// with multilingual support, human-like voice, and Kannada dialect awareness.
class VoiceService {
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _stt = stt.SpeechToText();

  VoiceLanguage _language = VoiceLanguage.english;
  KannadaDialect _dialect = KannadaDialect.mysore;
  bool _sttAvailable = false;
  String? _detectedCity;

  VoiceLanguage get language => _language;
  KannadaDialect get dialect => _dialect;
  String? get detectedCity => _detectedCity;
  bool get isSttAvailable => _sttAvailable;

  // ── Region-to-dialect mapping ──
  static const Map<String, KannadaDialect> _cityDialectMap = {
    // North Karnataka
    'belgaum': KannadaDialect.northKarnataka,
    'belagavi': KannadaDialect.northKarnataka,
    'hubli': KannadaDialect.northKarnataka,
    'dharwad': KannadaDialect.northKarnataka,
    'gadag': KannadaDialect.northKarnataka,
    'haveri': KannadaDialect.northKarnataka,
    'bagalkot': KannadaDialect.northKarnataka,
    'vijayapura': KannadaDialect.northKarnataka,
    'bijapur': KannadaDialect.northKarnataka,
    // Coastal Karnataka
    'mangalore': KannadaDialect.coastal,
    'mangaluru': KannadaDialect.coastal,
    'udupi': KannadaDialect.coastal,
    'karwar': KannadaDialect.coastal,
    'uttara kannada': KannadaDialect.coastal,
    // Hyderabad-Karnataka
    'raichur': KannadaDialect.hyderabadKarnataka,
    'bellary': KannadaDialect.hyderabadKarnataka,
    'ballari': KannadaDialect.hyderabadKarnataka,
    'gulbarga': KannadaDialect.hyderabadKarnataka,
    'kalaburagi': KannadaDialect.hyderabadKarnataka,
    'bidar': KannadaDialect.hyderabadKarnataka,
    'koppal': KannadaDialect.hyderabadKarnataka,
    'yadgir': KannadaDialect.hyderabadKarnataka,
    // Old Mysore (default)
    'bangalore': KannadaDialect.mysore,
    'bengaluru': KannadaDialect.mysore,
    'mysore': KannadaDialect.mysore,
    'mysuru': KannadaDialect.mysore,
    'mandya': KannadaDialect.mysore,
    'hassan': KannadaDialect.mysore,
    'tumkur': KannadaDialect.mysore,
    'tumakuru': KannadaDialect.mysore,
    'kolar': KannadaDialect.mysore,
    'chitradurga': KannadaDialect.mysore,
    'shimoga': KannadaDialect.mysore,
    'shivamogga': KannadaDialect.mysore,
    'davanagere': KannadaDialect.mysore,
    'davangere': KannadaDialect.mysore,
    'ramanagara': KannadaDialect.mysore,
    'chikkamagaluru': KannadaDialect.mysore,
  };

  /// Initialize TTS + STT engines
  Future<void> init() async {
    // TTS setup — warm, natural voice
    await _tts.setSpeechRate(0.45); // Slightly slower for clarity
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.05); // Slightly warmer pitch

    // STT setup
    _sttAvailable = await _stt.initialize(
      onError: (error) {},
      onStatus: (status) {},
    );
  }

  /// Set language and configure engines
  Future<void> setLanguage(VoiceLanguage lang) async {
    _language = lang;
    String ttsLang;
    switch (lang) {
      case VoiceLanguage.english:
        ttsLang = 'en-IN'; // Indian English accent
        break;
      case VoiceLanguage.hindi:
        ttsLang = 'hi-IN';
        break;
      case VoiceLanguage.kannada:
        ttsLang = 'kn-IN';
        break;
    }
    await _tts.setLanguage(ttsLang);
  }

  /// Auto-detect Kannada dialect from GPS location
  Future<KannadaDialect> detectDialect() async {
    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          return KannadaDialect.mysore; // Default fallback
        }
      }

      // Get position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // Reverse geocode to get city
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final city = (place.locality ?? '').toLowerCase().trim();
        final subAdmin =
            (place.subAdministrativeArea ?? '').toLowerCase().trim();

        _detectedCity = place.locality ?? place.subAdministrativeArea ?? '';

        // Match city or district to dialect
        for (var entry in _cityDialectMap.entries) {
          if (city.contains(entry.key) || subAdmin.contains(entry.key)) {
            _dialect = entry.value;
            return _dialect;
          }
        }
      }
    } catch (_) {
      // Location unavailable — use default
    }

    _dialect = KannadaDialect.mysore;
    return _dialect;
  }

  /// Get the STT locale string for the current language
  String get _sttLocale {
    switch (_language) {
      case VoiceLanguage.english:
        return 'en_IN';
      case VoiceLanguage.hindi:
        return 'hi_IN';
      case VoiceLanguage.kannada:
        return 'kn_IN';
    }
  }

  /// Speak text using TTS and wait for completion
  Future<void> speak(String text) async {
    final completer = Completer<void>();
    _tts.setCompletionHandler(() {
      if (!completer.isCompleted) completer.complete();
    });
    _tts.setCancelHandler(() {
      if (!completer.isCompleted) completer.complete();
    });
    _tts.setErrorHandler((msg) {
      if (!completer.isCompleted) completer.complete();
    });
    await _tts.speak(text);
    return completer.future;
  }

  /// Stop TTS
  Future<void> stop() async {
    await _tts.stop();
  }

  /// Listen via STT and return recognized text
  /// [onPartial] receives partial results as user speaks
  Future<String> listen({
    Duration timeout = const Duration(seconds: 8),
    Function(String)? onPartial,
  }) async {
    if (!_sttAvailable) return '';

    final completer = Completer<String>();
    String finalResult = '';

    await _stt.listen(
      onResult: (result) {
        finalResult = result.recognizedWords;
        if (onPartial != null) {
          onPartial(finalResult);
        }
        if (result.finalResult && !completer.isCompleted) {
          completer.complete(finalResult);
        }
      },
      listenFor: timeout,
      pauseFor: const Duration(seconds: 3),
      localeId: _sttLocale,
      cancelOnError: true,
      listenMode: stt.ListenMode.dictation,
    );

    // Safety timeout
    Future.delayed(timeout + const Duration(seconds: 2), () {
      if (!completer.isCompleted) {
        _stt.stop();
        completer.complete(finalResult);
      }
    });

    return completer.future;
  }

  /// Stop listening
  Future<void> stopListening() async {
    await _stt.stop();
  }

  // ══════════════════════════════════════════════════
  // HUMAN-LIKE PROMPT GENERATION
  // These methods generate natural, warm prompts
  // adapted to the user's language and dialect.
  // ══════════════════════════════════════════════════

  /// Greeting when the voice session starts
  String get greeting {
    switch (_language) {
      case VoiceLanguage.english:
        return "Hello! I'm here to help you fill this form. I'll ask you each question one by one. Just speak your answer naturally. Let's begin!";
      case VoiceLanguage.hindi:
        return "नमस्ते! मैं आपकी इस फॉर्म को भरने में मदद करूँगा। मैं एक-एक करके पूछूँगा, आप बस बोलकर जवाब दीजिए। चलिए शुरू करते हैं!";
      case VoiceLanguage.kannada:
        return _kannadaGreeting;
    }
  }

  String get _kannadaGreeting {
    switch (_dialect) {
      case KannadaDialect.mysore:
        return "ನಮಸ್ಕಾರ! ನಾನು ನಿಮಗೆ ಈ ಫಾರ್ಮ್ ಭರ್ತಿ ಮಾಡೋಕೆ ಸಹಾಯ ಮಾಡ್ತೀನಿ. ಒಂದೊಂದಾಗಿ ಕೇಳ್ತೀನಿ, ನೀವು ಹೇಳಿ. ಶುರು ಮಾಡೋಣ!";
      case KannadaDialect.northKarnataka:
        return "ನಮಸ್ಕಾರ! ನಾನು ನಿಮಗ ಈ ಫಾರ್ಮ್ ಭರ್ತಿ ಮಾಡಾಕ ಸಹಾಯ ಮಾಡ್ತೀನಿ. ಒಂದೊಂದಾಗಿ ಕೇಳ್ತೀನಿ, ನೀವು ಹೇಳ್ರಿ. ಶುರು ಮಾಡೋಣ!";
      case KannadaDialect.coastal:
        return "ನಮಸ್ಕಾರ! ನಾನು ನಿಮಗೆ ಈ ಫಾರ್ಮ್ ಭರ್ತಿ ಮಾಡಲು ಸಹಾಯ ಮಾಡುತ್ತೇನೆ. ಒಂದೊಂದಾಗಿ ಕೇಳುತ್ತೇನೆ, ನೀವು ಹೇಳಿ. ಶುರು ಮಾಡೋಣ!";
      case KannadaDialect.hyderabadKarnataka:
        return "ನಮಸ್ಕಾರ! ನಾನು ನಿಮಗ ಈ ಫಾರ್ಮ್ ಭರ್ತಿ ಮಾಡಾಕ ಹೆಲ್ಪ್ ಮಾಡ್ತೀನಿ. ಒಂದೊಂದಾಗಿ ಕೇಳ್ತೀನಿ, ನೀವು ಹೇಳ್ರಿ. ಶುರು ಮಾಡೋಣ!";
    }
  }

  /// Generate a natural question prompt for a form field
  String questionFor(String label, {String? fieldType, List? options}) {
    final cleanLabel = label.replaceAll(RegExp(r'[*:]'), '').trim();

    switch (_language) {
      case VoiceLanguage.english:
        return _englishQuestion(cleanLabel, fieldType, options);
      case VoiceLanguage.hindi:
        return _hindiQuestion(cleanLabel, fieldType, options);
      case VoiceLanguage.kannada:
        return _kannadaQuestion(cleanLabel, fieldType, options);
    }
  }

  String _englishQuestion(String label, String? type, List? options) {
    if (type == 'select' && options != null && options.isNotEmpty) {
      final optionTexts =
          options.map((o) => o is Map ? (o['text'] ?? o['value']) : o).toList();
      if (optionTexts.length <= 5) {
        return "For $label, you have these choices: ${optionTexts.join(', ')}. Which one would you like?";
      }
      return "What would you like to select for $label?";
    }
    if (type == 'radio' && options != null && options.isNotEmpty) {
      final optionTexts =
          options.map((o) => o is Map ? (o['text'] ?? o['value']) : o).toList();
      return "For $label, the options are: ${optionTexts.join(', ')}. Which one?";
    }
    if (type == 'checkbox') {
      return "Should I check the box for $label? Say yes or no.";
    }
    // Text field — conversational
    final lower = label.toLowerCase();
    if (lower.contains('name')) return "What is your $label?";
    if (lower.contains('date') || lower.contains('dob'))
      return "What is your $label? Please say the date.";
    if (lower.contains('email'))
      return "What is your email address?";
    if (lower.contains('phone') || lower.contains('mobile'))
      return "What is your mobile number?";
    if (lower.contains('address'))
      return "Please tell me your $label.";
    return "Please tell me your $label.";
  }

  String _hindiQuestion(String label, String? type, List? options) {
    if (type == 'select' && options != null && options.isNotEmpty) {
      final optionTexts =
          options.map((o) => o is Map ? (o['text'] ?? o['value']) : o).toList();
      if (optionTexts.length <= 5) {
        return "$label के लिए ये विकल्प हैं: ${optionTexts.join(', ')}। कौन सा चुनेंगे?";
      }
      return "$label के लिए क्या चुनना चाहेंगे?";
    }
    if (type == 'radio' && options != null && options.isNotEmpty) {
      final optionTexts =
          options.map((o) => o is Map ? (o['text'] ?? o['value']) : o).toList();
      return "$label के विकल्प हैं: ${optionTexts.join(', ')}। कौन सा?";
    }
    if (type == 'checkbox') {
      return "क्या $label को चेक करना है? हाँ या ना बोलिए।";
    }
    final lower = label.toLowerCase();
    if (lower.contains('name')) return "आपका $label क्या है?";
    if (lower.contains('date') || lower.contains('dob'))
      return "आपकी $label क्या है? कृपया तारीख बताइए।";
    if (lower.contains('email'))
      return "आपका ईमेल पता क्या है?";
    if (lower.contains('phone') || lower.contains('mobile'))
      return "आपका मोबाइल नंबर क्या है?";
    return "कृपया अपना $label बताइए।";
  }

  String _kannadaQuestion(String label, String? type, List? options) {
    // Dialect-aware phrasing
    String tellMe;
    String whichOne;
    String yesOrNo;

    switch (_dialect) {
      case KannadaDialect.mysore:
        tellMe = "ನಿಮ್ಮ $label ಹೇಳಿ";
        whichOne = "ಯಾವುದು ಬೇಕು?";
        yesOrNo = "ಹೌದು ಅಥವಾ ಇಲ್ಲ ಹೇಳಿ";
        break;
      case KannadaDialect.northKarnataka:
        tellMe = "ನಿಮ್ಮ $label ಹೇಳ್ರಿ";
        whichOne = "ಯಾವುದು ಬೇಕ್ರಿ?";
        yesOrNo = "ಹೌದ್ರಿ ಅಥವಾ ಇಲ್ಲ ಹೇಳ್ರಿ";
        break;
      case KannadaDialect.coastal:
        tellMe = "ನಿಮ್ಮ $label ಹೇಳಿ";
        whichOne = "ಯಾವುದು ಬೇಕು?";
        yesOrNo = "ಹೌದು ಅಥವಾ ಇಲ್ಲ ಹೇಳಿ";
        break;
      case KannadaDialect.hyderabadKarnataka:
        tellMe = "ನಿಮ್ಮ $label ಹೇಳ್ರಿ";
        whichOne = "ಯಾವುದು ಬೇಕ್ರಿ?";
        yesOrNo = "ಹೌದ ಅಥವಾ ಇಲ್ಲ ಹೇಳ್ರಿ";
        break;
    }

    if (type == 'select' && options != null && options.isNotEmpty) {
      final optionTexts =
          options.map((o) => o is Map ? (o['text'] ?? o['value']) : o).toList();
      if (optionTexts.length <= 5) {
        return "$label ಗೆ ಈ ಆಯ್ಕೆಗಳಿವೆ: ${optionTexts.join(', ')}. $whichOne";
      }
      return "$label ಗೆ ಏನು ಆಯ್ಕೆ ಮಾಡ್ತೀರಿ?";
    }
    if (type == 'radio' && options != null && options.isNotEmpty) {
      final optionTexts =
          options.map((o) => o is Map ? (o['text'] ?? o['value']) : o).toList();
      return "$label ನ ಆಯ್ಕೆಗಳು: ${optionTexts.join(', ')}. $whichOne";
    }
    if (type == 'checkbox') {
      return "$label ಗೆ ಟಿಕ್ ಮಾಡಬೇಕಾ? $yesOrNo";
    }

    return "$tellMe.";
  }

  /// Confirmation prompt after user answers
  String confirmPrompt(String answer) {
    switch (_language) {
      case VoiceLanguage.english:
        return "$answer. Is that correct? Say yes or no.";
      case VoiceLanguage.hindi:
        return "$answer. क्या ये सही है? हाँ या ना बोलिए।";
      case VoiceLanguage.kannada:
        switch (_dialect) {
          case KannadaDialect.mysore:
            return "$answer. ಸರಿ ಆಗಿದ್ಯಾ? ಹೌದು ಅಥವಾ ಇಲ್ಲ ಹೇಳಿ.";
          case KannadaDialect.northKarnataka:
            return "$answer. ಸರಿ ಐತಿ? ಹೌದ್ರಿ ಅಥವಾ ಇಲ್ಲ ಹೇಳ್ರಿ.";
          case KannadaDialect.coastal:
            return "$answer. ಸರಿ ಇದೆಯಾ? ಹೌದು ಅಥವಾ ಇಲ್ಲ ಹೇಳಿ.";
          case KannadaDialect.hyderabadKarnataka:
            return "$answer. ಸರಿ ಐತ? ಹೌದ ಅಥವಾ ಇಲ್ಲ ಹೇಳ್ರಿ.";
        }
    }
  }

  /// Check if user said "yes"
  bool isYes(String input) {
    final lower = input.toLowerCase().trim();
    return lower.contains('yes') ||
        lower.contains('haan') ||
        lower.contains('haa') ||
        lower.contains('ha') ||
        lower.contains('correct') ||
        lower.contains('right') ||
        lower.contains('sahi') ||
        lower.contains('theek') ||
        lower.contains('ಹೌದು') ||
        lower.contains('ಸರಿ') ||
        lower.contains('हाँ') ||
        lower.contains('हां') ||
        lower == 'ji' ||
        lower == 'ho' ||
        lower == 'howdu';
  }

  /// Check if user said "no"
  bool isNo(String input) {
    final lower = input.toLowerCase().trim();
    return lower.contains('no') ||
        lower.contains('nahi') ||
        lower.contains('naa') ||
        lower.contains('galat') ||
        lower.contains('wrong') ||
        lower.contains('ಇಲ್ಲ') ||
        lower.contains('ತಪ್ಪು') ||
        lower.contains('नहीं') ||
        lower.contains('ना') ||
        lower == 'illa';
  }

  /// Completion message when all fields are done
  String get completionMessage {
    switch (_language) {
      case VoiceLanguage.english:
        return "All details are filled in. Ready to submit the form!";
      case VoiceLanguage.hindi:
        return "सभी जानकारी भर दी गई है। फॉर्म जमा करने के लिए तैयार है!";
      case VoiceLanguage.kannada:
        switch (_dialect) {
          case KannadaDialect.mysore:
            return "ಎಲ್ಲಾ ವಿವರಗಳು ಭರ್ತಿ ಆಗಿದೆ. ಫಾರ್ಮ್ ಸಬ್ಮಿಟ್ ಮಾಡೋಣ!";
          case KannadaDialect.northKarnataka:
            return "ಎಲ್ಲಾ ಡೀಟೇಲ್ಸ್ ಭರ್ತಿ ಆಗ್ಯಾವ. ಫಾರ್ಮ್ ಸಬ್ಮಿಟ್ ಮಾಡೋಣ!";
          case KannadaDialect.coastal:
            return "ಎಲ್ಲಾ ವಿವರಗಳು ಭರ್ತಿ ಆಗಿದೆ. ಫಾರ್ಮ್ ಸಬ್ಮಿಟ್ ಮಾಡೋಣ!";
          case KannadaDialect.hyderabadKarnataka:
            return "ಎಲ್ಲಾ ಡೀಟೇಲ್ಸ್ ಭರ್ತಿ ಆಗ್ಯಾವ. ಫಾರ್ಮ್ ಸಬ್ಮಿಟ್ ಮಾಡೋಣ!";
        }
    }
  }

  /// Next field transition prompt
  String get nextFieldPrompt {
    switch (_language) {
      case VoiceLanguage.english:
        return "Great! Next question.";
      case VoiceLanguage.hindi:
        return "बहुत अच्छा! अगला सवाल।";
      case VoiceLanguage.kannada:
        switch (_dialect) {
          case KannadaDialect.mysore:
            return "ಚೆನ್ನಾಗಿದೆ! ಮುಂದಿನ ಪ್ರಶ್ನೆ.";
          case KannadaDialect.northKarnataka:
            return "ಛಲೋ ಐತಿ! ಮುಂದಿನ ಪ್ರಶ್ನೆ.";
          case KannadaDialect.coastal:
            return "ಒಳ್ಳೆಯದು! ಮುಂದಿನ ಪ್ರಶ್ನೆ.";
          case KannadaDialect.hyderabadKarnataka:
            return "ಛಲೋ! ಮುಂದಿನ ಪ್ರಶ್ನೆ.";
        }
    }
  }

  /// Couldn't hear prompt
  String get didntHearPrompt {
    switch (_language) {
      case VoiceLanguage.english:
        return "Sorry, I couldn't hear that clearly. Could you say it again?";
      case VoiceLanguage.hindi:
        return "माफ़ कीजिए, मुझे सुनाई नहीं दिया। क्या आप दोबारा बोल सकते हैं?";
      case VoiceLanguage.kannada:
        switch (_dialect) {
          case KannadaDialect.mysore:
            return "ಕ್ಷಮಿಸಿ, ನನಗೆ ಕೇಳಿಸಲಿಲ್ಲ. ಮತ್ತೊಮ್ಮೆ ಹೇಳ್ತೀರಾ?";
          case KannadaDialect.northKarnataka:
            return "ಕ್ಷಮಿಸಿ, ಕೇಳಿಸಲಿಲ್ಲ. ಮತ್ತೊಮ್ಮೆ ಹೇಳ್ರಿ?";
          case KannadaDialect.coastal:
            return "ಕ್ಷಮಿಸಿ, ಕೇಳಿಸಲಿಲ್ಲ. ಮತ್ತೊಮ್ಮೆ ಹೇಳಿ?";
          case KannadaDialect.hyderabadKarnataka:
            return "ಕ್ಷಮಿಸಿ, ಕೇಳಿಸಲಿಲ್ಲ. ಮತ್ತೊಮ್ಮೆ ಹೇಳ್ರಿ?";
        }
    }
  }

  /// Skipping field prompt
  String get skipPrompt {
    switch (_language) {
      case VoiceLanguage.english:
        return "Okay, skipping this one. Moving on.";
      case VoiceLanguage.hindi:
        return "ठीक है, इसे छोड़ रहे हैं। आगे बढ़ते हैं।";
      case VoiceLanguage.kannada:
        return "ಸರಿ, ಇದನ್ನ ಬಿಡ್ತೀನಿ. ಮುಂದಕ್ಕೆ ಹೋಗೋಣ.";
    }
  }

  /// Clean up
  Future<void> dispose() async {
    await _tts.stop();
    await _stt.stop();
  }
}

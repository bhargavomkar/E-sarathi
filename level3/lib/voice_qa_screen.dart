import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'voice_service.dart';
import 'main.dart';

//////////////////////////////////////////////////////////////
// VOICE Q&A SCREEN — Conversational voice form filling
//////////////////////////////////////////////////////////////

class VoiceQAScreen extends StatefulWidget {
  final String url;
  final Map<String, Map<String, dynamic>> fieldsMap;

  const VoiceQAScreen({super.key, required this.url, required this.fieldsMap});

  @override
  State<VoiceQAScreen> createState() => _VoiceQAScreenState();
}

class _VoiceQAScreenState extends State<VoiceQAScreen>
    with TickerProviderStateMixin {
  final VoiceService _voice = VoiceService();

  // ── State ──
  bool _languageSelected = false;
  bool _isInitializing = false;
  bool _isSpeaking = false;
  bool _isListening = false;
  bool _isConfirming = false;
  bool _isTypingFallback = false;
  String _partialText = '';
  int _currentFieldIndex = 0;
  final Map<String, dynamic> _answers = {};
  final List<_ChatMessage> _chatHistory = [];
  final ScrollController _scrollCtrl = ScrollController();
  final TextEditingController _typeCtrl = TextEditingController();

  // ── Ordered fields list ──
  late List<MapEntry<String, Map<String, dynamic>>> _orderedFields;

  // ── Animations ──
  late AnimationController _pulseCtrl;
  late AnimationController _waveCtrl;

  @override
  void initState() {
    super.initState();
    _orderedFields = widget.fieldsMap.entries.toList();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
  }

  @override
  void dispose() {
    _voice.dispose();
    _pulseCtrl.dispose();
    _waveCtrl.dispose();
    _scrollCtrl.dispose();
    _typeCtrl.dispose();
    super.dispose();
  }

  /// Navigate to manual ReviewScreen (existing code, untouched)
  void _goToManualForm() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewScreen(url: widget.url, fieldsMap: widget.fieldsMap),
      ),
    );
  }

  /// Navigate to AutoFillScreen after voice Q&A
  void _goToAutoFill() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AutoFillScreen(url: widget.url, values: _answers),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // LANGUAGE SELECTION
  // ══════════════════════════════════════════════════════

  Future<void> _selectLanguage(VoiceLanguage lang) async {
    setState(() => _isInitializing = true);

    await _voice.init();
    await _voice.setLanguage(lang);

    // If Kannada, detect dialect
    String? dialectInfo;
    if (lang == VoiceLanguage.kannada) {
      final dialect = await _voice.detectDialect();
      final city = _voice.detectedCity;
      final dialectName = _dialectDisplayName(dialect);
      dialectInfo = city != null && city.isNotEmpty
          ? '$dialectName Kannada (detected: $city)'
          : '$dialectName Kannada';
    }

    if (!mounted) return;

    setState(() {
      _languageSelected = true;
      _isInitializing = false;
    });

    // Add system message
    if (dialectInfo != null) {
      _addChat(_ChatMessage(
        text: '🗣️ $dialectInfo',
        isSystem: true,
      ));
    }

    // Start the greeting
    await _speakAndShow(_voice.greeting);
    await Future.delayed(const Duration(milliseconds: 500));

    // Start asking questions
    _askCurrentField();
  }

  String _dialectDisplayName(KannadaDialect d) {
    switch (d) {
      case KannadaDialect.mysore:
        return 'Mysore / Bengaluru';
      case KannadaDialect.northKarnataka:
        return 'North Karnataka';
      case KannadaDialect.coastal:
        return 'Coastal Karnataka';
      case KannadaDialect.hyderabadKarnataka:
        return 'Hyderabad-Karnataka';
    }
  }

  // ══════════════════════════════════════════════════════
  // Q&A FLOW
  // ══════════════════════════════════════════════════════

  Future<void> _askCurrentField() async {
    if (_currentFieldIndex >= _orderedFields.length) {
      // All done!
      await _speakAndShow(_voice.completionMessage);
      _addChat(_ChatMessage(
        text: '✅ All fields filled!',
        isSystem: true,
      ));
      return;
    }

    final entry = _orderedFields[_currentFieldIndex];
    final field = entry.value;
    final label = (field['label'] ?? field['name'] ?? '').toString();
    final type = (field['type'] ?? 'text').toString();
    final options = field['options'] as List?;

    final question = _voice.questionFor(label, fieldType: type, options: options);
    setState(() {
      _isConfirming = false;
      _isTypingFallback = false;
    });

    await _speakAndShow(question);
    _startListening();
  }

  Future<void> _speakAndShow(String text) async {
    _addChat(_ChatMessage(text: text, isAssistant: true));
    setState(() => _isSpeaking = true);
    _scrollToBottom();
    await _voice.speak(text);
    if (mounted) setState(() => _isSpeaking = false);
  }

  void _startListening() async {
    setState(() {
      _isListening = true;
      _partialText = '';
    });

    final result = await _voice.listen(
      onPartial: (partial) {
        if (mounted) setState(() => _partialText = partial);
      },
    );

    if (!mounted) return;
    setState(() => _isListening = false);

    if (result.trim().isEmpty) {
      // Didn't hear anything
      await _speakAndShow(_voice.didntHearPrompt);
      _startListening();
      return;
    }

    // Show user's answer
    _addChat(_ChatMessage(text: result, isUser: true));
    _scrollToBottom();

    // Process the answer
    _processAnswer(result);
  }

  void _processAnswer(String answer) async {
    final entry = _orderedFields[_currentFieldIndex];
    final field = entry.value;
    final fieldName = entry.key;
    final type = (field['type'] ?? 'text').toString();
    final options = field['options'] as List?;

    // For checkbox, interpret yes/no directly
    if (type == 'checkbox') {
      if (_voice.isYes(answer)) {
        _answers[fieldName] = true;
        await _speakAndShow(_voice.nextFieldPrompt);
        _moveToNextField();
        return;
      } else if (_voice.isNo(answer)) {
        _answers[fieldName] = false;
        await _speakAndShow(_voice.nextFieldPrompt);
        _moveToNextField();
        return;
      }
    }

    // For select/radio, try to match answer to an option
    if ((type == 'select' || type == 'radio') &&
        options != null &&
        options.isNotEmpty) {
      final matchedOption = _matchOption(answer, options);
      if (matchedOption != null) {
        _pendingAnswer = matchedOption;
        _confirmAnswer(matchedOption is Map ? (matchedOption['text'] ?? matchedOption['value']).toString() : matchedOption.toString());
        return;
      }
      // Couldn't match — store raw text as best effort
      _pendingAnswer = answer;
      _confirmAnswer(answer);
      return;
    }

    // Text field — confirm the answer
    _pendingAnswer = answer;
    _confirmAnswer(answer);
  }

  dynamic _pendingAnswer;

  /// Ask user to confirm the transcribed answer
  void _confirmAnswer(String displayAnswer) async {
    setState(() => _isConfirming = true);
    await _speakAndShow(_voice.confirmPrompt(displayAnswer));
    _startConfirmListening();
  }

  void _startConfirmListening() async {
    setState(() {
      _isListening = true;
      _partialText = '';
    });

    final result = await _voice.listen(
      onPartial: (partial) {
        if (mounted) setState(() => _partialText = partial);
      },
    );

    if (!mounted) return;
    setState(() => _isListening = false);

    if (result.trim().isNotEmpty) {
      _addChat(_ChatMessage(text: result, isUser: true));
    }

    if (_voice.isYes(result) || result.trim().isEmpty) {
      // Accept the answer
      final entry = _orderedFields[_currentFieldIndex];
      final fieldName = entry.key;

      if (_pendingAnswer is Map) {
        _answers[fieldName] = _pendingAnswer['value']?.toString() ?? _pendingAnswer.toString();
      } else {
        _answers[fieldName] = _pendingAnswer.toString();
      }

      await _speakAndShow(_voice.nextFieldPrompt);
      _moveToNextField();
    } else if (_voice.isNo(result)) {
      // Re-ask the question
      _askCurrentField();
    } else {
      // Unclear — treat as re-answer
      _processAnswer(result);
    }
  }

  /// Try to match spoken text to a dropdown/radio option
  dynamic _matchOption(String spoken, List options) {
    final lower = spoken.toLowerCase().trim();
    // Try exact and partial matching
    for (var opt in options) {
      String optText = '';
      String optValue = '';
      if (opt is Map) {
        optText = (opt['text'] ?? '').toString().toLowerCase();
        optValue = (opt['value'] ?? '').toString().toLowerCase();
      } else {
        optText = opt.toString().toLowerCase();
        optValue = optText;
      }
      if (optText == lower || optValue == lower) return opt;
      if (lower.contains(optText) || optText.contains(lower)) return opt;
    }
    return null;
  }

  void _moveToNextField() {
    _currentFieldIndex++;
    if (_currentFieldIndex < _orderedFields.length) {
      _askCurrentField();
    } else {
      _askCurrentField(); // Will trigger completion message
    }
  }

  void _skipField() async {
    await _voice.stop();
    await _voice.stopListening();
    setState(() {
      _isListening = false;
      _isSpeaking = false;
      _isConfirming = false;
    });
    _addChat(_ChatMessage(text: '⏭️ Skipped', isSystem: true));
    await _speakAndShow(_voice.skipPrompt);
    _moveToNextField();
  }

  void _typeInstead() {
    _voice.stop();
    _voice.stopListening();
    setState(() {
      _isListening = false;
      _isSpeaking = false;
      _isTypingFallback = true;
      _typeCtrl.clear();
    });
  }

  void _submitTypedAnswer() {
    final text = _typeCtrl.text.trim();
    if (text.isEmpty) return;
    _addChat(_ChatMessage(text: text, isUser: true));
    setState(() => _isTypingFallback = false);
    _processAnswer(text);
  }

  // ── Chat helpers ──
  void _addChat(_ChatMessage msg) {
    setState(() => _chatHistory.add(msg));
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ══════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    if (!_languageSelected) {
      return _buildLanguageSelection();
    }
    return _buildConversationUI();
  }

  // ── LANGUAGE SELECTION SCREEN ──
  Widget _buildLanguageSelection() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1B2A), Color(0xFF162032), Color(0xFF1B2838)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Back button
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 20, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _goToManualForm,
                      child: Text(
                        'Manual Form →',
                        style: TextStyle(
                          color: Colors.white.withAlpha(100),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Mic icon with glow
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6C63FF).withAlpha(50),
                      const Color(0xFF4ECDC4).withAlpha(50),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withAlpha(60),
                      blurRadius: 40,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.mic_rounded,
                  size: 44,
                  color: Color(0xFF6C63FF),
                ),
              ),
              const SizedBox(height: 28),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
                ).createShader(bounds),
                child: const Text(
                  'Voice Assistant',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose your language to begin',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withAlpha(130),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${widget.fieldsMap.length} fields to fill',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withAlpha(80),
                ),
              ),
              const SizedBox(height: 40),

              if (_isInitializing) ...[
                const CircularProgressIndicator(
                  color: Color(0xFF6C63FF),
                  strokeWidth: 2.5,
                ),
                const SizedBox(height: 16),
                Text(
                  'Setting up voice...',
                  style: TextStyle(
                    color: Colors.white.withAlpha(140),
                    fontSize: 14,
                  ),
                ),
              ] else ...[
                // Language cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      _LanguageCard(
                        flag: '🇺🇸',
                        name: 'English',
                        subtitle: 'I\'ll ask questions in English',
                        color: const Color(0xFF6C63FF),
                        onTap: () => _selectLanguage(VoiceLanguage.english),
                      ),
                      const SizedBox(height: 14),
                      _LanguageCard(
                        flag: '🇮🇳',
                        name: 'हिन्दी',
                        subtitle: 'मैं हिंदी में पूछूँगा',
                        color: const Color(0xFFFF6B6B),
                        onTap: () => _selectLanguage(VoiceLanguage.hindi),
                      ),
                      const SizedBox(height: 14),
                      _LanguageCard(
                        flag: '🏛️',
                        name: 'ಕನ್ನಡ',
                        subtitle: 'ನಿಮ್ಮ ಪ್ರದೇಶದ ಕನ್ನಡದಲ್ಲಿ ಮಾತಾಡ್ತೀನಿ',
                        color: const Color(0xFF4ECDC4),
                        onTap: () => _selectLanguage(VoiceLanguage.kannada),
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              // Skip to manual
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: TextButton.icon(
                  onPressed: _goToManualForm,
                  icon: Icon(Icons.edit_note_rounded,
                      size: 18, color: Colors.white.withAlpha(100)),
                  label: Text(
                    'Skip voice — fill manually',
                    style: TextStyle(
                      color: Colors.white.withAlpha(100),
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── CONVERSATION UI ──
  Widget _buildConversationUI() {
    final progress = _orderedFields.isEmpty
        ? 0.0
        : _currentFieldIndex / _orderedFields.length;
    final isDone = _currentFieldIndex >= _orderedFields.length;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1B2A), Color(0xFF162032), Color(0xFF1B2838)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Top bar ──
              _buildTopBar(progress),

              // ── Chat history ──
              Expanded(
                child: ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: _chatHistory.length + (_isListening ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < _chatHistory.length) {
                      return _buildChatBubble(_chatHistory[index]);
                    }
                    // Live transcription bubble
                    return _buildListeningBubble();
                  },
                ),
              ),

              // ── Bottom action area ──
              _buildBottomArea(isDone),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(double progress) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1923),
        border: Border(
          bottom: BorderSide(color: const Color(0xFF6C63FF).withAlpha(30)),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18, color: Colors.white70),
                onPressed: () async {
                  await _voice.stop();
                  await _voice.stopListening();
                  if (mounted) Navigator.pop(context);
                },
              ),
              Expanded(
                child: Column(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
                      ).createShader(bounds),
                      child: const Text(
                        'Voice Assistant',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Field ${min(_currentFieldIndex + 1, _orderedFields.length)} of ${_orderedFields.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withAlpha(100),
                      ),
                    ),
                  ],
                ),
              ),
              // Status indicator
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isSpeaking
                      ? const Color(0xFF6C63FF)
                      : _isListening
                          ? const Color(0xFF4ADE80)
                          : Colors.white.withAlpha(40),
                  boxShadow: [
                    if (_isSpeaking || _isListening)
                      BoxShadow(
                        color: (_isSpeaking
                                ? const Color(0xFF6C63FF)
                                : const Color(0xFF4ADE80))
                            .withAlpha(150),
                        blurRadius: 10,
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 3,
              backgroundColor: const Color(0xFF1E2D42),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(_ChatMessage msg) {
    if (msg.isSystem) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withAlpha(20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              msg.text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withAlpha(140),
              ),
            ),
          ),
        ),
      );
    }

    final isUser = msg.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6C63FF).withAlpha(80),
                    const Color(0xFF4ECDC4).withAlpha(80),
                  ],
                ),
              ),
              child: const Icon(Icons.assistant_rounded,
                  size: 16, color: Colors.white70),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? const Color(0xFF6C63FF).withAlpha(40)
                    : const Color(0xFF1E2D42),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                border: Border.all(
                  color: isUser
                      ? const Color(0xFF6C63FF).withAlpha(60)
                      : const Color(0xFF2A3A50),
                  width: 1,
                ),
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withAlpha(220),
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4ECDC4).withAlpha(60),
              ),
              child: const Icon(Icons.person_rounded,
                  size: 16, color: Colors.white70),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildListeningBubble() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF4ADE80).withAlpha(20),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(4),
                ),
                border: Border.all(
                  color: const Color(0xFF4ADE80).withAlpha(40),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated listening dots
                  AnimatedBuilder(
                    animation: _waveCtrl,
                    builder: (context, child) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(3, (i) {
                          final delay = i * 0.3;
                          final value =
                              sin((_waveCtrl.value + delay) * 3.14159 * 2);
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            width: 6,
                            height: 6 + (value.abs() * 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4ADE80),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                  if (_partialText.isNotEmpty) ...[
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        _partialText,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withAlpha(180),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4ADE80).withAlpha(60),
            ),
            child: const Icon(Icons.mic_rounded,
                size: 16, color: Color(0xFF4ADE80)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomArea(bool isDone) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1923),
        border: Border(
          top: BorderSide(color: const Color(0xFF6C63FF).withAlpha(30)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(80),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Typing fallback
          if (_isTypingFallback) ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _typeCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'Type your answer...',
                      hintStyle: TextStyle(color: Colors.white.withAlpha(60)),
                      filled: true,
                      fillColor: const Color(0xFF1E2D42),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: const Color(0xFF6C63FF).withAlpha(40)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
                      ),
                    ),
                    onSubmitted: (_) => _submitTypedAnswer(),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    onPressed: _submitTypedAnswer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() => _isTypingFallback = false);
                _startListening();
              },
              child: Text(
                '🎙️ Switch back to voice',
                style: TextStyle(
                    color: Colors.white.withAlpha(100), fontSize: 13),
              ),
            ),
          ] else ...[
            // Main mic area
            if (_isListening)
              AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (context, child) {
                  return Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF4ADE80)
                              .withAlpha((60 + _pulseCtrl.value * 40).toInt()),
                          const Color(0xFF4ADE80).withAlpha(0),
                        ],
                      ),
                    ),
                    child: Container(
                      width: 52,
                      height: 52,
                      margin: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF4ADE80),
                      ),
                      child: const Icon(Icons.mic_rounded,
                          color: Color(0xFF052E16), size: 28),
                    ),
                  );
                },
              )
            else if (_isSpeaking)
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6C63FF).withAlpha(30),
                ),
                child: const Icon(Icons.volume_up_rounded,
                    color: Color(0xFF6C63FF), size: 28),
              )
            else if (isDone)
              // Submit button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4ADE80), Color(0xFF22C55E)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4ADE80).withAlpha(80),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: const Color(0xFF052E16),
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _goToAutoFill,
                    icon: const Icon(Icons.bolt_rounded, size: 22),
                    label: const Text(
                      'Submit & Auto-Fill',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),

            if (!isDone) ...[
              const SizedBox(height: 10),
              // Action buttons row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ActionChip(
                    icon: Icons.skip_next_rounded,
                    label: 'Skip',
                    onTap: (_isSpeaking || _isListening || _isConfirming)
                        ? _skipField
                        : null,
                  ),
                  const SizedBox(width: 12),
                  _ActionChip(
                    icon: Icons.keyboard_rounded,
                    label: 'Type instead',
                    onTap: _typeInstead,
                  ),
                  const SizedBox(width: 12),
                  _ActionChip(
                    icon: Icons.edit_note_rounded,
                    label: 'Manual form',
                    onTap: _goToManualForm,
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// HELPER WIDGETS
// ══════════════════════════════════════════════════════

class _ChatMessage {
  final String text;
  final bool isUser;
  final bool isAssistant;
  final bool isSystem;

  _ChatMessage({
    required this.text,
    this.isUser = false,
    this.isAssistant = false,
    this.isSystem = false,
  });
}

class _LanguageCard extends StatelessWidget {
  final String flag;
  final String name;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.flag,
    required this.name,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1E2D42),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        splashColor: color.withAlpha(30),
        highlightColor: color.withAlpha(15),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withAlpha(40), width: 1),
          ),
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withAlpha(230),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withAlpha(100),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 16, color: color.withAlpha(150)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2D42),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withAlpha(20),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.white.withAlpha(120)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withAlpha(120),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

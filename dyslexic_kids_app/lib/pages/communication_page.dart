import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;

// ═══════════════════════════════════════════════════════════
// OPENAI — GPT-4.1-mini
// ═══════════════════════════════════════════════════════════
class _OpenAI {
  static const _key   = 'sk-YOUR_OPENAI_KEY_HERE'; // 🔑 remplace ici
  static const _model = 'gpt-4.1-mini';
  static const _url   = 'https://api.openai.com/v1/chat/completions';

  static const _system = '''
You are "Lumi" 🌟, a warm and fun reading buddy for children aged 5-9 with dyslexia.
Rules:
- Keep replies SHORT (max 2 sentences) and use simple words
- Always encourage, never say "wrong"
- Use emojis to stay fun and friendly
- When asked about syllables, clap out the word: e.g. BUT·TER·FLY 👏
- Reply in the same language the child uses (English, French, Arabic)
''';

  static Future<String> ask(List<Map<String, String>> history) async {
    try {
      final res = await http.post(
        Uri.parse(_url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_key',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 120,
          'temperature': 0.7,
          'messages': [
            {'role': 'system', 'content': _system},
            ...history,
          ],
        }),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['choices'][0]['message']['content'] as String;
      }
      return '😅 Oops! Try again?';
    } catch (_) {
      return '😅 No connection right now!';
    }
  }
}

// ═══════════════════════════════════════════════════════════
// CommunicationPage — Lumi AI Chatbot
// ═══════════════════════════════════════════════════════════
class CommunicationPage extends StatefulWidget {
  final int userId;
  const CommunicationPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<CommunicationPage> createState() => _CommunicationPageState();
}

class _CommunicationPageState extends State<CommunicationPage> {
  final FlutterTts _tts = FlutterTts();
  final TextEditingController _ctrl   = TextEditingController();
  final ScrollController      _scroll = ScrollController();

  final List<_Msg>                _messages = [];
  final List<Map<String, String>> _history  = [];
  bool _loading = false;

  final List<String> _suggestions = [
    '👏 Clap a word',
    '🔤 B or D help!',
    '📖 Spell with me',
    '⭐ Encourage me!',
    '🐰 Split RABBIT',
    '🦋 Split BUTTERFLY',
  ];

  @override
  void initState() {
    super.initState();
    _tts.setLanguage("en-US");
    _tts.setSpeechRate(0.42);
    _addBot("Hi! I'm Lumi 🌟 I'm here to help you with letters and words! What do you want to learn today? 😊");
  }

  @override
  void dispose() {
    _tts.stop();
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _addBot(String text) {
    setState(() => _messages.add(_Msg(text: text, isUser: false)));
    _tts.speak(text);
    _scrollDown();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty || _loading) return;
    _ctrl.clear();
    setState(() {
      _messages.add(_Msg(text: text, isUser: true));
      _loading = true;
    });
    _scrollDown();

    _history.add({'role': 'user', 'content': text});
    final reply = await _OpenAI.ask(List.from(_history));
    _history.add({'role': 'assistant', 'content': reply});

    setState(() => _loading = false);
    _addBot(reply);
  }

  void _handleSuggestion(String label) {
    final Map<String, String> map = {
      '👏 Clap a word':     'Can you teach me how to clap out syllables?',
      '🔤 B or D help!':    'I always confuse B and D, can you help me?',
      '📖 Spell with me':   'Can we practice spelling a word together?',
      '⭐ Encourage me!':   'Please encourage me, I am trying my best!',
      '🐰 Split RABBIT':    'How do I split the word RABBIT into syllables?',
      '🦋 Split BUTTERFLY': 'How do I split the word BUTTERFLY into syllables?',
    };
    _send(map[label] ?? label);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 0,
        title: Row(children: [
          const Text('🌟', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          const Text('Lumi',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10)),
            child: const Text('GPT-4.1-mini',
                style: TextStyle(fontSize: 11, color: Colors.white70)),
          ),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up_rounded, color: Colors.white),
            tooltip: 'Hear last message',
            onPressed: () {
              final last = _messages.lastWhere((m) => !m.isUser,
                  orElse: () => _messages.last);
              _tts.speak(last.text);
            },
          ),
        ],
      ),
      body: Column(children: [
        // messages
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            itemCount: _messages.length + (_loading ? 1 : 0),
            itemBuilder: (ctx, i) {
              if (i == _messages.length) return _buildTyping();
              return _buildBubble(_messages[i]);
            },
          ),
        ),

        // suggestions
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: _suggestions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) => GestureDetector(
                onTap: () => _handleSuggestion(_suggestions[i]),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: const Color(0xFF6C63FF).withOpacity(0.3)),
                  ),
                  alignment: Alignment.center,
                  child: Text(_suggestions[i],
                      style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6C63FF),
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ),
        ),

        // input bar
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(14, 6, 12, 16),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                style: const TextStyle(fontSize: 15),
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Ask Lumi anything… 😊',
                  hintStyle:
                      TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  filled: true,
                  fillColor: const Color(0xFFF5F3FF),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(26),
                      borderSide: BorderSide.none),
                ),
                onSubmitted: _send,
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => _send(_ctrl.text),
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                    color: Color(0xFF6C63FF), shape: BoxShape.circle),
                child: _loading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send_rounded,
                        color: Colors.white, size: 22),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildBubble(_Msg msg) {
    final isUser = msg.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: () => _tts.speak(msg.text),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isUser ? const Color(0xFF6C63FF) : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(isUser ? 20 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 20),
            ),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 8,
                  offset: const Offset(0, 3))
            ],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (!isUser)
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text('🌟 Lumi',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6C63FF))),
              ),
            Text(msg.text,
                style: TextStyle(
                    fontSize: 15,
                    color: isUser ? Colors.white : Colors.black87,
                    height: 1.4)),
            const SizedBox(height: 4),
            Text('🔊 Tap to hear',
                style: TextStyle(
                    fontSize: 10,
                    color: isUser ? Colors.white54 : Colors.grey.shade400)),
          ]),
        ),
      ),
    );
  }

  Widget _buildTyping() => Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 8,
                    offset: const Offset(0, 3))
              ]),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Text('🌟 Lumi is thinking',
                style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(width: 8),
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  color: const Color(0xFF6C63FF).withOpacity(0.5),
                  strokeWidth: 2),
            ),
          ]),
        ),
      );
}

class _Msg {
  final String text;
  final bool   isUser;
  _Msg({required this.text, required this.isUser});
}
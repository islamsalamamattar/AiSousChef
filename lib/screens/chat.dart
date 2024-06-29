// screens/chat.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services/chat_history_service.dart';
import '../services/chat_message_service.dart';
import '../services/chat_message_formatter.dart'; // Corrected the import

class ChatPage extends StatefulWidget {
  final String accessToken;

  ChatPage({required this.accessToken});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Map<String, dynamic>> _messages = [];
  final TextEditingController _textEditingController = TextEditingController();
  final ChatMessageService _messageService = ChatMessageService();
  bool _isTalking = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  _loadHistory() async {
    try {
      List<Map<String, dynamic>> history =
          await HistoryService().fetchHistory(widget.accessToken);
      setState(() {
        _messages = history;
      });
    } catch (e) {
      print('Error fetching history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double radiusTalking =
        screenWidth < screenHeight ? screenWidth * 0.2 : screenHeight * 0.2;
    double RadiusNotTalking =
        screenWidth < screenHeight ? screenWidth * 0.1 : screenHeight * 0.1;

    return CupertinoPageScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(top: 12, left: 12),
              child: CircleAvatar(
                radius: _isTalking ? radiusTalking : RadiusNotTalking,
                backgroundImage: AssetImage(_isTalking
                    ? 'lib/assets/images/sous_chef_talk.gif'
                    : 'lib/assets/images/sous_chef_smile.png'),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 16, left: 16),
              child: SingleChildScrollView(
                reverse: true,
                child: Column(
                  children: _messages.map((message) {
                    return Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: MessageFormatter.formatMessage(
                          context, message, widget.accessToken),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 50.0, right: 12.0, left: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: CupertinoTextField(
                    controller: _textEditingController,
                    placeholder: 'Type a message',
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.0),
                      //color: CupertinoColors.darkBackgroundGray,
                    ),
                  ),
                ),
                CupertinoButton(
                  child: Text('Send'),
                  onPressed: () {
                    _sendMessage();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    String message = _textEditingController.text.trim();
    if (message.isNotEmpty) {
      setState(() {
        // Add the user's message to the chat box
        _messages.add({
          'role': 'user',
          'text': message,
        });
        _textEditingController.clear();
      });

      try {
        // Attempt to send the user's message to the backend
        Map<String, dynamic> response =
            await _messageService.sendMessage(widget.accessToken, message);
        // Format and add the reply from the API to the chat box
        if (response.containsKey('text')) {
          String reply = response['text'];
          String interactionId = response['interaction_id'];
          setState(() {
            _isTalking = true;
          });
          await _displayResponse(reply, interactionId);
          setState(() {
            _isTalking = false;
          });
        }
      } catch (e) {
        print('Error sending message: $e');
        // Handle error
      }
    }
  }

  Future<void> _displayResponse(String response, String interactionId) async {
    // Split the response by "\n\n"
    List<String> parts = response.split('\n\n');

    // If there's at least one part, handle it as the first message
    if (parts.isNotEmpty) {
      // Handle the first part word by word
      setState(() {
        _messages.add({
          'role': 'assistant',
          'text': '',
        });
      });

      List<String> words = parts[0].split(' '); // Split by space to get words
      for (int j = 0; j < words.length; j++) {
        String word = words[j];
        setState(() {
          _messages.last['text'] += word + ' '; // Add a space after each word
        });
        await Future.delayed(Duration(milliseconds: 300));
      }

      // Combine the remaining parts into one message
      String remainingMessage = parts.sublist(1).join('\n\n');
      if (remainingMessage.isNotEmpty) {
        setState(() {
          _messages.add({
            'role': 'assistant',
            'text': remainingMessage,
            'interaction_id': interactionId
          });
        });
      }
    }
  }
}

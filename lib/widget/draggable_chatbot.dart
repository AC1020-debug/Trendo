import 'package:flutter/material.dart';

class DraggableChatbot extends StatefulWidget {
  const DraggableChatbot({Key? key}) : super(key: key);

  @override
  _DraggableChatbotState createState() => _DraggableChatbotState();
}

class _DraggableChatbotState extends State<DraggableChatbot> {
  static Offset? savedPosition; // persist across screens
  late Offset position;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenSize = MediaQuery.of(context).size;
      final buttonSize = 40.0;

      setState(() {
        position =
            savedPosition ??
            Offset(
              screenSize.width - buttonSize - 20,
              screenSize.height - buttonSize - 100,
            );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Draggable(
        feedback: _buildChatbotButton(isDragging: true),
        childWhenDragging: Container(),
        onDragEnd: (details) {
          setState(() {
            double newX = details.offset.dx;
            double newY = details.offset.dy;

            final screenSize = MediaQuery.of(context).size;
            final buttonSize = 40.0;

            newX = newX.clamp(0.0, screenSize.width - buttonSize);
            newY = newY.clamp(0.0, screenSize.height - buttonSize - 80);

            position = Offset(newX, newY);
            savedPosition = position; // save globally
          });
        },
        child: _buildChatbotButton(isDragging: false),
      ),
    );
  }

  Widget _buildChatbotButton({required bool isDragging}) {
    return GestureDetector(
      onTap: isDragging
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatbotPage()),
              );
            },
      child: Opacity(
        opacity: 0.6, // half transparent
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[600]!, Colors.blue[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.4),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: Image.asset(
                  'assets/icon/robot.png',
                  width: 30,
                  height: 30,
                ),
              ),
              // Notification badge
              // Positioned(
              //   top: 6,
              //   right: 6,
              //   child: Container(
              //     width: 10,
              //     height: 10,
              //     decoration: BoxDecoration(
              //       color: Colors.red,
              //       shape: BoxShape.circle,
              //       border: Border.all(color: Colors.white, width: 2),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

// Chatbot Page (unchanged from before)
class ChatbotPage extends StatefulWidget {
  const ChatbotPage({Key? key}) : super(key: key);

  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> messages = [
    ChatMessage(
      text: "Hello! I'm your AI assistant. How can I help you today?",
      isUser: false,
      timestamp: DateTime.now(),
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      messages.add(
        ChatMessage(
          text: _messageController.text,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
    });

    String userMessage = _messageController.text;
    _messageController.clear();

    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        messages.add(
          ChatMessage(
            text: _getAIResponse(userMessage),
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });

      Future.delayed(Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    });
  }

  String _getAIResponse(String userMessage) {
    String lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('stock') || lowerMessage.contains('inventory')) {
      return "I can help you with stock management! You can view your current inventory levels, check products running low, and get restock recommendations in the Dashboard.";
    } else if (lowerMessage.contains('forecast') ||
        lowerMessage.contains('predict')) {
      return "Our AI forecast analyzes your sales history to predict future demand. Upload your sales data in the Sales Data section to generate accurate forecasts.";
    } else if (lowerMessage.contains('product')) {
      return "To add a new product, go to the 'Add Product' tab and fill in the details including product name, SKU, pricing, and stock quantity.";
    } else if (lowerMessage.contains('help')) {
      return "I can assist you with:\n• Stock management\n• Sales forecasting\n• Product information\n• Dashboard insights\n\nWhat would you like to know more about?";
    } else if (lowerMessage.contains('risk')) {
      return "Risk levels are calculated based on days until stockout:\n• Low Risk: >7 days\n• Medium Risk: 4-7 days\n• High Risk: <4 days\n\nCheck the Dashboard for detailed risk analysis.";
    } else {
      return "I understand you're asking about: \"$userMessage\". Could you provide more details so I can assist you better?";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        elevation: 4,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.blue[600],
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0), // optional padding
                child: Image.asset(
                  'assets/icon/robot.png',
                  width: 28,
                  height: 28,
                ),
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Assistant',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Online',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(messages[index]);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.blue[600] : Colors.grey[200],
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: message.isUser
                ? Radius.circular(4)
                : Radius.circular(16),
            bottomLeft: message.isUser
                ? Radius.circular(16)
                : Radius.circular(4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                fontSize: 15,
                color: message.isUser ? Colors.white : Colors.grey[800],
                height: 1.4,
              ),
            ),
            SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                fontSize: 11,
                color: message.isUser ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.blue[600],
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _sendMessage,
              icon: Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

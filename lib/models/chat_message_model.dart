class ChatMessage {
  final String text;
  final String senderId;
  final DateTime timestamp; 

  ChatMessage({
    required this.text,
    required this.senderId,
    required this.timestamp,
  });
}
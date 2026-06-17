class ChatMessage {
  final String id;
  final String autor; // usuario ou ia
  final String texto;

  ChatMessage({
    required this.id,
    required this.autor,
    required this.texto,
  });
}

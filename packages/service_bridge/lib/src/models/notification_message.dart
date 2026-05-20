/// Represents a push notification message.
class NotificationMessage {
  /// Creates a [NotificationMessage].
  const NotificationMessage({this.title, this.body, this.data = const {}, this.imageUrl, this.messageId});

  /// Notification title.
  final String? title;

  /// Notification body text.
  final String? body;

  /// Custom data payload.
  final Map<String, dynamic> data;

  /// Image URL for rich notifications.
  final String? imageUrl;

  /// Unique message identifier.
  final String? messageId;

  @override
  String toString() => 'NotificationMessage(title: $title, body: $body, messageId: $messageId)';
}

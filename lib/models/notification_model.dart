// lib/models/notification_model.dart
enum NotificationType {
  info,
  success,
  warning,
  error,
  appointment,
  payment,
  reminder,
  promotion,
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType? type;
  final DateTime timestamp;
  final bool isRead;
  final String? userId;
  final String? consentFormId;
  final String? appointmentId;
  final String? imageUrl;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    this.type,
    required this.timestamp,
    this.isRead = false,
    this.userId,
    this.consentFormId,
    this.appointmentId,
    this.imageUrl,
    this.data,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    String? userId,
    String? consentFormId,
    String? appointmentId,
    String? imageUrl,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      userId: userId ?? this.userId,
      consentFormId: consentFormId ?? this.consentFormId,
      appointmentId: appointmentId ?? this.appointmentId,
      imageUrl: imageUrl ?? this.imageUrl,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type?.name,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'userId': userId,
      'consentFormId': consentFormId,
      'appointmentId': appointmentId,
      'imageUrl': imageUrl,
      'data': data,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] != null
          ? NotificationType.values.firstWhere(
            (e) => e.name == json['type'],
        orElse: () => NotificationType.info,
      )
          : null,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      isRead: json['isRead'] ?? false,
      userId: json['userId'],
      consentFormId: json['consentFormId'],
      appointmentId: json['appointmentId'],
      imageUrl: json['imageUrl'],
      data: json['data'],
    );
  }

  // Helper method to get type label
  String get typeLabel {
    return type?.name ?? 'info';
  }

  // Helper method to get icon based on type
  String get icon {
    switch (type) {
      case NotificationType.success:
        return '✅';
      case NotificationType.warning:
        return '⚠️';
      case NotificationType.error:
        return '❌';
      case NotificationType.appointment:
        return '📅';
      case NotificationType.payment:
        return '💰';
      case NotificationType.reminder:
        return '🔔';
      case NotificationType.promotion:
        return '🎉';
      default:
        return 'ℹ️';
    }
  }

  // Helper method to get color based on type
  String get color {
    switch (type) {
      case NotificationType.success:
        return 'green';
      case NotificationType.warning:
        return 'orange';
      case NotificationType.error:
        return 'red';
      default:
        return 'blue';
    }
  }
}
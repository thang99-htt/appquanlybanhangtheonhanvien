class Notifications {
  final int? id;
  final String? message;
  final String? sendby;
  final DateTime? date;
  final int? readed;

  Notifications({
    this.id,
    this.message,
    this.sendby,
    this.date,
    this.readed,
  });

  Notifications copyWith({
    int? id,
    String? message,
    String? sendby,
    DateTime? date,
    int? readed,
  }) {
    return Notifications(
      id: id ?? this.id,
      message: message ?? this.message,
      sendby: sendby ?? this.sendby,
      date: date ?? this.date,
      readed: readed ?? this.readed,
    );
  }
}

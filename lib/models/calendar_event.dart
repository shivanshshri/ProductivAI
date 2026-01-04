class CalendarEvent {
  final String subject;
  final DateTime start;
  final DateTime end;
  final bool isAllDay;

  CalendarEvent({
    required this.subject,
    required this.start,
    required this.end,
    required this.isAllDay,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      subject: json['subject'] ?? 'No Title',
      start: DateTime.parse(json['start']['dateTime']),
      end: DateTime.parse(json['end']['dateTime']),
      isAllDay: json['isAllDay'] ?? false,
    );
  }

  // Calculate meeting duration in minutes
  int getDurationInMinutes() {
    return end.difference(start).inMinutes;
  }
}
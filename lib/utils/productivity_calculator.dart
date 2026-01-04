import 'package:ai_app/models/calendar_event.dart';

class ProductivityCalculator {

  static int calculateScore(List<CalendarEvent> events) {
    // Total workday in minutes (8 hours)
    const int workdayMinutes = 480;

    // Calculate total meeting time
    int totalMeetingMinutes = 0;
    for (var event in events) {
      totalMeetingMinutes += event.getDurationInMinutes();
    }

    // Calculate meeting load percentage
    double meetingLoad = totalMeetingMinutes / workdayMinutes;

    // Calculate productivity score
    int score = (100 - (meetingLoad * 100)).round();

    // Ensure score is between 0 and 100
    return score.clamp(0, 100);
  }
}

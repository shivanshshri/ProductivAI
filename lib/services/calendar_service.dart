import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ai_app/models/calendar_event.dart';

// services/calendar_service.dart
class CalendarService {

  Future<Map<String, dynamic>> getUserInfo(String accessToken) async {
    print('👤 Fetching user info...');

    final url = Uri.parse('https://graph.microsoft.com/v1.0/me');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    print('User info status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ User info loaded: ${data['displayName']}');
      return data;
    } else {
      print('❌ Failed to load user info: ${response.body}');
      throw Exception('Failed to load user info: ${response.statusCode}');
    }
  }

  Future<List<CalendarEvent>> getTodaysEvents(String accessToken) async {
    try {
      // Get today's date range
      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
      DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      String startDateTime = startOfDay.toUtc().toIso8601String();
      String endDateTime = endOfDay.toUtc().toIso8601String();

      print('📅 Fetching calendar events...');
      print('🔑 Access Token (first 50 chars): ${accessToken.substring(0, 50)}...');
      print('📆 Start: $startDateTime');
      print('📆 End: $endDateTime');

      final url = Uri.parse(
          'https://graph.microsoft.com/v1.0/me/calendarView'
              '?startDateTime=$startDateTime'
              '&endDateTime=$endDateTime'
              '&\$select=subject,start,end,isAllDay'
              '&\$orderby=start/dateTime'
      );

      print('🌐 URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      print('📊 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<CalendarEvent> events = [];

        for (var event in data['value']) {
          events.add(CalendarEvent.fromJson(event));
        }

        print('✅ Successfully loaded ${events.length} events');
        return events;
      } else {
        // Decode error response
        try {
          final errorData = json.decode(response.body);
          print('❌ Error Details: $errorData');
        } catch (e) {
          print('❌ Could not parse error response');
        }
        throw Exception('Failed to load calendar: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Calendar fetch error: $e');
      rethrow;
    }
  }

  // Test basic user access
  Future<void> testUserAccess(String accessToken) async {
    print('🧪 Testing User.Read permission...');

    final url = Uri.parse('https://graph.microsoft.com/v1.0/me');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    print('User.Read test: ${response.statusCode}');
    if (response.statusCode == 200) {
      print('✅ User.Read works!');
      print('User data: ${response.body}');
    } else {
      print('❌ User.Read failed: ${response.body}');
    }
  }

  // Test calendar list access
  Future<void> testCalendarAccess(String accessToken) async {
    print('🧪 Testing Calendars.Read permission...');

    final url = Uri.parse('https://graph.microsoft.com/v1.0/me/calendars');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    print('Calendars.Read test: ${response.statusCode}');
    if (response.statusCode == 200) {
      print('✅ Calendars.Read works!');
      print('Calendars: ${response.body}');
    } else {
      print('❌ Calendars.Read failed: ${response.body}');
    }
  }
}
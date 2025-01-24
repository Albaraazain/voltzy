import 'package:intl/intl.dart';

String formatDateTime(DateTime dateTime) {
  return DateFormat('MMM d, y h:mm a').format(dateTime);
}

String formatDate(DateTime date) {
  return DateFormat('MMM d, y').format(date);
}

String formatTime(DateTime time) {
  return DateFormat('h:mm a').format(time);
}

String formatDateRange(DateTime start, DateTime end) {
  if (start.year == end.year &&
      start.month == end.month &&
      start.day == end.day) {
    return '${formatDate(start)} ${formatTime(start)} - ${formatTime(end)}';
  }
  return '${formatDateTime(start)} - ${formatDateTime(end)}';
}

String getRelativeTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inDays > 7) {
    return formatDate(dateTime);
  } else if (difference.inDays > 0) {
    return '${difference.inDays}d ago';
  } else if (difference.inHours > 0) {
    return '${difference.inHours}h ago';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes}m ago';
  } else {
    return 'Just now';
  }
}

String getDayName(int dayOfWeek) {
  switch (dayOfWeek) {
    case 1:
      return 'Monday';
    case 2:
      return 'Tuesday';
    case 3:
      return 'Wednesday';
    case 4:
      return 'Thursday';
    case 5:
      return 'Friday';
    case 6:
      return 'Saturday';
    case 7:
      return 'Sunday';
    default:
      return '';
  }
}

String getShortDayName(int dayOfWeek) {
  switch (dayOfWeek) {
    case 1:
      return 'Mon';
    case 2:
      return 'Tue';
    case 3:
      return 'Wed';
    case 4:
      return 'Thu';
    case 5:
      return 'Fri';
    case 6:
      return 'Sat';
    case 7:
      return 'Sun';
    default:
      return '';
  }
}

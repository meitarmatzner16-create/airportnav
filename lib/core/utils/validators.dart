class Validators {
  Validators._();

  static bool isValidFlightNumber(String value) {
    final regex = RegExp(r'^[A-Z]{2}\d{1,4}$');
    return regex.hasMatch(value.toUpperCase().trim());
  }

  static bool isValidIataCode(String value) {
    final regex = RegExp(r'^[A-Z]{3}$');
    return regex.hasMatch(value.toUpperCase().trim());
  }

  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  static String timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}

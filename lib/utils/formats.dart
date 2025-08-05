// lib/utils/date_format.dart

String formatDate(DateTime? dateTime, {String separator = '-'}) {
  if (dateTime == null) return '';
  return "${dateTime.year}${separator}${dateTime.month.toString().padLeft(2, '0')}${separator}${dateTime.day.toString().padLeft(2, '0')}";
}

String formatDateTime(DateTime? dateTime) {
  if (dateTime == null) return '';
  return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} "
      "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
}

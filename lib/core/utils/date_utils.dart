bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

DateTime startOfDay(DateTime date) => DateTime(date.year, date.month, date.day);

DateTime startOfMonth(DateTime date) => DateTime(date.year, date.month);

int daysInMonth(DateTime date) => DateTime(date.year, date.month + 1, 0).day;

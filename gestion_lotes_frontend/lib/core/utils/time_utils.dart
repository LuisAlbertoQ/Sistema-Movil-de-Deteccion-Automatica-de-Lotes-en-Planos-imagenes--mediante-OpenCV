// time_utils.dart
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

class TimeUtils {
  static void initialize() {
    tzdata.initializeTimeZones(); // Solo llamar una vez al inicio de la app
  }

  // Convierte cualquier DateTime a hora de Lima
  static DateTime toLimaTime(DateTime dateTime) {
    final lima = tz.getLocation('America/Lima');
    return tz.TZDateTime.from(dateTime, lima);
  }

  // Formatea fechas consistentemente
  static String formatToLimaTime(DateTime dateTime, {String format = 'yyyy-MM-dd HH:mm:ss'}) {
    final limaTime = toLimaTime(dateTime);
    return DateFormat(format).format(limaTime);
  }

  // Parsea strings desde la API directamente a hora de Lima
  static DateTime parseFromApi(String dateString) {
    final dateTime = DateTime.parse(dateString).toLocal();
    return toLimaTime(dateTime);
  }
}
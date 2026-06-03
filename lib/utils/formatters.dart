import 'dart:math' as math;

// I got help from AI

/// String formatting helpers used across screens.
///
/// Keeping these in one place means UI tweaks (e.g. switching from "42¢" to
/// "$0.42") happen once, not in twelve different widgets.
class Formatters {
  Formatters._();

  /// Formats a 0..100 cent price as "42¢".
  static String price(int cents) => '$cents¢';

  /// Formats a balance in cents as "$1,234.56".
  static String balance(int cents) {
    final double dollars = cents / 100.0;
    final String fixed = dollars.toStringAsFixed(2);
    // Insert thousands separators on the integer part.
    final List<String> parts = fixed.split('.');
    final String intPart = parts[0];
    final StringBuffer buf = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(',');
      buf.write(intPart[i]);
    }
    return '\$${buf.toString()}.${parts[1]}';
  }

  static String distance(double lat1, double lng1, double lat2, double lng2) {
    const earthRadiusMeters = 6371000.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) * math.cos(_toRadians(lat2)) *
            math.sin(dLng / 2) * math.sin(dLng / 2);
    final meters = earthRadiusMeters * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1609.344).toStringAsFixed(1)} mi';
  }

  static double _toRadians(double d) => d * math.pi / 180.0;
}

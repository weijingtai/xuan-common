import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sweph/sweph.dart';

import '../enums/enum_twenty_four_jie_qi.dart';
import '../utils/celestial_rise_set_calculator.dart';

class JieQiRiseSetCard extends StatelessWidget {
  final TwentyFourJieQi jieQi;
  final DateTime jieQiDate;
  final double longitude;
  final double latitude;
  final double? altitude;
  final String timezone;
  final Color? accentColor;
  final bool isCompact;

  const JieQiRiseSetCard({
    super.key,
    required this.jieQi,
    required this.jieQiDate,
    required this.longitude,
    required this.latitude,
    this.altitude,
    this.timezone = 'Asia/Shanghai',
    this.accentColor,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final riseSetInfo = CelestialRiseSetCalculator.calculateDaily(
      utcDateTime: jieQiDate.toUtc(),
      longitude: longitude,
      latitude: latitude,
      altitude: altitude ?? 0,
      includeTwilight: false,
    );

    final localTimezone = timezone;

    final sunRise = riseSetInfo.sun.rise?.toLocal();
    final sunSet = riseSetInfo.sun.set_?.toLocal();
    final moonRise = riseSetInfo.moon.rise?.toLocal();
    final moonSet = riseSetInfo.moon.set_?.toLocal();

    final color = accentColor ?? _getColorForJieQi(jieQi);

    if (isCompact) {
      return _buildCompactCard(color, sunRise, sunSet, moonRise, moonSet);
    }

    return _buildFullCard(color, sunRise, sunSet, moonRise, moonSet);
  }

  Widget _buildCompactCard(
    Color color,
    DateTime? sunRise,
    DateTime? sunSet,
    DateTime? moonRise,
    DateTime? moonSet,
  ) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            jieQi.name,
            style: GoogleFonts.notoSerif(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          _buildTimeRow('日', sunRise, sunSet, color),
          const SizedBox(height: 2),
          _buildTimeRow('月', moonRise, moonSet, color),
        ],
      ),
    );
  }

  Widget _buildFullCard(
    Color color,
    DateTime? sunRise,
    DateTime? sunSet,
    DateTime? moonRise,
    DateTime? moonSet,
  ) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.wb_sunny, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                jieQi.name,
                style: GoogleFonts.notoSerif(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),
          _buildRiseSetRow(
            icon: Icons.wb_sunny_outlined,
            label: '日出',
            time: sunRise,
            color: Colors.orange,
          ),
          const SizedBox(height: 4),
          _buildRiseSetRow(
            icon: Icons.wb_twilight,
            label: '日落',
            time: sunSet,
            color: Colors.deepOrange,
          ),
          const SizedBox(height: 8),
          _buildRiseSetRow(
            icon: Icons.nightlight_round,
            label: '月出',
            time: moonRise,
            color: Colors.indigo,
          ),
          const SizedBox(height: 4),
          _buildRiseSetRow(
            icon: Icons.nightlight_outlined,
            label: '月落',
            time: moonSet,
            color: Colors.blueGrey,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRow(
      String label, DateTime? rise, DateTime? set, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 9, color: color.withValues(alpha: 0.7)),
        ),
        const SizedBox(width: 4),
        Text(
          rise != null ? _formatTime(rise) : '--:--',
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
        ),
        const Text(' / ', style: TextStyle(fontSize: 8)),
        Text(
          set != null ? _formatTime(set) : '--:--',
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildRiseSetRow({
    required IconData icon,
    required String label,
    required DateTime? time,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const Spacer(),
        Text(
          time != null ? _formatTime(time) : '--:--',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Color _getColorForJieQi(TwentyFourJieQi jieQi) {
    switch (jieQi) {
      case TwentyFourJieQi.DONG_ZHI:
      case TwentyFourJieQi.XIAO_HAN:
      case TwentyFourJieQi.DA_HAN:
      case TwentyFourJieQi.LI_DONG:
      case TwentyFourJieQi.XIAO_XUE:
      case TwentyFourJieQi.DA_XUE:
        return Colors.blue;
      case TwentyFourJieQi.LI_CHUN:
      case TwentyFourJieQi.YU_SHUI:
      case TwentyFourJieQi.JING_ZHE:
      case TwentyFourJieQi.CHUN_FEN:
      case TwentyFourJieQi.QING_MING:
      case TwentyFourJieQi.GU_YU:
        return Colors.green;
      case TwentyFourJieQi.LI_XIA:
      case TwentyFourJieQi.XIAO_MAN:
      case TwentyFourJieQi.MANG_ZHONG:
      case TwentyFourJieQi.XIA_ZHI:
      case TwentyFourJieQi.XIAO_SHU:
      case TwentyFourJieQi.DA_SHU:
        return Colors.orange;
      case TwentyFourJieQi.LI_QIU:
      case TwentyFourJieQi.CHU_SHU:
      case TwentyFourJieQi.BAI_LU:
      case TwentyFourJieQi.QIU_FEN:
      case TwentyFourJieQi.HAN_LU:
      case TwentyFourJieQi.SHUANG_JIANG:
        return Colors.brown;
    }
  }
}

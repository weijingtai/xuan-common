import 'package:flutter/material.dart';
import 'package:common/enums/enum_twenty_four_jie_qi.dart';
import 'package:common/widgets/jie_qi_rise_set_card.dart';
import 'package:common/widgets/twenty_four_jie_qi_tag.dart';
import 'package:sweph/sweph.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();

  try {
    await Sweph.init();
  } catch (e) {
    debugPrint('Sweph init failed: $e');
  }

  runApp(const MaterialApp(home: JieQiTagDemoPage()));
}

class JieQiTagDemoPage extends StatelessWidget {
  const JieQiTagDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('节气卡片 Demo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '带日月出没的节气卡片 (完整模式)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 260,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: TwentyFourJieQi.values.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final jieQi = TwentyFourJieQi.values[index];
                    final jieQiDate = _getJieQiDate(2024, jieQi);
                    return JieQiRiseSetCard(
                      jieQi: jieQi,
                      jieQiDate: jieQiDate,
                      longitude: 121.47,
                      latitude: 31.23,
                      timezone: 'Asia/Shanghai',
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                '带日月出没的节气卡片 (紧凑模式)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: TwentyFourJieQi.values.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final jieQi = TwentyFourJieQi.values[index];
                    final jieQiDate = _getJieQiDate(2024, jieQi);
                    return JieQiRiseSetCard(
                      jieQi: jieQi,
                      jieQiDate: jieQiDate,
                      longitude: 121.47,
                      latitude: 31.23,
                      timezone: 'Asia/Shanghai',
                      isCompact: true,
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                '传统节气标签 (仅名称)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              const Text(
                '横向模式 (isHor: true)',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 60,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: TwentyFourJieQi.values.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final jieQi = TwentyFourJieQi.values[index];
                    return TwentyFourJieQiTag(
                      jieQi: jieQi,
                      fontColor: Colors.blue[700]!,
                      borderColor: Colors.blue[300]!,
                      backgroundColor: Colors.blue[50]!,
                      isBold: index % 3 == 0,
                      isHor: true,
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '竖向模式 (isHor: false)',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: TwentyFourJieQi.values.map((jieQi) {
                  final colors = _getColorsForIndex(jieQi.index);
                  return TwentyFourJieQiTag(
                    jieQi: jieQi,
                    fontColor: colors.$1,
                    borderColor: colors.$2,
                    backgroundColor: colors.$3,
                    isBold: jieQi.index % 4 == 0,
                    isHor: false,
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              const Text(
                '四立二至二分 (重点节气)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildKeyJieQi(TwentyFourJieQi.DONG_ZHI, Colors.blue),
                  _buildKeyJieQi(TwentyFourJieQi.LI_CHUN, Colors.green),
                  _buildKeyJieQi(TwentyFourJieQi.CHUN_FEN, Colors.green),
                  _buildKeyJieQi(TwentyFourJieQi.LI_XIA, Colors.orange),
                  _buildKeyJieQi(TwentyFourJieQi.XIA_ZHI, Colors.red),
                  _buildKeyJieQi(TwentyFourJieQi.LI_QIU, Colors.orange),
                  _buildKeyJieQi(TwentyFourJieQi.QIU_FEN, Colors.green),
                  _buildKeyJieQi(TwentyFourJieQi.LI_DONG, Colors.blue),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  DateTime _getJieQiDate(int year, TwentyFourJieQi jieQi) {
    final dates = {
      TwentyFourJieQi.DONG_ZHI: DateTime(year, 12, 21),
      TwentyFourJieQi.XIAO_HAN: DateTime(year, 1, 5),
      TwentyFourJieQi.DA_HAN: DateTime(year, 1, 20),
      TwentyFourJieQi.LI_CHUN: DateTime(year, 2, 4),
      TwentyFourJieQi.YU_SHUI: DateTime(year, 2, 19),
      TwentyFourJieQi.JING_ZHE: DateTime(year, 3, 5),
      TwentyFourJieQi.CHUN_FEN: DateTime(year, 3, 20),
      TwentyFourJieQi.QING_MING: DateTime(year, 4, 5),
      TwentyFourJieQi.GU_YU: DateTime(year, 4, 20),
      TwentyFourJieQi.LI_XIA: DateTime(year, 5, 5),
      TwentyFourJieQi.XIAO_MAN: DateTime(year, 5, 21),
      TwentyFourJieQi.MANG_ZHONG: DateTime(year, 6, 6),
      TwentyFourJieQi.XIA_ZHI: DateTime(year, 6, 21),
      TwentyFourJieQi.XIAO_SHU: DateTime(year, 7, 7),
      TwentyFourJieQi.DA_SHU: DateTime(year, 7, 23),
      TwentyFourJieQi.LI_QIU: DateTime(year, 8, 8),
      TwentyFourJieQi.CHU_SHU: DateTime(year, 8, 23),
      TwentyFourJieQi.BAI_LU: DateTime(year, 9, 8),
      TwentyFourJieQi.QIU_FEN: DateTime(year, 9, 23),
      TwentyFourJieQi.HAN_LU: DateTime(year, 10, 8),
      TwentyFourJieQi.SHUANG_JIANG: DateTime(year, 10, 23),
      TwentyFourJieQi.LI_DONG: DateTime(year, 11, 7),
      TwentyFourJieQi.XIAO_XUE: DateTime(year, 11, 22),
      TwentyFourJieQi.DA_XUE: DateTime(year, 12, 7),
    };
    return dates[jieQi] ?? DateTime(year, 6, 15);
  }

  Widget _buildKeyJieQi(TwentyFourJieQi jieQi, Color baseColor) {
    return TwentyFourJieQiTag(
      jieQi: jieQi,
      fontColor: baseColor,
      borderColor: baseColor.withValues(alpha: 0.5),
      backgroundColor: baseColor.withValues(alpha: 0.1),
      isBold: true,
      isHor: true,
    );
  }

  (Color, Color, Color) _getColorsForIndex(int index) {
    final colors = [
      (Colors.blue[700]!, Colors.blue[300]!, Colors.blue[50]!),
      (Colors.green[700]!, Colors.green[300]!, Colors.green[50]!),
      (Colors.orange[700]!, Colors.orange[300]!, Colors.orange[50]!),
      (Colors.red[700]!, Colors.red[300]!, Colors.red[50]!),
      (Colors.purple[700]!, Colors.purple[300]!, Colors.purple[50]!),
      (Colors.teal[700]!, Colors.teal[300]!, Colors.teal[50]!),
    ];
    return colors[index % colors.length];
  }
}

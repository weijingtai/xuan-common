import 'package:flutter/material.dart';
import 'package:common/enums/enum_twenty_four_jie_qi.dart';
import 'package:common/widgets/twenty_four_jie_qi_tag.dart';

void main() {
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '横向模式 (isHor: true)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 32),
              const Text(
                '竖向模式 (isHor: false)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
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

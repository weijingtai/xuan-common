import 'package:common/features/liu_yun/themes/ink_theme.dart';
import 'package:common/widgets/yun_liu_list_tile_card/yun_liu_list_tile_card_widget.dart';
import 'package:flutter/material.dart';

import 'yun_liu_demo_data_helper.dart';

void main() {
  runApp(const MaterialApp(home: YunLiuDemoPage()));
}

class YunLiuDemoPage extends StatefulWidget {
  const YunLiuDemoPage({super.key});

  @override
  State<YunLiuDemoPage> createState() => _YunLiuDemoPageState();
}

class _YunLiuDemoPageState extends State<YunLiuDemoPage> {
  late List<DaYunDisplayData> _mockData;

  @override
  void initState() {
    super.initState();
    _mockData = _buildMockData();
  }

  List<DaYunDisplayData> _buildMockData() {
    // Generates the real DaYun calculation data (using fake birth date set in the helper)
    return YunLiuDemoDataHelper.buildRealDaYunData();
  }

  @override
  Widget build(BuildContext context) {
    // Current date values for initial scrolling
    final today = DateTime.now();

    return Scaffold(
      backgroundColor: InkTheme.paperStone,
      appBar: AppBar(
        title: const Text('大运流年 · 三层级联'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: YunLiuListTileCardWidget(
            daYunList: _mockData,
            initialSelectedDaYunIndex: 0,
            initialSelectedLiuNianIndex: 0,
            initialSelectedLiuYueIndex: today.month - 1,
            fetchLiuRiData: YunLiuDemoDataHelper.fetchLiuRiData,
            fetchLiuShiData: YunLiuDemoDataHelper.fetchLiuShiData,
          ),
        ),
      ),
    );
  }
}

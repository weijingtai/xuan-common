import 'package:common/features/liu_yun/themes/ink_theme.dart';
import 'package:common/widgets/yun_liu_list_tile_card/yun_liu_list_tile_card_widget.dart';
import 'package:common/viewmodels/yun_liu_view_model.dart';
import 'package:common/services/yun_liu_service.dart';
import 'package:common/enums.dart';
import 'package:common/helpers/solar_lunar_datetime_helper.dart';
import 'package:common/features/datetime_details/input_info_params.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: YunLiuDemoPage()));
}

class YunLiuDemoPage extends StatefulWidget {
  const YunLiuDemoPage({super.key});

  @override
  State<YunLiuDemoPage> createState() => _YunLiuDemoPageState();
}

class _YunLiuDemoPageState extends State<YunLiuDemoPage> {
  late YunLiuViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final birthDate = DateTime(1990, 6, 15, 12, 0);
    final service = YunLiuService();
    final birthDateInfo = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
      birthDate,
      ZiShiStrategy.noDistinguishAt23,
    );

    _viewModel = YunLiuViewModel(
      service: service,
      birthDateTime: birthDate,
      gender: Gender.male,
      birthDateInfo: birthDateInfo,
    );
  }

  @override
  Widget build(BuildContext context) {
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
            viewModel: _viewModel,
          ),
        ),
      ),
    );
  }
}

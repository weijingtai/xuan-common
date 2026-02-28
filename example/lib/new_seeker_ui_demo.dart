import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:common/database/app_database.dart';
import 'package:common/database/daos/card_template_meta_dao.dart';
import 'package:common/database/daos/card_template_skill_usage_dao.dart';
import 'package:common/database/daos/card_template_setting_dao.dart';
import 'package:common/datasource/layout_template_local_data_source.dart';
import 'package:common/domain/usecases/layout_templates/delete_template_use_case.dart';
import 'package:common/domain/usecases/layout_templates/get_all_templates_use_case.dart';
import 'package:common/domain/usecases/layout_templates/get_template_by_id_use_case.dart';
import 'package:common/domain/usecases/layout_templates/save_template_use_case.dart';
import 'package:common/repositories/layout_template_repository_impl.dart';
import 'package:common/viewmodels/four_zhu_editor_view_model.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:common/features/liu_yun/da_yun_liu_nian/dayun_liunian_table_widget.dart';
import 'package:common/enums.dart';
import 'package:common/widgets/yun_liu_tree_list/yun_liu_node.dart';
import 'package:common/widgets/yun_liu_tree_list/yun_liu_tree_list.dart';
import 'package:common/widgets/yun_liu_tree_list/da_yun_tree_tile_header.dart';
import 'package:common/widgets/yun_liu_tree_list/yun_liu_tree_tile_theme.dart';
import 'package:common/features/datetime_details/datetime_details_bundle_calculation.dart';
import 'package:common/features/datetime_details/input_info_params.dart';
import 'package:common/models/divination_datetime.dart';
import 'package:common/datamodel/location.dart' as loc;
import 'package:common/widgets/editable_fourzhu_card.dart';
import 'package:common/widgets/jieqi_entry_settings_capsule.dart';
import 'package:common/widgets/jieqi_phenology_settings_capsule.dart';
import 'package:common/widgets/zi_strategy_settings_capsule.dart';
import 'package:common/widgets/lunar_date_info_card.dart';

class NewSeekerUiDemo extends StatelessWidget {
  const NewSeekerUiDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FourZhuEditorViewModel>(
          create: (ctx) {
            final localDataSource = ctx.read<LayoutTemplateLocalDataSource>();
            final repository = LayoutTemplateRepositoryImpl(
              localDataSource,
              authScopeProvider: ctx.read<AuthScopeProvider>(),
            );

            return FourZhuEditorViewModel(
              getAllTemplatesUseCase: GetAllTemplatesUseCase(repository),
              getTemplateByIdUseCase: GetTemplateByIdUseCase(repository),
              saveTemplateUseCase: SaveTemplateUseCase(repository),
              deleteTemplateUseCase: DeleteTemplateUseCase(repository),
              cardTemplateMetaDao: CardTemplateMetaDao(ctx.read<AppDatabase>()),
              cardTemplateSettingDao: CardTemplateSettingDao(
                ctx.read<AppDatabase>(),
              ),
              cardTemplateSkillUsageDao: CardTemplateSkillUsageDao(
                ctx.read<AppDatabase>(),
              ),
            )..initialize(collectionId: 'four_zhu_templates');
          },
        ),
      ],
      child: const _NewSeekerUiDemoBody(),
    );
  }
}

class _NewSeekerUiDemoBody extends StatefulWidget {
  const _NewSeekerUiDemoBody();

  @override
  State<_NewSeekerUiDemoBody> createState() => _NewSeekerUiDemoBodyState();
}

class _NewSeekerUiDemoBodyState extends State<_NewSeekerUiDemoBody> {
  DateTimeDetailsBundle? _bundle;
  bool _isLoading = true;
  bool _showTags = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final editorVm = context.read<FourZhuEditorViewModel>();
      editorVm.cardBrightnessNotifier.value = Theme.of(context).brightness;
    });
  }

  Future<void> _loadData() async {
    try {
      final params = DateTimeDetailsCalculationParams(
        inputDateTime: DateTime(1995, 6, 12, 10, 30),
        timezoneStr: 'Asia/Shanghai',
        coordinates: loc.Coordinates(
          latitude: 31.23170,
          longitude: 121.47260,
        ), // Shanghai precise
        location: loc.Location(
          preciseCoordinates: loc.Coordinates(
            latitude: 31.23170,
            longitude: 121.47260,
          ),
        ),
      );
      final bundle = await DateTimeDetailsBundleCalculation.calculate(
        params: params,
      );
      if (!mounted) return;
      setState(() {
        _bundle = bundle;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      debugPrint("Error loading datetime bundle: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Seeker UI Demo')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bundle == null
          ? const Center(child: Text('Failed to load data'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Consumer<FourZhuEditorViewModel>(
                            builder: (context, viewModel, child) {
                              if (viewModel.currentTemplate == null &&
                                  viewModel.isLoading) {
                                return const SizedBox(
                                  height: 300,
                                  width: 340,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              return EditableFourZhuCardV3(
                                dayGanZhi: JiaZi.JIA_ZI,
                                brightnessNotifier:
                                    viewModel.cardBrightnessNotifier,
                                colorPreviewModeNotifier:
                                    viewModel.colorPreviewModeNotifier,
                                cardPayloadNotifier:
                                    viewModel.cardPayloadNotifier,
                                referenceDateTime: DateTime.now(),
                                showGrip: false,
                                paddingNotifier: viewModel.paddingNotifier,
                                themeNotifier: viewModel.editableThemeNotifier,
                                rowStrategyMapper: viewModel.rowStrategyMapper,
                                pillarStrategyMapper:
                                    viewModel.pillarStrategyMapper,
                                gender: Gender.male,
                                onReorderRow: viewModel.reorderRow,
                                onInsertRow: viewModel.insertRow,
                                onDeleteRow: viewModel.deleteRow,
                                onReorderPillar: viewModel.reorderPillarGlobal,
                                onInsertPillar: viewModel.insertPillarGlobal,
                                onDeletePillar: viewModel.deletePillarGlobal,
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          ZiStrategySettingsCapsule(
                            viewMode: JieQiEntryCapsuleMode.tiny,
                            onStrategyChanged: (s) {
                              debugPrint("Zi Strategy Changed to: $s");
                            },
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LunarDateInfoCard(
                            bundle: _bundle!,
                            inUsed: _bundle!.trueSolarChineseInfo != null
                                ? EnumDatetimeType.trueSolar
                                : EnumDatetimeType.standard,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              JieQiEntrySettingsCapsule(
                                viewMode: JieQiEntryCapsuleMode.tiny,
                                onChanged: (precision) {
                                  debugPrint(
                                    "JieQi Precision Changed to: $precision",
                                  );
                                },
                              ),
                              const SizedBox(width: 12),
                              JieQiPhenologySettingsCapsule(
                                viewMode: JieQiEntryCapsuleMode.tiny,
                                onChanged: (jq, ph) {
                                  debugPrint(
                                    "JieQi Phenology Changed to: $jq, $ph",
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 32,
                    child: const DaYunLiuNianTableDemoWidget(
                      scale: 0.82,
                      fitHeight: false,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Tree List Constrained Width matching the right-side capsule cards
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Card(
                        elevation: 0,
                        color: Theme.of(context).cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Theme.of(context).dividerColor.withAlpha(20),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    '大运树状列表 (100年全周期预览)',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Text(
                                        '显示标签',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      Transform.scale(
                                        scale: 0.7,
                                        child: Switch(
                                          value: _showTags,
                                          activeColor: const Color(
                                            0xFFA62C2B,
                                          ), // Vermilion
                                          onChanged: (val) {
                                            setState(() => _showTags = val);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Builder(
                                builder: (context) {
                                  // Simplified Mock Generation for 10 DaYun periods
                                  final nodes = List.generate(10, (d) {
                                    final startYear = 2024 + (d * 10);
                                    final startAge = 28 + (d * 10);
                                    final jiaZi =
                                        JiaZi.values[(JiaZi.JIA_CHEN.index +
                                                d * 10) %
                                            60];

                                    // Generate 10 Liu Nian for each DaYun
                                    final liuNianItems = List.generate(10, (i) {
                                      return JiaZi.values[(jiaZi.index + i) %
                                          60];
                                    });

                                    // 12 Months mock
                                    final liuYueMock = List.generate(12, (j) {
                                      return JiaZi
                                          .values[(JiaZi.BING_YIN.index + j) %
                                          60];
                                    });

                                    return YunLiuNode(
                                      title: '${jiaZi.name}大运',
                                      type: YunLiuNodeType.daYun,
                                      customHeader: DaYunTreeTileHeader(
                                        daYunGanZhi: jiaZi,
                                        ganGod: EnumTenGods.ZhenCai,
                                        hiddenGans: const [
                                          (
                                            gan: TianGan.WU,
                                            hiddenGods: EnumTenGods.ZhenCai,
                                          ),
                                          (
                                            gan: TianGan.YI,
                                            hiddenGods: EnumTenGods.ZhengGuan,
                                          ),
                                          (
                                            gan: TianGan.BING,
                                            hiddenGods: EnumTenGods.PanYin,
                                          ),
                                        ],
                                        startYear: startYear,
                                        startAge: startAge,
                                        yearsCount: 10,
                                        index: d + 1,
                                        liuNianList: liuNianItems,
                                        theme: YunLiuTreeTileTheme.daYun(),
                                        showTags: true,
                                        showSubLabels: _showTags,
                                      ),
                                      children: List.generate(10, (i) {
                                        final y = startYear + i;
                                        final lnJiaZi = liuNianItems[i];
                                        return YunLiuNode(
                                          title: '$y ${lnJiaZi.name}年',
                                          type: YunLiuNodeType.liuNian,
                                          customHeader: LiuNianTreeTileHeader(
                                            year: y,
                                            age: startAge + i,
                                            jiaZi: lnJiaZi,
                                            liuYueList: liuYueMock,
                                            theme:
                                                YunLiuTreeTileTheme.liuNian(),
                                            showSubLabels: _showTags,
                                            ganGod: EnumTenGods.ZhenCai,
                                            hiddenGans: const [
                                              (
                                                gan: TianGan.WU,
                                                hiddenGods: EnumTenGods.ZhenCai,
                                              ),
                                              (
                                                gan: TianGan.YI,
                                                hiddenGods:
                                                    EnumTenGods.ZhengGuan,
                                              ),
                                              (
                                                gan: TianGan.BING,
                                                hiddenGods: EnumTenGods.PanYin,
                                              ),
                                            ],
                                          ),
                                          children: List.generate(12, (j) {
                                            return YunLiuNode(
                                              title:
                                                  '${j + 1}月 ${liuYueMock[j].name}',
                                              type: YunLiuNodeType.liuYue,
                                              customHeader: LiuYueTreeTileHeader(
                                                jiaZi: liuYueMock[j],
                                                monthName: (j < 10)
                                                    ? '${j + 1}月'
                                                    : (j == 10)
                                                    ? '冬月'
                                                    : '腊月',
                                                description: '本月运势概览...',
                                                theme:
                                                    YunLiuTreeTileTheme.liuYue(),
                                                showSubLabels: _showTags,
                                                ganGod: EnumTenGods.BiJian,
                                                hiddenGans: const [
                                                  (
                                                    gan: TianGan.JIA,
                                                    hiddenGods:
                                                        EnumTenGods.BiJian,
                                                  ),
                                                  (
                                                    gan: TianGan.BING,
                                                    hiddenGods:
                                                        EnumTenGods.ShiShen,
                                                  ),
                                                  (
                                                    gan: TianGan.WU,
                                                    hiddenGods:
                                                        EnumTenGods.PanGuan,
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                        );
                                      }),
                                    );
                                  });

                                  return YunLiuTreeList(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    nodes: nodes,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

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
                  Card(
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
                          const Text(
                            '大运树状列表 (Tree List Demo)',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Builder(
                            builder: (context) {
                              const liuNianList = [
                                JiaZi.JIA_CHEN,
                                JiaZi.YI_SI,
                                JiaZi.BING_WU,
                                JiaZi.DING_WEI,
                                JiaZi.WU_SHEN,
                                JiaZi.JI_YOU,
                                JiaZi.GENG_XU,
                                JiaZi.XIN_HAI,
                                JiaZi.REN_ZI,
                                JiaZi.GUI_CHOU,
                              ];
                              const liuYueMock = [
                                JiaZi.BING_YIN,
                                JiaZi.DING_MAO,
                                JiaZi.WU_CHEN,
                                JiaZi.JI_SI,
                                JiaZi.GENG_WU,
                                JiaZi.XIN_WEI,
                                JiaZi.REN_SHEN,
                                JiaZi.GUI_YOU,
                                JiaZi.JIA_XU,
                                JiaZi.YI_HAI,
                                JiaZi.BING_ZI,
                                JiaZi.DING_CHOU,
                              ];
                              return YunLiuTreeList(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                nodes: [
                                  YunLiuNode(
                                    title: '甲辰大运',
                                    type: YunLiuNodeType.daYun,
                                    customHeader: DaYunTreeTileHeader(
                                      daYunGanZhi: JiaZi.JIA_CHEN,
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
                                      startYear: 2024,
                                      startAge: 28,
                                      yearsCount: 10,
                                      index: 1,
                                      liuNianList: liuNianList,
                                      theme: YunLiuTreeTileTheme.daYun(),
                                    ),
                                    children: [
                                      for (var i = 0; i < 10; i++)
                                        YunLiuNode(
                                          title: '202${4 + i} 甲辰年',
                                          type: YunLiuNodeType.liuNian,
                                          customHeader: YunLiuPillarHeader(
                                            jiaZi: liuNianList[i],
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
                                            label: '202${4 + i}',
                                            theme:
                                                YunLiuTreeTileTheme.liuNian(),
                                            content: LiuNianHeaderRightContent(
                                              year: 2024 + i,
                                              age: 28 + i,
                                              liuYueList: liuYueMock,
                                              theme:
                                                  YunLiuTreeTileTheme.liuNian(),
                                            ),
                                          ),
                                          children: [
                                            for (var j = 0; j < 12; j++)
                                              YunLiuNode(
                                                title:
                                                    '${j + 1}月 ${liuYueMock[j].name}',
                                                type: YunLiuNodeType.liuYue,
                                                customHeader: YunLiuPillarHeader(
                                                  jiaZi: liuYueMock[j],
                                                  label: (j < 10)
                                                      ? '${j + 1}月'
                                                      : (j == 10)
                                                      ? '冬月'
                                                      : '腊月',
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
                                                  theme:
                                                      YunLiuTreeTileTheme.liuYue(),
                                                  content: LiuYueHeaderRightContent(
                                                    monthName: (j < 10)
                                                        ? '${j + 1}月'
                                                        : (j == 10)
                                                        ? '冬月'
                                                        : '腊月',
                                                    description: '本月运势概览...',
                                                    theme:
                                                        YunLiuTreeTileTheme.liuYue(),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

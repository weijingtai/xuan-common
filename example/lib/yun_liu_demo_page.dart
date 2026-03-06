import 'package:common/enums.dart';
import 'package:common/features/liu_yun/themes/ink_theme.dart';
import 'package:common/widgets/yun_liu_list_tile_card/yun_liu_list_tile_card_widget.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: YunLiuDemoPage()));
}

/// Demo page replicating the list9.html three-tier cascading design.
class YunLiuDemoPage extends StatelessWidget {
  const YunLiuDemoPage({super.key});

  // ── Helper: resolve JiaZi from Chinese GanZhi string ──
  static JiaZi _jz(String gz) => JiaZi.getFromGanZhiValue(gz)!;

  // ── Helper: resolve TianGan from Chinese character ──
  static TianGan _tg(String g) => TianGan.getFromValue(g)!;

  // ── Helper: resolve EnumTenGods from full Chinese name ──
  // Note: list9.html uses '七杀' as alias for '偏官' (PanGuan).
  static EnumTenGods _god(String name) {
    if (name == '七杀') return EnumTenGods.PanGuan;
    return EnumTenGods.values.firstWhere((e) => e.name == name);
  }

  // ── Helper: build hidden gans list ──
  static List<({TianGan gan, EnumTenGods hiddenGods})> _h(
    List<List<String>> pairs,
  ) {
    return pairs.map((p) => (gan: _tg(p[0]), hiddenGods: _god(p[1]))).toList();
  }

  // ── Build LiuYue mock data (shared across all LiuNian) ──
  static List<LiuYueDisplayData> _buildLiuYueMock() {
    const monthLabels = [
      '正月',
      '二月',
      '三月',
      '四月',
      '五月',
      '六月',
      '七月',
      '八月',
      '九月',
      '十月',
      '冬月',
      '腊月',
    ];
    const monthGz = [
      '丙寅',
      '丁卯',
      '戊辰',
      '己巳',
      '庚午',
      '辛未',
      '壬申',
      '癸酉',
      '甲戌',
      '乙亥',
      '丙子',
      '丁丑',
    ];
    const monthGods = [
      '正官',
      '七杀',
      '正印',
      '偏印',
      '劫财',
      '比肩',
      '伤官',
      '食神',
      '正财',
      '偏财',
      '正官',
      '七杀',
    ];
    const monthHidden = [
      [
        ['甲', '偏财'],
        ['丙', '正官'],
        ['戊', '正印'],
      ],
      [
        ['乙', '正财'],
      ],
      [
        ['戊', '正印'],
        ['乙', '正财'],
        ['癸', '偏印'],
      ],
      [
        ['丙', '正官'],
        ['戊', '正印'],
        ['庚', '劫财'],
      ],
      [
        ['丁', '七杀'],
        ['己', '偏印'],
      ],
      [
        ['己', '偏印'],
        ['丁', '七杀'],
        ['乙', '正财'],
      ],
      [
        ['庚', '劫财'],
        ['壬', '伤官'],
        ['戊', '正印'],
      ],
      [
        ['辛', '比肩'],
      ],
      [
        ['戊', '正印'],
        ['辛', '比肩'],
        ['丁', '七杀'],
      ],
      [
        ['壬', '偏印'],
        ['甲', '偏财'],
      ],
      [
        ['癸', '偏印'],
      ],
      [
        ['己', '偏印'],
        ['癸', '偏印'],
        ['辛', '比肩'],
      ],
    ];

    return List.generate(
      12,
      (i) => LiuYueDisplayData(
        ganZhi: monthGz[i],
        tenGodName: monthGods[i],
        hidden: monthHidden[i].map((h) => (gan: h[0], tenGod: h[1])).toList(),
        monthName: monthLabels[i],
        gregorianMonth: (i + 2) > 12
            ? (i + 2) - 12
            : (i + 2), // Rough approximation: starts around February
      ),
    );
  }

  // ── Build a single LiuNian entry ──
  static LiuNianDisplayData _ln(
    String gz,
    String god,
    int year,
    int age,
    List<List<String>> hidden,
    List<LiuYueDisplayData> liuyue,
  ) {
    return (
      pillar: _jz(gz),
      ganGod: _god(god),
      hiddenGans: _h(hidden),
      year: year,
      age: age,
      liuyue: liuyue,
    );
  }

  // ── Build the full DaYun mock data (matching list9.html exactly) ──
  static List<DaYunDisplayData> buildMockData() {
    final liuyue = _buildLiuYueMock();

    return [
      // ── 大运三：丙午 ──
      (
        pillar: _jz('丙午'),
        ganGod: _god('正官'),
        hiddenGans: _h([
          ['丁', '七杀'],
          ['己', '偏印'],
        ]),
        startYear: 2044,
        startAge: 48,
        yearsCount: 10,
        liunian: [
          _ln('甲寅', '偏财', 2044, 48, [
            ['甲', '偏财'],
            ['丙', '正官'],
            ['戊', '正印'],
          ], liuyue),
          _ln('乙卯', '正财', 2045, 49, [
            ['乙', '正财'],
          ], liuyue),
          _ln('丙辰', '正官', 2046, 50, [
            ['戊', '正印'],
            ['乙', '正财'],
            ['癸', '偏印'],
          ], liuyue),
          _ln('丁巳', '七杀', 2047, 51, [
            ['丙', '正官'],
            ['戊', '正印'],
            ['庚', '劫财'],
          ], liuyue),
          _ln('戊午', '正印', 2048, 52, [
            ['丁', '七杀'],
            ['己', '偏印'],
          ], liuyue),
          _ln('己未', '偏印', 2049, 53, [
            ['己', '偏印'],
            ['丁', '七杀'],
            ['乙', '正财'],
          ], liuyue),
          _ln('庚申', '劫财', 2050, 54, [
            ['庚', '劫财'],
            ['壬', '伤官'],
            ['戊', '正印'],
          ], liuyue),
          _ln('辛酉', '比肩', 2051, 55, [
            ['辛', '比肩'],
          ], liuyue),
          _ln('壬戌', '伤官', 2052, 56, [
            ['戊', '正印'],
            ['辛', '比肩'],
            ['丁', '七杀'],
          ], liuyue),
          _ln('癸亥', '食神', 2053, 57, [
            ['壬', '伤官'],
            ['甲', '偏财'],
          ], liuyue),
        ],
      ),

      // ── 大运四：甲戌 ──
      (
        pillar: _jz('甲戌'),
        ganGod: _god('正财'),
        hiddenGans: _h([
          ['戊', '正财'],
          ['辛', '伤官'],
          ['丁', '劫财'],
        ]),
        startYear: 2054,
        startAge: 58,
        yearsCount: 10,
        liunian: [
          _ln('甲戌', '正财', 2054, 58, [
            ['戊', '正财'],
            ['辛', '伤官'],
            ['丁', '劫财'],
          ], liuyue),
          _ln('乙亥', '偏财', 2055, 59, [
            ['壬', '偏印'],
            ['甲', '偏财'],
          ], liuyue),
          _ln('丙子', '正官', 2056, 60, [
            ['癸', '正印'],
          ], liuyue),
          _ln('丁丑', '七杀', 2057, 61, [
            ['己', '偏财'],
            ['癸', '正印'],
            ['辛', '伤官'],
          ], liuyue),
          _ln('戊寅', '正印', 2058, 62, [
            ['甲', '偏财'],
            ['丙', '正官'],
            ['戊', '正印'],
          ], liuyue),
          _ln('己卯', '偏印', 2059, 63, [
            ['乙', '正财'],
          ], liuyue),
          _ln('庚辰', '劫财', 2060, 64, [
            ['戊', '正印'],
            ['乙', '正财'],
            ['癸', '偏印'],
          ], liuyue),
          _ln('辛巳', '比肩', 2061, 65, [
            ['丙', '正官'],
            ['戊', '正印'],
            ['庚', '劫财'],
          ], liuyue),
          _ln('壬午', '伤官', 2062, 66, [
            ['丁', '七杀'],
            ['己', '偏印'],
          ], liuyue),
          _ln('癸未', '食神', 2063, 67, [
            ['己', '偏印'],
            ['丁', '七杀'],
            ['乙', '正财'],
          ], liuyue),
        ],
      ),

      // ── 大运五：乙亥 ──
      (
        pillar: _jz('乙亥'),
        ganGod: _god('偏财'),
        hiddenGans: _h([
          ['壬', '偏印'],
          ['甲', '偏财'],
        ]),
        startYear: 2064,
        startAge: 68,
        yearsCount: 10,
        liunian: [
          _ln('甲申', '偏财', 2064, 68, [
            ['庚', '劫财'],
            ['壬', '偏印'],
            ['戊', '正印'],
          ], liuyue),
          _ln('乙酉', '正财', 2065, 69, [
            ['辛', '比肩'],
          ], liuyue),
          _ln('丙戌', '正官', 2066, 70, [
            ['戊', '正印'],
            ['辛', '比肩'],
            ['丁', '七杀'],
          ], liuyue),
          _ln('丁亥', '七杀', 2067, 71, [
            ['壬', '偏印'],
            ['甲', '偏财'],
          ], liuyue),
          _ln('戊子', '正印', 2068, 72, [
            ['癸', '偏印'],
          ], liuyue),
          _ln('己丑', '偏印', 2069, 73, [
            ['己', '偏印'],
            ['癸', '偏印'],
            ['辛', '比肩'],
          ], liuyue),
          _ln('庚寅', '劫财', 2070, 74, [
            ['甲', '偏财'],
            ['丙', '正官'],
            ['戊', '正印'],
          ], liuyue),
          _ln('辛卯', '比肩', 2071, 75, [
            ['乙', '正财'],
          ], liuyue),
          _ln('壬辰', '伤官', 2072, 76, [
            ['戊', '正印'],
            ['乙', '正财'],
            ['癸', '偏印'],
          ], liuyue),
          _ln('癸巳', '食神', 2073, 77, [
            ['丙', '正官'],
            ['戊', '正印'],
            ['庚', '劫财'],
          ], liuyue),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final mockData = buildMockData();

    return Scaffold(
      backgroundColor: InkTheme.paperStone,
      appBar: AppBar(
        title: const Text('大运流年 · 三层级联'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: YunLiuListTileCardWidget(
          daYunList: mockData,
          todayYear: 2050,
          todayMonthName: '五月',
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:common/models/yun_liu_display_models.dart';
import 'package:common/services/yun_liu_service.dart';
import 'package:common/models/chinese_date_info.dart';
import 'package:common/enums/enum_gender.dart';
import 'package:common/enums/enum_tian_gan.dart';

class YunLiuViewModel extends ChangeNotifier {
  final YunLiuService _service;

  // --- Input Config ---
  final DateTime birthDateTime;
  final Gender gender;
  final ChineseDateInfo birthDateInfo;
  final DateTime referenceDate;

  // --- Business Data ---
  List<DaYunDisplayData> _daYunList = [];
  List<DaYunDisplayData> get daYunList => _daYunList;

  // --- Interaction State ---
  int? _selectedDaYunIdx;
  int? get selectedDaYunIdx => _selectedDaYunIdx;

  int? _selectedLiuNianIdx;
  int? get selectedLiuNianIdx => _selectedLiuNianIdx;

  int? _selectedLiuYueIdx;
  int? get selectedLiuYueIdx => _selectedLiuYueIdx;

  int? _selectedLiuRiDay;
  int? get selectedLiuRiDay => _selectedLiuRiDay;

  int? _selectedLiuShiIdx;
  int? get selectedLiuShiIdx => _selectedLiuShiIdx;

  // --- View State ---
  bool _isMiniMode = false;
  bool get isMiniMode => _isMiniMode;

  bool _isHorizontal = true;
  bool get isHorizontal => _isHorizontal;

  final Map<int, bool> _daYunExpanded = {};
  Map<int, bool> get daYunExpanded => _daYunExpanded;
  final Map<int, bool> _liuNianExpanded = {};
  Map<int, bool> get liuNianExpanded => _liuNianExpanded;
  final Map<int, bool> _liuYueExpanded = {};
  Map<int, bool> get liuYueExpanded => _liuYueExpanded;
  final Map<int, bool> _liuRiExpanded = {};
  Map<int, bool> get liuRiExpanded => _liuRiExpanded;

  bool _isExplicitlyCollapsed = false;
  bool get isAllCollapsed => _isExplicitlyCollapsed;

  YunLiuViewModel({
    required YunLiuService service,
    required this.birthDateTime,
    required this.gender,
    required this.birthDateInfo,
    DateTime? referenceDate,
  })  : _service = service,
        referenceDate = referenceDate ?? DateTime.now() {
    _init();
  }

  void _init() {
    _daYunList = _service.calculateDaYunList(
      birthDateTime: birthDateTime,
      gender: gender,
      birthDateInfo: birthDateInfo,
    );
    backToTargetDate(referenceDate);
  }

  // --- Actions ---

  void selectDaYun(int index) {
    if (index == _selectedDaYunIdx) return;
    _selectedDaYunIdx = index;
    _selectedLiuNianIdx = 0;
    _selectedLiuYueIdx = 0;
    _selectedLiuRiDay = null;
    _selectedLiuShiIdx = null;
    notifyListeners();
  }

  void selectLiuNian(int idx) {
    _selectedLiuNianIdx = idx;
    _selectedLiuYueIdx = 0;
    _selectedLiuRiDay = null;
    _selectedLiuShiIdx = null;
    notifyListeners();
  }

  void selectLiuYue(int idx) {
    _selectedLiuYueIdx = idx;
    _liuYueExpanded[idx] = true;
    _selectedLiuRiDay = null;
    _selectedLiuShiIdx = null;
    notifyListeners();
  }

  void selectLiuRi(int day) {
    _selectedLiuRiDay = day;
    _liuRiExpanded[day] = true;
    _selectedLiuShiIdx = null;
    notifyListeners();
  }

  void selectLiuShi(int idx) {
    _selectedLiuShiIdx = idx;
    notifyListeners();
  }

  void toggleMiniMode() {
    _isMiniMode = !_isMiniMode;
    notifyListeners();
  }

  void toggleOrientation() {
    _isHorizontal = !_isHorizontal;
    notifyListeners();
  }

  void toggleDaYunExpand(int idx) {
    _daYunExpanded[idx] = !(_daYunExpanded[idx] ?? false);
    if (_daYunExpanded[idx] == true) _isExplicitlyCollapsed = false;
    notifyListeners();
  }

  bool isDaYunExpanded(int idx) => _daYunExpanded[idx] ?? false;

  void toggleLiuNianExpand(int idx) {
    _liuNianExpanded[idx] = !(_liuNianExpanded[idx] ?? false);
    if (_liuNianExpanded[idx] == true) _isExplicitlyCollapsed = false;
    notifyListeners();
  }

  bool isLiuNianExpanded(int idx) => _liuNianExpanded[idx] ?? false;

  void toggleLiuYueExpand(int idx) {
    _liuYueExpanded[idx] = !(_liuYueExpanded[idx] ?? false);
    if (_liuYueExpanded[idx] == true) _isExplicitlyCollapsed = false;
    notifyListeners();
  }

  bool isLiuYueExpanded(int idx) => _liuYueExpanded[idx] ?? false;

  void toggleLiuRiExpand(int day) {
    _liuRiExpanded[day] = !(_liuRiExpanded[day] ?? false);
    if (_liuRiExpanded[day] == true) _isExplicitlyCollapsed = false;
    notifyListeners();
  }

  bool isLiuRiExpanded(int day) => _liuRiExpanded[day] ?? false;

  void collapseAll() {
    _daYunExpanded.clear();
    _liuNianExpanded.clear();
    _liuYueExpanded.clear();
    _liuRiExpanded.clear();
    _isExplicitlyCollapsed = true;
    notifyListeners();
  }

  void expandAll() {
    for (int i = 0; i < _daYunList.length; i++) {
      _daYunExpanded[i] = true;
    }
    if (_selectedDaYunIdx != null) {
      final dy = _daYunList[_selectedDaYunIdx!];
      for (int j = 0; j < dy.liunian.length; j++) {
        _liuNianExpanded[j] = true;
      }
      if (_selectedLiuNianIdx != null) {
        final ln = dy.liunian[_selectedLiuNianIdx!];
        for (int k = 0; k < ln.liuyue.length; k++) {
          _liuYueExpanded[k] = true;
        }
        if (_selectedLiuYueIdx != null) {
          final ly = ln.liuyue[_selectedLiuYueIdx!];
          final dt = DateTime(ln.year, ly.gregorianMonth + 1, 0);
          for (int d = 1; d <= dt.day; d++) {
            _liuRiExpanded[d] = true;
          }
        }
      }
    }
    _isExplicitlyCollapsed = false;
    notifyListeners();
  }

  /// Automatically syncs indices with the target date (e.g. Back to Today)
  void backToTargetDate(DateTime target) {
    final targetYear = target.year;
    final targetMonth = target.month;

    for (int i = 0; i < _daYunList.length; i++) {
      final dy = _daYunList[i];
      if (targetYear >= dy.startYear && targetYear < dy.startYear + dy.yearsCount) {
        _selectedDaYunIdx = i;
        for (int j = 0; j < dy.liunian.length; j++) {
          final ln = dy.liunian[j];
          if (ln.year == targetYear) {
            _selectedLiuNianIdx = j;
            for (int k = 0; k < ln.liuyue.length; k++) {
              if (ln.liuyue[k].gregorianMonth == targetMonth) {
                _selectedLiuYueIdx = k;
                _selectedLiuRiDay = target.day;
                int hourIdx = (target.hour + 1) ~/ 2;
                if (hourIdx >= 12) hourIdx = 0;
                _selectedLiuShiIdx = hourIdx;
                break;
              }
            }
            break;
          }
        }
        break;
      }
    }
    notifyListeners();
  }

  // --- Data Providing ---

  TianGan get dayMaster => birthDateInfo.dayGanZhi.tianGan;

  List<LiuRiDisplayData> fetchLiuRiData(int year, int month) {
    return _service.fetchLiuRiData(year, month, dayMaster);
  }

  List<LiuShiDisplayData> fetchLiuShiData(int year, int month, int day) {
    return _service.fetchLiuShiData(year, month, day, dayMaster);
  }
}

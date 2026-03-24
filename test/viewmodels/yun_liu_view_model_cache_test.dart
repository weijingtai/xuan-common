import 'package:flutter_test/flutter_test.dart';
import 'package:common/features/liu_yun/liu_yun.dart';
import 'package:common/enums.dart';
import 'package:common/features/datetime_details/input_info_params.dart';
import 'package:common/helpers/solar_lunar_datetime_helper.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'yun_liu_view_model_cache_test.mocks.dart';

@GenerateMocks([YunLiuService])
void main() {
  late YunLiuViewModel viewModel;
  late MockYunLiuService mockService;

  setUp(() {
    mockService = MockYunLiuService();
    final birthDate = DateTime(1990, 6, 15);
    final birthDateInfo = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
      birthDate,
      ZiShiStrategy.noDistinguishAt23,
    );

    // Provide default behavior for init
    when(mockService.calculateDaYunList(
      birthDateTime: anyNamed('birthDateTime'),
      gender: anyNamed('gender'),
      birthDateInfo: anyNamed('birthDateInfo'),
    )).thenReturn([]);

    viewModel = YunLiuViewModel(
      service: mockService,
      birthDateTime: birthDate,
      gender: Gender.male,
      birthDateInfo: birthDateInfo,
    );
  });

  test('fetchLiuRiData should use cache on second call', () {
    final year = 2024;
    final month = 3;
    final mockData = <LiuRiDisplayData>[];

    when(mockService.fetchLiuRiData(year, month, any)).thenReturn(mockData);

    // First call - should hit service
    final result1 = viewModel.fetchLiuRiData(year, month);
    expect(result1, mockData);

    // Second call - should hit cache
    final result2 = viewModel.fetchLiuRiData(year, month);
    expect(result2, mockData);

    verify(mockService.fetchLiuRiData(year, month, any)).called(1);
  });

  test('fetchLiuShiData should use cache on second call', () {
    final year = 2024;
    final month = 3;
    final day = 15;
    final mockData = <LiuShiDisplayData>[];

    when(mockService.fetchLiuShiData(year, month, day, any))
        .thenReturn(mockData);

    // First call - should hit service
    final result1 = viewModel.fetchLiuShiData(year, month, day);
    expect(result1, mockData);

    // Second call - should hit cache
    final result2 = viewModel.fetchLiuShiData(year, month, day);
    expect(result2, mockData);

    verify(mockService.fetchLiuShiData(year, month, day, any)).called(1);
  });
}

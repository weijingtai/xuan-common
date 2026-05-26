import 'package:flutter_test/flutter_test.dart';

// TDD Expectation: We write tests against the FUTURE pure domain extraction package,
// but run them against the CURRENT facade to prove behavior won't change.
// When Hermes extracts `metaphysics_core`, this test must still pass.
import 'package:xuan_common/xuan_common.dart';

void main() {
  group('Metaphysics Core Contract: JiaZi', () {
    test('All 60 JiaZi values preserve order and Chinese serialized value', () {
      expect(JiaZi.values.length, equals(60), reason: 'Must have exactly 60 JiaZi pairs.');

      // Check first few and specific boundaries
      expect(JiaZi.values[0], equals(JiaZi.JIA_ZI));
      expect(JiaZi.JIA_ZI.getDisplayName(), equals('甲子'));

      expect(JiaZi.values[1], equals(JiaZi.YI_CHOU));
      expect(JiaZi.YI_CHOU.getDisplayName(), equals('乙丑'));

      expect(JiaZi.values[59], equals(JiaZi.GUI_HAI));
      expect(JiaZi.GUI_HAI.getDisplayName(), equals('癸亥'));
    });

    test('JiaZi Lookup by Gan/Zhi or enum-pair returns identical instance', () {
      final fromString = JiaZiExt.fromGanZhi('甲子'); // Adjust API call as per common if different
      expect(fromString, equals(JiaZi.JIA_ZI));

      final fromStringLast = JiaZiExt.fromGanZhi('癸亥');
      expect(fromStringLast, equals(JiaZi.GUI_HAI));
    });

    test('Invalid JiaZi Lookup throws explicit error instead of null dereference', () {
      expect(() => JiaZiExt.fromGanZhi('not-a-jiazi'), throwsA(isA<Exception>()));
    });
  });
}

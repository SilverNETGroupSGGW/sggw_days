import 'package:flutter_test/flutter_test.dart';
import 'package:sggw_days/core/router/app_router.dart';

void main() {
  group('scanRouteRedirectLocation', () {
    test('redirects native scan links into the treasure hunt route', () {
      expect(
        scanRouteRedirectLocation(isWeb: false, pointId: 'point-1'),
        '/?scanPointId=point-1',
      );
    });

    test('keeps web scan links on the public landing page', () {
      expect(
        scanRouteRedirectLocation(isWeb: true, pointId: 'point-1'),
        isNull,
      );
    });

    test('does not redirect invalid point ids', () {
      expect(
        scanRouteRedirectLocation(isWeb: false, pointId: '../admin'),
        isNull,
      );
    });
  });
}

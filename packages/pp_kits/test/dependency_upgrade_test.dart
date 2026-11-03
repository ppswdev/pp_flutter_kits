import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:pp_kits/commons/timeagos.dart';
import 'package:pp_kits/utils/zip_util.dart';

void main() {
  test('custom time messages work with the new locale interface', () {
    final now = DateTime(2026, 1, 1, 12);
    GetTimeAgo.registerLocale('pl', PLMessages());
    final formatter = GetTimeAgo(locale: 'pl', clock: () => now);
    expect(formatter.format(now.subtract(const Duration(minutes: 3))),
        '3 minut temu');
  });

  test('zip round trip and damaged archive handling', () async {
    final dir = await Directory.systemTemp.createTemp('pp_kits_zip_test_');
    addTearDown(() => dir.delete(recursive: true));
    final source = File('${dir.path}/source.txt');
    await source.writeAsString('hello');
    final zip = '${dir.path}/test.zip';
    await ZipUtil.zip(source.path, zip);
    final files = await ZipUtil.unzip(zip, '${dir.path}/out');
    expect(await File(files.single).readAsString(), 'hello');
    await File(zip).writeAsBytes([1, 2, 3, 4]);
    await expectLater(ZipUtil.unzip(zip, '${dir.path}/bad'), throwsException);
  });
}

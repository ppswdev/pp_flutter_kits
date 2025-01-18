import 'dart:io';

import 'package:test/test.dart';
import 'package:pp_tool/pp_tool.dart' as pp_tool;

void main() {
  test('测试创建Flutter项目', () {
    // 模拟命令行参数
    List<String> arguments = ['create', '-f', 'test_project'];

    // 调用 main 函数
    pp_tool.main(arguments);

    // 这里可以添加断言来验证项目是否正确创建
    // 例如，检查项目目录是否存在
    // 检查项目目录是否存在
    final projectDir = Directory('test_project');
    expect(projectDir.existsSync(), isTrue, reason: '项目目录未创建');

    // 检查项目中的某个文件是否存在，例如 pubspec.yaml
    final pubspecFile = File('test_project/pubspec.yaml');
    expect(pubspecFile.existsSync(), isTrue, reason: 'pubspec.yaml 文件未创建');
  });
}

import 'dart:io';
import 'package:archive/archive.dart';

/// 压缩解压工具类
///
/// 使用示例：
///
/// ```dart
/// // 压缩（无密码）
/// try {
///   final zipPath = await ZipUtil.zip(
///     '/your/source/folder_or_file',
///     '/your/target/output.zip',
///   );
///   print('压缩成功：$zipPath');
/// } catch (e) {
///   print('压缩失败：$e');
/// }
///
/// // 压缩（有密码）
/// try {
///   final zipPath = await ZipUtil.zipWithPassword(
///     '/your/source/folder_or_file',
///     '/your/target/encrypted.zip',
///     '123456',
///   );
///   print('加密压缩成功：$zipPath');
/// } catch (e) {
///   print('加密压缩失败：$e');
/// }
///
/// // 解压（无密码）
/// try {
///   final files = await ZipUtil.unzip(
///     '/your/source/output.zip',
///     '/your/target/dir',
///   );
///   print('解压成功，文件列表：$files');
/// } catch (e) {
///   print('解压失败：$e');
/// }
///
/// // 解压（有密码）
/// try {
///   final files = await ZipUtil.unzipWithPassword(
///     '/your/source/encrypted.zip',
///     '/your/target/dir',
///     '123456',
///   );
///   print('解密解压成功，文件列表：$files');
/// } catch (e) {
///   print('解密解压失败：$e');
/// }
/// ```
class ZipUtil {
  /// 压缩文件/文件夹为zip包（不加密）
  ///
  /// [sourcePath]   源文件/文件夹路径
  /// [targetPath]   输出 zip 文件路径
  ///
  /// 示例：
  /// ```dart
  /// String zipFile = await ZipUtil.zip('a.txt', 'a.zip');
  /// ```
  ///
  /// 返回结果：
  ///   [String] 返回生成的zip文件路径
  static Future<String> zip(String sourcePath, String targetPath) async {
    try {
      final sourceDir = Directory(sourcePath);
      final archive = Archive();

      // 如果是目录，递归添加目录下所有文件
      if (await sourceDir.exists()) {
        await for (final file in sourceDir.list(recursive: true)) {
          if (file is File) {
            final relativePath = file.path.substring(sourcePath.length);
            final data = await file.readAsBytes();
            archive.addFile(ArchiveFile(relativePath, data.length, data));
          }
        }
      }
      // 如果仅为单个文件
      else if (await File(sourcePath).exists()) {
        final file = File(sourcePath);
        final data = await file.readAsBytes();
        archive.addFile(
          ArchiveFile(
            file.path.split(Platform.pathSeparator).last,
            data.length,
            data,
          ),
        );
      } else {
        throw Exception('源文件/文件夹不存在');
      }

      // 开始压缩
      final zipData = ZipEncoder().encode(archive);
      final zipFile = File(targetPath);
      await zipFile.writeAsBytes(zipData);
      await Future.delayed(const Duration(milliseconds: 100));
      return targetPath;
    } catch (e) {
      throw Exception('压缩错误: $e');
    }
  }

  /// 使用密码压缩文件/文件夹为 zip 包
  ///
  /// [sourcePath]   源文件/文件夹路径
  /// [targetPath]   输出 zip 文件路径
  /// [password]     压缩密码
  ///
  /// 示例：
  /// ```dart
  /// String zipFile = await ZipUtil.zipWithPassword('a.txt', 'a.enc.zip', '123456');
  /// ```
  ///
  /// 返回结果：
  ///   [String] 返回生成的zip文件路径
  static Future<String> zipWithPassword(
    String sourcePath,
    String targetPath,
    String password,
  ) async {
    try {
      final sourceDir = Directory(sourcePath);
      final archive = Archive();

      // 如果是目录，递归添加文件
      if (await sourceDir.exists()) {
        await for (final file in sourceDir.list(recursive: true)) {
          if (file is File) {
            final relativePath = file.path.substring(sourcePath.length);
            final data = await file.readAsBytes();
            archive.addFile(ArchiveFile(relativePath, data.length, data));
          }
        }
      }
      // 如果是单个文件
      else if (await File(sourcePath).exists()) {
        final file = File(sourcePath);
        final data = await file.readAsBytes();
        archive.addFile(
          ArchiveFile(
            file.path.split(Platform.pathSeparator).last,
            data.length,
            data,
          ),
        );
      } else {
        throw Exception('源文件/文件夹不存在');
      }

      // 开始加密压缩
      final zipData = ZipEncoder(password: password).encode(archive);
      final zipFile = File(targetPath);
      await zipFile.writeAsBytes(zipData);
      await Future.delayed(const Duration(milliseconds: 100));
      return targetPath;
    } catch (e) {
      throw Exception('加密压缩错误: $e');
    }
  }

  /// 解压zip文件到目标路径（不加密/无密码zip）
  ///
  /// [zipPath]     zip文件路径
  /// [targetPath]  解压目标路径
  ///
  /// 示例：
  /// ```dart
  /// List<String> files = await ZipUtil.unzip('a.zip', './output');
  /// ```
  ///
  /// 返回结果：
  ///   [List<String>] 返回解压出的全部文件路径列表
  static Future<List<String>> unzip(String zipPath, String targetPath) async {
    try {
      final bytes = await File(zipPath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      final extractedFiles = <String>[];

      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          final filePath = '$targetPath${Platform.pathSeparator}$filename';
          final outFile = File(filePath);
          await outFile.parent.create(recursive: true);
          await outFile.writeAsBytes(data);
          extractedFiles.add(filePath);
        }
      }

      return extractedFiles;
    } catch (e) {
      throw Exception('解压错误: $e');
    }
  }

  /// 解压加密zip文件到目标路径
  ///
  /// [zipPath]     zip文件路径
  /// [targetPath]  解压目标路径
  /// [password]    解压密码
  ///
  /// 示例：
  /// ```dart
  /// List<String> files = await ZipUtil.unzipWithPassword('a.enc.zip', './output', '123456');
  /// ```
  ///
  /// 返回结果：
  ///   [List<String>] 返回解压出的全部文件路径列表
  ///
  /// 若解压密码错误，异常信息包含“密码错误”
  static Future<List<String>> unzipWithPassword(
    String zipPath,
    String targetPath,
    String password,
  ) async {
    try {
      final bytes = await File(zipPath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes, password: password);
      final extractedFiles = <String>[];

      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          final filePath = '$targetPath${Platform.pathSeparator}$filename';
          final outFile = File(filePath);
          await outFile.parent.create(recursive: true);
          await outFile.writeAsBytes(data);
          extractedFiles.add(filePath);
        }
      }

      return extractedFiles;
    } catch (e) {
      if (e.toString().contains('Invalid password')) {
        throw Exception('密码错误');
      }
      throw Exception('解压错误: $e');
    }
  }
}

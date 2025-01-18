import 'dart:io';
import 'package:archive/archive.dart';

/// 压缩解压工具类
/// // 压缩文件（不加密）
/// try {
///   final zipPath = await ZipUtil.zip(
///     '/path/to/source',
///     '/path/to/output.zip'
///   );
///   print('压缩成功：$zipPath');
/// } catch (e) {
///   print('压缩失败：$e');
/// }
/// // 加密压缩
/// try {
///   final zipPath = await ZipUtil.zipWithPassword(
///     '/path/to/source',
///     '/path/to/encrypted.zip',
///     'your_password'
///   );
///   print('加密压缩成功：$zipPath');
/// } catch (e) {
///   print('加密压缩失败：$e');
/// }
/// // 解压文件（不需要密码）
/// try {
///   final files = await ZipUtil.unzip(
///     '/path/to/archive.zip',
///     '/path/to/extract'
///   );
///   print('解压成功，文件列表：$files');
/// } catch (e) {
///   print('解压失败：$e');
/// }
/// // 解密并解压
/// try {
///   final files = await ZipUtil.unzipWithPassword(
///     '/path/to/encrypted.zip',
///     '/path/to/extract',
///     'your_password'
///   );
///   print('解密解压成功，文件列表：$files');
/// } catch (e) {
///   print('解密解压失败：$e');
/// }
class ZipUtil {
  /// 压缩文件/文件夹（不加密）
  /// [sourcePath] 源文件/文件夹路径
  /// [targetPath] 目标zip文件路径
  static Future<String> zip(String sourcePath, String targetPath) async {
    try {
      final sourceDir = Directory(sourcePath);
      final archive = Archive();

      // 如果是目录，递归添加文件
      if (await sourceDir.exists()) {
        await for (final file in sourceDir.list(recursive: true)) {
          if (file is File) {
            final relativePath = file.path.substring(sourcePath.length);
            final data = await file.readAsBytes();
            archive.addFile(ArchiveFile(
              relativePath,
              data.length,
              data,
            ));
          }
        }
      }
      // 如果是单个文件
      else if (await File(sourcePath).exists()) {
        final file = File(sourcePath);
        final data = await file.readAsBytes();
        archive.addFile(ArchiveFile(
          file.path.split('/').last,
          data.length,
          data,
        ));
      } else {
        throw Exception('源文件/文件夹不存在');
      }

      // 压缩并保存
      final zipData = ZipEncoder().encode(archive);
      final zipFile = File(targetPath);
      await zipFile.writeAsBytes(zipData);
      return targetPath;
    } catch (e) {
      throw Exception('压缩错误: $e');
    }
  }

  /// 使用密码压缩文件/文件夹
  /// [sourcePath] 源文件/文件夹路径
  /// [targetPath] 目标zip文件路径
  /// [password] 压缩密码
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
            archive.addFile(ArchiveFile(
              relativePath,
              data.length,
              data,
            ));
          }
        }
      }
      // 如果是单个文件
      else if (await File(sourcePath).exists()) {
        final file = File(sourcePath);
        final data = await file.readAsBytes();
        archive.addFile(ArchiveFile(
          file.path.split('/').last,
          data.length,
          data,
        ));
      } else {
        throw Exception('源文件/文件夹不存在');
      }

      // 使用密码压缩并保存
      final zipData = ZipEncoder(password: password).encode(archive);
      final zipFile = File(targetPath);
      await zipFile.writeAsBytes(zipData);
      return targetPath;
    } catch (e) {
      throw Exception('加密压缩错误: $e');
    }
  }

  /// 解压缩（不需要密码）
  /// [zipPath] zip文件路径
  /// [targetPath] 解压目标路径
  static Future<List<String>> unzip(String zipPath, String targetPath) async {
    try {
      final bytes = await File(zipPath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      final extractedFiles = <String>[];

      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          final filePath = '$targetPath/$filename';
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

  /// 使用密码解压缩
  /// [zipPath] zip文件路径
  /// [targetPath] 解压目标路径
  /// [password] 解压密码
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
          final filePath = '$targetPath/$filename';
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

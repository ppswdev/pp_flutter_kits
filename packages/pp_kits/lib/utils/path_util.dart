import 'dart:io';
import 'package:path/path.dart' as dart_path;
import 'package:path_provider/path_provider.dart';

/// 路径工具类
/// 提供一些常用的路径操作方法
class PPath {
  /// 获取临时目录
  /// 使用示例
  /// void example() {
  ///   PPath.appTempDir();
  /// }
  static Future<Directory> appTempDir() async {
    return await getTemporaryDirectory();
  }

  /// 获取应用支持目录
  /// 使用示例
  /// void example() {
  ///   PPath.appSupportDir();
  /// }
  static Future<Directory> appSupportDir() async {
    return await getApplicationSupportDirectory();
  }

  /// 获取应用文档目录
  /// 使用示例
  /// void example() {
  ///   PPath.appDocumentDir();
  /// }
  static Future<Directory> appDocumentDir() async {
    return await getApplicationDocumentsDirectory();
  }

  /// 获取应用缓存目录
  static Future<Directory> appCacheDir() async {
    return await getApplicationCacheDirectory();
  }

  /// 获取下载目录(Android不支持)
  static Future<Directory?> appDownloadDir() async {
    return await getDownloadsDirectory();
  }

  /// 获取外部存储目录(仅支持Android)
  static Future<Directory?> extStorageDir() async {
    return await getExternalStorageDirectory();
  }

  /// 获取外部存储缓存目录(仅支持Android)
  static Future<List<Directory>?> extStorageCacheDirs() async {
    return await getExternalCacheDirectories();
  }

  /// 在一个目录下追加一个目录或文件名
  /// 使用示例
  /// void example() {
  ///   PPath.join('documents', 'dir1', 'file.txt');
  /// }
  /// 返回：documents/dir1/file.txt
  static String join(String path, String name) {
    //增加多个可参考：join('documents', 'dir1', 'file.txt')
    return dart_path.join(path, name);
  }

  /// 获取路径全路径目录
  /// 使用示例
  /// void example() {
  ///   PPath.dirname('documents/dir1/file.txt');
  /// }
  /// 返回：documents/dir1
  static String dirname(String path) {
    return dart_path.dirname(path);
  }

  /// 获取路径的文件名
  /// 使用示例
  /// void example() {
  ///   PPath.filename('documents/dir1/file.txt');
  /// }
  /// 返回：file.txt
  static String filename(String path) {
    return dart_path.basename(path);
  }

  /// 获取路径的文件名不包含后缀名
  /// 使用示例
  /// void example() {
  ///   PPath.filenameWithoutExt('documents/dir1/file.txt');
  /// }
  /// 返回：file
  static String filenameWithoutExt(String path) {
    return dart_path.basenameWithoutExtension(path);
  }

  /// 获取路径的文件名扩展名 .ext
  /// 使用示例
  /// void example() {
  ///   PPath.extension('documents/dir1/file.txt');
  /// }
  /// 返回：.txt
  static String extension(String path) {
    return dart_path.extension(path);
  }

  /// 根据路径创建一个目录
  /// 使用示例
  /// void example() {
  ///   PPath.createDir('documents/dir1/dir2');
  /// }
  /// 返回：documents/dir1/dir2
  static Future<Directory> createDir(String path) async {
    Directory dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true); // 递归创建所有中间目录
    }
    return dir;
  }

  /// 在应用临时中添加一个目录
  /// 使用示例
  /// void example() {
  ///   PPath.createDirInTemp('dir2');
  /// }
  /// 返回：/var/mobile/***/tmp/dir2
  static Future<Directory> createDirInTemp(String dirName) async {
    Directory appTempDir = await PPath.appTempDir();
    Directory dir = Directory('${appTempDir.path}/$dirName');
    if (!await dir.exists()) {
      await dir.create();
    }
    return dir;
  }

  /// 在应用文档中添加一个目录
  /// 使用示例
  /// void example() {
  ///   PPath.createDirInDoc('dir2');
  /// }
  /// 返回：/var/mobile/***/Documents/dir2
  static Future<Directory> createDirInDoc(String dirName) async {
    Directory appDocDir = await PPath.appDocumentDir();
    Directory dir = Directory('${appDocDir.path}/$dirName');
    if (!await dir.exists()) {
      await dir.create();
    }
    return dir;
  }

  /// 在应用缓存中添加一个目录
  /// 使用示例
  /// void example() {
  ///   PPath.createDirInCache('dir2');
  /// }
  /// 返回：/var/mobile/***/Library/Caches/dir2
  static Future<Directory> createDirInCache(String dirName) async {
    Directory appCacheDir = await PPath.appCacheDir();
    Directory dir = Directory('${appCacheDir.path}/$dirName');
    if (!await dir.exists()) {
      await dir.create();
    }
    return dir;
  }

  // 清理临时目录中的所有文件
  static Future<void> clearTempDir() async {
    final tempDir = await appTempDir();
    if (tempDir.existsSync()) {
      tempDir.listSync().forEach((file) {
        if (file is File) {
          file.deleteSync();
        } else if (file is Directory) {
          file.deleteSync(recursive: true);
        }
      });
    }
  }

  /// 构建Documents文件路径
  /// 使用示例
  /// void example() {
  ///   PPath.buildFilePathInDoc('file.txt');
  /// }
  /// 返回：/var/mobile/***/Documents/file.txt
  static Future<String> buildFilePathInDoc(String fileName) async {
    var dir = await PPath.appDocumentDir();
    return join(dir.path, fileName);
  }

  /// 构建Caches文件路径
  /// 使用示例
  /// void example() {
  ///   PPath.buildFilePathInCache('file.txt');
  /// }
  /// 返回：/var/mobile/***/Library/Caches/file.txt
  static Future<String> buildFilePathInCache(String fileName) async {
    var dir = await PPath.appCacheDir();
    return join(dir.path, fileName);
  }
}

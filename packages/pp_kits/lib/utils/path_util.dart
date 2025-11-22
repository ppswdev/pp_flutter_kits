import 'dart:io';
import 'package:path/path.dart' as dart_path;
import 'package:path_provider/path_provider.dart';

/// 路径工具类
/// 提供一些常用的路径操作方法
class PPath {
  /// 获取临时目录
  ///
  /// 示例代码：
  /// ```dart
  /// Directory dir = await PPath.appTempDir(); // 返回临时目录对象
  /// ```
  static Future<Directory> appTempDir() async {
    return await getTemporaryDirectory();
  }

  /// 获取应用支持目录
  ///
  /// 示例代码：
  /// ```dart
  /// Directory dir = await PPath.appSupportDir(); // 返回应用支持目录对象
  /// ```
  static Future<Directory> appSupportDir() async {
    return await getApplicationSupportDirectory();
  }

  /// 获取应用文档目录
  ///
  /// 示例代码：
  /// ```dart
  /// Directory dir = await PPath.appDocumentDir(); // 返回文档目录对象
  /// ```
  static Future<Directory> appDocumentDir() async {
    return await getApplicationDocumentsDirectory();
  }

  /// 获取应用缓存目录
  ///
  /// 示例代码：
  /// ```dart
  /// Directory dir = await PPath.appCacheDir(); // 返回缓存目录对象
  /// ```
  static Future<Directory> appCacheDir() async {
    return await getApplicationCacheDirectory();
  }

  /// 获取下载目录(Android不支持)
  ///
  /// 示例代码：
  /// ```dart
  /// Directory? dir = await PPath.appDownloadDir(); // 返回下载目录对象
  /// ```
  static Future<Directory?> appDownloadDir() async {
    return await getDownloadsDirectory();
  }

  /// 获取外部存储目录(仅支持Android)
  ///
  /// 示例代码：
  /// ```dart
  /// Directory? dir = await PPath.extStorageDir(); // 返回外部存储对象
  /// ```
  static Future<Directory?> extStorageDir() async {
    return await getExternalStorageDirectory();
  }

  /// 获取外部存储缓存目录(仅支持Android)
  ///
  /// 示例代码：
  /// ```dart
  /// List<Directory>? dirs = await PPath.extStorageCacheDirs(); // 返回外部缓存目录列表
  /// ```
  static Future<List<Directory>?> extStorageCacheDirs() async {
    return await getExternalCacheDirectories();
  }

  /// 在一个目录下追加一个目录或文件名
  ///
  /// 示例代码：
  /// ```dart
  /// String path = PPath.join('documents', 'dir1/file.txt'); // 返回 'documents/dir1/file.txt'
  /// ```
  /// 返回：documents/dir1/file.txt
  static String join(String path, String name) {
    // dart_path.join 支持可变参数，推荐用 dart_path.join(a, b, c)
    return dart_path.join(path, name);
  }

  /// 获取路径的上级目录名
  ///
  /// 示例代码：
  /// ```dart
  /// String dirName = PPath.dirname('documents/dir1/file.txt'); // 返回 'documents/dir1'
  /// ```
  static String dirname(String path) {
    return dart_path.dirname(path);
  }

  /// 获取路径最后的文件名（含扩展名）
  ///
  /// 示例代码：
  /// ```dart
  /// String name = PPath.filename('documents/dir1/file.txt'); // 返回 'file.txt'
  /// ```
  static String filename(String path) {
    return dart_path.basename(path);
  }

  /// 获取不带扩展名的文件名
  ///
  /// 示例代码：
  /// ```dart
  /// String name = PPath.filenameWithoutExt('documents/dir1/file.txt'); // 返回 'file'
  /// ```
  static String filenameWithoutExt(String path) {
    return dart_path.basenameWithoutExtension(path);
  }

  /// 获取文件的扩展名（.ext）
  ///
  /// 示例代码：
  /// ```dart
  /// String ext = PPath.fileExt('documents/dir1/file.txt'); // 返回 '.txt'
  /// ```
  static String fileExt(String path) {
    return dart_path.extension(path);
  }

  /// 根据路径创建一个目录
  ///
  /// 示例代码：
  /// ```dart
  /// Directory dir = await PPath.createDir('documents/dir1/dir2'); // 返回所创建的目录对象
  /// ```
  static Future<Directory> createDir(String path) async {
    Directory dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true); // 递归创建所有中间目录
    }
    return dir;
  }

  /// 在应用临时目录下创建一个子目录
  ///
  /// 示例代码：
  /// ```dart
  /// Directory dir = await PPath.createDirInTemp('dir2'); // 返回 /tmp/dir2 目录对象
  /// ```
  static Future<Directory> createDirInTemp(String dirName) async {
    Directory appTempDir = await PPath.appTempDir();
    Directory dir = Directory('${appTempDir.path}/$dirName');
    if (!await dir.exists()) {
      await dir.create();
    }
    return dir;
  }

  /// 在应用文档目录下创建一个子目录
  ///
  /// 示例代码：
  /// ```dart
  /// Directory dir = await PPath.createDirInDoc('dir2'); // 返回 Documents/dir2 目录对象
  /// ```
  static Future<Directory> createDirInDoc(String dirName) async {
    Directory appDocDir = await PPath.appDocumentDir();
    Directory dir = Directory('${appDocDir.path}/$dirName');
    if (!await dir.exists()) {
      await dir.create();
    }
    return dir;
  }

  /// 在应用缓存目录下创建一个子目录
  ///
  /// 示例代码：
  /// ```dart
  /// Directory dir = await PPath.createDirInCache('dir2'); // 返回 Caches/dir2 目录对象
  /// ```
  static Future<Directory> createDirInCache(String dirName) async {
    Directory appCacheDir = await PPath.appCacheDir();
    Directory dir = Directory('${appCacheDir.path}/$dirName');
    if (!await dir.exists()) {
      await dir.create();
    }
    return dir;
  }

  /// 清理临时目录中的所有文件和子目录
  ///
  /// 示例代码：
  /// ```dart
  /// await PPath.clearTempDir(); // 清理临时目录内容，无返回值
  /// ```
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
  ///
  /// 弃用方法，推荐用 [buildPathInDoc]
  ///
  /// 示例代码：
  /// ```dart
  /// String path = await PPath.buildFilePathInDoc('dir1/file.txt'); // 返回完整路径如 Documents/dir1/file.txt
  /// ```
  @Deprecated('该方法已弃用，请使用PPath.buildPathInDoc方法替代。')
  static Future<String> buildFilePathInDoc(String pathFile) async {
    var dir = await PPath.appDocumentDir();
    final fullPath = dart_path.join(dir.path, pathFile);
    final parentPath = dart_path.dirname(fullPath);
    final parentDir = Directory(parentPath);
    if (!await parentDir.exists()) {
      await parentDir.create(recursive: true);
    }
    return fullPath;
  }

  /// 构建Caches文件路径
  ///
  /// 弃用方法，推荐用 [buildPathInCache]
  ///
  /// 示例代码：
  /// ```dart
  /// String path = await PPath.buildFilePathInCache('dir1/dir2/file.txt'); // 返回完整路径如 Caches/dir1/dir2/file.txt
  /// ```
  @Deprecated('该方法已弃用，请使用PPath.buildPathInCache方法替代。')
  static Future<String> buildFilePathInCache(String pathFile) async {
    final dir = await PPath.appCacheDir();
    final fullPath = dart_path.join(dir.path, pathFile);
    final parentPath = dart_path.dirname(fullPath);
    final parentDir = Directory(parentPath);
    if (!await parentDir.exists()) {
      await parentDir.create(recursive: true);
    }
    return fullPath;
  }

  /// 构建Documents下的路径
  ///
  /// 示例代码：
  /// ```dart
  /// // 构建目录路径
  /// String path1 = await PPath.buildPathInDoc(subPath: 'dir1'); // 返回 Documents/dir1
  ///
  /// // 构建文件路径
  /// String path2 = await PPath.buildPathInDoc(fileName: 'file.txt'); // 返回 Documents/file.txt
  ///
  /// // 构建带子目录的文件路径
  /// String path3 = await PPath.buildPathInDoc(subPath: 'dir1', fileName: 'file.txt'); // 返回 Documents/dir1/file.txt
  /// String path4 = await PPath.buildPathInDoc(subPath: 'dir1/dir2', fileName: 'file.txt'); // 返回 Documents/dir1/dir2/file.txt
  /// ```
  static Future<String> buildPathInDoc({
    String subPath = '',
    String fileName = '',
  }) async {
    var fullPath = (await PPath.appDocumentDir()).path;
    // 如果 subPath 不为空，则拼接 subPath 并确保目录存在
    if (subPath.isNotEmpty) {
      fullPath = dart_path.join(fullPath, subPath);
      final parentDir = Directory(fullPath);
      if (!await parentDir.exists()) {
        await parentDir.create(recursive: true);
      }
    }
    // 如果 fileName 不为空，则拼接 fileName 到路径
    if (fileName.isNotEmpty) {
      fullPath = dart_path.join(fullPath, fileName);
    }
    return fullPath;
  }

  /// 构建Caches下的路径
  ///
  /// 示例代码：
  /// ```dart
  /// // 构建目录路径
  /// String path1 = await PPath.buildPathInCache(subPath: 'dir1'); // 返回 Caches/dir1
  ///
  /// // 构建文件路径
  /// String path2 = await PPath.buildPathInCache(fileName: 'file.txt'); // 返回 Caches/file.txt
  ///
  /// // 构建带子目录的文件路径
  /// String path3 = await PPath.buildPathInCache(subPath: 'dir1', fileName: 'file.txt'); // 返回 Caches/dir1/file.txt
  /// String path4 = await PPath.buildPathInCache(subPath: 'dir1/dir2', fileName: 'file.txt'); // 返回 Caches/dir1/dir2/file.txt
  /// ```
  static Future<String> buildPathInCache({
    String subPath = '',
    String fileName = '',
  }) async {
    var fullPath = (await PPath.appCacheDir()).path;
    // 如果 subPath 不为空，则拼接 subPath 并确保目录存在
    if (subPath.isNotEmpty) {
      fullPath = dart_path.join(fullPath, subPath);
      final parentDir = Directory(fullPath);
      if (!await parentDir.exists()) {
        await parentDir.create(recursive: true);
      }
    }
    // 如果 fileName 不为空，则拼接 fileName 到路径
    if (fileName.isNotEmpty) {
      fullPath = dart_path.join(fullPath, fileName);
    }
    return fullPath;
  }
}

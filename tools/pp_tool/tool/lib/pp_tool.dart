import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as path;
import 'package:archive/archive.dart';

void main(List<String> arguments) {
  print('arguments: $arguments');
  final parser = ArgParser()
    ..addCommand(
      'create',
      ArgParser()
        ..addOption(
          'flutter',
          abbr: 'f',
          help: 'Create a Flutter project',
          mandatory: true,
        )
        ..addOption(
          'organization',
          abbr: 'o',
          help: 'Specify the organization name',
          defaultsTo: 'example',
        ),
    )
    ..addFlag(
      'version',
      abbr: 'v',
      negatable: false,
      help: 'Show the version of the tool',
    );

  try {
    ArgResults argResults = parser.parse(arguments);
    if (argResults['version'] as bool) {
      print('pp_tool v1.0.4 created on 2024-11-13 by xiaopindev.');
      return;
    }
    if (argResults.command?.name == 'create') {
      String organizationName = argResults.command!['organization'];
      String projectName = argResults.command!['flutter'];

      organizationName = organizationName.toLowerCase();
      projectName = projectName.toLowerCase();

      print('Organization: $organizationName');
      print('Project: $projectName');

      print('$projectName flutter project generating...');
      createFlutterProjectFromZip(projectName,
          organizationName: organizationName);
    } else {
      printUsage();
    }
  } catch (e) {
    print('Error: ${e.toString()}');
    printUsage();
  }
}

void printUsage() {
  print('''pp_tool help: 
  Usage:
  ptool create -f <project_name> [-o <organization_name>]
  -f <project_name>: The name of the Flutter project to create.
  -o <organization_name>: The organization name for the project. Defaults to 'example'.
  
  ptool -v : Show the version of the tool
  ''');
}

void createFlutterProjectFromZip(String projectName,
    {String organizationName = 'example'}) {
  String? templateZipPath = Platform.environment['FLUTTER_TEMPLATE_PATH'];
  if (templateZipPath == null || templateZipPath.isEmpty) {
    print('Error: FLUTTER_TEMPLATE_PATH environment variable is not set.');
    exit(1);
  }
  print('Template source file: $templateZipPath');
  String destinationPath = Directory.current.path;
  print('Target directory path: $destinationPath');

  if (!Directory(destinationPath).existsSync()) {
    print('Error: $destinationPath not exists.');
    exit(1);
  }

  File zipFile = File(templateZipPath);
  if (!zipFile.existsSync()) {
    print('Error: Template zip file not found at $templateZipPath');
    exit(1);
  }

  List<int> bytes = zipFile.readAsBytesSync();
  Archive archive = ZipDecoder().decodeBytes(bytes);

  for (ArchiveFile file in archive) {
    if (file.name.contains('__MACOSX') || file.name.contains('DS_Store')) {
      continue;
    }

    String filePath = path.join(destinationPath, file.name);

    if (file.isFile) {
      //print('File: $filePath');
      String fileExtension = path.extension(file.name);
      Set<String> textFileExtensions = {
        '.dart',
        '.yaml',
        '.json',
        '.txt',
        '.md',
        '.html',
        '.xml',
        '.gradle',
        '.kt',
        '.cc',
        '.rc',
        '.cpp',
        '.plist',
        '.xcconfig',
        '.xcscheme',
        '.pbxproj'
      };
      if (textFileExtensions.contains(fileExtension)) {
        List<int> content = file.content as List<int>;
        String fileContent = String.fromCharCodes(content);
        fileContent = fileContent.replaceAll('flutter_app', projectName);
        if (organizationName != 'example') {
          fileContent =
              fileContent.replaceAll('com.example', 'com.$organizationName');
        }
        File(filePath)
          ..createSync(recursive: true)
          ..writeAsStringSync(fileContent);
      } else {
        // 对于非文本文件，直接写入字节
        File(filePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(file.content as List<int>);
      }
    } else {
      //print('Directory: $filePath');
      Directory(filePath).createSync(recursive: true);
    }
  }
  renameFiles(destinationPath, projectName);
  renameDirectories(destinationPath, projectName,
      organizationName: organizationName);
  print(
      'Flutter project "$projectName" created successfully at $destinationPath/$projectName');
  print('Done!');
}

void renameFiles(String directoryPath, String projectName) {
  Directory directory = Directory(directoryPath);
  for (FileSystemEntity entity in directory.listSync(recursive: true)) {
    if (entity is File) {
      String dirPath = path.dirname(entity.path);
      String fileName = path.basename(entity.path);
      if (!fileName.contains('flutter_app')) {
        continue;
      }
      String newFileName = fileName.replaceAll('flutter_app', projectName);
      String newPath = path.join(dirPath, newFileName);
      try {
        entity.renameSync(newPath);
        //print('Renamed file: ${entity.path} to $newPath');
      } catch (e) {
        print('ERROR: Failed to rename ${entity.path}: $e');
      }
    }
  }
}

void renameDirectories(String directoryPath, String projectName,
    {String organizationName = 'example'}) {
  Directory directory = Directory(directoryPath);

  for (FileSystemEntity entity in directory.listSync()) {
    if (entity is Directory) {
      renameDirectories(entity.path, projectName,
          organizationName: organizationName);
    }
  }

  for (FileSystemEntity entity in directory.listSync()) {
    if (entity is Directory) {
      String parentDirPath = path.dirname(entity.path);
      String dirName = path.basename(entity.path);
      String newDirName = '';
      if (dirName.contains('example')) {
        newDirName = dirName.replaceAll('example', organizationName);
      } else if (dirName.contains('flutter_app')) {
        newDirName = dirName.replaceAll('flutter_app', projectName);
      }
      if (newDirName.isEmpty) {
        continue;
      }
      String newPath = path.join(parentDirPath, newDirName);
      try {
        entity.renameSync(newPath);
        //print('Renamed directory: ${entity.path} to $newPath');
      } catch (e) {
        print('ERROR: Failed to rename ${entity.path}: $e');
      }
    }
  }
}

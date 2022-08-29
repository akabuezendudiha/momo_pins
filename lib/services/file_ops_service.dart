import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:momo_pins/dto/list_menu.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class FileOpsService {
  Future<String> _getCurrentPath(String? parentDir) async {
    String currentDirectory =
        '$parentDir/${DateFormat.yMMMEd().format(DateTime.now()).toString()}';

    // Creates folder if doesn't exist
    if (!await Directory(currentDirectory).exists()) {
      await Directory(currentDirectory).create(recursive: true);
    }

    return currentDirectory;
  }

  Future<String> _getOrCreateDirectory(
      Directory? directory, String folder) async {
    // throws error directory is null
    if (directory == null) throw Exception('Directory does not exist');

    // Composes the full directory
    String dir = '${directory.path}/$folder';

    // Creates directory if it doesn't exist
    if (!await Directory(dir).exists()) {
      await Directory(dir).create(recursive: true);
    }

    return dir;
  }

  Future<String?> get _localPath async {
    try {
      // Gets or creates the external download directory
      String localDownloadDir = await _getOrCreateDirectory(
          await getExternalStorageDirectory(), 'Momo Local Downloads');

      return localDownloadDir;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      rethrow;
    }
  }

  Future<String?> get _backupPath async {
    try {
      // Get or creates the backup download directory
      String backupDownloadDir = await _getOrCreateDirectory(
          await getApplicationSupportDirectory(), 'Momo Backup Downloads');

      return backupDownloadDir;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      rethrow;
    }
  }

  Future<File> _localFile(String fileName) async {
    final path = await _getCurrentPath(await _localPath);
    return File('$path/$fileName.txt');
  }

  Future<File> _backupFile(String fileName) async {
    final path = await _getCurrentPath(await _backupPath);
    return File('$path/$fileName.txt');
  }

  // Future<List<String>> readLocalFile(String fileName) async {
  //   //Gets the local file
  //   final file = await _localFile(fileName);
  //
  //   // Read the file
  //   return await file.readAsLines();
  // }

  Future<int> _getFileLength(String filePath) async {
    // Gets the file
    final file = File(filePath);
    final fileContent = await file.readAsLines();
    return fileContent.length;
  }

  Future<File> writeLocalFile(String fileName, String line) async {
    //Gets the local file
    final file = await _localFile(fileName);

    // Writes the local file
    return await file.writeAsString('$line\n', mode: FileMode.append);
  }

  // Future<List<String>> readBackupFile(String fileName) async {
  //   //Gets the backup file
  //   final file = await _backupFile(fileName);
  //
  //   // Read the file
  //   return await file.readAsLines();
  // }

  Future<File> writeBackupFile(String fileName, String line) async {
    //Gets the backup file
    final file = await _backupFile(fileName);

    // Writes the backup file
    return await file.writeAsString('$line\n', mode: FileMode.append);
  }

  Future<List<Item>> getLocalDownloadContents() async {
    // Gets the local download directory
    return await _getDirectoryContents(await _localPath);
  }

  Future<List<Item>> getBackupDownloadContents() async {
    // Gets the backup download directory
    return await _getDirectoryContents(await _backupPath);
  }

  Future<List<Item>> _getDirectoryContents(String? dir) async {
    // Gets the backup download directory
    List<Item> downloadFolderContents = [];

    // Gets all date folders
    final folders = await Directory(dir!)
        .list(recursive: false, followLinks: false)
        .map((e) => e.path)
        .toList();

    // Loops through all date folders
    for (var dateFolderPath in folders) {
      String dateFolderName =
          dateFolderPath.substring(dateFolderPath.lastIndexOf('/') + 1);

      final files =
          await Directory(dateFolderPath).list().map((e) => e.path).toList();
      List<SubItem> subItems = [];
      for (var file in files) {
        String label = file.substring(file.lastIndexOf('/') + 1, file.lastIndexOf('.'));
        int numOfPins = await _getFileLength(file);

        subItems.add(SubItem(label: label, numOfPins: numOfPins.toString()));
      }
      downloadFolderContents
          .add(Item(date: dateFolderName, subItems: subItems));
    }
    return downloadFolderContents;
  }
}

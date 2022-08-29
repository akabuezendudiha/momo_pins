import 'package:flutter/material.dart';
import 'package:momo_pins/services/file_ops_service.dart';
import 'package:momo_pins/widgets/expandable_list.dart';

import '../dto/list_menu.dart';
import '../main.dart';

class BackupCollection extends StatefulWidget {
  const BackupCollection({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<BackupCollection> createState() => _BackupCollectionState();
}

class _BackupCollectionState extends State<BackupCollection> {
  List<ViewItem> _data = [];
  String? selectedPopupMenuItem;

  @override
  void initState() {
    super.initState();
    _getBackupDownloads();
  }

  // Gets the contents of the backup PIN download folder
  void _getBackupDownloads() async {
    final folderContents =
        await locator<FileOpsService>().getBackupDownloadContents();

    setState(() {
      _data = folderContents.map((e) {
        return ViewItem()
          ..date = e.date
          ..subItems = e.subItems;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: MyExpandableList(items: _data),
      ),
    );
  }
}

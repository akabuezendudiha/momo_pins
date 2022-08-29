import 'package:flutter/material.dart';
import 'package:momo_pins/dto/list_menu.dart';
import 'package:momo_pins/main.dart';
import 'package:momo_pins/services/file_ops_service.dart';
import 'package:momo_pins/widgets/expandable_list.dart';

// This is the type used for the PopupMenuButton return
enum Menu { refresh, delete, wipe }

class PinCollection extends StatefulWidget {
  const PinCollection({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<PinCollection> createState() => _PinCollectionState();
}

class _PinCollectionState extends State<PinCollection> {
  List<ViewItem> _data = []; 

  PopupMenuItem<Menu> popupMenuItem(IconData? icon, String text, Menu value) {
    return PopupMenuItem<Menu>(
        value: value,
        child: TextButton.icon(
          icon: Icon(icon),
          label: Text(text),
          onPressed: null,
        ));
  }

  @override
  void initState() {
    super.initState();
    // Loads pin download folder
    _getLocalDownloads();
  }

  // Gets contents of the PIN download folder
  void _getLocalDownloads() async {
    final folderContents =
        await locator<FileOpsService>().getLocalDownloadContents();

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
        appBar: AppBar(title: const Text("My PIN Collection"), actions: [
          PopupMenuButton<Menu>(
              icon: const Icon(Icons.more_vert),
              onSelected: (Menu item) {
                // Handles the menu selection
              },
              itemBuilder: (context) => <PopupMenuEntry<Menu>>[
                    popupMenuItem(Icons.refresh, 'Refresh', Menu.refresh),
                    popupMenuItem(Icons.delete, 'Wipe Data', Menu.delete),
                    popupMenuItem(Icons.sort, 'Sort By..', Menu.wipe)
                  ])
        ]),
        body: SingleChildScrollView(
          child: _data.isNotEmpty
              ? MyExpandableList(items: _data)
              : const Padding(
                  padding: EdgeInsets.only(
                    top: 18.0,
                  ),
                  child: Center(
                    child: Text('No PIN(s) Downloaded'),
                  ),
                ),
        ));
  }
}

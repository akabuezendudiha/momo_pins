import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:momo_pins/helpers/shared_pref.dart';

import '../dto/vend_type.dart';
import '../main.dart';
import '../widgets/grid_text_button.dart';
import '../widgets/vend_panel_display.dart';

class MyHome extends StatefulWidget {
  const MyHome({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  DownloadState? downloadState = DownloadState.stopped;
  VendType? vendTypeOptions;
  int pinsDownloaded = 0;

  Color get getDownloadStateColor {
    switch (downloadState) {
      case DownloadState.running:
        return Colors.grey;
      default:
        return Colors.green;
    }
  }

  IconData get getDownloadStateIconData {
    switch (downloadState) {
      case DownloadState.running:
        return Icons.stop;
      default:
        return Icons.play_arrow;
    }
  }

  String get getDownloadStateLabelString {
    switch (downloadState) {
      case DownloadState.running:
        return 'Stop PIN Download';
      default:
        return 'Start PIN Download';
    }
  }

  Future<void> updateAppState() async {
    VendType? vendType = await locator<AppSharedPreference>().getVendType();
    int downloaded = 0;
    setState(() {
      downloadState = DownloadState.stopped;
      vendTypeOptions = vendType;
      pinsDownloaded = downloaded;
    });
  }

  void _startPinDownload() async {
    setState(() {
      if (downloadState == DownloadState.running) {
        downloadState = DownloadState.stopped;
      } else {
        downloadState = DownloadState.running;
      }
    });
  }  

  @override
  void initState() {
    super.initState();
    updateAppState();
  }

  void _openBackup() async {
    await Navigator.pushNamed(context, '/backup_collection');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () => _openBackup(),
            icon: const Icon(Icons.backup_outlined),
          )
        ],
      ),
      body: SingleChildScrollView(
        // physics: const NeverScrollableScrollPhysics(),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
          ),
          padding: const EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 24.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: VendPanelDisplay(
                  downloadState: downloadState ?? DownloadState.stopped,
                  vendTypeOptions: vendTypeOptions ?? vendTypeTemplateList[0],
                  pinsDownloaded: pinsDownloaded,
                ),
              ),
              StaggeredGrid.count(
                crossAxisCount: 4,
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
                children: [
                  StaggeredGridTile.count(
                    crossAxisCellCount: 4,
                    mainAxisCellCount: 2,
                    child: gridTextButton(
                      onPressed: () => _startPinDownload(),
                      backgroundColor: getDownloadStateColor,
                      iconData: getDownloadStateIconData,
                      text: getDownloadStateLabelString,
                      iconSize: 75.0,
                    ),
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 2,
                    mainAxisCellCount: 2,
                    child: gridTextButton(
                      onPressed: () async {
                        await Navigator.pushNamed(
                          context,
                          '/pin_collections',
                        );
                        // Update UI
                        updateAppState();
                      },
                      backgroundColor: Colors.blue[400],
                      iconData: Icons.shopping_basket,
                      text: 'My PIN(s)',
                      iconSize: 50.0,
                    ),
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 2,
                    mainAxisCellCount: 2,
                    child: gridTextButton(
                      onPressed: () async {
                        await Navigator.pushNamed(
                          context,
                          '/balance',
                        );
                      },
                      backgroundColor: Colors.deepPurple[200],
                      iconData: Icons.balance,
                      text: 'Balance',
                      iconSize: 50.0,
                    ),
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 4,
                    mainAxisCellCount: 1,
                    child: gridTextButton(
                      onPressed: () async {
                        await Navigator.pushNamed(
                          context,
                          '/settings',
                        );
                        // Update UI
                        updateAppState();
                      },
                      backgroundColor: Colors.amber[900],
                      iconData: Icons.settings,
                      iconSize: 40,
                      text: 'Settings',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:momo_pins/dto/vend_type.dart';

enum DownloadState { running, stopped }

String sayHello(String name) {
  return 'Hello, $name';
}

class VendPanelDisplay extends StatefulWidget {
  const VendPanelDisplay({
    Key? key,
    required this.downloadState,
    required this.vendTypeOptions,
    required this.pinsDownloaded,
  }) : super(key: key);
  final DownloadState downloadState;
  final VendType? vendTypeOptions;
  final int pinsDownloaded;

  @override
  State<VendPanelDisplay> createState() => _VendPanelDisplayState();
}

class _VendPanelDisplayState extends State<VendPanelDisplay> {
  // Arrow function to format date
  String getCurrentDate() => DateFormat.yMMMEd().format(DateTime.now());

  Widget rowDivider({double height = 18}) {
    return Divider(
      height: height,
      color: Colors.black54,
      thickness: 1,
    );
  }

  TextStyle labelTextStyle() {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.green[700],
    );
  }

  TextStyle detailTextStyle() {
    return const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      // fontStyle: FontStyle.italic,
    );
  }

  Color get getDownloadStateColor {
    switch (widget.downloadState) {
      case DownloadState.running:
        return Colors.green;
      default:
        return Colors.red;
    }
  }

  String get getDownloadStateString {
    switch (widget.downloadState) {
      case DownloadState.running:
        return 'PIN Download Running';
      default:
        return 'PIN Download Stopped';
    }
  }

  Icon get getDownloadStateIcon {
    Color iconColor = getDownloadStateColor;
    switch (widget.downloadState) {
      case DownloadState.running:
        return Icon(Icons.play_arrow, color: iconColor);
      default:
        return Icon(Icons.stop, color: iconColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 1.25,
              spreadRadius: 0.025,
            )
          ]),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Welcome,',
                  style: TextStyle(
                    fontSize: 21.0,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue[700],
                  )),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  getCurrentDate(),
                  style: const TextStyle(
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.bold,
                    wordSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          rowDivider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getDownloadStateIcon,
              Text(
                getDownloadStateString,
                style: const TextStyle(
                  fontSize: 18.0,
                ),
              )
            ],
          ),
          rowDivider(),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Text(
                  'Current Vend Status',
                  style: labelTextStyle().copyWith(
                    color: Colors.grey,
                    fontSize: 22.0,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Logical PIN:',
                    style: labelTextStyle(),
                  ),
                  Text(
                    widget.vendTypeOptions?.text ?? 'Not Set',
                    style: detailTextStyle(),
                  )
                ],
              ),
              const SizedBox(height: 4.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quantity:',
                    style: labelTextStyle(),
                  ),
                  Text(
                    '${widget.pinsDownloaded} PIN(s)',
                    style: detailTextStyle(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

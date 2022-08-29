import 'package:flutter/material.dart';
import 'package:momo_pins/dto/list_menu.dart';

class MyExpandableList extends StatefulWidget {
  const MyExpandableList({Key? key, required this.items}) : super(key: key);
  final List<ViewItem> items;

  @override
  State<MyExpandableList> createState() => _MyExpandableListState();
}

class _MyExpandableListState extends State<MyExpandableList> {

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          widget.items[index].isExpanded = !isExpanded;
        });
      },
      children: widget.items.map<ExpansionPanel>((item) {
        return ExpansionPanel(          
          headerBuilder: (context, isExpanded) {
            return ListTile(
              title: Text('${item.date}'),
            );
          },          
          body: Container(
            color: Colors.white,
            child: Column(
              children: item.subItems!.map<ListTile>((subItem) => ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${subItem.label}'),
                    Text('PINS: ${subItem.numOfPins}')
                  ],
                ),
              )).toList(),
            ),
          ),
          isExpanded: item.isExpanded,
          canTapOnHeader: true,
          backgroundColor: Colors.grey[200],
        );
      }).toList(),
    );
  }

}
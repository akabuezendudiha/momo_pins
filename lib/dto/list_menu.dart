class ViewItem extends Item {
  bool isExpanded;
  ViewItem({this.isExpanded = false});
}

class Item {
  String? date;
  List<SubItem>? subItems = [];
  Item({this.date, this.subItems});

  // Item.fromJson(Map<String, dynamic> json) {
  //   date = json['date'];
  //   if (json['contents'] != null) {
  //     subItems?.clear();
  //     json['contents'].forEach((v) {
  //       subItems?.add(SubItem.fromJson(v));
  //     });
  //   }
  // }
}

class SubItem {
  String? label;
  String? numOfPins;
  SubItem({this.label, this.numOfPins});

  // SubItem.fromJson(Map<String, String> json) {
  //   label = json['label'];
  //   numOfPins = json['numOfPins'];
  // }
}
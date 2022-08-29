class SimCardData {
  int slotIndex;
  String displayName;
  SimCardData(this.slotIndex, this.displayName);

  SimCardData.fromJson(Map<String, dynamic> json) :
    slotIndex = json['slotIndex'],
    displayName = json['display_name'];

  Map<String, dynamic> toJson() => {
    'slotIndex': slotIndex,
    'display_name': displayName,
  };
  
}
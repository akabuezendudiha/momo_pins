// Vend Types List Template
List<VendType> vendTypeTemplateList = [
  VendType(1,'MTN100'),
  VendType(2, 'MTN200'),
  VendType(3, 'MTN500'),
  VendType(4, 'MTN1000')
];

// VendType class object
class VendType {
  int option;
  String text;
  VendType(this.option, this.text); 

  VendType.fromJson(Map<String, dynamic> json) :
    option = json['option'],
    text = json['text'];    
  

  Map<String, dynamic> toJson() => {
      'option': option,
      'text': text,
    };  
}
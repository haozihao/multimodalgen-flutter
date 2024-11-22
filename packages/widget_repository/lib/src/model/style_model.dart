import 'package:equatable/equatable.dart';


/// create by blueming.wu
/// 风格数据模型


class StyleModel extends Equatable {
  final int id;
  final String name;
  final int sort;
  final String icon;
  // final List<int> children;


  const StyleModel(
      {
        required this.id,
        required  this.name,
        required this.sort,
        required this.icon,
        // required this.children,
      });

  @override
  List<Object> get props => [id];


  static StyleModel fromJson(Map<String, dynamic> styleModel) {
    int id = styleModel['id'];
    String name = styleModel['name'];
    int sort = styleModel.containsKey('sort') ? styleModel['sort'] : 0;
    String icon = styleModel['icon'];

    return StyleModel(
      id: id,
      name: name,
      sort: sort,
      icon: icon,
    );
  }

  static convertImage(String name) {
    // return image.isEmpty ? null : AssetImage(image);
    return null;
  }


  @override
  String toString() {
    return 'StyleModel{id: $id, name: $name, deprecated: $deprecated, }';
  }

  static List<int> formatLinkTo(String links) {
    if(links.isEmpty){
      return [];
    }
    if(!links.contains(',')){
      return [int.parse(links)];
    }
    return links.split(',').map<int>((e)=>int.parse(e)).toList();
  }

}

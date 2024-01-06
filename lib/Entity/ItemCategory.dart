import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import 'User.dart';

@JsonSerializable()
class ItemCategory {
  final int id;
  final String name;
  final String itemClass;
  final String image;
  bool hasImageStored;
  Widget imageStored;

  ItemCategory({
    required this.id,
    required this.name,
    required this.itemClass,
    required this.image,
    required this.hasImageStored,
    required this.imageStored,
  });

  factory ItemCategory.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      print('MenuItem.fromJson: $json');
    }
    return ItemCategory(
      id: json['id'],
      name: json['name'],
      itemClass: json['itemClass'],
      image: json['image'],
      hasImageStored: false,
      imageStored: Container(),
    );
  }

  static List<ItemCategory> getItemCategoryDataList(Map<String, dynamic> json) {
    List<ItemCategory> itemCategoryDataList = [];
    for (Map<String,dynamic> itemCategoryData in json['data']) {
      ItemCategory oneItemCategoryData = ItemCategory.fromJson(itemCategoryData);
      itemCategoryDataList.add(oneItemCategoryData);
    }
    return itemCategoryDataList;
  }
}
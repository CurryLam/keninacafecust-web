import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import 'User.dart';

@JsonSerializable()
class MenuItem {
  final int id;
  final String itemClass;
  final String image;
  final String name;
  final double price;
  final String description;
  final bool isOutOfStock;
  final bool hasVariant;
  final String variants;
  final bool hasSize;
  final String sizes;
  final String category_name;
  final String user_created_name;
  final String user_updated_name;

  const MenuItem({
    required this.id,
    required this.itemClass,
    required this.image,
    required this.name,
    required this.price,
    required this.description,
    required this.isOutOfStock,
    required this.hasVariant,
    required this.variants,
    required this.hasSize,
    required this.sizes,
    required this.category_name,
    required this.user_created_name,
    required this.user_updated_name,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      print('MenuItem.fromJson: $json');
    }
    return MenuItem(
      id: json['id'],
      itemClass: json['itemClass'],
      image: json['image'] ?? '',
      name: json['name'],
      price: json['price'],
      description: json['description'] ?? '',
      isOutOfStock: json['isOutOfStock'],
      hasVariant: json['hasVariant'],
      variants: json['variants'] ?? '',
      hasSize: json['hasSize'],
      sizes: json['sizes'] ?? '',
      category_name: json['category_name'],
      user_created_name: json['user_created_name'] != null ? json['user_created_name'] : '',
      user_updated_name: json['user_updated_name'] != null ? json['user_updated_name'] : '',
    );
  }

  static List<MenuItem> getMenuItemDataList(Map<String, dynamic> json) {
    List<MenuItem> menuItemDataList = [];
    for (Map<String,dynamic> menuItemData in json['data']) {
      MenuItem oneMenuItemData = MenuItem.fromJson(menuItemData);
      menuItemDataList.add(oneMenuItemData);
    }
    return menuItemDataList;
  }

  static List<MenuItem> getItemCategoryExistMenuItemList(Map<String, dynamic> json) {
    List<MenuItem> itemCategoryExistMenuItemList = [];
    print(json['data']);
    for (Map<String,dynamic> itemCategoryExistMenuItem in json['data']) {
      print(itemCategoryExistMenuItem);
      MenuItem oneitemCategoryExistMenuItem = MenuItem.fromJson(itemCategoryExistMenuItem);
      itemCategoryExistMenuItemList.add(oneitemCategoryExistMenuItem);
    }
    print(itemCategoryExistMenuItemList);
    return itemCategoryExistMenuItemList;
  }
}
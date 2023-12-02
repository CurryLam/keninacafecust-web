import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:tuple/tuple.dart';

import 'User.dart';

@JsonSerializable()
class MenuItem {
  final int id;
  final String itemClass;
  final String image;
  final String name;
  final double price_standard;
  final double price_large;
  final String description;
  final bool isOutOfStock;
  final bool hasVariant;
  final String variants;
  final bool hasSize;
  final String sizes;
  final String category_name;
  final String user_created_name;
  final String user_updated_name;
  int numOrder; // Cart and Order purpose
  // double priceNumOrder; // Cart and Order purpose
  String sizeChosen; // Cart and Order purpose
  String variantChosen; // Cart and Order purpose
  String remarks; // Cart and Order purpose

  MenuItem({
    required this.id,
    required this.itemClass,
    required this.image,
    required this.name,
    required this.price_standard,
    required this.price_large,
    required this.description,
    required this.isOutOfStock,
    required this.hasVariant,
    required this.variants,
    required this.hasSize,
    required this.sizes,
    required this.category_name,
    required this.user_created_name,
    required this.user_updated_name,
    required this.numOrder, // Cart and Order purpose
    // required this.priceNumOrder, // Cart and Order purpose
    required this.sizeChosen, // Cart and Order purpose
    required this.variantChosen, // Cart and Order purpose
    required this.remarks, // Cart and Order purpose
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    // if (kDebugMode) {
    //   print('MenuItem.fromJson: $json');
    // }
    return MenuItem(
      id: json['id'],
      itemClass: json['itemClass'],
      image: json['image'] ?? '',
      name: json['name'],
      price_standard: json['price_standard'],
      price_large: json['price_large'] ?? 0,
      description: json['description'] ?? '',
      isOutOfStock: json['isOutOfStock'],
      hasVariant: json['hasVariant'],
      variants: json['variants'] ?? '',
      hasSize: json['hasSize'],
      sizes: json['sizes'] ?? '',
      category_name: json['category_name'],
      user_created_name: json['user_created_name'] != null ? json['user_created_name'] : '',
      user_updated_name: json['user_updated_name'] != null ? json['user_updated_name'] : '',
      numOrder: 0, // Cart and Order purpose
      // priceNumOrder: 0, // Cart and Order purpose
      sizeChosen: "", // Cart and Order purpose
      variantChosen: "", // Cart and Order purpose
      remarks: "", // Cart and Order purpose
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemClass': itemClass,
      'image': image,
      'name': name,
      'price_standard': price_standard,
      'description': description,
      'isOutOfStock': isOutOfStock,
      'hasVariant': hasVariant,
      'variants': variants,
      'hasSize': hasSize,
      'sizes': sizes,
      'category_name': category_name,
      'numOrder': numOrder, // Cart and Order purpose
      'sizeChosen': sizeChosen, // Cart and Order purpose
      'variantChosen': variantChosen, // Cart and Order purpose
      'remarks': remarks, // Cart and Order purpose
    };
  }

  @override
  bool operator ==(Object other) {
    if (other is! MenuItem) return false;
    if (name == other.name && sizeChosen == other.sizeChosen && variantChosen == other.variantChosen && remarks == other.remarks) return true;
    return false;
  }

  @override
  int get hashCode => id.hashCode;

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
    for (Map<String,dynamic> itemCategoryExistMenuItem in json['data']) {
      MenuItem oneitemCategoryExistMenuItem = MenuItem.fromJson(itemCategoryExistMenuItem);
      itemCategoryExistMenuItemList.add(oneitemCategoryExistMenuItem);
    }
    return itemCategoryExistMenuItemList;
  }

  static Tuple2<List<MenuItem>, List<MenuItem>> getBestSellingMenuItemList(Map<String, dynamic> json) {
    List<MenuItem> bestSellingFoodsList = [];
    List<MenuItem> bestSellingDrinksList = [];
    List<Map<String, dynamic>> bestSellingFoodsListGet = List<Map<String, dynamic>>.from(json['data']['all_stock']);
    List<Map<String, dynamic>> bestSellingDrinksListGet = List<Map<String, dynamic>>.from(json['data']['all_stock_with_current_supplier']);
    for (Map<String,dynamic> foods in bestSellingFoodsListGet) {
      MenuItem oneFoods = MenuItem.fromJson(foods);
      bestSellingFoodsList.add(oneFoods);
    }
    for (Map<String,dynamic> drinks in bestSellingDrinksListGet) {
      MenuItem oneDrinks = MenuItem.fromJson(drinks);
      bestSellingDrinksList.add(oneDrinks);
    }
    if (kDebugMode) {
      print(bestSellingFoodsList);
      print(bestSellingDrinksList);
    }
    return Tuple2<List<MenuItem>, List<MenuItem>>(bestSellingFoodsList, bestSellingDrinksList);
  }

}
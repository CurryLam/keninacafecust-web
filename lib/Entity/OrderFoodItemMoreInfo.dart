import 'package:json_annotation/json_annotation.dart';

import 'FoodOrder.dart';
import 'MenuItem.dart';

@JsonSerializable()
class OrderFoodItemMoreInfo {
  final int id;
  final String remarks;
  final String size;
  final String variant;
  final bool is_done;
  final int food_order;
  final String menu_item_image;
  final String menu_item_name;
  final double menu_item_price_standard;
  final double menu_item_price_large;
  double numOrder;

  OrderFoodItemMoreInfo({
    required this.id,
    required this.remarks,
    required this.size,
    required this.variant,
    required this.is_done,
    required this.food_order,
    required this.menu_item_image,
    required this.menu_item_name,
    required this.menu_item_price_standard,
    required this.menu_item_price_large,
    required this.numOrder,
  });

  factory OrderFoodItemMoreInfo.fromJson(Map<dynamic, dynamic> json) {
    // if (kDebugMode) {
    //   print('MenuItem.fromJson: $json');
    // }
    return OrderFoodItemMoreInfo(
      id: json['id'],
      remarks: json['description'] ?? '',
      size: json['size'] ?? '',
      variant: json['variant'] ?? '',
      is_done: json['is_done'],
      food_order: json['food_order'],
      menu_item_image: json['menu_item_image'],
      menu_item_name: json['menu_item_name'],
      menu_item_price_standard: json['menu_item_price_standard'],
      menu_item_price_large: json['menu_item_price_large'] ?? 0,
      numOrder: json['num_order'],

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'remarks': remarks,
      'size': size,
      'variant': variant,
      'is_done': is_done,
      'food_order': food_order,
      'menu_item_image': menu_item_image,
      'menu_item_name': menu_item_name,
      'menu_item_price_standard': menu_item_price_standard,
      'menu_item_price_large': menu_item_price_large,
      'numOrder': numOrder,
    };
  }

  static List<OrderFoodItemMoreInfo> getOrderFoodItemDataList(Map<String, dynamic> json) {
    List<OrderFoodItemMoreInfo> orderFoodItemDataList = [];
    for (Map<String,dynamic> orderFoodItemData in json['data']) {
      OrderFoodItemMoreInfo oneOrderFoodItemData = OrderFoodItemMoreInfo.fromJson(orderFoodItemData);
      orderFoodItemDataList.add(oneOrderFoodItemData);
    }
    return orderFoodItemDataList;
  }

// static List<MenuItem> getItemCategoryExistMenuItemList(Map<String, dynamic> json) {
//   List<MenuItem> itemCategoryExistMenuItemList = [];
//   for (Map<String,dynamic> itemCategoryExistMenuItem in json['data']) {
//     MenuItem oneitemCategoryExistMenuItem = MenuItem.fromJson(itemCategoryExistMenuItem);
//     itemCategoryExistMenuItemList.add(oneitemCategoryExistMenuItem);
//   }
//   return itemCategoryExistMenuItemList;
// }

}
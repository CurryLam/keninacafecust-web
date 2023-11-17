import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import 'MenuItem.dart';
import 'OrderFoodItemMoreInfo.dart';
import 'User.dart';

@JsonSerializable()
class CartForOrderFoodItemMoreInfo {
  List<OrderFoodItemMoreInfo> orderFoodItemMoreInfoList;
  double order_grand_total;

  CartForOrderFoodItemMoreInfo({
    required this.orderFoodItemMoreInfoList,
    required this.order_grand_total,
  });

  List<OrderFoodItemMoreInfo> getFoodItemOrderList () {
    return orderFoodItemMoreInfoList;
  }

  double getOrderGrandTotal () {
    return order_grand_total;
  }

  bool containFoodItem () {
    if (orderFoodItemMoreInfoList.isNotEmpty) {
      return true;
    }
    else {
      return false;
    }
  }

  void addToCartForOrderFoodItemMoreInfo (OrderFoodItemMoreInfo orderFoodItemMoreInfo) {
    OrderFoodItemMoreInfo itemAdded = OrderFoodItemMoreInfo(
      id: orderFoodItemMoreInfo.id,
      remarks: orderFoodItemMoreInfo.remarks,
      size: orderFoodItemMoreInfo.size,
      variant: orderFoodItemMoreInfo.variant,
      is_done: orderFoodItemMoreInfo.is_done,
      food_order: orderFoodItemMoreInfo.food_order,
      menu_item_image: orderFoodItemMoreInfo.menu_item_image,
      menu_item_name: orderFoodItemMoreInfo.menu_item_name,
      menu_item_price_standard: orderFoodItemMoreInfo.menu_item_price_standard,
      menu_item_price_large: orderFoodItemMoreInfo.menu_item_price_large,
      numOrder: orderFoodItemMoreInfo.numOrder,
    );
    orderFoodItemMoreInfoList.add(itemAdded);
  }

  void addOrderGrandTotal (OrderFoodItemMoreInfo orderFoodItemMoreInfo, double numMenuItemAdded) {
    if (orderFoodItemMoreInfo.size == "" || orderFoodItemMoreInfo.size == "Standard") {
      order_grand_total += (orderFoodItemMoreInfo.menu_item_price_standard*numMenuItemAdded);
    } else if (orderFoodItemMoreInfo.size == "Large") {
      order_grand_total += (orderFoodItemMoreInfo.menu_item_price_large*numMenuItemAdded);
    }
  }

  void deductOrderGrandTotal (OrderFoodItemMoreInfo orderFoodItemMoreInfo, double numMenuItemDeducted) {
    if (orderFoodItemMoreInfo.size == "" || orderFoodItemMoreInfo.size == "Standard") {
      order_grand_total -= (orderFoodItemMoreInfo.menu_item_price_standard*numMenuItemDeducted);
    } else if (orderFoodItemMoreInfo.size == "Large") {
      order_grand_total -= (orderFoodItemMoreInfo.menu_item_price_large*numMenuItemDeducted);
    }
  }

  void removeFromCartForOrderFoodItemMoreInfo (OrderFoodItemMoreInfo orderFoodItemMoreInfo) {
    for (int i = 0; i < orderFoodItemMoreInfoList.length; i++) {
      if (orderFoodItemMoreInfoList[i] == orderFoodItemMoreInfo) {
        deductOrderGrandTotal (orderFoodItemMoreInfoList[i], orderFoodItemMoreInfoList[i].numOrder);
        orderFoodItemMoreInfoList[i].numOrder = 0;
        break;
      }
    }
  }

  void increaseNumOrderForOrderFoodItemMoreInfo (OrderFoodItemMoreInfo orderFoodItemMoreInfo) {
    for (int i = 0; i < orderFoodItemMoreInfoList.length; i++) {
      if (orderFoodItemMoreInfoList[i] == orderFoodItemMoreInfo) {
        orderFoodItemMoreInfoList[i].numOrder++;
        addOrderGrandTotal (orderFoodItemMoreInfoList[i], 1);
        break;
      }
    }
  }

  void reduceNumOrderForOrderFoodItemMoreInfo (OrderFoodItemMoreInfo orderFoodItemMoreInfo) {
    for (int i = 0; i < orderFoodItemMoreInfoList.length; i++) {
      if (orderFoodItemMoreInfoList[i] == orderFoodItemMoreInfo) {
        orderFoodItemMoreInfoList[i].numOrder--;
        deductOrderGrandTotal (orderFoodItemMoreInfoList[i], 1);
        break;
      }
    }
  }
}

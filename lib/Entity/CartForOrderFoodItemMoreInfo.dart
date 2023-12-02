import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tuple/tuple.dart';

import 'MenuItem.dart';
import 'OrderFoodItemMoreInfo.dart';
import 'User.dart';

@JsonSerializable()
class CartForOrderFoodItemMoreInfo {
  List<OrderFoodItemMoreInfo> orderFoodItemMoreInfoList;
  double order_grand_total;
  double order_grand_total_before_discount;
  double price_discount_voucher;
  int voucherAppliedIDBefore;
  int voucherAppliedID;
  String voucherApplied_type_name;
  double voucherApplied_cost_off;
  String voucherApplied_free_menu_item_name;
  String voucherApplied_applicable_menu_item_name;
  double voucherApplied_min_spending;
  bool isEditCartOrder;

  CartForOrderFoodItemMoreInfo({
    required this.orderFoodItemMoreInfoList,
    required this.order_grand_total,
    required this.order_grand_total_before_discount,
    required this.price_discount_voucher,
    required this.voucherAppliedIDBefore,
    required this.voucherAppliedID,
    required this.voucherApplied_type_name,
    required this.voucherApplied_cost_off,
    required this.voucherApplied_free_menu_item_name,
    required this.voucherApplied_applicable_menu_item_name,
    required this.voucherApplied_min_spending,
    required this.isEditCartOrder,
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

  bool checkIsLastItem (OrderFoodItemMoreInfo orderFoodItemMoreInfo) {
    bool isLastItem = true;
    for (int i = 0; i < orderFoodItemMoreInfoList.length; i++) {
      if (orderFoodItemMoreInfoList[i] != orderFoodItemMoreInfo) {
        if (orderFoodItemMoreInfoList[i].numOrder > 0) {
          isLastItem = false;
          break;
        }
      }
    }
    return isLastItem;
  }

  void removeVoucher (bool voucherVerified) {
    if (voucherVerified) {
      order_grand_total += price_discount_voucher;
    }
    voucherAppliedID = 0;
    voucherApplied_type_name = "";
    voucherApplied_cost_off = 0;
    voucherApplied_free_menu_item_name = "";
    voucherApplied_applicable_menu_item_name = "";
    price_discount_voucher = 0;
  }

  void applyVoucher (int voucherAppliedID, String voucher_type_name, double cost_off, String free_menu_item_name, String applicable_menu_item_name, double min_spending) {
    this.voucherAppliedID = voucherAppliedID;
    voucherApplied_type_name = voucher_type_name;
    voucherApplied_cost_off = cost_off;
    voucherApplied_free_menu_item_name = free_menu_item_name;
    voucherApplied_applicable_menu_item_name = applicable_menu_item_name;
    voucherApplied_min_spending = min_spending;
    if (voucher_type_name == "Discount") {
      price_discount_voucher = cost_off;
      order_grand_total -= cost_off;
    } else if (voucher_type_name == "FreeItem" || voucher_type_name == "BuyOneFreeOne") {
      for (int i = 0; i < orderFoodItemMoreInfoList.length; i++) {
        if (free_menu_item_name == orderFoodItemMoreInfoList[i].menu_item_name || applicable_menu_item_name == orderFoodItemMoreInfoList[i].menu_item_name) {
          if (orderFoodItemMoreInfoList[i].size == "Large") {
            price_discount_voucher = orderFoodItemMoreInfoList[i].menu_item_price_large;
            continue;
          }
          if (orderFoodItemMoreInfoList[i].size == "" || orderFoodItemMoreInfoList[i].size == "Standard") {
            price_discount_voucher = orderFoodItemMoreInfoList[i].menu_item_price_standard;
            break;
          }
        }
      }
      String roundedValue = order_grand_total.toStringAsFixed(2);
      order_grand_total = double.parse(roundedValue);
      order_grand_total -= price_discount_voucher;
    }
  }

  Tuple2<bool, String> verifyVoucher () {
    double requirementsToFulfill = 0;
    double numOrderOfCurrentFoodItem = 0;
    double numOrderOfFoodItemRequired = 0;
    double lowestPrice = 10000;
    bool voucherApplied = false;
    // order_grand_total = order_grand_total_before_discount;
    if (voucherApplied_type_name == "Discount") {
      if (order_grand_total_before_discount < voucherApplied_min_spending) {
        requirementsToFulfill = voucherApplied_min_spending - order_grand_total_before_discount;
        return Tuple2(voucherApplied, "Add MYR $requirementsToFulfill more to use this voucher");
      }
      voucherApplied = true;
      // order_grand_total -= price_discount_voucher;
      return Tuple2(voucherApplied, "Applied Successfully");
    } else if (voucherApplied_type_name == "FreeItem") {
      for (int i = 0; i < orderFoodItemMoreInfoList.length; i++) {
        if (voucherApplied_free_menu_item_name == orderFoodItemMoreInfoList[i].menu_item_name && orderFoodItemMoreInfoList[i].numOrder >= 1) {
          voucherApplied = true;
          // if (orderFoodItemMoreInfoList[i].size == "Large") {
          //   // price_discount_voucher = orderFoodItemMoreInfoList[i].menu_item_price_large;
          //   if (price_discount_voucher < lowestPrice) {
          //     lowestPrice = price_discount_voucher;
          //   }
          // }
          // if (orderFoodItemMoreInfoList[i].size == "" || orderFoodItemMoreInfoList[i].size == "Standard") {
          //   // price_discount_voucher = orderFoodItemMoreInfoList[i].menu_item_price_standard;
          //   if (price_discount_voucher < lowestPrice) {
          //     lowestPrice = price_discount_voucher;
          //   }
          // }
        }
        if (voucherApplied) {
          // price_discount_voucher = lowestPrice;
          // order_grand_total -= price_discount_voucher;
          return Tuple2(voucherApplied, "Applied Successfully");
        }
      }
      return Tuple2(voucherApplied, "No applicable for this order.");
    } else if (voucherApplied_type_name == "BuyOneFreeOne") {
      for (int i = 0; i < orderFoodItemMoreInfoList.length; i++) {
        if (voucherApplied_applicable_menu_item_name == orderFoodItemMoreInfoList[i].menu_item_name) {
          numOrderOfCurrentFoodItem += orderFoodItemMoreInfoList[i].numOrder;
        }
        if (numOrderOfCurrentFoodItem >= 2) {
          voucherApplied = true;
        }
      }
      if (voucherApplied) {
        return Tuple2(voucherApplied, "Applied Successfully");
        // for (int i = 0; i < orderFoodItemMoreInfoList.length; i++) {
        //   if (voucherApplied_applicable_menu_item_name == orderFoodItemMoreInfoList[i].menu_item_name) {
        //     if (orderFoodItemMoreInfoList[i].size == "Large") {
        //       // price_discount_voucher = orderFoodItemMoreInfoList[i].menu_item_price_large;
        //       if (price_discount_voucher < lowestPrice) {
        //         lowestPrice = price_discount_voucher;
        //       }
        //     }
        //     if (orderFoodItemMoreInfoList[i].size == "" || orderFoodItemMoreInfoList[i].size == "Standard") {
        //       // price_discount_voucher = orderFoodItemMoreInfoList[i].menu_item_price_standard;
        //       if (price_discount_voucher < lowestPrice) {
        //         lowestPrice = price_discount_voucher;
        //         i = orderFoodItemMoreInfoList.length - 1;
        //       }
        //     }
        //   }
        //   if (i == orderFoodItemMoreInfoList.length - 1) {
        //     price_discount_voucher = lowestPrice;
        //     // order_grand_total -= price_discount_voucher;
        //     return Tuple2(voucherApplied, "Applied Successfully");
        //   }
        // }
      }
      numOrderOfFoodItemRequired = 2 - numOrderOfCurrentFoodItem;
      if (numOrderOfFoodItemRequired == 2) {
        return Tuple2(voucherApplied, "No applicable for this order.");
      }
      return Tuple2(voucherApplied, "Add ${numOrderOfFoodItemRequired.toStringAsFixed(0)} more to apply this voucher.");
    }
    return Tuple2(voucherApplied, "An error is occurred when verifying the voucher applied before");
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

  void addOrderGrandTotal (OrderFoodItemMoreInfo orderFoodItemMoreInfo) {
    if (orderFoodItemMoreInfo.size == "" || orderFoodItemMoreInfo.size == "Standard") {
      order_grand_total += orderFoodItemMoreInfo.menu_item_price_standard;
      order_grand_total_before_discount += orderFoodItemMoreInfo.menu_item_price_standard;
    } else if (orderFoodItemMoreInfo.size == "Large") {
      order_grand_total += orderFoodItemMoreInfo.menu_item_price_large;
      order_grand_total_before_discount += orderFoodItemMoreInfo.menu_item_price_standard;
    }
  }

  void deductOrderGrandTotal (OrderFoodItemMoreInfo orderFoodItemMoreInfo, double numMenuItemDeducted) {
    if (orderFoodItemMoreInfo.size == "" || orderFoodItemMoreInfo.size == "Standard") {
      order_grand_total -= (orderFoodItemMoreInfo.menu_item_price_standard * numMenuItemDeducted);
      order_grand_total_before_discount -= (orderFoodItemMoreInfo.menu_item_price_standard * numMenuItemDeducted);
    } else if (orderFoodItemMoreInfo.size == "Large") {
      order_grand_total -= (orderFoodItemMoreInfo.menu_item_price_large * numMenuItemDeducted);
      order_grand_total_before_discount -= (orderFoodItemMoreInfo.menu_item_price_large * numMenuItemDeducted);
    }
  }

  void increaseNumOrderForOrderFoodItemMoreInfo (OrderFoodItemMoreInfo orderFoodItemMoreInfo) {
    for (int i = 0; i < orderFoodItemMoreInfoList.length; i++) {
      if (orderFoodItemMoreInfoList[i] == orderFoodItemMoreInfo) {
        orderFoodItemMoreInfoList[i].numOrder++;
        addOrderGrandTotal (orderFoodItemMoreInfoList[i]);
        if (order_grand_total == order_grand_total_before_discount) {
          if (voucherApplied_type_name == "Discount" && order_grand_total > voucherApplied_min_spending) {
            order_grand_total -= voucherApplied_cost_off;
          } else if (voucherApplied_type_name == "FreeItem" && voucherApplied_free_menu_item_name == orderFoodItemMoreInfo.menu_item_name) {
            var calculateResult = calculatePriceDiscountAndNumItemOrder(orderFoodItemMoreInfo);
            if (calculateResult.item1 >= 1) {
              order_grand_total -= calculateResult.item2;
            } else {
              order_grand_total = order_grand_total_before_discount;
            }
          } else if (voucherApplied_type_name == "BuyOneFreeOne" && voucherApplied_applicable_menu_item_name == orderFoodItemMoreInfo.menu_item_name) {
            var calculateResult = calculatePriceDiscountAndNumItemOrder(orderFoodItemMoreInfo);
            if (calculateResult.item1 >= 2) {
              order_grand_total -= calculateResult.item2;
            } else {
              order_grand_total = order_grand_total_before_discount;
            }
          }
        }
        break;
      }
    }
  }

  Tuple2<double, double> calculatePriceDiscountAndNumItemOrder (OrderFoodItemMoreInfo orderFoodItemMoreInfo) {
    double num_promotion_menu_item = 0;
    double lowest_price = 1000;
    for (int i = 0; i < orderFoodItemMoreInfoList.length; i++) {
      if (orderFoodItemMoreInfo.menu_item_name == orderFoodItemMoreInfoList[i].menu_item_name) {
        num_promotion_menu_item += orderFoodItemMoreInfoList[i].numOrder;
        if (orderFoodItemMoreInfoList[i].size == "Large" && orderFoodItemMoreInfoList[i].menu_item_price_large < lowest_price) {
          lowest_price = orderFoodItemMoreInfoList[i].menu_item_price_large;
        } else if (orderFoodItemMoreInfoList[i].size == "" || orderFoodItemMoreInfoList[i].size == "Standard" && orderFoodItemMoreInfoList[i].menu_item_price_standard < lowest_price) {
          lowest_price = orderFoodItemMoreInfoList[i].menu_item_price_standard;
        }
      }
    }
    return Tuple2(num_promotion_menu_item, lowest_price);
  }

  void reduceNumOrderForOrderFoodItemMoreInfo (OrderFoodItemMoreInfo orderFoodItemMoreInfo, double numOrder) {
    for (int i = 0; i < orderFoodItemMoreInfoList.length; i++) {
      if (orderFoodItemMoreInfoList[i] == orderFoodItemMoreInfo) {
        orderFoodItemMoreInfoList[i].numOrder -= numOrder;
        deductOrderGrandTotal (orderFoodItemMoreInfoList[i], numOrder);
        if (voucherApplied_type_name == "Discount" && order_grand_total < voucherApplied_min_spending) {
          order_grand_total = order_grand_total_before_discount;
        } else if (voucherApplied_type_name == "FreeItem" && voucherApplied_free_menu_item_name == orderFoodItemMoreInfo.menu_item_name) {
          var calculateResult = calculatePriceDiscountAndNumItemOrder(orderFoodItemMoreInfo);
          if (calculateResult.item1 == 0) {
            order_grand_total = order_grand_total_before_discount;
          } else {
            order_grand_total = order_grand_total_before_discount;
            order_grand_total -= calculateResult.item2;
          }
        } else if (voucherApplied_type_name == "BuyOneFreeOne" && voucherApplied_applicable_menu_item_name == orderFoodItemMoreInfo.menu_item_name) {
          var calculateResult = calculatePriceDiscountAndNumItemOrder(orderFoodItemMoreInfo);
          if (calculateResult.item1 <= 1) {
            order_grand_total = order_grand_total_before_discount;
          } else {
            order_grand_total = order_grand_total_before_discount;
            order_grand_total -= calculateResult.item2;
          }
        }
        break;
      }
    }
  }
}

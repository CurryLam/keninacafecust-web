import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tuple/tuple.dart';

import 'MenuItem.dart';
import 'User.dart';
import 'VoucherAssignUserMoreInfo.dart';

@JsonSerializable()
class Cart {
  int id;
  List<MenuItem> menuItem;
  int voucherAppliedID;
  String voucherApplied_type_name;
  double voucherApplied_cost_off;
  String voucherApplied_free_menu_item_name;
  String voucherApplied_applicable_menu_item_name;
  double voucherApplied_min_spending;
  int numMenuItemOrder;
  double price_discount;
  double grandTotalBeforeDiscount;
  double grandTotalAfterDiscount;

  Cart({
    required this.id,
    required this.menuItem,
    required this.voucherAppliedID,
    required this.voucherApplied_type_name,
    required this.voucherApplied_cost_off,
    required this.voucherApplied_free_menu_item_name,
    required this.voucherApplied_applicable_menu_item_name,
    required this.voucherApplied_min_spending,
    required this.numMenuItemOrder,
    required this.price_discount,
    required this.grandTotalBeforeDiscount,
    required this.grandTotalAfterDiscount,
  });

  List<MenuItem> getMenuItemList () {
    return menuItem;
  }

  int getNumMenuItemOrder () {
    return numMenuItemOrder;
  }

  double getGrandTotalBeforeDiscount () {
    return grandTotalBeforeDiscount;
  }

  double getGrandTotalAfterDiscount () {
    return grandTotalAfterDiscount;
  }

  String getDiffBetweenPriceGrandAndGross () {
    return (grandTotalBeforeDiscount - grandTotalAfterDiscount).toStringAsFixed(2);
  }

  bool containMenuItem () {
    if (menuItem.isNotEmpty) {
      return true;
    }
    else {
      return false;
    }
  }

  int getVoucherAppliedID () {
    return voucherAppliedID;
  }

  void applyVoucher (int voucherAppliedID, String voucher_type_name, double cost_off, String free_menu_item_name, String applicable_menu_item_name, double min_spending) {
    this.voucherAppliedID = voucherAppliedID;
    voucherApplied_type_name = voucher_type_name;
    voucherApplied_cost_off = cost_off;
    voucherApplied_free_menu_item_name = free_menu_item_name;
    voucherApplied_applicable_menu_item_name = applicable_menu_item_name;
    voucherApplied_min_spending = min_spending;
    if (voucher_type_name == "Discount") {
      price_discount = cost_off;
      grandTotalAfterDiscount -= cost_off;
    } else if (voucher_type_name == "FreeItem" || voucher_type_name == "BuyOneFreeOne") {
      for (int i = 0; i < menuItem.length; i++) {
        if (free_menu_item_name == menuItem[i].name || applicable_menu_item_name == menuItem[i].name) {
          if (menuItem[i].sizeChosen == "Large") {
            price_discount = menuItem[i].price_large;
            continue;
          }
          if (menuItem[i].sizeChosen == "" || menuItem[i].sizeChosen == "Standard") {
            price_discount = menuItem[i].price_standard;
            break;
          }
        }
      }
      grandTotalAfterDiscount -= price_discount;
    }
  }

  void removeVoucher (bool voucherVerified) {
    if (voucherVerified) {
      grandTotalAfterDiscount += price_discount;
    }
    voucherAppliedID = 0;
    voucherApplied_type_name = "";
    voucherApplied_cost_off = 0;
    voucherApplied_free_menu_item_name = "";
    voucherApplied_applicable_menu_item_name = "";
    price_discount = 0;
  }

  Tuple2<bool, String> verifyVoucher () {
    double requirementsToFulfill = 0;
    double numOrderOfCurrentFoodItem = 0;
    double numOrderOfFoodItemRequired = 0;
    double lowestPrice = 10000;
    bool voucherApplied = false;
    grandTotalAfterDiscount = grandTotalBeforeDiscount;
    if (voucherApplied_type_name == "Discount") {
      if (grandTotalBeforeDiscount < voucherApplied_min_spending) {
        requirementsToFulfill = voucherApplied_min_spending - grandTotalBeforeDiscount;
        return Tuple2(voucherApplied, "Add MYR $requirementsToFulfill more to use this voucher");
      }
      voucherApplied = true;
      grandTotalAfterDiscount -= price_discount;
      return Tuple2(voucherApplied, "Applied Successfully");
    } else if (voucherApplied_type_name == "FreeItem") {
      for (int i = 0; i < menuItem.length; i++) {
        if (voucherApplied_free_menu_item_name == menuItem[i].name) {
          voucherApplied = true;
          if (menuItem[i].sizeChosen == "Large") {
            price_discount = menuItem[i].price_large;
            if (price_discount < lowestPrice) {
              lowestPrice = price_discount;
            }
          }
          if (menuItem[i].sizeChosen == "" || menuItem[i].sizeChosen == "Standard") {
            price_discount = menuItem[i].price_standard;
            if (price_discount < lowestPrice) {
              lowestPrice = price_discount;
            }
          }
        }
        if (i == menuItem.length - 1 && voucherApplied) {
          price_discount = lowestPrice;
          grandTotalAfterDiscount -= price_discount;
          return Tuple2(voucherApplied, "Applied Successfully");
        }
      }
      return Tuple2(voucherApplied, "Add specific item to apply this voucher.");
    } else if (voucherApplied_type_name == "BuyOneFreeOne") {
      for (int i = 0; i < menuItem.length; i++) {
        if (voucherApplied_applicable_menu_item_name == menuItem[i].name) {
          numOrderOfCurrentFoodItem += menuItem[i].numOrder;
        }
        if (numOrderOfCurrentFoodItem >= 2) {
          voucherApplied = true;
        }
      }
      if (voucherApplied) {
        for (int i = 0; i < menuItem.length; i++) {
          if (voucherApplied_applicable_menu_item_name == menuItem[i].name) {
            if (menuItem[i].sizeChosen == "Large") {
              price_discount = menuItem[i].price_large;
              if (price_discount < lowestPrice) {
                lowestPrice = price_discount;
              }
            }
            if (menuItem[i].sizeChosen == "" || menuItem[i].sizeChosen == "Standard") {
              price_discount = menuItem[i].price_standard;
              if (price_discount < lowestPrice) {
                lowestPrice = price_discount;
                i = menuItem.length - 1;
              }
            }
          }
          if (i == menuItem.length - 1) {
            price_discount = lowestPrice;
            grandTotalAfterDiscount -= price_discount;
            return Tuple2(voucherApplied, "Applied Successfully");
          }
        }
      }
      numOrderOfFoodItemRequired = 2 - numOrderOfCurrentFoodItem;
      return Tuple2(voucherApplied, "Add ${numOrderOfFoodItemRequired.toStringAsFixed(0)} more to apply this voucher.");
    }
    return Tuple2(voucherApplied, "An error is occurred when verifying the voucher applied before");
  }

  void addToCart (int numMenuItemAdded, MenuItem menuItemAdded) {
    MenuItem itemAdded = MenuItem(
      id: menuItemAdded.id,
      itemClass: menuItemAdded.itemClass,
      image: menuItemAdded.image,
      name: menuItemAdded.name,
      price_standard: menuItemAdded.price_standard,
      price_large: menuItemAdded.price_large,
      description: menuItemAdded.description,
      isOutOfStock: menuItemAdded.isOutOfStock,
      hasVariant: menuItemAdded.hasVariant,
      variants: menuItemAdded.variants,
      hasSize: menuItemAdded.hasSize,
      sizes: menuItemAdded.sizes,
      category_name: menuItemAdded.category_name,
      category_image: menuItemAdded.category_image,
      user_created_name: menuItemAdded.user_created_name,
      user_updated_name: menuItemAdded.user_updated_name,
      numOrder: numMenuItemAdded,
      // priceNumOrder: (menuItemAdded.price * menuItemAdded.numOrder),
      sizeChosen: menuItemAdded.sizeChosen,
      variantChosen: menuItemAdded.variantChosen,
      remarks: menuItemAdded.remarks,
    );
    if (menuItem.isNotEmpty) {
      for (int i = 0; i < menuItem.length; i++) {
        print(menuItem);
        if (menuItem[i] == menuItemAdded) {
          menuItem[i].numOrder += numMenuItemAdded;
          numMenuItemOrder += numMenuItemAdded;
          addGrandTotalBeforeDiscount(menuItemAdded, numMenuItemAdded);
          break;
        }
        else if (i == menuItem.length - 1) {
          menuItemAdded.numOrder += numMenuItemAdded;
          numMenuItemOrder += numMenuItemAdded;
          menuItem.add(itemAdded);
          addGrandTotalBeforeDiscount(menuItemAdded, numMenuItemAdded);
          break;
        }
      }
    }
    else {
      menuItemAdded.numOrder += numMenuItemAdded;
      numMenuItemOrder += numMenuItemAdded;
      menuItem.add(itemAdded);
      addGrandTotalBeforeDiscount(menuItemAdded, numMenuItemAdded);
    }
    menuItem.sort((a, b) => a.name.compareTo(b.name));
  }

  void addGrandTotalBeforeDiscount (MenuItem menuItemAdded, int numMenuItemAdded) {
    if (menuItemAdded.sizeChosen == "" || menuItemAdded.sizeChosen == "Standard") {
      grandTotalBeforeDiscount += (menuItemAdded.price_standard * numMenuItemAdded);
      grandTotalAfterDiscount += (menuItemAdded.price_standard * numMenuItemAdded);
    } else if (menuItemAdded.sizeChosen == "Large") {
      grandTotalBeforeDiscount += (menuItemAdded.price_large * numMenuItemAdded);
      grandTotalAfterDiscount += (menuItemAdded.price_large * numMenuItemAdded);
    }
  }

  void deductGrandTotalBeforeDiscount (MenuItem menuItemReduceOrRemoved, int numMenuItemReduceOrRemoved) {
    if (menuItemReduceOrRemoved.sizeChosen == "" || menuItemReduceOrRemoved.sizeChosen == "Standard") {
      grandTotalBeforeDiscount -= (menuItemReduceOrRemoved.price_standard * numMenuItemReduceOrRemoved);
      grandTotalAfterDiscount -= (menuItemReduceOrRemoved.price_standard * numMenuItemReduceOrRemoved);
    } else if (menuItemReduceOrRemoved.sizeChosen == "Large") {
      grandTotalBeforeDiscount -= (menuItemReduceOrRemoved.price_large * numMenuItemReduceOrRemoved);
      grandTotalAfterDiscount -= (menuItemReduceOrRemoved.price_large * numMenuItemReduceOrRemoved);
    }
  }


  void removeFromCart (MenuItem menuItemRemoved) {
    deductGrandTotalBeforeDiscount(menuItemRemoved, menuItemRemoved.numOrder);
    numMenuItemOrder -= menuItemRemoved.numOrder;
    menuItem.removeWhere((item) => item == menuItemRemoved);
  }

  void reduceNumOrderOfMenuItem (MenuItem menuItemReduce) {
    for (int i = 0; i < menuItem.length; i++) {
      if (menuItem[i] == menuItemReduce) {
        menuItem[i].numOrder--;
        numMenuItemOrder--;
        deductGrandTotalBeforeDiscount(menuItemReduce, 1);
        if (menuItem[i].numOrder == 0) {
          numMenuItemOrder -= menuItemReduce.numOrder;
          menuItem.removeWhere((item) => item == menuItemReduce);
        }
        break;
      }
    }
  }
}
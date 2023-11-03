import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import 'MenuItem.dart';
import 'User.dart';

@JsonSerializable()
class Cart {
  int id;
  List<MenuItem> menuItem;
  int numMenuItemOrder;
  double grandTotalBeforeDiscount;
  double grandTotalAfterDiscount;

  Cart({
    required this.id,
    required this.menuItem,
    required this.numMenuItemOrder,
    required this.grandTotalBeforeDiscount,
    required this.grandTotalAfterDiscount,
  });

  List<MenuItem> getMenuItemList () {
    return menuItem;
  }

  int getNumMenuItemOrder () {
    return numMenuItemOrder;
  }

  double getGrandTotal () {
    return grandTotalBeforeDiscount;
  }

  bool containMenuItem () {
    if (menuItem.isNotEmpty) {
      return true;
    }
    else {
      return false;
    }
  }

  void addToCart (int numMenuItemAdded, MenuItem menuItemAdded) {
    MenuItem itemAdded = MenuItem(
      id: menuItemAdded.id,
      itemClass: menuItemAdded.itemClass,
      image: menuItemAdded.image,
      name: menuItemAdded.name,
      price: menuItemAdded.price,
      description: menuItemAdded.description,
      isOutOfStock: menuItemAdded.isOutOfStock,
      hasVariant: menuItemAdded.hasVariant,
      variants: menuItemAdded.variants,
      hasSize: menuItemAdded.hasSize,
      sizes: menuItemAdded.sizes,
      category_name: menuItemAdded.category_name,
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
          // menuItem[i].priceNumOrder += (menuItemAdded.price * numMenuItemAdded);
          grandTotalBeforeDiscount += (menuItemAdded.price * numMenuItemAdded);
          break;
        }
        else if (i == menuItem.length - 1) {
          menuItemAdded.numOrder += numMenuItemAdded;
          numMenuItemOrder += numMenuItemAdded;
          menuItem.add(itemAdded);
          grandTotalBeforeDiscount += (menuItemAdded.price * numMenuItemAdded);
          break;
        }
      }
    }

    else {
      menuItemAdded.numOrder += numMenuItemAdded;
      numMenuItemOrder += numMenuItemAdded;
      menuItem.add(itemAdded);
      grandTotalBeforeDiscount += (menuItemAdded.price * numMenuItemAdded);
    }
    menuItem.sort((a, b) => a.name.compareTo(b.name));
  }

  void removeFromCart (MenuItem menuItemRemoved) {
    grandTotalBeforeDiscount-=(menuItemRemoved.price * menuItemRemoved.numOrder);
    numMenuItemOrder -= menuItemRemoved.numOrder;
    menuItem.removeWhere((item) => item == menuItemRemoved);
  }

  void reduceNumOrderOfMenuItem (MenuItem menuItemReduce) {
    for (int i = 0; i < menuItem.length; i++) {
      if (menuItem[i] == menuItemReduce) {
        menuItem[i].numOrder--;
        numMenuItemOrder--;
        // menuItem[i].priceNumOrder -= menuItemReduce.price;
        grandTotalBeforeDiscount-=menuItemReduce.price;
        if (menuItem[i].numOrder == 0) {
          numMenuItemOrder -= menuItemReduce.numOrder;
          menuItem.removeWhere((item) => item == menuItemReduce);
        }
        break;
      }
    }
  }
}
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import 'User.dart';

@JsonSerializable()
class VoucherAssignUserMoreInfo {
  final int id;
  final DateTime expiry_date;
  final String voucher_code;
  final bool is_available;
  final String user_name;
  final String voucher_type_name;
  final double cost_off;
  final String free_menu_item_name;
  final String applicable_menu_item_name;
  final double min_spending;

  VoucherAssignUserMoreInfo({
    required this.id,
    required this.expiry_date,
    required this.voucher_code,
    required this.is_available,
    required this.user_name,
    required this.voucher_type_name,
    required this.cost_off,
    required this.free_menu_item_name,
    required this.applicable_menu_item_name,
    required this.min_spending,
  });

  factory VoucherAssignUserMoreInfo.fromJson(Map<String, dynamic> json) {
    // if (kDebugMode) {
    //   print('MenuItem.fromJson: $json');
    // }
    return VoucherAssignUserMoreInfo(
      id: json['id'] ?? 0,
      expiry_date: DateTime.parse(json['expiry_date']),
      voucher_code: json['voucher_code'],
      is_available: json['is_available'],
      user_name: json['user_name'] ?? '',
      voucher_type_name: json['voucher_type_name'],
      cost_off: json['cost_off'] ?? 0,
      free_menu_item_name: json['free_menu_item_name'] ?? '',
      applicable_menu_item_name: json['applicable_menu_item_name'] ?? '',
      min_spending: json['min_spending'] ?? 0,

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expiry_date': expiry_date,
      'voucher_code': voucher_code,
      'is_available': is_available,
      'user_name': user_name,
      'voucher_type_name': voucher_type_name,
      'cost_off': cost_off,
      'free_menu_item_name': free_menu_item_name,
      'applicable_menu_item_name': applicable_menu_item_name,
      'min_spending': min_spending,
    };
  }

  static List<VoucherAssignUserMoreInfo> getAvailableVoucherRedeemedList(Map<String, dynamic> json) {
    List<VoucherAssignUserMoreInfo> availableVoucherRedeemedList = [];
    for (Map<String,dynamic> availableVoucherRedeemed in json['data']) {
      VoucherAssignUserMoreInfo oneAvailableVoucherRedeemed = VoucherAssignUserMoreInfo.fromJson(availableVoucherRedeemed);
      availableVoucherRedeemedList .add(oneAvailableVoucherRedeemed);
    }
    return availableVoucherRedeemedList ;
  }

}
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

@JsonSerializable()
class User {
  final int uid;
  final String name;
  final String email;
  final String phone;
  final String gender;
  final DateTime dob;

  const User({required this.uid, required this.name, required this.email, required this.phone, required this.gender, required this.dob});

  factory User.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      print('User.fromJson: $json');
    }
    return User(
      uid: json['uid'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      gender: json['gender'],
      dob: DateTime.parse(json['dob'])
    );
  }

  factory User.fromJWT(String jwtToken) {
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(jwtToken);
    return User(
      uid: jwtDecodedToken['uid'],
      name: jwtDecodedToken['name'],
      email: jwtDecodedToken['email'],
      phone: jwtDecodedToken['phone'],
      gender: jwtDecodedToken['gender'],
      dob: DateTime.parse(jwtDecodedToken['dob']),
    );
  }
}
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

@JsonSerializable()
class User {
  final int uid;
  final String name;
  final bool is_active;
  final String email;
  final String phone;
  final String gender;
  final DateTime dob;
  double points;

  User({required this.uid, required this.name, required this.is_active, required this.email, required this.phone, required this.gender, required this.dob, required this.points});

  factory User.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      print('User.fromJson: $json');
    }
    return User(
      uid: json['uid'],
      name: json['name'],
      is_active: json['is_active'],
      email: json['email'],
      phone: json['phone'],
      gender: json['gender'],
      dob: DateTime.parse(json['dob']),
      points: json['points'],
    );
  }

  factory User.fromJWT(String jwtToken) {
    final jwt = JWT.verify(jwtToken, SecretKey('authsecret')); // Verify token from legit source
    Map<String, dynamic> jwtDecodedToken = jwt.payload;
    return User(
      uid: jwtDecodedToken['uid'],
      name: jwtDecodedToken['name'],
      is_active: jwtDecodedToken['is_active'],
      email: jwtDecodedToken['email'],
      phone: jwtDecodedToken['phone'],
      gender: jwtDecodedToken['gender'],
      dob: DateTime.parse(jwtDecodedToken['dob']),
      points: jwtDecodedToken['points'],
    );
  }
}
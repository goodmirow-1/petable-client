import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalFunction.dart';

class SnackIntake {
  int id = nullInt;
  int petID = nullInt;
  int snackID = nullInt;
  double weight = nullDouble;
  String time = '';
  String createdAt = '';
  String updatedAt = '';

  SnackIntake({
    required this.id,
    required this.petID,
    required this.snackID,
    required this.weight,
    required this.time,
    required this.updatedAt,
    required this.createdAt,
  });

  factory SnackIntake.fromJson(Map<String, dynamic> json){

    return SnackIntake(
      id: json["id"] ?? nullInt,
      petID: json["PetID"] ?? nullInt,
      snackID: json["SnackID"] ?? nullInt,
      weight: double.parse(json['Amount'].toString()),
      time: json['Time'] ?? '',
      createdAt: replaceDateToDateTime(json['createdAt'] ?? json['Time']),
      updatedAt: replaceDateToDateTime(json['updatedAt'] ?? json['Time']),
    );
  }

  Map<String, Object?> toMap(){
    var map = <String, Object?>{
      'snackIntakeID': id,
      'petID': petID,
      'snackID': snackID,
      'weight': weight,
      'time': time,
      'updatedAt': updatedAt,
      'createdAt': createdAt,
    };
    return map;
  }

  SnackIntake.fromMap(Map<dynamic, dynamic> map){
    id = map['snackIntakeID'] as int;
    petID = map['petID'] as int;
    snackID = map['snackID'] as int;
    weight = map['weight'] as double;
    time = map['time'] as String;
    createdAt = map['updatedAt'] as String;
    updatedAt = map['createdAt'] as String;
  }
}

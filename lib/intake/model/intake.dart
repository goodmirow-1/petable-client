import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalFunction.dart';

const int INTAKE_STATE_FEED = 1;
const int INTAKE_STATE_START = 2;
const int INTAKE_STATE_END = 3;
const int INTAKE_STATE_NO_BOWL = 4;

const int INTAKE_TYPE_FOOD = 0;
const int INTAKE_TYPE_WATER = 1;

class Intake {
  int id = nullInt;
  int petID = nullInt;
  int foodID = nullInt;
  double weight = nullDouble;
  int state = nullInt;
  int type = nullInt;
  String createdAt = '';
  String updatedAt = '';

  Intake({
    required this.id,
    required this.petID,
    required this.foodID,
    required this.weight,
    required this.state,
    required this.type,
    required this.updatedAt,
    required this.createdAt,
  });

  factory Intake.fromJson(Map<String, dynamic> json){
    double _weight = (json["Amount"]).toDouble() - (json["BowlWeight"]).toDouble();
    if(_weight < 0) _weight = 0;

    return Intake(
      id: json["id"] ?? nullInt,
      petID: json["PetID"] ?? nullInt,
      foodID: json["FoodID"] ?? nullInt,
      weight: _weight,
      state: json["State"] ?? nullInt,
      type: json["BowlType"] ?? nullInt,
      createdAt: replaceDateToDateTime(json['createdAt'] ?? ''),
      updatedAt: replaceDateToDateTime(json['updatedAt'] ?? ''),
    );
  }

  Map<String, Object?> toMap(){
    var map = <String, Object?>{
      'intakeID': id,
      'petID': petID,
      'foodID': foodID,
      'weight': weight,
      'state': state,
      'type': type,
      'updatedAt': updatedAt,
      'createdAt': createdAt,
    };
    return map;
  }

  Intake.fromMap(Map<dynamic, dynamic> map){
    id = map['intakeID'] as int;
    petID = map['petID'] as int;
    foodID = map['foodID'] as int;
    weight = map['weight'] as double;
    state = map['state'] as int;
    type = map['type'] as int;
    createdAt = map['updatedAt'] as String;
    updatedAt = map['createdAt'] as String;
  }
}

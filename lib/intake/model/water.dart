import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalFunction.dart';

const int WATER_TYPE_DRINK = 1;
const int WATER_TYPE_EAT = 2;

class Water {
  int id = nullInt;
  int petID = nullInt;
  double amount = nullDouble;
  int type = nullInt;
  DateTime time = DateTime.now();
  int intakeID = 0;
  int snackIntakeID = 0;

  Water({
    this.id = nullInt,
    required this.petID,
    required this.amount,
    required this.type,
    required this.time,
    this.intakeID = 0,
    this.snackIntakeID = 0,
  });

  Map<String, Object?> toMap(){
    var map = <String, Object?>{
      'petID': petID,
      'amount': amount,
      'type': type,
      'time': time.toString(),
      'intakeID': intakeID,
      'snackIntakeID': snackIntakeID,
    };
    return map;
  }

  Water.fromMap(Map<dynamic, dynamic> map){
    id = map['id'] as int;
    petID = map['petID'] as int;
    amount = map['amount'] as double;
    type = map['type'] as int;
    time = dateTimeFromString(map['time'] as String);
    intakeID = map['intakeID'] as int;
    snackIntakeID = map['snackIntakeID'] as int;
  }
}

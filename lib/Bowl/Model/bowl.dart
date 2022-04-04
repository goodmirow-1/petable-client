
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Config/GlobalFunction.dart';

const BOWL_TYPE_FOOD = 0;
const BOWL_TYPE_WATER = 1;

class Bowl {
  int id = nullInt;
  int petID = nullInt;
  String uuID = '';
  double bowlWeight = nullDouble;
  int type = nullInt;
  int battery = nullInt;
  String createdAt = '';
  String updatedAt = '';

  Bowl({
    required this.id,
    required this.petID,
    required this.uuID,
    required this.bowlWeight,
    required this.type,
    required this.battery,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Bowl.fromJson(Map<String, dynamic> json) => Bowl(
      id: json["id"] ?? nullInt,
      petID: json["PetID"] ?? nullInt,
      uuID: json["UUID"] ?? '',
      type: json["Type"] ?? nullInt,
      bowlWeight: json["BowlWeight"] == null ? nullDouble : (json["BowlWeight"]).toDouble(),
      battery: json['Battery'] ?? nullInt,
      createdAt: replaceDate(json['createdAt'] ?? ''),
      updatedAt: replaceDate(json['updatedAt'] ?? ''),
  );
}


import 'package:get/get.dart';
import 'package:myvef_app/Bowl/Model/bowl.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Data/global_data.dart';

class FoodBowlController extends GetxController{
  static get to => Get.find<FoodBowlController>();

  int id = nullInt;
  int petID = nullInt;
  String uuID = '';
  double bowlWeight = nullDouble;
  int type = nullInt;
  int battery = nullInt;
  String createdAt = '';
  String updatedAt = '';

  void reset(){
    id = nullInt;
    petID = nullInt;
    uuID = '';
    bowlWeight = nullDouble;
    type = nullInt;
    battery = nullInt;
    createdAt = '';
    updatedAt = '';
  }

  void getBowl(Bowl bowl){
    id = bowl.id;
    petID = bowl.petID;
    uuID = bowl.uuID;
    bowlWeight = bowl.bowlWeight;
    type = bowl.type;
    battery = bowl.battery;
    createdAt = bowl.createdAt;
    updatedAt = bowl.updatedAt;
  }
}

class WaterBowlController extends GetxController{
  static get to => Get.find<WaterBowlController>();

  int id = nullInt;
  int petID = nullInt;
  String uuID = '';
  double bowlWeight = nullDouble;
  int type = nullInt;
  int battery = nullInt;
  String createdAt = '';
  String updatedAt = '';

  void reset(){
    id = nullInt;
    petID = nullInt;
    uuID = '';
    bowlWeight = nullDouble;
    type = nullInt;
    battery = nullInt;
    createdAt = '';
    updatedAt = '';
  }

  void getBowl(Bowl bowl){
    id = bowl.id;
    petID = bowl.petID;
    uuID = bowl.uuID;
    bowlWeight = bowl.bowlWeight;
    type = bowl.type;
    battery = bowl.battery;
    createdAt = bowl.createdAt;
    updatedAt = bowl.updatedAt;
  }
}

Future<void> getBowlData() async {
  if(GlobalData.mainPet.value.foodBowl != null){
    FoodBowlController foodBowlController = Get.put(FoodBowlController());
    foodBowlController.getBowl(GlobalData.mainPet.value.foodBowl!);
  } else {
    FoodBowlController foodBowlController = Get.put(FoodBowlController());
    foodBowlController.reset();
  }

  if(GlobalData.mainPet.value.waterBowl != null){
    WaterBowlController waterBowlController = Get.put(WaterBowlController());
    waterBowlController.getBowl(GlobalData.mainPet.value.waterBowl!);
  } else {
    WaterBowlController waterBowlController = Get.put(WaterBowlController());
    waterBowlController.reset();
  }
}
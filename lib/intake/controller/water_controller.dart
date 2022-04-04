
import 'package:get/get.dart';
import 'package:myvef_app/intake/model/water.dart';
import 'package:myvef_app/intake/controller/water_database.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'intake_contoller.dart';
import 'snack_intake_controller.dart';

class WaterController extends GetxController{
  static get to => Get.find<WaterController>();

  RxList<Water> waterList = <Water>[].obs;

  void reset(){
    waterList.clear();
  }

  //음수량 리스트 세팅
  setWater() async {
    //리스트 다른 펫이면 클리어
    if(waterList.isNotEmpty){
      if(GlobalData.mainPet.value.id != waterList[0].petID) waterList.clear();
    }

    List<Water> _waterList = await WaterDBHelper().getWaterList(petID: GlobalData.mainPet.value.id, id: waterList.isNotEmpty ? waterList[0].id : 0);

    waterList.insertAll(0, _waterList);
  }

  insertWater(Water water) async{
    WaterDBHelper().insert(water);
    waterList.insert(0, water);
  }

  insertWaterList(List<Water> _waterList)async{
    await WaterDBHelper().insertMulti(_waterList);
    waterList.insertAll(0, _waterList);
  }

  Future<int> getLastIntakeID() async {
    int _intakeID = await WaterDBHelper().getLastIntakeID();
    return _intakeID;
  }

  Future<int> getLastSnackIntakeID() async {
    int _snackIntakeID = await WaterDBHelper().getLastSnackIntakeID();
    return _snackIntakeID;
  }
}
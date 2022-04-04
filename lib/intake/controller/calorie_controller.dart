import 'package:get/get.dart';
import 'package:myvef_app/intake/controller/intake_contoller.dart';
import 'package:myvef_app/intake/controller/snack_intake_controller.dart';
import 'package:myvef_app/intake/model/calorie.dart';
import 'package:myvef_app/intake/controller/calorie_database.dart';
import 'package:myvef_app/Data/global_data.dart';

class CalorieController extends GetxController {
  static get to => Get.find<CalorieController>();

  RxList<Calorie> calorieList = <Calorie>[].obs;

  void reset(){
    calorieList.clear();
  }

  //칼로리 리스트 세팅 및 업데이트
  setCalorie() async {
    //리스트 다른 펫이면 클리어
    if(calorieList.isNotEmpty){
      if(GlobalData.mainPet.value.id != calorieList[0].petID) calorieList.clear();
    }
    List<Calorie> _calorieList = await CalorieDBHelper().getCalorieList(petID: GlobalData.mainPet.value.id, id: calorieList.isNotEmpty ? calorieList[0].id : 0);

    calorieList.insertAll(0, _calorieList);
  }

  insertCalorie(Calorie calorie) async {
    await CalorieDBHelper().insert(calorie);
    calorieList.insert(0, calorie);
  }

  insertCalorieList(List<Calorie> _calorieList)async{
    await CalorieDBHelper().insertMulti(_calorieList);
    calorieList.insertAll(0, _calorieList);
  }

  Future<int> getLastIntakeID() async {
    int _intakeID = await CalorieDBHelper().getLastIntakeID();
    return _intakeID;
  }

  Future<int> getLastSnackIntakeID() async {
    int _snackIntakeID = await CalorieDBHelper().getLastSnackIntakeID();
    return _snackIntakeID;
  }
}

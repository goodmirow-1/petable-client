import 'package:get/get.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:myvef_app/Data/pet.dart';

class DetailProfileController extends GetxController {
  RxInt currentImgIndex = 0.obs; // 이미지 인덱스

  Pet selectedPet = Pet(); // 선택된 펫
  List<Pet> selectedPetList = []; // 선택된 펫 리스트

  @override
  void onClose() {
    super.onClose();

    GlobalData.profileCommunityList.clear(); // 프로필 커뮤니티 리스트 초기화
  }

  // 처음 펫 세팅
  void initPet(Pet pet) {
    selectedPet = pet;
  }

  // 스테이트 업데이트
  void stateUpdate() {
    update();
  }

  // 펫 토글
  void togglePet(Pet pet, List<Pet> petList) {
    Pet mainPet = petList[0];
    List<int> checkedCommunity = []; // 이미 체크한 커뮤니티 아이디 리스트

    if (selectedPetList.contains(pet)) {
      selectedPetList.remove(pet); // 이미 포함된 펫이면 삭제
    } else {
      selectedPetList.add(pet); // 선택된 펫 추가
    }

    if (selectedPetList.isEmpty)
      selectedPet = mainPet; // 펫 리스트가 비어있으면 메인펫 넣어주기
    else
      selectedPet = selectedPetList[selectedPetList.length - 1]; // 선택된 펫 리스트 중 마지막을 선택된 펫으로

    // 선택된 펫이 없거나 다 눌려있으면 모두 보여주기
    if (selectedPetList.isEmpty || selectedPetList.length == petList.length) {
      GlobalData.profileCommunityList.forEach((element) {
        element.isShow = 1;
      });
    } else {
      // 선택된 펫의 품종이 포함된 커뮤니티만 보여주기
      selectedPetList.forEach((element) {
        for (int i = 0; i < GlobalData.profileCommunityList.length; i++) {
          // 아직 체크하지 않은 커뮤니티만
          if (!checkedCommunity.contains(GlobalData.profileCommunityList[i].id)) {
            // 선택된 펫이 커뮤니티 품종에 포함된다면
            if (GlobalData.profileCommunityList[i].kind.contains(element.kind)) {
              GlobalData.profileCommunityList[i].isShow = 1;
              checkedCommunity.add(GlobalData.profileCommunityList[i].id); // 체크한 커뮤니티 아이디 리스트에 add
            } else {
              GlobalData.profileCommunityList[i].isShow = 0;
            }
          }
        }
      });
    }

    update();
  }
}

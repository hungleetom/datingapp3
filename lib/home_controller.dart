import 'package:get/get.dart';

class HomeController extends GetxController {
  var screenIndex = 0.obs; // Observable screen index

  void changeTab(int index) {
    screenIndex.value = index;
  }
}

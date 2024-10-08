import 'package:get/get.dart';

class TimerController extends GetxController {
  var currentCount = 10.obs;
  var targetCount = 10.obs;

  void increaseCount() {
    targetCount++;
    animateCount();
  }

  void decreaseCount() {
    if (targetCount > 0) {
      targetCount--;
      animateCount();
    }
  }

  void animateCount() async {
    for (int i = currentCount.value; i != targetCount.value;) {
      await Future.delayed(Duration(milliseconds: 100));
      if (i < targetCount.value) {
        i++;
      } else if (i > targetCount.value) {
        i--;
      }
      currentCount.value = i;
    }
  }
}
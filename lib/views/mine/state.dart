import 'package:get/get.dart';

class MineState {
  RxString test = "111".obs;

  /// 1表示可签到  0表示已签到
  RxInt signedIn = 1.obs;
  RxString username = ''.obs;
  RxString role = ''.obs;
  RxString avatar = ''.obs;
}

import 'package:xkit/x_kit.dart';
import 'package:xmca/cubit/chat_room_cubit.dart';
import 'package:xmca/helper/global.dart';
import 'package:xmca/helper/user_manager.dart';
import 'package:xmca/pages/chat/chat_room.dart';
export 'package:xkit/x_kit.dart';

class Xmca {
  static void config({
    required Map<String, dynamic> params,
    Function()? backToNative,
    Function(dynamic args)? humanCustomerService,
  }) {
    UserManager.instance.threeLoginData = params;
    csBackToNative = backToNative;
    csHumanCustomerService = humanCustomerService;
  }

  static get chatRoomPage {
    return BlocProvider(create: (context) => ChatRoomCubit(), child: ChatRoomPage());
  }
}

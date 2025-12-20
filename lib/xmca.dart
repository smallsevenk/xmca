import 'package:xkit/x_kit.dart';
import 'package:xmca/cubit/chat_room_cubit.dart';
import 'package:xmca/helper/native_util.dart';
import 'package:xmca/pages/chat/chat_room.dart';

class Xmca {
  static void config({Function()? backToNative, Function(dynamic args)? humanCustomerService}) {
    NativeUtil.backToNative = backToNative;
    NativeUtil.humanCustomerService = humanCustomerService;
  }
}

const String grpXmca = '/xmca';
registCaRouters() {
  XRouter.instance.registRouters([
    GoRoute(
      path: grpXmca,
      builder: (context, state) {
        return BlocProvider(create: (context) => ChatRoomCubit(), child: ChatRoomPage());
      },
    ),
  ]);
}

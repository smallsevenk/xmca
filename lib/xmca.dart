import 'package:xkit/x_kit.dart';
import 'package:xmca/cubit/chat_room_cubit.dart';
import 'package:xmca/helper/native_util.dart';
import 'package:xmca/pages/chat/chat_room.dart';

class Xmca {
  static void config({
    OnInvokeNativeCallBack? backToNative,
    OnInvokeNativeWithArgsCallBack? humanCustomerService,
    OnInvokeNativeWithArgsCallBack? xmcaReferenceDetail,
  }) {
    NativeUtil.backToNative = backToNative;
    NativeUtil.humanCustomerService = humanCustomerService;
    NativeUtil.xmcaReferenceDetail = xmcaReferenceDetail;
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

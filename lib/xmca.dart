import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xmca/cubit/chat_room_cubit.dart';
import 'package:xmca/helper/native_global.dart';
import 'package:xmca/pages/chat/chat_room.dart';
export 'package:xkit/x_kit.dart';

class Xmca {
  static void config({
    required Map<String, dynamic> params,
    Function()? backToNative,
    Function(dynamic args)? humanCustomerService,
  }) {
    NativeGlobal.appParams = params;
    NativeGlobal.backToNative = backToNative;
    NativeGlobal.humanCustomerService = humanCustomerService;
  }

  static get chatRoomPage {
    return BlocProvider(create: (context) => ChatRoomCubit(), child: ChatRoomPage());
  }
}

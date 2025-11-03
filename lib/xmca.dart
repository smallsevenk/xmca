import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xmca/cubit/ca_chat_room_cubit.dart';
import 'package:xmca/helper/ca_global.dart';
import 'package:xmca/helper/ca_user_manager.dart';
import 'package:xmca/pages/chat/ca_chat_room.dart';
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

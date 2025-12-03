import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xmca/cubit/chat_room_cubit.dart';
import 'package:xmca/helper/global.dart';
import 'package:xmca/helper/three_params.dart';
import 'package:xmca/pages/chat/chat_room.dart';
export 'package:xkit/x_kit.dart';

class Xmca {
  static void config({
    required Map<String, dynamic> params,
    Function()? backToNative,
    Function(dynamic args)? humanCustomerService,
  }) {
    threeAppParams = params;
    csBackToNative = backToNative;
    csHumanCustomerService = humanCustomerService;
  }

  static get chatRoomPage {
    return BlocProvider(create: (context) => ChatRoomCubit(), child: ChatRoomPage());
  }
}

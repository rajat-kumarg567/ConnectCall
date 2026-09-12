import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import '../core/theme/app_theme.dart';
import '../models/call_model.dart';
import '../models/user_model.dart';
import '../services/calling_service.dart';
import 'package:zego_uikit/zego_uikit.dart';

class UserTile extends StatelessWidget {
  final UserModel user;

  const UserTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final calling = context.read<CallingService>();

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.primary.withOpacity(0.15),
            backgroundImage: user.photoUrl.isNotEmpty ? NetworkImage(user.photoUrl) : null,
            child: user.photoUrl.isEmpty
                ? Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: user.isOnline ? AppTheme.success : Colors.grey,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
      title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(user.isOnline ? 'Online' : 'Offline'),
      // trailing: Row(
      //   mainAxisSize: MainAxisSize.min,
      //   children: [
      //     ZegoSendCallInvitationButton(
      //       isVideoCall: false,
      //       invitees: [ZegoUIKitUser(id: user.uid, name: user.name)],
      //       icon: ButtonIcon(
      //         icon: const Icon(Icons.call, color: AppTheme.primary),
      //         backgroundColor: Colors.transparent,
      //       ),
      //       onPressed: (code, message, invitees) {
      //         calling.logOutgoingCallStarted(
      //           calleeId: user.uid,
      //           calleeName: user.name,
      //           type: CallType.audio,
      //         );
      //       },
      //     ),
      //     ZegoSendCallInvitationButton(
      //       isVideoCall: true,
      //       invitees: [ZegoUIKitUser(id: user.uid, name: user.name)],
      //       icon: ButtonIcon(
      //         icon: const Icon(Icons.videocam, color: AppTheme.secondary),
      //         backgroundColor: Colors.transparent,
      //       ),
      //       onPressed: (code, message, invitees) {
      //         calling.logOutgoingCallStarted(
      //           calleeId: user.uid,
      //           calleeName: user.name,
      //           type: CallType.video,
      //         );
      //       },
      //     ),
      //   ],
      // ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ZegoSendCallInvitationButton(
            buttonSize: const Size(48, 48),
            iconSize: const Size(28, 28),
            isVideoCall: false,
            invitees: [
              ZegoUIKitUser(
                id: user.uid,
                name: user.name,
              ),
            ],
            icon: ButtonIcon(
              icon: const Icon(
                Icons.call,
                color: AppTheme.primary,
                size: 24,
              ),
              backgroundColor: Colors.transparent,
            ),
            onPressed: (code, message, invitees) {
              calling.logOutgoingCallStarted(
                calleeId: user.uid,
                calleeName: user.name,
                type: CallType.audio,
              );
            },
          ),

          SizedBox(
            width: 30,
          ),

          ZegoSendCallInvitationButton(
            buttonSize: const Size(48, 48),
            iconSize: const Size(28, 28),
            isVideoCall: true,
            invitees: [
              ZegoUIKitUser(
                id: user.uid,
                name: user.name,
              ),
            ],
            icon: ButtonIcon(
              icon: const Icon(
                Icons.videocam,
                color: AppTheme.secondary,
                size: 24,
              ),
              backgroundColor: Colors.transparent,
            ),
            onPressed: (code, message, invitees) {
              calling.logOutgoingCallStarted(
                calleeId: user.uid,
                calleeName: user.name,
                type: CallType.video,
              );
            },
          ),
        ],
      ),
    );
  }
}





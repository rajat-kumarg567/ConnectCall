

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import '../core/constants/app_constants.dart';
import '../models/call_model.dart';

class CallingService {
  bool _initialized = false;

  final FirebaseFirestore _db = FirebaseFirestore.instance;


  String? _activeCallHistoryId;

  DateTime? _callConnectedAt;

  bool _isOutgoingCall = false;

  CallType? _activeCallType;


  Future<void> init({
    required String uid,
    required String name,
    required GlobalKey<NavigatorState> navigatorKey,
  }) async {
    if (_initialized) return;

    _initialized = true;

    ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(
      navigatorKey,
    );

    await ZegoUIKitPrebuiltCallInvitationService().init(
      appID: AppConstants.zegoAppID,
      appSign: AppConstants.zegoAppSign,
      userID: uid,
      userName: name,
      plugins: [
        ZegoUIKitSignalingPlugin(),
      ],


      invitationEvents: ZegoUIKitPrebuiltCallInvitationEvents(

        // =========================
        // INCOMING CALL RECEIVED
        // =========================

        onIncomingCallReceived: (
            String callID,
            ZegoCallUser caller,
            ZegoCallType callType,
            List callees,
            String customData,
            ) async {
          final type = callType == ZegoCallType.videoCall
              ? CallType.video
              : CallType.audio;

          await _createIncomingCallHistory(
            callerId: caller.id,
            callerName: caller.name,
            type: type,
          );
        },

        // =========================
        // INCOMING CALL ACCEPTED
        // =========================

        onIncomingCallAcceptButtonPressed: () async {
          await _markCallConnected();
        },

        // =========================
        // INCOMING CALL DECLINED
        // =========================

        onIncomingCallDeclineButtonPressed: () async {
          await _updateActiveCallStatus(
            CallStatus.rejected,
          );

          _clearActiveCall();
        },

        // =========================
        // CALLER RECEIVES ACCEPT
        // =========================

        onOutgoingCallAccepted: (
            String callID,
            ZegoCallUser callee,
            ) async {
          await _markCallConnected();
        },

        // =========================
        // CALLER RECEIVES DECLINE
        // =========================

        onOutgoingCallDeclined: (
            String callID,
            ZegoCallUser callee,
            String customData,
            ) async {
          await _updateActiveCallStatus(
            CallStatus.rejected,
          );

          _clearActiveCall();
        },

        // =========================
        // CALLEE IS BUSY
        // =========================

        onOutgoingCallRejectedCauseBusy: (
            String callID,
            ZegoCallUser callee,
            String customData,
            ) async {
          await _updateActiveCallStatus(
            CallStatus.busy,
          );

          _clearActiveCall();
        },

        // =========================
        // OUTGOING TIMEOUT
        // =========================

        onOutgoingCallTimeout: (
            String callID,
            List<ZegoCallUser> callees,
            bool isVideoCall,
            ) async {
          await _updateActiveCallStatus(
            CallStatus.missed,
          );

          _clearActiveCall();
        },

        // =========================
        // INCOMING TIMEOUT
        // =========================

        onIncomingCallTimeout: (
            String callID,
            ZegoCallUser caller,
            ) async {
          await _updateActiveCallStatus(
            CallStatus.missed,
          );

          _clearActiveCall();
        },

        // =========================
        // CALLER CANCELS
        // =========================

        onOutgoingCallCancelButtonPressed: () async {
          await _updateActiveCallStatus(
            CallStatus.ended,
          );

          _clearActiveCall();
        },

        // =========================
        // CALLER CANCELS BEFORE
        // CALLEE ACCEPTS
        // =========================

        onIncomingCallCanceled: (
            String callID,
            ZegoCallUser caller,
            String customData,
            ) async {
          await _updateActiveCallStatus(
            CallStatus.missed,
          );

          _clearActiveCall();
        },
      ),

      // ----------------------------------------------------------
      // ACTUAL CALL EVENTS
      // ----------------------------------------------------------

      events: ZegoUIKitPrebuiltCallEvents(
        onCallEnd: (event, defaultAction) async {
          await _finishCall();

          defaultAction.call();
        },
      ),

      // ----------------------------------------------------------
      // CALL UI CONFIG
      // ----------------------------------------------------------

      requireConfig: (ZegoCallInvitationData data) {
        final isVideo = data.type == ZegoCallType.videoCall;

        return isVideo
            ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
            : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();
      },
    );
  }

  // ------------------------------------------------------------
  // OUTGOING CALL START
  // ------------------------------------------------------------

  Future<void> logOutgoingCallStarted({
    required String calleeId,
    required String calleeName,
    required CallType type,
  }) async {
    final me = FirebaseAuth.instance.currentUser;

    if (me == null) return;

    final doc = _db
        .collection(AppConstants.callsCollection)
        .doc();

    final call = CallModel(
      id: doc.id,
      callerId: me.uid,
      callerName: me.displayName ?? 'Me',
      callerPhoto: me.photoURL ?? '',
      calleeId: calleeId,
      calleeName: calleeName,
      calleePhoto: '',
      type: type,
      status: CallStatus.calling,
      createdAt: Timestamp.now(),
      durationSeconds: 0,
    );

    await doc.set(
      call.toMap(),
    );

    // Remember this exact Firestore document.
    _activeCallHistoryId = doc.id;

    _activeCallType = type;

    _isOutgoingCall = true;

    _callConnectedAt = null;
  }

  // ------------------------------------------------------------
  // INCOMING CALL HISTORY
  // ------------------------------------------------------------

  Future<void> _createIncomingCallHistory({
    required String callerId,
    required String callerName,
    required CallType type,
  }) async {
    final me = FirebaseAuth.instance.currentUser;

    if (me == null) return;

    final doc = _db
        .collection(AppConstants.callsCollection)
        .doc();

    final call = CallModel(
      id: doc.id,
      callerId: callerId,
      callerName: callerName,
      callerPhoto: '',
      calleeId: me.uid,
      calleeName: me.displayName ?? 'Me',
      calleePhoto: me.photoURL ?? '',
      type: type,
      status: CallStatus.ringing,
      createdAt: Timestamp.now(),
      durationSeconds: 0,
    );

    await doc.set(
      call.toMap(),
    );

    _activeCallHistoryId = doc.id;

    _activeCallType = type;

    _isOutgoingCall = false;

    _callConnectedAt = null;
  }

  // ------------------------------------------------------------
  // CALL CONNECTED
  // ------------------------------------------------------------

  Future<void> _markCallConnected() async {
    if (_activeCallHistoryId == null) {
      return;
    }

    _callConnectedAt = DateTime.now();

    await _db
        .collection(AppConstants.callsCollection)
        .doc(_activeCallHistoryId)
        .update({
      'status': CallStatus.connected.name,
    });
  }

  // ------------------------------------------------------------
  // CALL ENDED
  // ------------------------------------------------------------

  Future<void> _finishCall() async {
    final historyId = _activeCallHistoryId;

    if (historyId == null) {
      return;
    }

    int durationSeconds = 0;

    if (_callConnectedAt != null) {
      durationSeconds = DateTime.now()
          .difference(_callConnectedAt!)
          .inSeconds;
    }

    await _db
        .collection(AppConstants.callsCollection)
        .doc(historyId)
        .update({
      'status': CallStatus.ended.name,
      'durationSeconds': durationSeconds,
    });

    _clearActiveCall();
  }

  // ------------------------------------------------------------
  // UPDATE CURRENT CALL STATUS
  // ------------------------------------------------------------

  Future<void> _updateActiveCallStatus(
      CallStatus status,
      ) async {
    final historyId = _activeCallHistoryId;

    if (historyId == null) {
      return;
    }

    await _db
        .collection(AppConstants.callsCollection)
        .doc(historyId)
        .update({
      'status': status.name,
    });
  }

  // ------------------------------------------------------------
  // CLEAR CURRENT CALL
  // ------------------------------------------------------------

  void _clearActiveCall() {
    _activeCallHistoryId = null;
    _callConnectedAt = null;
    _activeCallType = null;
    _isOutgoingCall = false;
  }

  // ------------------------------------------------------------
  // DISPOSE
  // ------------------------------------------------------------

  Future<void> dispose_() async {
    if (!_initialized) return;

    _initialized = false;

    _clearActiveCall();

    await ZegoUIKitPrebuiltCallInvitationService().uninit();
  }

  // ------------------------------------------------------------
  // HISTORY STREAM
  // ------------------------------------------------------------

  Stream<List<CallModel>> historyStream(String myUid) {
    return _db
        .collection(AppConstants.callsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
          .map(
            (d) => CallModel.fromMap(
          d.data(),
          d.id,
        ),
      )
          .where(
            (c) =>
        c.callerId == myUid ||
            c.calleeId == myUid,
      )
          .toList(),
    );
  }
}



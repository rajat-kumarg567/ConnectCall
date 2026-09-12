import 'package:cloud_firestore/cloud_firestore.dart';

enum CallType { audio, video }

enum CallStatus {
  calling, // caller has initiated, waiting for callee
  ringing, // callee's phone is ringing
  connected, // both joined the channel
  ended, // finished normally
  rejected, // callee declined
  missed, // callee never answered
  busy, // callee already on another call
  failed, // connection error
}

class CallModel {
  final String id; // Firestore document id for this history record
  final String callerId;
  final String callerName;
  final String callerPhoto;
  final String calleeId;
  final String calleeName;
  final String calleePhoto;
  final CallType type;
  final CallStatus status;
  final Timestamp createdAt;
  final int durationSeconds;

  CallModel({
    required this.id,
    required this.callerId,
    required this.callerName,
    required this.callerPhoto,
    required this.calleeId,
    required this.calleeName,
    required this.calleePhoto,
    required this.type,
    required this.status,
    required this.createdAt,
    this.durationSeconds = 0,
  });

  factory CallModel.fromMap(Map<String, dynamic> map, String id) {
    return CallModel(
      id: id,
      callerId: map['callerId'] ?? '',
      callerName: map['callerName'] ?? '',
      callerPhoto: map['callerPhoto'] ?? '',
      calleeId: map['calleeId'] ?? '',
      calleeName: map['calleeName'] ?? '',
      calleePhoto: map['calleePhoto'] ?? '',
      type: (map['type'] == 'video') ? CallType.video : CallType.audio,
      status: CallStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => CallStatus.ended,
      ),
      createdAt: map['createdAt'] ?? Timestamp.now(),
      durationSeconds: map['durationSeconds'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'callerId': callerId,
      'callerName': callerName,
      'callerPhoto': callerPhoto,
      'calleeId': calleeId,
      'calleeName': calleeName,
      'calleePhoto': calleePhoto,
      'type': type.name,
      'status': status.name,
      'createdAt': createdAt,
      'durationSeconds': durationSeconds,
    };
  }
}

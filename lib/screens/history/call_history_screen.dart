
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/call_model.dart';
import '../../services/calling_service.dart';

class CallHistoryScreen extends StatelessWidget {
  const CallHistoryScreen({super.key});

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');

    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const SafeArea(
        child: Center(
          child: Text('Please log in to view call history.'),
        ),
      );
    }

    final myUid = user.uid;
    final calling = context.read<CallingService>();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --------------------------------------------------
          // HEADER
          // --------------------------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              16,
              20,
              8,
            ),
            child: Text(
              'Call History',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // --------------------------------------------------
          // CALL HISTORY
          // --------------------------------------------------
          Expanded(
            child: StreamBuilder<List<CallModel>>(
              stream: calling.historyStream(myUid),

              builder: (context, snapshot) {
                // Loading
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // Error
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Could not load call history.',
                    ),
                  );
                }

                final calls = snapshot.data ?? [];

                // Empty
                if (calls.isEmpty) {
                  return const Center(
                    child: Text('No calls yet.'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),

                  itemCount: calls.length,

                  separatorBuilder: (_, __) =>
                  const Divider(height: 1),

                  itemBuilder: (context, i) {
                    final c = calls[i];

                    // ------------------------------------------------
                    // DETERMINE CALL DIRECTION
                    // ------------------------------------------------

                    final outgoing =
                        c.callerId == myUid;

                    final otherName = outgoing
                        ? c.calleeName
                        : c.callerName;

                    // ------------------------------------------------
                    // DETERMINE WHETHER TO SHOW STATUS OR DURATION
                    // ------------------------------------------------

                    final showStatus =
                        c.status == CallStatus.missed ||
                            c.status == CallStatus.rejected ||
                            c.status == CallStatus.busy ||
                            c.status == CallStatus.failed;

                    // ------------------------------------------------
                    // STATUS COLOR
                    // ------------------------------------------------

                    final statusColor =
                    showStatus
                        ? AppTheme.danger
                        : Colors.grey;

                    // ------------------------------------------------
                    // TRAILING TEXT
                    // ------------------------------------------------

                    final trailingText = showStatus
                        ? _statusLabel(c.status)
                        : _formatDuration(
                      c.durationSeconds,
                    );

                    return ListTile(
                      contentPadding:
                      const EdgeInsets.symmetric(
                        horizontal: 4,
                      ),

                      // ------------------------------------------------
                      // CALL ICON
                      // ------------------------------------------------

                      leading: CircleAvatar(
                        backgroundColor:
                        AppTheme.primary.withOpacity(
                          0.12,
                        ),
                        child: Icon(
                          c.type == CallType.video
                              ? Icons.videocam
                              : Icons.call,
                          color: AppTheme.primary,
                        ),
                      ),

                      // ------------------------------------------------
                      // NAME
                      // ------------------------------------------------

                      title: Text(
                        otherName.isEmpty
                            ? 'Unknown'
                            : otherName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // ------------------------------------------------
                      // DATE + DIRECTION
                      // ------------------------------------------------

                      subtitle: Row(
                        children: [
                          Icon(
                            outgoing
                                ? Icons.call_made
                                : Icons.call_received,
                            size: 14,
                            color: statusColor,
                          ),

                          const SizedBox(width: 4),

                          Flexible(
                            child: Text(
                              DateFormat(
                                'MMM d, h:mm a',
                              ).format(
                                c.createdAt.toDate(),
                              ),
                              style: TextStyle(
                                color: statusColor,
                              ),
                              maxLines: 1,
                              overflow:
                              TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      // ------------------------------------------------
                      // DURATION / STATUS
                      // ------------------------------------------------

                      trailing: Text(
                        trailingText,
                        style: TextStyle(
                          color: showStatus
                              ? AppTheme.danger
                              : Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // CALL STATUS LABEL
  // ------------------------------------------------------------

  String _statusLabel(CallStatus status) {
    switch (status) {
      case CallStatus.missed:
        return 'Missed';

      case CallStatus.rejected:
        return 'Declined';

      case CallStatus.busy:
        return 'Busy';

      case CallStatus.failed:
        return 'Failed';

      case CallStatus.calling:
        return 'Calling';

      case CallStatus.ringing:
        return 'Ringing';

      case CallStatus.connected:
        return 'Connected';

      case CallStatus.ended:
        return _formatDuration(0);
    }
  }
}

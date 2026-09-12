import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/calling_service.dart';
import '../../services/user_service.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _userService = UserService();

  Future<void> _editName(BuildContext context, String current) async {
    final ctrl = TextEditingController(text: current);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit name'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: const Text('Save')),
        ],
      ),
    );
    if (newName != null && newName.isNotEmpty) {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await _userService.updateProfile(uid: uid, name: newName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return SafeArea(
      child: StreamBuilder(
        stream: _userService.userStream(uid),
        builder: (context, snapshot) {
          final user = snapshot.data;
          if (user == null) return const Center(child: CircularProgressIndicator());
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: AppTheme.primary.withOpacity(0.15),
                  backgroundImage: user.photoUrl.isNotEmpty ? NetworkImage(user.photoUrl) : null,
                  child: user.photoUrl.isEmpty
                      ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                          style: const TextStyle(fontSize: 32, color: AppTheme.primary, fontWeight: FontWeight.bold))
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              Center(child: Text(user.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))),
              const SizedBox(height: 4),
              Center(child: Text(user.email, style: Theme.of(context).textTheme.bodyMedium)),
              const SizedBox(height: 4),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: user.isOnline ? AppTheme.success : Colors.grey, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(user.isOnline ? 'Online' : 'Offline'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit Profile'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _editName(context, user.name),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: AppTheme.danger),
                title: const Text('Logout', style: TextStyle(color: AppTheme.danger)),
                onTap: () async {
                  await context.read<CallingService>().dispose_();
                  await context.read<AuthService>().logout();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

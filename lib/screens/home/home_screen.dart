import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import '../../services/user_service.dart';
import '../../widgets/user_tile.dart';
import '../contacts/contacts_screen.dart';
import '../history/call_history_screen.dart';
import '../profile/profile_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  final _tabs = const [
    _HomeTab(),
    ContactsScreen(),
    CallHistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tab, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.people_outline_rounded), selectedIcon: Icon(Icons.people_rounded), label: 'Contacts'),
          NavigationDestination(icon: Icon(Icons.call_outlined), selectedIcon: Icon(Icons.call_rounded), label: 'Calls'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

/// Home tab: gradient greeting header + search + contact list.
class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final _userService = UserService();
  String _query = '';

  String get _greetingName {
    final name = FirebaseAuth.instance.currentUser?.displayName;
    if (name == null || name.trim().isEmpty) return 'there';
    return name.trim().split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hey, $_greetingName 👋',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 2),
                        Text('Who do you want to call today?',
                            style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
                      ],
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.4)),
                      ),
                      child: const Icon(Icons.call_rounded, color: Colors.white, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  style: const TextStyle(
                    color: Colors.black, // text you type
                  ),

                  decoration: InputDecoration(
                    hintText: 'Search people...',
                    prefixIcon: const Icon(Icons.search_rounded,
                    color: Colors.black,),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _userService.contactsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Could not load contacts.'));
                }
                final users = _userService.filter(snapshot.data ?? [], _query);
                if (users.isEmpty) {
                  return const Center(child: Text('No contacts found.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
                  itemCount: users.length,
                  itemBuilder: (context, i) => UserTile(user: users[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


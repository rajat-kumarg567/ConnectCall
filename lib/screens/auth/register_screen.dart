// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../main.dart' show navigatorKey;
// import '../../services/auth_service.dart';
// import '../../services/calling_service.dart';
// import '../home/home_screen.dart';
//
// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});
//
//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }
//
// class _RegisterScreenState extends State<RegisterScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameCtrl = TextEditingController();
//   final _emailCtrl = TextEditingController();
//   final _passCtrl = TextEditingController();
//   final _confirmCtrl = TextEditingController();
//   bool _loading = false;
//   String? _error;
//
//   Future<void> _register() async {
//     if (!_formKey.currentState!.validate()) return;
//     setState(() {
//       _loading = true;
//       _error = null;
//     });
//     final auth = context.read<AuthService>();
//     try {
//       await auth.register(
//         name: _nameCtrl.text,
//         email: _emailCtrl.text,
//         password: _passCtrl.text,
//       );
//       if (!mounted) return;
//       final user = auth.currentUser!;
//       await context.read<CallingService>().init(
//         uid: user.uid,
//         name: _nameCtrl.text.trim(),
//         navigatorKey: navigatorKey,
//       );
//       if (!mounted) return;
//       Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(builder: (_) => const HomeScreen()),
//             (route) => false,
//       );
//     } catch (e) {
//       setState(() => _error = auth.mapError(e));
//     } finally {
//       if (mounted) setState(() => _loading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Create Account')),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24),
//           child: Form(
//             key: _formKey,
//             child: ListView(
//               children: [
//                 const SizedBox(height: 8),
//                 TextFormField(
//                   controller: _nameCtrl,
//                   decoration: const InputDecoration(labelText: 'Name'),
//                   validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
//                 ),
//                 const SizedBox(height: 14),
//                 TextFormField(
//                   controller: _emailCtrl,
//                   keyboardType: TextInputType.emailAddress,
//                   decoration: const InputDecoration(labelText: 'Email'),
//                   validator: (v) =>
//                   (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
//                 ),
//                 const SizedBox(height: 14),
//                 TextFormField(
//                   controller: _passCtrl,
//                   obscureText: true,
//                   decoration: const InputDecoration(labelText: 'Password'),
//                   validator: (v) =>
//                   (v == null || v.length < 6) ? 'Minimum 6 characters' : null,
//                 ),
//                 const SizedBox(height: 14),
//                 TextFormField(
//                   controller: _confirmCtrl,
//                   obscureText: true,
//                   decoration: const InputDecoration(labelText: 'Confirm Password'),
//                   validator: (v) =>
//                   (v != _passCtrl.text) ? 'Passwords do not match' : null,
//                 ),
//                 if (_error != null) ...[
//                   const SizedBox(height: 12),
//                   Text(_error!, style: const TextStyle(color: Colors.red)),
//                 ],
//                 const SizedBox(height: 24),
//                 ElevatedButton(
//                   onPressed: _loading ? null : _register,
//                   child: _loading
//                       ? const SizedBox(
//                     width: 22,
//                     height: 22,
//                     child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
//                   )
//                       : const Text('Create Account'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../main.dart' show navigatorKey;
import '../../services/auth_service.dart';
import '../../services/calling_service.dart';
import '../home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final auth = context.read<AuthService>();
    try {
      await auth.register(
        name: _nameCtrl.text,
        email: _emailCtrl.text,
        password: _passCtrl.text,
      );
      if (!mounted) return;
      final user = auth.currentUser!;
      await context.read<CallingService>().init(
        uid: user.uid,
        name: _nameCtrl.text.trim(),
        navigatorKey: navigatorKey,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
      );
    } catch (e) {
      setState(() => _error = auth.mapError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Vibrant gradient hero behind everything, matching the login screen.
          Container(
            height: 260,
            decoration: const BoxDecoration(
              gradient: AppTheme.coolGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(48),
                bottomRight: Radius.circular(48),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.15),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Create account',
                    style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Join ConnectCall in a few seconds',
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _nameCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Name',
                              prefixIcon: Icon(Icons.person_outline_rounded),
                            ),
                            validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.mail_outline_rounded),
                            ),
                            validator: (v) =>
                            (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _passCtrl,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock_outline_rounded),
                            ),
                            validator: (v) =>
                            (v == null || v.length < 6) ? 'Minimum 6 characters' : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _confirmCtrl,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Confirm Password',
                              prefixIcon: Icon(Icons.lock_outline_rounded),
                            ),
                            validator: (v) =>
                            (v != _passCtrl.text) ? 'Passwords do not match' : null,
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 12),
                            Text(_error!, style: const TextStyle(color: AppTheme.danger, fontSize: 13)),
                          ],
                          const SizedBox(height: 22),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: AppTheme.coolGradient,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              onPressed: _loading ? null : _register,
                              child: _loading
                                  ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                                  : const Text('Create Account'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

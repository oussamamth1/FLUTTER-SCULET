// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:zenify_auth/zenify_auth.dart';
// import 'package:go_router/go_router.dart';

// class LoginScreen extends ConsumerStatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   ConsumerState<LoginScreen> createState() => _LoginScreenState();

// }

// class _LoginScreenState extends ConsumerState<LoginScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _loading = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Login")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               controller: _emailController,
//               decoration: const InputDecoration(labelText: "Email"),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _passwordController,
//               obscureText: true,
//               decoration: const InputDecoration(labelText: "Password"),
//             ),
//             const SizedBox(height: 24),
//             _loading
//                 ? const CircularProgressIndicator()
//                 : ElevatedButton(
//                   onPressed: () async {
//                     setState(() => _loading = true);

//                     // 🔥 Use the authProvider's notifier to login
//                     await ref
//                         .read(authProvider.notifier)
//                         .login(
//                           _emailController.text.trim(),
//                           _passwordController.text.trim(),
//                         );

//                     // Get the current user from state
//                     if (!mounted) return; // ensure widget is still alive
//                     final user = ref.read(authProvider);
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text("Invalid credentials")),
//                     );
//                     if (user != null) {
//                       context.go('/'); // safe now
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text("Invalid credentials")),
//                       );
//                     }

//                     setState(() => _loading = false);
//                   },
//                   child: const Text("Login"),
//                 ),
//           ],
//         ),
//       ),
//     );
//   }
// }

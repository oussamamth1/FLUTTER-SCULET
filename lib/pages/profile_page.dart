import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenify_auth/zenify_auth.dart' as zenifyAuth;
import 'package:go_router/go_router.dart';
import 'package:zenifytrip_guide/env.dart';
import 'package:zenifytrip_guide/provider/location_provider.dart';
import 'package:provider/provider.dart' as provider;

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  String? socketId;
  String? authCookie;

  @override
  void initState() {
    super.initState();
    
   
  }



  @override
  Widget build(BuildContext context) {
    final user = ref.watch(zenifyAuth.authProvider);
    final authState = ref.watch(zenifyAuth.authProvider);
    print(authState.user?.picture);
    // final locationProvider = context.read<LocationProvider>();
    // locationProvider.setCustomMapPin(
    //     "${AppEnvironment.baseApiUrl}/assets/uploads/traveller/${authState.user?.picture}");
    // locationProvider.setPictureUrl("${AppEnvironment.baseApiUrl}/assets/uploads/traveller/${authState.user?.picture}");
    // //print("Auth Cookie: $authCookie");
    return Scaffold(
      appBar: AppBar(title: Text('Profile s${authCookie ?? "dd"}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            user == null
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/location.png'),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${authState.user?.firstName ?? ''} ${authState.user?.lastName ?? ''}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.status.name ?? '',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text('Settings'),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Logout'),
                      onTap: () async {
                        await ref
                            .read(zenifyAuth.authProvider.notifier)
                            .logout();
                        context.go('/login');
                      },
                    ),
                  ],
                ),
      ),
    );
  }
}

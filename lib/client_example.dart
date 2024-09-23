import 'package:flutter/material.dart';
import 'package:nebx_minimal_example/persistence/dummy_repository.dart';
import 'package:nebx_minimal_example/services.dart';

class ClientExample extends StatefulWidget {
  const ClientExample({super.key});

  @override
  State<ClientExample> createState() => _ClientExampleState();
}

class _ClientExampleState extends State<ClientExample> {
  // try to change the http client injection at service.dart
  final dummyRepo = getIt<IDummyRepository>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              await dummyRepo.loginAccount();
            },
            child: const Text("Login Account"),
          ),
          ElevatedButton(
            onPressed: () async {
              // try wait the token expired to see auto refresh token functionality when facing unauthorized status code
              await dummyRepo.fetchUserData();
            },
            child: const Text("Fetch user data"),
          )
        ],
      )),
    );
  }
}

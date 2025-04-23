import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;
  final String redirectRoute;

  const AuthGuard({
    Key? key,
    required this.child,
    this.redirectRoute = '/login',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (!auth.isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed(redirectRoute);
          });
          return const SizedBox.shrink();
        }
        return child;
      },
    );
  }
}
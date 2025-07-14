// lib/main.dart

// Import packages/modules
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rovify/data/firebase/firebase_initializer.dart';
import 'package:rovify/data/repositories/auth_repository_impl.dart';
import 'package:rovify/domain/usecases/sign_in_user.dart';
import 'package:rovify/domain/usecases/sign_up_user.dart';
import 'package:rovify/presentation/blocs/auth/auth_bloc.dart';
import 'core/theme/app_theme.dart';
import 'presentation/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseInitializer.initialize(); // call from custom initializer
  //  debugPaintSizeEnabled = true; // SHOW widget boundaries
  // Firebase instances
  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

   // Repository implementation
  final authRepository = AuthRepositoryImpl(firebaseAuth, firestore);

   // Use cases
  final signUpUser = SignUpUser(authRepository);
  final signInUser = SignInUser(authRepository);
  
  runApp(
    BlocProvider(
      create: (_) => AuthBloc(
        signUpUser: signUpUser,
        signInUser: signInUser,
        firebaseAuth: firebaseAuth,
      ),
    child: const RovifyApp()
    )
  );
}

class RovifyApp extends StatelessWidget {
  const RovifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Rovify',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
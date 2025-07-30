import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:rovify/core/theme/app_theme.dart';
import 'package:rovify/data/firebase/firebase_initializer.dart';

import 'package:rovify/data/datasources/event_remote_datasource.dart';
import 'package:rovify/data/repositories/auth_repository_impl.dart';
import 'package:rovify/data/repositories/event_repository_impl.dart';

import 'package:rovify/domain/usecases/sign_up_user.dart';
import 'package:rovify/domain/usecases/sign_in_user.dart';
import 'package:rovify/domain/usecases/events/get_upcoming_events.dart';
import 'package:rovify/domain/usecases/events/toggle_event_favorite.dart';

import 'package:rovify/presentation/blocs/auth/auth_bloc.dart';
import 'package:rovify/presentation/blocs/auth/auth_state.dart';
import 'package:rovify/presentation/blocs/events/event_bloc.dart';
import 'package:rovify/presentation/blocs/splash/splash_cubit.dart';

import 'package:rovify/presentation/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseInitializer.initialize(); // Initializes Firebase

  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  // Repositories
 final authRepository = AuthRepositoryImpl(
  firebaseAuth,
  firestore,
);


  final eventRepository = EventRepositoryImpl(
    EventRemoteDataSource(firestore),
  );

  // Use Cases
  final signUpUser = SignUpUser(authRepository);
  final signInUser = SignInUser(authRepository);
  final getUpcomingEvents = GetUpcomingEvents(eventRepository);
  final toggleEventFavorite = ToggleEventFavorite(eventRepository);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SplashCubit()),
        BlocProvider(
          create: (_) => AuthBloc(
            signUpUser: signUpUser,
            signInUser: signInUser,
            firebaseAuth: firebaseAuth,
          ),
        ),
        BlocProvider(
          create: (_) => EventBloc(
            getUpcomingEvents: getUpcomingEvents,
            toggleEventFavorite: toggleEventFavorite,
            userId: firebaseAuth.currentUser?.uid ?? '',
          )..add(LoadUpcomingEvents()),
        ),
      ],
      child: const RovifyApp(),
    ),
  );
}

class RovifyApp extends StatelessWidget {
  const RovifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Rovify',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
      builder: (context, child) {
        return BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is Authenticated) {
              AppRouter.router.go('/explore');
            } else if (state is UnAuthenticated) {
              AppRouter.router.go('/auth/login');
            }
          },
          child: child,
        );
      },
    );
  }
}

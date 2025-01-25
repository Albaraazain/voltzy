import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/logger_service.dart';
import 'package:flutter/material.dart';
import '../features/auth/screens/welcome_screen.dart';
import '../models/profile_model.dart' as models;

enum UserType { professional, homeowner, none }

class AuthProvider extends ChangeNotifier {
  StreamSubscription<AuthState>? _authStateSubscription;
  late final Future<void> initializationCompleted;
  final SupabaseClient _client;

  bool _isAuthenticated = false;
  UserType _userType = UserType.none;
  User? _user;
  Map<String, dynamic>? _profile;
  bool _isInitialized = false;
  models.Profile? _profileModel;

  AuthProvider(this._client) {
    // Initialize the completion future
    initializationCompleted = _initializeAuth();
  }

  // Expose client safely
  SupabaseClient get client => _client;

  bool get isAuthenticated => _isAuthenticated;
  UserType get userType => _userType;
  User? get user => _user;
  Map<String, dynamic>? get profile => _profile;
  String? get userId => _user?.id;
  String? get email => _user?.email;
  String? get fullName => _profile?['name'];
  bool get isInitialized => _isInitialized;

  Future<void> _initializeAuth() async {
    if (_isInitialized) return;

    try {
      LoggerService.info('🔄 Starting auth initialization...');

      // Listen to auth state changes
      _authStateSubscription =
          _client.auth.onAuthStateChange.listen((event) async {
        LoggerService.debug('Auth state changed: ${event.event}');

        if (event.event == AuthChangeEvent.signedIn) {
          _user = event.session?.user;
          _isAuthenticated = true;
          if (_user != null) {
            await _loadProfile(_user!.id);
          }
        } else if (event.event == AuthChangeEvent.signedOut) {
          _isAuthenticated = false;
          _userType = UserType.none;
          _user = null;
          _profile = null;
          notifyListeners();
        }
      });

      // Check if user is already signed in
      final session = _client.auth.currentSession;
      _user = session?.user;
      if (_user != null) {
        _isAuthenticated = true;
        await _loadProfile(_user!.id);
      }

      _isInitialized = true;
      LoggerService.info('✅ Auth initialization completed');
      notifyListeners();
    } catch (e, stackTrace) {
      LoggerService.error('❌ Failed to initialize auth', e, stackTrace);
      rethrow;
    }
  }

  Future<void> _loadProfile(String userId) async {
    try {
      LoggerService.debug('📥 Loading profile data for user ID: $userId');
      final response =
          await _client.from('profiles').select().eq('id', userId).single();

      LoggerService.debug('Converting profile data to model...');
      _profileModel = models.Profile.fromJson(response);

      _isAuthenticated = true;
      _userType = _convertUserType(_profileModel!.userType);
      _profile = _profileModel!.toJson();

      LoggerService.info('✅ Profile loaded successfully');
      LoggerService.debug(
          'Profile details: ${_profile!['name']} (${_profile!['user_type']})');
    } catch (e, stackTrace) {
      LoggerService.error('❌ Failed to load profile', e, stackTrace);
      rethrow;
    }
  }

  UserType _convertUserType(models.UserType type) {
    switch (type) {
      case models.UserType.professional:
        return UserType.professional;
      case models.UserType.homeowner:
        return UserType.homeowner;
      default:
        return UserType.none;
    }
  }

  models.UserType _convertToModelUserType(UserType type) {
    switch (type) {
      case UserType.professional:
        return models.UserType.professional;
      case UserType.homeowner:
        return models.UserType.homeowner;
      case UserType.none:
        return models.UserType.homeowner; // Default to homeowner
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      LoggerService.info(
          '🔐 Starting sign-in process for email: ${email.split('@')[0]}@***');

      LoggerService.debug('Attempting to sign in with Supabase auth...');
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        LoggerService.error(
            'Sign-in failed: No user returned from auth response');
        throw 'Invalid credentials';
      }

      LoggerService.info('✅ Auth successful, user ID: ${response.user!.id}');
      LoggerService.debug('Loading user profile...');

      await _loadProfile(response.user!.id);
      LoggerService.info(
          '👤 Profile loaded successfully. User type: $_userType');

      notifyListeners();
      LoggerService.info('🎉 Sign-in process completed successfully');
    } catch (e, stackTrace) {
      LoggerService.error('❌ Sign-in failed', e, stackTrace);
      rethrow;
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
    required UserType userType,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw 'Failed to create account';
      }

      final profile = models.Profile(
        id: response.user!.id,
        email: email,
        name: name,
        userType: _convertToModelUserType(userType),
        createdAt: DateTime.now(),
      );

      await _client.from('profiles').insert(profile.toJson());
      _profileModel = profile;
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      LoggerService.error('Error signing up', e);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      _isAuthenticated = false;
      _userType = UserType.none;
      _user = null;
      _profile = null;
      notifyListeners();
    } catch (e) {
      LoggerService.error('Error signing out', e);
      rethrow;
    }
  }

  Future<void> signOutAndNavigate(BuildContext context) async {
    try {
      // First, detach the auth state listener to prevent unwanted updates
      _authStateSubscription?.pause();

      // Clear the state immediately but don't notify
      _isAuthenticated = false;
      _userType = UserType.none;
      _user = null;
      _profile = null;

      // Then sign out from Supabase
      await _client.auth.signOut();

      // Only after state is cleared, navigate
      if (context.mounted) {
        await Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          (route) => false,
        );
      }

      // Finally notify listeners after navigation is complete
      notifyListeners();

      // Resume the auth state listener
      _authStateSubscription?.resume();
    } catch (e, stackTrace) {
      // Resume the auth state listener in case of error
      _authStateSubscription?.resume();
      LoggerService.error('Failed to sign out and navigate', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    try {
      // First, detach the auth state listener to prevent unwanted updates
      _authStateSubscription?.pause();

      // Clear the state immediately but don't notify
      _isAuthenticated = false;
      _userType = UserType.none;
      _user = null;
      _profile = null;

      // Delete the account
      await _client.auth.signOut();

      // Navigate to welcome screen
      if (context.mounted) {
        await Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          (route) => false,
        );
      }

      // Finally notify listeners after navigation is complete
      notifyListeners();

      // Resume the auth state listener
      _authStateSubscription?.resume();
    } catch (e, stackTrace) {
      // Resume the auth state listener in case of error
      _authStateSubscription?.resume();
      LoggerService.error('Failed to delete account', e, stackTrace);
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      LoggerService.error('Error resetting password', e);
      rethrow;
    }
  }

  Future<void> checkSession() async {
    try {
      final session = _client.auth.currentSession;
      if (session != null) {
        await _loadProfile(session.user.id);
        notifyListeners();
      }
    } catch (e) {
      LoggerService.error('Error checking session', e);
      rethrow;
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}

// TODO: Implement account deletion functionality

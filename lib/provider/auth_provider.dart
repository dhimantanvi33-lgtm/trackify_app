import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

enum AuthStatus { idle, loading, authenticated, error }

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService() {
    _init();
  }

  final AuthService _authService;

  AuthStatus _status = AuthStatus.idle;
  String? _errorMessage;
  User? _user;
  bool _isInitializing = true;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  User? get user => _user;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isAuthenticated => _user != null;
  bool get isInitializing => _isInitializing;

  void _init() {
    _authService.authStateChanges.listen((user) {
      _user = user;
      if (_isInitializing) {
        _isInitializing = false;
      }
      notifyListeners();
    });
  }
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      final credential = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      _user = credential.user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (_) {
      _setError('Something went wrong. Please try again');
      return false;
    }
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      final credential = await _authService.signUpWithEmail(
        name: name,
        email: email,
        password: password,
      );
      _user = credential.user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (_) {
      _setError('Something went wrong. Please try again');
      return false;
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    _setLoading();
    try {
      await _authService.sendPasswordResetEmail(email);
      _status = AuthStatus.idle;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (_) {
      _setError('Something went wrong. Please try again');
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _status = AuthStatus.idle;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) _status = AuthStatus.idle;
    notifyListeners();
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }
}
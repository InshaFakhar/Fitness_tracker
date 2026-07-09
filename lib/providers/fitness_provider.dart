import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/workout_model.dart';
import '../services/database_service.dart';
import '../services/firebase_service.dart';

class FitnessProvider extends ChangeNotifier {
  final _db = DatabaseService();
  final _fb = FirebaseService();

  List<WorkoutModel> _all    = [];
  List<WorkoutModel> _today  = [];
  List<WorkoutModel> _week   = [];
  List<WorkoutModel> _search = [];
  UserProfile? _profile;
  int _water    = 0;
  bool _loading = false;
  String? _sync;
  List<double> _weekCals = List.filled(7, 0);
  String _filter  = 'All';
  String _searchQ = '';

  List<WorkoutModel> get all        => _all;
  List<WorkoutModel> get today      => _today;
  List<WorkoutModel> get week       => _week;
  List<WorkoutModel> get search     => _search;
  UserProfile?       get profile    => _profile;
  int                get water      => _water;
  bool               get loading    => _loading;
  String?            get sync       => _sync;
  List<double>       get weekCals   => _weekCals;
  String             get filter     => _filter;
  bool               get isLoggedIn => _fb.loggedIn;
  String             get email      => _fb.email;
  String             get displayName => _fb.displayName;
  String             get uid        => _fb.uid;

  int    get todaySteps    => _today.fold(0, (s, e) => s + e.steps);
  int    get todayCals     => _today.fold(0, (s, e) => s + e.calories);
  int    get todayMins     => _today.fold(0, (s, e) => s + e.duration);
  int    get weekCalsTotal => _week.fold(0, (s, e) => s + e.calories);

  double get calProgress   => (todayCals  / (_profile?.dailyCalorieGoal ?? 500)).clamp(0.0, 1.0);
  double get stepProgress  => (todaySteps / (_profile?.dailyStepGoal    ?? 8000)).clamp(0.0, 1.0);
  double get waterProgress => (_water / 8.0).clamp(0.0, 1.0);

  // ── INIT ──────────────────────────────────────────────────
  Future<void> init() async {
    _loading = true; notifyListeners();
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        _profile = await _db.getProfile(firebaseUser.uid);
        if (_profile == null) {
          _profile = await _fb.getProfile()
              .timeout(const Duration(seconds: 5), onTimeout: () => null);
          if (_profile != null) await _db.saveProfile(_profile!);
        }
      }
      await _loadLocal();
    } catch (_) {}
    _loading = false; notifyListeners();
    // Background sync
    if (_fb.loggedIn) {
      _fb.syncAll(_fb.uid).catchError((_) {});
    }
  }

  Future<void> _loadLocal() async {
    if (!_fb.loggedIn) return;
    final uid = _fb.uid;
    try {
      _all      = await _db.getAll(uid);
      _today    = await _db.getToday(uid);
      _week     = await _db.getThisWeek(uid);
      _water    = await _db.getWaterToday(uid);
      _weekCals = await _db.weeklyCalories(uid);
      if (_profile == null) {
        _profile = await _db.getProfile(uid);
        _profile ??= await _fb.getProfile()
            .timeout(const Duration(seconds: 5), onTimeout: () => null);
        if (_profile != null) await _db.saveProfile(_profile!);
      }
    } catch (_) {}
    _applyFilter();
  }

  void _applyFilter() {
    var list = _all;
    if (_filter != 'All') list = list.where((e) => e.type == _filter).toList();
    if (_searchQ.isNotEmpty) {
      list = list.where((e) =>
      e.name.toLowerCase().contains(_searchQ.toLowerCase()) ||
          e.type.toLowerCase().contains(_searchQ.toLowerCase())).toList();
    }
    _search = list;
    notifyListeners();
  }

  void setFilter(String f) { _filter = f; _applyFilter(); }
  void setSearch(String q) { _searchQ = q; _applyFilter(); }

  // ── WORKOUTS ──────────────────────────────────────────────
  Future<void> addWorkout(WorkoutModel w) async {
    // Save local first — instant
    await _db.upsertWorkout(w);
    await _loadLocal();
    notifyListeners();
    // Firebase background — no await
    if (_fb.loggedIn) {
      _setSync('Syncing...');
      _fb.uploadWorkout(w)
          .then((_) => _setSync('Synced ✓'))
          .catchError((_) { _sync = null; notifyListeners(); });
    }
  }

  Future<void> updateWorkout(WorkoutModel w) async {
    await _db.upsertWorkout(w);
    await _loadLocal();
    notifyListeners();
    if (_fb.loggedIn) {
      _fb.uploadWorkout(w).catchError((_) {});
    }
  }

  Future<void> deleteWorkout(String id) async {
    await _db.deleteWorkout(id);
    if (_fb.loggedIn) _fb.deleteWorkoutCloud(id).catchError((_) {});
    await _loadLocal();
    notifyListeners();
  }

  Future<void> setWater(int g) async {
    if (!_fb.loggedIn) return;
    _water = g;
    await _db.setWater(_fb.uid, g);
    notifyListeners();
  }

  // Profile save — local instant, Firebase background
  Future<void> saveProfile(UserProfile p) async {
    _profile = p;
    notifyListeners();
    await _db.saveProfile(p);
    // Firebase background
    _fb.updateProfile(p).catchError((_) {});
  }

  // ── AUTH ──────────────────────────────────────────────────
  Future<String?> signIn(String e, String p) async {
    try {
      final err = await _fb.signIn(e, p)
          .timeout(const Duration(seconds: 15),
          onTimeout: () => 'Connection timeout. Check internet.');
      if (err != null) return err;
      // Load profile
      try {
        _profile = await _fb.getProfile()
            .timeout(const Duration(seconds: 5), onTimeout: () => null);
        if (_profile != null) await _db.saveProfile(_profile!);
      } catch (_) {}
      await _loadLocal();
      // Cloud sync background
      _fb.pullCloud().catchError((_) {});
      _setSync('Synced ✓');
      return null;
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }

  Future<String?> signUp(String e, String p, String name) async {
    try {
      final err = await _fb.signUp(e, p, name)
          .timeout(const Duration(seconds: 15),
          onTimeout: () => 'Connection timeout. Check internet.');
      if (err != null) return err;
      // Wait a moment then get profile
      await Future.delayed(const Duration(milliseconds: 600));
      try {
        _profile = await _fb.getProfile()
            .timeout(const Duration(seconds: 5), onTimeout: () => null);
        if (_profile != null) await _db.saveProfile(_profile!);
      } catch (_) {}
      await _loadLocal();
      notifyListeners();
      return null;
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }

  Future<String?> signInGoogle() async {
    try {
      final err = await _fb.signInWithGoogle()
          .timeout(const Duration(seconds: 30),
          onTimeout: () => 'Connection timeout. Check internet.');
      if (err == 'Cancelled') return 'Cancelled';
      if (err != null) return err;
      try {
        _profile = await _fb.getProfile()
            .timeout(const Duration(seconds: 5), onTimeout: () => null);
        if (_profile != null) await _db.saveProfile(_profile!);
      } catch (_) {}
      await _loadLocal();
      _fb.pullCloud().catchError((_) {});
      _setSync('Synced ✓');
      return null;
    } catch (_) {
      return 'Google sign-in failed. Please try again.';
    }
  }

  Future<String?> forgotPassword(String e) async {
    try {
      return await _fb.forgotPassword(e)
          .timeout(const Duration(seconds: 15),
          onTimeout: () => 'Connection timeout. Check internet.');
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }

  Future<void> signOut() async {
    await _fb.signOut();
    _profile  = null;
    _all      = [];
    _today    = [];
    _week     = [];
    _search   = [];
    _water    = 0;
    _weekCals = List.filled(7, 0);
    _filter   = 'All';
    _searchQ  = '';
    notifyListeners();
  }

  void _setSync(String? s) {
    _sync = s; notifyListeners();
    if (s?.contains('✓') == true) {
      Future.delayed(const Duration(seconds: 2), () {
        _sync = null; notifyListeners();
      });
    }
  }
}

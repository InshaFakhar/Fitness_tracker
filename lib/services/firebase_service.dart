import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/workout_model.dart';
import 'database_service.dart';

class FirebaseService {
  static final FirebaseService _i = FirebaseService._();
  factory FirebaseService() => _i;
  FirebaseService._();

  final _auth = FirebaseAuth.instance;
  final _fs   = FirebaseFirestore.instance;
  final _gsi  = GoogleSignIn();
  final _db   = DatabaseService();

  User? get user        => _auth.currentUser;
  bool get loggedIn     => user != null;
  String get uid        => user?.uid ?? '';
  String get email      => user?.email ?? '';
  String get displayName => user?.displayName ?? '';

  Future<String?> signUp(String email, String password, String name) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await cred.user?.updateDisplayName(name);
      try { await _createUserDoc(cred.user!, name); } catch (_) {}
      return null;
    } on FirebaseAuthException catch (e) {
      return _msg(e.code);
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _msg(e.code);
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }

  Future<String?> signInWithGoogle() async {
    try {
      final gUser = await _gsi.signIn();
      if (gUser == null) return 'Cancelled';
      final gAuth = await gUser.authentication;
      final cred  = GoogleAuthProvider.credential(
          accessToken: gAuth.accessToken, idToken: gAuth.idToken);
      final uc = await _auth.signInWithCredential(cred);
      if (uc.additionalUserInfo?.isNewUser == true) {
        try {
          await _createUserDoc(uc.user!, uc.user!.displayName ?? 'User');
        } catch (_) {}
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return _msg(e.code);
    } catch (_) {
      return 'Google sign-in failed. Add SHA-1 in Firebase Console.';
    }
  }

  Future<String?> forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return _msg(e.code);
    } catch (_) {
      return 'Something went wrong.';
    }
  }

  Future<void> signOut() async {
    try { await _gsi.signOut(); } catch (_) {}
    try { await _auth.signOut(); } catch (_) {}
  }

  Future<void> _createUserDoc(User u, String name) async {
    await _fs.collection('users').doc(u.uid).set({
      'uid': u.uid, 'name': name, 'email': u.email,
      'photoUrl': u.photoURL,
      'createdAt': FieldValue.serverTimestamp(),
      'height': 165.0, 'weight': 55.0, 'age': 21,
      'gender': 'Female',
      'dailyCalorieGoal': 500,
      'dailyStepGoal': 8000,
    }, SetOptions(merge: true));
  }

  // ── PROFILE ───────────────────────────────────────────────
  Future<UserProfile?> getProfile() async {
    if (!loggedIn) return null;
    try {
      final doc = await _fs.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserProfile.fromMap(doc.data()!);
      }
    } catch (_) {}
    return null;
  }

  Future<void> updateProfile(UserProfile p) async {
    if (!loggedIn) return;
    try {
      await _fs.collection('users').doc(uid)
          .set(p.toMap(), SetOptions(merge: true));
      await _db.saveProfile(p);
    } catch (_) {}
  }

  // ── WORKOUTS ──────────────────────────────────────────────
  CollectionReference get _workouts =>
      _fs.collection('users').doc(uid).collection('workouts');

  Future<void> uploadWorkout(WorkoutModel w) async {
    if (!loggedIn) return;
    try {
      await _workouts.doc(w.id).set(w.toFirestore());
      await _db.markSynced(w.id);
    } catch (_) {}
  }

  Future<void> deleteWorkoutCloud(String id) async {
    if (!loggedIn) return;
    try { await _workouts.doc(id).delete(); } catch (_) {}
  }

  Future<void> syncAll(String userId) async {
    if (!loggedIn) return;
    try {
      final unsynced = await _db.getUnsynced(userId);
      for (final w in unsynced) await uploadWorkout(w);
    } catch (_) {}
  }

  Future<void> pullCloud() async {
    if (!loggedIn) return;
    try {
      final snap = await _workouts
          .orderBy('date', descending: true)
          .get();
      for (final d in snap.docs) {
        final w =
        WorkoutModel.fromMap(d.data() as Map<String, dynamic>);
        w.synced = true;
        await _db.upsertWorkout(w);
      }
    } catch (_) {}
  }

  String _msg(String code) {
    switch (code) {
      case 'user-not-found':       return 'No account with this email.';
      case 'wrong-password':       return 'Incorrect password.';
      case 'invalid-credential':   return 'Incorrect email or password.';
      case 'email-already-in-use': return 'Email already registered.';
      case 'weak-password':        return 'Password must be at least 6 characters.';
      case 'invalid-email':        return 'Please enter a valid email.';
      case 'too-many-requests':    return 'Too many attempts. Try again later.';
      case 'network-request-failed': return 'No internet connection.';
      default: return 'Something went wrong. Please try again.';
    }
  }
}
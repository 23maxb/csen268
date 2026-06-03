import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserSettings {
  final int meals;
  final int calories;
  final Map<String, bool> restrictions;

  const UserSettings({
    required this.meals,
    required this.calories,
    required this.restrictions,
  });
}

class SettingsService {
  SettingsService._();

  static final SettingsService instance = SettingsService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const int defaultMeals = 3;
  static const int defaultCalories = 2000;

  static const Map<String, bool> defaultRestrictions = {
    'Gluten Free': false,
    'Halal': true,
    'Ketogenic': false,
    'Kosher': false,
    'Lacto-Vegetarian': false,
    'Low FODMAP': false,
    'Ovo-Vegetarian': false,
    'Paleo': false,
    'Pescetarian': false,
    'Primal': false,
    'Vegan': false,
    'Vegetarian': false,
    'Whole30': false,
  };

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('settings').doc(uid);

  Future<UserSettings> fetchOrCreate() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('No authenticated user.');
    }
    final ref = _doc(user.uid);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'meals': defaultMeals,
        'calories': defaultCalories,
        'restrictions': defaultRestrictions,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return UserSettings(
        meals: defaultMeals,
        calories: defaultCalories,
        restrictions: Map<String, bool>.from(defaultRestrictions),
      );
    }
    final data = snap.data() ?? {};
    final stored = (data['restrictions'] as Map?) ?? {};
    // Start from defaults so newly added restrictions show up, then overlay
    // any stored values.
    final restrictions = Map<String, bool>.from(defaultRestrictions);
    for (final entry in stored.entries) {
      restrictions[entry.key.toString()] = entry.value == true;
    }
    return UserSettings(
      meals: (data['meals'] as num?)?.toInt() ?? defaultMeals,
      calories: (data['calories'] as num?)?.toInt() ?? defaultCalories,
      restrictions: restrictions,
    );
  }

  Future<void> save(UserSettings settings) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('No authenticated user.');
    }
    await _doc(user.uid).set({
      'meals': settings.meals,
      'calories': settings.calories,
      'restrictions': settings.restrictions,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

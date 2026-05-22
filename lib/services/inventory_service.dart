import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InventoryService {
  InventoryService._();
  static final InventoryService instance = InventoryService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const Map<String, List<String>> defaultInventory = {
    'Vegetables': [
      'Carrots (3)',
      'Broccoli (1 head)',
      'Spinach (1 bag)',
      'Bell Peppers (2 red, 1 yellow)',
      'Zucchini (2)',
      'Mushrooms (1 box)',
      'Green Onions (1 bunch)',
      'Lettuce (1 head)',
    ],
    'Fruit': [
      'Apples (4)',
      'Bananas (5)',
      'Oranges (3)',
      'Grapes (1 small bunch)',
      'Strawberries (1 container)',
      'Blueberries (1 container)',
      'Lemon (2)',
    ],
    'Meat & Fish': [
      'Chicken Breast (2 pieces)',
      'Ground Beef (500g)',
      'Bacon (1 pack)',
      'Salmon Fillet (1)',
      'Deli Turkey Slices (1 pack)',
    ],
    'Dairy & Eggs': [
      'Milk (1L)',
      'Yogurt (2 small tubs)',
      'Butter (1 stick)',
      'Cheddar Cheese (1 block)',
      'Eggs (12)',
    ],
  };

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('inventories').doc(uid);

  Future<Map<String, List<String>>> fetchOrCreate() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('No authenticated user.');
    }
    final ref = _doc(user.uid);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'sections': defaultInventory,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return Map<String, List<String>>.from(
        defaultInventory.map((k, v) => MapEntry(k, List<String>.from(v))),
      );
    }
    final data = snap.data() ?? {};
    final sections = (data['sections'] as Map?) ?? {};
    return sections.map(
      (k, v) => MapEntry(k.toString(), List<String>.from(v as List)),
    );
  }

  Future<void> save(Map<String, List<String>> sections) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('No authenticated user.');
    }
    await _doc(user.uid).set({
      'sections': sections,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
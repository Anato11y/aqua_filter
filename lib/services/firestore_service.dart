import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aqua_filter/models/product_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Сохранение товара в Firestore
  Future<void> addProduct(Product product) async {
    await _db.collection('products').doc(product.id).set(product.toMap());
  }

  // Получение списка товаров из Firestore
  Stream<QuerySnapshot> getProductsStream() {
    return _db.collection('products').snapshots();
  }

  // Обновление товара
  Future<void> updateProduct(Product product) async {
    await _db.collection('products').doc(product.id).update(product.toMap());
  }

  // Удаление товара
  Future<void> deleteProduct(String productId) async {
    await _db.collection('products').doc(productId).delete();
  }
}

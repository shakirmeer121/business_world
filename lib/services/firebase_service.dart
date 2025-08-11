import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create/Add a new document to specified collection, returns doc ID
  Future<String> addDocument(String collection, Map<String, dynamic> data) async {
    DocumentReference docRef = await _firestore.collection(collection).add(data);
    return docRef.id;
  }

  // Read a single document by collection & doc ID
  Future<Map<String, dynamic>?> getDocument(String collection, String docId) async {
    DocumentSnapshot snapshot = await _firestore.collection(collection).doc(docId).get();
    return snapshot.exists ? snapshot.data() as Map<String, dynamic> : null;
  }

  // Read all documents from a collection
  Future<List<Map<String, dynamic>>> getAllDocuments(String collection) async {
    QuerySnapshot snapshot = await _firestore.collection(collection).get();
    return snapshot.docs
        .map((doc) => {
              "id": doc.id,
              ...doc.data() as Map<String, dynamic>,
            })
        .toList();
  }

  // Update a document by collection & doc ID
  Future<void> updateDocument(String collection, String docId, Map<String, dynamic> data) async {
    await _firestore.collection(collection).doc(docId).update(data);
  }

  // Delete a document by collection & doc ID
  Future<void> deleteDocument(String collection, String docId) async {
    await _firestore.collection(collection).doc(docId).delete();
  }

  // Listen to real-time updates for all documents in a collection
  Stream<List<Map<String, dynamic>>> listenToCollection(String collection) {
    return _firestore.collection(collection).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => {
                    "id": doc.id,
                    ...doc.data(),
                  })
              .toList(),
        );
  }
}

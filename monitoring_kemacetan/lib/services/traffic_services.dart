import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/traffic.dart';

class TrafficService {
  static final CollectionReference _trafficCollection =
      FirebaseFirestore.instance.collection('traffic');

  static Future<void> addTraffic(
    Traffic traffic,
  ) async {
    await _trafficCollection.add({
      ...traffic.toDocument(),
      'created_at': Timestamp.now(),
      'updated_at': Timestamp.now(),
    });
  }

  static Stream<List<Traffic>>
      getTrafficListByCategory(String? category) {
    Query query = _trafficCollection;

    if (category != null) {
      query = query.where(
        'category',
        isEqualTo: category,
      );
    }

    return query
        .orderBy(
          'created_at',
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Traffic.fromDocument(doc))
              .toList(),
        );
  }

  static Future<void> deleteTraffic(
    Traffic traffic,
  ) async {
    await _trafficCollection
        .doc(traffic.id)
        .delete();
  }
}
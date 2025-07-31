import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String rideId;
  final String riderId;
  final String passengerId;
  final double rating;
  final String feedback;
  final DateTime timestamp;

  Review({
    required this.id,
    required this.rideId,
    required this.riderId,
    required this.passengerId,
    required this.rating,
    required this.feedback,
    required this.timestamp,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      rideId: data['rideId'] ?? '',
      riderId: data['riderId'] ?? '',
      passengerId: data['passengerId'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      feedback: data['feedback'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rideId': rideId,
      'riderId': riderId,
      'passengerId': passengerId,
      'rating': rating,
      'feedback': feedback,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

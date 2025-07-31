import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create notification when passenger requests a ride
  static Future<void> createRideRequestNotification({
    required String rideRequestId,
    required String passengerId,
    required String riderId,
    required String passengerName,
    required String passengerPhone,
    required String startLocation,
    required String endLocation,
  }) async {
    try {
      print('🚀 Creating ride request notifications...');
      print('   Ride ID: $rideRequestId');
      print('   Passenger: $passengerName ($passengerId)');
      print('   Rider: $riderId');
      print('   Route: $startLocation → $endLocation');

      // Create notification for rider
      final riderNotificationRef =
          await _firestore.collection('notifications').add({
        'userId': riderId,
        'type': 'ride_request',
        'title': 'New Ride Request',
        'message':
            'You have a new ride request from $passengerName. Please review the details and respond.',
        'rideRequestId': rideRequestId,
        'passengerId': passengerId,
        'passengerName': passengerName,
        'passengerPhone': passengerPhone,
        'startLocation': startLocation,
        'endLocation': endLocation,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'icon': 'directions_car_outlined',
      });

      print('✅ Rider notification created: ${riderNotificationRef.id}');

      // Create confirmation notification for passenger
      final passengerNotificationRef =
          await _firestore.collection('notifications').add({
        'userId': passengerId,
        'type': 'ride_update',
        'title': 'Ride Request Sent',
        'message':
            'Your ride request has been sent successfully. Waiting for rider confirmation.',
        'rideRequestId': rideRequestId,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'icon': 'check_circle_outline',
      });

      print('✅ Passenger notification created: ${passengerNotificationRef.id}');
      print('🎉 Ride request notifications created successfully!');
    } catch (e) {
      print('❌ Error creating ride request notification: $e');
      rethrow;
    }
  }

  // Create notification when ride is accepted/rejected
  static Future<void> createRideResponseNotification({
    required String rideRequestId,
    required String passengerId,
    required String riderId,
    required String riderName,
    required String riderPhone,
    required bool isAccepted,
  }) async {
    try {
      print('🔄 Creating ride response notification...');
      print('   Ride ID: $rideRequestId');
      print('   Status: ${isAccepted ? "ACCEPTED" : "REJECTED"}');
      print('   Passenger: $passengerId');
      print('   Rider: $riderName ($riderId) - $riderPhone');

      final notificationRef = await _firestore.collection('notifications').add({
        'userId': passengerId,
        'type': 'ride_update',
        'title':
            isAccepted ? 'Ride Request Accepted!' : 'Ride Request Rejected',
        'message': isAccepted
            ? 'Great news! Your ride request has been accepted by $riderName. Contact: $riderPhone'
            : 'Sorry, your ride request has been rejected. Please try booking another ride.',
        'rideRequestId': rideRequestId,
        'riderId': riderId,
        'riderName': riderName,
        'riderPhone': riderPhone,
        'status': isAccepted ? 'accepted' : 'rejected',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'icon': isAccepted ? 'check_circle_outline' : 'cancel_outlined',
      });

      print('✅ Response notification created: ${notificationRef.id}');
      print('🎉 Ride response notification created successfully!');
    } catch (e) {
      print('❌ Error creating ride response notification: $e');
      rethrow;
    }
  }

  // Create notification for ride completion
  static Future<void> createRideCompletedNotification({
    required String rideRequestId,
    required String passengerId,
    required String riderId,
  }) async {
    try {
      // Notification for passenger
      await _firestore.collection('notifications').add({
        'userId': passengerId,
        'type': 'ride_update',
        'title': 'Ride Completed Successfully',
        'message':
            'Your ride has been completed successfully. Thank you for using ViaGo! Please rate your experience.',
        'rideRequestId': rideRequestId,
        'status': 'completed',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'icon': 'check_circle_outline',
      });

      // Notification for rider
      await _firestore.collection('notifications').add({
        'userId': riderId,
        'type': 'ride_update',
        'title': 'Ride Completed',
        'message': 'Ride completed successfully. Payment has been processed.',
        'rideRequestId': rideRequestId,
        'status': 'completed',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'icon': 'payment_outlined',
      });

      print('Ride completion notifications created successfully');
    } catch (e) {
      print('Error creating ride completion notification: $e');
      rethrow;
    }
  }

  // Create system notification
  static Future<void> createSystemNotification({
    required String userId,
    required String title,
    required String message,
    String type = 'system',
    String icon = 'info_outline',
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'type': type,
        'title': title,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'icon': icon,
      });

      print('System notification created successfully');
    } catch (e) {
      print('Error creating system notification: $e');
      rethrow;
    }
  }

  // Create promotional notification
  static Future<void> createPromotionalNotification({
    required String userId,
    required String title,
    required String message,
    String? promoCode,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'type': 'promotion',
        'title': title,
        'message': message,
        'promoCode': promoCode,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'icon': 'local_offer_outlined',
      });

      print('Promotional notification created successfully');
    } catch (e) {
      print('Error creating promotional notification: $e');
      rethrow;
    }
  }

  // Mark notification as read
  static Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking notification as read: $e');
      rethrow;
    }
  }

  // Delete notification
  static Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      print('Error deleting notification: $e');
      rethrow;
    }
  }

  // Get user notifications stream
  static Stream<QuerySnapshot> getUserNotificationsStream(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Get unread notification count
  static Future<int> getUnreadNotificationCount(String userId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print('Error getting unread notification count: $e');
      return 0;
    }
  }

  // Mark all notifications as read for a user
  static Future<void> markAllAsRead(String userId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final WriteBatch batch = _firestore.batch();

      for (QueryDocumentSnapshot doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      print('Error marking all notifications as read: $e');
      rethrow;
    }
  }

  // Create test notification for debugging
  static Future<void> createTestNotification({
    required String userId,
    String? rideRequestId,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'type': 'ride_request',
        'title': 'Test Ride Request',
        'message':
            'This is a test notification to verify the system is working properly.',
        'rideRequestId': rideRequestId ?? 'test_ride_123',
        'passengerName': 'Test Passenger',
        'passengerPhone': '+94701234567',
        'startLocation': 'Colombo',
        'endLocation': 'Anuradhapura',
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'icon': 'directions_car_outlined',
      });

      print('Test notification created successfully');
    } catch (e) {
      print('Error creating test notification: $e');
      rethrow;
    }
  }
}

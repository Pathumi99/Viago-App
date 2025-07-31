import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_service.dart';

class RideService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a ride request with notifications
  static Future<String?> createRideRequest({
    required String from,
    required String to,
    required String passengerName,
    required String passengerPhone,
    required String riderId,
    required DateTime departureDate,
    required TimeOfDay departureTime,
    required String vehicleType,
    double? startLat,
    double? startLng,
    double? endLat,
    double? endLng,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Create ride request document
      final rideRequestRef = await _firestore.collection('ride_requests').add({
        'passengerId': user.uid,
        'riderId': riderId,
        'passengerName': passengerName,
        'passengerPhone': passengerPhone,
        'startLocation': from,
        'endLocation': to,
        'startLat': startLat,
        'startLng': startLng,
        'endLat': endLat,
        'endLng': endLng,
        'departureDate': Timestamp.fromDate(departureDate),
        'departureTime':
            '${departureTime.hour}:${departureTime.minute.toString().padLeft(2, '0')}',
        'vehicleType': vehicleType,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Create notifications for both rider and passenger
      await NotificationService.createRideRequestNotification(
        rideRequestId: rideRequestRef.id,
        passengerId: user.uid,
        riderId: riderId,
        passengerName: passengerName,
        passengerPhone: passengerPhone,
        startLocation: from,
        endLocation: to,
      );

      print('Ride request created successfully with ID: ${rideRequestRef.id}');
      return rideRequestRef.id;
    } catch (e) {
      print('Error creating ride request: $e');
      rethrow;
    }
  }

  // Accept a ride request
  static Future<void> acceptRideRequest({
    required String rideRequestId,
    required String riderId,
  }) async {
    try {
      // Get ride request details
      final rideDoc =
          await _firestore.collection('ride_requests').doc(rideRequestId).get();

      if (!rideDoc.exists) {
        throw Exception('Ride request not found');
      }

      final rideData = rideDoc.data() as Map<String, dynamic>;
      final passengerId = rideData['passengerId'];

      // Update ride request status
      await _firestore.collection('ride_requests').doc(rideRequestId).update({
        'status': 'accepted',
        'riderId': riderId,
        'acceptedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update the rider's notification status for this ride request
      final riderNotifications = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: riderId)
          .where('rideRequestId', isEqualTo: rideRequestId)
          .where('type', isEqualTo: 'ride_request')
          .get();

      for (var notificationDoc in riderNotifications.docs) {
        await notificationDoc.reference.update({
          'status': 'accepted',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Get rider details
      final riderDoc = await _firestore.collection('users').doc(riderId).get();

      if (riderDoc.exists) {
        final riderData = riderDoc.data() as Map<String, dynamic>;

        // Create notification for passenger
        await NotificationService.createRideResponseNotification(
          rideRequestId: rideRequestId,
          passengerId: passengerId,
          riderId: riderId,
          riderName: riderData['name'] ?? 'Rider',
          riderPhone: riderData['phone'] ?? 'N/A',
          isAccepted: true,
        );
      }

      print('Ride request accepted successfully');
    } catch (e) {
      print('Error accepting ride request: $e');
      rethrow;
    }
  }

  // Reject a ride request
  static Future<void> rejectRideRequest({
    required String rideRequestId,
    required String riderId,
  }) async {
    try {
      // Get ride request details
      final rideDoc =
          await _firestore.collection('ride_requests').doc(rideRequestId).get();

      if (!rideDoc.exists) {
        throw Exception('Ride request not found');
      }

      final rideData = rideDoc.data() as Map<String, dynamic>;
      final passengerId = rideData['passengerId'];

      // Update ride request status
      await _firestore.collection('ride_requests').doc(rideRequestId).update({
        'status': 'rejected',
        'rejectedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update the rider's notification status for this ride request
      final riderNotifications = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: riderId)
          .where('rideRequestId', isEqualTo: rideRequestId)
          .where('type', isEqualTo: 'ride_request')
          .get();

      for (var notificationDoc in riderNotifications.docs) {
        await notificationDoc.reference.update({
          'status': 'rejected',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Get rider details
      final riderDoc = await _firestore.collection('users').doc(riderId).get();

      if (riderDoc.exists) {
        final riderData = riderDoc.data() as Map<String, dynamic>;

        // Create notification for passenger
        await NotificationService.createRideResponseNotification(
          rideRequestId: rideRequestId,
          passengerId: passengerId,
          riderId: riderId,
          riderName: riderData['name'] ?? 'Rider',
          riderPhone: riderData['phone'] ?? 'N/A',
          isAccepted: false,
        );
      }

      print('Ride request rejected successfully');
    } catch (e) {
      print('Error rejecting ride request: $e');
      rethrow;
    }
  }

  // Complete a ride
  static Future<void> completeRide({
    required String rideRequestId,
  }) async {
    try {
      // Get ride request details
      final rideDoc =
          await _firestore.collection('ride_requests').doc(rideRequestId).get();

      if (!rideDoc.exists) {
        throw Exception('Ride request not found');
      }

      final rideData = rideDoc.data() as Map<String, dynamic>;
      final passengerId = rideData['passengerId'];
      final riderId = rideData['riderId'];

      // Update ride request status
      await _firestore.collection('ride_requests').doc(rideRequestId).update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Create completion notifications
      await NotificationService.createRideCompletedNotification(
        rideRequestId: rideRequestId,
        passengerId: passengerId,
        riderId: riderId,
      );

      print('Ride completed successfully');
    } catch (e) {
      print('Error completing ride: $e');
      rethrow;
    }
  }

  // Get ride requests for a rider (to show in notifications)
  static Stream<QuerySnapshot> getRideRequestsForRider(String riderId) {
    return _firestore
        .collection('ride_requests')
        .where('riderId', isEqualTo: riderId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get ride history for a user
  static Stream<QuerySnapshot> getRideHistoryForUser(
      String userId, String userType) {
    final field = userType == 'rider' ? 'riderId' : 'passengerId';
    return _firestore
        .collection('ride_requests')
        .where(field, isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Cancel a ride request
  static Future<void> cancelRideRequest({
    required String rideRequestId,
    required String reason,
  }) async {
    try {
      await _firestore.collection('ride_requests').doc(rideRequestId).update({
        'status': 'cancelled',
        'cancellationReason': reason,
        'cancelledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Ride request cancelled successfully');
    } catch (e) {
      print('Error cancelling ride request: $e');
      rethrow;
    }
  }
}

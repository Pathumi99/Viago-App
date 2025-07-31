import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/ride_service.dart';
import 'rider_reviews_screen.dart';
import '../generated/app_localizations.dart';
import 'dart:math';

class MatchingRidersScreen extends StatelessWidget {
  final String from;
  final String to;
  final double? passengerStartLat;
  final double? passengerStartLng;
  final double? passengerEndLat;
  final double? passengerEndLng;
  final DateTime? departureDate;
  final TimeOfDay? departureTime;
  final String? vehicleType;

  const MatchingRidersScreen({
    super.key,
    required this.from,
    required this.to,
    this.passengerStartLat,
    this.passengerStartLng,
    this.passengerEndLat,
    this.passengerEndLng,
    this.departureDate,
    this.departureTime,
    this.vehicleType,
  });

  // Method to create sample data for testing (can be removed in production)
  Future<void> _createSampleRiderRoutes() async {
    final firestore = FirebaseFirestore.instance;

    // Sample rider routes
    final sampleRoutes = [
      {
        'riderId': 'rider1',
        'from': 'Colombo',
        'to': 'Kandy',
        'departureTime': '08:00 AM',
        'departureDate':
            Timestamp.fromDate(DateTime.now().add(Duration(days: 1))),
        'availableSeats': 3,
        'vehicleType': 'Car',
        'price': 1500.0,
        'notes': 'Comfortable sedan, AC available',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'riderId': 'rider2',
        'from': 'Galle',
        'to': 'Colombo',
        'departureTime': '06:30 AM',
        'departureDate':
            Timestamp.fromDate(DateTime.now().add(Duration(days: 1))),
        'availableSeats': 2,
        'vehicleType': 'Van',
        'price': 2000.0,
        'notes': 'Spacious van for families',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'riderId': 'rider3',
        'from': 'Negombo',
        'to': 'Gampaha',
        'departureTime': '07:15 AM',
        'departureDate':
            Timestamp.fromDate(DateTime.now().add(Duration(days: 1))),
        'availableSeats': 4,
        'vehicleType': 'Car',
        'price': 800.0,
        'notes': 'Quick route, experienced driver',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];

    // Sample users (riders)
    final sampleUsers = [
      {
        'name': 'John Silva',
        'phone': '+94771234567',
        'userType': 'rider',
        'vehicleType': 'Car',
        'averageRating': 4.5,
        'numRatings': 23,
      },
      {
        'name': 'Maria Perera',
        'phone': '+94762345678',
        'userType': 'rider',
        'vehicleType': 'Van',
        'averageRating': 4.8,
        'numRatings': 45,
      },
      {
        'name': 'Kasun Fernando',
        'phone': '+94753456789',
        'userType': 'rider',
        'vehicleType': 'Car',
        'averageRating': 4.2,
        'numRatings': 12,
      },
    ];

    // Sample passenger requests (to show complete flow)
    final samplePassengerRequests = [
      {
        'userId': 'passenger1',
        'from': 'Colombo Fort',
        'to': 'Kandy City',
        'contact': '+94701111111',
        'name': 'Saman Kumara',
        'startLat': 6.9320,
        'startLng': 79.8428,
        'endLat': 7.2906,
        'endLng': 80.6337,
        'timestamp': FieldValue.serverTimestamp(),
        'departureDate':
            Timestamp.fromDate(DateTime.now().add(Duration(days: 1))),
        'departureTime': '08:00 AM',
        'vehicleType': 'Car',
      },
      {
        'userId': 'passenger2',
        'from': 'Galle',
        'to': 'Colombo',
        'contact': '+94702222222',
        'name': 'Nimal Rathnayake',
        'startLat': 6.0329,
        'startLng': 80.2168,
        'endLat': 6.9271,
        'endLng': 79.8612,
        'timestamp': FieldValue.serverTimestamp(),
        'departureDate':
            Timestamp.fromDate(DateTime.now().add(Duration(days: 1))),
        'departureTime': '06:30 AM',
        'vehicleType': 'Van',
      },
    ];

    try {
      // Create sample users
      for (int i = 0; i < sampleUsers.length; i++) {
        await firestore
            .collection('users')
            .doc('rider${i + 1}')
            .set(sampleUsers[i]);
      }

      // Create sample routes
      for (var route in sampleRoutes) {
        await firestore.collection('rider_routes').add(route);
      }

      // Create sample passenger requests
      for (var request in samplePassengerRequests) {
        await firestore.collection('passenger_requests').add(request);
      }

      print('Sample data created successfully!');
      print('✅ Created ${sampleUsers.length} riders');
      print('✅ Created ${sampleRoutes.length} rider routes');
      print('✅ Created ${samplePassengerRequests.length} passenger requests');
    } catch (e) {
      print('Error creating sample data: $e');
    }
  }

  Future<void> _sendRideRequest(BuildContext context, String riderId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('You must be logged in!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                ),
                SizedBox(height: 16),
                Text(
                  'Sending request...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Get passenger details
      final passengerDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final passengerData = passengerDoc.data();
      final passengerName = passengerData?['name'] ?? 'A passenger';
      final passengerPhone = passengerData?['phone'] ?? 'N/A';

      // Create ride request using RideService (this will create notifications)
      final rideRequestId = await RideService.createRideRequest(
        from: from,
        to: to,
        passengerName: passengerName,
        passengerPhone: passengerPhone,
        riderId: riderId,
        departureDate:
            departureDate ?? DateTime.now().add(const Duration(hours: 1)),
        departureTime: departureTime ?? TimeOfDay.now(),
        vehicleType: vehicleType ?? 'Any',
        startLat: passengerStartLat,
        startLng: passengerStartLng,
        endLat: passengerEndLat,
        endLng: passengerEndLng,
      );

      // Hide loading dialog
      Navigator.of(context).pop();

      if (rideRequestId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Ride request sent successfully! 🚗',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        // Navigate back or to a confirmation screen
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Hide loading dialog if still showing
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Failed to send request: $e',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _viewRiderReviews(BuildContext context, String riderId, String riderName,
      double avgRating, int numRatings) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RiderReviewsScreen(
          riderId: riderId,
          riderName: riderName,
          averageRating: avgRating,
          totalReviews: numRatings,
        ),
      ),
    );
  }

  double haversine(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Earth radius in km
    final dLat = (lat2 - lat1) * 3.141592653589793 / 180;
    final dLon = (lon2 - lon1) * 3.141592653589793 / 180;
    final a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(lat1 * 3.141592653589793 / 180) *
            cos(lat2 * 3.141592653589793 / 180) *
            (sin(dLon / 2) * sin(dLon / 2));
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  List<DocumentSnapshot> filterByProximity(
    List<DocumentSnapshot> riders,
    double passengerStartLat,
    double passengerStartLng,
    double passengerEndLat,
    double passengerEndLng,
  ) {
    const double maxDistanceKm = 5.0;
    return riders.where((rider) {
      final startLat = rider['startLat'];
      final startLng = rider['startLng'];
      final endLat = rider['endLat'];
      final endLng = rider['endLng'];
      if (startLat == null ||
          startLng == null ||
          endLat == null ||
          endLng == null) {
        return false;
      }
      final startDist =
          haversine(passengerStartLat, passengerStartLng, startLat, startLng);
      final endDist =
          haversine(passengerEndLat, passengerEndLng, endLat, endLng);
      return startDist <= maxDistanceKm && endDist <= maxDistanceKm;
    }).toList();
  }

  List<DocumentSnapshot> filterByDateTime(
    List<DocumentSnapshot> riders,
    DateTime passengerDate,
    TimeOfDay passengerTime,
    int windowMinutes,
    BuildContext context,
  ) {
    return riders.where((rider) {
      final data = rider.data() as Map<String, dynamic>;
      final Timestamp? riderDateTs =
          data.containsKey('departureDate') ? data['departureDate'] : null;
      final String? riderTimeStr =
          data.containsKey('departureTime') ? data['departureTime'] : null;
      if (riderDateTs == null || riderTimeStr == null) return false;
      final DateTime riderDate = riderDateTs.toDate();
      // Compare only year, month, day
      if (riderDate.year != passengerDate.year ||
          riderDate.month != passengerDate.month ||
          riderDate.day != passengerDate.day) {
        return false;
      }
      // Parse rider time string to TimeOfDay
      final TimeOfDay? riderTime = _parseTimeOfDay(riderTimeStr, context);
      if (riderTime == null) return false;
      final int diff = _timeDifferenceInMinutes(passengerTime, riderTime);
      return diff.abs() <= windowMinutes;
    }).toList();
  }

  TimeOfDay? _parseTimeOfDay(String timeStr, BuildContext context) {
    // Supports 'hh:mm AM/PM' format
    final timeRegExp =
        RegExp(r'^(\d{1,2}):(\d{2}) ?([AP]M)?', caseSensitive: false);
    final match = timeRegExp.firstMatch(timeStr.trim());
    if (match != null) {
      int hour = int.parse(match.group(1)!);
      int minute = int.parse(match.group(2)!);
      final ampm = match.group(3)?.toUpperCase();
      if (ampm == 'PM' && hour < 12) hour += 12;
      if (ampm == 'AM' && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: minute);
    }
    return null;
  }

  int _timeDifferenceInMinutes(TimeOfDay t1, TimeOfDay t2) {
    final dt1 = Duration(hours: t1.hour, minutes: t1.minute);
    final dt2 = Duration(hours: t2.hour, minutes: t2.minute);
    return dt1.inMinutes - dt2.inMinutes;
  }

  String _getTimeMatchInfo(String riderTimeStr, BuildContext context) {
    if (departureTime == null) return riderTimeStr;

    final riderTime = _parseTimeOfDay(riderTimeStr, context);
    if (riderTime == null) return riderTimeStr;

    final diff = _timeDifferenceInMinutes(departureTime!, riderTime);
    final diffAbs = diff.abs();

    if (diffAbs == 0) {
      return '$riderTimeStr ✅ Exact Match';
    } else if (diffAbs <= 30) {
      final diffStr = diff > 0 ? '${diffAbs}m earlier' : '${diffAbs}m later';
      return '$riderTimeStr ⏰ $diffStr';
    } else {
      return riderTimeStr;
    }
  }

  Widget _buildMatchIndicator(String riderFrom, String riderTo,
      String riderVehicle, String riderTimeStr, BuildContext context) {
    List<Widget> matchIndicators = [];

    // Route match
    final fromMatch = riderFrom.toLowerCase().contains(from.toLowerCase()) ||
        from.toLowerCase().contains(riderFrom.toLowerCase());
    final toMatch = riderTo.toLowerCase().contains(to.toLowerCase()) ||
        to.toLowerCase().contains(riderTo.toLowerCase());

    if (fromMatch && toMatch) {
      matchIndicators.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.route, size: 12, color: Colors.green[700]),
              const SizedBox(width: 4),
              Text('Route Match',
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
    }

    // Vehicle match
    if (vehicleType != null &&
        riderVehicle.toLowerCase() == vehicleType!.toLowerCase()) {
      matchIndicators.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.directions_car, size: 12, color: Colors.blue[700]),
              const SizedBox(width: 4),
              Text('Vehicle Match',
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
    }

    // Time match
    if (departureTime != null) {
      final riderTime = _parseTimeOfDay(riderTimeStr, context);
      if (riderTime != null) {
        final diff = _timeDifferenceInMinutes(departureTime!, riderTime).abs();
        if (diff <= 30) {
          matchIndicators.add(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.access_time, size: 12, color: Colors.orange[700]),
                  const SizedBox(width: 4),
                  Text(diff == 0 ? 'Exact Time' : 'Time Match',
                      style: TextStyle(
                          fontSize: 10,
                          color: Colors.orange[700],
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          );
        }
      }
    }

    if (matchIndicators.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: matchIndicators,
      ),
    );
  }

  List<DocumentSnapshot> filterByVehicleType(
    List<DocumentSnapshot> riders,
    String vehicleType,
  ) {
    return riders.where((rider) {
      final String? riderVehicleType = rider['vehicleType'];
      return riderVehicleType != null && riderVehicleType == vehicleType;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.matchingRiders,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2563EB),
                Color(0xFF1D4ED8),
                Color(0xFF1E40AF),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2563EB),
                  Color(0xFF1D4ED8),
                  Color(0xFF1E40AF),
                ],
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.search,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${l10n.from}: $from',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${l10n.to}: $to',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                if (departureTime != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Time: ${departureTime!.format(context)} (±30 min)',
                                    style: const TextStyle(
                                      color: Colors.white60,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                                if (vehicleType != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Vehicle: $vehicleType',
                                    style: const TextStyle(
                                      color: Colors.white60,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content Section
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('rider_routes')
                  .where('isActive', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading riders: ${snapshot.error}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please try again later',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noMatchingRiders,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.adjustCriteria,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Test button to create sample data
                          ElevatedButton.icon(
                            onPressed: () async {
                              await _createSampleRiderRoutes();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      const Text('Sample riders created! 🚗'),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text(
                              'Create Sample Riders (Test)',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                List<DocumentSnapshot> allRoutes = snapshot.data!.docs;

                // Apply comprehensive filtering based on passenger criteria
                List<DocumentSnapshot> filteredRoutes = allRoutes;

                // 1. Filter by route (from/to locations)
                filteredRoutes = filteredRoutes.where((route) {
                  final routeData = route.data() as Map<String, dynamic>;
                  final riderFrom =
                      (routeData['from'] ?? '').toString().toLowerCase();
                  final riderTo =
                      (routeData['to'] ?? '').toString().toLowerCase();
                  final passengerFrom = from.toLowerCase();
                  final passengerTo = to.toLowerCase();

                  // Check if routes match (exact or similar)
                  return riderFrom.contains(passengerFrom) ||
                      passengerFrom.contains(riderFrom) ||
                      riderTo.contains(passengerTo) ||
                      passengerTo.contains(riderTo);
                }).toList();

                // 2. Filter by vehicle type if specified
                if (vehicleType != null && vehicleType!.isNotEmpty) {
                  filteredRoutes =
                      filterByVehicleType(filteredRoutes, vehicleType!);
                }

                // 3. Filter by date and time with ±30 minute tolerance
                if (departureDate != null && departureTime != null) {
                  filteredRoutes = filterByDateTime(filteredRoutes,
                      departureDate!, departureTime!, 30, context);
                }

                // 4. Filter by location proximity if coordinates are available
                if (passengerStartLat != null &&
                    passengerStartLng != null &&
                    passengerEndLat != null &&
                    passengerEndLng != null) {
                  filteredRoutes = filterByProximity(
                      filteredRoutes,
                      passengerStartLat!,
                      passengerStartLng!,
                      passengerEndLat!,
                      passengerEndLng!);
                }

                // Show message if no matching riders found
                if (filteredRoutes.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Matching Riders Found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No riders match your route, time, and vehicle preferences.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Your Search Criteria:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Route: $from → $to',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[600]),
                                ),
                                if (vehicleType != null)
                                  Text(
                                    'Vehicle: $vehicleType',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey[600]),
                                  ),
                                if (departureDate != null &&
                                    departureTime != null)
                                  Text(
                                    'Time: ${departureTime!.format(context)} (±30 min)',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey[600]),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: filteredRoutes.length,
                  itemBuilder: (context, index) {
                    final route = filteredRoutes[index];
                    final routeData = route.data() as Map<String, dynamic>;
                    final riderId = routeData['riderId'] ?? '';

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(riderId)
                          .get(),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return const SizedBox.shrink();
                        }

                        final userData =
                            userSnapshot.data!.data() as Map<String, dynamic>?;
                        if (userData == null) {
                          return const SizedBox.shrink();
                        }

                        final riderName = userData['name'] ?? 'Unknown Rider';
                        final riderPhone = userData['phone'] ?? 'N/A';
                        final vehicleType = userData['vehicleType'] ??
                            routeData['vehicleType'] ??
                            'Car';
                        final avgRating =
                            (userData['averageRating'] ?? 5.0).toDouble();
                        final numRatings = userData['numRatings'] ?? 0;

                        // Route information
                        final fromLocation = routeData['from'] ?? 'Unknown';
                        final toLocation = routeData['to'] ?? 'Unknown';
                        final departureTime =
                            routeData['departureTime'] ?? 'Not specified';
                        final availableSeats = routeData['availableSeats'] ?? 1;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Rider Header
                                Row(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2563EB),
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            riderName,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '$avgRating ($numRatings)',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2563EB)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        vehicleType,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF2563EB),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Match Indicators
                                _buildMatchIndicator(fromLocation, toLocation,
                                    vehicleType, departureTime, context),

                                // Route Information
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            color: Colors.green,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'From: $fromLocation',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            color: Colors.red,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'To: $toLocation',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            color: Colors.blue,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Time: ${_getTimeMatchInfo(departureTime, context)}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.airline_seat_recline_normal,
                                            color: Colors.orange,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '$availableSeats seats available',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          if (departureDate != null) ...[
                                            const Spacer(),
                                            Icon(
                                              Icons.calendar_today,
                                              color: Colors.purple,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${departureDate!.day}/${departureDate!.month}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Contact Info
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.phone,
                                        color: Colors.blue[600],
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        riderPhone,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.blue[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Action Buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => _viewRiderReviews(
                                          context,
                                          riderId,
                                          riderName,
                                          avgRating,
                                          numRatings,
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor:
                                              const Color(0xFF2563EB),
                                          side: const BorderSide(
                                            color: Color(0xFF2563EB),
                                            width: 1,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                        ),
                                        icon: const Icon(Icons.star_outline,
                                            size: 18),
                                        label: Text(
                                          l10n.reviews,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () =>
                                            _sendRideRequest(context, riderId),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF2563EB),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                        ),
                                        icon: const Icon(Icons.send, size: 18),
                                        label: Text(
                                          l10n.sendRequest,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

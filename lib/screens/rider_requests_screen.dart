import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/ride_service.dart';
import '../generated/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'message_screen.dart';

class RiderRequestsScreen extends StatefulWidget {
  const RiderRequestsScreen({super.key});

  @override
  State<RiderRequestsScreen> createState() => _RiderRequestsScreenState();
}

class _RiderRequestsScreenState extends State<RiderRequestsScreen> {
  User? _user;
  bool _loading = true;
  Stream<QuerySnapshot>? _requestsStream;
  final Map<String, String> _processingActions =
      <String, String>{}; // Track specific actions being processed
  final Map<String, String> _optimisticStatusUpdates =
      <String, String>{}; // Local status overrides

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  void _initializeUser() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        _user = currentUser;
        _loading = false;
      });
      // Initialize stream after setting user
      _initializeStream();
    } else {
      // Wait for auth state change
      FirebaseAuth.instance.authStateChanges().listen((user) {
        if (mounted && user != null) {
          setState(() {
            _user = user;
            _loading = false;
          });
          _initializeStream();
        }
      });
    }
  }

  void _initializeStream() {
    if (_user != null && mounted) {
      _createResilientStream();
    }
  }

  void _createResilientStream() {
    try {
      // Try with orderBy first
      _requestsStream = FirebaseFirestore.instance
          .collection('ride_requests')
          .where('riderId', isEqualTo: _user!.uid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .handleError((error) {
        print('Stream error handled: $error');
        // Don't throw the error, just log it
        return null;
      });

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error with orderBy, trying without: $e');
      // Fallback without orderBy
      if (mounted) {
        _requestsStream = FirebaseFirestore.instance
            .collection('ride_requests')
            .where('riderId', isEqualTo: _user!.uid)
            .snapshots()
            .handleError((error) {
          print('Fallback stream error handled: $error');
          return null;
        });
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_loading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF2563EB),
                Color(0xFF1D4ED8),
              ],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      );
    }
    if (_user == null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF2563EB),
                Color(0xFF1D4ED8),
              ],
            ),
          ),
          child: const Center(
            child: Text(
              'You must be logged in!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }
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
          l10n.incomingRideRequests,
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
                              Icons.inbox,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.manageRequests,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
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
            child: _requestsStream == null
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                    ),
                  )
                : StreamBuilder<QuerySnapshot>(
                    stream: _requestsStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF2563EB)),
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
                                  'Error loading requests',
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
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Main illustration icon
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2563EB)
                                        .withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.inbox_outlined,
                                    size: 64,
                                    color: const Color(0xFF2563EB),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Main title
                                Text(
                                  'No Ride Requests Yet',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),

                                // Description
                                Text(
                                  'When passengers request rides from you, they\'ll appear here. You can accept or reject requests based on your availability.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),

                                // Tips section
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.blue.shade100,
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.lightbulb_outline,
                                            color: Colors.blue.shade600,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Tips to get more requests:',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.blue.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '• Post rides on popular routes\n• Keep your profile updated\n• Maintain good ratings',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.blue.shade600,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final requests = snapshot.data!.docs;

                      // Clean up optimistic updates that match real data
                      for (var request in requests) {
                        final requestId = request.id;
                        final realStatus =
                            (request.data() as Map<String, dynamic>)['status'];
                        if (_optimisticStatusUpdates.containsKey(requestId) &&
                            _optimisticStatusUpdates[requestId] == realStatus) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() {
                                _optimisticStatusUpdates.remove(requestId);
                              });
                            }
                          });
                        }
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: requests.length,
                        itemBuilder: (context, index) {
                          final request = requests[index];
                          final data = request.data() as Map<String, dynamic>;
                          // Use optimistic status if available, otherwise use real status
                          final status = _optimisticStatusUpdates[request.id] ??
                              data['status'] ??
                              'pending';
                          final startLocation =
                              data['startLocation'] ?? 'Unknown';
                          final endLocation = data['endLocation'] ?? 'Unknown';
                          final passengerName =
                              data['passengerName'] ?? 'Unknown';
                          final passengerPhone =
                              data['passengerPhone'] ?? 'N/A';
                          final createdAt = data['createdAt'] as Timestamp?;

                          // Check which specific action is being processed
                          final isProcessingReject =
                              _processingActions[request.id] == 'rejected';
                          final isProcessingAccept =
                              _processingActions[request.id] == 'accepted';
                          final isProcessing =
                              _processingActions.containsKey(request.id);

                          return Dismissible(
                            key: Key(request.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              await _showDeleteConfirmDialog(
                                  request.id, passengerName);
                              return false; // We handle deletion in the dialog
                            },
                            child: Container(
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
                                    // Request Header
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF2563EB)
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Icon(
                                                Icons.directions_car,
                                                color: Color(0xFF2563EB),
                                                size: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              l10n.rideRequest,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(status)
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color: _getStatusColor(status)
                                                  .withOpacity(0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            _getStatusText(status, l10n),
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: _getStatusColor(status),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 16),

                                    // Passenger Details with enhanced styling
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Passenger info header
                                          Row(
                                            children: [
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFF2563EB),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: const Icon(
                                                  Icons.person,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                l10n.passengerDetails,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          _buildDetailRow(
                                              l10n.name, passengerName),
                                          const SizedBox(height: 8),
                                          _buildDetailRow(
                                              l10n.contact, passengerPhone),
                                          const SizedBox(height: 8),
                                          _buildDetailRow(
                                              l10n.from, startLocation),
                                          const SizedBox(height: 8),
                                          _buildDetailRow(l10n.to, endLocation),
                                          if (createdAt != null) ...[
                                            const SizedBox(height: 8),
                                            _buildDetailRow(l10n.requested,
                                                _formatTimestamp(createdAt)),
                                          ],
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    // Communication Buttons
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () =>
                                                _makePhoneCall(passengerPhone),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor:
                                                  Color(0xFF2563EB),
                                              side: BorderSide(
                                                color: Color(0xFF2563EB),
                                                width: 1,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 12),
                                            ),
                                            icon: Icon(Icons.phone, size: 18),
                                            label: Text(
                                              'Call',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              // Get passenger ID from the request data
                                              final passengerId =
                                                  data['passengerId'];
                                              if (passengerId != null) {
                                                _openMessageScreen(
                                                  passengerId,
                                                  passengerName,
                                                  passengerPhone,
                                                );
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Color(0xFF2563EB),
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 12),
                                            ),
                                            icon: Icon(Icons.message, size: 18),
                                            label: Text(
                                              'Message',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 16),

                                    // Action Buttons (only for pending requests)
                                    if (status == 'pending')
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: isProcessing
                                                  ? null
                                                  : () => _handleRequest(
                                                      context,
                                                      request.id,
                                                      'rejected'),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: Colors.red,
                                                side: const BorderSide(
                                                    color: Colors.red,
                                                    width: 1),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12),
                                              ),
                                              icon: isProcessingReject
                                                  ? SizedBox(
                                                      width: 18,
                                                      height: 18,
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                                    Color>(
                                                                Colors.red),
                                                      ),
                                                    )
                                                  : const Icon(Icons.close,
                                                      size: 18),
                                              label: Text(
                                                l10n.reject,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: isProcessing
                                                  ? null
                                                  : () => _handleRequest(
                                                      context,
                                                      request.id,
                                                      'accepted'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xFF2563EB),
                                                foregroundColor: Colors.white,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12),
                                              ),
                                              icon: isProcessingAccept
                                                  ? SizedBox(
                                                      width: 18,
                                                      height: 18,
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                                    Color>(
                                                                Colors.white),
                                                      ),
                                                    )
                                                  : const Icon(Icons.check,
                                                      size: 18),
                                              label: Text(
                                                l10n.accept,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    else
                                      // Add delete button for non-pending requests
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: () =>
                                                  _showDeleteConfirmDialog(
                                                      request.id,
                                                      passengerName),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: Colors.red,
                                                side: const BorderSide(
                                                    color: Colors.red,
                                                    width: 1),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12),
                                              ),
                                              icon: const Icon(
                                                  Icons.delete_outline,
                                                  size: 18),
                                              label: const Text(
                                                'Delete Request',
                                                style: TextStyle(
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
                            ),
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

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  String _getStatusText(String status, AppLocalizations l10n) {
    switch (status) {
      case 'accepted':
        return l10n.accepted;
      case 'rejected':
        return l10n.rejected;
      case 'pending':
      default:
        return l10n.pending;
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _handleRequest(
      BuildContext context, String requestId, String newStatus) async {
    // Prevent multiple simultaneous requests for the same ID
    if (_processingActions.containsKey(requestId)) {
      return;
    }

    try {
      // Add to processing map and immediately update local status
      setState(() {
        _processingActions[requestId] =
            newStatus; // Track which action is being processed
        _optimisticStatusUpdates[requestId] =
            newStatus; // Immediate status update
      });

      // Show immediate loading state
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Text(newStatus == 'accepted'
                  ? 'Accepting request...'
                  : 'Rejecting request...'),
            ],
          ),
          backgroundColor:
              newStatus == 'accepted' ? Colors.orange : Colors.grey,
          duration:
              Duration(seconds: 3), // Will be replaced by success/error message
        ),
      );

      // Update Firestore
      if (newStatus == 'accepted') {
        await RideService.acceptRideRequest(
          rideRequestId: requestId,
          riderId: _user!.uid,
        );
      } else {
        await RideService.rejectRideRequest(
          rideRequestId: requestId,
          riderId: _user!.uid,
        );
      }

      // Show success message
      if (mounted) {
        // Clear the loading snackbar
        ScaffoldMessenger.of(context).clearSnackBars();

        final l10n = AppLocalizations.of(context)!;
        String message;
        if (newStatus == 'accepted') {
          message = l10n.requestAccepted;
        } else {
          message = l10n.requestRejected;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  newStatus == 'accepted' ? Icons.check_circle : Icons.cancel,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(message)),
              ],
            ),
            backgroundColor:
                newStatus == 'accepted' ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Clear the loading snackbar
        ScaffoldMessenger.of(context).clearSnackBars();

        // Remove optimistic update on error
        setState(() {
          _optimisticStatusUpdates.remove(requestId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error updating request: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } finally {
      // Remove from processing map and keep optimistic update
      if (mounted) {
        setState(() {
          _processingActions.remove(requestId);
          // Keep the optimistic status update until stream provides real data
        });
      }
    }
  }

  Future<void> _deleteRequest(String requestId) async {
    try {
      // Delete from Firestore
      await FirebaseFirestore.instance
          .collection('ride_requests')
          .doc(requestId)
          .delete();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                const Text(
                  'Request deleted successfully',
                  style: TextStyle(fontWeight: FontWeight.w500),
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
      }
    } catch (e) {
      print('Error deleting request: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  'Failed to delete request: $e',
                  style: const TextStyle(fontWeight: FontWeight.w500),
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
  }

  Future<void> _showDeleteConfirmDialog(
      String requestId, String passengerName) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_outlined,
                color: Colors.orange[600],
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text('Delete Request'),
            ],
          ),
          content: Text(
            'Are you sure you want to delete the ride request from $passengerName? This action cannot be undone.',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteRequest(requestId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper method to make phone calls
  Future<void> _makePhoneCall(String phoneNumber) async {
    // Clean the phone number (remove spaces, dashes, etc.)
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    final Uri launchUri = Uri(
      scheme: 'tel',
      path: cleanNumber,
    );

    try {
      // First try to check if we can launch
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(
          launchUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Fallback: try with different launch mode
        await launchUrl(
          launchUri,
          mode: LaunchMode.platformDefault,
        );
      }
    } catch (e) {
      if (mounted) {
        // Show the actual phone number that users can dial manually
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info, color: Colors.white),
                    SizedBox(width: 12),
                    Text('Please dial manually:'),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    SizedBox(width: 36),
                    Expanded(
                      child: Text(
                        cleanNumber,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.copy, color: Colors.white),
                      onPressed: () async {
                        try {
                          await Clipboard.setData(
                              ClipboardData(text: cleanNumber));
                          // Hide the current snackbar first
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          // Show a new success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  SizedBox(width: 12),
                                  Text('Phone number copied: $cleanNumber'),
                                ],
                              ),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 3),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.error, color: Colors.white),
                                  SizedBox(width: 12),
                                  Text('Failed to copy: $cleanNumber'),
                                ],
                              ),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 3),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Close',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    }
  }

  // Helper method to open message screen
  void _openMessageScreen(String userId, String userName, String userPhone) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessageScreen(
          chatWithUserId: userId,
          chatWithUserName: userName,
          chatWithUserPhone: userPhone,
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up any listeners
    super.dispose();
  }
}

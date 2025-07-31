import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'matching_riders_screen.dart';

class PassengerMapScreen extends StatefulWidget {
  final String from;
  final String to;
  final String contact;
  final String name;
  final DateTime? departureDate;
  final TimeOfDay? departureTime;
  final String? vehicleType;

  const PassengerMapScreen({
    super.key,
    required this.from,
    required this.to,
    required this.contact,
    required this.name,
    this.departureDate,
    this.departureTime,
    this.vehicleType,
  });

  @override
  State<PassengerMapScreen> createState() => _PassengerMapScreenState();
}

class _PassengerMapScreenState extends State<PassengerMapScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _isLoading = true;
  LatLng? _startPoint;
  LatLng? _endPoint;
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  // Comprehensive Sri Lankan locations with coordinates
  final List<Map<String, dynamic>> _popularLocations = [
    // Western Province
    {'name': 'Colombo', 'lat': 6.9271, 'lon': 79.8612},
    {'name': 'Gampaha', 'lat': 7.0873, 'lon': 79.9990},
    {'name': 'Kalutara', 'lat': 6.5854, 'lon': 79.9607},
    {'name': 'Negombo', 'lat': 7.2086, 'lon': 79.8357},
    {'name': 'Panadura', 'lat': 6.7132, 'lon': 79.9026},
    {'name': 'Horana', 'lat': 6.7154, 'lon': 80.0630},
    {'name': 'Moratuwa', 'lat': 6.7730, 'lon': 79.8816},
    {'name': 'Dehiwala', 'lat': 6.8510, 'lon': 79.8630},
    {'name': 'Mount Lavinia', 'lat': 6.8383, 'lon': 79.8653},
    {'name': 'Ratmalana', 'lat': 6.8210, 'lon': 79.8866},
    {'name': 'Kelaniya', 'lat': 6.9553, 'lon': 79.9216},
    {'name': 'Peliyagoda', 'lat': 6.9678, 'lon': 79.8890},
    {'name': 'Wattala', 'lat': 6.9890, 'lon': 79.8916},
    {'name': 'Ja-Ela', 'lat': 7.0747, 'lon': 79.8917},
    {'name': 'Kadawatha', 'lat': 7.0006, 'lon': 79.9475},
    {'name': 'Ragama', 'lat': 7.0267, 'lon': 79.9167},
    {'name': 'Kiribathgoda', 'lat': 6.9805, 'lon': 79.9292},
    {'name': 'Maharagama', 'lat': 6.8480, 'lon': 79.9286},
    {'name': 'Homagama', 'lat': 6.8444, 'lon': 80.0022},
    {'name': 'Piliyandala', 'lat': 6.8016, 'lon': 79.9225},
    {'name': 'Kaduwela', 'lat': 6.9333, 'lon': 79.9833},
    {'name': 'Kotte', 'lat': 6.8905, 'lon': 79.9017},
    {'name': 'Kollupitiya', 'lat': 6.9147, 'lon': 79.8560},
    {'name': 'Bambalapitiya', 'lat': 6.8947, 'lon': 79.8560},
    {'name': 'Wellawatta', 'lat': 6.8747, 'lon': 79.8560},
    {'name': 'Borella', 'lat': 6.9147, 'lon': 79.8760},
    {'name': 'Maradana', 'lat': 6.9278, 'lon': 79.8606},
    {'name': 'Pettah', 'lat': 6.9388, 'lon': 79.8542},
    {'name': 'Fort', 'lat': 6.9344, 'lon': 79.8428},

    // Central Province
    {'name': 'Kandy', 'lat': 7.2906, 'lon': 80.6337},
    {'name': 'Matale', 'lat': 7.4675, 'lon': 80.6234},
    {'name': 'Nuwara Eliya', 'lat': 6.9497, 'lon': 80.7891},
    {'name': 'Peradeniya', 'lat': 7.2594, 'lon': 80.5972},
    {'name': 'Gampola', 'lat': 7.1644, 'lon': 80.5744},
    {'name': 'Nawalapitiya', 'lat': 7.0544, 'lon': 80.5344},
    {'name': 'Hatton', 'lat': 6.8944, 'lon': 80.5944},
    {'name': 'Dimbula', 'lat': 6.8544, 'lon': 80.5544},
    {'name': 'Talawakele', 'lat': 6.9344, 'lon': 80.6544},
    {'name': 'Nanu Oya', 'lat': 6.9444, 'lon': 80.7544},
    {'name': 'Haputale', 'lat': 6.7694, 'lon': 80.9594},
    {'name': 'Bandarawela', 'lat': 6.8294, 'lon': 80.9894},
    {'name': 'Ella', 'lat': 6.8694, 'lon': 81.0494},
    {'name': 'Welimada', 'lat': 6.9094, 'lon': 80.9094},
    {'name': 'Badulla', 'lat': 6.9894, 'lon': 81.0594},
    {'name': 'Mahiyanganaya', 'lat': 7.3294, 'lon': 81.0094},
    {'name': 'Passara', 'lat': 7.0594, 'lon': 81.1094},
    {'name': 'Hali Ela', 'lat': 6.9594, 'lon': 81.0794},
    {'name': 'Katugastota', 'lat': 7.3394, 'lon': 80.6294},
    {'name': 'Akurana', 'lat': 7.3694, 'lon': 80.6494},
    {'name': 'Kadugannawa', 'lat': 7.2494, 'lon': 80.5294},
    {'name': 'Pilimathalawa', 'lat': 7.2794, 'lon': 80.6794},
    {'name': 'Kundasale', 'lat': 7.2894, 'lon': 80.6994},
    {'name': 'Digana', 'lat': 7.2594, 'lon': 80.7194},
    {'name': 'Teldeniya', 'lat': 7.3094, 'lon': 80.7794},
    {'name': 'Hasalaka', 'lat': 7.4094, 'lon': 80.7594},
    {'name': 'Panvila', 'lat': 7.3594, 'lon': 80.7394},
    {'name': 'Wattegama', 'lat': 7.3794, 'lon': 80.7094},
    {'name': 'Dambulla', 'lat': 7.8603, 'lon': 80.6517},
    {'name': 'Sigiriya', 'lat': 7.9603, 'lon': 80.7517},
    {'name': 'Galewela', 'lat': 7.7503, 'lon': 80.5517},
    {'name': 'Ukuwela', 'lat': 7.6503, 'lon': 80.5717},
    {'name': 'Rattota', 'lat': 7.5503, 'lon': 80.5917},

    // Southern Province
    {'name': 'Galle', 'lat': 6.0535, 'lon': 80.2210},
    {'name': 'Matara', 'lat': 5.9497, 'lon': 80.5353},
    {'name': 'Hambantota', 'lat': 6.1241, 'lon': 81.1185},
    {'name': 'Tangalle', 'lat': 6.0241, 'lon': 80.7985},
    {'name': 'Weligama', 'lat': 5.9741, 'lon': 80.4285},
    {'name': 'Mirissa', 'lat': 5.9441, 'lon': 80.4585},
    {'name': 'Unawatuna', 'lat': 6.0141, 'lon': 80.2485},
    {'name': 'Koggala', 'lat': 5.9941, 'lon': 80.3285},
    {'name': 'Ahangama', 'lat': 5.9641, 'lon': 80.3685},
    {'name': 'Midigama', 'lat': 5.9541, 'lon': 80.3885},

    // Northern Province
    {'name': 'Jaffna', 'lat': 9.6615, 'lon': 80.0255},
    {'name': 'Vavuniya', 'lat': 8.7514, 'lon': 80.4971},
    {'name': 'Mannar', 'lat': 8.9814, 'lon': 79.9171},
    {'name': 'Kilinochchi', 'lat': 9.3814, 'lon': 80.4071},
    {'name': 'Mullaitivu', 'lat': 9.2714, 'lon': 80.8171},

    // Eastern Province
    {'name': 'Trincomalee', 'lat': 8.5874, 'lon': 81.2152},
    {'name': 'Batticaloa', 'lat': 7.7167, 'lon': 81.7000},
    {'name': 'Ampara', 'lat': 7.2967, 'lon': 81.6800},
    {'name': 'Kalmunai', 'lat': 7.4167, 'lon': 81.8200},
    {'name': 'Akkaraipattu', 'lat': 7.2167, 'lon': 81.8500},
    {'name': 'Sammanthurai', 'lat': 7.3767, 'lon': 81.8300},
    {'name': 'Pottuvil', 'lat': 6.8767, 'lon': 81.8300},
    {'name': 'Arugam Bay', 'lat': 6.8467, 'lon': 81.8400},
    {'name': 'Monaragala', 'lat': 6.8717, 'lon': 81.3502},
    {'name': 'Wellawaya', 'lat': 6.7317, 'lon': 81.1002},
    {'name': 'Buttala', 'lat': 6.7517, 'lon': 81.2302},
    {'name': 'Polonnaruwa', 'lat': 7.9403, 'lon': 81.0017},

    // North Western Province
    {'name': 'Kurunegala', 'lat': 7.4818, 'lon': 80.3609},
    {'name': 'Puttalam', 'lat': 8.0362, 'lon': 79.8283},
    {'name': 'Chilaw', 'lat': 7.5762, 'lon': 79.7983},
    {'name': 'Wariyapola', 'lat': 7.6818, 'lon': 80.2309},
    {'name': 'Kuliyapitiya', 'lat': 7.4618, 'lon': 80.0409},

    // North Central Province
    {'name': 'Anuradhapura', 'lat': 8.3114, 'lon': 80.4037},
    {'name': 'Mihintale', 'lat': 8.3514, 'lon': 80.5037},
    {'name': 'Kekirawa', 'lat': 8.0314, 'lon': 80.5937},

    // Sabaragamuwa Province
    {'name': 'Ratnapura', 'lat': 6.6844, 'lon': 80.3996},
    {'name': 'Kegalle', 'lat': 7.2544, 'lon': 80.3496},
    {'name': 'Balangoda', 'lat': 6.6544, 'lon': 80.6996},
    {'name': 'Rakwana', 'lat': 6.4844, 'lon': 80.5996},
    {'name': 'Pelmadulla', 'lat': 6.6144, 'lon': 80.5396},
    {'name': 'Kuruwita', 'lat': 6.5844, 'lon': 80.3696},
    {'name': 'Godakawela', 'lat': 6.5544, 'lon': 80.6196},
    {'name': 'Kalawana', 'lat': 6.4644, 'lon': 80.4096},
    {'name': 'Kolonna', 'lat': 6.6344, 'lon': 80.2796},
    {'name': 'Eheliyagoda', 'lat': 6.8444, 'lon': 80.2696},
    {'name': 'Avissawella', 'lat': 6.9544, 'lon': 80.2096},
    {'name': 'Yatiyantota', 'lat': 6.9844, 'lon': 80.3296},
    {'name': 'Deraniyagala', 'lat': 6.9244, 'lon': 80.3496},
    {'name': 'Kitulgala', 'lat': 6.9944, 'lon': 80.4196},
    {'name': 'Ruwanwella', 'lat': 7.0644, 'lon': 80.2596},
    {'name': 'Warakapola', 'lat': 7.2244, 'lon': 80.1996},
    {'name': 'Mawanella', 'lat': 7.2544, 'lon': 80.4596},
    {'name': 'Rambukkana', 'lat': 7.3244, 'lon': 80.3896},
  ];

  @override
  void initState() {
    super.initState();
    _fromController.text = widget.from;
    _toController.text = widget.to;
    _initializeLocations();
  }

  Future<void> _initializeLocations() async {
    setState(() => _isLoading = true);

    try {
      final from = _fromController.text;
      final to = _toController.text;

      // Find coordinates for from location
      if (from.isNotEmpty) {
        final fromResponse = await http.get(Uri.parse(
            'https://nominatim.openstreetmap.org/search?format=json&q=$from&countrycodes=lk&limit=1'));
        if (fromResponse.statusCode == 200) {
          final List<dynamic> fromData = json.decode(fromResponse.body);
          if (fromData.isNotEmpty) {
            _startPoint = LatLng(
              double.parse(fromData[0]['lat']),
              double.parse(fromData[0]['lon']),
            );
            _addMarker(_startPoint!, 'Start');
          }
        }
      }

      // Find coordinates for to location
      if (to.isNotEmpty) {
        final toResponse = await http.get(Uri.parse(
            'https://nominatim.openstreetmap.org/search?format=json&q=$to&countrycodes=lk&limit=1'));
        if (toResponse.statusCode == 200) {
          final List<dynamic> toData = json.decode(toResponse.body);
          if (toData.isNotEmpty) {
            _endPoint = LatLng(
              double.parse(toData[0]['lat']),
              double.parse(toData[0]['lon']),
            );
            _addMarker(_endPoint!, 'End');
          }
        }
      }

      // Get route between points
      if (_startPoint != null && _endPoint != null) {
        await _getRoute(_startPoint!, _endPoint!);
      }
    } catch (e) {
      print('Error initializing locations: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addMarker(LatLng position, String title) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(title),
          position: position,
          infoWindow: InfoWindow(title: title),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            title == 'Start'
                ? BitmapDescriptor.hueRed
                : BitmapDescriptor.hueGreen,
          ),
        ),
      );
    });
  }

  Future<void> _getRoute(LatLng start, LatLng end) async {
    try {
      final response = await http.get(Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson',
      ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> coordinates =
            data['routes'][0]['geometry']['coordinates'];

        setState(() {
          _polylines.add(
            Polyline(
              polylineId: const PolylineId('route'),
              points: coordinates
                  .map((coord) => LatLng(coord[1], coord[0]))
                  .toList(),
              color: const Color(0xFF2563EB),
              width: 5,
            ),
          );
        });

        // Fit bounds to show the entire route
        final bounds = _getBounds(_markers);
        _mapController.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 50),
        );
      }
    } catch (e) {
      print('Error getting route: $e');
    }
  }

  LatLngBounds _getBounds(Set<Marker> markers) {
    if (markers.isEmpty) {
      return LatLngBounds(
        southwest: const LatLng(0, 0),
        northeast: const LatLng(0, 0),
      );
    }

    double minLat = 90;
    double maxLat = -90;
    double minLng = 180;
    double maxLng = -180;

    for (var marker in markers) {
      final lat = marker.position.latitude;
      final lng = marker.position.longitude;

      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lng < minLng) minLng = lng;
      if (lng > maxLng) maxLng = lng;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  Future<void> _savePassengerRequest() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in!')),
      );
      return;
    }
    try {
      await FirebaseFirestore.instance.collection('passenger_requests').add({
        'userId': user.uid,
        'from': _fromController.text,
        'to': _toController.text,
        'contact': widget.contact,
        'name': widget.name,
        'startLat': _startPoint?.latitude,
        'startLng': _startPoint?.longitude,
        'endLat': _endPoint?.latitude,
        'endLng': _endPoint?.longitude,
        'timestamp': FieldValue.serverTimestamp(),
        'departureDate': widget.departureDate != null
            ? Timestamp.fromDate(widget.departureDate!)
            : null,
        'departureTime': widget.departureTime?.format(context),
        'vehicleType': widget.vehicleType,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request saved!')),
      );
      // Navigate to matching riders screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MatchingRidersScreen(
            from: _fromController.text,
            to: _toController.text,
            passengerStartLat: _startPoint?.latitude,
            passengerStartLng: _startPoint?.longitude,
            passengerEndLat: _endPoint?.latitude,
            passengerEndLng: _endPoint?.longitude,
            departureDate: widget.departureDate,
            departureTime: widget.departureTime,
            vehicleType: widget.vehicleType,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save request: $e')),
      );
    }
  }

  void _showLocationSuggestions(bool isFrom) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        String query = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredLocations = _popularLocations
                .where((location) =>
                    query.isEmpty ||
                    location['name']
                        .toString()
                        .toLowerCase()
                        .startsWith(query.toLowerCase()))
                .toList();
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: isFrom
                          ? 'Search pickup location'
                          : 'Search destination',
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setModalState(() {
                        query = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.3,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredLocations.length,
                      itemBuilder: (context, index) {
                        final location = filteredLocations[index];
                        return ListTile(
                          title: Text(location['name']),
                          onTap: () {
                            if (isFrom) {
                              _fromController.text = location['name'];
                              _startPoint = LatLng(
                                location['lat'],
                                location['lon'],
                              );
                              _addMarker(_startPoint!, 'Start');
                            } else {
                              _toController.text = location['name'];
                              _endPoint = LatLng(
                                location['lat'],
                                location['lon'],
                              );
                              _addMarker(_endPoint!, 'End');
                            }
                            if (_startPoint != null && _endPoint != null) {
                              _getRoute(_startPoint!, _endPoint!);
                            }
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        title: const Text(
          'Your Selected Route',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _fromController,
                        decoration: InputDecoration(
                          hintText: 'From',
                          prefixIcon: const Icon(Icons.location_on),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () => _showLocationSuggestions(true),
                          ),
                        ),
                        readOnly: true,
                        onTap: () => _showLocationSuggestions(true),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _toController,
                        decoration: InputDecoration(
                          hintText: 'To',
                          prefixIcon: const Icon(Icons.location_on),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () => _showLocationSuggestions(false),
                          ),
                        ),
                        readOnly: true,
                        onTap: () => _showLocationSuggestions(false),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _startPoint ??
                          const LatLng(7.8731, 80.7718), // Center of Sri Lanka
                      zoom: 7,
                    ),
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                    markers: _markers,
                    polylines: _polylines,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: true,
                    mapToolbarEnabled: true,
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _savePassengerRequest();
        },
        backgroundColor: const Color(0xFF2563EB),
        child: const Icon(Icons.check),
      ),
    );
  }
}

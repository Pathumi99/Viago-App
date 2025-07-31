import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'matching_riders_screen.dart';

class MapScreen extends StatefulWidget {
  final String from;
  final String to;
  final String contact;
  final String name;
  final DateTime? departureDate;
  final TimeOfDay? departureTime;
  final String? vehicleType;
  final int? availableSeats;
  final bool? isRider;

  const MapScreen({
    super.key,
    required this.from,
    required this.to,
    required this.contact,
    required this.name,
    this.departureDate,
    this.departureTime,
    this.vehicleType,
    this.availableSeats,
    this.isRider,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _isLoading = true;
  LatLng? _startPoint;
  LatLng? _endPoint;

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
    {'name': 'Slave Island', 'lat': 6.9244, 'lon': 79.8528},
    {'name': 'Cinnamon Gardens', 'lat': 6.9147, 'lon': 79.8647},
    {'name': 'Nugegoda', 'lat': 6.8747, 'lon': 79.8897},
    {'name': 'Kottawa', 'lat': 6.8147, 'lon': 79.9297},
    {'name': 'Battaramulla', 'lat': 6.8997, 'lon': 79.9197},
    {'name': 'Rajagiriya', 'lat': 6.9097, 'lon': 79.9297},
    {'name': 'Thalawathugoda', 'lat': 6.8897, 'lon': 79.9397},
    {'name': 'Malabe', 'lat': 6.9097, 'lon': 79.9597},
    {'name': 'Beruwala', 'lat': 6.4790, 'lon': 79.9827},
    {'name': 'Aluthgama', 'lat': 6.4290, 'lon': 80.0027},
    {'name': 'Bentota', 'lat': 6.4256, 'lon': 79.9951},
    {'name': 'Hikkaduwa', 'lat': 6.1390, 'lon': 80.1027},
    {'name': 'Ambalangoda', 'lat': 6.2354, 'lon': 80.0540},
    {'name': 'Balapitiya', 'lat': 6.2790, 'lon': 80.0427},
    {'name': 'Kosgoda', 'lat': 6.3390, 'lon': 80.0227},
    {'name': 'Ahungalla', 'lat': 6.3590, 'lon': 80.0127},
    {'name': 'Induruwa', 'lat': 6.3790, 'lon': 80.0027},
    {'name': 'Wadduwa', 'lat': 6.6590, 'lon': 79.9327},
    {'name': 'Bandaragama', 'lat': 6.7090, 'lon': 80.0127},
    {'name': 'Ingiriya', 'lat': 6.7790, 'lon': 80.0827},
    {'name': 'Bulathsinhala', 'lat': 6.7290, 'lon': 80.1027},
    {'name': 'Mathugama', 'lat': 6.5390, 'lon': 80.1227},
    {'name': 'Agalawatta', 'lat': 6.5590, 'lon': 80.0827},
    {'name': 'Katunayake', 'lat': 7.1690, 'lon': 79.8827},
    {'name': 'Seeduwa', 'lat': 7.1290, 'lon': 79.8927},
    {'name': 'Minuwangoda', 'lat': 7.1690, 'lon': 79.9527},
    {'name': 'Veyangoda', 'lat': 7.1590, 'lon': 80.0227},
    {'name': 'Nittambuwa', 'lat': 7.1390, 'lon': 80.0927},
    {'name': 'Divulapitiya', 'lat': 7.2090, 'lon': 80.0827},
    {'name': 'Mirigama', 'lat': 7.2490, 'lon': 80.1227},
    {'name': 'Kirindiwela', 'lat': 7.0590, 'lon': 80.0527},
    {'name': 'Ganemulla', 'lat': 7.0790, 'lon': 80.0127},
    {'name': 'Yakkala', 'lat': 7.0890, 'lon': 80.0327},

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
    {'name': 'Laggala', 'lat': 7.4503, 'lon': 80.7317},
    {'name': 'Pallepola', 'lat': 7.3503, 'lon': 80.7517},
    {'name': 'Yatawatta', 'lat': 7.2503, 'lon': 80.7717},
    {'name': 'Raththota', 'lat': 7.1503, 'lon': 80.7917},
    {'name': 'Wilgamuwa', 'lat': 7.4703, 'lon': 80.8317},
    {'name': 'Naula', 'lat': 7.5703, 'lon': 80.8517},
    {'name': 'Ginigathena', 'lat': 7.0503, 'lon': 80.6017},
    {'name': 'Walapane', 'lat': 6.9503, 'lon': 80.6717},
    {'name': 'Ramboda', 'lat': 6.9703, 'lon': 80.6917},
    {'name': 'Kotagala', 'lat': 6.8703, 'lon': 80.6317},
    {'name': 'Agarapathana', 'lat': 6.8503, 'lon': 80.7117},
    {'name': 'Ragala', 'lat': 6.8303, 'lon': 80.7317},
    {'name': 'Kandapola', 'lat': 6.9803, 'lon': 80.7517},
    {'name': 'Ambewela', 'lat': 6.9003, 'lon': 80.8017},
    {'name': 'Pussellawa', 'lat': 7.0003, 'lon': 80.6817},
    {'name': 'Kotmale', 'lat': 7.0203, 'lon': 80.6617},
    {'name': 'Kandaketiya', 'lat': 6.9794, 'lon': 81.0294},
    {'name': 'Demodara', 'lat': 6.8994, 'lon': 81.0694},

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
    {'name': 'Talpe', 'lat': 6.0041, 'lon': 80.2885},
    {'name': 'Habaraduwa', 'lat': 6.0341, 'lon': 80.2685},
    {'name': 'Elpitiya', 'lat': 6.2941, 'lon': 80.1685},
    {'name': 'Neluwa', 'lat': 6.3341, 'lon': 80.3885},
    {'name': 'Nagoda', 'lat': 6.0441, 'lon': 80.2185},
    {'name': 'Baddegama', 'lat': 6.1841, 'lon': 80.1985},
    {'name': 'Hiniduma', 'lat': 6.3141, 'lon': 80.3585},
    {'name': 'Tawalama', 'lat': 6.2641, 'lon': 80.3385},
    {'name': 'Wanduramba', 'lat': 6.2841, 'lon': 80.3185},
    {'name': 'Pitigala', 'lat': 6.2541, 'lon': 80.2985},
    {'name': 'Akmeemana', 'lat': 6.0641, 'lon': 80.2385},
    {'name': 'Yakkalamulla', 'lat': 6.0841, 'lon': 80.2585},
    {'name': 'Bope', 'lat': 6.1041, 'lon': 80.2785},
    {'name': 'Poddala', 'lat': 6.1241, 'lon': 80.2985},
    {'name': 'Imaduwa', 'lat': 6.1441, 'lon': 80.3185},
    {'name': 'Kamburupitiya', 'lat': 5.9141, 'lon': 80.4885},
    {'name': 'Kirinda', 'lat': 6.0741, 'lon': 81.1385},
    {'name': 'Beliatta', 'lat': 6.0341, 'lon': 80.9985},
    {'name': 'Weeraketiya', 'lat': 6.1141, 'lon': 80.9585},
    {'name': 'Ambalantota', 'lat': 6.1341, 'lon': 81.0285},
    {'name': 'Tissamaharama', 'lat': 6.2941, 'lon': 81.2885},
    {'name': 'Kataragama', 'lat': 6.4141, 'lon': 81.3385},
    {'name': 'Sooriyawewa', 'lat': 6.3541, 'lon': 81.1885},
    {'name': 'Bundala', 'lat': 6.1941, 'lon': 81.2485},
    {'name': 'Yala', 'lat': 6.3741, 'lon': 81.5185},
    {'name': 'Dickwella', 'lat': 5.9341, 'lon': 80.7085},
    {'name': 'Dondra', 'lat': 5.9241, 'lon': 80.5885},
    {'name': 'Gandara', 'lat': 6.0541, 'lon': 80.5485},
    {'name': 'Mulkirigala', 'lat': 6.0741, 'lon': 80.7385},
    {'name': 'Ridiyagama', 'lat': 6.2441, 'lon': 80.4985},
    {'name': 'Embilipitiya', 'lat': 6.3441, 'lon': 80.8485},
    {'name': 'Angunakolapelessa', 'lat': 6.0941, 'lon': 80.9185},
    {'name': 'Middeniya', 'lat': 6.1741, 'lon': 80.8785},
    {'name': 'Ranna', 'lat': 6.1541, 'lon': 81.1585},
    {'name': 'Hungama', 'lat': 6.2241, 'lon': 81.1785},

    // Northern Province
    {'name': 'Jaffna', 'lat': 9.6615, 'lon': 80.0255},
    {'name': 'Vavuniya', 'lat': 8.7514, 'lon': 80.4971},
    {'name': 'Mannar', 'lat': 8.9814, 'lon': 79.9171},
    {'name': 'Kilinochchi', 'lat': 9.3814, 'lon': 80.4071},
    {'name': 'Mullaitivu', 'lat': 9.2714, 'lon': 80.8171},
    {'name': 'Point Pedro', 'lat': 9.8314, 'lon': 80.2371},
    {'name': 'Chavakachcheri', 'lat': 9.6314, 'lon': 80.1671},
    {'name': 'Nallur', 'lat': 9.6714, 'lon': 80.0371},
    {'name': 'Kopay', 'lat': 9.6414, 'lon': 80.0571},
    {'name': 'Tellippalai', 'lat': 9.7114, 'lon': 80.0871},
    {'name': 'Sandilipay', 'lat': 9.6914, 'lon': 80.1071},
    {'name': 'Karainagar', 'lat': 9.7714, 'lon': 79.9571},
    {'name': 'Velanai', 'lat': 9.7314, 'lon': 79.9371},
    {'name': 'Kayts', 'lat': 9.6814, 'lon': 79.8571},
    {'name': 'Karaveddy', 'lat': 9.6514, 'lon': 80.1271},
    {'name': 'Manipay', 'lat': 9.7014, 'lon': 80.0671},
    {'name': 'Uduvil', 'lat': 9.6114, 'lon': 80.0771},
    {'name': 'Chunnakam', 'lat': 9.7414, 'lon': 80.0471},
    {'name': 'Kondavil', 'lat': 9.6814, 'lon': 80.0171},
    {'name': 'Nelliady', 'lat': 9.5814, 'lon': 80.0971},

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
    {'name': 'Siyambalanduwa', 'lat': 6.8117, 'lon': 81.5302},
    {'name': 'Medagama', 'lat': 6.7717, 'lon': 81.4502},
    {'name': 'Thanamalvila', 'lat': 6.8917, 'lon': 81.4802},
    {'name': 'Kinniya', 'lat': 8.4874, 'lon': 81.1852},
    {'name': 'Mutur', 'lat': 8.4674, 'lon': 81.2852},
    {'name': 'Kantale', 'lat': 8.3674, 'lon': 81.0852},
    {'name': 'Seruwila', 'lat': 8.3874, 'lon': 81.2452},
    {'name': 'Somawathiya', 'lat': 8.2874, 'lon': 81.1252},
    {'name': 'Polonnaruwa', 'lat': 7.9403, 'lon': 81.0017},
    {'name': 'Kaduruwela', 'lat': 7.9603, 'lon': 80.9817},
    {'name': 'Hingurakgoda', 'lat': 7.9803, 'lon': 80.9617},
    {'name': 'Medirigiriya', 'lat': 7.8803, 'lon': 80.9817},
    {'name': 'Dimbulagala', 'lat': 7.8603, 'lon': 80.9617},
    {'name': 'Manampitiya', 'lat': 8.0803, 'lon': 81.0417},
    {'name': 'Valaichchenai', 'lat': 7.9167, 'lon': 81.5800},
    {'name': 'Eravur', 'lat': 7.7767, 'lon': 81.6100},
    {'name': 'Chenkaladi', 'lat': 7.7367, 'lon': 81.6300},
    {'name': 'Kattankudy', 'lat': 7.6767, 'lon': 81.7300},
    {'name': 'Valaichenai', 'lat': 7.9267, 'lon': 81.5600},

    // North Western Province
    {'name': 'Kurunegala', 'lat': 7.4818, 'lon': 80.3609},
    {'name': 'Puttalam', 'lat': 8.0362, 'lon': 79.8283},
    {'name': 'Chilaw', 'lat': 7.5762, 'lon': 79.7983},
    {'name': 'Wariyapola', 'lat': 7.6818, 'lon': 80.2309},
    {'name': 'Kuliyapitiya', 'lat': 7.4618, 'lon': 80.0409},
    {'name': 'Mawathagama', 'lat': 7.2418, 'lon': 80.4609},
    {'name': 'Galgamuwa', 'lat': 7.9818, 'lon': 80.2809},
    {'name': 'Nikaweratiya', 'lat': 7.7218, 'lon': 80.1109},
    {'name': 'Pannala', 'lat': 7.3318, 'lon': 80.2409},
    {'name': 'Narammala', 'lat': 7.4218, 'lon': 80.2209},
    {'name': 'Bingiriya', 'lat': 7.5818, 'lon': 80.0909},
    {'name': 'Rideegama', 'lat': 7.3618, 'lon': 80.0709},
    {'name': 'Polgahawela', 'lat': 7.3318, 'lon': 80.3009},
    {'name': 'Alawwa', 'lat': 7.2918, 'lon': 80.2409},
    {'name': 'Meerigama', 'lat': 7.2618, 'lon': 80.1609},
    {'name': 'Dankotuwa', 'lat': 7.3162, 'lon': 79.8983},
    {'name': 'Wennappuwa', 'lat': 7.3562, 'lon': 79.8483},
    {'name': 'Marawila', 'lat': 7.4462, 'lon': 79.8183},
    {'name': 'Nattandiya', 'lat': 7.4062, 'lon': 79.8683},
    {'name': 'Madampe', 'lat': 7.5162, 'lon': 79.8383},
    {'name': 'Bangadeniya', 'lat': 7.5862, 'lon': 79.8083},
    {'name': 'Udubaddawa', 'lat': 7.9362, 'lon': 80.1283},
    {'name': 'Anamaduwa', 'lat': 8.0762, 'lon': 79.9083},
    {'name': 'Pallama', 'lat': 8.0362, 'lon': 79.9583},
    {'name': 'Nawagattegama', 'lat': 7.8862, 'lon': 80.0883},
    {'name': 'Mahawewa', 'lat': 8.0162, 'lon': 80.0383},
    {'name': 'Kalpitiya', 'lat': 8.2362, 'lon': 79.7683},
    {'name': 'Mundel', 'lat': 8.1762, 'lon': 79.7883},
    {'name': 'Waikkal', 'lat': 7.2862, 'lon': 79.8483},

    // North Central Province
    {'name': 'Anuradhapura', 'lat': 8.3114, 'lon': 80.4037},
    {'name': 'Mihintale', 'lat': 8.3514, 'lon': 80.5037},
    {'name': 'Kekirawa', 'lat': 8.0314, 'lon': 80.5937},
    {'name': 'Tambuttegama', 'lat': 8.1314, 'lon': 80.4737},
    {'name': 'Galenbindunuwewa', 'lat': 8.2114, 'lon': 80.4537},
    {'name': 'Eppawala', 'lat': 8.1914, 'lon': 80.4337},
    {'name': 'Thirappane', 'lat': 8.2514, 'lon': 80.4137},
    {'name': 'Nochchiyagama', 'lat': 8.3914, 'lon': 80.2337},
    {'name': 'Medawachchiya', 'lat': 8.5414, 'lon': 80.4937},
    {'name': 'Horowpothana', 'lat': 8.3714, 'lon': 80.2537},
    {'name': 'Rambewa', 'lat': 8.4114, 'lon': 80.2737},
    {'name': 'Talawa', 'lat': 8.4314, 'lon': 80.2937},
    {'name': 'Palagala', 'lat': 8.4514, 'lon': 80.3137},
    {'name': 'Maradankadawala', 'lat': 8.4714, 'lon': 80.3337},
    {'name': 'Kebithigollewa', 'lat': 8.4914, 'lon': 80.3537},
    {'name': 'Rajanganaya', 'lat': 8.1714, 'lon': 80.3737},
    {'name': 'Galnewa', 'lat': 7.9714, 'lon': 80.3937},
    {'name': 'Welikanda', 'lat': 7.9314, 'lon': 81.0737},
    {'name': 'Lankapura', 'lat': 7.8914, 'lon': 81.0537},
    {'name': 'Bakamuna', 'lat': 7.8714, 'lon': 81.0337},
    {'name': 'Elahera', 'lat': 7.8514, 'lon': 81.0137},
    {'name': 'Aralaganwila', 'lat': 7.8314, 'lon': 80.9937},
    {'name': 'Nissankamallapura', 'lat': 7.8114, 'lon': 80.9737},
    {'name': 'Jayanthipura', 'lat': 7.7914, 'lon': 80.9537},
    {'name': 'Minneriya', 'lat': 7.9114, 'lon': 80.8937},
    {'name': 'Habarana', 'lat': 8.0414, 'lon': 80.7537},
    {'name': 'Galadivulwewa', 'lat': 8.0614, 'lon': 80.7337},
    {'name': 'Ritigala', 'lat': 8.0814, 'lon': 80.7137},
    {'name': 'Puliyankulama', 'lat': 8.6414, 'lon': 80.4137},
    {'name': 'Padaviya', 'lat': 8.5614, 'lon': 80.3737},

    // Uva Province
    {'name': 'Diyatalawa', 'lat': 6.8094, 'lon': 80.9694},
    {'name': 'Haldummulla', 'lat': 6.7394, 'lon': 80.9394},
    {'name': 'Lunugala', 'lat': 7.1594, 'lon': 81.0894},
    {'name': 'Soranathota', 'lat': 7.0894, 'lon': 81.0494},
    {'name': 'Kinigama', 'lat': 7.0294, 'lon': 81.0294},
    {'name': 'Rideemaliyadda', 'lat': 7.0694, 'lon': 81.0094},
    {'name': 'Uva Paranagama', 'lat': 7.1094, 'lon': 80.9894},
    {'name': 'Sevanagala', 'lat': 6.8417, 'lon': 81.2802},
    {'name': 'Madulla', 'lat': 6.8717, 'lon': 81.2502},
    {'name': 'Bibila', 'lat': 6.9017, 'lon': 81.2202},
    {'name': 'Moneragala', 'lat': 6.8717, 'lon': 81.3502},
    {'name': 'Bibile', 'lat': 7.1617, 'lon': 81.2102},
    {'name': 'Okkampitiya', 'lat': 6.7817, 'lon': 81.3202},
    {'name': 'Kumbalwela', 'lat': 6.8417, 'lon': 81.3802},
    {'name': 'Girandurukotte', 'lat': 7.3217, 'lon': 81.1402},
    {'name': 'Badalkumbura', 'lat': 7.2017, 'lon': 81.1702},
    {'name': 'Hali-Ela', 'lat': 6.9594, 'lon': 81.0794},

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
    {'name': 'Galigamuwa', 'lat': 7.1844, 'lon': 80.3796},
    {'name': 'Dehiowita', 'lat': 6.8644, 'lon': 80.1296},
    {'name': 'Bulathkohupitiya', 'lat': 7.1644, 'lon': 80.1596},
    {'name': 'Aranayaka', 'lat': 7.2844, 'lon': 80.2796},
    {'name': 'Weligepola', 'lat': 7.2644, 'lon': 80.2396},
    {'name': 'Nelundeniya', 'lat': 7.1444, 'lon': 80.2196},
    {'name': 'Nivitigala', 'lat': 6.4144, 'lon': 80.4796},
    {'name': 'Ayagama', 'lat': 6.5244, 'lon': 80.4596},
    {'name': 'Pinnawala', 'lat': 7.2944, 'lon': 80.3896},
    {'name': 'Hemmatagama', 'lat': 7.2744, 'lon': 80.3696},

    // Additional Popular Locations
    {'name': 'Awissawella', 'lat': 6.9544, 'lon': 80.2096},
    {'name': 'Padukka', 'lat': 6.8644, 'lon': 80.1096},
    {'name': 'Hanwella', 'lat': 6.9044, 'lon': 80.0896},
    {'name': 'Kosgama', 'lat': 6.9344, 'lon': 80.1296},
    {'name': 'Seethawaka', 'lat': 6.9144, 'lon': 80.1496},
    {'name': 'Malwala', 'lat': 6.8944, 'lon': 80.1696},
    {'name': 'Palindanuwara', 'lat': 6.5990, 'lon': 80.0827},
    {'name': 'Millaniya', 'lat': 6.5690, 'lon': 80.0627},
    {'name': 'Dodangoda', 'lat': 6.5490, 'lon': 80.0427},
    {'name': 'Madurawela', 'lat': 6.5290, 'lon': 80.0227},
    {'name': 'Walallawita', 'lat': 6.5090, 'lon': 80.0027},
    {'name': 'Liyanagemulla', 'lat': 7.1090, 'lon': 79.9227},
    {'name': 'Dharga Town', 'lat': 6.5190, 'lon': 80.1327},
    {'name': 'Dodanduwa', 'lat': 6.1190, 'lon': 80.0827},
    {'name': 'Gintota', 'lat': 6.0890, 'lon': 80.1927},
    {'name': 'Boossa', 'lat': 6.0790, 'lon': 80.2027},
    {'name': 'Piyadigama', 'lat': 6.1990, 'lon': 80.1827},
    {'name': 'Bentara', 'lat': 6.2790, 'lon': 80.1527},
    {'name': 'Urubokka', 'lat': 6.0990, 'lon': 80.2927},
  ];

  @override
  void initState() {
    super.initState();
    _initializeLocations();
  }

  Future<void> _initializeLocations() async {
    setState(() => _isLoading = true);

    try {
      // Find coordinates for from location
      final fromLocation = _popularLocations.firstWhere(
        (loc) =>
            loc['name'].toString().toLowerCase() == widget.from.toLowerCase(),
        orElse: () => {'name': '', 'lat': 0.0, 'lon': 0.0},
      );

      if (fromLocation['name'] == '') {
        final fromResponse = await http.get(Uri.parse(
            'https://nominatim.openstreetmap.org/search?format=json&q=${widget.from}&countrycodes=lk&limit=1'));
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
      } else {
        _startPoint = LatLng(fromLocation['lat'], fromLocation['lon']);
        _addMarker(_startPoint!, 'Start');
      }

      // Find coordinates for to location
      final toLocation = _popularLocations.firstWhere(
        (loc) =>
            loc['name'].toString().toLowerCase() == widget.to.toLowerCase(),
        orElse: () => {'name': '', 'lat': 0.0, 'lon': 0.0},
      );

      if (toLocation['name'] == '') {
        final toResponse = await http.get(Uri.parse(
            'https://nominatim.openstreetmap.org/search?format=json&q=${widget.to}&countrycodes=lk&limit=1'));
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
      } else {
        _endPoint = LatLng(toLocation['lat'], toLocation['lon']);
        _addMarker(_endPoint!, 'End');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        title: const Text(
          'Confirm Your Route',
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
          : GoogleMap(
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('You must be logged in!')),
            );
            return;
          }

          try {
            if (widget.isRider == true) {
              // Save as rider route with all required fields
              await FirebaseFirestore.instance.collection('rider_routes').add({
                'riderId': user.uid,
                'riderName': widget.name,
                'riderContact': widget.contact,
                'from': widget.from,
                'to': widget.to,
                'departureDate': widget.departureDate != null
                    ? Timestamp.fromDate(widget.departureDate!)
                    : Timestamp.fromDate(
                        DateTime.now().add(const Duration(days: 1))),
                'departureTime': widget.departureTime != null
                    ? widget.departureTime!.format(context)
                    : TimeOfDay.now().format(context),
                'vehicleType': widget.vehicleType ?? 'Car',
                'availableSeats': widget.availableSeats ?? 1,
                'startLat': _startPoint?.latitude,
                'startLng': _startPoint?.longitude,
                'endLat': _endPoint?.latitude,
                'endLng': _endPoint?.longitude,
                'isActive': true,
                'createdAt': FieldValue.serverTimestamp(),
                'updatedAt': FieldValue.serverTimestamp(),
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Ride posted successfully! 🚗',
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
            } else {
              // Passenger request logic - save to passenger_requests and find matching riders
              await FirebaseFirestore.instance
                  .collection('passenger_requests')
                  .add({
                'userId': user.uid,
                'passengerName': widget.name,
                'passengerContact': widget.contact,
                'from': widget.from,
                'to': widget.to,
                'startLat': _startPoint?.latitude,
                'startLng': _startPoint?.longitude,
                'endLat': _endPoint?.latitude,
                'endLng': _endPoint?.longitude,
                'departureDate': widget.departureDate != null
                    ? Timestamp.fromDate(widget.departureDate!)
                    : Timestamp.fromDate(
                        DateTime.now().add(const Duration(days: 1))),
                'departureTime': widget.departureTime != null
                    ? widget.departureTime!.format(context)
                    : TimeOfDay.now().format(context),
                'vehicleType': widget.vehicleType,
                'isActive': true,
                'createdAt': FieldValue.serverTimestamp(),
                'updatedAt': FieldValue.serverTimestamp(),
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Route confirmed! Finding riders... 🔍',
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

              // Navigate to matching riders screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MatchingRidersScreen(
                    from: widget.from,
                    to: widget.to,
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
              return; // Don't execute the default navigation logic
            }

            // Navigate back to home screen (pop twice to get back to home)
            Navigator.pop(context); // Pop map screen
            Navigator.pop(context); // Pop passenger/rider route screen
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Failed to save route: $e',
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
        },
        backgroundColor: const Color(0xFF2563EB),
        icon: const Icon(Icons.check, color: Colors.white),
        label: const Text(
          'Confirm Route',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }
}

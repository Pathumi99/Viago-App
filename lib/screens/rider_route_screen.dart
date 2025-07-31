import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'map_screen.dart';

class RiderRouteScreen extends StatefulWidget {
  const RiderRouteScreen({super.key});

  @override
  State<RiderRouteScreen> createState() => _RiderRouteScreenState();
}

class _RiderRouteScreenState extends State<RiderRouteScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final bool _isLoading = false;

  // New fields for departure date, time, and vehicle details
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedVehicleType;
  int _availableSeats = 1;

  // Animation controllers
  late AnimationController _masterAnimationController;
  late AnimationController _floatingAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _pulseAnimation;

  // Comprehensive Sri Lankan cities, towns, and villages for suggestions
  final List<String> _popularLocations = [
    // Western Province
    'Colombo', 'Gampaha', 'Kalutara', 'Negombo', 'Panadura', 'Horana',
    'Moratuwa', 'Dehiwala', 'Mount Lavinia', 'Ratmalana', 'Kelaniya',
    'Peliyagoda', 'Wattala', 'Ja-Ela', 'Kadawatha', 'Ragama', 'Kiribathgoda',
    'Maharagama', 'Homagama', 'Piliyandala', 'Kaduwela', 'Kotte',
    'Kollupitiya', 'Bambalapitiya', 'Wellawatta', 'Borella', 'Maradana',
    'Pettah', 'Fort', 'Slave Island', 'Cinnamon Gardens', 'Nugegoda',
    'Kottawa', 'Battaramulla', 'Rajagiriya', 'Thalawathugoda', 'Malabe',
    'Beruwala', 'Aluthgama', 'Bentota', 'Hikkaduwa', 'Ambalangoda',
    'Balapitiya', 'Kosgoda', 'Ahungalla', 'Induruwa', 'Wadduwa',
    'Bandaragama', 'Ingiriya', 'Bulathsinhala', 'Mathugama', 'Agalawatta',
    'Palindanuwara', 'Millaniya', 'Dodangoda', 'Madurawela', 'Walallawita',
    'Katunayake', 'Seeduwa', 'Liyanagemulla', 'Minuwangoda', 'Veyangoda',
    'Nittambuwa', 'Divulapitiya', 'Mirigama', 'Kirindiwela', 'Ganemulla',
    'Yakkala', 'Gampaha', 'Kiribathgoda', 'Kelaniya', 'Wattala',

    // Central Province
    'Kandy', 'Matale', 'Nuwara Eliya', 'Peradeniya', 'Gampola', 'Nawalapitiya',
    'Hatton', 'Dimbula', 'Talawakele', 'Nanu Oya', 'Haputale', 'Bandarawela',
    'Ella', 'Welimada', 'Badulla', 'Mahiyanganaya', 'Passara', 'Hali Ela',
    'Katugastota', 'Akurana', 'Kadugannawa', 'Pilimathalawa', 'Kundasale',
    'Digana', 'Teldeniya', 'Hasalaka', 'Panvila', 'Wattegama',
    'Dambulla', 'Sigiriya', 'Galewela', 'Ukuwela', 'Rattota', 'Laggala',
    'Pallepola', 'Yatawatta', 'Raththota', 'Wilgamuwa', 'Naula',
    'Ginigathena', 'Walapane', 'Ramboda', 'Kotagala', 'Agarapathana',
    'Ragala', 'Kandapola', 'Ambewela', 'Pussellawa', 'Kotmale',
    'Meerigama', 'Passara', 'Lunugala', 'Kandaketiya', 'Demodara',

    // Southern Province
    'Galle', 'Matara', 'Hambantota', 'Tangalle', 'Weligama', 'Mirissa',
    'Unawatuna', 'Koggala', 'Ahangama', 'Midigama', 'Talpe', 'Habaraduwa',
    'Bentota', 'Hikkaduwa', 'Ambalangoda', 'Elpitiya', 'Neluwa', 'Nagoda',
    'Baddegama', 'Hiniduma', 'Tawalama', 'Wanduramba', 'Pitigala',
    'Akmeemana', 'Yakkalamulla', 'Bope', 'Poddala', 'Imaduwa',
    'Kamburupitiya', 'Kirinda', 'Beliatta', 'Weeraketiya', 'Ambalantota',
    'Tissamaharama', 'Kataragama', 'Sooriyawewa', 'Bundala', 'Yala',
    'Dickwella', 'Dondra', 'Gandara', 'Mulkirigala', 'Ridiyagama',
    'Embilipitiya', 'Angunakolapelessa', 'Middeniya', 'Ranna', 'Hungama',

    // Northern Province
    'Jaffna', 'Vavuniya', 'Mannar', 'Kilinochchi', 'Mullaitivu',
    'Point Pedro', 'Chavakachcheri', 'Nallur', 'Kopay', 'Tellippalai',
    'Sandilipay', 'Karainagar', 'Velanai', 'Kayts', 'Karaveddy',
    'Manipay', 'Uduvil', 'Chunnakam', 'Kondavil', 'Nelliady',
    'Cheddikulam', 'Nedunkeni', 'Omanthai', 'Puliyankulam', 'Madhu',
    'Adampan', 'Manthai West', 'Musali', 'Nanattan', 'Thalladi',
    'Parayanalankulam', 'Kandavalai', 'Poonakary', 'Pallai', 'Paranthan',
    'Elephant Pass', 'Pachchilaipalli', 'Puthukkudiyiruppu', 'Thunukkai',
    'Maritimepattu', 'Oddusuddan', 'Puthukudiyiruppu', 'Manthai East',

    // Eastern Province
    'Trincomalee', 'Batticaloa', 'Ampara', 'Kalmunai', 'Akkaraipattu',
    'Sammanthurai', 'Pottuvil', 'Arugam Bay', 'Monaragala', 'Wellawaya',
    'Buttala', 'Kataragama', 'Siyambalanduwa', 'Medagama', 'Thanamalvila',
    'Kinniya', 'Mutur', 'Kantale', 'Seruwila', 'Somawathiya', 'Polonnaruwa',
    'Kaduruwela', 'Hingurakgoda', 'Medirigiriya', 'Dimbulagala', 'Manampitiya',
    'Valaichchenai', 'Eravur', 'Chenkaladi', 'Kattankudy', 'Valaichenai',
    'Paddiruppu', 'Oddamavadi', 'Koralaipattu', 'Pasikudah', 'Kalkudah',
    'Uhana', 'Maha Oya', 'Addalaichenai', 'Akkaraipattu', 'Alayadivembu',
    'Nintavur', 'Chavalakade', 'Thirukovil', 'Lahugala', 'Panama',

    // North Western Province
    'Kurunegala', 'Puttalam', 'Chilaw', 'Wariyapola', 'Kuliyapitiya',
    'Mawathagama', 'Galgamuwa', 'Nikaweratiya', 'Pannala', 'Narammala',
    'Bingiriya', 'Rideegama', 'Polgahawela', 'Alawwa', 'Meerigama',
    'Dankotuwa', 'Wennappuwa', 'Marawila', 'Nattandiya', 'Madampe',
    'Bangadeniya', 'Udubaddawa', 'Anamaduwa', 'Pallama', 'Nawagattegama',
    'Mahawewa', 'Kalpitiya', 'Puttalam', 'Mundel', 'Waikkal',
    'Tabbowa', 'Norochcholai', 'Dalupotha', 'Karukupone', 'Nainamadama',
    'Mahakumbukkadawala', 'Kochchikade', 'Lunuwila', 'Madhu Road',
    'Ibbagamuwa', 'Yapahuwa', 'Maho', 'Giriulla', 'Melsiripura',

    // North Central Province
    'Anuradhapura', 'Polonnaruwa', 'Dambulla', 'Sigiriya', 'Mihintale',
    'Kekirawa', 'Tambuttegama', 'Galenbindunuwewa', 'Eppawala', 'Thirappane',
    'Nochchiyagama', 'Medawachchiya', 'Horowpothana', 'Rambewa', 'Talawa',
    'Palagala', 'Maradankadawala', 'Kebithigollewa', 'Rajanganaya', 'Galnewa',
    'Kaduruwela', 'Hingurakgoda', 'Medirigiriya', 'Dimbulagala', 'Welikanda',
    'Lankapura', 'Bakamuna', 'Somawathiya', 'Manampitiya', 'Elahera',
    'Aralaganwila', 'Nissankamallapura', 'Jayanthipura', 'Minneriya',
    'Habarana', 'Galadivulwewa', 'Ritigala', 'Puliyankulama', 'Padaviya',

    // Uva Province
    'Badulla', 'Monaragala', 'Bandarawela', 'Haputale', 'Ella', 'Welimada',
    'Diyatalawa', 'Haldummulla', 'Passara', 'Lunugala', 'Mahiyanganaya',
    'Soranathota', 'Kandaketiya', 'Kinigama', 'Rideemaliyadda',
    'Uva Paranagama',
    'Wellawaya', 'Buttala', 'Kataragama', 'Siyambalanduwa', 'Medagama',
    'Thanamalvila', 'Sevanagala', 'Madulla', 'Bibila', 'Moneragala',
    'Bibile', 'Medagama', 'Wellawaya', 'Buttala', 'Okkampitiya',
    'Kumbalwela', 'Girandurukotte', 'Badalkumbura', 'Hali-Ela', 'Demodara',

    // Sabaragamuwa Province
    'Ratnapura', 'Kegalle', 'Embilipitiya', 'Balangoda', 'Rakwana',
    'Pelmadulla', 'Kuruwita', 'Godakawela', 'Kalawana', 'Kolonna',
    'Eheliyagoda', 'Avissawella', 'Yatiyantota', 'Deraniyagala', 'Kitulgala',
    'Ruwanwella', 'Warakapola', 'Mawanella', 'Rambukkana', 'Kegalle',
    'Galigamuwa', 'Dehiowita', 'Bulathkohupitiya', 'Yatiyantota', 'Aranayaka',
    'Weligepola', 'Nelundeniya', 'Alutgama', 'Beruwala', 'Kalutara',
    'Nivitigala', 'Ayagama', 'Weligepola', 'Dehiovita', 'Bulathkohupitiya',
    'Pinnawala', 'Hemmatagama', 'Rideegama', 'Galigamuwa', 'Warakapola',

    // Additional Popular Locations
    'Awissawella', 'Homagama', 'Padukka', 'Hanwella', 'Kosgama',
    'Seethawaka', 'Malwala', 'Ingiriya', 'Bulathsinhala', 'Horana',
    'Panadura', 'Bandaragama', 'Millaniya', 'Madurawela', 'Agalawatta',
    'Mathugama', 'Dharga Town', 'Aluthgama', 'Bentota', 'Induruwa',
    'Kosgoda', 'Balapitiya', 'Ambalangoda', 'Hikkaduwa', 'Dodanduwa',
    'Gintota', 'Boossa', 'Piyadigama', 'Baddegama', 'Neluwa',
    'Elpitiya', 'Bentara', 'Wanduramba', 'Hiniduma', 'Tawalama',
    'Urubokka', 'Akmeemana', 'Yakkalamulla', 'Bope', 'Poddala',
  ];

  final List<String> _vehicleTypes = [
    'Car',
    'Van',
    'SUV',
    'Pickup',
    'Bus',
    'Bike',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadUserData();
  }

  void _setupAnimations() {
    // Master animation controller for main entrance
    _masterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Floating animation for background elements
    _floatingAnimationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    // Pulse animation for interactive elements
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _masterAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _masterAnimationController,
      curve: Curves.easeOutBack,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _masterAnimationController,
      curve: Curves.elasticOut,
    ));

    _floatingAnimation = Tween<double>(
      begin: -8,
      end: 8,
    ).animate(CurvedAnimation(
      parent: _floatingAnimationController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));

    _masterAnimationController.forward();
    _floatingAnimationController.repeat(reverse: true);
    _pulseAnimationController.repeat(reverse: true);
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _nameController.text = userData['name'] ?? '';
            _contactController.text = userData['phone'] ?? '';
          });
        }
      } catch (e) {
        // If there's an error loading user data, just continue with empty fields
        debugPrint('Error loading user data: $e');
      }
    }
  }

  @override
  void dispose() {
    _masterAnimationController.dispose();
    _floatingAnimationController.dispose();
    _pulseAnimationController.dispose();
    _fromController.dispose();
    _toController.dispose();
    _nameController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _showLocationSuggestions(
      String query, TextEditingController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final filteredLocations = _popularLocations
              .where((location) =>
                  query.isEmpty ||
                  location.toLowerCase().contains(query.toLowerCase()))
              .toList();

          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1E3A8A),
                  Color(0xFF2563EB),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Search Location',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                // Search TextField
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    autofocus: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type to search location...',
                      hintStyle:
                          TextStyle(color: Colors.white.withOpacity(0.6)),
                      prefixIcon: Icon(Icons.search,
                          color: Colors.white.withOpacity(0.8)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.white.withOpacity(0.4)),
                      ),
                    ),
                    onChanged: (value) {
                      setModalState(() {
                        query = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView.builder(
                      itemCount: filteredLocations.length,
                      itemBuilder: (context, index) {
                        final location = filteredLocations[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.1),
                                Colors.white.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.location_on,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            title: Text(
                              location,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onTap: () {
                              controller.text = location;
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  void _proceedToMap() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('You must be logged in!'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    // Navigate to map screen with route data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          from: _fromController.text.trim(),
          to: _toController.text.trim(),
          contact: _contactController.text.trim(),
          name: _nameController.text.trim(),
          departureDate: _selectedDate,
          departureTime: _selectedTime,
          vehicleType: _selectedVehicleType,
          availableSeats: _availableSeats,
          isRider: true, // Flag to indicate this is for rider
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildEnhancedAppBar(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: _buildEnhancedBackground(),
        child: Stack(
          children: [
            // Animated background elements
            _buildFloatingElements(),

            // Main content
            SafeArea(
              child: AnimatedBuilder(
                animation: _masterAnimationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 20),

                                // Enhanced header
                                _buildEnhancedHeader(),

                                const SizedBox(height: 40),

                                // Staggered form fields
                                _buildStaggeredFormField(0, _buildNameField()),
                                const SizedBox(height: 20),

                                _buildStaggeredFormField(
                                    1, _buildContactField()),
                                const SizedBox(height: 20),

                                _buildStaggeredFormField(2, _buildFromField()),
                                const SizedBox(height: 20),

                                _buildStaggeredFormField(3, _buildToField()),
                                const SizedBox(height: 20),

                                _buildStaggeredFormField(4, _buildDateField()),
                                const SizedBox(height: 20),

                                _buildStaggeredFormField(5, _buildTimeField()),
                                const SizedBox(height: 20),

                                _buildStaggeredFormField(
                                    6, _buildVehicleTypeField()),
                                const SizedBox(height: 20),

                                _buildStaggeredFormField(7, _buildSeatsField()),
                                const SizedBox(height: 40),

                                // Enhanced continue button
                                _buildStaggeredFormField(
                                    8, _buildContinueButton()),

                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildEnhancedAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.25),
              Colors.white.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.25),
                  Colors.white.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.add_road,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Post a Ride',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              fontFamily: 'Poppins',
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      centerTitle: true,
    );
  }

  BoxDecoration _buildEnhancedBackground() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF0F172A),
          Color(0xFF1E3A8A),
          Color(0xFF2563EB),
          Color(0xFF3B82F6),
          Color(0xFF60A5FA),
          Color(0xFF93C5FD),
        ],
        stops: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
      ),
    );
  }

  Widget _buildFloatingElements() {
    return AnimatedBuilder(
      animation: _floatingAnimationController,
      builder: (context, child) {
        return Stack(
          children: [
            // Floating circle 1
            Positioned(
              top: 80 + _floatingAnimation.value,
              right: 20,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.08),
                      Colors.white.withValues(alpha: 0.03),
                    ],
                  ),
                ),
              ),
            ),
            // Floating circle 2
            Positioned(
              top: 200 - _floatingAnimation.value,
              left: 30,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.06),
                      Colors.white.withValues(alpha: 0.02),
                    ],
                  ),
                ),
              ),
            ),
            // Floating circle 3
            Positioned(
              top: 400 + (_floatingAnimation.value * 0.5),
              right: 50,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.05),
                      Colors.white.withValues(alpha: 0.02),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEnhancedHeader() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.15),
              Colors.white.withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.directions_car,
              size: 40,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            const SizedBox(height: 12),
            const Text(
              'Share your ride with passengers',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Fill in your journey details to connect with passengers',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaggeredFormField(int index, Widget field) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 600 + (index * 150)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: field,
          ),
        );
      },
    );
  }

  Widget _buildEnhancedFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    String? hintText,
    Widget? suffixIcon,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.12),
            Colors.white.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 14,
          ),
          prefixIcon: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(
              icon,
              color: Colors.white.withValues(alpha: 0.8),
              size: 20,
            ),
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildNameField() {
    return _buildEnhancedFormField(
      controller: _nameController,
      label: 'Your Name',
      icon: Icons.person,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your name';
        }
        return null;
      },
    );
  }

  Widget _buildContactField() {
    return _buildEnhancedFormField(
      controller: _contactController,
      label: 'Contact Number',
      icon: Icons.phone,
      keyboardType: TextInputType.phone,
      hintText: '+94771234567',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your contact number';
        }
        if (value.length < 10) {
          return 'Please enter a valid contact number';
        }
        return null;
      },
    );
  }

  Widget _buildFromField() {
    return _buildEnhancedFormField(
      controller: _fromController,
      label: 'From',
      icon: Icons.location_on,
      suffixIcon: Container(
        padding: const EdgeInsets.all(12),
        child: Icon(
          Icons.search,
          color: Colors.white.withValues(alpha: 0.6),
          size: 20,
        ),
      ),
      onTap: () =>
          _showLocationSuggestions(_fromController.text, _fromController),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter starting location';
        }
        return null;
      },
    );
  }

  Widget _buildToField() {
    return _buildEnhancedFormField(
      controller: _toController,
      label: 'To',
      icon: Icons.flag,
      suffixIcon: Container(
        padding: const EdgeInsets.all(12),
        child: Icon(
          Icons.search,
          color: Colors.white.withValues(alpha: 0.6),
          size: 20,
        ),
      ),
      onTap: () => _showLocationSuggestions(_toController.text, _toController),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter destination';
        }
        return null;
      },
    );
  }

  Widget _buildDateField() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.12),
            Colors.white.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          Icons.calendar_today,
          color: Colors.white.withValues(alpha: 0.8),
          size: 20,
        ),
        title: Text(
          _selectedDate == null
              ? 'Departure Date'
              : '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
          style: TextStyle(
            color: _selectedDate == null
                ? Colors.white.withValues(alpha: 0.8)
                : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.white.withValues(alpha: 0.6),
          size: 16,
        ),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now().add(const Duration(days: 1)),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 30)),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Color(0xFF2563EB),
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            setState(() => _selectedDate = picked);
          }
        },
      ),
    );
  }

  Widget _buildTimeField() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.12),
            Colors.white.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          Icons.access_time,
          color: Colors.white.withValues(alpha: 0.8),
          size: 20,
        ),
        title: Text(
          _selectedTime == null
              ? 'Departure Time'
              : _selectedTime!.format(context),
          style: TextStyle(
            color: _selectedTime == null
                ? Colors.white.withValues(alpha: 0.8)
                : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.white.withValues(alpha: 0.6),
          size: 16,
        ),
        onTap: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Color(0xFF2563EB),
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            setState(() => _selectedTime = picked);
          }
        },
      ),
    );
  }

  Widget _buildVehicleTypeField() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.12),
            Colors.white.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedVehicleType,
        items: _vehicleTypes
            .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(
                    type,
                    style: const TextStyle(
                      color: Color(0xFF1E3A8A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ))
            .toList(),
        onChanged: (value) {
          setState(() => _selectedVehicleType = value);
        },
        decoration: InputDecoration(
          labelText: 'Vehicle Type',
          labelStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.directions_car,
              color: Colors.white.withValues(alpha: 0.8),
              size: 20,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
        ),
        dropdownColor: Colors.white,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a vehicle type';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSeatsField() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.12),
            Colors.white.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.airline_seat_recline_normal,
                color: Colors.white.withValues(alpha: 0.8),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Available Seats',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.2),
                      Colors.white.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: _availableSeats > 1
                      ? () => setState(() => _availableSeats--)
                      : null,
                  icon: const Icon(
                    Icons.remove,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.25),
                      Colors.white.withValues(alpha: 0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '$_availableSeats',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.2),
                      Colors.white.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: _availableSeats < 8
                      ? () => setState(() => _availableSeats++)
                      : null,
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return AnimatedBuilder(
      animation: _pulseAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Colors.white,
                  Color(0xFFF8FAFC),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _proceedToMap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.map,
                          color: Color(0xFF2563EB),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Continue to Route Map',
                          style: TextStyle(
                            color: Color(0xFF2563EB),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}

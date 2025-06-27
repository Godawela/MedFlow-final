//device list in a one category
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:med/pages/user%20pages/machine_details.dart';
import 'dart:convert';
import 'package:med/widgets/appbar.dart';

class DeviceListPage extends StatefulWidget {
  final String category;

  const DeviceListPage({super.key, required this.category});

  @override
  _DeviceListPageState createState() => _DeviceListPageState();
}

class _DeviceListPageState extends State<DeviceListPage>
    with TickerProviderStateMixin {
  List<dynamic> devices = [];
  bool isLoading = true;
  String? error;
  String? categoryDescription;
  String? categoryImage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _loadData();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _refreshTimer?.cancel();

    super.dispose();
  }

  // Load both devices and category description
  Future<void> _loadData() async {
    await Future.wait([
      fetchDevicesByCategory(),
      fetchCategoryDescription(),
    ]);
  }

  Future<void> fetchDevicesByCategory() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://10.0.2.2:8000/api/devices/category/${widget.category}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          devices = json.decode(response.body);
          isLoading = false;
        });
        _animationController.forward();
      } else {
        setState(() {
          error = 'Failed to load devices: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> fetchCategoryDescription() async {
    try {
      debugPrint('Fetching category description for ${widget.category}');
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/category/name/${widget.category}'),
      );

      debugPrint(
          'Category description response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Received category data: $data');
        setState(() {
          categoryDescription = data['description'];
          categoryImage = data['image'];
        });
        debugPrint('Set category image to: $categoryImage');
      } else {
        debugPrint('Failed to fetch category description');
        setState(() {
          categoryDescription = 'No description available.';
        });
      }
    } catch (e) {
      debugPrint('Error fetching category description: $e');
      setState(() {
        categoryDescription = 'Error fetching description.';
      });
    }
  }

  //method to construct the full image URL
  String? getImageUrl() {
    if (categoryImage == null || categoryImage!.isEmpty) return null;

    // Convert backslashes to forward slashes for URL
    String imagePath = categoryImage!.replaceAll('\\', '/');

    // Construct full URL
    return 'http://10.0.2.2:8000/$imagePath';
  }

  // Get icon for device type
  IconData getDeviceIcon(String deviceName) {
    final lowerName = deviceName.toLowerCase();
    if (lowerName.contains('mri')) return Icons.medical_information_rounded;
    if (lowerName.contains('ct')) return Icons.scanner_rounded;
    if (lowerName.contains('x-ray') || lowerName.contains('xray')) {
      return Icons.healing_rounded;
    }
    if (lowerName.contains('ultrasound')) return Icons.monitor_heart_rounded;
    if (lowerName.contains('ecg')) return Icons.favorite_rounded;
    if (lowerName.contains('ventilator')) return Icons.air_rounded;
    if (lowerName.contains('dialysis')) return Icons.water_drop_rounded;
    if (lowerName.contains('lab') || lowerName.contains('laboratory')) {
      return Icons.science_rounded;
    }
    return Icons.medical_services_rounded;
  }

  // Get color for device card
  List<Color> getDeviceColors(int index) {
    final colorSets = [
      [Colors.blue.shade400, Colors.blue.shade600],
      [Colors.green.shade400, Colors.green.shade600],
      [Colors.purple.shade400, Colors.purple.shade600],
      [Colors.orange.shade400, Colors.orange.shade600],
      [Colors.red.shade400, Colors.red.shade600],
      [Colors.teal.shade400, Colors.teal.shade600],
      [Colors.indigo.shade400, Colors.indigo.shade600],
      [Colors.pink.shade400, Colors.pink.shade600],
    ];
    return colorSets[index % colorSets.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          CurvedAppBar(
            title: widget.category,
            isProfileAvailable: false,
            showIcon: true,
            isBack: true,
          ),
          Expanded(
            child: isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              )
                            ],
                          ),
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.deepPurple.shade400,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Loading devices...',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.error_outline_rounded,
                                size: 48,
                                color: Colors.red.shade400,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Oops! Something went wrong',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              error!,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.red.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  isLoading = true;
                                  error = null;
                                });
                                fetchDevicesByCategory();
                              },
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Try Again'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade500,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _fadeAnimation,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  // Category header section
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.deepPurple.shade400,
                                          Colors.deepPurple.shade600,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.deepPurple
                                              .withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 100,
                                              height: 100,
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: getImageUrl() != null
                                                    ? Image.network(
                                                        getImageUrl()!,
                                                        width: 80,
                                                        height: 80,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context,
                                                            error, stackTrace) {
                                                          debugPrint(
                                                              'Error loading image: $error');
                                                          return Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(12),
                                                            child: Icon(
                                                              getDeviceIcon(
                                                                  widget
                                                                      .category),
                                                              size: 28,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          );
                                                        },
                                                        loadingBuilder: (context,
                                                            child,
                                                            loadingProgress) {
                                                          if (loadingProgress ==
                                                              null) {
                                                            return child;
                                                          }
                                                          return Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(16),
                                                            child:
                                                                CircularProgressIndicator(
                                                              value: loadingProgress
                                                                          .expectedTotalBytes !=
                                                                      null
                                                                  ? loadingProgress
                                                                          .cumulativeBytesLoaded /
                                                                      loadingProgress
                                                                          .expectedTotalBytes!
                                                                  : null,
                                                              strokeWidth: 2,
                                                              valueColor:
                                                                  const AlwaysStoppedAnimation<
                                                                      Color>(
                                                                Colors.white,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      )
                                                    : Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(12),
                                                        child: Icon(
                                                          getDeviceIcon(
                                                              widget.category),
                                                          size: 28,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Text(
                                                widget.category,
                                                style: GoogleFonts.inter(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (categoryDescription != null) ...[
                                          const SizedBox(height: 16),
                                          Text(
                                            categoryDescription!,
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              color:
                                                  Colors.white.withOpacity(0.9),
                                              height: 1.5,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // Devices count
                                  Row(
                                    children: [
                                      Text(
                                        'Available Devices',
                                        style: GoogleFonts.inter(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.deepPurple.shade100,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '${devices.length} devices',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.deepPurple.shade700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // Devices list
                                  Expanded(
                                    child: devices.isEmpty
                                        ? Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.devices_other_rounded,
                                                  size: 60,
                                                  color: Colors.grey.shade400,
                                                ),
                                                const SizedBox(height: 16),
                                                Text(
                                                  'No devices found in ${widget.category}',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 16,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : ListView.builder(
                                            physics:
                                                const BouncingScrollPhysics(),
                                            itemCount: devices.length,
                                            itemBuilder: (context, index) {
                                              final device = devices[index];
                                              final colors =
                                                  getDeviceColors(index);
                                              final icon =
                                                  getDeviceIcon(device['name']);

                                              return TweenAnimationBuilder<
                                                  double>(
                                                duration: Duration(
                                                    milliseconds:
                                                        300 + (index * 100)),
                                                tween:
                                                    Tween(begin: 0.0, end: 1.0),
                                                builder:
                                                    (context, value, child) {
                                                  return Transform.scale(
                                                    scale: value,
                                                    child: Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              bottom: 16),
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          begin:
                                                              Alignment.topLeft,
                                                          end: Alignment
                                                              .bottomRight,
                                                          colors: colors,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: colors[0]
                                                                .withOpacity(
                                                                    0.3),
                                                            blurRadius: 8,
                                                            offset:
                                                                const Offset(
                                                                    0, 4),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Material(
                                                        color:
                                                            Colors.transparent,
                                                        child: InkWell(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                          onTap: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        MachineDetailPage(
                                                                  machineName:
                                                                      device[
                                                                          'name'],
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(16),
                                                            child: Row(
                                                              children: [
                                                                Container(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          12),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white
                                                                        .withOpacity(
                                                                            0.2),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            12),
                                                                  ),
                                                                  child: Icon(
                                                                    icon,
                                                                    size: 28,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    width: 16),
                                                                Expanded(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        device[
                                                                            'name'],
                                                                        style: GoogleFonts
                                                                            .inter(
                                                                          fontSize:
                                                                              18,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                      ),
                                                                      if (device['reference'] !=
                                                                              null &&
                                                                          device['reference']
                                                                              .toString()
                                                                              .isNotEmpty)
                                                                        Text(
                                                                          device[
                                                                              'reference'],
                                                                          style:
                                                                              GoogleFonts.inter(
                                                                            fontSize:
                                                                                14,
                                                                            color:
                                                                                Colors.white.withOpacity(0.9),
                                                                          ),
                                                                        ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                const Icon(
                                                                  Icons
                                                                      .chevron_right_rounded,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
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
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

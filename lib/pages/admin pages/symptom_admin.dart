import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:med/pages/admin%20pages/symptom_details_page_admin.dart';
import 'dart:convert';

import 'package:med/routes/router.dart';
import 'package:med/widgets/appbar.dart';
import 'package:med/widgets/user_greetings.dart';

class SymptomPageAdmin extends StatefulWidget {
  const SymptomPageAdmin({super.key});

  @override
  State<SymptomPageAdmin> createState() => _SymptomPageAdminState();
}

class _SymptomPageAdminState extends State<SymptomPageAdmin>
    with TickerProviderStateMixin {
  List<dynamic> symptoms = [];
  bool isLoading = true;
  String? error;
  late AnimationController _animationController;
  late AnimationController _headerAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
    Timer? _refreshTimer;


  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    fetchSymptoms();
     _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchSymptoms();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _headerAnimationController.dispose();
        _refreshTimer?.cancel();

    super.dispose();
  }

  Future<void> fetchSymptoms() async {
    try {
      final response =
          await http.get(Uri.parse('https://medflow-phi.vercel.app/api/symptoms'));

      if (response.statusCode == 200) {
        final List<dynamic> symptomData = json.decode(response.body);
        setState(() {
          symptoms = symptomData;
          isLoading = false;
        });
        _animationController.forward();
        _headerAnimationController.forward();
      } else {
        setState(() {
          error = 'Failed to load symptoms: ${response.statusCode}';
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

  // Get icon for symptom
  IconData getSymptomIcon(String symptom) {
    switch (symptom.toLowerCase()) {
      case 'headache':
        return Icons.sick_rounded;
      case 'fever':
        return Icons.thermostat_rounded;
      case 'cough':
        return Icons.air_rounded;
      case 'pain':
        return Icons.broken_image;
      case 'nausea':
        return Icons.sick_outlined;
      case 'fatigue':
        return Icons.bedtime_rounded;
      case 'dizziness':
        return Icons.rotate_right_rounded;
      case 'rash':
        return Icons.texture_rounded;
      default:
        return Icons.medical_services_rounded;
    }
  }

  // Get color for symptom
  List<Color> getSymptomColors(int index) {
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
          const CurvedAppBar(
            title: 'Symptoms',
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
                              ),
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
                          'Loading symptoms...',
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
                                fetchSymptoms();
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
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    // Header section
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
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.2),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const CircleAvatar(
                                              radius: 32,
                                              backgroundImage: AssetImage(
                                                  'assets/images/logo.png'),
                                              backgroundColor: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          const UserGreeting(),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Select a symptom to explore possible conditions and treatments',
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              color:
                                                  Colors.white.withOpacity(0.9),
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    // Symptoms count
                                    Row(
                                      children: [
                                        Text(
                                          'Common Symptoms',
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
                                            '${symptoms.length} symptoms',
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

                                    // Symptoms grid
                                    Expanded(
                                      child: GridView.builder(
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          childAspectRatio: 1.2,
                                          crossAxisSpacing: 16,
                                          mainAxisSpacing: 16,
                                        ),
                                        itemCount: symptoms.length,
                                        itemBuilder: (context, index) {
                                          final symptom =
                                              symptoms[index]['name'];
                                          final colors =
                                              getSymptomColors(index);
                                          final icon = getSymptomIcon(symptom);

                                          return TweenAnimationBuilder<double>(
                                            duration: Duration(
                                                milliseconds:
                                                    300 + (index * 100)),
                                            tween: Tween(begin: 0.0, end: 1.0),
                                            builder: (context, value, child) {
                                              return Transform.scale(
                                                scale: value,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      colors: colors,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: colors[0]
                                                            .withOpacity(0.3),
                                                        blurRadius: 8,
                                                        offset:
                                                            const Offset(0, 4),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Material(
                                                    color: Colors.transparent,
                                                    child: InkWell(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                SymptomDetailPageAdmin(
                                                              symptomName:
                                                                  symptom,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(16),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(12),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .white
                                                                    .withOpacity(
                                                                        0.2),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            16),
                                                              ),
                                                              child: Icon(
                                                                icon,
                                                                size: 28,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 10),
                                                            Flexible(
                                                              child: Text(
                                                                symptom,
                                                                style:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 6),
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                horizontal: 6,
                                                                vertical: 3,
                                                              ),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .white
                                                                    .withOpacity(
                                                                        0.2),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                              ),
                                                              child: Text(
                                                                'View Details',
                                                                style:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  fontSize: 11,
                                                                  color: Colors
                                                                      .white
                                                                      .withOpacity(
                                                                          0.9),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
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
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add a new machine category
          context.router.push(const AddSymptomRoute());
        },
        backgroundColor: Colors.deepPurple.shade500,
        foregroundColor: Colors.white,
        elevation: 8,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Add a new Symptom',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

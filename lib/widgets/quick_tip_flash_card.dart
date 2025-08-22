import 'package:flutter/material.dart';
import 'package:med/models/quick_tip.dart';
import 'package:med/services/quick_tip_service.dart';

class QuickTipsFlashcards extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const QuickTipsFlashcards({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  _QuickTipsFlashcardsState createState() => _QuickTipsFlashcardsState();
}

class _QuickTipsFlashcardsState extends State<QuickTipsFlashcards>
    with TickerProviderStateMixin {
  late AnimationController _cardController;
  late AnimationController _progressController;
  late AnimationController _floatingController;
  late AnimationController _rippleController;

  late Animation<double> _cardAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _rippleAnimation;

  final PageController _pageController = PageController();
  int _currentIndex = 0;
  List<QuickTip> _tips = [];
  bool _isLoading = true;
  bool _showContent = false;
  bool _isRefreshing = false;
  String? _errorMessage;

  // Color themes for different cards
  final List<List<Color>> _cardThemes = [
    [const Color(0xFF6C5CE7), const Color(0xFFA29BFE)], // Purple
    [const Color(0xFF00B894), const Color(0xFF55EFC4)], // Green
    [const Color(0xFFE17055), const Color(0xFFFAB1A0)], // Orange
    [const Color(0xFF0984E3), const Color(0xFF74B9FF)], // Blue
    [const Color(0xFFE84393), const Color(0xFFFD79A8)], // Pink
    [const Color(0xFF00CEC9), const Color(0xFF81ECEC)], // Teal
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadQuickTips();
  }

  void _initializeAnimations() {
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _cardAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.elasticOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));

    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));
  }

  Future<void> _loadQuickTips({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _isRefreshing = true;
        _errorMessage = null;
      });
    } else {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final response = await QuickTipsService.getQuickTips(widget.categoryId);
      
      if (response != null && response.tips.isNotEmpty) {
        setState(() {
          _tips = response.tips;
          _isLoading = false;
          _isRefreshing = false;
          _errorMessage = null;
          
          // Reset to first card if current index is out of bounds
          if (_currentIndex >= _tips.length) {
            _currentIndex = 0;
            _showContent = false;
          }
        });
        
        if (!isRefresh) {
          _cardController.forward();
          _progressController.forward();
        }
      } else {
        setState(() {
          _tips = [];
          _isLoading = false;
          _isRefreshing = false;
          _errorMessage = 'No tips available for this category';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
        _errorMessage = 'Failed to load tips. Please try again.';
      });
    }
  }

  // Method to refresh data - can be called from UI
  Future<void> _refreshData() async {
    await _loadQuickTips(isRefresh: true);
  }

  @override
  void dispose() {
    _cardController.dispose();
    _progressController.dispose();
    _floatingController.dispose();
    _rippleController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFF6C5CE7),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildModernAppBar(),
              if (!_isLoading && _tips.isNotEmpty) _buildProgressIndicator(),
              Expanded(
                child: _isLoading 
                    ? _buildLoadingState() 
                    : _errorMessage != null 
                        ? _buildErrorState()
                        : _tips.isEmpty 
                            ? _buildEmptyState()
                            : _buildCardView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernAppBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Color(0xFF2D3436),
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.categoryName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D3436),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const Text(
                  'Flashcard Study Session',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF636E72),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Refresh button
          GestureDetector(
            onTap: _isRefreshing ? null : _refreshData,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _isRefreshing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
                      ),
                    )
                  : const Icon(
                      Icons.refresh,
                      color: Color(0xFF2D3436),
                      size: 18,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          if (!_isLoading && _tips.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getThemeColors(_currentIndex)[0],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentIndex + 1}/${_tips.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: 6,
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(3),
      ),
      child: AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) {
          return FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor:
                (_currentIndex + 1) / _tips.length * _progressAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getThemeColors(_currentIndex),
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Preparing your flashcards...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF636E72),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5F5),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFFFE5E5),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 40,
              color: Color(0xFFE74C3C),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 20,
              color: Color(0xFF2D3436),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Failed to load content',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF636E72),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _refreshData,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh, size: 18),
                SizedBox(width: 8),
                Text('Try Again'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardView() {
    if (_tips.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: const Color(0xFF6C5CE7),
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                  _showContent = false;
                });
                _progressController.forward();
              },
              itemCount: _tips.length,
              itemBuilder: (context, index) {
                return _buildFlashcard(_tips[index], index);
              },
            ),
          ),
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  Widget _buildFlashcard(QuickTip tip, int index) {
    final colors = _getThemeColors(index);

    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.all(20),
          child: AnimatedBuilder(
            animation: _floatingAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatingAnimation.value),
                child: GestureDetector(
                  onTap: () => _toggleCard(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.elasticOut,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: colors[0].withValues(alpha:0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _showContent
                                ? [Colors.white, Colors.grey[50]!]
                                : colors,
                          ),
                        ),
                        child: _showContent
                            ? _buildCardBack(tip, colors)
                            : _buildCardFront(tip, colors),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCardFront(QuickTip tip, List<Color> colors) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.2),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              _getIconData(tip.icon),
              size: 36,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            tip.title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...List.generate(
                    5,
                    (i) => Icon(
                          i < tip.priority ? Icons.star : Icons.star_border,
                          color: Colors.white,
                          size: 16,
                        )),
                const SizedBox(width: 8),
                const Text(
                  'Priority',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          AnimatedBuilder(
            animation: _rippleAnimation,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha:0.2),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.white.withValues(alpha:0.3),
                    width: 1,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.touch_app,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Tap to reveal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(QuickTip tip, List<Color> colors) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: colors),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconData(tip.icon),
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tip.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE8E8E8),
                  width: 1,
                ),
              ),
              child: Text(
                tip.content,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF2D3436),
                  height: 1.6,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.touch_app,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Tap to flip back',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavButton(
            Icons.arrow_back_ios,
            _currentIndex > 0 ? _previousCard : null,
            'Previous',
          ),
          Row(
            children: List.generate(_tips.length, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentIndex == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentIndex == index
                      ? _getThemeColors(index)[0]
                      : const Color(0xFFE8E8E8),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          _buildNavButton(
            Icons.arrow_forward_ios,
            _currentIndex < _tips.length - 1 ? _nextCard : null,
            'Next',
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback? onPressed, String label) {
    bool isEnabled = onPressed != null;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isEnabled ? Colors.white : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEnabled ? const Color(0xFFE8E8E8) : const Color(0xFFF0F0F0),
            width: 1,
          ),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isEnabled ? const Color(0xFF2D3436) : const Color(0xFFB2BEC3),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isEnabled ? const Color(0xFF2D3436) : const Color(0xFFB2BEC3),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFE8E8E8),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              size: 40,
              color: Color(0xFF636E72),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Tips Available',
            style: TextStyle(
              fontSize: 20,
              color: Color(0xFF2D3436),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check back later for new content!',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF636E72),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _refreshData,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh, size: 18),
                SizedBox(width: 8),
                Text('Refresh'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleCard() {
    setState(() {
      _showContent = !_showContent;
    });
    _rippleController.forward().then((_) {
      _rippleController.reset();
    });
  }

  void _nextCard() {
    if (_currentIndex < _tips.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  List<Color> _getThemeColors(int index) {
    return _cardThemes[index % _cardThemes.length];
  }

  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'hub':
        return Icons.hub;
      case 'battery':
        return Icons.battery_full;
      case 'shield':
        return Icons.security;
      case 'user':
        return Icons.person;
      case 'steps':
        return Icons.stairs;
      case 'lightbulb':
      default:
        return Icons.lightbulb;
    }
  }
}
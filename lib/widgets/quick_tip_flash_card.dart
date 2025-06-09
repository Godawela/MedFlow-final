import 'package:flutter/material.dart';
import 'package:med/models/quick_tip.dart';
import 'package:med/services/quick_tip_service.dart';

class QuickTipsFlashcards extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const QuickTipsFlashcards({
    Key? key,
    required this.categoryId,
    required this.categoryName,
  }) : super(key: key);

  @override
  _QuickTipsFlashcardsState createState() => _QuickTipsFlashcardsState();
}

class _QuickTipsFlashcardsState extends State<QuickTipsFlashcards>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;
  
  PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentIndex = 0;
  List<QuickTip> _tips = [];
  bool _isLoading = true;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadQuickTips();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1.5),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(_shimmerController);
  }

  Future<void> _loadQuickTips() async {
    final response = await QuickTipsService.getQuickTips(widget.categoryId);
    if (response != null) {
      setState(() {
        _tips = response.tips;
        _isLoading = false;
      });
      _slideController.forward();
      _fadeController.forward();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _shimmerController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFF6B73FF),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildContent(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildModernHeader(),
        Expanded(
          child: _isLoading ? _buildEnhancedLoadingState() : _buildFlashcardStack(),
        ),
      ],
    );
  }

Widget _buildModernHeader() {
  return Container(
    padding: EdgeInsets.fromLTRB(24, 20, 24, 24),
    child: Row(
      children: [
        // Back button
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Add this
            children: [
              Text(
                widget.categoryName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(
                'Quick Tips Collection',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
        if (!_isLoading && _tips.isNotEmpty)
          Container(
            constraints: BoxConstraints(minWidth: 60), // Add constraints
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              '${_currentIndex + 1}/${_tips.length}',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    ),
  );
}

 Widget _buildEnhancedLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.white.withOpacity(0.7),
                  size: 30,
                ),
              ],
            ),
          ),
          SizedBox(height: 32),
          Text(
            'Loading Quick Tips...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcardStack() {
    if (_tips.isEmpty) {
      return _buildEnhancedEmptyState();
    }

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
                _isFlipped = false;
              });
            },
            itemCount: _tips.length,
            itemBuilder: (context, index) {
              return _buildEnhancedFlashcard(_tips[index], index);
            },
          ),
        ),
        _buildEnhancedFooter(),
      ],
    );
  }

Widget _buildEnhancedFlashcard(QuickTip tip, int index) {
  return AnimatedBuilder(
    animation: _pageController,
    builder: (context, child) {

     
        double value = 1.0;
        double parallax = 0.0;
        
        if (_pageController.position.haveDimensions) {
          value = _pageController.page! - index;
          parallax = value * 0.5;
          value = (1 - (value.abs() * 0.4)).clamp(0.0, 1.0);
        }
        
        return Transform.translate(
          offset: Offset(parallax * 100, 0),
          child: Transform.scale(
            scale: value,
            child: Opacity(
              opacity: value,
              child: GestureDetector(
                onTap: () => _toggleFlip(),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              // BoxShadow(
                              //   color: Colors.black.withOpacity(0.3),
                              //   blurRadius: 20,
                              //   offset: Offset(0, 10),
                              //   spreadRadius: 5,
                              // ),
                              BoxShadow(
  color: Colors.black.withOpacity(0.2),
  blurRadius: 10, // Ensure this is positive
  offset: Offset(0, 4),
),
                              // BoxShadow(
                              //   color: Colors.white.withOpacity(0.1),
                              //   blurRadius: 1,
                              //   offset: Offset(0, 1),
                              // ),
                              BoxShadow(
  color: Colors.black.withOpacity(0.2),
  blurRadius: 10, // Ensure this is positive
  offset: Offset(0, 4),
),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white,
                                    Colors.grey[50]!,
                                  ],
                                ),
                              ),
                              child: _isFlipped && _currentIndex == index
                                  ? _buildFlashcardBack(tip)
                                  : _buildFlashcardFront(tip),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFlashcardFront(QuickTip tip) {
    return Container(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF667eea).withOpacity(0.1),
                  Color(0xFF764ba2).withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: Color(0xFF667eea).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              _getIconData(tip.icon),
              size: 48,
              color: Color(0xFF667eea),
            ),
          ),
          SizedBox(height: 32),
          Text(
            tip.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
              letterSpacing: 0.5,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 24),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF667eea).withOpacity(0.1),
                  Color(0xFF764ba2).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Color(0xFF667eea).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star,
                  color: Color(0xFF667eea),
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  'Priority ${tip.priority}/5',
                  style: TextStyle(
                    color: Color(0xFF667eea),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 32),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.touch_app,
                  color: Colors.grey[600],
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  'Tap to reveal details',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcardBack(QuickTip tip) {
  return Container(
    padding: EdgeInsets.all(32),
    constraints: BoxConstraints(
      minHeight: MediaQuery.of(context).size.height * 0.5, // Add minimum height constraint
    ),
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min, // Use min to prevent expansion
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF667eea).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconData(tip.icon),
                  size: 24,
                  color: Color(0xFF667eea),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  tip.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  maxLines: 2, // Limit title to 2 lines
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 32),
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Text(
              tip.content,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.6,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          SizedBox(height: 24),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.touch_app,
                  color: Colors.grey[600],
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  'Tap to go back',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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
Widget _buildEnhancedFooter() {
  return Container(
    padding: EdgeInsets.fromLTRB(32, 24, 32, 32),
    child: Column(
      children: [
        SingleChildScrollView( // Add this to prevent overflow
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_tips.length, (index) {
              bool isActive = _currentIndex == index;
              return AnimatedContainer(
  duration: Duration(milliseconds: 400),
  curve: Curves.elasticOut,
  margin: EdgeInsets.symmetric(horizontal: 4),
  height: 6,
  width: isActive ? 24 : 6,
  decoration: BoxDecoration(
    color: isActive 
        ? Colors.white 
        : Colors.white.withOpacity(0.4),
    borderRadius: BorderRadius.circular(3),
    // Remove or simplify the boxShadow here
    boxShadow: isActive ? [
      BoxShadow(
        color: Colors.white.withOpacity(0.3),
        blurRadius: 4.0, // Positive value
        offset: Offset(0, 0),
      ),
    ] : null,
  ),
);
            }),
          ),
        ),
        SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavButton(
              Icons.arrow_back_ios,
              _currentIndex > 0 ? _previousTip : null,
              'Previous',
            ),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min, // Add this
                children: [
                  Icon(
                    Icons.swipe_left,
                    color: Colors.white.withOpacity(0.7),
                    size: 20,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Swipe to navigate',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            _buildNavButton(
              Icons.arrow_forward_ios,
              _currentIndex < _tips.length - 1 ? _nextTip : null,
              'Next',
            ),
          ],
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
        width: 80,
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isEnabled 
              ? Colors.white.withOpacity(0.2) 
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(isEnabled ? 0.3 : 0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white.withOpacity(isEnabled ? 1.0 : 0.5),
              size: 20,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(isEnabled ? 0.9 : 0.5),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.lightbulb_outline,
              size: 64,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          SizedBox(height: 32),
          Text(
            'No Quick Tips Available',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'New tips will be added soon!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleFlip() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });
  }

  void _nextTip() {
    if (_currentIndex < _tips.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _previousTip() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
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
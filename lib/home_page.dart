import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'settings_page.dart';
import 'course_detail_page.dart';
import 'news_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;
  String? _profileImageBase64;
  final _searchController = TextEditingController();
  int _selectedIndex = 0;
  final List<Widget> _pages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData().then((_) {
      setState(() {
        _pages.addAll([
          HomeContent(profileImageBase64: _profileImageBase64),
          const NewsPage(),
          const SettingsPage(),
        ]);
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();
        if (userDoc.exists && mounted) {
          setState(() {
            _profileImageBase64 = userDoc.data()?['profileImage'];
            // Update the HomeContent with new profile image
            if (_pages.isNotEmpty) {
              _pages[0] = HomeContent(profileImageBase64: _profileImageBase64);
            }
          });
        }
      } catch (e) {
        debugPrint('Error loading user data: $e');
      }
    }
  }

  ImageProvider? _getImageProvider(String? base64String) {
    if (base64String == null) return null;
    try {
      return MemoryImage(base64Decode(base64String));
    } catch (e) {
      return null;
    }
  }

  Widget _buildNavBarItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadUserData(); // Reload user data when widget updates
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primaryContainer,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App logo or icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                // Loading indicator
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                // Loading text
                const Text(
                  'Loading your courses...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            _pages[_selectedIndex],
            // Bottom Navigation Bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNavBarItem(0, Icons.home_rounded, 'Discover'),
                        _buildNavBarItem(1, Icons.newspaper_rounded, 'News'),
                        _buildNavBarItem(2, Icons.settings_rounded, 'Settings'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Create a new widget for the home content
class HomeContent extends StatelessWidget {
  final String? profileImageBase64;

  const HomeContent({
    super.key,
    this.profileImageBase64,
  });

  ImageProvider? _getImageProvider(String? base64String) {
    if (base64String == null) return null;
    try {
      return MemoryImage(base64Decode(base64String));
    } catch (e) {
      return null;
    }
  }

  void _showAllCategories(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      'All Categories',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 20),
                    _buildCategorySection(
                      context,
                      'Programming',
                      [
                        (
                          'Swift Programming',
                          'assets/images/swift_bg.jpg',
                          Colors.black
                        ),
                        (
                          'JavaScript Fundamentals',
                          'assets/images/js_bg.jpg',
                          Colors.amber.shade700
                        ),
                        (
                          'Flutter Development',
                          'assets/images/flutter_bg.jpg',
                          Colors.blue
                        ),
                        (
                          'Python Basics',
                          'assets/images/python_bg.jpg',
                          Colors.green.shade700
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    _buildCategorySection(
                      context,
                      'Design',
                      [
                        (
                          'Adobe Photoshop',
                          'assets/images/ps_bg.jpg',
                          Colors.blue.shade900
                        ),
                        (
                          'Figma UI/UX Design',
                          'assets/images/figma_bg.jpg',
                          Colors.pink.shade700
                        ),
                        (
                          'Adobe Premiere Pro',
                          'assets/images/pr_bg.jpg',
                          Colors.purple.shade900
                        ),
                        (
                          'AI & Machine Learning',
                          'assets/images/ai_bg.jpg',
                          Colors.purple.shade700
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, String title,
      List<(String, String, Color)> courses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final (title, image, color) = courses[index];
            return _buildCourseCard(context, title, image, color);
          },
        ),
      ],
    );
  }

  void _handleSearch(BuildContext context, String query) {
    if (query.isEmpty) return;

    final allCourses = [
      ('Swift Programming', 'assets/images/swift_bg.jpg', Colors.black),
      (
        'JavaScript Fundamentals',
        'assets/images/js_bg.jpg',
        Colors.amber.shade700
      ),
      ('Flutter Development', 'assets/images/flutter_bg.jpg', Colors.blue),
      ('Python Basics', 'assets/images/python_bg.jpg', Colors.green.shade700),
      ('Adobe Photoshop', 'assets/images/ps_bg.jpg', Colors.blue.shade900),
      (
        'Figma UI/UX Design',
        'assets/images/figma_bg.jpg',
        Colors.pink.shade700
      ),
      ('Adobe Premiere Pro', 'assets/images/pr_bg.jpg', Colors.purple.shade900),
      (
        'AI & Machine Learning',
        'assets/images/ai_bg.jpg',
        Colors.purple.shade700
      ),
    ];

    final searchResults = allCourses
        .where(
          (course) => course.$1.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      'Search Results',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Found ${searchResults.length} courses for "$query"',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 20),
                    if (searchResults.isEmpty)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No courses found',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final (title, image, color) = searchResults[index];
                          return _buildCourseCard(context, title, image, color);
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;
    final firstName = user?.displayName?.split(' ').first ?? 'there';
    final searchController = TextEditingController();

    return CustomScrollView(
      slivers: [
        // Header with Profile
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hey ${firstName},',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        'Find a course you want to learn',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800]
                          : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[700]
                              : Colors.grey[100],
                      backgroundImage: _getImageProvider(profileImageBase64),
                      child: profileImageBase64 == null
                          ? Icon(
                              Icons.person_outline_rounded,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white70
                                  : Colors.grey[600],
                              size: 28,
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Search Bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[850]
                    : Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                onSubmitted: (value) => _handleSearch(context, value),
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Search for anything',
                  hintStyle: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[500],
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : colorScheme.primary.withOpacity(0.7),
                    size: 24,
                  ),
                  suffixIcon: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.tune,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () =>
                          _handleSearch(context, searchController.text),
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Categories Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Browse categories',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    TextButton(
                      onPressed: () => _showAllCategories(context),
                      child: Text(
                        'See all',
                        style: TextStyle(color: colorScheme.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Programming Category
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Programming',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '5 Courses',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Row(
                          children: [
                            _buildCourseCard(
                              context,
                              'Python\nBasics',
                              'assets/images/python_bg.jpg',
                              Colors.green.shade700,
                            ),
                            const SizedBox(width: 16),
                            _buildCourseCard(
                              context,
                              'Flutter\nDevelopment',
                              'assets/images/flutter_bg.jpg',
                              Colors.blue,
                            ),
                            const SizedBox(width: 16),
                            _buildCourseCard(
                              context,
                              'JavaScript\nFundamentals',
                              'assets/images/js_bg.jpg',
                              Colors.amber.shade700,
                            ),
                            const SizedBox(width: 16),
                            _buildCourseCard(
                              context,
                              'Swift\nProgramming',
                              'assets/images/swift_bg.jpg',
                              Colors.grey.shade900,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Design Category
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Design',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '4 Courses',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Row(
                          children: [
                            _buildCourseCard(
                              context,
                              'Adobe\nPhotoshop',
                              'assets/images/ps_bg.jpg',
                              Colors.blue.shade900,
                            ),
                            const SizedBox(width: 16),
                            _buildCourseCard(
                              context,
                              'Figma UI/UX\nDesign',
                              'assets/images/figma_bg.jpg',
                              Colors.pink.shade700,
                            ),
                            const SizedBox(width: 16),
                            _buildCourseCard(
                              context,
                              'Adobe\nPremiere Pro',
                              'assets/images/pr_bg.jpg',
                              Colors.purple.shade900,
                            ),
                            const SizedBox(width: 16),
                            _buildCourseCard(
                              context,
                              'AI & Machine\nLearning',
                              'assets/images/ai_bg.jpg',
                              Colors.purple.shade700,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Add extra padding at bottom for navigation bar
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }

  Widget _buildCourseCard(
      BuildContext context, String title, String imagePath, Color color) {
    return GestureDetector(
      onTap: () {
        final course = Course(
          title: title,
          imagePath: imagePath,
          color: color,
          lessons: [
            CourseLesson(
              title: 'Introduction to Python Programming',
              duration: '13:45',
              videoId: title.contains('Python') ? 'kqtD5dpn9C8' : null,
              pdfUrl: 'assets/pdfs/python_intro.pdf',
            ),
            CourseLesson(
              title: 'Variables and Data Types',
              duration: '15:41',
              videoId: title.contains('Python') ? 'cQT33yu9pY8' : null,
              pdfUrl: 'assets/pdfs/python_variables.pdf',
            ),
            CourseLesson(
              title: 'Control Flow and Loops',
              duration: '18:22',
              videoId: title.contains('Python') ? '8ext9G7xspg' : null,
              pdfUrl: 'assets/pdfs/python_control_flow.pdf',
            ),
            CourseLesson(
              title: 'Functions and Modules',
              duration: '20:15',
              videoId: title.contains('Python') ? 'BVfCWuca9nw' : null,
              pdfUrl: 'assets/pdfs/python_functions.pdf',
            ),
          ],
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailPage(course: course),
          ),
        );
      },
      child: Container(
        width: 160,
        height: 200,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
            alignment: title.contains('JavaScript')
                ? Alignment.topCenter
                : Alignment.center,
            colorFilter: ColorFilter.mode(
              color.withOpacity(0.7),
              BlendMode.multiply,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Add a gradient overlay for better text readability
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        letterSpacing: -0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 140),
                    child: Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.play_circle_outline,
                              color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Start Learning',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
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
}

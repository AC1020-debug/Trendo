import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'dart:io';

// Import the separate pages
import 'product_page.dart';
import 'sales_history_page.dart';
import 'dashboard_page.dart';
import 'product_list_page.dart';
import 'notification_page.dart';
import 'edit_profile_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'services/news.dart';
import 'utils/utils.dart';
import 'widget/draggable_chatbot.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _errorMessage = "";

  String selectedProduct = 'rice';

  // News state
  bool isLoadingNews = true;
  int currentNewsIndex = 0;

  final String newsApiUrl = '${dotenv.env['NEWS_API_ENDPOINT']}/news';

  String selectedPeriod = 'daily';
  Timer? newsTimer;
  int currentIndex = 0;

  // Profile data state
  String userName = 'Unknown';
  String userEmail = 'unknown@example.com';
  String? userProfileImagePath;
  String? userPhone;
  String? userAddress;

  List<News> newsItems = [];

  final Map<String, Map<String, List<ChartData>>> forecastData = {
    'rice': {
      'daily': [
        ChartData('Mon', 120, 115),
        ChartData('Tue', 135, 130),
        ChartData('Wed', 110, 108),
        ChartData('Thu', 145, null),
        ChartData('Fri', 158, null),
        ChartData('Sat', 172, null),
        ChartData('Sun', 140, null),
      ],
      'weekly': [
        ChartData('W1', 850, 820),
        ChartData('W2', 920, 910),
        ChartData('W3', 780, 770),
        ChartData('W4', 1100, null),
        ChartData('W5', 1150, null),
      ],
      'monthly': [
        ChartData('Jan', 3200, 3100),
        ChartData('Feb', 3500, 3450),
        ChartData('Mar', 3800, 3750),
        ChartData('Apr', 4200, null),
        ChartData('May', 4500, null),
      ],
    },
    'egg': {
      'daily': [
        ChartData('Mon', 250, 240),
        ChartData('Tue', 280, 275),
        ChartData('Wed', 220, 215),
        ChartData('Thu', 300, null),
        ChartData('Fri', 320, null),
        ChartData('Sat', 350, null),
        ChartData('Sun', 280, null),
      ],
      'weekly': [
        ChartData('W1', 1800, 1750),
        ChartData('W2', 1950, 1920),
        ChartData('W3', 1700, 1680),
        ChartData('W4', 2100, null),
        ChartData('W5', 2200, null),
      ],
      'monthly': [
        ChartData('Jan', 7500, 7300),
        ChartData('Feb', 8200, 8100),
        ChartData('Mar', 7800, 7750),
        ChartData('Apr', 8800, null),
        ChartData('May', 9200, null),
      ],
    },
    'cooking_oil': {
      'daily': [
        ChartData('Mon', 180, 175),
        ChartData('Tue', 195, 190),
        ChartData('Wed', 170, 168),
        ChartData('Thu', 205, null),
        ChartData('Fri', 220, null),
        ChartData('Sat', 235, null),
        ChartData('Sun', 200, null),
      ],
      'weekly': [
        ChartData('W1', 1200, 1180),
        ChartData('W2', 1350, 1320),
        ChartData('W3', 1150, 1130),
        ChartData('W4', 1450, null),
        ChartData('W5', 1500, null),
      ],
      'monthly': [
        ChartData('Jan', 5000, 4900),
        ChartData('Feb', 5400, 5300),
        ChartData('Mar', 5800, 5700),
        ChartData('Apr', 6200, null),
        ChartData('May', 6500, null),
      ],
    },
    'chicken': {
      'daily': [
        ChartData('Mon', 300, 290),
        ChartData('Tue', 330, 320),
        ChartData('Wed', 280, 275),
        ChartData('Thu', 350, null),
        ChartData('Fri', 380, null),
        ChartData('Sat', 400, null),
        ChartData('Sun', 320, null),
      ],
      'weekly': [
        ChartData('W1', 2100, 2050),
        ChartData('W2', 2300, 2250),
        ChartData('W3', 2000, 1980),
        ChartData('W4', 2500, null),
        ChartData('W5', 2650, null),
      ],
      'monthly': [
        ChartData('Jan', 8800, 8600),
        ChartData('Feb', 9500, 9300),
        ChartData('Mar', 9200, 9000),
        ChartData('Apr', 10200, null),
        ChartData('May', 10800, null),
      ],
    },
    'sugar': {
      'daily': [
        ChartData('Mon', 160, 155),
        ChartData('Tue', 175, 170),
        ChartData('Wed', 150, 148),
        ChartData('Thu', 185, null),
        ChartData('Fri', 195, null),
        ChartData('Sat', 210, null),
        ChartData('Sun', 180, null),
      ],
      'weekly': [
        ChartData('W1', 1100, 1080),
        ChartData('W2', 1200, 1180),
        ChartData('W3', 1050, 1030),
        ChartData('W4', 1300, null),
        ChartData('W5', 1350, null),
      ],
      'monthly': [
        ChartData('Jan', 4500, 4400),
        ChartData('Feb', 4900, 4800),
        ChartData('Mar', 5100, 5000),
        ChartData('Apr', 5500, null),
        ChartData('May', 5800, null),
      ],
    },
  };

  @override
  void initState() {
    super.initState();
    _fetchNewsData();
    _startNewsTimer();
  }

  // Fetch news data from API
  Future<void> _fetchNewsData() async {
    setState(() => isLoadingNews = true);

    try {
      final response = await http.get(Uri.parse(newsApiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        List<News> fetchedNews = [];

        for (var news in data) {
          var content = news['content'];
          if (content != null &&
              content['is_relevant'] == true &&
              content['possible_impacts'] != null &&
              content['possible_impacts'].isNotEmpty) {
            String url = content['url'] ?? 'No URL available';
            String filteredContent =
                content['filtered_content'] ?? 'No filtered content available';

            // Convert dynamic list to Strings list
            List<String> impacts =
                (content['possible_impacts'] as List<dynamic>)
                    .map((item) => item.toString())
                    .toList();
            String headline = content['headline'] ?? 'No headline available';

            fetchedNews.add(News(url, filteredContent, impacts, headline));
          }
        }

        setState(() {
          newsItems = fetchedNews;
        });
      } else {
        setState(() {
          _errorMessage = "Error loading news: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error loading news: $e";
      });
    } finally {
      isLoadingNews = false;
    }
  }

  void _startNewsTimer() {
    newsTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (newsItems.isNotEmpty) {
        setState(() {
          currentNewsIndex = (currentNewsIndex + 1) % newsItems.length;
        });
      }
    });
  }

  @override
  void dispose() {
    newsTimer?.cancel();
    super.dispose();
  }

  // Navigate to edit profile page
  Future<void> _navigateToEditProfile() async {
    Navigator.pop(context); // Close drawer first

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          currentName: userName,
          currentEmail: userEmail,
          currentPhone: userPhone,
          currentAddress: userAddress,
          currentProfileImagePath: userProfileImagePath,
        ),
      ),
    );

    // Update profile data if changes were saved
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        userName = result['name'] ?? userName;
        userEmail = result['email'] ?? userEmail;
        userPhone = result['phone'] ?? userPhone;
        userAddress = result['address'] ?? userAddress;
        userProfileImagePath = result['profileImagePath'];
      });
    }
  }

  // Build drawer for left side navigation
  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          // Profile Header - Make it clickable
          GestureDetector(
            onTap: _navigateToEditProfile,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              decoration: BoxDecoration(color: Colors.blue[600]),
              child: Row(
                children: [
                  // Profile picture
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: _buildProfileImage(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Profile info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          userEmail,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Edit icon to indicate it's clickable
                  const Icon(Icons.edit, color: Colors.white70, size: 16),
                ],
              ),
            ),
          ),

          // Menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
              children: [
                _buildDrawerMenuItem(
                  icon: Icons.inventory,
                  title: 'Product List',
                  subtitle: 'View all added products',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProductListPage(),
                      ),
                    );
                  },
                ),
                const Divider(height: 40),
                _buildDrawerMenuItem(
                  icon: Icons.settings,
                  title: 'Settings',
                  subtitle: 'App preferences',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Settings - Coming soon!'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                ),
                _buildDrawerMenuItem(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  subtitle: 'Get help and support',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Help & Support - Coming soon!'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    if (userProfileImagePath != null && userProfileImagePath!.isNotEmpty) {
      // Show user's profile image
      return Image.file(
        File(userProfileImagePath!),
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // If file doesn't exist, show placeholder
          return _buildPlaceholderAvatar();
        },
      );
    } else {
      // Show placeholder
      return _buildPlaceholderAvatar();
    }
  }

  Widget _buildPlaceholderAvatar() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Icon(Icons.person, size: 25, color: Colors.grey[400]),
    );
  }

  Widget _buildDrawerMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.blue[600], size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[600], fontSize: 13),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show error message snackbar
    if (_errorMessage != null && _errorMessage!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_errorMessage != null) {
          showError(context, _errorMessage!);
        }
      });
    }
    return Stack(
      children: [
        Scaffold(
          drawer: _buildDrawer(), // Add drawer here
          appBar: AppBar(
            backgroundColor: Colors.blue[600],
            elevation: 4,
            leading: Builder(
              builder: (context) => IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: Icon(
                  Icons.menu,
                  color: Colors.white,
                  size: responsiveFont(context, 22, min: 18, max: 26),
                ),
              ),
            ),
            title: Text(
              'Trendo',
              style: TextStyle(
                fontSize: responsiveFont(context, 24, min: 18, max: 28),
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () {
                  // Navigate to notification page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationPage(),
                    ),
                  );
                },
                icon: Stack(
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: responsiveFont(context, 22, min: 18, max: 26),
                    ),
                    // Add notification badge
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: const Text(
                          '2',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              _buildNewsHeader(),
              Expanded(child: _buildCurrentPage()),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: currentIndex,
            selectedItemColor: Colors.blue[600],
            unselectedItemColor: Colors.grey[500],
            onTap: (index) {
              setState(() {
                currentIndex = index;
              });
              _navigateToPage(index);
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag_outlined),
                label: 'Add Product',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.upload_file),
                label: 'Sales Data',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
            ],
          ),
        ),
        DraggableChatbot(),
      ],
    );
  }

  Widget _buildNewsHeader() {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        setState(() {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! < 0) {
              // Swipe left → next news
              currentNewsIndex = (currentNewsIndex + 1) % newsItems.length;
            } else if (details.primaryVelocity! > 0) {
              // Swipe right → previous news
              currentNewsIndex =
                  (currentNewsIndex - 1 + newsItems.length) % newsItems.length;
            }
          }
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[600],
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: Colors.white,
                  size: responsiveFont(context, 16, min: 14, max: 18),
                ),
                const SizedBox(width: 6),
                Text(
                  'Live Market News',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: responsiveFont(context, 14, min: 12, max: 18),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: responsiveFont(context, 13, min: 11, max: 16) * 1.4 * 3,
              child: isLoadingNews
                  ? Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    )
                  : newsItems.isNotEmpty
                      ? Text(
                          newsItems[currentNewsIndex].headline,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize:
                                responsiveFont(context, 13, min: 11, max: 16),
                            height: 1.3,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.justify,
                        )
                      : Text(
                          'No news available at the moment',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize:
                                responsiveFont(context, 13, min: 11, max: 16),
                            height: 1.3,
                          ),
                        ),
            ),
            const SizedBox(height: 6),
            // Dots indicator
            if (newsItems.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(newsItems.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: currentNewsIndex == index ? 10 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: currentNewsIndex == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
          ],
        ),
      ),
    );
  }

  void _navigateToPage(int index) async {
    switch (index) {
      case 0:
        setState(() => currentIndex = 0);
        break;
      case 1:
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProductPage()),
        );
        setState(() => currentIndex = 0);
        break;
      case 2:
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SalesHistoryPage()),
        );
        setState(() => currentIndex = 0);
        break;
      case 3:
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DashboardPage()),
        );
        setState(() => currentIndex = 0);
        break;
    }
  }

  Widget _buildCurrentPage() {
    return _buildHomeTab();
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildQuickStats(),
          const SizedBox(height: 16),
          _buildProductSelection(),
          const SizedBox(height: 16),
          SizedBox(
            height: 400,
            child: _buildForecastChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.shopping_basket,
              label: 'Total Products',
              value: '5',
              color: Colors.blue,
            ),
          ),
          Container(
            width: 1,
            height: 50,
            color: Colors.grey[200],
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.inventory_2,
              label: 'In Stock',
              value: '1,234',
              color: Colors.green,
            ),
          ),
          Container(
            width: 1,
            height: 50,
            color: Colors.grey[200],
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.warning_amber_rounded,
              label: 'Low Stock',
              value: '2',
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProductSelection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Product',
            style: TextStyle(
              fontSize: responsiveFont(context, 16, min: 14, max: 18),
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          // Grid of products (3 columns, 2 rows)
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.0,
            children: [
              _buildProductCard(
                  Icons.grass, 'Rice', 'rice', Colors.green[600]!),
              _buildProductCard(
                  Icons.egg_outlined, 'Egg', 'egg', Colors.orange[600]!),
              _buildProductCard(Icons.water_drop, 'Cooking Oil',
                  'cooking_oil', Colors.amber[700]!),
              _buildProductCard(
                  MdiIcons.foodDrumstick, 'Chicken', 'chicken', Colors.red[600]!),
              _buildProductCard(
                  MdiIcons.sack, 'Sugar', 'sugar', Colors.pink[600]!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(
      IconData icon, String label, String value, Color color) {
    bool isSelected = selectedProduct == value;
    return GestureDetector(
      onTap: () => setState(() => selectedProduct = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? color : Colors.grey[600],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 11,
                color: isSelected ? color : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildActionButton(
                icon: Icons.add_shopping_cart,
                label: 'Add Stock',
                color: Colors.blue[600]!,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProductPage()),
                  );
                },
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                icon: Icons.analytics,
                label: 'View Reports',
                color: Colors.purple[600]!,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DashboardPage()),
                  );
                },
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                icon: Icons.notifications_active,
                label: 'Alerts',
                color: Colors.orange[600]!,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotificationPage()),
                  );
                },
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                icon: Icons.history,
                label: 'Sales History',
                color: Colors.teal[600]!,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SalesHistoryPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastChart() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildChartHeader(),
          const SizedBox(height: 12),
          Expanded(child: LineChart(_createLineChartData())),
          const SizedBox(height: 8),
          _buildChartLegend(),
        ],
      ),
    );
  }

  Widget _buildChartHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '${selectedProduct.replaceAll('_', ' ').capitalize()} Demand Forecast',
                style: TextStyle(
                  fontSize: responsiveFont(context, 15, min: 12, max: 18),
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: responsiveFont(context, 14, min: 12, max: 16),
              color: Colors.grey[500],
            ),
            const SizedBox(width: 4),
            DropdownButton<String>(
              value: selectedPeriod,
              underline: Container(),
              items: const [
                DropdownMenuItem(value: 'daily', child: Text('Daily')),
                DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedPeriod = value!;
                });
              },
              style: TextStyle(
                fontSize: responsiveFont(context, 14, min: 12, max: 16),
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChartLegend() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 24,
      runSpacing: 8,
      children: [
        _buildLegendItem(Colors.green, 'Actual Demand'),
        _buildLegendItem(Colors.blue, 'Forecasted Demand'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 2,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: responsiveFont(context, 12, min: 10, max: 14),
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  LineChartData _createLineChartData() {
    List<ChartData> data = forecastData[selectedProduct]![selectedPeriod]!;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 50,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) =>
            FlLine(color: Colors.grey[300]!, strokeWidth: 1),
        getDrawingVerticalLine: (value) =>
            FlLine(color: Colors.grey[300]!, strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (double value, TitleMeta meta) {
              if (value.toInt() < data.length) {
                return Text(
                  data[value.toInt()].period,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                    fontSize: responsiveFont(context, 10, min: 9, max: 13),
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (double value, TitleMeta meta) {
              return Text(
                value.toInt().toString(),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: responsiveFont(context, 12, min: 10, max: 14),
                ),
              );
            },
            reservedSize: 42,
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      minX: 0,
      maxX: data.length - 1.0,
      minY: 0,
      maxY: data
          .map((e) => e.forecast)
          .reduce((a, b) => a > b ? a : b)
          .toDouble(),
      lineBarsData: [
        LineChartBarData(
          spots: data
              .asMap()
              .entries
              .where((entry) => entry.value.actual != null)
              .map((entry) {
                return FlSpot(
                  entry.key.toDouble(),
                  entry.value.actual!.toDouble(),
                );
              })
              .toList(),
          isCurved: true,
          color: Colors.green,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) =>
                FlDotCirclePainter(
                  radius: 4,
                  color: Colors.green,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
          ),
          belowBarData: BarAreaData(show: false),
        ),
        LineChartBarData(
          spots: data.asMap().entries.map((entry) {
            return FlSpot(
              entry.key.toDouble(),
              entry.value.forecast.toDouble(),
            );
          }).toList(),
          isCurved: true,
          color: Colors.blue,
          barWidth: 3,
          isStrokeCapRound: true,
          dashArray: [5, 5],
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) =>
                FlDotCirclePainter(
                  radius: 4,
                  color: Colors.blue,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
          ),
          belowBarData: BarAreaData(show: false),
        ),
      ],
    );
  }

  double responsiveFont(
    BuildContext context,
    double size, {
    double min = 10,
    double max = 18,
  }) {
    double screenWidth = MediaQuery.of(context).size.width;
    double scaled = size * (screenWidth / 375);
    return scaled.clamp(min, max);
  }
}

class ChartData {
  final String period;
  final double forecast;
  final double? actual;

  ChartData(this.period, this.forecast, [this.actual]);
}

extension StringCasingExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
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
import 'utils/ui_utils.dart';

import 'recommendation_page_forecast.dart';
import 'recommendation_page_monthly.dart';
import 'recommendation_page_promo.dart';
import 'recommendation_page_weekly.dart';
import 'recommendation_page_product.dart';
import 'recommendation_page_outlet.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
          body: Column(children: [Expanded(child: _buildCurrentPage())]),
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
          _buildNewsCard(),
          const SizedBox(height: 16),
          _buildQuickStats(),
          const SizedBox(height: 16),
          _buildMetricsCards(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNewsCard() {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (newsItems.isEmpty) return;
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: Colors.blue[600],
                  size: responsiveFont(context, 20, min: 16, max: 24),
                ),
                const SizedBox(width: 8),
                Text(
                  'Live Market News',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: responsiveFont(context, 16, min: 14, max: 18),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            isLoadingNews
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.blue[600]!,
                        ),
                      ),
                    ),
                  )
                : newsItems.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        newsItems[currentNewsIndex].headline,
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: responsiveFont(
                            context,
                            14,
                            min: 12,
                            max: 16,
                          ),
                          height: 1.4,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 12),
                      // Dots indicator
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
                                  ? Colors.blue[600]
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),
                    ],
                  )
                : Text(
                    'No news available at the moment',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: responsiveFont(context, 14, min: 12, max: 16),
                      height: 1.4,
                    ),
                  ),
          ],
        ),
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
          Container(width: 1, height: 50, color: Colors.grey[200]),
          Expanded(
            child: _buildStatItem(
              icon: Icons.inventory_2,
              label: 'In Stock',
              value: '1,234',
              color: Colors.green,
            ),
          ),
          Container(width: 1, height: 50, color: Colors.grey[200]),
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
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          textAlign: TextAlign.center,
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

  Widget _buildMetricsCards() {
    return Column(
      children: [
        _buildSalesTrendChart(),
        const SizedBox(height: 16),
        _buildMonthlySalesChart(),
        const SizedBox(height: 16),
        _buildWeekdayVsWeekendChart(),
        const SizedBox(height: 16),
        _buildPromoVsNonPromoChart(),
        const SizedBox(height: 16),
        _buildProductSalesChart(),
        const SizedBox(height: 16),
        _buildOutletPerformanceChart(),
      ],
    );
  }

  // State for QuickSight embed URL (Prediction)
  String? _quicksightEmbedUrl;
  bool _isLoadingQuicksight = false;
  String? _quicksightError;
  WebViewController? _quicksightController;
  DateTime? _quicksightUrlFetchTime;

  // State for QuickSight embed URL (Monthly Sales)
  String? _monthlySalesEmbedUrl;
  bool _isLoadingMonthlySales = false;
  String? _monthlySalesError;
  WebViewController? _monthlySalesController;
  DateTime? _monthlySalesUrlFetchTime;

  // Fetch QuickSight embed URL
  Future<void> _fetchQuicksightEmbedUrl() async {
    setState(() {
      _isLoadingQuicksight = true;
      _quicksightError = null;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://keugh3ttkl.execute-api.us-east-1.amazonaws.com/dev/embed-url?type=prediction',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final embedUrl = data['embedUrl'];
        
        setState(() {
          _quicksightEmbedUrl = embedUrl;
          _quicksightUrlFetchTime = DateTime.now();
          _isLoadingQuicksight = false;
          
          // Create new WebView controller with the fresh URL
          _quicksightController = WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setBackgroundColor(Colors.white)
            ..setNavigationDelegate(
              NavigationDelegate(
                onPageStarted: (String url) {
                  print('QuickSight page started loading: $url');
                },
                onPageFinished: (String url) {
                  print('QuickSight page finished loading');
                },
                onWebResourceError: (WebResourceError error) {
                  print('QuickSight error: ${error.description}');
                  // If we get an auth error, the URL might be expired
                  if (error.description.contains('401') || 
                      error.description.contains('403') ||
                      error.description.contains('authorization')) {
                    setState(() {
                      _quicksightError = 'Session expired. Please reload the dashboard.';
                      _quicksightEmbedUrl = null;
                    });
                  }
                },
              ),
            )
            ..loadRequest(Uri.parse(embedUrl));
        });
      } else {
        final errorBody = response.body;
        setState(() {
          _quicksightError = 'Failed to load dashboard (${response.statusCode}): $errorBody';
          _isLoadingQuicksight = false;
        });
      }
    } catch (e) {
      setState(() {
        _quicksightError = 'Error loading dashboard: $e';
        _isLoadingQuicksight = false;
      });
    }
  }
  
  // Check if QuickSight URL needs refresh (URLs typically expire after 5 minutes)
  bool _needsQuicksightRefresh() {
    if (_quicksightUrlFetchTime == null) return false;
    final timeSinceFetch = DateTime.now().difference(_quicksightUrlFetchTime!);
    return timeSinceFetch.inMinutes >= 4; // Refresh before 5-minute expiry
  }

  // Fetch Monthly Sales QuickSight embed URL
  Future<void> _fetchMonthlySalesEmbedUrl() async {
    setState(() {
      _isLoadingMonthlySales = true;
      _monthlySalesError = null;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://keugh3ttkl.execute-api.us-east-1.amazonaws.com/dev/embed-url?type=monthly',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final embedUrl = data['embedUrl'];
        
        setState(() {
          _monthlySalesEmbedUrl = embedUrl;
          _monthlySalesUrlFetchTime = DateTime.now();
          _isLoadingMonthlySales = false;
          
          // Create new WebView controller with the fresh URL
          _monthlySalesController = WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setBackgroundColor(Colors.white)
            ..setNavigationDelegate(
              NavigationDelegate(
                onPageStarted: (String url) {
                  print('Monthly Sales page started loading: $url');
                },
                onPageFinished: (String url) {
                  print('Monthly Sales page finished loading');
                },
                onWebResourceError: (WebResourceError error) {
                  print('Monthly Sales error: ${error.description}');
                  // If we get an auth error, the URL might be expired
                  if (error.description.contains('401') || 
                      error.description.contains('403') ||
                      error.description.contains('authorization')) {
                    setState(() {
                      _monthlySalesError = 'Session expired. Please reload the dashboard.';
                      _monthlySalesEmbedUrl = null;
                    });
                  }
                },
              ),
            )
            ..loadRequest(Uri.parse(embedUrl));
        });
      } else {
        final errorBody = response.body;
        setState(() {
          _monthlySalesError = 'Failed to load dashboard (${response.statusCode}): $errorBody';
          _isLoadingMonthlySales = false;
        });
      }
    } catch (e) {
      setState(() {
        _monthlySalesError = 'Error loading dashboard: $e';
        _isLoadingMonthlySales = false;
      });
    }
  }
  
  // Check if Monthly Sales URL needs refresh
  bool _needsMonthlySalesRefresh() {
    if (_monthlySalesUrlFetchTime == null) return false;
    final timeSinceFetch = DateTime.now().difference(_monthlySalesUrlFetchTime!);
    return timeSinceFetch.inMinutes >= 4; // Refresh before 5-minute expiry
  }

  Widget _buildSalesTrendChart() {
    // Check if URL needs refresh
    if (_quicksightEmbedUrl != null && _needsQuicksightRefresh()) {
      // Silently refresh the URL in the background
      Future.microtask(() => _fetchQuicksightEmbedUrl());
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: UIUtils.getCardBorderRadius(),
        boxShadow: UIUtils.getCardShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.trending_up, color: Colors.blue[600], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Sales Prediction',
                    style: TextStyle(
                      fontSize: UIUtils.getResponsiveFontSize(context, 16),
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Refresh button
                  if (_quicksightEmbedUrl != null)
                    IconButton(
                      onPressed: _isLoadingQuicksight ? null : _fetchQuicksightEmbedUrl,
                      icon: Icon(
                        Icons.refresh,
                        size: 20,
                        color: _isLoadingQuicksight ? Colors.grey : Colors.blue[600],
                      ),
                      tooltip: 'Refresh Dashboard',
                    ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RecommendationPage1(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward_ios, size: 16),
                    tooltip: 'Go to Recommendation',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // QuickSight Dashboard Container
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _buildQuicksightContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuicksightContent() {
    if (_quicksightEmbedUrl == null && !_isLoadingQuicksight && _quicksightError == null) {
      // Initial state - show button to load dashboard
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Sales Prediction Dashboard',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'View AI-powered sales predictions',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _fetchQuicksightEmbedUrl,
              icon: const Icon(Icons.bar_chart),
              label: const Text('Load Dashboard'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    if (_isLoadingQuicksight) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading dashboard...',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'This may take a few seconds',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      );
    }

    if (_quicksightError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
              const SizedBox(height: 16),
              Text(
                'Unable to Load Dashboard',
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _quicksightError!,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _quicksightError = null;
                        _quicksightEmbedUrl = null;
                      });
                    },
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _fetchQuicksightEmbedUrl,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    if (_quicksightEmbedUrl != null && _quicksightController != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: WebViewWidget(
          controller: _quicksightController!,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildMonthlySalesChart() {
    // Check if URL needs refresh
    if (_monthlySalesEmbedUrl != null && _needsMonthlySalesRefresh()) {
      // Silently refresh the URL in the background
      Future.microtask(() => _fetchMonthlySalesEmbedUrl());
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: UIUtils.getCardBorderRadius(),
        boxShadow: UIUtils.getCardShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_month, color: Colors.blue[600], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Monthly Sales',
                    style: TextStyle(
                      fontSize: UIUtils.getResponsiveFontSize(context, 16),
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Refresh button
                  if (_monthlySalesEmbedUrl != null)
                    IconButton(
                      onPressed: _isLoadingMonthlySales ? null : _fetchMonthlySalesEmbedUrl,
                      icon: Icon(
                        Icons.refresh,
                        size: 20,
                        color: _isLoadingMonthlySales ? Colors.grey : Colors.blue[600],
                      ),
                      tooltip: 'Refresh Dashboard',
                    ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RecommendationPage1(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward_ios, size: 16),
                    tooltip: 'Go to Recommendation',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // QuickSight Dashboard Container
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _buildMonthlySalesContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlySalesContent() {
    if (_monthlySalesEmbedUrl == null && !_isLoadingMonthlySales && _monthlySalesError == null) {
      // Initial state - show button to load dashboard
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Monthly Sales Dashboard',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'View monthly sales trends and analytics',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _fetchMonthlySalesEmbedUrl,
              icon: const Icon(Icons.calendar_month),
              label: const Text('Load Dashboard'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    if (_isLoadingMonthlySales) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading dashboard...',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'This may take a few seconds',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      );
    }

    if (_monthlySalesError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
              const SizedBox(height: 16),
              Text(
                'Unable to Load Dashboard',
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _monthlySalesError!,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _monthlySalesError = null;
                        _monthlySalesEmbedUrl = null;
                      });
                    },
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _fetchMonthlySalesEmbedUrl,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    if (_monthlySalesEmbedUrl != null && _monthlySalesController != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: WebViewWidget(
          controller: _monthlySalesController!,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  


  Widget _buildWeekdayVsWeekendChart() {
    // 🔄 Use same data as Sales Trend chart (including 3-day forecast)
    final sales = [3100, 5200, 5800, 4000, 3300, 3400, 3200, 3500, 5000];

    final weekdaySales = [
      sales[0],
      sales[3],
      sales[4],
      sales[5],
      sales[6],
      sales[7],
    ]; // Fri, Mon, Tue, Wed, Thu, Fri
    final weekendSales = [sales[1], sales[2], sales[8]]; // Sat, Sun, Sat

    final weekdayAvg =
        weekdaySales.reduce((a, b) => a + b) / weekdaySales.length;
    final weekendAvg =
        weekendSales.reduce((a, b) => a + b) / weekendSales.length;

    final ratio = (weekendAvg / weekdayAvg);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: UIUtils.getCardBorderRadius(),
        boxShadow: UIUtils.getCardShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Colors.purple[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Weekday vs Weekend Sales',
                    style: TextStyle(
                      fontSize: UIUtils.getResponsiveFontSize(context, 16),
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),

              // 🟡 New small button
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecommendationPageWeekly(),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                tooltip: 'Go to Recommendation',
              ),
            ],
          ),

          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.purple[50],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.purple[300]!, width: 1),
            ),
            child: Text(
              "🎉 Weekend: ${ratio.toStringAsFixed(2)}x higher per day",
              style: TextStyle(
                fontSize: UIUtils.getResponsiveFontSize(context, 13),
                color: Colors.purple[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.25,
            child: BarChart(
              BarChartData(
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.black.withOpacity(0.6),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        'RM${(rod.toY).toStringAsFixed(2)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      );
                    },
                  ),
                ),
                alignment: BarChartAlignment.spaceAround,
                maxY: (weekendAvg / 1000).ceil() * 1000,
                gridData: FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${(value / 1000).toStringAsFixed(2)}k',
                          style: TextStyle(
                            fontSize: UIUtils.getResponsiveFontSize(
                              context,
                              11,
                            ),
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 0:
                            return Text(
                              'Weekday',
                              style: TextStyle(
                                fontSize: UIUtils.getResponsiveFontSize(
                                  context,
                                  12,
                                ),
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          case 1:
                            return Text(
                              'Weekend',
                              style: TextStyle(
                                fontSize: UIUtils.getResponsiveFontSize(
                                  context,
                                  12,
                                ),
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          default:
                            return const Text('');
                        }
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: weekdayAvg,
                        color: Colors.blue[400],
                        width: 40,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: weekendAvg,
                        color: Colors.purple[400],
                        width: 40,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

//   


  Widget _buildPromoVsNonPromoChart() {
    // Different promo types with their average sales
    final promoData = [
      {'name': 'Buy 1 Free 1', 'sales': 5800.0, 'color': Colors.orange[600]!},
      {'name': 'Flash Sale', 'sales': 5200.0, 'color': Colors.red[600]!},
      {'name': '20% Off', 'sales': 4500.0, 'color': Colors.purple[600]!},
      // {'name': 'Bundle Deal', 'sales': 4200.0, 'color': Colors.blue[600]!},
      {'name': 'Non-Promo', 'sales': 3400.0, 'color': Colors.grey[400]!},
    ];

    // Calculate effectiveness compared to non-promo
    final nonPromoSales = promoData.last['sales'] as double;
    final bestPromo = promoData.first;
    final bestPromoSales = bestPromo['sales'] as double;
    final boost = ((bestPromoSales - nonPromoSales) / nonPromoSales) * 100;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: UIUtils.getCardBorderRadius(),
        boxShadow: UIUtils.getCardShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.local_offer, color: Colors.orange[600], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Promo Effectiveness',
                    style: TextStyle(
                      fontSize: UIUtils.getResponsiveFontSize(context, 16),
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),

              // 🟡 New small button
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecommendationPagePromo(),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                tooltip: 'Go to Recommendation',
              ),
            ],
          ),

          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.orange[300]!, width: 1),
            ),
            child: Text(
              "🔥 Best: ${bestPromo['name']} (+${boost.toStringAsFixed(2)}% vs non-promo)",
              style: TextStyle(
                fontSize: UIUtils.getResponsiveFontSize(context, 13),
                color: Colors.orange[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.25,
            child: BarChart(
              BarChartData(
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.black.withOpacity(0.6),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final promoName = promoData[groupIndex]['name'] as String;
                      return BarTooltipItem(
                        '$promoName\nRM${(rod.toY).toStringAsFixed(2)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      );
                    },
                  ),
                ),
                alignment: BarChartAlignment.spaceAround,
                maxY: (bestPromoSales / 1000).ceil() * 1000,
                gridData: FlGridData(show: true, drawVerticalLine: false),

                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${(value / 1000).toStringAsFixed(2)}k',
                          style: TextStyle(
                            fontSize: UIUtils.getResponsiveFontSize(
                              context,
                              11,
                            ),
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < promoData.length) {
                          final name = promoData[index]['name'] as String;
                          // Shorten names for better fit
                          String displayName;
                          switch (name) {
                            case 'Buy 1 Free 1':
                              displayName = 'B1F1';
                              break;
                            case 'Flash Sale':
                              displayName = 'Flash';
                              break;
                            case '20% Off':
                              displayName = '20%';
                              break;
                            // case 'Bundle Deal':
                            //   displayName = 'Bundle';
                            //   break;
                            case 'Non-Promo':
                              displayName = 'None';
                              break;
                            default:
                              displayName = name;
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              displayName,
                              style: TextStyle(
                                fontSize: UIUtils.getResponsiveFontSize(
                                  context,
                                  9,
                                ),
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(
                  promoData.length,
                  (index) => BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: promoData[index]['sales'] as double,
                        color: promoData[index]['color'] as Color,
                        width: 35,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductSalesChart() {
    // Product sales data (average daily sales) - sorted highest to lowest
    final productData = [
      {'name': 'Rice', 'sales': 1850.0, 'color': Colors.brown[400]!},
      {'name': 'Chicken', 'sales': 1520.0, 'color': Colors.orange[400]!},
      {'name': 'Eggs', 'sales': 1340.0, 'color': Colors.amber[400]!},
      {'name': 'Cooking Oil', 'sales': 980.0, 'color': Colors.yellow[600]!},
      {'name': 'Sugar', 'sales': 720.0, 'color': Colors.grey[400]!},
    ];

    final topProduct = productData.first;
    final topProductSales = topProduct['sales'] as double;
    final totalSales = productData.fold<double>(
      0,
      (sum, item) => sum + (item['sales'] as double),
    );
    final topPercentage = (topProductSales / totalSales) * 100;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: UIUtils.getCardBorderRadius(),
        boxShadow: UIUtils.getCardShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.shopping_basket,
                    color: Colors.brown[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Product Sales Performance',
                    style: TextStyle(
                      fontSize: UIUtils.getResponsiveFontSize(context, 16),
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),

              // 🟡 New small button
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecommendationPageProduct(),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                tooltip: 'Go to Recommendation',
              ),
            ],
          ),

          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.brown[50],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.brown[300]!, width: 1),
            ),
            child: Text(
              "🌾 Top: ${topProduct['name']} (RM${(topProductSales / 1000).toStringAsFixed(2)}k, ${topPercentage.toStringAsFixed(1)}%)",

              style: TextStyle(
                fontSize: UIUtils.getResponsiveFontSize(context, 13),
                color: Colors.brown[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.25,
            child: BarChart(
              BarChartData(
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.black.withOpacity(0.5),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final productName =
                          productData[groupIndex]['name'] as String;
                      return BarTooltipItem(
                        'RM${(rod.toY).toStringAsFixed(2)}',
                        // '$productName\nRM${(rod.toY).toStringAsFixed(2)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      );
                    },
                  ),
                ),
                alignment: BarChartAlignment.spaceAround,
                maxY: (topProductSales / 500).ceil() * 500,
                gridData: FlGridData(show: true, drawVerticalLine: false),

                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${(value / 1000).toStringAsFixed(1)}k',
                          style: TextStyle(
                            fontSize: UIUtils.getResponsiveFontSize(
                              context,
                              11,
                            ),
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < productData.length) {
                          final name = productData[index]['name'] as String;
                          String displayName;
                          switch (name) {
                            case 'Cooking Oil':
                              displayName = 'Oil';
                              break;
                            default:
                              displayName = name;
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              displayName,
                              style: TextStyle(
                                fontSize: UIUtils.getResponsiveFontSize(
                                  context,
                                  10,
                                ),
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(
                  productData.length,
                  (index) => BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: productData[index]['sales'] as double,
                        color: productData[index]['color'] as Color,
                        width: 35,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutletPerformanceChart() {
    // Outlet performance data (average daily sales) - top 3 and bottom 3
    final outletData = [
      {
        'name': 'KLCC',
        'sales': 2850.0,
        'color': Colors.green[600]!,
        'isTop': true,
      },
      {
        'name': 'Pavilion',
        'sales': 2640.0,
        'color': Colors.green[500]!,
        'isTop': true,
      },
      {
        'name': 'Mid Valley',
        'sales': 2380.0,
        'color': Colors.green[400]!,
        'isTop': true,
      },
      {
        'name': 'Setapak',
        'sales': 1120.0,
        'color': Colors.red[400]!,
        'isTop': false,
      },
      {
        'name': 'Ampang',
        'sales': 980.0,
        'color': Colors.red[500]!,
        'isTop': false,
      },
      {
        'name': 'Cheras',
        'sales': 850.0,
        'color': Colors.red[600]!,
        'isTop': false,
      },
    ];

    final topOutlet = outletData.first;
    final bottomOutlet = outletData.last;
    final topSales = topOutlet['sales'] as double;
    final bottomSales = bottomOutlet['sales'] as double;
    final gap = ((topSales - bottomSales) / bottomSales) * 100;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: UIUtils.getCardBorderRadius(),
        boxShadow: UIUtils.getCardShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.store, color: Colors.green[600], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Outlet Performance',
                    style: TextStyle(
                      fontSize: UIUtils.getResponsiveFontSize(context, 16),
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),

              // 🟡 New small button
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecommendationPageOutlet(),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                tooltip: 'Go to Recommendation',
              ),
            ],
          ),

          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.green[300]!, width: 1),
            ),
            child: Text(
              "🏆 ${topOutlet['name']}: RM${(topSales / 1000).toStringAsFixed(2)}k (${gap.toStringAsFixed(0)}% higher than lowest)",
              style: TextStyle(
                fontSize: UIUtils.getResponsiveFontSize(context, 13),
                color: Colors.green[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.25,
            child: BarChart(
              BarChartData(
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.black.withOpacity(0.5),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final outletName =
                          outletData[groupIndex]['name'] as String;
                      final isTop = outletData[groupIndex]['isTop'] as bool;
                      return BarTooltipItem(
                        '$outletName\nRM${(rod.toY).toStringAsFixed(2)}\n${isTop ? "🔥 Top 3" : "📉 Bottom 3"}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      );
                    },
                  ),
                ),
                alignment: BarChartAlignment.spaceAround,
                maxY: (topSales / 500).ceil() * 500,
                gridData: FlGridData(show: true, drawVerticalLine: false),

                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${(value / 1000).toStringAsFixed(1)}k',
                          style: TextStyle(
                            fontSize: UIUtils.getResponsiveFontSize(
                              context,
                              11,
                            ),
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < outletData.length) {
                          final name = outletData[index]['name'] as String;

                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Transform.rotate(
                              angle: -0.5,
                              child: Text(
                                name,
                                style: TextStyle(
                                  fontSize: UIUtils.getResponsiveFontSize(
                                    context,
                                    9,
                                  ),
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(
                  outletData.length,
                  (index) => BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: outletData[index]['sales'] as double,
                        color: outletData[index]['color'] as Color,
                        width: 30,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
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

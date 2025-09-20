import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'dart:math';
import 'dart:io';

// Import the separate pages
import 'product_page.dart';
import 'sales_history_page.dart';
import 'dashboard_page.dart';
import 'product_list_page.dart';
import 'notification_page.dart';
import 'edit_profile_page.dart'; // Add this import
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedProduct = 'rice';
  // News state
bool isLoadingNews = false;
int currentNewsIndex = 0;
final String newsApiUrl = "https://vs8p5qqzwb.execute-api.ap-southeast-1.amazonaws.com/dev/news"; 
// 👆 Replace with your actual API endpoint

  String selectedPeriod = 'daily';
  String newsHeader =
      "The proposed 5% tax on petroleum products will increase production costs for poultry businesses.";
  Timer? newsTimer;
  int currentIndex = 0;

  // Profile data state
  String userName = 'Unknown';
  String userEmail = 'unknown@example.com';
  String? userProfileImagePath;
  String? userPhone;
  String? userAddress;

  List<String> newsItems = [
    "The proposed 5% tax on petroleum products will increase production costs for poultry businesses.",
    "Higher production costs are likely to raise consumer prices for eggs and poultry.",
    "Increased fuel costs will elevate expenses for feed, veterinary services, packaging, and distribution.",
    "Food inflation and food insecurity may worsen, especially affecting small and medium-scale farmers.",
    "Targeted subsidies for agricultural inputs like maize, soybeans, and veterinary products could help lower production costs and stabilize consumer prices.",
    "Lack of an egg subsidy may reduce the affordability of eggs as a protein source for consumers.",
    "Improved infrastructure investment could reduce reliance on expensive fuel and lower transportation costs for businesses.",
    "Trade restrictions or higher costs could risk reduced domestic poultry production.",
    "Failure to implement supportive policies may undermine national food security and consumer affordability.",
  ];

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
      List<String> fetchedNews = [];

      for (var item in data) {
        if (item['content'] != null &&
            item['content']['is_relevant'] == true &&
            item['content']['possible_impacts'] != null) {
          List<dynamic> impacts = item['content']['possible_impacts'];
          for (var impact in impacts) {
            if (impact != null && impact.toString().trim().isNotEmpty) {
              fetchedNews.add(impact.toString());
            }
          }
        }
      }

      setState(() {
        newsItems = fetchedNews; // 👈 only possible_impacts go here
        isLoadingNews = false;
      });
    } else {
      throw Exception("Failed to load news");
    }
  } catch (e) {
    setState(() {
      newsItems = ["Error loading news: $e"];
      isLoadingNews = false;
    });
  }
}


  void _setDefaultNews() {
    setState(() {
      newsItems = [
        "Market conditions are being monitored for price stability.",
        "Government policies may impact agricultural product prices.",
        "Import and export regulations affect market dynamics.",
        "Price control measures are being evaluated for essential items.",
      ];
      newsHeader = newsItems.first;
      currentNewsIndex = 0;
      isLoadingNews = false;
    });
  }

  void _startNewsTimer() {
    newsTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (newsItems.isNotEmpty) {
        setState(() {
          currentNewsIndex = (currentNewsIndex + 1) % newsItems.length;
          newsHeader = newsItems[currentNewsIndex];
        });
      }
    });
  }

  // Refresh news data
  Future<void> _refreshNews() async {
    await _fetchNewsData();
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
    return Scaffold(
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
          newsHeader = newsItems[currentNewsIndex];
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                : Text(
                    newsHeader,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: responsiveFont(context, 13, min: 11, max: 16),
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.justify,
                  ),
          ),
          const SizedBox(height: 6),
          // 🔹 Dots indicator
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildProductSelection(),
          const SizedBox(height: 16),
          Expanded(child: _buildForecastChart()),
        ],
      ),
    );
  }

  Widget _buildProductSelection() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Product',
            style: TextStyle(
              fontSize: responsiveFont(context, 18, min: 14, max: 20),
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildProductButton(
                  Icons.grass,
                  'Rice',
                  selectedProduct == 'rice',
                  () => setState(() => selectedProduct = 'rice'),
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildProductButton(
                  Icons.egg_outlined,
                  'Egg',
                  selectedProduct == 'egg',
                  () => setState(() => selectedProduct = 'egg'),
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductButton(
    IconData icon,
    String label,
    bool isSelected,
    VoidCallback onTap,
    Color color,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: responsiveFont(context, 32, min: 24, max: 36),
              color: isSelected ? color : Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: responsiveFont(context, 14, min: 12, max: 16),
                color: isSelected ? color : Colors.grey[600],
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            '${selectedProduct.capitalize()} Demand Forecast',
            style: TextStyle(
              fontSize: responsiveFont(context, 15, min: 12, max: 18),
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
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

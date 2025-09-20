import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'dart:math';

// Import the separate pages
import 'product_page.dart';
import 'sales_history_page.dart';
import 'dashboard_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedProduct = 'rice';
  String selectedPeriod = 'daily';
  String newsHeader =
      'Market Update: Agricultural commodity prices show stability across Southeast Asian markets';
  Timer? newsTimer;
  int currentIndex = 0;

  final List<String> newsItems = [
    'Market Update: Agricultural commodity prices show stability across Southeast Asian markets',
    'Breaking: Weather forecast indicates favorable conditions for rice production this quarter',
    'Economic Report: Consumer demand for essential goods increases by 12% this month',
    'Supply Chain Alert: Transportation costs expected to decrease following fuel price reduction',
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
    _startNewsTimer();
  }

  void _startNewsTimer() {
    newsTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      setState(() {
        newsHeader = newsItems[Random().nextInt(newsItems.length)];
      });
    });
  }

  @override
  void dispose() {
    newsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        elevation: 4,
        leading: IconButton(
          onPressed: () {
            print("Hamburger menu tapped");
          },
          icon: Icon(
            Icons.menu,
            color: Colors.white,
            size: responsiveFont(context, 22, min: 18, max: 26),
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
              print("Notification tapped");
            },
            icon: Stack(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: responsiveFont(context, 22, min: 18, max: 26),
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
    return Container(
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
            ],
          ),
          const SizedBox(height: 4),
          Text(
            newsHeader,
            style: TextStyle(
              color: Colors.white,
              fontSize: responsiveFont(context, 13, min: 11, max: 16),
              height: 1.3,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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
      maxY: data.map((e) => e.forecast).reduce((a, b) => a > b ? a : b) * 1.2,
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
          }).toList(),
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

  double responsiveFont(BuildContext context, double size,
      {double min = 10, double max = 18}) {
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

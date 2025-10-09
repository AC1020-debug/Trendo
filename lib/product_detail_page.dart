import 'package:flutter/material.dart';
import 'dart:ui' as dart_ui;
import 'product_data.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
// Import utility classes
import '../utils/stock_analyzer.dart' as stock;
import '../utils/ui_utils.dart' as ui;
import '../models/enums.dart';
import 'widget/draggable_chatbot.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductData product;

  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final PageController _pageController = PageController();
  int _currentChartPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Generate 1-month historical data + 3-day prediction (but keep 6 months for scrolling)
  List<FlSpot> get6MonthTrendData() {
    List<FlSpot> spots = [];
    
    // Base parameters for more natural sales pattern
    double baseValue = 5000; // Average sales around 5000
    double trendSlope = 5; // Gradual upward trend
    
    // Generate 6 months of data (180 days) with natural patterns
    for (int i = 0; i <= 180; i++) {
      // Base trend (gradual increase)
      double trend = baseValue + (i * trendSlope);
      
      // Weekly pattern (weekend peaks)
      int dayOfWeek = (i % 7);
      double weeklyPattern = 0;
      if (dayOfWeek == 5 || dayOfWeek == 6) { // Weekend
        weeklyPattern = 800;
      } else {
        weeklyPattern = -200;
      }
      
      // Monthly seasonality (smooth wave)
      double monthlyWave = 400 * math.sin((i / 30) * 2 * math.pi);
      
      // Random daily variation (small noise)
      double noise = (math.Random(i).nextDouble() - 0.5) * 300;
      
      double value = trend + weeklyPattern + monthlyWave + noise;
      spots.add(FlSpot(i.toDouble(), value.clamp(3000, 8000)));
    }

    // Add prediction for next 3 days
    double lastValue = spots.last.y;
    double recentTrend = (spots.last.y - spots[spots.length - 7].y) / 7;

    for (int i = 1; i <= 3; i++) {
      int futureDayOfWeek = ((180 + i) % 7);
      double weekendBoost = (futureDayOfWeek == 5 || futureDayOfWeek == 6) ? 600 : 0;
      double predictedValue = lastValue + (recentTrend * i) + weekendBoost + 
                              ((math.Random(180 + i).nextDouble() - 0.5) * 200);
      spots.add(FlSpot(180.0 + i, predictedValue.clamp(3000, 8000)));
    }

    return spots;
  }

  // Generate weekday vs weekend sales data for PAST WEEK ONLY
  List<FlSpot> getWeekdaySalesData() {
    List<FlSpot> spots = [];
    DateTime startDate = DateTime.now().subtract(
      Duration(days: 6),
    ); // Last 7 days

    for (int i = 0; i < 7; i++) {
      DateTime day = startDate.add(Duration(days: i));
      bool isWeekend =
          day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;

      double baseValue = 3500; // Base sales around 3500
      if (isWeekend) baseValue += 2000; // Weekend boost

      // Add some variation
      double variation = (i % 3) * 250;
      spots.add(FlSpot(i.toDouble(), baseValue + variation));
    }
    return spots;
  }

  // Generate promotion data for a specific period
  List<FlSpot> getPromotionPeriodData(bool withPromotion) {
    List<FlSpot> spots = [];
    for (int i = 0; i < 30; i++) {
      double baseValue = withPromotion ? 6500 : 3800; // Higher numbers
      double variation = (i % 5) * 250;
      double trend = withPromotion ? (i * 30) : (i * 10);
      spots.add(FlSpot(i.toDouble(), baseValue + variation + trend));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue[600],
            elevation: 4,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            title: Text(
              widget.product.name,
              style: TextStyle(
                fontSize: ui.UIUtils.getResponsiveFontSize(context, 20),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: false,
          ),
          body: SingleChildScrollView(
            padding: ui.UIUtils.getResponsivePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusCard(context),
                const SizedBox(height: 20),
                _buildChartsSection(context),
                const SizedBox(height: 20),
                _buildCriticalInfoCard(context),
              ],
            ),
          ),
        ),
        DraggableChatbot(),
      ],
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    // Use StockAnalyzer for comprehensive analysis
    stock.StockAnalysisResult analysis = stock.StockAnalyzer.analyzeStock(
      widget.product.daysWithoutStock,
      widget.product.forecast,
    );

    return Container(
      width: double.infinity,
      padding: ui.UIUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: ui.UIUtils.getCardBorderRadius(),
        boxShadow: ui.UIUtils.getCardShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status:',
            style: TextStyle(
              fontSize: ui.UIUtils.getResponsiveFontSize(context, 18),
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: analysis.riskColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: analysis.riskColor, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  analysis.riskLevel == RiskLevel.high
                      ? Icons.error
                      : analysis.riskLevel == RiskLevel.medium
                      ? Icons.warning
                      : Icons.check_circle,
                  color: analysis.riskColor,
                  size: ui.UIUtils.getResponsiveFontSize(context, 16),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '${analysis.stockStatusString} - ${analysis.riskLevel.displayName}',
                    style: TextStyle(
                      fontSize: ui.UIUtils.getResponsiveFontSize(context, 14),
                      color: analysis.riskColor,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (widget.product.currentStock != null)
            Text(
              'Current Stock: ${widget.product.currentStock}',
              style: TextStyle(
                fontSize: ui.UIUtils.getResponsiveFontSize(context, 16),
                color: Colors.grey[700],
              ),
            ),
          if (widget.product.daysWithoutStock != null)
            Text(
              'Days until without Stock: ${widget.product.daysWithoutStock}',
              style: TextStyle(
                fontSize: ui.UIUtils.getResponsiveFontSize(context, 16),
                color: Colors.grey[700],
              ),
            ),
          Text(
            'Forecast: ${widget.product.forecast}',
            style: TextStyle(
              fontSize: ui.UIUtils.getResponsiveFontSize(context, 16),
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 340,
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentChartPage = index;
              });
            },
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildChart6MonthTrend(context),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildChartWeekdayWeekend(context),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildChartPromotionComparison(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildPageIndicator(),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentChartPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentChartPage == index
                ? Colors.blue[600]
                : Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildChart6MonthTrend(BuildContext context) {
    List<FlSpot> spots = get6MonthTrendData();
    DateTime now = DateTime.now();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: ui.UIUtils.getCardBorderRadius(),
        boxShadow: ui.UIUtils.getCardShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sales Trend Forecast',
            style: TextStyle(
              fontSize: ui.UIUtils.getResponsiveFontSize(context, 16),
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(width: 20, height: 3, color: Colors.blue[600]),
              const SizedBox(width: 6),
              Text(
                'Historical',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
              const SizedBox(width: 12),
              Container(
                width: 20,
                height: 3,
                decoration: BoxDecoration(color: Colors.orange[600]),
                child: CustomPaint(
                  painter: DashedLinePainter(color: Colors.orange[600]!),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Prediction',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Stack(
              children: [
                // Sticky Y-axis on the left
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 30,
                  width: 50,
                  child: Container(
                    color: Colors.white,
                    child: CustomPaint(
                      painter: YAxisPainter(
                        minY: 2500,
                        maxY: 8500,
                        interval: 1000,
                      ),
                    ),
                  ),
                ),
                // Scrollable chart area with padding
                Padding(
                  padding: const EdgeInsets.only(left: 50),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 3.2, // Increased width for better spacing
                      padding: const EdgeInsets.only(top: 30, bottom: 30, right: 40, left: 20), // Added left padding
                      child: LineChart(
                        LineChartData(
                          minX: -5, // Start slightly before 0 to prevent truncation
                          maxX: 215, // Extended to give more space
                          lineTouchData: LineTouchData(
                            enabled: true,
                            touchTooltipData: LineTouchTooltipData(
                              tooltipBgColor: Colors.black87,
                              tooltipRoundedRadius: 8,
                              tooltipPadding: EdgeInsets.all(8),
                              fitInsideHorizontally: true,
                              fitInsideVertically: true,
                              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                                return touchedSpots.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  LineBarSpot spot = entry.value;
                                  
                                  // Only show tooltip for valid data points
                                  if (spot.x < 0 || spot.x > 210) return null;
                                  
                                  // Only show tooltip for historical line (index 0)
                                  // or forecast line (index 1) when x > 180
                                  if (index == 1 && spot.x <= 180) {
                                    return null;
                                  }
                                  
                                  if (index > 1) {
                                    return null;
                                  }
                                  
                                  String dateStr;
                                  
                                  if (spot.x < 180) {
                                    // Days before today
                                    DateTime date = now.subtract(
                                      Duration(days: 180 - spot.x.toInt()),
                                    );
                                    dateStr = DateFormat('MMM d').format(date);
                                  } else if (spot.x == 180) {
                                    dateStr = 'Today';
                                  } else {
                                    // Forecast data
                                    int forecastDay = ((spot.x - 180) / 10).round();
                                    dateStr = 'D+$forecastDay';
                                  }
                                  
                                  return LineTooltipItem(
                                    '$dateStr\nRM${(spot.y).toStringAsFixed(0)}',
                                    TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 1000,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(color: Colors.grey[200]!, strokeWidth: 1);
                            },
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
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
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  if (value < 0 || value > 210) return const SizedBox();

                                  DateTime date = now.subtract(
                                    Duration(days: 180 - value.toInt()),
                                  );

                                  // Past 5 months (scrollable): Show month labels at start of each month
                                  if (value < 150) {
                                    // Show month label at the beginning of each month (approximately every 30 days)
                                    if (value % 30 == 0 || value == 0) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8, left: 5), // Added left padding
                                        child: Text(
                                          DateFormat('MMM').format(date),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                  // Last 30 days: Show dates every 5 days
                                  else if (value >= 150 && value < 180) {
                                    if ((value - 150) % 5 == 0) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          DateFormat('d/M').format(date),
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                  // Today marker
                                  else if (value == 180) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        'Today',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.blue[800],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  }
                                  // Forecast days (D+1, D+2, D+3)
                                  else if (value > 180 && value <= 210) {
                                    if ((value - 180) % 10 == 0) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          'D+${((value - 180) / 10).toInt()}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.orange[700],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                  
                                  return const SizedBox();
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border(
                              bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                              left: BorderSide(color: Colors.grey[300]!, width: 1),
                            ),
                          ),
                          minY: 2500,
                          maxY: 8500,
                          lineBarsData: [
                            // Historical data line
                            LineChartBarData(
                              spots: spots.where((s) => s.x <= 180).toList(),
                              isCurved: true,
                              curveSmoothness: 0.4,
                              color: Colors.blue[600],
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Colors.blue[600]!.withOpacity(0.1),
                              ),
                            ),
                            // Forecast data line with expanded x-scale
                            LineChartBarData(
                              spots: [
                                spots[180], // Today
                                FlSpot(190, spots[181].y), // D+1
                                FlSpot(200, spots[182].y), // D+2
                                FlSpot(210, spots[183].y), // D+3
                              ],
                              isCurved: true,
                              curveSmoothness: 0.4,
                              color: Colors.orange[600],
                              barWidth: 3,
                              dashArray: [8, 4],
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 6,
                                    color: Colors.orange[600]!,
                                    strokeWidth: 2,
                                    strokeColor: Colors.white,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Colors.orange[600]!.withOpacity(0.1),
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
          ),
        ],
      ),
    );
  }

  Widget _buildChartWeekdayWeekend(BuildContext context) {
    List<FlSpot> spots = getWeekdaySalesData();
    DateTime startDate = DateTime.now().subtract(Duration(days: 6));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: ui.UIUtils.getCardBorderRadius(),
        boxShadow: ui.UIUtils.getCardShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Past Week Sales Pattern',
            style: TextStyle(
              fontSize: ui.UIUtils.getResponsiveFontSize(context, 16),
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 12,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green[600],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Weekend',
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.blue[400],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Weekday',
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 6,
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Colors.black87,
                    tooltipRoundedRadius: 8,
                    tooltipPadding: EdgeInsets.all(8),
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '${spot.y.toStringAsFixed(2)}',
                          TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1000,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: Colors.grey[200]!, strokeWidth: 1);
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      interval: 1000,
                      getTitlesWidget: (value, meta) => Text(
                        '${(value / 1000).toStringAsFixed(1)}k',
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
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
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value < 0 || value >= 7) return const SizedBox();
                        DateTime day = startDate.add(
                          Duration(days: value.toInt()),
                        );

                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            DateFormat('E\nd').format(day),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey[600],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                    left: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                ),
                minY: 2000,
                maxY: 7000,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.purple[600],
                    barWidth: 2.5,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        DateTime day = startDate.add(Duration(days: index));
                        bool isWeekend =
                            day.weekday == DateTime.saturday ||
                            day.weekday == DateTime.sunday;

                        Color dotColor = isWeekend
                            ? Colors.green[600]!
                            : Colors.blue[400]!;
                        double radius = isWeekend ? 4 : 3;

                        return FlDotCirclePainter(
                          radius: radius,
                          color: dotColor,
                          strokeWidth: 1.5,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple[600]!.withOpacity(0.2),
                          Colors.purple[600]!.withOpacity(0.05),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildChartPromotionComparison(BuildContext context) {
    // Generate continuous sales data with color segments
    List<LineChartBarData> getLineChartBarData() {
      List<LineChartBarData> segments = [];
      
      // Helper to create spots for a range
      List<FlSpot> createSpots(int start, int end) {
        List<FlSpot> spots = [];
        double baseValue = 4000;
        
        for (int i = start; i <= end; i++) {
          double value = baseValue;
          
          // Define promotion periods
          bool isPromo1 = i >= 30 && i <= 50;
          bool isPromo2 = i >= 90 && i <= 110;
          bool isPromo3 = i >= 140 && i <= 160;
          
          // Base trend
          double trend = i * 4;
          
          // Weekly pattern
          int dayOfWeek = (i % 7);
          double weeklyPattern = (dayOfWeek == 5 || dayOfWeek == 6) ? 400 : -100;
          
          // Promotion boost - realistic increases
          double promoBoost = 0;
          if (isPromo1) {
            promoBoost = 1200 + ((i - 30) * 20);
          } else if (isPromo2) {
            promoBoost = 700 + ((i - 90) * 12);
          } else if (isPromo3) {
            promoBoost = 300 + ((i - 140) * 8);
          }
          
          // Random noise
          double noise = (math.Random(i).nextDouble() - 0.5) * 200;
          
          value = value + trend + weeklyPattern + promoBoost + noise;
          spots.add(FlSpot(i.toDouble(), value.clamp(3000, 9000)));
        }
        
        return spots;
      }
      
      // Normal period 1: 0-29
      segments.add(LineChartBarData(
        spots: createSpots(0, 30),
        isCurved: true,
        curveSmoothness: 0.4,
        color: Colors.blue[600],
        barWidth: 3,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: Colors.blue[600]!.withOpacity(0.1),
        ),
      ));
      
      // Promo 1: 30-50 (Green)
      segments.add(LineChartBarData(
        spots: createSpots(30, 50),
        isCurved: true,
        curveSmoothness: 0.4,
        color: Colors.green[600],
        barWidth: 3,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: Colors.green[600]!.withOpacity(0.1),
        ),
      ));
      
      // Normal period 2: 50-90
      segments.add(LineChartBarData(
        spots: createSpots(50, 90),
        isCurved: true,
        curveSmoothness: 0.4,
        color: Colors.blue[600],
        barWidth: 3,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: Colors.blue[600]!.withOpacity(0.1),
        ),
      ));
      
      // Promo 2: 90-110 (Green)
      segments.add(LineChartBarData(
        spots: createSpots(90, 110),
        isCurved: true,
        curveSmoothness: 0.4,
        color: Colors.green[600],
        barWidth: 3,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: Colors.green[600]!.withOpacity(0.1),
        ),
      ));
      
      // Normal period 3: 110-140
      segments.add(LineChartBarData(
        spots: createSpots(110, 140),
        isCurved: true,
        curveSmoothness: 0.4,
        color: Colors.blue[600],
        barWidth: 3,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: Colors.blue[600]!.withOpacity(0.1),
        ),
      ));
      
      // Promo 3: 140-160 (Green)
      segments.add(LineChartBarData(
        spots: createSpots(140, 160),
        isCurved: true,
        curveSmoothness: 0.4,
        color: Colors.green[600],
        barWidth: 3,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: Colors.green[600]!.withOpacity(0.1),
        ),
      ));
      
      // Normal period 4: 160-180
      segments.add(LineChartBarData(
        spots: createSpots(160, 180),
        isCurved: true,
        curveSmoothness: 0.4,
        color: Colors.blue[600],
        barWidth: 3,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: Colors.blue[600]!.withOpacity(0.1),
        ),
      ));
      
      return segments;
    }

    List<LineChartBarData> lineSegments = getLineChartBarData();
    
    // Get all spots for tooltip handling
    List<FlSpot> getAllSpots() {
      List<FlSpot> allSpots = [];
      for (var segment in lineSegments) {
        allSpots.addAll(segment.spots);
      }
      return allSpots;
    }
    
    DateTime now = DateTime.now();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: ui.UIUtils.getCardBorderRadius(),
        boxShadow: ui.UIUtils.getCardShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Promotion Impact Analysis',
            style: TextStyle(
              fontSize: ui.UIUtils.getResponsiveFontSize(context, 16),
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 16, height: 3, color: Colors.blue[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Normal Sales',
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16,
                    height: 3,
                    color: Colors.green[100]!.withOpacity(0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Promo Period',
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 16, height: 3, color: Colors.green[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Promo Sales',
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Stack(
              children: [
                // Sticky Y-axis
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 30,
                  width: 50,
                  child: Container(
                    color: Colors.white,
                    child: CustomPaint(
                      painter: YAxisPainter(
                        minY: 2500,
                        maxY: 9000,
                        interval: 1000,
                      ),
                    ),
                  ),
                ),
                // Scrollable chart
                Padding(
                  padding: const EdgeInsets.only(left: 50),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 3.2,
                      padding: const EdgeInsets.only(top: 10, bottom: 30, right: 40, left: 20),
                      child: Stack(
                        children: [
                          // Promotion period highlights with labels
                          Positioned.fill(
                            child: CustomPaint(
                              painter: PromotionHighlightPainter(
                                minX: -5,
                                maxX: 185,
                                chartWidth: MediaQuery.of(context).size.width * 3.2 - 60,
                                promotionPeriods: [
                                  {'start': 30.0, 'end': 50.0, 'label': 'B1F1'},
                                  {'start': 90.0, 'end': 110.0, 'label': 'Flash'},
                                  {'start': 140.0, 'end': 160.0, 'label': '20%'},
                                ],
                              ),
                            ),
                          ),
                          // Line chart
                          LineChart(
                            LineChartData(
                              minX: -5,
                              maxX: 185,
                              lineTouchData: LineTouchData(
                                enabled: true,
                                touchTooltipData: LineTouchTooltipData(
                                  tooltipBgColor: Colors.black87,
                                  tooltipRoundedRadius: 8,
                                  tooltipPadding: EdgeInsets.all(8),
                                  getTooltipItems: (List<LineBarSpot> touchedSpots) {
                                    return touchedSpots.map((spot) {
                                      if (spot.x < 0 || spot.x > 180) return null;
                                      
                                      DateTime date = now.subtract(
                                        Duration(days: 180 - spot.x.toInt()),
                                      );
                                      String dateStr = DateFormat('MMM d').format(date);
                                      
                                      return LineTooltipItem(
                                        '$dateStr\nRM${(spot.y).toStringAsFixed(0)}',
                                        TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      );
                                    }).toList();
                                  },
                                ),
                              ),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: 1000,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(color: Colors.grey[200]!, strokeWidth: 1);
                                },
                              ),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
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
                                    interval: 1,
                                    getTitlesWidget: (value, meta) {
                                      if (value < 0 || value > 180) return const SizedBox();

                                      DateTime date = now.subtract(
                                        Duration(days: 180 - value.toInt()),
                                      );

                                      // Show month labels
                                      if (value % 30 == 0 || value == 0) {
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8, left: 5),
                                          child: Text(
                                            DateFormat('MMM').format(date),
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        );
                                      }
                                      
                                      return const SizedBox();
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: Border(
                                  bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                                  left: BorderSide(color: Colors.grey[300]!, width: 1),
                                ),
                              ),
                              minY: 2500,
                              maxY: 9000,
                              lineBarsData: lineSegments,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCriticalInfoCard(BuildContext context) {
    // Use StockAnalyzer to determine risk level
    stock.StockAnalysisResult analysis = stock.StockAnalyzer.analyzeStock(
      widget.product.daysWithoutStock,
      widget.product.forecast,
    );

    // Show if there's a recommendation OR if it's critical
    bool hasRecommendation =
        widget.product.recommendation != null &&
        widget.product.recommendation!.isNotEmpty;

    if (!hasRecommendation && !analysis.isCritical) return const SizedBox();

    return Container(
      padding: ui.UIUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: analysis.isCritical ? Colors.orange[50] : Colors.blue[50],
        borderRadius: ui.UIUtils.getCardBorderRadius(),
        border: Border.all(
          color: analysis.isCritical ? Colors.orange[200]! : Colors.blue[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                analysis.isCritical
                    ? Icons.warning_amber_rounded
                    : Icons.info_outline,
                color: analysis.isCritical
                    ? Colors.orange[600]
                    : Colors.blue[600],
                size: ui.UIUtils.getResponsiveFontSize(context, 24),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  analysis.isCritical
                      ? 'Critical - Stockout Expected'
                      : 'Recommendation',
                  style: TextStyle(
                    fontSize: ui.UIUtils.getResponsiveFontSize(context, 16),
                    fontWeight: FontWeight.bold,
                    color: analysis.isCritical
                        ? Colors.orange[800]
                        : Colors.blue[800],
                  ),
                ),
              ),
            ],
          ),
          if (analysis.isCritical) ...[
            const SizedBox(height: 12),
            Text(
              'Product needed soon',
              style: TextStyle(
                fontSize: ui.UIUtils.getResponsiveFontSize(context, 14),
                color: Colors.orange[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (hasRecommendation) ...[
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: analysis.isCritical
                      ? Colors.orange[600]
                      : Colors.blue[600],
                  size: ui.UIUtils.getResponsiveFontSize(context, 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.product.recommendation!,
                    style: TextStyle(
                      fontSize: ui.UIUtils.getResponsiveFontSize(context, 14),
                      color: analysis.isCritical
                          ? Colors.orange[700]
                          : Colors.blue[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// Custom painter for dashed line in legend
class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + 5, size.height / 2),
        paint,
      );
      startX += 8;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Add this YAxisPainter class at the bottom of your file (outside the widget class)
class YAxisPainter extends CustomPainter {
  final double minY;
  final double maxY;
  final double interval;

  YAxisPainter({
    required this.minY,
    required this.maxY,
    required this.interval,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1;

    final textPainter = TextPainter(
      textDirection: dart_ui.TextDirection.ltr,
      textAlign: TextAlign.right,
    );

    // Draw left border
    canvas.drawLine(
      Offset(size.width - 1, 0),
      Offset(size.width - 1, size.height),
      paint,
    );

    // Draw Y-axis labels
    for (double value = minY; value <= maxY; value += interval) {
      final normalizedY = 1 - (value - minY) / (maxY - minY);
      final y = normalizedY * size.height;

      // Draw horizontal grid line indicator
      paint.color = Colors.grey[200]!;
      canvas.drawLine(
        Offset(size.width - 1, y),
        Offset(size.width + 5, y),
        paint,
      );

      // Draw label
      final textSpan = TextSpan(
        text: '${(value / 1000).toStringAsFixed(1)}k',
        style: TextStyle(
          fontSize: 10,
          color: Colors.grey[600],
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: dart_ui.TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(size.width - textPainter.width - 8, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PromotionHighlightPainter extends CustomPainter {
  final double minX;
  final double maxX;
  final double chartWidth;
  final List<Map<String, dynamic>> promotionPeriods;

  PromotionHighlightPainter({
    required this.minX,
    required this.maxX,
    required this.chartWidth,
    required this.promotionPeriods,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final xRange = maxX - minX;

    for (var promo in promotionPeriods) {
      final start = promo['start'] as double;
      final end = promo['end'] as double;
      final label = promo['label'] as String;

      // Calculate positions
      final startX = ((start - minX) / xRange) * chartWidth;
      final endX = ((end - minX) / xRange) * chartWidth;

      // Draw light green rectangle
      final rect = Rect.fromLTWH(startX, 0, endX - startX, size.height);
      final paint = Paint()
        ..color = Colors.green[100]!.withOpacity(0.2)
        ..style = PaintingStyle.fill;
      canvas.drawRect(rect, paint);

      // Draw border
      final borderPaint = Paint()
        ..color = Colors.green[300]!.withOpacity(0.3)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      canvas.drawRect(rect, borderPaint);

      // Draw label
      final textSpan = TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.green[700],
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: dart_ui.TextDirection.ltr,
      );
      textPainter.layout();
      
      final labelX = startX + (endX - startX) / 2 - textPainter.width / 2;
      textPainter.paint(canvas, Offset(labelX, 8));
    }
  }

  @override
  bool shouldRepaint(PromotionHighlightPainter oldDelegate) => false;
}
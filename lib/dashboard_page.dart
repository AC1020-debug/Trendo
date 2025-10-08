import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'product_detail_page.dart';
import 'product_data.dart';
// Import the new utility classes
import 'utils/stock_analyzer.dart';
import 'utils/ui_utils.dart';
import 'models/enums.dart';
import 'sample_products.dart';
import 'widget/draggable_chatbot.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String selectedRiskLevel = 'Risk Level';
  String selectedSort = 'Sort';

  final List<String> riskLevels = ['Risk Level', 'Low', 'Medium', 'High'];
  final List<String> sortOptions = [
    'Sort',
    'Name A-Z',
    'Name Z-A',
    'Risk Level',
  ];

  // Sample product data

  List<ProductData> allProducts = sampleProducts;

  // --- Simplified using StockAnalyzer ---
  String get stockRiskSummary {
    List<String?> daysList = allProducts
        .map((p) => p.daysWithoutStock)
        .toList();
    Map<RiskLevel, int> summary = StockAnalyzer.generateRiskSummary(daysList);
    return StockAnalyzer.formatRiskSummary(summary);
  }

  List<String> get topSellingProducts {
    List<Map<String, dynamic>> productsWithUnits = allProducts.map((p) {
      int units = StockAnalyzer.extractUnitsFromForecast(p.forecast);
      return {"name": p.name, "units": units};
    }).toList();

    productsWithUnits.sort(
      (a, b) => (b["units"] as int).compareTo(a["units"] as int),
    );

    return productsWithUnits.take(3).map((e) => e["name"] as String).toList();
  }

  String get topSellingSummary {
    List<String> list = [];
    for (int i = 0; i < 3; i++) {
      if (i < topSellingProducts.length) {
        list.add("${i + 1}. ${topSellingProducts[i]}");
      } else {
        list.add("${i + 1}. —"); // placeholder
      }
    }
    return list.join("\n");
  }

  List<ProductData> get filteredProducts {
    List<ProductData> filtered = List.from(allProducts);

    // Filter by risk level using StockAnalyzer
    if (selectedRiskLevel != 'Risk Level') {
      filtered = filtered
          .where(
            (product) =>
                StockAnalyzer.calculateRiskLevel(
                  product.daysWithoutStock,
                ).toString() ==
                selectedRiskLevel,
          )
          .toList();
    }

    // Sort products
    if (selectedSort == 'Name A-Z') {
      filtered.sort((a, b) => a.name.compareTo(b.name));
    } else if (selectedSort == 'Name Z-A') {
      filtered.sort((a, b) => b.name.compareTo(a.name));
    } else if (selectedSort == 'Risk Level') {
      const riskOrder = {'High': 0, 'Medium': 1, 'Low': 2};
      filtered.sort((a, b) {
        String aRisk = StockAnalyzer.calculateRiskLevel(
          a.daysWithoutStock,
        ).toString();
        String bRisk = StockAnalyzer.calculateRiskLevel(
          b.daysWithoutStock,
        ).toString();
        return (riskOrder[aRisk] ?? 3).compareTo(riskOrder[bRisk] ?? 3);
      });
    }

    return filtered;
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
              'Dashboard',
              style: TextStyle(
                fontSize: UIUtils.getResponsiveFontSize(context, 20),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: false,
          ),
          body: SingleChildScrollView(
            padding: UIUtils.getResponsivePadding(context),
            child: Column(
              children: [
                _buildMetricsCards(),
                const SizedBox(height: 20),
                _buildFilters(),
                const SizedBox(height: 16),
                _buildProductList(),
              ],
            ),
          ),
        ),
        DraggableChatbot(),
      ],
    );
  }

  // Widget _buildMetricsCards() {
  //   return Column(
  //     children: [
  //       // First row: Total Forecast Sale & Forecasted Quantity
  //       Row(
  //         children: [
  //           Expanded(
  //             child: _buildMetricCard(
  //               title: 'Total Forecast Sale',
  //               value: 'RM 450,200',
  //               subtitle: '+7.2% vs last month',
  //               color: Colors.blue,
  //               icon: Icons.trending_up,
  //             ),
  //           ),
  //           const SizedBox(width: 12),
  //           Expanded(
  //             child: _buildMetricCard(
  //               title: 'Forecasted Quantity',
  //               value: '125k units',
  //               subtitle: '+9.1% vs last month',
  //               color: Colors.green,
  //               icon: Icons.inventory,
  //             ),
  //           ),
  //         ],
  //       ),
  //       const SizedBox(height: 12),
  //       // Second row: Stock Risk & Top Selling Product
  //       Row(
  //         children: [
  //           Expanded(
  //             child: _buildMetricCard(
  //               title: 'Stock Risk',
  //               value: stockRiskSummary,
  //               subtitle: '',
  //               color: Colors.orange,
  //               icon: Icons.warning_amber,
  //             ),
  //           ),
  //           const SizedBox(width: 12),
  //           Expanded(
  //             child: _buildMetricCard(
  //               title: 'Top Selling Product',
  //               value: topSellingSummary,
  //               subtitle: '',
  //               color: Colors.purple,
  //               icon: Icons.star,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildMetricCard({
  //   required String title,
  //   required String value,
  //   required String subtitle,
  //   required Color color,
  //   required IconData icon,
  // }) {
  //   return LayoutBuilder(
  //     builder: (context, constraints) {
  //       return Container(
  //         padding: UIUtils.getResponsivePadding(context),
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: UIUtils.getCardBorderRadius(),
  //           boxShadow: UIUtils.getCardShadow(),
  //         ),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Row(
  //               children: [
  //                 Icon(
  //                   icon,
  //                   color: color,
  //                   size: UIUtils.getResponsiveFontSize(context, 18),
  //                 ),
  //                 const SizedBox(width: 8),
  //                 Expanded(
  //                   child: Text(
  //                     title,
  //                     style: TextStyle(
  //                       fontSize: UIUtils.getResponsiveFontSize(context, 13),
  //                       color: Colors.grey[600],
  //                       fontWeight: FontWeight.w500,
  //                     ),
  //                     overflow: TextOverflow.ellipsis,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             const SizedBox(height: 8),
  //             Text(
  //               value,
  //               style: TextStyle(
  //                 fontSize: UIUtils.getResponsiveFontSize(context, 16),
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.grey[800],
  //               ),
  //             ),
  //             if (subtitle.isNotEmpty) ...[
  //               const SizedBox(height: 4),
  //               Text(
  //                 subtitle,
  //                 style: TextStyle(
  //                   fontSize: UIUtils.getResponsiveFontSize(context, 12),
  //                   color: Colors.green[600],
  //                   fontWeight: FontWeight.w500,
  //                 ),
  //               ),
  //             ],
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
  Widget _buildMetricsCards() {
    return Column(
      children: [
        _buildSalesTrendChart(),
        const SizedBox(height: 16),
        _buildWeekdayVsWeekendChart(),
        const SizedBox(height: 16),
        _buildPromoVsNonPromoChart(),
      ],
    );
  }

  Widget _buildSalesTrendChart() {
    final List<FlSpot> spots = [
      FlSpot(0, 3100), // Fri last week
      FlSpot(1, 5200), // Sat last week
      FlSpot(2, 5800), // Sun
      FlSpot(3, 4000), // Mon
      FlSpot(4, 3300), // Tue
      FlSpot(5, 3400), // Wed (Today = Wed)
      FlSpot(6, 3200), // Thu (Tomorrow forecast)
    ];

    // Today & Forecast
    final today = spots[5].y;
    final forecast = spots[6].y;

    // Compare forecast vs today
    final diffPct = ((forecast - today) / today) * 100;

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
            children: [
              Icon(Icons.trending_up, color: Colors.blue[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'Sales Trend',
                style: TextStyle(
                  fontSize: UIUtils.getResponsiveFontSize(context, 16),
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: diffPct >= 0 ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: diffPct >= 0 ? Colors.green[300]! : Colors.red[300]!,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  diffPct >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                  color: diffPct >= 0 ? Colors.green[700] : Colors.red[700],
                  size: 16,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    "Next Day Sales: RM${(forecast / 1000).toStringAsFixed(1)}k "
                    "(${diffPct >= 0 ? '+' : ''}${diffPct.toStringAsFixed(0)}%)",
                    style: TextStyle(
                      fontSize: UIUtils.getResponsiveFontSize(context, 13),
                      color: diffPct >= 0 ? Colors.green[700] : Colors.red[700],
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: MediaQuery.of(context).size.height * 0.25,
            child: LineChart(
              LineChartData(
                // ✅ Calculate dynamic min/max for Y axis
                minY:
                    (spots.map((e) => e.y).reduce((a, b) => a < b ? a : b) -
                            500)
                        .clamp(0, double.infinity),
                maxY:
                    spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 500,

                gridData: FlGridData(show: true, drawVerticalLine: false),

                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 1000, // ✅ step by 1k
                      getTitlesWidget: (value, meta) {
                        if (value % 1000 == 0) {
                          return Text(
                            '${(value ~/ 1000)}k',
                            style: TextStyle(
                              fontSize: UIUtils.getResponsiveFontSize(
                                context,
                                11,
                              ),
                              color: Colors.grey[600],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
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
                        final now = DateTime.now();
                        final start = now.subtract(const Duration(days: 5));

                        if (value.toInt() >= 0 && value.toInt() <= 6) {
                          final date = start.add(Duration(days: value.toInt()));
                          String label;

                          if (value.toInt() == 4) {
                            label = "Yest";
                          } else if (value.toInt() == 5) {
                            label = "Today";
                          } else if (value.toInt() == 6) {
                            label = "Tmr";
                          } else {
                            label = "${date.day}/${date.month}";
                          }

                          final isLongLabel = label.length > 5;

                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: UIUtils.getResponsiveFontSize(
                                  context,
                                  isLongLabel ? 9 : 11,
                                ),
                                color: value.toInt() == 6
                                    ? Colors.orange[700]
                                    : Colors.grey[600],
                                fontWeight: value.toInt() == 6
                                    ? FontWeight.bold
                                    : FontWeight.normal,
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

                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.blue[600],
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: index == 6 ? 6 : 4,
                          color: index == 6 ? Colors.orange : Colors.blue[600]!,
                          strokeWidth: index == 6 ? 2 : 0,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue[600]!.withOpacity(0.1),
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

  Widget _buildWeekdayVsWeekendChart() {
    // 🔄 Use same data as Sales Trend chart
    final sales = [3100, 5200, 5800, 4000, 3300, 3400, 3200];

    final weekdaySales = [
      sales[0],
      sales[3],
      sales[4],
      sales[5],
    ]; // Fri, Mon, Tue, Wed
    final weekendSales = [sales[1], sales[2]]; // Sat, Sun

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
            children: [
              Icon(Icons.calendar_today, color: Colors.purple[600], size: 20),
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
                        switch (value.toInt()) {
                          case 0:
                            return Text(
                              'Weekday',
                              style: TextStyle(
                                fontSize: UIUtils.getResponsiveFontSize(
                                  context,
                                  12,
                                ),
                                color: Colors.grey[700],
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
                                color: Colors.grey[700],
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

  Widget _buildPromoVsNonPromoChart() {
    // 🔄 Use same data as Sales Trend chart
    final sales = [3100, 5200, 5800, 4000, 3300, 3400, 3200];

    final nonPromoSales = [
      sales[0],
      sales[1],
      sales[3],
      sales[4],
      sales[5],
    ]; // Normal days
    final promoSales = [sales[2]]; // Promo days (weekend)

    final nonPromoAvg =
        nonPromoSales.reduce((a, b) => a + b) / nonPromoSales.length;
    final promoAvg = promoSales.reduce((a, b) => a + b) / promoSales.length;

    final ratio = (promoAvg / nonPromoAvg);

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
            children: [
              Icon(Icons.local_offer, color: Colors.orange[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'Promo vs Non-Promo Sales',
                style: TextStyle(
                  fontSize: UIUtils.getResponsiveFontSize(context, 16),
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
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
              "🔥 Promo: ${ratio.toStringAsFixed(2)}x boost in sales",
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
                alignment: BarChartAlignment.spaceAround,
                maxY: (promoAvg / 1000).ceil() * 1000,
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
                        switch (value.toInt()) {
                          case 0:
                            return Text(
                              'Non-Promo',
                              style: TextStyle(
                                fontSize: UIUtils.getResponsiveFontSize(
                                  context,
                                  12,
                                ),
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          case 1:
                            return Text(
                              'With Promo',
                              style: TextStyle(
                                fontSize: UIUtils.getResponsiveFontSize(
                                  context,
                                  12,
                                ),
                                color: Colors.grey[700],
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
                        toY: nonPromoAvg,
                        color: Colors.grey[400],
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
                        toY: promoAvg,
                        color: Colors.orange[400],
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

  Widget _buildFilters() {
    return Row(
      children: [
        const SizedBox(width: 8),
        Expanded(
          child: _buildFilterDropdown(
            value: selectedRiskLevel,
            items: riskLevels,
            onChanged: (value) => setState(() => selectedRiskLevel = value),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildFilterDropdown(
            value: selectedSort,
            items: sortOptions,
            onChanged: (value) => setState(() => selectedSort = value),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: UIUtils.getCardBorderRadius(),
        color: Colors.white,
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: Container(),
        style: TextStyle(
          fontSize: UIUtils.getResponsiveFontSize(context, 13),
          color: Colors.grey[800],
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: (newValue) {
          if (newValue != null) onChanged(newValue);
        },
      ),
    );
  }

  Widget _buildProductList() {
    List<ProductData> products = filteredProducts;

    if (products.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: UIUtils.getCardBorderRadius(),
          boxShadow: UIUtils.getCardShadow(),
        ),
        child: Center(
          child: Text(
            'No products match the selected filters',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: UIUtils.getResponsiveFontSize(context, 16),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: UIUtils.getCardBorderRadius(),
        boxShadow: UIUtils.getCardShadow(),
      ),
      child: Column(
        children: products.asMap().entries.map((entry) {
          int index = entry.key;
          ProductData product = entry.value;

          // Use StockAnalyzer for analysis
          StockAnalysisResult analysis = StockAnalyzer.analyzeStock(
            product.daysWithoutStock,
            product.forecast,
          );

          return Column(
            children: [
              _buildProductItem(
                name: product.name,
                forecast: product.forecast,
                currentStock: product.currentStock,
                daysWithoutStock: product.daysWithoutStock,
                recommendation: product.recommendation,
                status: analysis.riskLevelString,
                statusColor: analysis.riskColor,
              ),
              if (index < products.length - 1) const Divider(height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductItem({
    required String name,
    required String forecast,
    String? currentStock,
    String? daysWithoutStock,
    String? recommendation,
    required String status,
    required Color statusColor,
  }) {
    return Padding(
      padding: UIUtils.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: UIUtils.getResponsiveFontSize(context, 18),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: statusColor, width: 1),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: UIUtils.getResponsiveFontSize(context, 12),
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Forecast: $forecast',
            style: TextStyle(
              fontSize: UIUtils.getResponsiveFontSize(context, 14),
              color: Colors.grey[700],
            ),
          ),
          if (currentStock != null && currentStock.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Current Stock: $currentStock',
              style: TextStyle(
                fontSize: UIUtils.getResponsiveFontSize(context, 14),
                color: Colors.grey[700],
              ),
            ),
          ],
          if (daysWithoutStock != null && daysWithoutStock.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Days until without Stock: $daysWithoutStock',
              style: TextStyle(
                fontSize: UIUtils.getResponsiveFontSize(context, 14),
                color: Colors.grey[700],
              ),
            ),
          ],
          if (recommendation != null && recommendation.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: UIUtils.getResponsiveFontSize(context, 16),
                  color: Colors.orange[600],
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    recommendation,
                    style: TextStyle(
                      fontSize: UIUtils.getResponsiveFontSize(context, 14),
                      color: Colors.orange[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // Find the product data to pass to detail page
                ProductData productToPass = ProductData(
                  name: name,
                  forecast: forecast,
                  currentStock: currentStock,
                  daysWithoutStock: daysWithoutStock,
                  recommendation: recommendation,
                  stockStatus: status,
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProductDetailPage(product: productToPass),
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'View Details',
                style: TextStyle(
                  fontSize: UIUtils.getResponsiveFontSize(context, 14),
                  color: Colors.blue[600],
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

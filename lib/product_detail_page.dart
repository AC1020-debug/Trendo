import 'package:flutter/material.dart';
import 'product_data.dart';
import 'package:intl/intl.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductData product;

  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  String selectedTimeframe = 'Daily';
  final List<String> timeframes = ['Daily', 'Weekly', 'Monthly'];

  // Helper method for responsive font
  double scaleFont(BuildContext context, double fontSize) {
    double screenWidth = MediaQuery.of(context).size.width;
    return fontSize * (screenWidth / 375); // 375 reference width
  }

  // Generate forecast dynamically
  List<Map<String, dynamic>> getForecastData(String timeframe) {
    List<Map<String, dynamic>> data = [];
    DateTime today = DateTime.now();

    if (timeframe == 'Daily') {
      for (int i = 0; i < 7; i++) {
        DateTime day = today.add(Duration(days: i));
        String dayLabel =
            '${DateFormat.EEEE().format(day)} (${DateFormat.MMMd().format(day)})';
        data.add({
          'period': dayLabel,
          'units': (10 + i * 2),
          'status': i < 2 ? 'warning' : i < 4 ? 'critical' : 'normal',
        });
      }
    } else if (timeframe == 'Weekly') {
      for (int i = 0; i < 4; i++) {
        DateTime weekStart = today.add(Duration(days: i * 7));
        DateTime weekEnd = weekStart.add(Duration(days: 6));
        String label = i == 0
            ? 'Current Week (${DateFormat.MMMd().format(weekStart)}-${DateFormat.MMMd().format(weekEnd)})'
            : 'Next Week ${i} (${DateFormat.MMMd().format(weekStart)}-${DateFormat.MMMd().format(weekEnd)})';
        data.add({
          'period': label,
          'units': (30 - i * 5),
          'status': i == 3 ? 'critical' : i == 1 ? 'warning' : 'normal',
        });
      }
    } else if (timeframe == 'Monthly') {
      for (int i = 0; i < 4; i++) {
        DateTime month = DateTime(today.year, today.month + i, 1);
        data.add({
          'period': DateFormat.MMMM().format(month),
          'units': (100 - i * 20),
          'status': i == 2 ? 'warning' : 'normal',
        });
      }
    }

    return data;
  }

  String getRiskLevel(String? daysWithoutStock) {
    if (daysWithoutStock == null || daysWithoutStock.isEmpty) return 'Low';
    final match = RegExp(r'(\d+)').firstMatch(daysWithoutStock);
    if (match == null) return 'Low';
    int days = int.parse(match.group(1)!);
    if (days < 5) return 'High';
    if (days <= 30) return 'Medium';
    return 'Low';
  }

  Color getRiskColor(String riskLevel) {
    switch (riskLevel) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
      default:
        return Colors.green;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'critical':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'normal':
      default:
        return Colors.green;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case 'critical':
        return Icons.error;
      case 'warning':
        return Icons.warning;
      case 'normal':
      default:
        return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    String riskLevel = getRiskLevel(widget.product.daysWithoutStock);
    Color riskColor = getRiskColor(riskLevel);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        elevation: 4,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        title: Text(
          widget.product.name,
          style: TextStyle(
            fontSize: scaleFont(context, 20),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(context, riskLevel, riskColor),
            SizedBox(height: scaleFont(context, 20)),
            _buildTimeframeSelector(context),
            SizedBox(height: scaleFont(context, 16)),
            _buildForecastCard(context),
            SizedBox(height: scaleFont(context, 20)),
            _buildCriticalInfoCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, String riskLevel, Color riskColor) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(scaleFont(context, 20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status:',
            style: TextStyle(
              fontSize: scaleFont(context, 18),
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: scaleFont(context, 8)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: scaleFont(context, 12),
              vertical: scaleFont(context, 6),
            ),
            decoration: BoxDecoration(
              color: riskColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: riskColor, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  riskLevel == 'High'
                      ? Icons.error
                      : riskLevel == 'Medium'
                          ? Icons.warning
                          : Icons.check_circle,
                  color: riskColor,
                  size: scaleFont(context, 16),
                ),
                SizedBox(width: scaleFont(context, 6)),
                Flexible(
                  child: Text(
                    '$riskLevel Stock - Action Needed',
                    style: TextStyle(
                      fontSize: scaleFont(context, 14),
                      color: riskColor,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: scaleFont(context, 16)),
          if (widget.product.currentStock != null)
            Text(
              'Current Stock: ${widget.product.currentStock}',
              style: TextStyle(
                fontSize: scaleFont(context, 16),
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 5),
          if (widget.product.daysWithoutStock != null)
            Text(
              'Days until without Stock: ${widget.product.daysWithoutStock}',
              style: TextStyle(
                fontSize: scaleFont(context, 16),
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 5),
          Text(
            'Forecast: ${widget.product.forecast}',
            style: TextStyle(
              fontSize: scaleFont(context, 16),
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeframeSelector(BuildContext context) {
    return Row(
      children: timeframes.map((timeframe) {
        bool isSelected = selectedTimeframe == timeframe;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => selectedTimeframe = timeframe),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: scaleFont(context, 4)),
              padding: EdgeInsets.symmetric(vertical: scaleFont(context, 12)),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue[600] : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? Colors.blue[600]! : Colors.grey[300]!,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.2),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                timeframe,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: scaleFont(context, 14),
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildForecastCard(BuildContext context) {
    List<Map<String, dynamic>> data = getForecastData(selectedTimeframe);

    return Container(
      padding: EdgeInsets.all(scaleFont(context, 20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selectedTimeframe == 'Daily'
                ? 'Next 7 Days Forecast'
                : selectedTimeframe == 'Weekly'
                    ? 'Next 4 Weeks Forecast'
                    : 'Next 4 Months Forecast',
            style: TextStyle(
              fontSize: scaleFont(context, 18),
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: scaleFont(context, 16)),
          ...data.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: scaleFont(context, 12)),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      item['period'],
                      style: TextStyle(
                        fontSize: scaleFont(context, 14),
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${item['units']} units',
                      style: TextStyle(
                        fontSize: scaleFont(context, 14),
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  Icon(
                    getStatusIcon(item['status']),
                    color: getStatusColor(item['status']),
                    size: scaleFont(context, 20),
                  ),
                ],
              ),
            ),
          ).toList(),
        ],
      ),
    );
  }

  Widget _buildCriticalInfoCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(scaleFont(context, 20)),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange[600],
                size: scaleFont(context, 24),
              ),
              SizedBox(width: scaleFont(context, 8)),
              Text(
                'Critical - Stockout Expected',
                style: TextStyle(
                  fontSize: scaleFont(context, 16),
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[800],
                ),
              ),
            ],
          ),
          SizedBox(height: scaleFont(context, 12)),
          Text(
            'Product needed by Wednesday',
            style: TextStyle(
              fontSize: scaleFont(context, 14),
              color: Colors.orange[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: scaleFont(context, 16)),
          if (widget.product.recommendation != null &&
              widget.product.recommendation!.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.orange[600],
                  size: scaleFont(context, 20),
                ),
                SizedBox(width: scaleFont(context, 8)),
                Expanded(
                  child: Text(
                    widget.product.recommendation!,
                    style: TextStyle(
                      fontSize: scaleFont(context, 14),
                      color: Colors.orange[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'product_data.dart';
import 'package:intl/intl.dart';
// Import utility classes
import '../utils/stock_analyzer.dart' as stock;
import '../utils/ui_utils.dart' as ui;
import '../models/enums.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductData product;

  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  String selectedTimeframe = 'Daily';
  final List<String> timeframes = ['Daily', 'Weekly', 'Monthly'];

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

  @override
  Widget build(BuildContext context) {
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
            _buildTimeframeSelector(context),
            const SizedBox(height: 16),
            _buildForecastCard(context),
            const SizedBox(height: 20),
            _buildCriticalInfoCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    // Use StockAnalyzer for comprehensive analysis
    stock.StockAnalysisResult analysis = stock.StockAnalyzer.analyzeStock(
      widget.product.daysWithoutStock, 
      widget.product.forecast
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
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
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

  Widget _buildTimeframeSelector(BuildContext context) {
    return Row(
      children: timeframes.map((timeframe) {
        bool isSelected = selectedTimeframe == timeframe;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => selectedTimeframe = timeframe),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue[600] : Colors.white,
                borderRadius: ui.UIUtils.getCardBorderRadius(),
                border: Border.all(
                  color: isSelected ? Colors.blue[600]! : Colors.grey[300]!,
                ),
                boxShadow: isSelected ? ui.UIUtils.getCardShadow(opacity: 0.2) : [],
              ),
              child: Text(
                timeframe,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ui.UIUtils.getResponsiveFontSize(context, 14),
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
            selectedTimeframe == 'Daily'
                ? 'Next 7 Days Forecast'
                : selectedTimeframe == 'Weekly'
                    ? 'Next 4 Weeks Forecast'
                    : 'Next 4 Months Forecast',
            style: TextStyle(
              fontSize: ui.UIUtils.getResponsiveFontSize(context, 18),
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          ...data.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      item['period'],
                      style: TextStyle(
                        fontSize: ui.UIUtils.getResponsiveFontSize(context, 14),
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${item['units']} units',
                      style: TextStyle(
                        fontSize: ui.UIUtils.getResponsiveFontSize(context, 14),
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  Icon(
                    stock.StockAnalyzer.getStatusIcon(item['status']),
                    color: stock.StockAnalyzer.getStatusColor(item['status']),
                    size: ui.UIUtils.getResponsiveFontSize(context, 20),
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
    // Use StockAnalyzer to determine risk level
    stock.StockAnalysisResult analysis = stock.StockAnalyzer.analyzeStock(
      widget.product.daysWithoutStock, 
      widget.product.forecast
    );

    // Show if there's a recommendation OR if it's critical
    bool hasRecommendation = widget.product.recommendation != null && 
                           widget.product.recommendation!.isNotEmpty;
    
    if (!hasRecommendation && !analysis.isCritical) return const SizedBox();

    return Container(
      padding: ui.UIUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: analysis.isCritical ? Colors.orange[50] : Colors.blue[50],
        borderRadius: ui.UIUtils.getCardBorderRadius(),
        border: Border.all(
          color: analysis.isCritical ? Colors.orange[200]! : Colors.blue[200]!, 
          width: 1
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                analysis.isCritical ? Icons.warning_amber_rounded : Icons.info_outline,
                color: analysis.isCritical ? Colors.orange[600] : Colors.blue[600],
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
                    color: analysis.isCritical ? Colors.orange[800] : Colors.blue[800],
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
                  color: analysis.isCritical ? Colors.orange[600] : Colors.blue[600],
                  size: ui.UIUtils.getResponsiveFontSize(context, 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.product.recommendation!,
                    style: TextStyle(
                      fontSize: ui.UIUtils.getResponsiveFontSize(context, 14),
                      color: analysis.isCritical ? Colors.orange[700] : Colors.blue[700],
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
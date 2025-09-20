import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'product_detail_page.dart';
import 'product_data.dart'; 

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String selectedRiskLevel = 'Risk Level';
  String selectedSort = 'Sort';

  final List<String> riskLevels = ['Risk Level', 'Low', 'Medium', 'High'];
  final List<String> sortOptions = ['Sort', 'Name A-Z', 'Name Z-A', 'Risk Level'];

  // Sample product data
  List<ProductData> allProducts = [
    ProductData(
      name: 'Rice',
      forecast: 'RM200k (50k units)',
      currentStock: '50 units',
      daysWithoutStock: '3 days',
      recommendation: 'Consider 29 weeks',
      stockStatus: 'Low Stock',
    ),
    ProductData(
      name: 'Egg',
      forecast: 'Stock increase 35 kg',
      currentStock: '120 units',
      daysWithoutStock: '15 days',
      recommendation: 'Stock level optimal',
      stockStatus: 'Overstock',
    ),
  ];

  // --- Risk calculation helpers ---
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

  String get stockRiskSummary {
    int high = allProducts.where((p) => getRiskLevel(p.daysWithoutStock) == 'High').length;
    int medium = allProducts.where((p) => getRiskLevel(p.daysWithoutStock) == 'Medium').length;
    int low = allProducts.where((p) => getRiskLevel(p.daysWithoutStock) == 'Low').length;

    return '$high High\n$medium Medium\n$low Low';
  }

  List<String> get topSellingProducts {
    List<Map<String, dynamic>> productsWithUnits = allProducts.map((p) {
      final match = RegExp(r'(\d+)')
          .firstMatch(p.forecast.replaceAll(RegExp(r'[^0-9]'), ''));
      int units = 0;
      if (match != null) {
        units = int.tryParse(match.group(1)!) ?? 0;
      }
      return {"name": p.name, "units": units};
    }).toList();

    productsWithUnits.sort((a, b) => (b["units"] as int).compareTo(a["units"] as int));

    return productsWithUnits.take(3).map((e) => e["name"] as String).toList();
  }

  String get topSellingSummary {
    List<String> list = [];
    for (int i = 0; i < 3; i++) {
      if (i < topSellingProducts.length) {
        list.add("${i + 1}. ${topSellingProducts[i]}");
      } else {
        list.add("${i + 1}. –"); // placeholder
      }
    }
    return list.join("\n");
  }

  List<ProductData> get filteredProducts {
    List<ProductData> filtered = List.from(allProducts);

    // Filter by risk level
    if (selectedRiskLevel != 'Risk Level') {
      filtered = filtered
          .where((product) => getRiskLevel(product.daysWithoutStock) == selectedRiskLevel)
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
        return (riskOrder[getRiskLevel(a.daysWithoutStock)] ?? 3)
            .compareTo(riskOrder[getRiskLevel(b.daysWithoutStock)] ?? 3);
      });
    }

    return filtered;
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
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
    );
  }

  Widget _buildMetricsCards() {
  return Column(
    children: [
      // First row: Total Forecast Sale & Forecasted Quantity
      Row(
        children: [
          Expanded(
            child: _buildMetricCard(
              title: 'Total Forecast Sale',
              value: 'RM 450,200',
              subtitle: '+7.2% vs last month',
              color: Colors.blue,
              icon: Icons.trending_up,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMetricCard(
              title: 'Forecasted Quantity',
              value: '125k units',
              subtitle: '+9.1% vs last month',
              color: Colors.green,
              icon: Icons.inventory,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      // Second row: Stock Risk & Top Selling Product
      Row(
        children: [
          Expanded(
            child: _buildMetricCard(
              title: 'Stock Risk',
              value: stockRiskSummary,
              subtitle: '',
              color: Colors.orange,
              icon: Icons.warning_amber,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMetricCard(
              title: 'Top Selling Product',
              value: topSellingSummary,
              subtitle: '',
              color: Colors.purple,
              icon: Icons.star,
            ),
          ),
        ],
      ),
    ],
  );
}


  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = MediaQuery.of(context).size.width;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: screenWidth * 0.04),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: screenWidth * 0.025, // smaller & responsive
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: screenWidth * 0.028,
                    color: Colors.green[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        );
      },
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
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: Container(),
        style: TextStyle(
          fontSize: 13,
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
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'No products match the selected filters',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Container(
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
        children: products.asMap().entries.map((entry) {
          int index = entry.key;
          ProductData product = entry.value;

          String riskLevel = getRiskLevel(product.daysWithoutStock);
          Color riskColor = getRiskColor(riskLevel);

          return Column(
            children: [
              _buildProductItem(
                name: product.name,
                forecast: product.forecast,
                currentStock: product.currentStock,
                daysWithoutStock: product.daysWithoutStock,
                recommendation: product.recommendation,
                status: riskLevel,
                statusColor: riskColor,
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
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: screenWidth * 0.05, // responsive & smaller
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
                    fontSize: screenWidth * 0.035,
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
              fontSize: screenWidth * 0.032,
              color: Colors.grey[700],
            ),
          ),
          if (currentStock != null && currentStock.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Current Stock: $currentStock',
              style: TextStyle(
                fontSize: screenWidth * 0.032,
                color: Colors.grey[700],
              ),
            ),
          ],
          if (daysWithoutStock != null && daysWithoutStock.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Days until without Stock: $daysWithoutStock',
              style: TextStyle(
                fontSize: screenWidth * 0.032,
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
                  size: screenWidth * 0.035,
                  color: Colors.orange[600],
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    recommendation,
                    style: TextStyle(
                      fontSize: screenWidth * 0.032,
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
      builder: (context) => ProductDetailPage(product: productToPass),
    ),
  );
},
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'View Details',
                style: TextStyle(
                  fontSize: screenWidth * 0.032,
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

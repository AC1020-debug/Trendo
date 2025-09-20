import 'product_data.dart';

List<ProductData> sampleProducts = [
  ProductData(
    name: 'Rice',
    forecast: 'RM30,000 (1k units)',
    currentStock: '50 units',
    daysWithoutStock: '3 days',
    recommendation: 'Urgent restock needed — increase stock within 1 week',
    stockStatus: 'Low Stock',
  ),
  ProductData(
    name: 'Egg',
    forecast: 'RM5,000 (800 units)',
    currentStock: '120 units',
    daysWithoutStock: '15 days',
    recommendation: 'Stock level optimal — no action required',
    stockStatus: 'Optimal',
  ),
];

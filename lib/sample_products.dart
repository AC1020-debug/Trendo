import 'product_data.dart';

List<ProductData> sampleProducts = [
  ProductData(
    name: 'Egg',
    forecast: '-',
    currentStock: '100 units',
    daysWithoutStock: '-',
    recommendation: '-',
    stockStatus: '-',
  ),
  ProductData(
    name: 'Rice',
    forecast: 'RM30,000 (1k units)',
    currentStock: '50 units',
    daysWithoutStock: '3 days',
    recommendation: 'Urgent restock needed — increase stock within 1 week',
    stockStatus: 'Low Stock',
  ),
];

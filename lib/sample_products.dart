import 'product_data.dart';

List<ProductData> sampleProducts = [
  ProductData(
    name: 'Egg',
    forecast: 'RM38,200 (3,000 units)',
    currentStock: '1,800 units',
    daysWithoutStock: '16 days',
    recommendation: 'Maintain stock — stable demand expected',
    stockStatus: 'Healthy Stock',
  ),
  ProductData(
    name: 'Rice',
    forecast: 'RM35,000 (1,200 units)',
    currentStock: '80 units',
    daysWithoutStock: '3 days',
    recommendation: 'Urgent restock needed — replenish within 3 days',
    stockStatus: 'Low Stock',
  ),
  ProductData(
    name: 'Cooking Oil',
    forecast: 'RM23,000 (930 units)',
    currentStock: '226 units',
    daysWithoutStock: '8 days',
    recommendation: 'Restock soon — rising demand expected next week',
    stockStatus: 'Medium Stock',
  ),
  ProductData(
    name: 'Chicken',
    forecast: 'RM5,400 (820 units)',
    currentStock: '90 units',
    daysWithoutStock: '4 days',
    recommendation: 'Restock soon — rising demand expected next week',
    stockStatus: 'Medium Stock',
  ),
  ProductData(
    name: 'Sugar',
    forecast: 'RM4,500 (1,100 units)',
    currentStock: '950 units',
    daysWithoutStock: '12 days',
    recommendation: 'Stock sufficient — monitor sales next week',
    stockStatus: 'Healthy Stock',
  ),
];

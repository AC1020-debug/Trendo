import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProductPage extends StatefulWidget {
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _skuController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _stockQuantityController = TextEditingController();
  final _reorderPointController = TextEditingController();
  
  String? _selectedImagePath;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _productNameController.dispose();
    _skuController.dispose();
    _sellingPriceController.dispose();
    _costPriceController.dispose();
    _stockQuantityController.dispose();
    _reorderPointController.dispose();
    super.dispose();
  }

  void _showImagePicker() {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Select Product Image',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildImagePickerOption(
                icon: Icons.camera_alt,
                label: 'Camera',
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              _buildImagePickerOption(
                icon: Icons.photo_library,
                label: 'Gallery',
                onTap: () {
                  Navigator.pop(context);
                  _selectFromGallery();
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    ),
  );
}

Widget _buildImagePickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: (color ?? Colors.blue[600])?.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: color ?? Colors.blue[600]!,
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              size: 30,
              color: color ?? Colors.blue[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color ?? Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  void _selectFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _selectedImagePath = image.path;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image selected from gallery')),
      );
    }
    
    // Placeholder for now:
    setState(() {
      _selectedImagePath = 'gallery_image.jpg';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Image selection placeholder (add image_picker package)')),
    );
  }

  void _takePhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _selectedImagePath = image.path;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Photo captured from camera')),
      );
    }
  }

  void _addProduct() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      _formKey.currentState!.reset();
      _productNameController.clear();
      _skuController.clear();
      _sellingPriceController.clear();
      _costPriceController.clear();
      _stockQuantityController.clear();
      _reorderPointController.clear();
      setState(() {
        _selectedImagePath = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Image Upload (center top)
              // Product Image Upload
Center(
  child: Column(
    children: [
      GestureDetector(
        onTap: _showImagePicker,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[50],
          ),
          child: _selectedImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined,
                        size: 40, color: Colors.grey[400]),
                    const SizedBox(height: 4),
                    Text(
                      'Add Image',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
        ),
      ),
      const SizedBox(height: 8),
      Text(
        'Product Image',
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
    ],
  ),
),

              
              SizedBox(height: 16),
              
              // Product Name (full width)
              TextFormField(
                controller: _productNameController,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_bag),
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product name';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: 12),
              
              // All fields arranged vertically
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // SKU/Product Code
                      TextFormField(
                        controller: _skuController,
                        decoration: InputDecoration(
                          labelText: 'SKU/Product Code',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.qr_code),
                          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter SKU/Product Code';
                          }
                          return null;
                        },
                      ),
                      
                      SizedBox(height: 12),
                      
                      // Selling Price
                      TextFormField(
                        controller: _sellingPriceController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Selling Price',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                          prefixText: '\$ ',
                          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter selling price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid price';
                          }
                          return null;
                        },
                      ),
                      
                      SizedBox(height: 12),
                      
                      // Cost Price
                      TextFormField(
                        controller: _costPriceController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Cost Price',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.money_off),
                          prefixText: '\$ ',
                          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter cost price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid price';
                          }
                          return null;
                        },
                      ),
                      
                      SizedBox(height: 12),
                      
                      // Current Stock Quantity
                      TextFormField(
                        controller: _stockQuantityController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Current Stock Quantity',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.inventory),
                          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter stock quantity';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      
                      SizedBox(height: 12),
                      
                      // Reorder Point
                      TextFormField(
                        controller: _reorderPointController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Reorder Point',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.warning_amber),
                          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter reorder point';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Add Product Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Add Product',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
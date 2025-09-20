import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dashboard_page.dart';

class SalesHistoryPage extends StatefulWidget {
  @override
  _SalesHistoryPageState createState() => _SalesHistoryPageState();
}

class _SalesHistoryPageState extends State<SalesHistoryPage> {
  File? _selectedFile;
  String? _fileName;
  bool _isUploading = false;
  bool _isUploaded = false;

  Future<void> _pickAndUploadFile() async {
    try {
      // First, pick the file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _fileName = result.files.single.name;
          _isUploading = true;
        });
        
        // Show file selected message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File selected: $_fileName'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 1),
          ),
        );

        // Simulate file upload process
        await Future.delayed(Duration(seconds: 2));
        
        // Here you would implement actual file upload logic
        // For now, we'll just show success message
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          _isUploading = false;
          _isUploaded = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _generateForecast() {
    // Navigate to dashboard page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DashboardPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Sales Data'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[600]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Upload your sales history data to generate AI-powered forecasts and analytics',
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 10),

            // File Upload Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!, width: 2, style: BorderStyle.solid),
              ),
              child: Column(
                children: [
                  Icon(
                    _isUploaded ? Icons.check_circle : Icons.cloud_upload_outlined,
                    size: 48,
                    color: _isUploaded ? Colors.green[600] : Colors.grey[600],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isUploaded ? 'File Uploaded Successfully' : 'Upload Excel or CSV File',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _isUploaded ? Colors.green[700] : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (!_isUploaded)
                    Text(
                      'Supported formats: .xlsx, .xls, .csv',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  const SizedBox(height: 16),
                  
                  // Upload button (only show if not uploaded)
                  if (!_isUploaded)
                    ElevatedButton.icon(
                      onPressed: _isUploading ? null : _pickAndUploadFile,
                      icon: _isUploading 
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Icon(Icons.upload),
                      label: Text(_isUploading ? 'Uploading...' : 'Upload File'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),

                  // Uploaded file display
                  if (_isUploaded && _fileName != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.insert_drive_file, color: Colors.green[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _fileName!,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.green[800],
                              ),
                            ),
                          ),
                          Icon(Icons.check_circle, color: Colors.green[600]),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Forecast Button
            Container(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _generateForecast,
                icon: Icon(Icons.analytics, size: 24),
                label: Text(
                  'Generate AI Forecast',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
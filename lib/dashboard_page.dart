import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Colors.blue[600],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue[100],
                  child: Icon(Icons.person, size: 30, color: Colors.blue[600]),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('John Doe', 
                         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('Market Analyst', 
                         style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildDashboardItem(context, Icons.settings, 'Settings', 'Configure app preferences'),
            _buildDashboardItem(context, Icons.notifications, 'Notifications', 'Manage alert settings'),
            _buildDashboardItem(context, Icons.help, 'Help & Support', 'Get assistance'),
            _buildDashboardItem(context, Icons.info, 'About', 'App information'),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardItem(BuildContext context, IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue[600]),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title feature coming soon!')),
        );
      },
    );
  }
}
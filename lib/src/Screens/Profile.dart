import 'package:flutter/material.dart';
import 'package:try_space/Utilities/Auth.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final Auth _auth = Auth();

  final List<Color> gradientColors = const [
    Color(0xFFFF5F6D),
    Color(0xFFFFC371),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildButton(
              icon: Icons.edit,
              label: 'Edit Profile',
              onTap: () => Navigator.pushNamed(context, '/editprofile'),
            ),
            _buildButton(
              icon: Icons.settings,
              label: 'Settings',
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),
            _buildButton(
              icon: Icons.info_outline,
              label: 'About Us',
              onTap: () => Navigator.pushNamed(context, '/about'),
            ),
            const Spacer(),
            _buildButton(
              icon: Icons.logout,
              label: 'Sign Out',
              color: const Color.fromARGB(255, 255, 17, 0),
              onTap: () async {
                await _auth.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: color),
        label: Text(label, style: TextStyle(color: color)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.2),
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.centerLeft,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

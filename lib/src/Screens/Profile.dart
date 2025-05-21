import 'package:flutter/material.dart';
import 'package:try_space/Utilities/Auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:try_space/Models/UserModel.dart';
import 'package:try_space/Providers/UserProvider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final Auth _auth = Auth();
  bool _isLoading = true;

  final List<Color> gradientColors = const [
    Color(0xFFFF5F6D),
    Color(0xFFFFC371),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    final User? currentUser = FirebaseAuth.instance.currentUser;
    
    if (currentUser != null) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.fetchUser(currentUser.uid);
    }

    setState(() {
      _isLoading = false;
    });
  }

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
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Consumer<UserProvider>(
              builder: (context, userProvider, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 30),
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
                        // Clear user data in provider
                        Provider.of<UserProvider>(context, listen: false).clearUser();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                    ),
                  ],
                );
              },
            ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final userProvider = Provider.of<UserProvider>(context);
    final UserModel? user = userProvider.user;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: user?.profileImageUrl != null && user!.profileImageUrl.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    user.profileImageUrl,
                    fit: BoxFit.cover,
                    width: 100,
                    height: 100,
                    errorBuilder: (context, error, stackTrace) => 
                      const Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                )
              : const Center(
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
          ),
          const SizedBox(height: 16),
          
          // User Name
          Text(
            user?.name ?? 'User',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          
          // User Email
          Text(
            user?.email ?? 'No email found',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
        ],
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
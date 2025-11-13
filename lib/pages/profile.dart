import 'package:chatapp_real/pages/onboarding.dart';
import 'package:chatapp_real/services/shared_pref.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:chatapp_real/pages/login_page.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? myName, myEmail, myPicture;
  bool isLoading = true;

  Future<void> getSharedPref() async {
    final user = FirebaseAuth.instance.currentUser;

    myName = await SharedPrefreferencesHelper().GetUserDisplayName();
    myEmail = await SharedPrefreferencesHelper().GetUserEmail();
    myPicture = await SharedPrefreferencesHelper().GetUserImage();

    if (myName == null || myName!.isEmpty) {
      myName = user?.displayName ?? "No Name";
    }
    if (myEmail == null || myEmail!.isEmpty) {
      myEmail = user?.email ?? "No Email";
    }
    if (myPicture == null || myPicture!.isEmpty) {
      myPicture =
          user?.photoURL ??
          "https://cdn-icons-png.flaticon.com/512/149/149071.png";
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getSharedPref();
  }

  Future<void> logoutUser() async {
    try {
      await FirebaseAuth.instance.signOut();
      await SharedPrefreferencesHelper().clearUserData();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Onboarding()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
    }
  }

  Future<void> deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text(
          "Are you sure you want to permanently delete your account? This cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await user.delete();
                await SharedPrefreferencesHelper().clearUserData();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Onboarding()),
                  (route) => false,
                );
              } on FirebaseAuthException catch (e) {
                if (e.code == 'requires-recent-login') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please re-login before deleting your account.',
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
                }
              }
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double padding = size.width * 0.05;
    final double avatarSize = size.width * 0.3;

    return Scaffold(
      backgroundColor: const Color(0xff703eff),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: padding,
                      vertical: size.height * 0.02,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 24,
                            child: Icon(
                              Icons.arrow_back,
                              color: Color(0xff703eff),
                              size: 28,
                            ),
                          ),
                        ),
                        const Text(
                          "Profile",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 48), // Balance the Row
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: padding,
                        vertical: size.height * 0.03,
                      ),
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Image.network(
                                  myPicture!,
                                  height: avatarSize,
                                  width: avatarSize,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: avatarSize,
                                      width: avatarSize,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(
                                          100,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.person,
                                        size: 80,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: size.height * 0.04),

                            _buildInfoTile(
                              icon: Icons.person_outline,
                              title: myName ?? "No Name",
                              context: context,
                            ),

                            SizedBox(height: size.height * 0.03),

                            _buildInfoTile(
                              icon: Icons.email,
                              title: myEmail ?? "No Email",
                              context: context,
                            ),

                            SizedBox(height: size.height * 0.03),

                            _buildInfoTile(
                              icon: Icons.logout,
                              title: "Logout",
                              context: context,
                              onTap: logoutUser,
                            ),

                            SizedBox(height: size.height * 0.03),

                            _buildInfoTile(
                              icon: Icons.delete_outline,
                              title: "Delete Account",
                              context: context,
                              onTap: deleteAccount,
                            ),
                            SizedBox(height: size.height * 0.04),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required BuildContext context,
    VoidCallback? onTap,
  }) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: onTap,
      child: Material(
        elevation: 2.5,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.04,
            vertical: size.height * 0.018,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: const Color(0xff703eff),
                size: size.width * 0.08,
              ),
              SizedBox(width: size.width * 0.05),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: size.width * 0.05,
                    fontWeight: FontWeight.w600,
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
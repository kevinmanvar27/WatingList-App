import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

import '../Api_Model/Restaurent/User_restaurent.dart';
import '../Api_Model/Restaurent_users/All_users_show.dart';
import '../Api_Model/Restaurent_users/Waiting_user_by_id.dart';
import '../Api_Model/Setting/subscriptions status.dart';
import '../Appbar.dart';
import '../services/razorpay_service.dart';
import '../widgets/main_bottom_nav.dart';
import 'SubscriptionPlansScreen.dart';
import 'Home_screen.dart';
import 'Setting_Screen.dart';

class WaitingListScreen extends StatefulWidget {
  const WaitingListScreen({super.key});

  @override
  State<WaitingListScreen> createState() => _WaitingListScreenState();
}

class _WaitingListScreenState extends State<WaitingListScreen> with TickerProviderStateMixin {
  List<Data5> allUsers = [];
  bool _isDisposed = false;
  bool _isLoading = false;
  String? _authToken;
  Map<int, AnimationController> _animationControllers = {};
  Map<int, Future<void>?> _deleteTimers = {};
  int? _restaurantId;
  int? _operationalStatus;
  final RazorpayService _razorpayService = RazorpayService();
  bool _hasActiveSubscription = false;
  SubscriptionsStatusDatum? _activeSubscription;

  @override
  void initState() {
    super.initState();
    _loadAuthToken();
    _checkSubscription();
  }

  Future<void> _loadAuthToken() async {
    final sp = await SharedPreferences.getInstance();
    setState(() {
      _authToken = sp.getString('auth_token');
    });
    if (_authToken != null) {
      _fetchAllUsers();
      _fetchRestaurantData();
    }
  }

  Future<void> _checkSubscription() async {
    final hasSubscription = await _razorpayService.hasActiveSubscription();
    if (mounted) {
      setState(() {
        _hasActiveSubscription = hasSubscription;
      });
    }
  }

  Future<void> _fetchRestaurantData() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final token = sp.getString('auth_token');

      if (token == null) {
        throw Exception('No auth token found');
      }

      final response = await http.get(
        Uri.parse('https://waitinglist.rektech.work/api/restaurants/my-restaurant'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final restaurant = CreateRestaurant.fromJson(jsonData);

        if (mounted) {
          setState(() {
            _restaurantId = restaurant.data.id;
            _operationalStatus = restaurant.data.operationalStatus;
          });
          await _fetchAllUsers(restaurant.data.id);
        }
      }
    } catch (e) {
      // print('Fetch error: $e');
    }
  }

  Future<void> _fetchAllUsers([int? restaurantId]) async {
    if (_authToken == null || _authToken!.isEmpty) return;
    if (restaurantId == null) return;

    setState(() => _isLoading = true);

    try {
      final url = "https://waitinglist.rektech.work/api/restaurants/$restaurantId/waiting-users";
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final waitingListUsers = WaitingListUsers.fromJson(jsonResponse);

        setState(() {
          allUsers = waitingListUsers.data.map((datum) {
            return Data5(
              id: datum.id,
              username: datum.username,
              mobileNumber: datum.mobileNumber,
              totalUsersCount: datum.totalUsersCount,
              createdAt: datum.createdAt.toIso8601String(),
              updatedAt: datum.updatedAt.toIso8601String(),
            );
          }).toList();
        });
      }
    } catch (e) {
      // print("Error fetching users: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<Map<String, dynamic>?> _createUserAPI(String name, String mobile, int persons) async {
    if (_authToken == null || _authToken!.isEmpty) return null;

    if (mobile.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mobile number is required'), backgroundColor: Colors.red),
      );
      return null;
    }

    if (mobile.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mobile number must be exactly 10 digits'), backgroundColor: Colors.red),
      );
      return null;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(mobile)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mobile number must contain only digits'), backgroundColor: Colors.red),
      );
      return null;
    }

    try {
      final response = await http.post(
        Uri.parse("https://waitinglist.rektech.work/api/restaurant-users"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: jsonEncode({
          'username': name,
          'mobile_number': mobile,
          'total_users_count': persons,
        }),
      );
      // print("username$name");
      // print("mobile_number$mobile");
      // print("total_users_count$persons");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['data'];
      }
    } catch (e) {
      // print("Auth token$_authToken");
      // print("Auth token$");

      // print("Error creating user: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>?> _deleteUserAPI(int userId) async {
    if (_authToken == null || _authToken!.isEmpty) return null;

    try {
      final response = await http.delete(
        Uri.parse("https://waitinglist.rektech.work/api/restaurant-users/$userId"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      // print("Error deleting user: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>?> _updateUserAPI(int userId, String name, String mobile, int persons) async {
    if (_authToken == null || _authToken!.isEmpty) return null;

    try {
      final response = await http.put(
        Uri.parse("https://waitinglist.rektech.work/api/restaurant-users/$userId"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: jsonEncode({
          'username': name,
          'mobile_number': mobile,
          'total_users_count': persons,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      }
    } catch (e) {
      // print("Error updating user: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>?> _moveToDineInAPI(int userId) async {
    if (_authToken == null || _authToken!.isEmpty) return null;

    try {
      final response = await http.post(
        Uri.parse("https://waitinglist.rektech.work/api/restaurant-users/$userId/mark-dine-in"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      // print("Error moving user to dine-in: $e");
    }
    return null;
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Calling $phoneNumber'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch phone call'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // print('Error making call: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: Could not make call'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadActiveSubscription() async {
    try {
      final subscription = await _razorpayService.getActiveSubscription();
      if (mounted) {
        setState(() {
          _activeSubscription = subscription;
        });
      }
    } catch (e) {
      // print("Error loading active subscription: $e");
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    for (var controller in _animationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _callUser(String? mobile) {
    if (mobile == null || mobile.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No phone number available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _makePhoneCall(mobile);
  }

  void _toggleDineIn(int userId) {
    if (_isDisposed) return;

    final index = allUsers.indexWhere((user) => user.id == userId);
    if (index == -1) return;

    setState(() {
      allUsers[index].dineIn = !allUsers[index].dineIn;
    });

    if (allUsers[index].dineIn) {
      _deleteTimers[userId]?.ignore();

      _deleteTimers[userId] = Future.delayed(Duration(seconds: 2), () async {
        if (_isDisposed) return;

        final currentIndex = allUsers.indexWhere((u) => u.id == userId);
        if (currentIndex == -1 || !allUsers[currentIndex].dineIn) return;

        final controller = AnimationController(
          duration: Duration(seconds: 3),
          vsync: this,
        );
        _animationControllers[userId] = controller;

        controller.forward().then((_) async {
          if (_isDisposed) return;

          final finalIndex = allUsers.indexWhere((u) => u.id == userId);
          if (finalIndex != -1 && allUsers[finalIndex].dineIn) {
            // Call the new API to move user to dine-in status instead of deleting
            final dineInResult = await _moveToDineInAPI(userId);

            if (mounted) {
              setState(() {
                allUsers.removeWhere((user) => user.id == userId);
              });

              _animationControllers[userId]?.dispose();
              _animationControllers.remove(userId);

              if (dineInResult != null && dineInResult['message'] != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(dineInResult['message']),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            }
          }
        });
      });
    } else {
      _deleteTimers[userId]?.ignore();
      _deleteTimers.remove(userId);

      if (_animationControllers[userId] != null) {
        _animationControllers[userId]?.reverse();
        Future.delayed(Duration(milliseconds: 500), () {
          if (_animationControllers[userId] != null) {
            _animationControllers[userId]?.dispose();
            _animationControllers.remove(userId);
          }
        });
      }
    }
  }

  void _deleteUser(int userId) {
    if (_isDisposed) return;

    setState(() {
      allUsers.removeWhere((user) => user.id == userId);
    });

    _animationControllers[userId]?.dispose();
    _animationControllers.remove(userId);

    // If all users are deleted, trigger a refresh to update the UI properly
    if (allUsers.isEmpty && _restaurantId != null) {
      _fetchAllUsers(_restaurantId);
    }
  }

  String _formatTimeAgo(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} min';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hours';
      } else {
        return '${difference.inDays} days';
      }
    } catch (e) {
      return dateString;
    }
  }

  void _editUser(Data5 user) {
    final nameCtrl = TextEditingController(text: user.username);
    final mobileCtrl = TextEditingController(text: user.mobileNumber);
    final personsCtrl = TextEditingController(text: user.totalUsersCount.toString());

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text('Edit Person', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                ),
                SizedBox(height: 20),
                Text('Mobile', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                TextField(
                  controller: mobileCtrl,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                SizedBox(height: 12),
                Text('Persons', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                TextField(
                  controller: personsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                SizedBox(height: 12),
                Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          side: BorderSide(color: Color(0xFFFF6B00)),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          // nameCtrl.dispose();
                          // mobileCtrl.dispose();
                          // personsCtrl.dispose();
                          Navigator.pop(dialogContext);
                        },
                        child: Text('Cancel', style: TextStyle(color: Color(0xFFFF6B00), fontWeight: FontWeight.bold)),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFF6B00),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () async {
                          final name = nameCtrl.text.trim();
                          final mobile = mobileCtrl.text.trim();
                          final persons = int.tryParse(personsCtrl.text.trim()) ?? 1;

                          if (name.isEmpty || mobile.isEmpty) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(content: Text('Name and mobile required')),
                            );
                            return;
                          }

                          final result = await _updateUserAPI(user.id ?? 0, name, mobile, persons);

                          if (result != null) {
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                            if (_restaurantId != null) {
                              await _fetchAllUsers(_restaurantId);
                            }
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('User updated successfully'), backgroundColor: Colors.green),
                              );
                            }
                          }
                        },
                        child: Text('Update', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadAuthToken();
        await _checkSubscription();
        await _loadActiveSubscription();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: DynamicAppBar(
          rightButtonLabel: null,
          showRightButton: true,
          onStatusChanged: (isOpen) {
            setState(() {});
          },
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Waiting Persons", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text(
                        DateFormat('dd-MM-yyyy').format(DateTime.now()),
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      )
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF6F00),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () {
                      if (!_isDisposed) {
                        if (!_hasActiveSubscription) {
                          _showSubscriptionRequiredDialog();
                          return;
                        }
                        if (_operationalStatus == 0) {
                          // Restaurant is closed
                          showDialog(
                            context: context,
                            builder: (dialogContext) => Dialog(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(Icons.lock_clock, size: 60, color: Colors.red),
                                    SizedBox(height: 16),
                                    Text(
                                      'Are you sure?',
                                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'Your restaurant is currently closed. Do you want to add a user to the waiting list?',
                                      style: TextStyle(fontSize: 14, color: Colors.grey),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 25),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            style: OutlinedButton.styleFrom(
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                              side: BorderSide(color: Color(0xFFFF6B00)),
                                              padding: EdgeInsets.symmetric(vertical: 12),
                                            ),
                                            onPressed: () {
                                              Navigator.pop(dialogContext);
                                            },
                                            child: Text(
                                              'No',
                                              style: TextStyle(color: Color(0xFFFF6B00), fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color(0xFFFF6B00),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                              padding: EdgeInsets.symmetric(vertical: 12),
                                            ),
                                            onPressed: () {
                                              Navigator.pop(dialogContext);
                                              _showAddUserDialog(context);
                                            },
                                            child: Text(
                                              'Yes',
                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        } else {
                          // Restaurant is open - show add user dialog directly
                          _showAddUserDialog(context);
                        }
                      }
                    },
                    child: Text("Add Person", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 6, offset: Offset(0, 3))],
                  ),
                  child: Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                          decoration: BoxDecoration(
                            color: Color(0xFFFF6F00),
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(width: 5),
                              Text("#", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              SizedBox(width: 46),
                              Text("Name", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              SizedBox(width: 40),
                              Text("Persons", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              SizedBox(width: 15),
                              Text("Dine-in", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              SizedBox(width: 15),
                              Text("Call", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              SizedBox(width: 15),
                              Text("Actions", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: _isLoading
                            ? Center(child: CircularProgressIndicator(color: Color(0xFFFF6F00)))
                            : allUsers.isEmpty
                            ? Center(
                            child: Column(
                              children: [
                                Spacer(),
                                Text("No person are in waiting list"),
                                IconButton(onPressed: () async {
                                  await _loadAuthToken();
                                  await _checkSubscription();
                                  await _loadActiveSubscription();
                                }, icon: Icon(Icons.refresh)),
                                Spacer(),
                              ],
                            ))
                            : ListView.builder(
                          itemCount: allUsers.length,
                          itemBuilder: (context, index) {
                            final user = allUsers[index];
                            final controller = _animationControllers[user.id];

                            if (controller == null) {
                              return _buildUserRow(user, index + 1);
                            }

                            return SlideTransition(
                              position: Tween<Offset>(begin: Offset(0, 0), end: Offset(1.5, 0)).animate(
                                CurvedAnimation(parent: controller, curve: Curves.easeInOut),
                              ),
                              child: Opacity(
                                opacity: 1.0 - controller.value,
                                child: _buildUserRow(user, index + 1),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Added bottom navigation bar
        bottomNavigationBar: FutureBuilder<int>(
          future: _getShowHomePageFlag(), // Get the show_home_page flag
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(); // Show empty container while loading
            }
            
            final showHomePage = snapshot.data ?? 1; // Default to 1 (show home)
            // print('showHomePage value in WaitingListScreen: $showHomePage'); // Print show home page value
            
            return
              showHomePage ==0 ?
              MainBottomNavBar(
              currentIndex: 0, // Always highlight waiting list as current screen
              isLoggedIn: true, // User is logged in when on this screen
              showHomePage: showHomePage, // Pass the show home page flag
              onHomeTap: showHomePage == 1 ? () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => HomeScreen(refreshKey: UniqueKey(), showHomePage: showHomePage)),
                );
              } : null,
              onWaitingTap: () {
                // Already on waiting list screen, do nothing
              },
              onSettingsTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => Setting_Screen()),
                );
              },
              onLogoutTap: () async {
                final sp = await SharedPreferences.getInstance();
                await sp.clear();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => HomeScreen(refreshKey: UniqueKey(), showHomePage: showHomePage)),
                );
              },
            ): SizedBox();
          },
        ),
      ),
    );
  }
  
  // Helper method to get show_home_page flag from shared preferences
  Future<int> _getShowHomePageFlag() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getInt('show_home_page') ?? 1;
  }

  Widget _buildUserRow(Data5 user, int serialNumber) {
    final isDineIn = user.dineIn;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: GestureDetector(
        onTap: () => _editUser(user),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          margin: EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isDineIn ? Colors.green.shade100 : Colors.white,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 30,
                  child: Text(serialNumber.toString(), style: TextStyle(fontSize: 12)),
                ),
              ),
              SizedBox(width: 8),
              SizedBox(
                width: 100,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username ?? 'N/A',
                        style: TextStyle(
                          color: isDineIn ? Colors.green.shade700 : Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        _formatTimeAgo(user.createdAt),
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 25),
              SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                      width: 30,
                      child: Text(
                          user.totalUsersCount.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12)))),
              SizedBox(width: 15),
              Checkbox(
                value: user.dineIn,
                onChanged: (value) {
                  if (!_isDisposed) {
                    _toggleDineIn(user.id ?? 0);
                  }
                },
                activeColor: Colors.green.shade700,
              ),
              SizedBox(width: 5),
              IconButton(
                icon: Icon(Icons.call),
                color: Colors.green,
                onPressed: () => _callUser(user.mobileNumber),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                iconSize: 18,
              ),
              IconButton(
                icon: Icon(Icons.delete),
                color: Colors.red,
                onPressed: () async {
                  _deleteUser(user.id ?? 0);
                  final result = await _deleteUserAPI(user.id ?? 0);
                  // Refresh the list after deletion
                  if (_restaurantId != null) {
                    await _fetchAllUsers(_restaurantId);
                  }
                },
                iconSize: 18,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    if (!context.mounted) return;

    final TextEditingController mobileCtrl = TextEditingController();
    final TextEditingController nameCtrl = TextEditingController();
    final TextEditingController personsCtrl = TextEditingController(text: '1');
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    bool _isSearching = false;
    Data5? _existingUser;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            _existingUser != null ? "Edit Person" : "Add New Person",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Mobile Number *",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        TextFormField(
                          controller: mobileCtrl,
                          enabled: _existingUser == null,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          onChanged: (value) async {
                            if (value.length == 10 &&
                                RegExp(r'^[0-9]+$').hasMatch(value)) {
                              setDialogState(() {
                                _isSearching = true;
                              });

                              try {
                                final searchedName = await _searchUserByMobile(value);
                                final existingUserData = _findUserByMobile(value);

                                if (existingUserData != null) {
                                  // User already exists in waiting list
                                  setDialogState(() {
                                    _existingUser = existingUserData;
                                    nameCtrl.text = existingUserData.username ?? '';
                                    personsCtrl.text = existingUserData.totalUsersCount.toString();
                                    _isSearching = false;
                                  });
                                } else if (searchedName != null &&
                                    searchedName.isNotEmpty) {
                                  setDialogState(() {
                                    nameCtrl.text = searchedName;
                                    _isSearching = false;
                                  });
                                } else {
                                  setDialogState(() {
                                    nameCtrl.clear();
                                    _isSearching = false;
                                  });
                                }
                              } catch (e) {
                                // print("Error searching user: $e");
                                setDialogState(() {
                                  nameCtrl.clear();
                                  _isSearching = false;
                                });
                              }
                            } else {
                              setDialogState(() {
                                nameCtrl.clear();
                                _existingUser = null;
                                _isSearching = false;
                              });
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Mobile number is required';
                            }
                            if (value.length != 10) {
                              return 'Mobile number must be exactly 10 digits';
                            }
                            if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                              return 'Mobile number must contain only digits';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: "10-digit number",
                            counterText: "",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.red, width: 1.5),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.red, width: 1.5),
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "Total Persons *",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        TextFormField(
                          controller: personsCtrl,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Total persons is required';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: "Enter total persons",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.red, width: 1.5),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.red, width: 1.5),
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "Person Name *",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Stack(
                          children: [
                            TextFormField(
                              controller: nameCtrl,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Person name is required';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: "Enter person name",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.red, width: 1.5),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.red, width: 1.5),
                                ),
                              ),
                            ),
                            if (_isSearching)
                              Positioned(
                                right: 12,
                                top: 18,
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFFFF6B00),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 25),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  side: BorderSide(color: Color(0xFFFF6B00)),
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                },
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                    color: Color(0xFFFF6B00),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFFF6B00),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: () async {
                                  if (!_formKey.currentState!.validate()) {
                                    return;
                                  }

                                  final name = nameCtrl.text.trim();
                                  final mobile = mobileCtrl.text.trim();
                                  final personsText = personsCtrl.text.trim();
                                  final persons = personsText.isEmpty ? 1 : int.tryParse(personsText) ?? 1;

                                  if (_existingUser != null) {
                                    // Update existing user
                                    final result = await _updateUserAPI(
                                      _existingUser!.id ?? 0,
                                      name,
                                      mobile,
                                      persons,
                                    );

                                    if (result != null) {
                                      if (dialogContext.mounted) {
                                        Navigator.pop(dialogContext);
                                      }
                                      if (_restaurantId != null) {
                                        await _fetchAllUsers(_restaurantId);
                                      }
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('User updated successfully!'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    }
                                  } else {
                                    // Create new user
                                    final result = await _createUserAPI(name, mobile, persons);

                                    if (result != null) {
                                      if (dialogContext.mounted) {
                                        Navigator.pop(dialogContext);
                                      }

                                      if (_restaurantId != null) {
                                        await _fetchAllUsers(_restaurantId);
                                      }

                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('User created successfully!'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                                child: Text(
                                  _existingUser != null ? "Update Person" : "Add Person",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12,),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Data5? _findUserByMobile(String mobile) {
    try {
      return allUsers.firstWhere((user) => user.mobileNumber == mobile);
    } catch (e) {
      return null;
    }
  }

  Future<String?> _searchUserByMobile(String mobile) async {
    if (_authToken == null || mobile.isEmpty) {
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse(
          "https://waitinglist.rektech.work/api/restaurant-users/search/by-phone/$mobile",
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      ).timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['data'] != null) {
          final userData = jsonResponse['data'];
          return userData['username'] ?? null;
        }
      }
    } catch (e) {
      // print("Error searching user: $e");
    }

    return null;
  }

  void _showSubscriptionRequiredDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.workspace_premium, size: 60, color: Color(0xFFFF6B00)),
              SizedBox(height: 16),
              Text(
                'Subscription Required',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                'You need an active subscription to add users to the waiting list. Please purchase a subscription plan to continue.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        side: BorderSide(color: Color(0xFFFF6B00)),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Color(0xFFFF6B00), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFF6B00),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () async {
                        Navigator.pop(dialogContext);
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SubscriptionPlansScreen()),
                        );
                        if (result == true) {
                          _checkSubscription();
                        }
                      },
                      child: Text(
                        'View Plans',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}
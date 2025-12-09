import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import 'package:waiting_list2/Api_Model/Restaurent_users/restaurant_model.dart';
import '../Appbar.dart';
import 'auth_screen.dart';
import '../services/auth_service.dart';
import 'Business_profile_screen.dart';
import 'SubscriptionPlansScreen.dart';
import '../services/razorpay_service.dart';
import '../Api_Model/Setting/subscriptions status.dart';
import '../widgets/main_bottom_nav.dart';
import 'Home_screen.dart';
import 'waiting_list_screen.dart';

class Setting_Screen extends StatefulWidget {
  const Setting_Screen({super.key});

  @override
  State<Setting_Screen> createState() => _Setting_ScreenState();
}

class _Setting_ScreenState extends State<Setting_Screen> {
  final AuthService _auth = AuthService();
  final RazorpayService _razorpayService = RazorpayService();
  bool _isDisposed = false;

  String _userName = "User";
  String _userEmail = "user@example.com";
  String _userInitial = "U";
  String _restaurantName = "No restaurant data available";
  String _profileImage = "";
  String _location = "";
  String _contactNumber = "";
  bool _isLoading = true;
  bool _hasSubscriptionPlans = false;
  SubscriptionsStatusDatum? _activeSubscription;
  bool _isCancelling = false;

  // Helper function to strip HTML tags
  String _stripHtmlTags(String htmlText) {
    try {
      dom.Document document = html_parser.parse(htmlText);
      String parsedString = document.body?.text ?? "";
      return parsedString.trim();
    } catch (e) {
      // print("Error parsing HTML: $e");
      return htmlText;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkSubscriptionPlans();
    _loadActiveSubscription();
  }

  Future<void> _loadUserData() async {
    final sp = await SharedPreferences.getInstance();

    try {
      _userName = sp.getString('user_name') ?? "User";
      _userEmail = sp.getString('user_email') ?? "user@example.com";
      _userInitial = _userName.isNotEmpty ? _userName[0].toUpperCase() : "U";

      // Fetch restaurant data from API
      await _fetchRestaurantData();
    } catch (e) {
      // print("Error loading user data: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchRestaurantData() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final authToken = sp.getString('auth_token');

      if (authToken == null || authToken.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse("https://waitinglist.rektech.work/api/restaurants/my-restaurant"),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (_isDisposed) return;

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['success'] == true && jsonData['data'] != null) {
          final data = jsonData['data'];

          setState(() {
            _restaurantName = data['name'] ?? "No restaurant data available";
            _profileImage = data['profile'] ?? "";
            _location = data['location'] ?? "";
            _contactNumber = data['contact_number'] ?? "";
            _isLoading = false;

            // Save to SharedPreferences for offline access
            sp.setString('restaurant_name', _restaurantName);
            sp.setString('profile_image', _profileImage);
            // print("profile_image${_profileImage}");
            sp.setString('restaurant_location', _location);
            sp.setString('restaurant_contact', _contactNumber);
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        // Fallback to SharedPreferences if API fails
        setState(() {
          _restaurantName = sp.getString('restaurant_name') ?? "No restaurant data available";
          _profileImage = sp.getString('profile_image') ?? "";
          _location = sp.getString('restaurant_location') ?? "";
          _contactNumber = sp.getString('restaurant_contact') ?? "";
          _isLoading = false;
        });
      }
    } catch (e) {
      // print("Error fetching restaurant data: $e");
      final sp = await SharedPreferences.getInstance();
      setState(() {
        _restaurantName = sp.getString('restaurant_name') ?? "No restaurant data available";
        _profileImage = sp.getString('profile_image') ?? "";
        _location = sp.getString('restaurant_location') ?? "";
        _contactNumber = sp.getString('restaurant_contact') ?? "";
        _isLoading = false;
      });
    }
  }

  // Check subscription plans availability
  Future<void> _checkSubscriptionPlans() async {
    try {
      final response = await http.get(
        Uri.parse("https://waitinglist.rektech.work/api/subscription-plans"),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final data = jsonData['data'];
          if (data is List && data.isNotEmpty) {
            setState(() {
              _hasSubscriptionPlans = true;
            });
          } else {
            setState(() {
              _hasSubscriptionPlans = false;
            });
          }
        } else {
          setState(() {
            _hasSubscriptionPlans = false;
          });
        }
      } else {
        setState(() {
          _hasSubscriptionPlans = false;
        });
      }
    } catch (e) {
      // print("Error checking subscription plans: $e");
      setState(() {
        _hasSubscriptionPlans = false;
      });
    }
  }

  // Load active subscription
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

  int _getRemainingDays() {
    if (_activeSubscription == null) return 0;
    try {
      final endDate = _activeSubscription!.expiresAt;
      final now = DateTime.now();
      return endDate.difference(now).inDays;
    } catch (e) {
      return 0;
    }
  }

  Future<void> _handleCancelSubscription() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Subscription?'),
        content: Text(
          'Are you sure you want to cancel your subscription? You will lose access to premium features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('No, Keep It'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Yes, Cancel',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isCancelling = true;
    });

    final result = await _razorpayService.cancelSubscription();

    if (mounted) {
      setState(() {
        _isCancelling = false;
      });

      if (result != null && result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.green,
          ),
        );
        // Reload subscription data
        await _loadActiveSubscription();
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel subscription'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Fetch Privacy Policy data
  Future<void> _fetchPrivacyPolicy() async {
    try {
      final response = await http.get(
        Uri.parse("https://waitinglist.rektech.work/api/pages/privacy-policy"),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final data = jsonData['data'];
          String cleanContent = _stripHtmlTags(data['content'] ?? "No content available");
          _showContentPopup(data['title'] ?? "Privacy Policy", cleanContent);
        } else {
          _showErrorPopup("Error", "Failed to load privacy policy");
        }
      } else {
        _showErrorPopup("Error", "Failed to load privacy policy");
      }
    } catch (e) {
      // print("Error fetching privacy policy: $e");
      _showErrorPopup("Error", "Error: $e");
    }
  }

  // Fetch Terms of Service data
  Future<void> _fetchTermsOfService() async {
    try {
      final response = await http.get(
        Uri.parse("https://waitinglist.rektech.work/api/pages/terms-of-service"),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final data = jsonData['data'];
          String cleanContent = _stripHtmlTags(data['content'] ?? "No content available");
          _showContentPopup(data['title'] ?? "Terms of Service", cleanContent);
        } else {
          _showErrorPopup("Error", "Failed to load terms of service");
        }
      } else {
        _showErrorPopup("Error", "Failed to load terms of service");
      }
    } catch (e) {
      // print("Error fetching terms of service: $e");
      _showErrorPopup("Error", "Error: $e");
    }
  }

  // Fetch About Us data
  Future<void> _fetchAboutUs() async {
    try {
      final response = await http.get(
        Uri.parse("https://waitinglist.rektech.work/api/pages/about-us"),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final data = jsonData['data'];
          String cleanContent = _stripHtmlTags(data['content'] ?? "No content available");
          _showContentPopup(data['title'] ?? "About Us", cleanContent);
        } else {
          _showErrorPopup("Error", "Failed to load about us");
        }
      } else {
        _showErrorPopup("Error", "Failed to load about us");
      }
    } catch (e) {
      // print("Error fetching about us: $e");
      _showErrorPopup("Error", "Error: $e");
    }
  }

  // Show content in popup dialog
  void _showContentPopup(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.95,
              maxWidth: MediaQuery.of(context).size.width * 0.95,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B00),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      content,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
                // Close button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B00),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        "Close",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Show error popup
  void _showErrorPopup(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B00),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "OK",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    if (!mounted) return;
    final sp = await SharedPreferences.getInstance();
    await sp.remove('user_pin');
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => AuthScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadUserData();
        await _checkSubscriptionPlans();
        await _loadActiveSubscription();
        setState(() {}); // Force UI refresh
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: DynamicAppBar(),
        body: _isLoading
            ? Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFF6B00),
          ),
        )
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ------------ PROFILE TITLE ------------
              const Text(
                "Profile",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              
              // ------------ PROFILE CARD ------------
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.20),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _profileImage.isEmpty
                              ? Image.asset(
                            "assets/Images/app_logo.png",
                            height: 80,
                            width: 80,
                            fit: BoxFit.fill,
                          )
                              : Image.network(
                            "https://waitinglist.rektech.work/storage/${_profileImage}",
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) {
                              return Image.asset(
                                "assets/Images/app_logo.png",
                                height: 70,
                                width: 70,
                                fit: BoxFit.cover,
                              );
                            },
                            loadingBuilder:
                                (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return Container(
                                height: 70,
                                width: 70,
                                color: Colors.grey.shade200,
                                child: Center(
                                  child:
                                  CircularProgressIndicator(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                _userName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 6),
                              // Text(
                              //   _userEmail,
                              //   style: TextStyle(
                              //     fontSize: 14,
                              //     color: Colors.black54,
                              //   ),
                              //   maxLines: 1,
                              //   overflow: TextOverflow.ellipsis,
                              // ),
                              // SizedBox(height: 6),
                              Text(
                                _restaurantName,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black45,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (_contactNumber.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Text(
                                    _contactNumber,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black45,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              /*if (_location.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Row(
                                    children: [
                                      Icon(Icons.location_on,
                                          size: 12,
                                          color: Colors.red),
                                      SizedBox(width: 2),
                                      Expanded(
                                        child: Text(
                                          _location,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black45,
                                          ),
                                          maxLines: 1,
                                          overflow:
                                          TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),*/
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(
                        thickness: 1, color: Color(0xFFE5E7EB)),
                    // const SizedBox(height: ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (!_isDisposed) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      Business_profile_screen(),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            "Edit Profile",
                            style: TextStyle(
                              color: Color(0xFFFF6B00),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ------------ SUBSCRIPTION TITLE ------------
              if (_hasSubscriptionPlans)
                const Text(
                  "Subscription",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              if (_hasSubscriptionPlans)
                const SizedBox(height: 8),

              // ------------ SUBSCRIPTION CARD ------------
              if (_hasSubscriptionPlans)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.20),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _activeSubscription != null && _activeSubscription!.status.toLowerCase() == 'active'
                            ? _activeSubscription!.planSnapshot.name
                            : "No Active Subscription",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        _activeSubscription != null && _activeSubscription!.status.toLowerCase() == 'active'
                            ? "${_getRemainingDays()} days remaining"
                            : "Subscribe to unlock premium features",
                        style: TextStyle(
                          fontSize: 13,
                          color: _activeSubscription != null && _getRemainingDays() <= 7
                              ? Colors.red
                              : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Divider(
                          thickness: 1, color: Color(0xFFE5E7EB)),
                      const SizedBox(height: 2),
                      // Only show subscription management when subscription is NOT active
                      if (_activeSubscription == null || _activeSubscription!.status.toLowerCase() != 'active')
                        GestureDetector(
                          onTap: () {
                            if (!_isDisposed) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SubscriptionPlansScreen(),
                                ),
                              ).then((_) => _loadActiveSubscription());
                            }
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "View Subscription Plans",
                                style: TextStyle(
                                  color: Color(0xFFFF6B00),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "Choose a plan to unlock premium features",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Spacer(),
                            // Refresh button
                            // IconButton(
                            //   icon: Icon(Icons.refresh, color: Color(0xFFFF6B00)),
                            //   onPressed: () async {
                            //     await _loadActiveSubscription();
                            //     setState(() {});
                            //   },
                            // ),
                            
                            // Cancel subscription button
                            if (!_isCancelling)
                              OutlinedButton(
                                onPressed: _handleCancelSubscription,
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  side: BorderSide(color: Colors.red),
                                ),
                                child: Text(
                                  'Cancel Plan',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            else
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.red,
                                  strokeWidth: 2,
                                ),
                              ),
                            Spacer(),
                          ],
                        ),

                    ],
                  ),
                ),

              if (_hasSubscriptionPlans)
                const SizedBox(height: 25),

              // ------------ ABOUT TITLE ------------
              const Text(
                "About",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              // ------------ ABOUT CARD ------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.20),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: _fetchPrivacyPolicy,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Privacy Policy",
                              style:
                              TextStyle(fontWeight: FontWeight.w600,fontSize: 15)),
                          const Text("View our privacy policy",
                              style: TextStyle(color: Colors.black54,fontSize: 13)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Divider(
                        thickness: 1, color: Color(0xFFE5E7EB)),
                    const SizedBox(height: 2),
                    InkWell(
                      onTap: _fetchTermsOfService,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Terms of Service",
                              style:
                              TextStyle(fontWeight: FontWeight.w600,fontSize: 15)),

                          const Text("View terms and conditions",
                              style: TextStyle(color: Colors.black54,fontSize: 13)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Divider(
                        thickness: 1, color: Color(0xFFE5E7EB)),
                    const SizedBox(height: 2),
                    InkWell(
                      onTap: _fetchAboutUs,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("About-us",
                              style:
                              TextStyle(fontWeight: FontWeight.w600,fontSize: 15)),
                          // const SizedBox(height: 2),
                          const Text("View about us",
                              style: TextStyle(color: Colors.black54,fontSize: 13)),
                        ],
                      ),
                    ),

                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ------------ FOOTER TEXT ------------
              Center(
                child: Column(
                  children: const [
                    Text("Restaurant User Management App",
                        style: TextStyle(
                            fontSize: 13, color: Colors.black54)),
                    SizedBox(height: 4),
                    Text(
                        "Made with ❤️ for restaurant management",
                        style: TextStyle(
                            fontSize: 13, color: Colors.black45)),
                  ],
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
            // print('showHomePage value in SettingScreen: $showHomePage'); // Print show home page value
            
            return
              showHomePage ==0 ?
              MainBottomNavBar(
              currentIndex: showHomePage == 1 ? 2 : 1, // Highlight settings as current screen
              isLoggedIn: true, // User is logged in when on this screen
              showHomePage: showHomePage, // Pass the show home page flag
              onHomeTap: showHomePage == 1 ? () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => HomeScreen(refreshKey: UniqueKey(), showHomePage: showHomePage)),
                );
              } : null,
              onWaitingTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => WaitingListScreen()),
                );
              },
              onSettingsTap: () {
                // Already on settings screen, do nothing
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
}
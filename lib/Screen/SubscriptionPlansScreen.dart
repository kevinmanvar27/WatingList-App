import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/razorpay_service.dart';
import 'ActiveSubscriptionScreen.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../Api_Model/Setting/subscriptions status.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  State<SubscriptionPlansScreen> createState() => _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  List<dynamic> subscriptionPlans = [];
  bool _isLoading = true;
  late RazorpayService _razorpayService;
  int? _selectedPlanId;
  bool _isProcessingPayment = false;
  SubscriptionsStatusDatum? _activeSubscription;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _razorpayService = RazorpayService();
    _initializeRazorpay();
    _fetchSubscriptionPlans();
    _loadActiveSubscription();
  }
  
  // Separate method to initialize Razorpay service asynchronously
  Future<void> _initializeRazorpay() async {
    _razorpayService.initialize(
      onPaymentSuccess: _handlePaymentSuccess,
      onPaymentFailure: _handlePaymentFailure,
    );
  }

  Future<void> _fetchSubscriptionPlans() async {
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
          setState(() {
            subscriptionPlans = jsonData['data'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      // print("Error fetching subscription plans: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleBuyNow(Map<String, dynamic> plan) async {
    if (_isProcessingPayment) return;

    // Check if user has an active subscription
    if (_activeSubscription != null && _activeSubscription!.status.toLowerCase() == 'active') {
      // Show confirmation dialog based on plan selection
      final shouldProceed = await _showPlanChangeDialog(plan);
      if (!shouldProceed) return;
    }

    final sp = await SharedPreferences.getInstance();
    final userName = sp.getString('user_name') ?? 'User';
    final userEmail = sp.getString('user_email') ?? '';

    if (userEmail.isEmpty) {
      _showMessage('Please login to purchase a subscription', isError: true);
      return;
    }

    setState(() {
      _selectedPlanId = plan['id'];
      _isProcessingPayment = true;
    });

    try {
      // Open Razorpay checkout directly
      await _razorpayService.openCheckout(
        planId: plan['id'],
        planName: plan['name'] ?? 'Subscription Plan',
        amount: double.parse(plan['price'].toString()),
        userName: userName,
        userEmail: userEmail,
        userMobile: '0000000000', // You can add mobile to user data
      );
    } catch (e) {
      // print('Error opening payment: $e');
      setState(() {
        _isProcessingPayment = false;
        _selectedPlanId = null;
      });
      _showMessage('Failed to open payment gateway', isError: true);
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (_selectedPlanId == null) return;

    // Call purchase API with payment details
    final purchase = await _razorpayService.purchaseSubscription(
      paymentResponse: response,
    );

    setState(() {
      _isProcessingPayment = false;
      _selectedPlanId = null;
    });

    if (purchase != null && purchase.success) {
      _showMessage('Subscription activated successfully!', isError: false);
      // Navigate to Active Subscription screen to show current plan
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ActiveSubscriptionScreen()),
        );
      }
    } else {
      _showMessage('Payment successful but activation failed. Contact support.', isError: true);
    }
  }

  void _handlePaymentFailure(String error) {
    setState(() {
      _isProcessingPayment = false;
      _selectedPlanId = null;
    });

    _showMessage(error, isError: true);
  }

  Future<bool> _showPlanChangeDialog(Map<String, dynamic> selectedPlan) async {
    // Check if it's the same plan
    if (_activeSubscription != null &&
        _activeSubscription!.subscriptionPlan.id == selectedPlan['id']) {
      // Same plan - show renewal dialog
      return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Renew Subscription?'),
          content: Text(
              'You are about to renew your "${selectedPlan['name']}" subscription. '
                  'This will extend your current subscription period. Do you want to proceed?'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Renew',
                style: TextStyle(color: Color(0xFFFF6B00)),
              ),
            ),
          ],
        ),
      ) ?? false;
    } else {
      // Different plan - show upgrade/downgrade dialog
      return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Change Subscription Plan?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'You currently have an active "${_activeSubscription!.planSnapshot.name}" subscription. '
                      'Changing to "${selectedPlan['name']}" will replace your current plan.'
              ),
              SizedBox(height: 16),
              Text(
                'Do you want to proceed with this change?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Change Plan',
                style: TextStyle(color: Color(0xFFFF6B00)),
              ),
            ),
          ],
        ),
      ) ?? false;
    }
  }

  void _showMessage(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
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
        _showMessage(result.message, isError: false);
        // Reload subscription data
        _loadActiveSubscription();
      } else {
        _showMessage('Failed to cancel subscription', isError: true);
      }
    }
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Subscription Plans",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),

      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFF6B00),
        ),
      )
          : Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                const SizedBox(height: 10),

                const Text(
                  "Choose Your Plan",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 6),

                const Text(
                  "Unlock premium features like Person Count\nManagement and Waiting List",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 28),

                // ===================== DYNAMIC PLAN CARDS =====================
                subscriptionPlans.isEmpty
                    ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Text(
                    "No subscription plans available",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                )
                    : Column(
                  children: List.generate(
                    subscriptionPlans.length,
                        (index) {
                      final plan = subscriptionPlans[index];
                      final planName = plan['name'] ?? 'Plan ${index + 1}';
                      final planPrice = plan['price'] ?? '0';
                      final durationDays = plan['duration_days'] ?? 30;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    planName,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    "₹$planPrice",
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFF6B00),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              Text(
                                "$durationDays Days",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),

                              const SizedBox(height: 20),

                              SizedBox(
                                width: double.infinity,
                                child: _activeSubscription != null &&
                                    _activeSubscription!.status.toLowerCase() == 'active' &&
                                    _activeSubscription!.subscriptionPlan.id == plan['id']
                                    ? OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Colors.red, width: 2),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  onPressed: _isCancelling ? null : _handleCancelSubscription,
                                  child: _isCancelling
                                      ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.red,
                                      strokeWidth: 2,
                                    ),
                                  )
                                      : Text(
                                    "Cancel Plan",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                                    : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF6B00),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: _isProcessingPayment
                                      ? null
                                      : () => _handleBuyNow(plan),
                                  child: _isProcessingPayment && _selectedPlanId == plan['id']
                                      ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                      : Text(
                                    _activeSubscription != null &&
                                        _activeSubscription!.status.toLowerCase() == 'active' &&
                                        _activeSubscription!.subscriptionPlan.id != plan['id']
                                        ? "Change Plan"
                                        : "Buy Now",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import '../Api_Model/Setting/purchase.dart';
import '../Api_Model/Setting/subscriptions status.dart';
import '../Api_Model/Setting/Ordercancel.dart';

class RazorpayService {
  late Razorpay _razorpay;
  Function(PaymentSuccessResponse)? onSuccess;
  Function(String)? onFailure;
  int? _currentPlanId;
  double? _currentAmount;
  
  // Variable to store the fetched Razorpay Key ID
  String? _razorpayKeyId;
  
  // Default Razorpay Key ID (fallback)
  static const String defaultRazorpayKeyId = 'rzp_test_Go3jN8rdNmRJ7P';
  static const String baseUrl = 'https://waitinglist.rektech.work/api';

  // Getter for Razorpay Key ID (uses fetched key or default)
  String get razorpayKeyId => _razorpayKeyId ?? defaultRazorpayKeyId;
  
  // Method to fetch Razorpay key from API
  Future<void> fetchRazorpayKey() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/settings/razorpay-keys'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Assuming the response has a 'key' field with the Razorpay key
        _razorpayKeyId = data['key'] ?? data['razorpay_key'] ?? defaultRazorpayKeyId;
        developer.log('Fetched Razorpay Key: $_razorpayKeyId', name: 'RazorpayService');
      } else {
        developer.log('Failed to fetch Razorpay key. Status: ${response.statusCode}', 
          name: 'RazorpayService.fetchRazorpayKey');
        _razorpayKeyId = defaultRazorpayKeyId;
      }
    } catch (e) {
      developer.log('Exception fetching Razorpay key: $e', 
        name: 'RazorpayService.fetchRazorpayKey', error: e);
      _razorpayKeyId = defaultRazorpayKeyId;
    }
  }

  void initialize({
    required Function(PaymentSuccessResponse) onPaymentSuccess,
    required Function(String) onPaymentFailure,
  }) async {
    _razorpay = Razorpay();
    onSuccess = onPaymentSuccess;
    onFailure = onPaymentFailure;

    // Fetch Razorpay key from API
    await fetchRazorpayKey();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    developer.log('Payment Success: ${response.paymentId}', name: 'RazorpayService');
    if (onSuccess != null) {
      onSuccess!(response);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    developer.log('Payment Error: ${response.code} - ${response.message}', name: 'RazorpayService');
    if (onFailure != null) {
      onFailure!(response.message ?? 'Payment failed');
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    developer.log('External Wallet: ${response.walletName}', name: 'RazorpayService');
  }

  Future<void> openCheckout({
    required int planId,
    required String planName,
    required double amount,
    required String userName,
    required String userEmail,
    required String userMobile,
  }) async {
    // Store plan details for later use in purchase API
    _currentPlanId = planId;
    _currentAmount = amount;

    var options = {
      'key': razorpayKeyId, // Use the getter which returns fetched or default key
      'amount': (amount * 100).toInt(), // Amount in paise
      'name': 'Waiting List Subscription',
      'description': planName,
      'prefill': {
        'contact': userMobile,
        'email': userEmail,
        'name': userName,
      },
      'theme': {
        'color': '#FF6B00'
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      developer.log('Error opening Razorpay: $e', name: 'RazorpayService', error: e);
      if (onFailure != null) {
        onFailure!('Failed to open payment gateway');
      }
    }
  }

  Future<Purchase?> purchaseSubscription({
    required PaymentSuccessResponse paymentResponse,
  }) async {
    try {
      final sp = await SharedPreferences.getInstance();
      final token = sp.getString('auth_token');

      if (token == null || _currentPlanId == null || _currentAmount == null) {
        developer.log('Missing required data for purchase', name: 'RazorpayService.purchaseSubscription');
        return null;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/subscriptions/purchase'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'subscription_plan_id': _currentPlanId,
          'payment_method': 'razorpay',
          'transaction_id': paymentResponse.paymentId,
          'payment_details': {
            'razorpay_payment_id': paymentResponse.paymentId,
            'razorpay_order_id': paymentResponse.orderId ?? '',
            'razorpay_signature': paymentResponse.signature ?? '',
            'amount_paid': (_currentAmount! * 100).toInt(),
            'currency': 'INR',
          }
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final purchase = Purchase.fromJson(data);
        
        if (purchase.success) {
          developer.log('Subscription purchased successfully', name: 'RazorpayService');
          return purchase;
        }
      }
      
      developer.log('Failed to purchase subscription. Status: ${response.statusCode}', 
        name: 'RazorpayService.purchaseSubscription');
      return null;
    } catch (e) {
      developer.log('Exception in purchaseSubscription: $e', 
        name: 'RazorpayService', error: e);
      return null;
    }
  }

  Future<SubscriptionsStatusDatum?> getActiveSubscription() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final token = sp.getString('auth_token');

      if (token == null) {
        developer.log('No auth token found', name: 'RazorpayService.getActiveSubscription');
        return null;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/subscriptions'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final subscriptionsStatus = SubscriptionsStatus.fromJson(data);

        if (subscriptionsStatus.success && subscriptionsStatus.data.isNotEmpty) {
          // Find active subscription
          final active = subscriptionsStatus.data.firstWhere(
            (sub) => sub.status.toLowerCase() == 'active',
            orElse: () => subscriptionsStatus.data.first,
          );
          return active;
        }
      }
      
      return null;
    } catch (e) {
      developer.log('Exception in getActiveSubscription: $e', 
        name: 'RazorpayService', error: e);
      return null;
    }
  }

  Future<bool> hasActiveSubscription() async {
    final subscription = await getActiveSubscription();
    return subscription != null && subscription.status.toLowerCase() == 'active';
  }

  Future<Ordercancel?> cancelSubscription() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final token = sp.getString('auth_token');

      if (token == null) {
        developer.log('No auth token found', name: 'RazorpayService.cancelSubscription');
        return null;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/subscriptions/cancel'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final cancelResult = Ordercancel.fromJson(data);
        
        if (cancelResult.success) {
          developer.log('Subscription cancelled successfully', name: 'RazorpayService');
          return cancelResult;
        }
      }
      
      developer.log('Failed to cancel subscription. Status: ${response.statusCode}', 
        name: 'RazorpayService.cancelSubscription');
      return null;
    } catch (e) {
      developer.log('Exception in cancelSubscription: $e', 
        name: 'RazorpayService', error: e);
      return null;
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}

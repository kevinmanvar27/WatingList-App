import 'dart:convert';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waiting_list/Screen/waiting_list_screen.dart';
import '../Api_Model/restaurant_user_model.dart';
import '../services/add_person_service.dart';
import '../services/subscription_service.dart';
import 'Business_profile_screen.dart';
import '../services/auth_service.dart';

class Setting_Screen extends StatefulWidget {
  const Setting_Screen({super.key});

  @override
  State<Setting_Screen> createState() => _Setting_ScreenState();
}

class _Setting_ScreenState extends State<Setting_Screen> {

  final GlobalKey<WaitingListScreenState> waitingListKey = GlobalKey<WaitingListScreenState>();

  late Razorpay _razorpay;

  List<RestaurantUser> users = [];

  void loadUsers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("SAVED TOKEN: ${prefs.getString("token")}");
    users = await ApiService.fetchUsers();
    setState(() {});
  }

  final AuthService _auth = AuthService();
  final SubscriptionService _subscriptionService = SubscriptionService();
  List<dynamic> _plans = [];
  bool _loading = true;
  bool _hasActiveSubscription = true;

  @override
  void initState() {
    super.initState();
    fetchPlans();
    loadUsers();

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> fetchPlans() async {
    try {
      final data = await _subscriptionService.getPlans();
      setState(() {
        _plans = data;
        _hasActiveSubscription = _plans.isNotEmpty;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _hasActiveSubscription = false;
      });
      print("Error fetching plans: $e");
    }
  }

  Future<void> _showTermsDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await http.get(
        Uri.parse("https://waitinglist.rektech.work/api/pages/terms-of-service"),
      );

      Navigator.pop(context);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data["data"]["content"] ?? "";

        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => Dialog(
            backgroundColor: Colors.white,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  /// TITLE + CLOSE BUTTON (Same as Privacy)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Terms of Service",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF6B00),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// CONTENT SCROLL (Same as Privacy)
                  Expanded(
                    child: SingleChildScrollView(
                      child: HtmlWidget(
                        content,
                        textStyle: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading Terms: $e")),
      );
    }
  }

  Future<void> _showPrivacyPolicyDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await http.get(
        Uri.parse("https://waitinglist.rektech.work/api/pages/privacy-policy"),
      );

      Navigator.pop(context);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data["data"]["content"] ?? "";

        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => Dialog(
            backgroundColor: Colors.white,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  /// TOP TITLE + CLOSE BUTTON
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Privacy Policy",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Color(0xFFFF6B00),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// CONTENT SCROLL AREA
                  Expanded(
                    child: SingleChildScrollView(
                      child: HtmlWidget(
                        content,
                        textStyle: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading Privacy Policy: $e")),
      );
    }
  }

  void openCheckout(int amount, String planName) {
    var options = {
      'key': 'rzp_test_Go3jN8rdNmRJ7P',
      'amount': amount * 100,
      'name': planName,
      'description': 'Subscription Payment',
      'prefill': {
        'contact': '9316842475',
        'email': 'rohit.rektech@gmail.com',
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print(e.toString());
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Successful ✅")),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed ❌")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("External Wallet: ${response.walletName}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Row(
          children: [
            Image.asset("assets/Images/re2.png", height: 40),
            const SizedBox(width: 30),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF6F00),
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: const Size(0, 32),
                elevation: 0,
              ),
              child: const Text(
                "Add Person",
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              onPressed: () {
                _showAddUserDialog(context);
              },
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text("Profile",
              style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600,color: Colors.black87),
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.20),
                    blurRadius: 10, spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Color(0xFFFF6B00),
                        child: const Text("K", style: TextStyle(color: Colors.white, fontSize: 20)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text("Kevinmanvar27",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
                            SizedBox(height: 6),
                            Text("kevinmanvar27@gmail.com",style: TextStyle(fontSize: 14,color: Colors.black54)),
                            SizedBox(height: 6),
                            Text("No restaurant data available",style: TextStyle(fontSize: 13,color: Colors.black45)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),
                  const Divider(thickness: 1, color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 10),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>Business_profile_screen()));
                    },
                    child: const Text(
                      "Update Resturant",
                      style: TextStyle(
                        color: Color(0xFFFF6B00),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            _hasActiveSubscription
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Subscription",
                  style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600,color: Colors.black87),
                ),
                const SizedBox(height: 8),

                _loading
                    ? Center(child: CircularProgressIndicator())
                    : Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.20),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text("Available Plans",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w600)),
                      SizedBox(height: 12),

                      ..._plans.map((plan) =>
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300, width: 1),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("${plan['name']}",style: const TextStyle(fontSize: 15,fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text("${plan['duration_days']} Days",style: const TextStyle(fontSize: 13,color: Colors.black54)),
                                  ],
                                ),

                                Text("₹ ${plan['price']}",style: const TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),

                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF6B00),
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: () {
                                    openCheckout(
                                      double.parse(plan['price'].toString()).round(), // ✅ Fix applied here
                                      plan['name'],
                                    );
                                  },
                                  child: const Text(
                                    "Buy Now",
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),



                              ],
                            ),
                          )
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
              ],
            )
                : SizedBox.shrink(),

            const Text("About",
              style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600,color: Colors.black87),
            ),
            const SizedBox(height: 8),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
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

                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    title: const Text("Version", style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text("1.0.0", style: TextStyle(color: Colors.black54)),
                  ),

                  const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),

                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    title: const Text("Privacy Policy", style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text("View our privacy policy",style: TextStyle(color: Colors.black54)),
                    onTap: () {
                      _showPrivacyPolicyDialog();
                    },
                  ),

                  const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),

                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    title: const Text("Terms of Service", style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text("View terms and conditions",style: TextStyle(color: Colors.black54)),
                    onTap: () {
                      _showTermsDialog();
                    },
                  ),

                ],
              ),
            ),

            const SizedBox(height: 40),

            Center(
              child: Column(
                children: const [
                  Text("Restaurant User Management App",style: TextStyle(fontSize: 13,color: Colors.black54)),
                  SizedBox(height: 4),
                  Text("Made with ❤️ for restaurant management",style: TextStyle(fontSize: 13,color: Colors.black45)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _showAddUserDialog(BuildContext context,) {
    final TextEditingController mobileCtrl = TextEditingController();
    final TextEditingController nameCtrl = TextEditingController();
    final TextEditingController personsCtrl = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Center(
                  child: Text(
                    "Add New Person",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(height: 20),

                Text("Mobile Number *",style: TextStyle(fontWeight: FontWeight.bold),),
                SizedBox(height: 5),
                TextField(
                  controller: mobileCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: "Enter mobile number",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                SizedBox(height: 12),

                Text("Total Persons",style: TextStyle(fontWeight: FontWeight.bold),),
                SizedBox(height: 5),
                TextField(
                  controller: personsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Enter total persons (optional)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                SizedBox(height: 12),

                Text("Person Name *",style: TextStyle(fontWeight: FontWeight.bold),),
                SizedBox(height: 5),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    hintText: "Enter person name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          side: BorderSide(color: Color(0xFFFF6B00)),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text("Cancel", style: TextStyle(color: Color(0xFFFF6B00),fontWeight: FontWeight.bold)),
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
                          if (nameCtrl.text.isEmpty || mobileCtrl.text.isEmpty) return;

                          await ApiService.addRestaurantUser(
                            nameCtrl.text,
                            mobileCtrl.text,
                            personsCtrl.text.isEmpty ? "1" : personsCtrl.text,
                          );

                          Navigator.pop(context);
                          waitingListKey.currentState?.refreshUsers();
                        },

                        child: Text("Add Person", style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),
        );
      },
    );
  }
}




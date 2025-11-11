import 'dart:convert';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Api_Model/restaurant_user_model.dart';
import '../services/add_person_service.dart';
import '../services/subscription_service.dart';
import 'Business_profile_screen.dart';
import '../services/auth_service.dart';

class Setting_Screen extends StatefulWidget {
  final VoidCallback onRefreshWaitingList;
  final bool isVisible;
  const Setting_Screen({super.key, required this.onRefreshWaitingList, this.isVisible = false});

  @override
  State<Setting_Screen> createState() => _Setting_ScreenState();
}

class _Setting_ScreenState extends State<Setting_Screen> {

  late Razorpay _razorpay;

  List<RestaurantUser> users = [];

  void loadUsers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    users = await ApiService.fetchUsers();
    setState(() {});
  }

  final AuthService _auth = AuthService();
  final SubscriptionService _subscriptionService = SubscriptionService();
  List<dynamic> _plans = [];
  bool _loading = true;
  bool _hasActiveSubscription = true;
  bool isRestaurantOpen = false;

  String userName = "";
  String userEmail = "";
  String profileImage = "";
  String restaurantName = "No restaurant data available";
  @override
  void initState() {
    super.initState();
    fetchPlans();
    loadUsers();
    loadProfile();
    loadRestaurant();
    loadRestaurantStatus();

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void didUpdateWidget(Setting_Screen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ✅ Refresh status when screen becomes visible
    if (widget.isVisible && !oldWidget.isVisible) {
      loadRestaurantStatus();
      loadProfile(); // ✅ Reload profile to get updated owner name
    }
  }

  void refreshUsers() {
    loadUsers();
  }

  // ✅ Add method to refresh restaurant status from parent
  void refreshRestaurantStatus() {
    loadRestaurantStatus();
  }

  void loadRestaurantStatus() async {
    // ✅ Load from SharedPreferences first (real-time update)
    final prefs = await SharedPreferences.getInstance();
    final savedStatus = prefs.getBool("restaurant_open_status");
    
    if (savedStatus != null) {
      setState(() {
        isRestaurantOpen = savedStatus;
      });
    } else {
      // ✅ Fallback: Load from API if not in SharedPreferences
      final data = await AuthService.fetchRestaurantDetail();
      setState(() {
        isRestaurantOpen = data["operational_status"] == "true";
      });
      // Save to SharedPreferences for next time
      prefs.setBool("restaurant_open_status", isRestaurantOpen);
    }
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
    }
  }

  Future<void> loadRestaurant() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    final response = await http.get(
      Uri.parse("https://waitinglist.rektech.work/api/restaurants/my-restaurant"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)["data"];

      // ✅ Convert profile to full URL
      final imagePath = data["profile"];
      final fullUrl = imagePath != null && imagePath.toString().trim().isNotEmpty
          ? "https://waitinglist.rektech.work/storage/$imagePath"
          : "";

      setState(() {
        restaurantName = data["name"] ?? "";
        profileImage = fullUrl;          // ✅ Store it in state
      });

      // ✅ Save locally (optional, useful after app restart)
      prefs.setString("profile_image", fullUrl);
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
      // Error opening Razorpay
    }
  }

  void loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString("user_name") ?? "No Name";
      userEmail = prefs.getString("user_email") ?? "No Email";
      profileImage = prefs.getString("profile_image") ?? "";
    });
  }


  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Successful ✅")),
    );

    /*SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    // ✅ Receive currently selected plan price and duration from last Buy Now click
    final selectedPlan = prefs.getString("selected_plan_id") ?? "";
    final selectedAmount = prefs.getString("selected_plan_amount") ?? "";

    if (selectedPlan.isEmpty || selectedAmount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Plan info missing ❗ Try again")),
      );
      return;
    }

    final url = Uri.parse(
        "https://waitinglist.rektech.work/api/subscriptions/purchase?"
            "subscription_plan_id=$selectedPlan&payment_method=razorpay&"
            "transaction_id=${response.orderId}&"
            "razorpay_payment_id=${response.paymentId}&"
            "razorpay_order_id=${response.orderId}&"
            "razorpay_signature=${response.signature}&"
            "amount_paid=$selectedAmount&currency=INR"
    );

    final res = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Subscription Activated ✅")),
      );

      /// ✅ Refresh UI (reload plans/status)
      fetchPlans();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Activation Failed ❌")),
      );
    }*/
  }


  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed ❌")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // External wallet selected
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
              onPressed: () async {
                // ✅ FIXED LOGIC START: Check if the restaurant is CLOSED
                if (!isRestaurantOpen) {
                  bool? proceed = await showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.info_outline, color: Color(0xFFFF6F00), size: 40),
                            SizedBox(height: 10),
                            Text("Restaurant Closed",
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            SizedBox(height: 10),
                            Text(
                              "Your restaurant is currently closed.\nDo you still want to add a person?",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 15),
                            ),
                            SizedBox(height: 25),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: Text("Cancel")),
                                SizedBox(width: 10),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFF6F00)),
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text("Continue", style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );

                  if (proceed != true) return; // ❌ User cancels -> Stop
                }

                // ✅ FIXED LOGIC END: Only show the Add Person dialog if open OR user continues
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
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: profileImage.isNotEmpty ? NetworkImage(profileImage) : null,
                        child: profileImage.isEmpty
                            ? Icon(Icons.store, color: Color(0xFFFF6B00), size: 28)
                            : null,
                      ),

                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${restaurantName.isEmpty ? "No resturant data avialable" : restaurantName}",
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),

                            SizedBox(height: 6),

                            // User Name
                            Text(
                              userName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),

                            SizedBox(height: 6),

                            // Email (Faded color)
                            Text(
                              userEmail,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),

                    ],
                  ),

                  const SizedBox(height: 10),
                  const Divider(thickness: 1, color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 10),

                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (context)=>Business_profile_screen()));
                      // ✅ Reload profile after returning from Business Profile screen
                      loadProfile();
                      loadRestaurant();
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
                                  onPressed: () async {////
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    prefs.setString("selected_plan_id", plan['id'].toString());
                                    prefs.setString("selected_plan_amount", plan['price'].toString());

                                    openCheckout(
                                      double.parse(plan['price'].toString()).round(), // ✅ amount
                                      plan['name'],                                   // ✅ plan name
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
  void _showAddUserDialog(BuildContext context, {RestaurantUser? user}) {
    final _formKey = GlobalKey<FormState>();

    final TextEditingController mobileCtrl =
    TextEditingController(text: user?.mobile ?? "");
    final TextEditingController nameCtrl =
    TextEditingController(text: user?.username ?? "");
    final TextEditingController personsCtrl =
    TextEditingController(text: user?.personCount.toString() ?? "1");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Center(
                        child: Text(
                          user == null ? "Add New Person" : "Edit Person",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(height: 20),

                      Text("Mobile Number *", style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      TextFormField(
                        controller: mobileCtrl,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        validator: (value) {
                          if (value == null || value.isEmpty) return "Enter mobile number";
                          if (!RegExp(r'^[0-9]+$').hasMatch(value)) return "Only numbers allowed";
                          if (value.length != 10) return "Mobile must be exactly 10 digits";
                          return null;
                        },
                        onChanged: (value) async {
                          if (value.length == 10) {
                            final foundUser = await AuthService.searchUserByPhone(value.trim());

                            if (foundUser != null) {
                              setStateDialog(() {
                                nameCtrl.text = foundUser.username;
                                personsCtrl.text = foundUser.personCount.toString();
                              });
                            } else {
                              setStateDialog(() {
                                nameCtrl.clear();
                                personsCtrl.text = "1";
                              });
                            }
                          }
                        },
                        decoration: InputDecoration(
                          counterText: "",
                          hintText: "Enter mobile number",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),

                      SizedBox(height: 12),

                      Text("Total Persons", style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      TextFormField(
                        controller: personsCtrl,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) return "Enter persons count";
                          if (int.tryParse(value) == null) return "Enter valid number";
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Enter total persons",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),

                      SizedBox(height: 12),

                      Text("Person Name *", style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      TextFormField(
                        controller: nameCtrl,
                        validator: (value) =>
                        value == null || value.isEmpty ? "Enter person name" : null,
                        decoration: InputDecoration(
                          hintText: "Enter person name",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),

                      SizedBox(height: 20),

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
                              child: Text("Cancel", style: TextStyle(color: Color(0xFFFF6B00))),
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
                                if (_formKey.currentState!.validate()) {

                                  final personCount = personsCtrl.text.isEmpty ? "1" : personsCtrl.text;

                                  if (user == null) {
                                    await ApiService.addRestaurantUser(
                                        nameCtrl.text, mobileCtrl.text, personCount);
                                  } else {
                                    await ApiService.editUser(
                                        user.id, nameCtrl.text, mobileCtrl.text, personCount);
                                  }
                                  Navigator.pop(context);
                                  loadUsers();
                                  widget.onRefreshWaitingList();
                                }
                              },
                              child: Text(
                                user == null ? "Add Person" : "Update",
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
          },
        );
      },
    );
  }
}




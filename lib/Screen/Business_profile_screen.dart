import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waiting_list/Screen/pin_login_screen.dart';
import 'package:waiting_list/services/auth_service.dart';
import 'Home_screen.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:math';

class Business_profile_screen extends StatefulWidget {
  const Business_profile_screen({super.key});

  @override
  State<Business_profile_screen> createState() => _Business_profile_screenState();
}
class _Business_profile_screenState extends State<Business_profile_screen> {

  int selectedIndex = 2;
  bool isLoggedIn = true;

  String city = "";
  String state = "";

  final _formKey = GlobalKey<FormState>();
  List subscriptions = [];////
  Map<String, dynamic>? subscriptionStatus;////
  List userTransactions = [];

  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController rNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();

  final TextEditingController streetController = TextEditingController();
  final TextEditingController apartmentController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();

  final TextEditingController currentPin = TextEditingController();
  final TextEditingController newPin = TextEditingController();
  final TextEditingController confirmPin = TextEditingController();


  File? _image;
  final ImagePicker _picker = ImagePicker();
  String? restaurantImageUrl;
  String? token;

  bool _showForgotPinCard = false;

  @override
  void initState() {
    super.initState();
    loadData(); // ✅ Don't auto override after loading saved data

    AuthService().fetchSubscriptions().then((data) {///
      setState(() {
        subscriptions = data;
      });
    });

    AuthService.fetchSubscriptionStatus().then((data) {///
      setState(() {
        subscriptionStatus = data;
      });
    });

    AuthService.fetchUserTransactions().then((data) {///
      setState(() {
        userTransactions = data;
      });
    });

  }


  Future pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    File original = File(pickedFile.path);
    int maxSize = 2 * 1024 * 1024; // 2 MB

    File compressedFile = original;
    int quality = 95;

    // Compress until size < 2MB
    while (compressedFile.lengthSync() > maxSize && quality > 10) {
      final result = await FlutterImageCompress.compressAndGetFile(
        compressedFile.path,
        "${compressedFile.path}_${Random().nextInt(9999)}.jpg",
        quality: quality,
      );

      if (result == null) break;
      compressedFile = File(result.path);
      quality -= 10;
    }

    setState(() {
      _image = compressedFile;
    });

    print("✅ Final Image Size: ${_image!.lengthSync() / 1024} KB");
  }

  Future<void> _signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Logout Successfully ✅"),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => PinLoginScreen()),
          (route) => false,
    );
  }
  void _showLogoutDialog(BuildContext context, Function signOut) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              /// Icon Circle
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.logout, size: 30, color: Colors.red),
              ),

              const SizedBox(height: 20),

              /// Title
              Text(
                "Confirm Logout",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 10),

              /// Subtitle
              Text(
                "Are you sure you want to log out of your account?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  /// Cancel Button
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        side: BorderSide(color: Colors.grey.shade400),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text("Cancel", style: TextStyle(color: Colors.black87, fontSize: 16)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  SizedBox(width: 10),

                  /// Logout Button
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text("Logout", style: TextStyle(color: Colors.white, fontSize: 16)),
                      onPressed: () {
                        Navigator.pop(context);
                        signOut();
                      },
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Row(
          children: [
            Image.asset("assets/Images/re2.png", height: 40),
            const SizedBox(width: 30),
            const Spacer(),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF6B00),
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: const Size(0, 33),
              ),
              icon: const Icon(Icons.save, size: 18, color: Colors.white),
              label: const Text("Save All", style: TextStyle(color: Colors.white, fontSize: 13)),
              onPressed: () {
                FocusScope.of(context).unfocus();
                if (_formKey.currentState!.validate()) {
                  saveRestaurant();
                } else {
                  showMsg("Please fix validation errors", error: true);
                }
              },
            ),
          ],
        ),
      ),

      /// ✅ Screen content here
      body: businessProfileContent(),

      /// ✅ Always show bottom navigation
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: _NavItem(
                icon: Icons.home,
                label: "Home",
                bgColor: selectedIndex == 0 ? Color(0xFFFFF0E6) : Colors.white,
                textColor: selectedIndex == 0 ? Color(0xFFFF6B00) : Colors.black,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => HomeScreen(initialIndex: 0)),
                  );
                },
              ),
            ),
            Expanded(
              child: _NavItem(
                icon: Icons.list_alt,
                label: "Waiting List",
                bgColor: selectedIndex == 1 ? Color(0xFFFFF0E6) : Colors.white,
                textColor: selectedIndex == 1 ? Color(0xFFFF6B00) : Colors.black,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => HomeScreen(initialIndex: 1)),
                  );
                },
              ),
            ),
            Expanded(
              child: _NavItem(
                icon: Icons.settings,
                label: "Settings",
                bgColor: selectedIndex == 2 ? Color(0xFFFFF0E6) : Colors.white,
                textColor: selectedIndex == 2 ? Color(0xFFFF6B00) : Colors.black,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => HomeScreen(initialIndex: 2)),
                  );
                },
              ),
            ),
            Expanded(
              child: _NavItem(
                icon: Icons.logout,
                label: "Logout",
                bgColor: Color(0xFFFFE3E3),
                textColor: Color(0xFFD9534F),
                onTap: () => _showLogoutDialog(context, _signOut),
              ),
            ),
          ],
        ),
      ),
    );

  }

  Widget _formInput(String label,
      {required TextEditingController controller,
        bool required = false,
        bool email = false,
        bool phone = false,
        bool website = false,
        bool enabled = true}) {  // ✅ NEW PARAM

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        enabled: enabled, // ✅ This disables the field
        validator: (value) {
          value = value?.trim() ?? "";

          if (required && value.isEmpty) return "$label is required";

          if (phone && value.isNotEmpty) {
            if (!RegExp(r'^[0-9]+$').hasMatch(value)) return "Numbers only allowed";
            if (value.length != 10) return "Phone must be 10 digits";
          }

          if (email && value.isNotEmpty && !RegExp(r"^[\w\.-]+@[\w\.-]+\.\w+$").hasMatch(value)) {
            return "Enter valid email";
          }

          if (website && value.isNotEmpty && !Uri.tryParse(value)!.isAbsolute == true) {
            return "Enter valid website";
          }

          return null;
        },

        decoration: _decoration(label).copyWith(
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey.shade200,
        ),
      ),
    );
  }



  Widget _simpleInput(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(controller: controller, decoration: _decoration(label)),
    );
  }

  InputDecoration _decoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
  );

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Text(text, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
  );

  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    margin: EdgeInsets.only(bottom: 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 13)],
    ),
    child: child,
  );

  void showMsg(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: TextStyle(color: Colors.white, fontSize: 15)),
        backgroundColor: error ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> saveRestaurant() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("https://waitinglist.rektech.work/api/restaurants/my-restaurant"),
    );

    request.headers['Authorization'] = "Bearer $token";
    request.fields['owner_name'] = ownerNameController.text;
    request.fields['email'] = emailController.text;
    request.fields['name'] = rNameController.text;
    request.fields['contact_number'] = phoneController.text;
    request.fields['website'] = websiteController.text;
    request.fields['address_line_1'] = streetController.text;
    request.fields['address_line_2'] = apartmentController.text;
    request.fields['city'] = cityController.text;
    request.fields['state'] = stateController.text;
    request.fields['country'] = countryController.text;
    request.fields['postal_code'] = postalCodeController.text;

    if (_image != null) {
      request.files.add(await http.MultipartFile.fromPath('profile', _image!.path));
    }

    var response = await request.send();
    var resBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      showMsg("✅ Saved Successfully");
    } else {
      showMsg("❌ Error: $resBody", error: true);
    }
  }

  Future<void> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token");

    // ✅ Email always from logged-in user stored locally
    String spEmail = prefs.getString("user_email") ?? "";
    emailController.text = spEmail;

    var response = await http.get(
      Uri.parse("https://waitinglist.rektech.work/api/restaurants/my-restaurant"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body)["data"];

      setState(() {
        ownerNameController.text = data["owner_name"] ?? ""; // ✅ API thi owner name
        rNameController.text = data["name"] ?? "";
        phoneController.text = data["contact_number"] ?? "";
        websiteController.text = data["website"] ?? "";
// ✅ Street should always be blank
        streetController.text = "";

// ✅ Apartment should get old saved address_line_1 if available
        apartmentController.text = data["address_line_1"] ?? "";

// ✅ If address_line_2 exists, append or use it
        if ((data["address_line_2"] ?? "").isNotEmpty) {
          apartmentController.text +=
          apartmentController.text.isEmpty ? data["address_line_2"] : ", ${data["address_line_2"]}";
        }
        cityController.text = data["city"] ?? "";
        stateController.text = data["state"] ?? "";
        countryController.text = data["country"] ?? "";
        postalCodeController.text = data["postal_code"] ?? "";
        restaurantImageUrl = "https://waitinglist.rektech.work/storage/${data["profile"]}";
      });
    }
  }

  void fillAddressFromLocation({bool forceUpdate = false}) async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placeMarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      Placemark place = placeMarks[0];

      setState(() {
        // ✅ Street value should NOT fill auto
        streetController.text = "";

        // ✅ Auto Fill should go to Apartment instead of Street
        apartmentController.text = place.street ?? "";

        // ✅ Other fields update normally
        if (forceUpdate || cityController.text.isEmpty) {
          cityController.text = place.locality ?? "";
        }
        if (forceUpdate || stateController.text.isEmpty) {
          stateController.text = place.administrativeArea ?? "";
        }
        if (forceUpdate || countryController.text.isEmpty) {
          countryController.text = place.country ?? "";
        }
        if (forceUpdate || postalCodeController.text.isEmpty) {
          postalCodeController.text = place.postalCode ?? "";
        }
      });


    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location not found. Please enable GPS.")),
      );
    }
  }




  Widget businessProfileContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // IMAGE CARD
          _card(
            child: Center(
              child: GestureDetector(
                onTap: pickImage,
                child: Container(
                  height: 110,
                  width: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade200,
                    image: _image != null
                        ? DecorationImage(image: FileImage(_image!), fit: BoxFit.cover)
                        : restaurantImageUrl != null
                        ? DecorationImage(image: NetworkImage(restaurantImageUrl!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: _image == null && restaurantImageUrl == null
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.camera_alt_outlined, size: 35, color: Colors.grey),
                      SizedBox(height: 6),
                      Text("Tap to add logo", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  )
                      : null,
                ),
              ),
            ),
          ),

          _sectionTitle("Basic Information"),
          _card(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _formInput("Owner Name", controller: ownerNameController, required: true, enabled: true),
                  _formInput("Email", controller: emailController, email: true, enabled: false),
                  _formInput("Restaurant Name *", controller: rNameController, required: true),
                  _formInput("Contact Number *", controller: phoneController, phone: true),
                  _formInput("Website", controller: websiteController, website: true),
                ],
              ),
            ),
          ),

          _sectionTitle("Address Information"),
          _card(
            child: Column(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFF6B00)),
                  onPressed: () => fillAddressFromLocation(forceUpdate: true),
                  child: Text(
                    "📍 Use Current Location",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 14),
                _simpleInput("Street", streetController),
                _simpleInput("Apartment (optional)", apartmentController),
                Row(children: [
                  Expanded(child: _simpleInput("City", cityController)),
                  SizedBox(width: 12),
                  Expanded(child: _simpleInput("State", stateController)),
                ]),
                Row(children: [
                  Expanded(child: _simpleInput("Country", countryController)),
                  SizedBox(width: 12),
                  Expanded(child: _simpleInput("Postal code", postalCodeController)),
                ]),
              ],
            ),
          ),

          _sectionTitle("Subscription Details"),///
          _card(
            child: subscriptions.isEmpty
                ? Center(child: Text("No Subscription Found"))
                : ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: subscriptions.length,
              itemBuilder: (context, index) {
                var sub = subscriptions[index];
                return ListTile(
                  leading: Icon(Icons.workspace_premium, color: Colors.orange),
                  title: Text(sub["plan_name"] ?? "Unknown Plan"),
                  subtitle: Text("From: ${sub["start_date"]}\nTo: ${sub["end_date"]}"),
                  trailing: Chip(
                    label: Text(
                      sub["status"] == "active" ? "Active" : "Expired",
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor:
                    sub["status"] == "active" ? Colors.green : Colors.red,
                  ),
                );
              },
            ),
          ),

          _sectionTitle("Active Subscription"),////
          _card(
            child: subscriptionStatus == null
                ? Text("No Active Subscription ❌")
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Plan: ${subscriptionStatus!["plan_name"]}", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text("Expires On: ${subscriptionStatus!["expires_at"]}"),
                SizedBox(height: 10),
                Chip(
                  label: Text(
                    subscriptionStatus!["is_active"] == true ? "ACTIVE" : "EXPIRED",
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: subscriptionStatus!["is_active"] == true ? Colors.green : Colors.red,
                ),
              ],
            ),
          ),

          _sectionTitle("Transaction History"),///////
          _card(
            child: userTransactions.isEmpty
                ? Center(child: Text("No Transactions Found"))
                : ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: userTransactions.length,
              itemBuilder: (context, index) {
                var tx = userTransactions[index];

                return ListTile(
                  leading: Icon(Icons.receipt_long, color: Colors.blueAccent),

                  title: Text(
                    tx["plan_name"] ?? "Subscription Plan",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  subtitle: Text(
                    "₹${tx["amount"]} • ${tx["payment_method"]}\n${tx["created_at"].toString().split(" ").first}",
                  ),

                  trailing: Chip(
                    label: Text(
                      tx["status"] ?? "unknown",
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: tx["status"] == "success"
                        ? Colors.green
                        : Colors.red,
                  ),
                );
              },
            ),
          ),


          subscriptionStatus != null && subscriptionStatus!["is_active"] == true
              ? ElevatedButton(
            onPressed: () async {
              bool result = await AuthService.cancelSubscription();
              if (result) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Subscription Cancelled ✅")),
                );
                // Refresh status after cancel
                AuthService.fetchSubscriptionStatus().then((data) {
                  setState(() {
                    subscriptionStatus = data;
                  });
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to Cancel Subscription ❌")),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text("Cancel Subscription"),
          )
              : SizedBox(),



          _sectionTitle("Security"),
          _card(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFF6B00), shape: StadiumBorder()),
              child: Text("🔐 Change PIN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: () => setState(() => _showForgotPinCard = !_showForgotPinCard),
            ),
          ),

          if (_showForgotPinCard)
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Change PIN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  _simpleInput("Current PIN", currentPin),
                  _simpleInput("New PIN", newPin),
                  _simpleInput("Confirm New PIN", confirmPin),
                  SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFF6B00)),
                    onPressed: () {
                      if (newPin.text.length != 4) return showMsg("PIN must be 4 digits", error: true);
                      if (newPin.text != confirmPin.text) return showMsg("PINs do not match", error: true);
                      changePin();
                    },
                    child: Text("Update PIN", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> changePin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (currentPin.text.isEmpty || newPin.text.isEmpty || confirmPin.text.isEmpty) {
      showMsg("Please fill all fields", error: true);
      return;
    }

    var url = Uri.parse(
        "https://waitinglist.rektech.work/api/auth/change-pin?"
            "current_pin=${currentPin.text}&new_pin=${newPin.text}&confirm_pin=${confirmPin.text}");

    var response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    var data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      showMsg("✅ PIN Updated Successfully");
      currentPin.clear();
      newPin.clear();
      confirmPin.clear();
      setState(() => _showForgotPinCard = false);
    } else {
      showMsg("❌ ${data["message"] ?? "Failed to update PIN"}", error: true);
    }
  }


}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bgColor;
  final Color textColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: textColor),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: textColor),
            ),
          ],
        ),
      ),
    );

  }



}
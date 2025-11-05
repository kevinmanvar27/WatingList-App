import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Business_profile_screen extends StatefulWidget {
  const Business_profile_screen({super.key});

  @override
  State<Business_profile_screen> createState() => _Business_profile_screenState();
}

class _Business_profile_screenState extends State<Business_profile_screen> {
  String city = "";
  String state = "";

  final _formKey = GlobalKey<FormState>();

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

  File? _image;
  final ImagePicker _picker = ImagePicker();
  String? restaurantImageUrl;
  String? token;

  bool _showForgotPinCard = false;

  @override
  void initState() {
    super.initState();
    loadData().then((_) {
      if (streetController.text.isEmpty) {
        fillAddressFromLocation();
      }
    });
  }

  Future pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
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
                if (_formKey.currentState!.validate()) {
                  saveRestaurant();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please fix validation errors")),
                  );
                }
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

            // IMAGE
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
                    _formInput("Owner Name", controller: ownerNameController, required: true),
                    _formInput("Email", controller: emailController, email: true),
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
                    onPressed: fillAddressFromLocation,
                    child: Text(city.isEmpty ? "📍 Use Current Location" : "$city, $state",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                    _simpleInput("Current PIN", TextEditingController()),
                    _simpleInput("New PIN", TextEditingController()),
                    _simpleInput("Confirm New PIN", TextEditingController()),
                    SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFF6B00)),
                      onPressed: () {},
                      child: Text("Update PIN", style: TextStyle(color: Colors.white)),
                    ),
                  ],
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
        bool website = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        validator: (value) {
          if (required && value!.isEmpty) return "$label is required";
          if (email && value!.isNotEmpty && !RegExp(r"^[\w\.-]+@[\w\.-]+\.\w+$").hasMatch(value)) return "Enter valid email";
          if (phone && value!.length < 10) return "Enter valid phone";
          if (website && value!.isNotEmpty && !Uri.tryParse(value)!.isAbsolute) return "Enter valid URL";
          return null;
        },
        decoration: _decoration(label),
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(response.statusCode == 200
              ? "✅ Saved Successfully"
              : "❌ Error: $resBody")),
    );
  }

  Future<void> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token");

    var response = await http.get(
      Uri.parse("https://waitinglist.rektech.work/api/restaurants/my-restaurant"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body)["data"];

      setState(() {
        ownerNameController.text = data["owner_name"] ?? "";
        emailController.text = data["email"] ?? "";
        rNameController.text = data["name"] ?? "";
        phoneController.text = data["contact_number"] ?? "";
        websiteController.text = data["website"] ?? "";

        streetController.text = data["address_line_1"] ?? "";
        apartmentController.text = data["address_line_2"] ?? "";
        cityController.text = data["city"] ?? "";
        stateController.text = data["state"] ?? "";
        countryController.text = data["country"] ?? "";
        postalCodeController.text = data["postal_code"] ?? "";

        restaurantImageUrl = "https://waitinglist.rektech.work/storage/${data["profile"]}";
      });
    }
  }

  void fillAddressFromLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placeMarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placeMarks[0];

    setState(() {
      city = place.locality ?? "";
      state = place.administrativeArea ?? "";
    });

    streetController.text = place.street ?? "";
    cityController.text = place.locality ?? "";
    stateController.text = place.administrativeArea ?? "";
    countryController.text = place.country ?? "";
    postalCodeController.text = place.postalCode ?? "";
  }
}

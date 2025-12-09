import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waiting_list2/Screen/waiting_list_screen.dart';
import '../Api_Model/Restaurent/User_restaurent.dart';
import '../Appbar.dart';
import 'Home_screen.dart';

class Business_profile_screen extends StatefulWidget {
  const Business_profile_screen({super.key});

  @override
  State<Business_profile_screen> createState() => _Business_profile_screenState();
}

class _Business_profile_screenState extends State<Business_profile_screen> {
  bool _showForgotPinCard = false;
  bool _isDisposed = false;
  bool _isSaving = false;
  bool _isGettingLocation = false;
  bool _isLoading = true;
  bool _isExistingRestaurant = false;

  File? _image;
  String _profileImageUrl = "";
  final ImagePicker _picker = ImagePicker();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _ownerNameCtrl;
  late TextEditingController _emailCtrl;
  // late TextEditingController _nameCtrl;
  late TextEditingController _restaurantNameCtrl;
  late TextEditingController _contactCtrl;
  late TextEditingController _websiteCtrl;
  late TextEditingController _streetCtrl;
  late TextEditingController _apartmentCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _stateCtrl;
  late TextEditingController _countryCtrl;
  late TextEditingController _postalCtrl;
  late TextEditingController _currentPinCtrl;
  late TextEditingController _newPinCtrl;
  late TextEditingController _confirmPinCtrl;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _fetchRestaurantData();
  }

  void _initializeControllers() {
    _ownerNameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _restaurantNameCtrl = TextEditingController();
    _contactCtrl = TextEditingController();
    _websiteCtrl = TextEditingController();
    _streetCtrl = TextEditingController();
    _apartmentCtrl = TextEditingController();
    _cityCtrl = TextEditingController();
    _stateCtrl = TextEditingController();
    _countryCtrl = TextEditingController();
    _postalCtrl = TextEditingController();
    _currentPinCtrl = TextEditingController();
    _newPinCtrl = TextEditingController();
    _confirmPinCtrl = TextEditingController();
  }

  // Replace the _fetchRestaurantData method with this updated version

  Future<void> _fetchRestaurantData() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final token = sp.getString('auth_token');
      final userEmail = sp.getString('user_email') ?? '';
      final userName = sp.getString('user_name') ?? '';

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

        // Check if data is not null
        if (jsonData['data'] != null) {
          final restaurant = CreateRestaurant.fromJson(jsonData);

          if (mounted) {
            String ownerName = restaurant.data.ownerName?.isNotEmpty == true
                ? restaurant.data.ownerName!
                : userName;

            setState(() {
              _isExistingRestaurant = true;
              _emailCtrl.text = userEmail;
              _ownerNameCtrl.text = ownerName;
              // print("Owner Name from API: $ownerName");
              _restaurantNameCtrl.text = restaurant.data.name ?? '';
              _contactCtrl.text = restaurant.data.contactNumber ?? '';
              _websiteCtrl.text = restaurant.data.website ?? '';
              _streetCtrl.text = restaurant.data.addressLine1 ?? '';
              _apartmentCtrl.text = restaurant.data.addressLine2 ?? '';
              _cityCtrl.text = restaurant.data.city ?? '';
              _stateCtrl.text = restaurant.data.state ?? '';
              _countryCtrl.text = restaurant.data.country ?? '';
              _postalCtrl.text = restaurant.data.postalCode ?? '';
              _profileImageUrl = restaurant.data.profile ?? "";
              _isLoading = false;
            });
          }
        } else {
          // data is null, treat as no restaurant
          _handleNoRestaurant(sp, userEmail, userName);
        }
      } else if (response.statusCode == 404) {
        _handleNoRestaurant(sp, userEmail, userName);
      } else {
        throw Exception('Failed to fetch restaurant data');
      }
    } catch (e) {
      // print('Fetch error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  void _handleNoRestaurant(SharedPreferences sp, String userEmail, String userName) {
    if (mounted) {
      String ownerName = userName.isNotEmpty ? userName : '';

      // If user_name not found, extract from email
      if (ownerName.isEmpty && userEmail.isNotEmpty) {
        ownerName = userEmail.split('@')[0];
        ownerName = ownerName[0].toUpperCase() + ownerName.substring(1);
      }

      // print("Owner Name from SharedPreferences: $ownerName");

      setState(() {
        _isExistingRestaurant = false;
        _emailCtrl.text = userEmail;
        _ownerNameCtrl.text = ownerName;
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    if (_isGettingLocation) return;

    setState(() => _isGettingLocation = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Location permission is required')),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty && mounted) {
        final place = placemarks[0];
        setState(() {
          _streetCtrl.text = place.street ?? '';
          _cityCtrl.text = place.locality ?? '';
          _stateCtrl.text = place.administrativeArea ?? '';
          _countryCtrl.text = place.country ?? '';
          _postalCtrl.text = place.postalCode ?? '';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location loaded successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGettingLocation = false);
      }
    }
  }

  Future<File?> _compressImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();

      if (bytes.length < 2097152) {
        return imageFile;
      }

      final image = img.decodeImage(bytes);
      if (image == null) return imageFile;

      final resized = img.copyResize(image, width: 800, height: 800);
      final compressed = img.encodeJpg(resized, quality: 70);

      final compressedFile = File(imageFile.path)..writeAsBytesSync(compressed);

      final finalBytes = await compressedFile.readAsBytes();
      if (finalBytes.length > 2097152) {
        final reCompressed = img.encodeJpg(resized, quality: 50);
        return File(imageFile.path)..writeAsBytesSync(reCompressed);
      }

      return compressedFile;
    } catch (e) {
      // print('Image compression error: $e');
      return imageFile;
    }
  }

  Future<void> _saveAllData() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _sendRestaurantDataToBackend();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restaurant data saved successfully!')),
        );

        await Future.delayed(Duration(seconds: 1));

        if (mounted) {
          // Check show home page flag
          final sp = await SharedPreferences.getInstance();
          final showHomePage = sp.getInt('show_home_page') ?? 1;
          
          if (showHomePage == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => WaitingListScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen(refreshKey: UniqueKey())),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _sendRestaurantDataToBackend() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final token = sp.getString('auth_token');

      if (token == null) {
        throw Exception('No auth token found');
      }

      http.Response response;

      if (_image != null) {
        final compressedImage = await _compressImage(_image!);
        response = await _sendWithImage(token, compressedImage!);
      } else {
        final requestBody = {
          'name': _restaurantNameCtrl.text,
          'owner_name': _ownerNameCtrl.text,
          'contact_number': _contactCtrl.text,
          'website': _websiteCtrl.text.isEmpty ? null : _websiteCtrl.text,
          'address_line_1': _streetCtrl.text,
          'address_line_2': _apartmentCtrl.text.isEmpty ? null : _apartmentCtrl.text,
          'city': _cityCtrl.text,
          'state': _stateCtrl.text,
          'country': _countryCtrl.text,
          'postal_code': _postalCtrl.text,
        };

        final Uri updateUrl = Uri.parse(
          'https://waitinglist.rektech.work/api/restaurants/my-restaurant',
        );

        response = await http.post(
          updateUrl,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode(requestBody),
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        final restaurant = CreateRestaurant.fromJson(jsonData);

        setState(() {
          _isExistingRestaurant = true;
          _image = null;
        });
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Token expired');
      } else {
        throw Exception('Failed to save: ${response.statusCode}');
      }
    } catch (e) {
      // print('Backend error: $e');
      rethrow;
    }
  }

  Future<http.Response> _sendWithImage(String token, File compressedImage) async {
    final Uri url = Uri.parse(
      'https://waitinglist.rektech.work/api/restaurants/my-restaurant',
    );

    final request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['name'] = _restaurantNameCtrl.text;
    request.fields['owner_name'] = _ownerNameCtrl.text;
    request.fields['contact_number'] = _contactCtrl.text;
    request.fields['website'] = _websiteCtrl.text;
    request.fields['address_line_1'] = _streetCtrl.text;
    request.fields['address_line_2'] = _apartmentCtrl.text;
    request.fields['city'] = _cityCtrl.text;
    request.fields['state'] = _stateCtrl.text;
    request.fields['country'] = _countryCtrl.text;
    request.fields['postal_code'] = _postalCtrl.text;

    request.files.add(
      await http.MultipartFile.fromPath('profile', compressedImage.path),
    );

    final response = await request.send();
    return http.Response.fromStream(response);
  }

  Future<void> pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null && !_isDisposed) {
        setState(() => _image = File(pickedFile.path));
      }
    } catch (e) {
      // print('Image pick error: $e');
    }
  }

  Future<void> _changePin() async {
    if (_currentPinCtrl.text.isEmpty || _newPinCtrl.text.isEmpty || _confirmPinCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All PIN fields are required')),
      );
      return;
    }

    if (_newPinCtrl.text != _confirmPinCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('New PINs do not match')),
      );
      return;
    }

    if (_newPinCtrl.text.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PIN must be 4 digits')),
      );
      return;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(_newPinCtrl.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PIN must contain only digits')),
      );
      return;
    }

    try {
      final sp = await SharedPreferences.getInstance();
      final token = sp.getString('auth_token');

      if (token == null) throw Exception('No auth token');

      final response = await http.post(
        Uri.parse('https://waitinglist.rektech.work/api/auth/change-pin'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'current_pin': _currentPinCtrl.text,
          'new_pin': _newPinCtrl.text,
          'confirm_pin': _confirmPinCtrl.text,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('PIN changed successfully')),
          );
          setState(() {
            _showForgotPinCard = false;
            _currentPinCtrl.clear();
            _newPinCtrl.clear();
            _confirmPinCtrl.clear();
          });
        }
      } else {
        throw Exception('Failed to change PIN');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }


  @override
  void dispose() {
    _isDisposed = true;
    _ownerNameCtrl.dispose();
    _emailCtrl.dispose();
    _restaurantNameCtrl.dispose();
    _contactCtrl.dispose();
    _websiteCtrl.dispose();
    _streetCtrl.dispose();
    _apartmentCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _countryCtrl.dispose();
    _postalCtrl.dispose();
    _currentPinCtrl.dispose();
    _newPinCtrl.dispose();
    _confirmPinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Color(0xFFFF6B00)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        toolbarHeight: 70,
        title: Row(
          children: [
            Image.asset("assets/Images/re2.png", height: 40),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B00),
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: const Size(0, 32),
                elevation: 0,
              ),
              onPressed: _isSaving ? null : _saveAllData,
              child: _isSaving
                  ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              )
                  : const Text(
                "Save All",
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _fetchRestaurantData();
        },
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _card(
                  child: Center(
                    child: GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade200,
                          image: _image != null
                              ? DecorationImage(
                            image: FileImage(_image!),
                            fit: BoxFit.cover,
                          )
                              : _profileImageUrl.isNotEmpty
                              ? DecorationImage(
                            image: NetworkImage(
                              "https://waitinglist.rektech.work/storage/${_profileImageUrl}",
                            ),
                            fit: BoxFit.cover,
                          )
                              : null,
                        ),
                        child: _image == null && _profileImageUrl.isEmpty
                            ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.camera_alt_outlined, size: 35, color: Colors.grey),
                            SizedBox(height: 6),
                            Text(
                              "Tap to add logo",
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        )
                            : null,
                      ),
                    ),
                  ),
                ),
                _sectionTitle("Basic Information"),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _inputField(_ownerNameCtrl, "Owner Name", isRequired: false),
                      _inputField(_emailCtrl, "Email", keyboardType: TextInputType.emailAddress, enabled: false, isRequired: false),
                      _inputField(_restaurantNameCtrl, "Restaurant Name *", isRequired: true),
                      _inputField(_contactCtrl, "Contact Number *", keyboardType: TextInputType.phone, isRequired: true),
                      _inputField(_websiteCtrl, "Website", isRequired: false),
                    ],
                  ),
                ),
                _sectionTitle("Address Information"),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B00),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: _isGettingLocation ? null : _getCurrentLocation,
                          child: _isGettingLocation
                              ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                              : const Text(
                            "Use Current Location",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _inputField(_apartmentCtrl, "Apartment, suite, etc. (optional)", isRequired: false),
                      _inputField(_streetCtrl, "Street address", isRequired: false),
                      Row(
                        children: [
                          Expanded(child: _inputField(_cityCtrl, "City", isRequired: false)),
                          const SizedBox(width: 12),
                          Expanded(child: _inputField(_stateCtrl, "State", isRequired: false)),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: _inputField(_countryCtrl, "Country", isRequired: false)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _inputField(_postalCtrl, "Postal code", keyboardType: TextInputType.number, isRequired: false),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _sectionTitle("Security"),
                _card(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B00),
                        shape: const StadiumBorder()),
                    child: const Text("Change PIN",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      if (!_isDisposed) {
                        setState(() {
                          _showForgotPinCard = !_showForgotPinCard;
                        });
                      }
                    },
                  ),
                ),
                if (_showForgotPinCard)
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Change PIN",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        _inputField(_currentPinCtrl, "Current PIN", keyboardType: TextInputType.number, isRequired: false, obscureText: true),
                        _inputField(_newPinCtrl, "New PIN", keyboardType: TextInputType.number, isRequired: false,obscureText: true),
                        _inputField(_confirmPinCtrl, "Confirm New PIN", keyboardType: TextInputType.number, isRequired: false,obscureText: true),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6B00),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            onPressed: _changePin,
                            child: const Text(
                              "Update PIN",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Text(text, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
  );

  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.only(bottom: 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.10),
          blurRadius: 13,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: child,
  );

  Widget _inputField(
      TextEditingController controller,
      String hint, {
        TextInputType keyboardType = TextInputType.text,
        bool enabled = true,
        bool obscureText = false,
        bool isRequired = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: enabled,
        obscureText: obscureText,
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return '${hint.replaceAll(' *', '')} is required';
          }

          // Email validation for email field
          if (hint.contains('Email') && value != null && value.isNotEmpty) {
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
              return 'Enter a valid email address';
            }
          }

          // Phone validation for contact field
          if (hint.contains('Contact') && value != null && value.isNotEmpty) {
            if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
              return 'Enter a valid 10-digit phone number';
            }
          }

          return null;
        },
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFFF6B00), width: 1.6),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
        ),
      ),
    );
  }
}
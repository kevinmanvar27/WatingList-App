import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class BusinessProfileScreen extends StatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future pickImage() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.gallery);
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
        elevation: 0,
        title: const Text("Business Profile",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B00),
                shape: const StadiumBorder(),
              ),
              icon: const Icon(Icons.save, size: 18, color: Colors.white),
              label:
              const Text("Save All", style: TextStyle(color: Colors.white)),
              onPressed: () {},
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _card(
              child: GestureDetector(
                onTap: pickImage,
                child: Container(
                  height: 160, // 👈 This will center the text inside
                  alignment: Alignment.center,
                  child: _image == null
                      ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.camera_alt_outlined,
                          size: 40, color: Colors.grey),
                      SizedBox(height: 6),
                      Text(
                        "Tap to add logo",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  )
                      : CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: FileImage(_image!),
                  ),
                ),
              ),
            ),


            // ---------------- BASIC INFORMATION ----------------
            _sectionTitle("Basic Information"),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _inputField("Owner Name"),
                  _inputField("Email", keyboardType: TextInputType.emailAddress),
                  _inputField("Restaurant Name *"),
                  _inputField("Contact Number *", keyboardType: TextInputType.phone),
                  _inputField("Website"),
                ],
              ),
            ),

// ---------------- ADDRESS INFORMATION ----------------
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
                      onPressed: () {},
                      child: const Text("📍  Use Current Location",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                    ),
                  ),
                  const SizedBox(height: 14),

                  _inputField("Street address"),
                  _inputField("Apartment, suite, etc. (optional)"),

                  Row(
                    children: [
                      Expanded(child: _inputField("City")),
                      const SizedBox(width: 12),
                      Expanded(child: _inputField("State")),
                    ],
                  ),

                  Row(
                    children: [
                      Expanded(child: _inputField("Country")),
                      const SizedBox(width: 12),
                      Expanded(child: _inputField("Postal code", keyboardType: TextInputType.number)),
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
                child: const Text("🔐 Change PIN",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Text(text,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
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


  Widget _inputField(String hint, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFFF6B00), width: 1.6),
          ),
        ),
      ),
    );
  }

}

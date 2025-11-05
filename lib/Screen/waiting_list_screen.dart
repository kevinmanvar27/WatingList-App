import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Api_Model/restaurant_user_model.dart';
import '../services/add_person_service.dart';

class WaitingListScreen extends StatefulWidget {
  const WaitingListScreen({super.key});

  @override
  State<WaitingListScreen> createState() => WaitingListScreenState();
}

class WaitingListScreenState extends State<WaitingListScreen> {

  List<RestaurantUser> users = [];


  void refreshUsers() {
    loadUsers();
  }

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  void loadUsers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("SAVED TOKEN: ${prefs.getString("token")}");
    users = await ApiService.fetchUsers();
    users.sort((a, b) => a.id.compareTo(b.id));
    setState(() {});
  }

  void callNumber(String phone) async {
    final Uri callUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      print("Could not launch dialer"); 
    }
  }

  bool dineInChecked = false;
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
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
                    Text("Waiting Users",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text("October 31, 2025",
                        style: TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),

                Row(
                  children: [
                    //IconButton(onPressed: (){}, icon: Icon(Icons.dark_mode,size: 30,)),

                    SizedBox(width: 10),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                      },
                      child: const Text("We are Open",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 30),
            // Card Table
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 6,
                          offset: const Offset(0, 3))
                    ],
                  ),
                
                  child: Column(
                    children: [
                
                      // Table Header
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                        decoration: const BoxDecoration(
                            color: Color(0xFFFF6F00),
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text("#", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                            Expanded(child: Text("Name", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                            Expanded(child: Text("Persons", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                            Expanded(child: Text("Dine-in", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                            Expanded(child: Text("Call", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                            Expanded(child: Text("Actions", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),
                
                      ...users.asMap().entries.map((entry) {
                        int index = entry.key + 1;
                        RestaurantUser user = entry.value;
                
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                          child: Row(
                            children: [
                              Expanded(child: Text(index.toString())),

                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    _showAddUserDialog(context, user: user);
                                  },
                                  child: Text(
                                    user.username,
                                    style: TextStyle(color: Colors.orange, decoration: TextDecoration.underline),
                                  ),
                                ),
                              ),


                              Expanded(child: Text(user.personCount.toString())),

                              Expanded(
                                child: StatefulBuilder(
                                  builder: (context, setCheckState) {
                                    return Checkbox(
                                      value: user.dineIn,
                                      onChanged: (value) async {
                                        setCheckState(() => user.dineIn = value!);

                                        if (value == true) {
                                          // ✅ Mark dine-in after 3 seconds
                                          Timer(Duration(seconds: 3), () async {
                                            await ApiService.markDineIn(user.id);
                                            loadUsers();
                                          });
                                        } else {
                                          // ✅ Mark Waiting BUT do NOT delete
                                          await ApiService.markWaiting(user.id);
                                          loadUsers(); // just refresh list
                                        }
                                      },
                                      activeColor: Color(0xFFFF6F00),
                                    );
                                  },
                                ),
                              ),



                              Expanded(
                                child: IconButton(
                                  icon: Icon(Icons.call),
                                  color: Colors.green,
                                  onPressed: () {
                                    callNumber(user.mobile);
                                  },
                                ),
                              ),

                              Expanded(
                                child: IconButton(
                                  icon: Icon(Icons.delete),
                                  color: Colors.red,
                                  onPressed: () async {
                                    bool deleted = await ApiService.deleteUser(user.id);
                                    if (deleted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("${user.username} removed from waiting list"))
                                      );
                                      loadUsers(); // ✅ UI refresh
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Failed to delete user"))
                                      );
                                    }
                                  },
                                ),
                              ),

                            ],
                          ),
                        );
                      }).toList(),
                
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context, {RestaurantUser? user}) {

    final TextEditingController mobileCtrl = TextEditingController(text: user?.mobile ?? "");
    final TextEditingController nameCtrl = TextEditingController(text: user?.username ?? "");
    final TextEditingController personsCtrl = TextEditingController(text: user?.personCount.toString() ?? "");


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
                    user == null ? "Add New Person" : "Edit Person",
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

                          if (user == null) {
                            // ✅ Add User API
                            await ApiService.addRestaurantUser(
                              nameCtrl.text,
                              mobileCtrl.text,
                              personsCtrl.text.isEmpty ? "1" : personsCtrl.text,
                            );
                          } else {
                            // ✅ Edit User API
                            await ApiService.editUser(
                              user.id,
                              nameCtrl.text,
                              mobileCtrl.text,
                              personsCtrl.text.isEmpty ? "1" : personsCtrl.text,
                            );
                          }

                          Navigator.pop(context);
                          loadUsers(); // ✅ UI Refresh
                        },
                        child: Text(
                          user == null ? "Add Person" : "Update",
                          style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                        ),

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
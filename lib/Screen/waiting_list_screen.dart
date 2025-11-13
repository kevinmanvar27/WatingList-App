import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Api_Model/restaurant_user_model.dart';
import '../services/add_person_service.dart';
import '../services/auth_service.dart';
import 'package:intl/intl.dart';

class WaitingListScreen extends StatefulWidget {
  final VoidCallback? onStatusChanged;
  const WaitingListScreen({super.key, this.onStatusChanged});

  @override
  State<WaitingListScreen> createState() => WaitingListScreenState();
}

class WaitingListScreenState extends State<WaitingListScreen> {

  List<RestaurantUser> users = [];

  void refreshUsers() {
    loadUsers();
  }

  Future<void> loadRestaurantStatus() async {
    final data = await AuthService.fetchRestaurantDetail();
    setState(() {
      // Handle case when data is empty
      if (data.isNotEmpty) {
        // Assuming data["operational_status"] is a String like "true" or "false"
        isRestaurantOpen = data["operational_status"] == "true";
        currentRestaurantId = data["id"];
      } else {
        // Set default values when data is empty
        isRestaurantOpen = false;
        currentRestaurantId = null;
      }
    });
    // Re-filter users after getting restaurant id
    loadUsers();
  }
  
  @override
  void initState() {
    super.initState();
    loadRestaurantStatus();
  }

  Future<void> loadUsers() async {
    users = await ApiService.fetchUsers();
    
    // For new users, if currentRestaurantId is null, try to load it again
    if (currentRestaurantId == null) {
      await loadRestaurantStatus();
    }
    
    // Filter users by restaurant ID only if we have a valid restaurant ID
    if (currentRestaurantId != null && currentRestaurantId != 0) {
      users = users.where((u) => u.restaurantId == currentRestaurantId).toList();
    }
    
    users.sort((a, b) => a.id.compareTo(b.id));
    setState(() {});
  }

  void callNumber(String phone) async {
    final Uri callUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    }
  }

  bool dineInChecked = false;
  bool isRestaurantOpen = false;
  int? currentRestaurantId;


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
              onPressed: () async {
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline, size: 26, color: Color(0xFFFF6F00)),
                                SizedBox(width: 10),
                                Text(
                                  "Restaurant Closed",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15),
                            Text(
                              "Your restaurant is currently closed.\nDo you still want to add a person?",
                              style: TextStyle(fontSize: 16, height: 1.4),
                            ),
                            SizedBox(height: 25),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  ),
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(fontSize: 15, color: Colors.black87),
                                  ),
                                ),
                                SizedBox(width: 6),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: Color(0xFFFF6F00),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                  ),
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text(
                                    "Continue",
                                    style: TextStyle(fontSize: 15, color: Colors.white),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );

                  if (proceed != true) return; // user cancel kare → kuch nahi
                }

                // Restaurant open hoy ke user OK kare → Add Dialog open
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
                    Text(
                      DateFormat('MMMM dd, yyyy').format(DateTime.now()), // Current Date
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),

                Row(
                  children: [
                    SizedBox(width: 10),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isRestaurantOpen ? Colors.green : Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () async {
                        bool? newStatus = await AuthService.toggleRestaurantStatus();

                        if (newStatus != null) {
                          setState(() {
                            isRestaurantOpen = newStatus;   // API value thi update
                          });

                          // ✅ Save status globally
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          prefs.setBool("restaurant_open_status", isRestaurantOpen);

                          // Notify HomeScreen to refresh status
                          if (widget.onStatusChanged != null) {
                            widget.onStatusChanged!();
                          }


/*                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isRestaurantOpen ? "Restaurant is now OPEN ✅" : "Restaurant is now CLOSED ❌"),
                              backgroundColor: isRestaurantOpen ? Colors.green : Colors.red,
                            ),
                          );*/
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Status update failed"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },


                      child: Text(
                        isRestaurantOpen ? "We are Open" : "We are Closed",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
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
                                    style: TextStyle(color: Color(0xFFFF6F00),fontWeight: FontWeight.bold),
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

                                        // If user UNCHECK → Cancel pending dine-in timer
                                        if (user.dineInTimer != null) {
                                          user.dineInTimer!.cancel();
                                          user.dineInTimer = null;
                                        }

                                        if (value == true) {
                                          // START Timer
                                          user.dineInTimer = Timer(Duration(seconds: 3), () async {
                                            await ApiService.markDineIn(user.id);
                                            loadUsers();


                                          });

                                          // ✅ SHOW DINE-IN MESSAGE
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text("${user.username} marked as Dine-In ✅"),
                                              backgroundColor: Colors.green,
                                              duration: Duration(seconds: 2),
                                            ),
                                          );

                                        } else {
                                          // Immediately mark waiting
                                          await ApiService.markWaiting(user.id);
                                          loadUsers();

                                          // ✅ SHOW DINE-OUT MESSAGE
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text("${user.username} moved back to Waiting List ❌"),
                                              backgroundColor: Colors.red,
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
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
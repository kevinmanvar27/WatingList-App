import 'package:flutter/material.dart';

class WaitingListScreen extends StatefulWidget {
  const WaitingListScreen({super.key});

  @override
  State<WaitingListScreen> createState() => _WaitingListScreenState();
}

class _WaitingListScreenState extends State<WaitingListScreen> {
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
                backgroundColor: Colors.green,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: const Size(0, 32),
                elevation: 0,
              ),
              child: const Text(
                "We are Open",
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              onPressed: () {
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
                        backgroundColor: Color(0xFFFF6F00),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        _showAddUserDialog(context);
                      },
                      child: const Text("Add Person",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 30),
            // Card Table
            Container(
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

                  // Single User Row (Interactive)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(child: Text("1")),

                        const Expanded(
                          child: Text(
                            "John Doe",
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                        SizedBox(width: 15,),
                        const Expanded(child: Text("5")),

                        // ✅ Checkbox
                        Expanded(
                          child: Checkbox(
                            value: dineInChecked,
                            onChanged: (value) {
                              setState(() {
                                dineInChecked = value!;
                              });
                            },
                            activeColor: Color(0xFFFF6F00),
                          ),
                        ),


                        // ✅ Call Button
                        Expanded(
                          child: IconButton(
                            icon: const Icon(Icons.call),
                            color: Colors.green,
                            onPressed: () {
                              // Call action
                            },
                          ),
                        ),

                        // ✅ Delete Button
                        Expanded(
                          child: IconButton(
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () {
                              // Delete action
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
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
                SizedBox(height: 25),

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
                        onPressed: () {
                          Navigator.pop(context);
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
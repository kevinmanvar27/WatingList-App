import 'package:flutter/material.dart';

class SubscriptionFeatureScreen extends StatelessWidget {
  const SubscriptionFeatureScreen({super.key});

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
                backgroundColor: Colors.red,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: const Size(0, 32),
                elevation: 0,
              ),
              child: const Text(
                "We are Close",
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              onPressed: () {
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 460,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  // 🔒 Lock Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.lock, size: 30, color: Colors.orange.shade600),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "Waiting List Management",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Manage your restaurant’s waiting list with advanced features like person count tracking and real-time status updates.",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),


                  const SizedBox(height: 22),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B00),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        //Navigator.push(context, MaterialPageRoute(builder: (context)=>SubscriptionPlansScreen()));
                      },
                      child: const Text(
                        "View Subscription Plans",
                        style: TextStyle(fontSize: 15, color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    "Available Plans:",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Premium Plan", style: TextStyle(fontSize: 15)),
                        const Text("₹999", style: TextStyle(fontWeight: FontWeight.bold)),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6B00),
                              padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                            ),
                            onPressed: (){},
                            child: const Text("Buy Now",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),))
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

    );
  }
}

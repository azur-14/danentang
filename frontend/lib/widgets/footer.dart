import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 32),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("HoaLaHe", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text("About Us"),
                  Text("Contact"),
                  Text("Careers"),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Customer Service", style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text("Help Center"),
                  Text("Returns"),
                  Text("Shipping Info"),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Follow Us", style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text("Facebook"),
                  Text("Twitter"),
                  Text("Instagram"),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          Text("© 2025 HoaLaHe. All Rights Reserved.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
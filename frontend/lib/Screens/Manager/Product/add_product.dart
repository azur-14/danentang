import 'package:flutter/material.dart';
import '../../../widgets/Footer/mobile_navigation_bar.dart';

class Add_Product extends StatelessWidget {
  const Add_Product({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NewProductScreen(),
    );
  }
}

class NewProductScreen extends StatefulWidget {
  const NewProductScreen({super.key});

  @override
  _NewProductScreenState createState() => _NewProductScreenState();
}

class _NewProductScreenState extends State<NewProductScreen> {
  String? selectedCategory;
  List<String> categories = ["Danh mục 1", "Danh mục 2", "Danh mục 3"];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: AppBar(
        title: Text("New Product", style: TextStyle(fontWeight: FontWeight.bold)),
        leading: isMobile
            ? IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildInputField("Tên Sản Phẩm"),
              buildInputField("Mã Số Sản Phẩm"),
              buildInputField("Số Lô Sản Phẩm"),
              buildInputField("Dòng Máy / Chip / RAM"),
              buildInputField("Màu Sắc"),
              buildDropdownField("Danh Mục Sản Phẩm"),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text("Lưu", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: isMobile
          ? MobileNavigationBar(
        selectedIndex: 0,
        onItemTapped: (index) {
          print("Tapped on item: $index");
        },
        isLoggedIn: true,
        role:'manager',
      )
          : null,
    );
  }

  Widget buildInputField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        TextField(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[300],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
        ),
        SizedBox(height: 15),
      ],
    );
  }

  Widget buildDropdownField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedCategory,
              hint: Text("Chọn danh mục"),
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down),
              items: categories.map((String category) {
                return DropdownMenuItem<String>(value: category, child: Text(category));
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedCategory = newValue;
                });
              },
            ),
          ),
        ),
        SizedBox(height: 15),
      ],
    );
  }
}
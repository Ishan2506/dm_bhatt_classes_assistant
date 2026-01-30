import 'package:dm_bhatt_classes_new/screen/admin/admin_explore_screen.dart';
import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminProductHistoryScreen extends StatefulWidget {
  const AdminProductHistoryScreen({super.key});

  @override
  State<AdminProductHistoryScreen> createState() => _AdminProductHistoryScreenState();
}

class _AdminProductHistoryScreenState extends State<AdminProductHistoryScreen> {
  // Mock Data
  final List<Map<String, dynamic>> _products = [
    {
      "id": "1",
      "name": "Maths Formula Book",
      "category": "Books",
      "price": "150",
      "originalPrice": "200",
      "image": "assets/images/book_placeholder.png"
    },
    {
      "id": "2",
      "name": "Science NCERT Guide",
      "category": "Books",
      "price": "250",
      "originalPrice": "300",
      "image": "assets/images/book_placeholder.png"
    },
    {
      "id": "3",
      "name": "Geometry Box",
      "category": "Stationery",
      "price": "100",
      "originalPrice": "120",
      "image": "assets/images/stationery_placeholder.png"
    },
    {
      "id": "4",
      "name": "Graph Papers (Pack of 50)",
      "category": "Stationery",
      "price": "50",
      "originalPrice": "60",
      "image": "assets/images/stationery_placeholder.png"
    },
    {
      "id": "5",
      "name": "Physics Diagrams",
      "category": "Diagram",
      "price": "80",
      "originalPrice": "100",
      "image": "assets/images/diagram_placeholder.png"
    },
  ];

  void _deleteProduct(String id) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: theme.cardColor,
        title: Row(
          children: [
             Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.delete_outline, color: Colors.red.shade900, size: 24),
            ),
            const SizedBox(width: 12),
             Text(
              "Delete Product",
               style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 18,
              ),
            ),
          ],
        ),
         content: Text(
          "Are you sure you want to delete this product?",
           style: GoogleFonts.poppins(
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            fontSize: 14,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              foregroundColor: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            child: Text("Cancel", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _products.removeWhere((element) => element['id'] == id);
              });
              CustomToast.showSuccess(context, "Product Deleted Successfully");
            },
           style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text("Delete", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          )
        ],
      ),
    );
  }

  void _editProduct(Map<String, dynamic> product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminExploreScreen(productToEdit: product),
      ),
    ).then((_) {
      // Refresh list if needed in real app
    });
  }

  Map<String, List<Map<String, dynamic>>> _groupProductsByCategory() {
    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var product in _products) {
      String category = product['category'];
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(product);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedProducts = _groupProductsByCategory();
    final sortedCategories = groupedProducts.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Product History",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade900, Colors.blue.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sortedCategories.length,
        itemBuilder: (context, index) {
          final category = sortedCategories[index];
          final categoryProducts = groupedProducts[category]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
                child: Text(
                  category,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ),
              ...categoryProducts.map((product) => Card(
                elevation: 0,
                color: Colors.grey.shade50,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                  title: Text(
                    product['name'],
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    "₹${product['price']}",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.green),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editProduct(product),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteProduct(product['id']),
                      ),
                    ],
                  ),
                ),
              )),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}

import 'dart:convert';
import 'package:dm_bhatt_classes_new/network/api_service.dart';
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
  List<dynamic> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final response = await ApiService.getExploreProducts();
      if (response.statusCode == 200) {
        setState(() {
          _products = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        CustomToast.showError(context, "Failed to load products");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      CustomToast.showError(context, "Error: $e");
    }
  }

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
              ApiService.deleteExploreProduct(id).then((response) {
                 if (response.statusCode == 200) {
                   setState(() {
                    _products.removeWhere((element) => element['_id'] == id);
                   });
                   CustomToast.showSuccess(context, "Product Deleted Successfully");
                 } else {
                    CustomToast.showError(context, "Failed to delete product");
                 }
              }).catchError((e) {
                 CustomToast.showError(context, "Error: $e");
              });
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
      _fetchProducts(); // Refresh list after edit
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
                      image: product['image'] != null && product['image'].isNotEmpty 
                        ? DecorationImage(
                            image: NetworkImage(product['image']),
                            fit: BoxFit.cover,
                          ) 
                        : null,
                    ),
                    child: product['image'] == null || product['image'].isEmpty 
                      ? const Icon(Icons.image, color: Colors.grey) 
                      : null,
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
                        onPressed: () => _deleteProduct(product['_id']),
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

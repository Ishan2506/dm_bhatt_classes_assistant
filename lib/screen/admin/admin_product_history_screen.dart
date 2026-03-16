import 'dart:convert';
import 'package:dm_bhatt_classes_new/network/api_service.dart';
import 'package:dm_bhatt_classes_new/screen/admin/admin_explore_screen.dart';
import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';
import 'package:dm_bhatt_classes_new/custom_widgets/custom_loader.dart';
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
  final TextEditingController _searchController = TextEditingController();
  String? _filterCategory;

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
              CustomLoader.show(context);
              ApiService.deleteExploreProduct(id).then((response) {
                 if (!mounted) return;
                 CustomLoader.hide(context);
                 if (response.statusCode == 200) {
                   setState(() {
                    _products.removeWhere((element) => element['_id'] == id);
                   });
                   CustomToast.showSuccess(context, "Product Deleted Successfully");
                 } else {
                    CustomToast.showError(context, "Failed to delete product");
                 }
              }).catchError((e) {
                 if (mounted) CustomLoader.hide(context);
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

  bool _isPdf(String? url) {
    if (url == null || url.isEmpty) return false;
    return url.toLowerCase().split('?').first.endsWith('.pdf');
  }

  Map<String, List<dynamic>> _groupProductsByCategory(List<dynamic> products) {
    final Map<String, List<dynamic>> grouped = {};
    for (final product in products) {
      final category = product['category'] as String? ?? "Uncategorized";
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(product);
    }
    return grouped;
  }

  List<dynamic> _getFilteredProducts() {
    return _products.where((p) {
      final name = (p['name'] ?? "").toString().toLowerCase();
      final query = _searchController.text.toLowerCase();
      final matchesSearch = name.contains(query);
      
      final matchesCategory = _filterCategory == null || p['category'] == _filterCategory;
      
      return matchesSearch && matchesCategory;
    }).toList();
  }

  Widget _buildSearchAndFilterHeader() {
    final categories = _products.map((p) => p['category'] as String?).where((c) => c != null).toSet().cast<String>().toList()..sort();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() {}),
            decoration: InputDecoration(
              hintText: "Search products...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              suffixIcon: _searchController.text.isNotEmpty 
                  ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _searchController.clear()))
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _filterCategory,
            decoration: InputDecoration(
              labelText: "Filter by Category",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.category_outlined),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text("All Categories")),
              ...categories.map((c) => DropdownMenuItem(value: c, child: Text(c))),
            ],
            onChanged: (val) => setState(() => _filterCategory = val),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredProducts();
    final groupedProducts = _groupProductsByCategory(filtered);
    final sortedCategories = groupedProducts.keys.toList()..sort();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Product History",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchAndFilterHeader(),
          Expanded(
            child: _isLoading
              ? const Center(child: CustomLoader())
              : filtered.isEmpty
                ? const Center(child: Text("No products found"))
                : ListView.builder(
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
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ),
                          ...categoryProducts.map((product) {
                            final imageUrl = product['image'] as String?;
                            final isPdf = _isPdf(imageUrl);

                            return Card(
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
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: imageUrl == null || imageUrl.isEmpty
                                      ? const Icon(Icons.image, color: Colors.grey)
                                      : isPdf
                                          ? const Icon(Icons.picture_as_pdf, color: Colors.red)
                                          : Image.network(
                                              imageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) =>
                                                  const Icon(Icons.broken_image, color: Colors.grey),
                                            ),
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
                            );
                          }),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

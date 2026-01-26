import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data for Analytics
    final List<Map<String, dynamic>> subjectSales = [
      {"subject": "Science", "sales": 45000, "percentage": 0.45, "color": Colors.blue},
      {"subject": "Maths", "sales": 32000, "percentage": 0.32, "color": Colors.green},
      {"subject": "English", "sales": 18000, "percentage": 0.18, "color": Colors.orange},
      {"subject": "Gujarati", "sales": 5000, "percentage": 0.05, "color": Colors.purple},
    ];

    final totalSales = subjectSales.fold(0, (sum, item) => sum + (item['sales'] as int));

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          "Admin Dashboard",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Sales Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade800, Colors.blue.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade200,
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                   Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.currency_rupee, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total Sales",
                        style: GoogleFonts.poppins(
                          color: Colors.blue.shade50,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "₹${totalSales.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),

            Text(
              "Sales by Subject",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Bar Chart Visualization (Custom Widget)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Subject Performance", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      Icon(Icons.bar_chart, color: Colors.grey.shade400),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: subjectSales.map((item) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Tooltip(
                             message: "₹${item['sales']}",
                             child: Container(
                              width: 30, // Bar width
                              height: 150.0 * (item['percentage'] as double), // Bar height based on percentage
                              decoration: BoxDecoration(
                                color: item['color'],
                                borderRadius: BorderRadius.circular(8),
                              ),
                                                   ),
                           ),
                          const SizedBox(height: 8),
                          Text(
                            item['subject'], 
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            
            // Detailed List
             Text(
              "Detailed Breakdown",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

             ...subjectSales.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                   border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: item['color'],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        item['subject'],
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      "₹${item['sales']}",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(width: 8),
                     Text(
                      "(${((item['percentage'] as double) * 100).toInt()}%)",
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }),
             SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
          ],
        ),
      ),
    );
  }
}

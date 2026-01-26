import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.blue.shade900;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Help & Support",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
       // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "How to use DM Bhatt Assistant App?",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
             Text(
              "Find step-by-step guides for common tasks below.",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            
            _buildExpansionTile(
              context,
              "How to edit Student Details?",
              Icons.edit,
              [
                "1. Go to the **Dashboard** from the bottom navigation.",
                "2. Tap on the Student card you wish to edit.",
                "3. In the Student Detail view, click the **Edit** icon (pencil) at the top right.",
                "4. Modify the necessary fields (Name, Standard, Stream, etc.).",
                "5. Tap **Save Changes** to update the details."
              ],
              primaryColor,
            ),
            const SizedBox(height: 16),
             _buildExpansionTile(
              context,
              "How to Mark Attendance?",
              Icons.check_circle_outline,
              [
                "1. Navigate to the **Attendance** tab.",
                "2. Select the appropriate **Batch** or **Stream**.",
                "3. You will see a list of students.",
                "4. Tap on 'P' for Present or 'A' for Absent.",
                "5. Tap **Submit** to finalize the attendance for the day."
              ],
              primaryColor,
            ),
             const SizedBox(height: 16),
            _buildExpansionTile(
              context,
              "How to Update Paperset Details?",
              Icons.description_outlined,
              [
                "1. Go to the **Paperset** section.",
                "2. Select the specific exam or test paper.",
                "3. Tap on the **Update Marks** or **Edit Details** button.",
                "4. Enter the obtained marks for each student.",
                "5. Review and click **Save** to publish the results."
              ],
              primaryColor,
            ),

            const SizedBox(height: 40),
            
            Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                   Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(Icons.headset_mic, size: 32, color: primaryColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Need Direct Support?",
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Our support team is available to help you.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                     // Can add url_launcher here for phone call
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: primaryColor.withOpacity(0.2)),
                      ),
                      child: Text(
                        "+91 9106315912",
                        style: GoogleFonts.poppins(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold, 
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
                   const SizedBox(height: 8),
                   Text(
                    "Available 9 AM - 6 PM",
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionTile(BuildContext context, String title, IconData icon, List<String> steps, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
               color: color.withOpacity(0.1),
               borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: steps.map((step) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    step,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ),
      ),
    );
  }
}

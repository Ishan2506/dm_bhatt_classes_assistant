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
              "How to use Padhaku Admin App?",
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
              "How to create an Online Exam?",
              Icons.quiz_outlined,
              [
                "1. Go to the **More** tab and select an Exam type (Regular, One-Liner, or 5-Min Quiz).",
                "2. Select the **Add Exam** tab at the top of the screen.",
                "3. Fill in the header details (Board, Standard, Medium, Marks, Title).",
                "4. Scroll down to add the Questions and their Correct Answers.",
                "5. Tap the **Save** (checkmark) icon at the top right to validate and publish."
              ],
              primaryColor,
            ),
            const SizedBox(height: 16),
            _buildExpansionTile(
              context,
              "How to manage Study Materials?",
              Icons.menu_book_outlined,
              [
                "1. Tap on the **Material** section from the bottom navigation.",
                "2. Use the Board/Standard filters to open a specific folder.",
                "3. Tap the **Add Material** button or the floating plus icon.",
                "4. Select the file, provide a Title and Subject, then confirm the upload.",
                "5. Students in that Standard will immediately see the new document."
              ],
              primaryColor,
            ),
            const SizedBox(height: 16),
            _buildExpansionTile(
              context,
              "How to generate Student Redeem Codes?",
              Icons.qr_code_2_outlined,
              [
                "1. Navigate to the **More** tab and open **Redeem Code**.",
                "2. Pick your target audience (Specific Board/Standard or Individual Student).",
                "3. Enter the exact **Points Value** to be embedded in the code.",
                "4. Tap **Generate PDF** to instantly compile a printable sheet of QR codes.",
                "5. Print and hand the physical codes to students to scan in their app."
              ],
              primaryColor,
            ),
            const SizedBox(height: 16),
            _buildExpansionTile(
              context,
              "How to manage Leaderboards and Gifts?",
              Icons.workspace_premium_outlined,
              [
                "1. Under the **More** section, tap the **Leaderboard** tool.",
                "2. Select the Std and Medium to filter the current top students.",
                "3. Students are ranked automatically based on accumulated points.",
                "4. To mark a student as rewarded, tap the **Give Gift** toggle on their card.",
                "5. The toggle will turn green (**Gifted**) to permanently track the reward state."
              ],
              primaryColor,
            ),
            const SizedBox(height: 16),
            _buildExpansionTile(
              context,
              "How to analyze Exam Reports?",
              Icons.analytics_outlined,
              [
                "1. Open the **More** tab and expand the **Reports** section.",
                "2. Choose the specific exam type report (e.g., One-Liner Report).",
                "3. Use the dynamic **Exam Title** dropdown to instantly isolate a single test.",
                "4. To export, tap the **Download** icon at the top right.",
                "5. The system will generate an Excel (.xlsx) file containing all student scores."
              ],
              primaryColor,
            ),
            const SizedBox(height: 16),
            _buildExpansionTile(
              context,
              "How are Student Reward Points calculated?",
              Icons.calculate_outlined,
              [
                "**1. Exam Scores:** Students earn 1 Reward Point for every 10 Marks successfully scored in an exam (e.g., 50 Marks = 5 Points).",
                "**2. Refer & Earn (App Sharing):** Students unlock massive bonuses by inviting friends using their Referral Code.",
                "   - 1st Invited Friend = 500 Points",
                "   - 2nd Invited Friend = 1,000 Points",
                "   - 3rd Invited Friend = 1,500 Points",
                "   - 4th Invited Friend = 2,000 Points",
                "   - 5th Invited Friend (Max Limit) = 2,500 Points",
                "**3. Redemption:** Students can spend these points to discount Premium App Plans, or Administrators can manually reward high-scoring students via the Leaderboard.",
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

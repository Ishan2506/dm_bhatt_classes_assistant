import 'package:dm_bhatt_classes_new/constant/app_images.dart';
import 'package:dm_bhatt_classes_new/screen/Dashboard/student_home_screen.dart';
import 'package:dm_bhatt_classes_new/screen/admin/admin_home_screen.dart';
import 'package:dm_bhatt_classes_new/screen/assistant/assistant_home_screen.dart';
import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  final String role;
  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late String _selectedRole;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.role;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                   const SizedBox(height: 20),
                  // Logo
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      imgDmBhattClassesLogo,
                      height: MediaQuery.of(context).size.height * 0.12,
                      width: MediaQuery.of(context).size.height * 0.12,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  Text(
                    "Hey $_selectedRole,",
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
                  ),
                  Text(
                    "Welcome Back",
                    style: GoogleFonts.poppins(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.black87
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),

                  // Phone Number Field
                  _buildTextField(
                    controller: _phoneController,
                    hint: "Phone Number", 
                    icon: Icons.phone_outlined, 
                    inputType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter phone number';
                      }
                      if (value.length != 10) {
                        return 'Phone number must be 10 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  _buildTextField(
                    controller: _passwordController,
                    hint: "Password",
                    icon: Icons.lock_outline,
                    isPassword: true,
                    isVisible: _isPasswordVisible,
                    onVisibilityChanged: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "Forgot your password?",
                      style: GoogleFonts.poppins(
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.07,
                    child: ElevatedButton(
                      onPressed: () {
                          if (_formKey.currentState!.validate()) {
                          CustomToast.showSuccess(context, "$_selectedRole Login Successful");
                          
                          Widget targetScreen;

                          if (_selectedRole == "Admin") {
                            targetScreen = const AdminHomeScreen();
                          } else if (_selectedRole == "Assistant") {
                            targetScreen = const AssistantHomeScreen();
                          } else {
                            targetScreen = const StudentHomeScreen();
                          }

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => targetScreen),
                            (route) => false,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(color: Colors.black12),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        "Login as $_selectedRole",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
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

  Widget _buildTextField({
    required String hint, 
    required IconData icon, 
    TextEditingController? controller,
    bool isPassword = false, 
    bool isVisible = false,
    VoidCallback? onVisibilityChanged,
    TextInputType inputType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && !isVisible,
        keyboardType: inputType,
        inputFormatters: inputFormatters,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: Colors.grey),
          prefixIcon: Icon(icon, color: Colors.black54),
          suffixIcon: isPassword 
              ? IconButton(
                  icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                  onPressed: onVisibilityChanged,
                ) 
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:dm_bhatt_classes_new/utils/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _parentPhoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _schoolNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // Selection States
  String? _selectedStandard;
  String? _selectedMedium;
  String? _selectedStream;
  String? _selectedState = "Gujarat";

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

   // Data Lists
  final List<String> _standards = ["6", "7", "8", "9", "10", "11", "12"];
  final List<String> _mediums = ["English", "Gujarati"];
  final List<String> _streams = ["Science", "Commerce", "General"];
  
  final Map<String, List<String>> _stateCityMap = {
    "Gujarat": ["Ahmedabad", "Surat", "Vadodara", "Rajkot"],
    "Maharashtra": ["Mumbai", "Pune", "Nagpur", "Nashik"],
    "Rajasthan": ["Jaipur", "Udaipur", "Jodhpur", "Kota"],
  };

  // Mock History
  final List<Map<String, String>> _history = [
    {"name": "Devarsh Shah", "std": "12", "stream": "Science", "date": "25 Jan 2024"},
    {"name": "Rahul Verma", "std": "10", "stream": "-", "date": "22 Jan 2024"},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _parentPhoneController.dispose();
    _cityController.dispose();
    _schoolNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<List<String>> _fetchSchools(String query) async {
    final cityToSearch = _cityController.text.isNotEmpty ? _cityController.text : "Ahmedabad";
    if (query.isEmpty) return [];
    
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query+school+in+$cityToSearch&format=json&limit=5');
    
    try {
      final response = await http.get(url, headers: {
        'User-Agent': 'DMBhattClasses/1.0', 
      });

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map<String>((e) => e['display_name'] as String).toList();
      }
    } catch (e) {
      debugPrint("Error fetching schools: $e");
    }
    return [];
  }

  Future<void> _pickImage() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        setState(() {
          _imageFile = File(photo.path);
        });
      }
    } catch (e) {
      CustomToast.showError(context, "Error: $e");
    }
  }

  void _createStudent() {
      if (_formKey.currentState!.validate()) {
        CustomToast.showSuccess(context, 'Student Added Successfully');
        // Clear form
        _nameController.clear();
        _phoneController.clear();
        _parentPhoneController.clear();
        _schoolNameController.clear();
        _addressController.clear();
        setState(() {
          _imageFile = null;
          _selectedStandard = null;
          _selectedMedium = null;
          _selectedStream = null;
        });
      }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "Manage Student",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          elevation: 0,
          bottom: const TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "Create New"),
              Tab(text: "History"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Create Form
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Profile Image
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              backgroundImage: _imageFile != null 
                                  ? FileImage(_imageFile!) 
                                  : const AssetImage("assets/images/user_placeholder.png") as ImageProvider,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade700,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Name
                    _buildTextField(
                      controller: _nameController,
                      hint: "Name", 
                      icon: Icons.person_outline,
                      validator: (val) => val!.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 16),

                    // Phone
                    _buildTextField(
                      controller: _phoneController,
                      hint: "Phone Number", 
                      icon: Icons.phone_outlined, 
                      inputType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                      validator: (val) => val!.length != 10 ? "Invalid phone" : null,
                    ),
                    const SizedBox(height: 16),

                    // Parent's Mobile
                    _buildTextField(
                      controller: _parentPhoneController,
                      hint: "Parent's Mobile Number", 
                      icon: Icons.family_restroom_outlined, 
                      inputType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                       validator: (val) => val!.length != 10 ? "Invalid phone" : null,
                    ),
                    const SizedBox(height: 16),

                    _buildDropdown(
                      hint: "Standard",
                      icon: Icons.school_outlined,
                      value: _selectedStandard,
                      items: _standards,
                      onChanged: (val) => setState(() => _selectedStandard = val),
                    ),
                    const SizedBox(height: 16),

                    _buildDropdown(
                      hint: "Medium",
                      icon: Icons.language,
                      value: _selectedMedium,
                      items: _mediums,
                      onChanged: (val) => setState(() => _selectedMedium = val),
                    ),
                     const SizedBox(height: 16),
                     
                     if (_selectedStandard == "11" || _selectedStandard == "12") ...[
                       _buildDropdown(
                        hint: "Stream",
                        icon: Icons.science_outlined,
                        value: _selectedStream,
                        items: _streams,
                        onChanged: (val) => setState(() => _selectedStream = val),
                      ),
                      const SizedBox(height: 16),
                     ],

                    _buildDropdown(
                      hint: "State",
                      icon: Icons.map_outlined,
                      value: _selectedState,
                      items: _stateCityMap.keys.toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedState = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                     _buildTextField(
                      controller: _cityController,
                      hint: "City",
                      icon: Icons.location_city,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _addressController,
                      hint: "Address",
                      icon: Icons.home_outlined,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // School Name
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text == '') {
                              return const Iterable<String>.empty();
                            }
                            return _fetchSchools(textEditingValue.text);
                          },
                          onSelected: (String selection) {
                            _schoolNameController.text = selection;
                          },
                          fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                             textEditingController.addListener(() {
                                _schoolNameController.text = textEditingController.text;
                             });
                            
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: TextFormField(
                                controller: textEditingController,
                                focusNode: focusNode,
                                 validator: (val) => val == null || val.isEmpty ? "Required" : null,
                                style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold), 
                                decoration: InputDecoration(
                                  hintText: "School Name",
                                  hintStyle: GoogleFonts.poppins(color: Colors.grey),
                                  prefixIcon: const Icon(Icons.school_outlined, color: Colors.black54),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                ),
                              ),
                            );
                          },
                          optionsViewBuilder: (context, onSelected, options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4.0,
                                 borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: constraints.maxWidth,
                                  color: Colors.white,
                                  constraints: const BoxConstraints(maxHeight: 200),
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      final String option = options.elementAt(index);
                                      final displayName = option.split(',')[0]; 
                                      return InkWell(
                                        onTap: () => onSelected(option),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Text(displayName, style: GoogleFonts.poppins(color: Colors.black87)),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _createStudent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade900,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          "Add Student",
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
            ),
            
            // Tab 2: History
             ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final item = _history[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0,
                   color: Colors.grey.shade50,
                   shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                  child: ListTile(
                    leading: CircleAvatar(
                       backgroundColor: Colors.blue.shade100,
                       child: Text(item['name']![0], style: TextStyle(color: Colors.blue.shade900)),
                    ),
                    title: Text(item['name']!, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    subtitle: Text("Std: ${item['std']} ${item['stream']} • ${item['date']}", style: GoogleFonts.poppins(fontSize: 12)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  ),
                );
              },
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
    TextInputType inputType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        inputFormatters: inputFormatters,
        validator: validator,
        maxLines: maxLines,
        style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold), 
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: Colors.grey),
          prefixIcon: Icon(icon, color: Colors.black54),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required IconData icon,
    required String? value,
    required List<String> items,
    required Function(String?)? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Row(
            children: [
              Icon(icon, color: Colors.black54),
              const SizedBox(width: 12),
              Text(hint, style: GoogleFonts.poppins(color: Colors.grey)),
            ],
          ),
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          dropdownColor: Colors.white, 
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

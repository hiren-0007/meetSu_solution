import 'package:flutter/material.dart';
import 'package:meetsu_solutions/clint/c_screen/c_more/c_profile/clint_profile_controller.dart';
import 'package:meetsu_solutions/utils/theme/app_theme.dart';

class ClientProfileScreen extends StatefulWidget {
  const ClientProfileScreen({Key? key}) : super(key: key);

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  final ClientProfileController _controller = ClientProfileController();
  final List<String> _profileOptions = [
    'Contact Details',
    'Address Details',
    'Company Details'
  ];
  String _selectedOption = 'Contact Details';

  @override
  void initState() {
    super.initState();
    _controller.loadProfileData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateSelectedOption(String option) {
    setState(() {
      _selectedOption = option;
      switch (option) {
        case 'Contact Details':
          _controller.setSelectedTab(TabType.contact);
          break;
        case 'Address Details':
          _controller.setSelectedTab(TabType.address);
          break;
        case 'Company Details':
          _controller.setSelectedTab(TabType.company);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryClintColor,
      body: SafeArea(
        child: Column(
          children: [
            // Title Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo in left corner
                  Container(
                    height: 35,
                    width: 35,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  // Profile text in center
                  const Text(
                    "Profile",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  // Empty SizedBox to balance the layout
                  const SizedBox(width: 35),
                ],
              ),
            ),

            // Expanded section with white background
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    // User info card
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryClintColor,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                _controller.contactName.isNotEmpty
                                    ? _controller.contactName[0].toUpperCase()
                                    : "U",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _controller.contactName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "MEETsu Solutions",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Text(
                              "Active",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Dropdown for profile options
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.grey.shade200,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DropdownButton<String>(
                        value: _selectedOption,
                        isExpanded: true,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: AppTheme.primaryClintColor,
                        ),
                        iconSize: 24,
                        elevation: 16,
                        underline: Container(height: 0),
                        style: TextStyle(
                          color: AppTheme.primaryClintColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            _updateSelectedOption(newValue);
                          }
                        },
                        items: _profileOptions
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                              child: Text(value),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    // Profile content based on selected option
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: _buildProfileContent(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    switch (_controller.selectedTab) {
      case TabType.contact:
        return _buildContactDetailsContent();
      case TabType.address:
        return _buildAddressDetailsContent();
      case TabType.company:
        return _buildCompanyDetailsContent();
      default:
        return _buildContactDetailsContent();
    }
  }

  Widget _buildContactDetailsContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildInfoViewField(
            label: 'Contact Name',
            value: _controller.contactName,
            icon: Icons.person_outline,
          ),
          _buildInfoViewField(
            label: 'Email',
            value: _controller.email,
            icon: Icons.email_outlined,
          ),
          _buildInfoViewField(
            label: 'Telephone',
            value: _controller.telephone,
            icon: Icons.phone_outlined,
          ),
          _buildInfoViewField(
            label: 'Extension',
            value: _controller.ext,
            icon: Icons.phone_forwarded_outlined,
          ),
          _buildInfoViewField(
            label: 'Alternate Contact',
            value: _controller.alternateContactNo,
            icon: Icons.contact_phone_outlined,
          ),
          _buildInfoViewField(
            label: 'Username',
            value: _controller.username,
            icon: Icons.account_circle_outlined,
          ),
          _buildInfoViewField(
            label: 'Fax',
            value: _controller.fax,
            icon: Icons.print_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressDetailsContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildInfoViewField(
            label: 'Address',
            value: _controller.address,
            icon: Icons.home_outlined,
          ),
          _buildInfoViewField(
            label: 'Address 2',
            value: _controller.address2,
            icon: Icons.home_work_outlined,
          ),
          _buildInfoViewField(
            label: 'Country',
            value: _controller.country,
            icon: Icons.public_outlined,
          ),
          _buildInfoViewField(
            label: 'Province',
            value: _controller.province,
            icon: Icons.location_city_outlined,
          ),
          _buildInfoViewField(
            label: 'City',
            value: _controller.city,
            icon: Icons.location_on_outlined,
          ),
          _buildInfoViewField(
            label: 'Postal Code',
            value: _controller.postalCode,
            icon: Icons.markunread_mailbox_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyDetailsContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildInfoViewField(
            label: 'Company Name',
            value: _controller.companyName,
            icon: Icons.business_outlined,
          ),
          _buildInfoViewField(
            label: 'Short Name',
            value: _controller.shortName,
            icon: Icons.short_text_outlined,
          ),
          _buildInfoViewField(
            label: 'Email',
            value: _controller.companyEmail,
            icon: Icons.email_outlined,
          ),
          _buildInfoViewField(
            label: 'Telephone',
            value: _controller.companyTelephone,
            icon: Icons.phone_outlined,
          ),
          _buildInfoViewField(
            label: 'Contact Name',
            value: _controller.companyContactName,
            icon: Icons.person_outline,
          ),
          _buildInfoViewField(
            label: 'Fax',
            value: _controller.companyFax,
            icon: Icons.print_outlined,
          ),
          if (_controller.companyLogo.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Company Logo',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    width: 150,
                    height: 150,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade200,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Image.network(
                      _controller.companyLogo,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildInfoViewField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    // If value is empty, use a placeholder
    final displayValue = value.isEmpty ? '-' : value;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 10, bottom: 4),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppTheme.primaryClintColor,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  displayValue,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (label == 'Contact Name' || label == 'Email' || label == 'Telephone')
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.deepPurple,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
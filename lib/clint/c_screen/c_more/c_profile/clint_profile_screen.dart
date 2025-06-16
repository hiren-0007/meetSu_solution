import 'package:flutter/material.dart';
import 'package:meetsu_solutions/clint/c_screen/c_more/c_profile/clint_profile_controller.dart';
import 'package:meetsu_solutions/utils/theme/app_theme.dart';

class ClientProfileScreen extends StatefulWidget {
  const ClientProfileScreen({Key? key}) : super(key: key);

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  late final ClientProfileController _controller;

  final Map<String, ProfileTab> _tabMapping = {
    'Contact Details': ProfileTab.contact,
    'Address Details': ProfileTab.address,
    'Company Details': ProfileTab.company,
  };

  String _selectedOption = 'Contact Details';
  bool _isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = ClientProfileController();
    _controller.addListener(_onControllerChange);
    _loadProfile();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChange);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerChange() {
    if (mounted) setState(() {});
  }

  Future<void> _loadProfile() async {
    await _controller.loadProfileData();
  }

  void _updateSelectedOption(String? option) {
    if (option != null && option != _selectedOption) {
      setState(() {
        _selectedOption = option;
        _isDropdownOpen = false;
        _controller.setSelectedTab(_tabMapping[option]!);
      });
    }
  }

  void _toggleDropdown() {
    setState(() {
      _isDropdownOpen = !_isDropdownOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryClintColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    _buildUserCard(),
                    _buildTabSelector(),
                    Expanded(child: _buildContent()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          _buildLogo(),
          const Expanded(
            child: Center(
              child: Text(
                "Profile",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 35),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      height: 35,
      width: 35,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildUserCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildAvatar(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _controller.contactName.isEmpty ? "Loading..." : _controller.contactName,
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
          _buildStatusBadge(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
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
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Text(
        "Active",
        style: TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          GestureDetector(
            onTap: _toggleDropdown,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedOption,
                    style: TextStyle(
                      color: AppTheme.primaryClintColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isDropdownOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppTheme.primaryClintColor,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: _isDropdownOpen ? null : 0,
            child: _isDropdownOpen
                ? Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: _tabMapping.keys
                    .where((option) => option != _selectedOption)
                    .map((option) => GestureDetector(
                  onTap: () => _updateSelectedOption(option),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ))
                    .toList(),
              ),
            )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.errorMessage != null) {
      return _buildErrorWidget();
    }

    if (!_controller.hasData) {
      return const Center(child: Text("No profile data available"));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: _buildTabContent(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            _controller.errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadProfile,
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_controller.selectedTab) {
      case ProfileTab.contact:
        return _buildContactDetails();
      case ProfileTab.address:
        return _buildAddressDetails();
      case ProfileTab.company:
        return _buildCompanyDetails();
    }
  }

  Widget _buildContactDetails() {
    final fields = [
      ('Contact Name', _controller.contactName, Icons.person_outline),
      ('Email', _controller.email, Icons.email_outlined),
      ('Telephone', _controller.telephone, Icons.phone_outlined),
      ('Extension', _controller.ext, Icons.phone_forwarded_outlined),
      ('Alternate Contact', _controller.alternateContactNo, Icons.contact_phone_outlined),
      ('Username', _controller.username, Icons.account_circle_outlined),
      ('Fax', _controller.fax, Icons.print_outlined),
    ];

    return _buildFieldsList(fields);
  }

  Widget _buildAddressDetails() {
    final fields = [
      ('Address', _controller.address, Icons.home_outlined),
      ('Address 2', _controller.address2, Icons.home_work_outlined),
      ('Country', _controller.country, Icons.public_outlined),
      ('Province', _controller.province, Icons.location_city_outlined),
      ('City', _controller.city, Icons.location_on_outlined),
      ('Postal Code', _controller.postalCode, Icons.markunread_mailbox_outlined),
    ];

    return _buildFieldsList(fields);
  }

  Widget _buildCompanyDetails() {
    final fields = [
      ('Company Name', _controller.companyName, Icons.business_outlined),
      ('Short Name', _controller.shortName, Icons.short_text_outlined),
      ('Email', _controller.companyEmail, Icons.email_outlined),
      ('Telephone', _controller.companyTelephone, Icons.phone_outlined),
      ('Contact Name', _controller.companyContactName, Icons.person_outline),
      ('Fax', _controller.companyFax, Icons.print_outlined),
    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          ..._buildFieldWidgets(fields),
          if (_controller.companyLogo.isNotEmpty) _buildCompanyLogo(),
        ],
      ),
    );
  }

  List<Widget> _buildFieldWidgets(List<(String, String, IconData)> fields) {
    return fields
        .map((field) => _buildInfoField(
      label: field.$1,
      value: field.$2,
      icon: field.$3,
    ))
        .toList();
  }

  Widget _buildFieldsList(List<(String, String, IconData)> fields) {
    return SingleChildScrollView(
      child: Column(
        children: _buildFieldWidgets(fields),
      ),
    );
  }

  Widget _buildInfoField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final displayValue = value.isEmpty ? '-' : value;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 12, bottom: 4),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.primaryClintColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    displayValue,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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

  Widget _buildCompanyLogo() {
    return Column(
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
            width: 120,
            height: 120,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                _controller.companyLogo,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.business,
                    size: 48,
                    color: Colors.grey[400],
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
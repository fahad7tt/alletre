import 'package:alletre_app/controller/providers/tab_index_provider.dart';
import 'package:alletre_app/controller/providers/login_state.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/widgets/common%20widgets/footer_elements_appbar.dart';
import 'package:alletre_app/view/widgets/settings%20widgets/settings_list_tile.dart';
import 'package:alletre_app/view/widgets/settings%20widgets/settings_section_title.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../contact screen/contact_screen.dart';
import '../user terms screen/user_terms.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<String> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return 'Version ${packageInfo.version}';
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    // Show dialog
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevents dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout',
              style: TextStyle(fontWeight: FontWeight.w500)),
          content: const Text('Do you want to logout?',
              style: TextStyle(
                  color: onSecondaryColor, fontWeight: FontWeight.w500)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(fontSize: 12)),
            ),
            TextButton(
              onPressed: () {
                // Log out the user
                context.read<LoggedInProvider>().logOut();
                // Navigate using TabIndexProvider
                context
                    .read<TabIndexProvider>()
                    .updateIndex(2); // Index for LoginPage
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Logout', style: TextStyle(fontSize: 12)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NavbarElementsAppbar(appBarTitle: 'Settings', showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SettingsSectionTitle(title: 'General'),
            SettingsListTile(
              title: 'Theme',
              subtitle: 'Use the theme set in your device settings',
              onTap: () {},
            ),
            SettingsListTile(
              title: 'Country',
              subtitle: 'United Arab Emirates',
              onTap: () {},
            ),
            SettingsListTile(
              title: 'Clear search history',
              onTap: () {},
            ),
            Divider(color: dividerColor, thickness: 0.5),
            const SettingsSectionTitle(title: 'Support'),
            SettingsListTile(
              title: 'Contact us',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactUsScreen()));
              },
            ),
            SettingsListTile(
              title: 'Terms and Conditions',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsAndConditions()));
              },
            ),
            Divider(color: dividerColor, thickness: 0.5),
            const SettingsSectionTitle(title: 'About'),
            SettingsListTile(
              title: 'Delete account',
              onTap: () {},
            ),
            SettingsListTile(
              title: 'Logout',
              onTap: () {
                _showLogoutDialog(context); // logout confirmation dialog
              },
            ),
            const SizedBox(height: 20),
            FutureBuilder<String>(
              future: _getAppVersion(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading version',
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                    ),
                  );
                } else {
                  return Center(
                    child: Text(
                      snapshot.data!,
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

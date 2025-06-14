import 'package:alletre_app/controller/providers/share_provider.dart';
import 'package:alletre_app/model/user_model.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/widgets/common%20widgets/footer_elements_appbar.dart';
import 'package:alletre_app/view/widgets/profile%20widgets/profile_list_tile.dart';
import 'package:alletre_app/view/widgets/profile%20widgets/profile_section_title.dart';
import 'package:alletre_app/view/widgets/profile%20widgets/user_profile_card.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../edit profile screen/edit_profile_screen.dart';
import '../faqs screen/faqs_screen.dart';
import '../settings screen/settings_screen.dart';
import '../wishlist screen/wishlist_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String? title;
  
  const ProfileScreen({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    final user = UserModel(
      name: "Username",
      email: "email",
      phoneNumber: "+1234567890",
      profileImagePath: null, // Initially empty
    );

    return Scaffold(
      appBar: const NavbarElementsAppbar(appBarTitle: 'Profile'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // _buildSectionTitle('Your updates', context),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //   children: [
            //     _buildQuickActionTile(
            //       title: 'Watchlist',
            //       subtitle: 'Your favorites and lists',
            //       onTap: () {},
            //     ),
            //     _buildQuickActionTile(
            //       title: 'Bids & offers',
            //       subtitle: 'Active auctions and seller offers',
            //       onTap: () {},
            //     ),
            //   ],
            // ),
            const SizedBox(height: 4),
            UserProfileCard(
              user: user,
              buttonText: "Edit Profile",
              onButtonPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
              },
            ),
            const SizedBox(height: 4),
            const ProfileSectionTitle(title: 'Shopping'),
            ProfileListTile(
              icon: Icons.bookmark_outline,
              title: 'Wishlist',
              subtitle: 'Save and track your favorite items',
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => WishlistScreen(
                            title: title ?? '', user: UserModel.empty())));
              },
            ),
            ProfileListTile(
              icon: Icons.sell_outlined,
              title: 'My Auctions',
              subtitle: 'Manage your auction listings',
              onTap: () {},
            ),
            ProfileListTile(
              icon: Icons.gavel,
              title: 'My Bids',
              subtitle: 'Check the status of your bids',
              onTap: () {},
            ),
            ProfileListTile(
              icon: Icons.inventory_2_outlined,
              title: 'My Products',
              subtitle: 'Manage your selling items',
              onTap: () {},
            ),
            ProfileListTile(
              icon: Icons.shopping_cart_outlined,
              title: 'Purchases',
              subtitle: 'View order history and details',
              onTap: () {},
            ),
            ProfileListTile(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Wallet',
              subtitle: 'Check your transaction record',
              onTap: () {},
            ),
            Divider(color: dividerColor, thickness: 0.5),
            const ProfileSectionTitle(title: 'About'),
            ProfileListTile(
              icon: Icons.policy,
              title: 'Privacy Policy',
              subtitle: 'Know how we protect your data',
              onTap: () {
                // Navigator.push(context, MaterialPageRoute(builder: (context) => const FaqScreen()));
              },
            ),
            ProfileListTile(
              icon: Icons.help_outline,
              title: 'FAQs',
              subtitle: 'Know more about the services',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const FaqScreen()));
              },
            ),
            ProfileListTile(
              icon: FontAwesomeIcons.shareFromSquare,
              title: 'Share App',
              subtitle: 'Let your network know about us',
              onTap: () {
                context.read<ShareProvider>().shareApp(context);
              },
            ),
            // ProfileListTile(
            //   icon: Icons.call,
            //   title: 'Contact us',
            //   subtitle: 'Reach out for help',
            //   onTap: () {
            //     context.read<TabIndexProvider>().updateIndex(16);
            //   },
            // ),
            ProfileListTile(
              icon: Icons.settings,
              title: 'Settings',
              subtitle: 'View more settings',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildQuickActionTile({
  //   required String title,
  //   required String subtitle,
  //   required VoidCallback onTap,
  // }) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Container(
  //       width: 160,
  //       padding: const EdgeInsets.all(12.0),
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(8),
  //         color: buttonBgColor,
  //       ),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             title,
  //             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //           ),
  //           const SizedBox(height: 4),
  //           Text(
  //             subtitle,
  //             style: const TextStyle(fontSize: 12, color: Colors.grey),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}

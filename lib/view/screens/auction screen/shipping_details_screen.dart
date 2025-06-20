// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:alletre_app/controller/providers/user_provider.dart';
import 'package:alletre_app/controller/providers/auction_provider.dart';
import 'package:alletre_app/controller/providers/location_provider.dart';
import 'package:alletre_app/controller/providers/login_state.dart';
import 'package:alletre_app/controller/providers/tab_index_provider.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/screens/login%20screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/common widgets/address_card.dart';
import '../../widgets/common widgets/footer_elements_appbar.dart';
import 'add_location_screen.dart';
import 'payment_details_screen.dart';

class ShippingDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> auctionData;
  final List<String> imagePaths;
  final String title;

  const ShippingDetailsScreen({
    super.key,
    required this.auctionData,
    required this.imagePaths,
    this.title = 'Create Auction',
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final locationProvider = Provider.of<LocationProvider>(context);
    final auctionProvider = Provider.of<AuctionProvider>(context);
    final loginProvider = Provider.of<LoggedInProvider>(context);
    final defaultAddress = userProvider.defaultAddress;

    return Scaffold(
      appBar: NavbarElementsAppbar(
          appBarTitle: title, showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.only(left: 14, right: 14, top: 8, bottom: 8),
        child: Column(
          children: [
            const Divider(thickness: 1, color: primaryColor),
            const Center(
              child: Text(
                "Shipping Details",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: onSecondaryColor,
                ),
              ),
            ),
            const Divider(thickness: 1, color: primaryColor),
            const SizedBox(height: 10),

            // List of Address Cards
            Expanded(
              child: ListView(
                children: [
                  // Address Cards
                  Consumer<UserProvider>(
                    builder: (context, userProvider, child) {
                      final addresses = userProvider.addresses;
                      final defaultAddress = userProvider.defaultAddress;

                      // Sort addresses to put default address first
                      final sortedAddresses = [...addresses]..sort((a, b) {
                          if (a == defaultAddress) return -1;
                          if (b == defaultAddress) return 1;
                          return 0;
                        });

                      return Column(
                        children: [
                          for (final address in sortedAddresses)
                            AddressCard(
                              address: address,
                              isDefault: address == defaultAddress,
                              onMakeDefault: () =>
                                  userProvider.setDefaultAddress(address),
                              onEdit: () async {
                                final editedAddress = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AddLocationScreen(),
                                  ),
                                );

                                if (editedAddress != null) {
                                  userProvider.editAddress(
                                      address, editedAddress);
                                }
                              },
                              onDelete: () =>
                                  userProvider.removeAddress(address),
                            ),
                        ],
                      );
                    },
                  ),

                  // Add Address Button
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: InkWell(
                      onTap: () async {
                        final selectedLocation = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddLocationScreen(),
                          ),
                        );

                        if (selectedLocation != null) {
                          userProvider.addAddress(selectedLocation);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add,
                              color: onSecondaryColor,
                              size: 22,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Add Address',
                              style: TextStyle(
                                color: onSecondaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Previous and Create Auction Buttons
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(80, 33),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      backgroundColor: Colors.grey[300],
                    ),
                    child: const Text(
                      "Previous",
                      style: TextStyle(color: onSecondaryColor),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () async {
                      // First check if user is logged in
                      if (!loginProvider.isLoggedIn) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please log in to create an auction'),
                          ),
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                LoginPage(fromAuctionCreation: true),
                          ),
                        );
                        return;
                      }

                      // Check if we have at least one address
                      if (userProvider.addresses.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please add at least one address'),
                          ),
                        );
                        return;
                      }

                      try {
                        // Show loading indicator
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );

                        // Debug log auction data
                        debugPrint('Incoming auction data:');
                        debugPrint('Product data: ${auctionData['product']}');

                        // Ensure product data is properly structured
                        if (auctionData['product'] == null || 
                            auctionData['product'] is! Map<String, dynamic>) {
                          throw Exception('Product data is not properly structured');
                        }

                        // Parse duration and unit
                        String durationStr = auctionData['duration'] ?? '1 DAYS';
                        List<String> durationParts = durationStr.split(' ');
                        int duration = int.parse(durationParts[0]);
                        String durationUnit = durationParts[1].toUpperCase().contains('HR') ? 'HOURS' : 'DAYS';
                        
                        // Parse prices
                        int startBidAmount = (double.parse(auctionData['startingPrice']?.toString() ?? '0')).toInt();
                        double buyNowPrice = double.parse(auctionData['buyNowPrice']?.toString() ?? '0');
                        
                        // Calculate end time based on duration and start time
                        DateTime startTime;
                        if (auctionData['scheduleBid'] == true) {
                            // Parse the ISO string and convert to local time
                            startTime = DateTime.parse(auctionData['startTime'] ?? auctionData['startDate']).toLocal();
                        } else {
                            startTime = DateTime.now();
                        }
                        
                        DateTime endTime;
                        if (durationUnit == 'HOURS') {
                          endTime = startTime.add(Duration(hours: duration));
                        } else {
                          endTime = startTime.add(Duration(days: duration));
                        }

                        // Debug end time calculation
                        debugPrint('Start time: $startTime');
                        debugPrint('Duration: $duration ${durationUnit.toLowerCase()}');
                        debugPrint('Calculated end time: $endTime');

                        // Create the full auction data structure
                        final Map<String, dynamic> fullAuctionData = {
                          'type': auctionData['scheduleBid'] == true ? 'SCHEDULED' : 'ON_TIME',
                          'durationUnit': durationUnit,
                          'duration': duration,
                          'startBidAmount': startBidAmount,
                          'startDate': startTime.toIso8601String(),
                          'endDate': endTime.toIso8601String(), 
                          'scheduleBid': auctionData['scheduleBid'] ?? false,
                          'buyNowEnabled': auctionData['buyNowEnabled'] ?? false,
                          'buyNowPrice': buyNowPrice,
                                                   'product': {
                            ...Map<String, dynamic>.from(
                                auctionData['product']),
                            // Always set ProductListingPrice for backend compatibility
                            'ProductListingPrice': auctionData['product']
                                ['price'],
                            // Add location IDs to product data for backend
                            // Ensure countryId is always 1 for UAE
                            'countryId': 1,
                            // Use cityId from locationProvider, defaulting to 1 (Dubai) if not set
                            'cityId': locationProvider.cityId ?? 1,
                            // Add address and addressLabel for backend DTO
                            'address': defaultAddress ?? '',
                            'addressLabel': 'Main Address',
                          },
                          // 'locationId': locationProvider.selectedLocationId ?? 0,
                          'shippingDetails': {
                            'country':
                                locationProvider.selectedCountry ?? 'UAE',
                            'state': locationProvider.selectedState ??
                                'Ras Al Khaima',
                            'city': locationProvider.selectedCity ?? 'Nakheel',
                            'address': defaultAddress ?? '',
                            'phone': userProvider.phoneNumber,
                          },
                        };

                        // Debug auction data
                        debugPrint('Creating auction with data: ${json.encode(fullAuctionData)}');

                        // Clean and convert product data
                        var productData = fullAuctionData['product'] as Map<String, dynamic>;
                        
                        // Remove null/empty values
                        productData.removeWhere((key, value) => value == null || value == '');
                        
                        // Convert numeric fields
                        if (productData['categoryId'] != null) {
                          productData['categoryId'] = int.parse(productData['categoryId'].toString());
                        }
                        if (productData['subCategoryId'] != null) {
                          productData['subCategoryId'] = int.parse(productData['subCategoryId'].toString());
                        }
                        if (productData['quantity'] != null) {
                          productData['quantity'] = int.parse(productData['quantity'].toString());
                        }
                        fullAuctionData['product'] = productData;

                        // Validate product data structure
                        final product = fullAuctionData['product'] as Map<String, dynamic>;
                        if (!product.containsKey('title') || !product.containsKey('description') ||
                            !product.containsKey('categoryId') || !product.containsKey('subCategoryId')) {
                          throw Exception('Product data missing required fields');
                        }

                        // Add optional policies if present
                        if (auctionData['returnPolicy'] != null) {
                          fullAuctionData['returnPolicy'] = auctionData['returnPolicy'];
                        }
                        if (auctionData['warrantyPolicy'] != null) {
                          fullAuctionData['warrantyPolicy'] = auctionData['warrantyPolicy'];
                        }

                        // Debug log the final structure
                        debugPrint('Final auction data structure:');
                        debugPrint(fullAuctionData.toString());

                        // Debug log media files
                        debugPrint('ShippingDetailsScreen - Media files before API call:');
                        debugPrint('Total files: ${imagePaths.length}');
                        for (var i = 0; i < imagePaths.length; i++) {
                          final path = imagePaths[i];
                          final isVideo = path.toLowerCase().endsWith('.mp4') || path.toLowerCase().endsWith('.mov');
                          debugPrint('  File $i: $path');
                          debugPrint('    Type: ${isVideo ? 'Video' : 'Image'}');
                          final file = File(path);
                          if (await file.exists()) {
                            debugPrint('    Size: ${(await file.length() / 1024).toStringAsFixed(2)} KB');
                            debugPrint('    Exists: Yes');
                          } else {
                            debugPrint('    Exists: No');
                          }
                        }

                        // Create auction with image paths
                        debugPrint('Creating auction with data: $fullAuctionData');
                        debugPrint('End time before API call: ${endTime.toIso8601String()}');
                        
                        // Debug the auction data before API call
                        debugPrint('Full auction data before API call:');
                        debugPrint(json.encode(fullAuctionData));

                        final response = title == 'Create Auction'
                            ? await auctionProvider.createAuction(
                                auctionData: fullAuctionData,
                                imagePaths: imagePaths,
                              )
                            : await auctionProvider.listProduct(
                                auctionData: fullAuctionData,
                                imagePaths: imagePaths,
                              );
                        
                        debugPrint('API Response: $response');

                        // Hide loading indicator
                        if (context.mounted) {
                          Navigator.pop(context);
                        }

                        if (response['success'] == true) {
                          // Show success message
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Center(child: Text('Item created successfully')),
                              ),
                            );
                          }

                          // Debug the data before navigation
                          debugPrint('Shipping Screen - Full auction data: $fullAuctionData');
                          debugPrint('Shipping Screen - API Response: $response');
                          debugPrint('Shipping Screen - End time: ${endTime.toIso8601String()}');
                          final navigationData = {
                            'success': response['success'],
                            'data': {
                              ...response['data'],
                              'endTime': endTime.toIso8601String(),
                              ...fullAuctionData,
                              'ProductListingPrice': fullAuctionData['product']
                                  ['price'],
                              'product': {
                                ...fullAuctionData['product'],
                                'images': imagePaths,
                              },
                            }
                          };
                          debugPrint('Shipping Screen - Navigation data: $navigationData');
                          
                          // Print item details
                          print('🔦🔦New Item Created:');
                          print('🔦🔦Item Name: ${auctionData['product']['title']}');
                          print('🔦🔦Status: ${response['status']}');
                          // Use ProductListingPrice for listed products, fallback to product price
                          final listingPrice = navigationData['data']
                                  ['ProductListingPrice'] ??
                              navigationData['data']['product']['price'];
                          print('🔦🔦Listing Price: $listingPrice');

                          if (context.mounted) {
                            if (title == 'Create Auction') {
                              // Navigate to payment details for auctions
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PaymentDetailsScreen(
                                    auctionData: navigationData,
                                  ),
                                ),
                              );
                            } else {
                              // Show success dialog for listed products
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.check_circle_outline,
                                        color: activeColor,
                                        size: 60,
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Success!',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: onSecondaryColor
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Your item ${auctionData['product']['title']} has been listed successfully.',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            color: onSecondaryColor),
                                      ),
                                      Text(
                                        'Listing Price: $listingPrice AED',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: onSecondaryColor),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context); // Close dialog
                                        // Navigate to home and update tab index
                                        context.read<TabIndexProvider>().updateIndex(1);
                                        // Pop until home
                                        Navigator.popUntil(
                                          context,
                                          (route) => route.isFirst,
                                        );
                                      },
                                      child: const Text('View My Products'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          }
                        } else {
                          throw Exception(response['message'] ?? 'Failed to create auction');
                        }
                      } catch (e) {
                        // Hide loading indicator
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);

                        // Show error message
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to create auction: $e'),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(50, 33),
                      maximumSize: const Size(130, 33),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: Text(
                      title,
                      style: const TextStyle(color: secondaryColor),
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
}

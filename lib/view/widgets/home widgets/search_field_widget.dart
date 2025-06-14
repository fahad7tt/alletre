import 'package:alletre_app/controller/providers/auction_provider.dart';
import 'package:alletre_app/controller/providers/tab_index_provider.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchFieldWidget extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final IconData leadingIcon;
  final VoidCallback? onLeadingIconPressed;
  final bool isNavigable;
  final VoidCallback? onFilterPressed; // Callback for filter button

  const SearchFieldWidget({
    super.key,
    this.onChanged,
    this.autofocus = false,
    this.leadingIcon = Icons.search, // Default to search icon
    this.onLeadingIconPressed,
    this.isNavigable = false, // flag for navigation behavior
    this.onFilterPressed // function to handle filter button press
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isNavigable
          ? () {
              // Navigates to SearchScreen when tapped
              context.read<TabIndexProvider>().updateIndex(13);
            }
          : null,
      child: AbsorbPointer(
        absorbing: isNavigable, // Prevents user from typing directly
        child: Padding(
          padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
          child: TextField(
            autofocus: autofocus,
             onChanged: (value) {
    context.read<AuctionProvider>().searchItems(value);
  },
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              hintText: 'Search on Alletre',
              hintStyle: Theme.of(context).textTheme.displayMedium,
              prefixIcon: IconButton(
                icon: Icon(leadingIcon),
                onPressed: onLeadingIconPressed, // Handles back button press
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.filter_list), // Filter icon
                onPressed: onFilterPressed, // Triggers the filter action
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 11),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: onSecondaryColor),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: primaryColor),
              ),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:alletre_app/view/auction%20screen/create_auction_screen.dart';
import 'package:alletre_app/view/home%20screen/home_screen.dart';
import 'package:alletre_app/view/onboarding%20screens/onboarding_pages.dart';
import 'package:alletre_app/view/onboarding%20screens/onboarding_screen3.dart';
import 'package:alletre_app/view/search%20screen/search_screen.dart';
import 'package:alletre_app/view/splash%20screen/splash_screen.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  // Defining named routes
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String onboarding3 = '/onboarding3';
  static const String home = '/home';
  static const String createAuction = '/createAuction';
  static const String search = '/search';

  // Static method to define all the routes in one place
  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
      onboarding: (context) => const OnboardingPages(),
      onboarding3: (context) {
  final PageController pageController = PageController();
  return OnboardingPage3(pageController: pageController);
},

      home: (context) => const HomeScreen(),
      createAuction: (context) => const CreateAuctionScreen(),
      search: (context) => const SearchScreen()
    };
  }
}
import 'package:alletre_app/controller/providers/auction_provider.dart';
import 'package:alletre_app/utils/theme/app_theme.dart';
import 'package:alletre_app/view/splash%20screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuctionProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Alletre',
        theme: customTheme(),
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}
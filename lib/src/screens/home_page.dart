import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../services/app_image_provider.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home';

  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushNamed(context, LoginPage.routeName,
          arguments: true); // Pass true to indicate it is @startup
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: SvgPicture.asset(AppImageProvider.mainbackground)),
    );
  }
}
// to load image (not svg type): Image.asset('path/to/company/image.png')),
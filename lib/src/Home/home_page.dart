// to load image (not svg type): Image.asset('path/to/company/image.png')),
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../services/app_image_paths.dart';

class HomePage extends StatelessWidget {
  static const routeName = '/home';

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: SvgPicture.asset(AppImagePaths.mainbackground)),
    );
  }
}

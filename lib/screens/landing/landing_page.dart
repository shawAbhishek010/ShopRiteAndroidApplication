import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import 'widgets/footer_widget.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.welcome,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(AppStrings.tagline),
              Spacer(),
              FooterWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

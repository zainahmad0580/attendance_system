import 'package:attendance_system/student%20panel/view%20screens/ap.dart';
import 'package:flutter/material.dart';

import 'view screens/cn.dart';
import 'view screens/ispr.dart';
import 'view screens/mc.dart';
import 'view screens/pf.dart';

class ViewScreen extends StatelessWidget {
  const ViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leadingWidth: 30,
            backgroundColor: Colors.lightBlue,
            foregroundColor: Colors.white,
            leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new)),
            title: const Text('Courses')),
        body: PageView(
          children: const [
            MobileComputingView(),
            PFView(),
            ISPRView(),
            ComputerNetworksView(),
            AppliedPhysicsView()
          ],
        ));
  }
}

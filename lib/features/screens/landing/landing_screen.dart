// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';

import '../../bloc/bottom_nav_cubit.dart';
import '../screens.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  /// Top Level Pages
  final List<Widget> topLevelPages = const [
    HomeScreen(),
    ProfileScreen()
  ];

  /// On Page Changed
  void onPageChanged(int page) {
    BlocProvider.of<BottomNavCubit>(context).changeSelectedIndex(page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 2, 2, 2),
      //appBar: _LandingScreenAppBar(),
      body: _LandingScreenBody(),
      bottomNavigationBar: _LandingScreenBottomNavBar(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      //floatingActionButton: _LandingScreenFab(),
    );
  }

  // Bottom Navigation Bar - LandingScreen Widget
  BottomAppBar _LandingScreenBottomNavBar(BuildContext context) {
    return BottomAppBar(
      padding: const EdgeInsets.all(10),
      color: Colors.white,

      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _bottomAppBarItem(
                  context,
                  defaultIcon: IconlyLight.game,
                  page: 0,
                  label: "Juegos",
                  filledIcon: IconlyBold.game,
                ),
            
                _bottomAppBarItem(
                  context,
                  defaultIcon: IconlyLight.profile,
                  page: 1,
                  label: "Perfil",
                  filledIcon: IconlyBold.profile,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Floating Action Button - LandingScreen Widget
  // FloatingActionButton _LandingScreenFab() {
  //   return FloatingActionButton(
  //     onPressed: () {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           behavior: SnackBarBehavior.floating,
  //           backgroundColor: Color.fromARGB(255, 7, 7, 7),
  //           content: Text("New post will generate in upcoming 2 mins 📮"),
  //         ),
  //       );
  //     },
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
  //     backgroundColor: Colors.amber,
  //     child: const Icon(Icons.add),
  //   );
  // }

  // App Bar - LandingScreen Widget
  // AppBar _LandingScreenAppBar() {
  //   return AppBar(
  //     backgroundColor: Colors.black,
  //     centerTitle: true,

  //     title: Text(
  //       "BottomNavigationBar with Cubit",

  //       style: GoogleFonts.poppins(
  //         color: Colors.white,
  //         fontSize: 18,
  //       ),
  //     ),
  //   );
  // }

  // Body - LandingScreen Widget
  PageView _LandingScreenBody() {
    return PageView(
      onPageChanged: (int page) => onPageChanged(page),
      controller: pageController,
      children: topLevelPages,
    );
  }

  // Bottom Navigation Bar Single item - LandingScreen Widget
  Widget _bottomAppBarItem(BuildContext context, {required defaultIcon, required page, required label, required filledIcon}) {
    return GestureDetector(
      onTap: () {
        BlocProvider.of<BottomNavCubit>(context).changeSelectedIndex(page);

        pageController.animateToPage(
          page,
          duration: const Duration(milliseconds: 10),
          curve: Curves.fastLinearToSlowEaseIn
        );
      },

      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 10,
            ),
            Icon(
              context.watch<BottomNavCubit>().state == page ? filledIcon : defaultIcon,
              color: context.watch<BottomNavCubit>().state == page ? Colors.blueGrey : Colors.grey,
              size: 26,
            ),
            const SizedBox(
              height: 3,
            ),
            Text(
              label,
              style: TextStyle(
                color: context.watch<BottomNavCubit>().state == page ? Colors.blueGrey : Colors.grey,
                fontSize: 13,
                fontWeight: context.watch<BottomNavCubit>().state == page ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
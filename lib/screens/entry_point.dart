// lib/screens/entry_point.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart'; // Pastikan package rive ada
import '../components/side_menu.dart'; // Import menu baru tadi
import '../models/sidebar_state_model.dart';
import '../utils/constants.dart';
import 'home/home_screen.dart'; // Pastikan path ke HomeScreen betul

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late Animation<double> _scaleAnimation;

  // Rive Animation untuk butang Menu (Hamburger)
  SMIBool? _isMenuOpenInput;

  @override
  void initState() {
    super.initState();
    // Setup Animasi Drawer
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() {
        setState(() {});
      });

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.fastOutSlowIn),
    );

    _scaleAnimation = Tween<double>(begin: 1, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.fastOutSlowIn),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dapatkan state sidebar
    final sidebarState = Provider.of<SidebarStateModel>(context);
    
    // Sinkronize state animasi dengan state provider jika perlu
    if (sidebarState.isMenuOpen && _animationController.isDismissed) {
      _animationController.forward();
    } else if (!sidebarState.isMenuOpen && _animationController.isCompleted) {
      _animationController.reverse();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF17203A), // Warna Background Menu
      resizeToAvoidBottomInset: false,
      extendBody: true,
      body: Stack(
        children: [
          // 1. SIDE MENU (Lapisan Belakang)
          // Kedudukan menu kekal statik di belakang
          const AnimatedPositioned(
            duration: Duration(milliseconds: 200),
            curve: Curves.fastOutSlowIn,
            width: 288,
            left: 0, 
            height: double.infinity,
            child: SideMenu(),
          ),

          // 2. HOME SCREEN (Lapisan Depan - Bergerak)
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspektif 3D
              ..rotateY(_animation.value - 30 * _animation.value * pi / 180),
            child: Transform.translate(
              offset: Offset(_animation.value * 265, 0),
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(sidebarState.isMenuOpen ? 24 : 0)),
                  child: const HomeScreen(), // Pastikan HomeScreen wujud
                ),
              ),
            ),
          ),

          // 3. BUTANG MENU (Hamburger Icon)
          // Butang ini terapung di atas Home Screen
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.fastOutSlowIn,
            top: 16,
            left: sidebarState.isMenuOpen ? 220 : 10, // Bergerak ikut menu
            child: SafeArea(
              child: GestureDetector(
                onTap: () {
                  // Toggle State
                  sidebarState.toggleMenu();
                  
                  // Trigger animasi icon
                  if (_isMenuOpenInput != null) {
                    _isMenuOpenInput!.value = sidebarState.isMenuOpen;
                  }
                },
                child: Container(
                  width: 44,
                  height: 44,
                  margin: const EdgeInsets.only(left: 10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        offset: Offset(0, 3),
                        blurRadius: 8,
                      )
                    ],
                  ),
                  child: RiveAnimation.asset(
                    "assets/RiveAssets/menu_button.riv", // Pastikan aset ini ada
                    onInit: (artboard) {
                      final controller = StateMachineController.fromArtboard(artboard, "State Machine");
                      artboard.addController(controller!);
                      _isMenuOpenInput = controller.findInput<bool>("isOpen") as SMIBool;
                      _isMenuOpenInput!.value = false; // Default tutup
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// lib/screens/entry_point.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import '../components/side_menu.dart';
import '../models/sidebar_state_model.dart';
import '../utils/constants.dart';

// IMPORT YANG BETUL
import '../home.dart'; 

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late Animation<double> _scaleAnimation;

  SMIBool? _isMenuOpenInput;

  @override
  void initState() {
    super.initState();
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
    final sidebarState = Provider.of<SidebarStateModel>(context);
    
    // Logic Animasi
    if (sidebarState.isMenuOpen && _animationController.isDismissed) {
      _animationController.forward();
    } else if (!sidebarState.isMenuOpen && _animationController.isCompleted) {
      _animationController.reverse();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF17203A), 
      resizeToAvoidBottomInset: false,
      extendBody: true,
      body: Stack(
        children: [
          // 1. MENU (Belakang)
          const AnimatedPositioned(
            duration: Duration(milliseconds: 200),
            curve: Curves.fastOutSlowIn,
            width: 288,
            left: 0, 
            height: double.infinity,
            child: SideMenu(),
          ),

          // 2. HOME SCREEN (Depan - Bergerak 3D)
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_animation.value - 30 * _animation.value * pi / 180),
            child: Transform.translate(
              offset: Offset(_animation.value * 265, 0),
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(sidebarState.isMenuOpen ? 24 : 0)),
                  
                  // --- [CRITICAL FIX] ---
                  // Guna 'HomePage' (ikut nama class di home.dart), BUKAN 'HomeScreen'
                  child: const HomePage(), 
                  // ---------------------
                  
                ),
              ),
            ),
          ),

          // 3. MENU BUTTON (Floating)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.fastOutSlowIn,
            top: 16,
            left: sidebarState.isMenuOpen ? 220 : 10,
            child: SafeArea(
              child: GestureDetector(
                onTap: () {
                  sidebarState.toggleMenu();
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
                    "assets/RiveAssets/menu_button.riv",
                    onInit: (artboard) {
                      final controller = StateMachineController.fromArtboard(artboard, "State Machine");
                      if (controller != null) {
                        artboard.addController(controller);
                        _isMenuOpenInput = controller.findInput<bool>("isOpen") as SMIBool;
                        _isMenuOpenInput!.value = false;
                      }
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

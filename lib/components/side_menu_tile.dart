import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class SideMenuTile extends StatelessWidget {
  const SideMenuTile({
    super.key,
    required this.menuKey, // Kita guna String sebagai ID (ikut error log)
    required this.riveSrc,
    required this.artboard,
    required this.isActive,
    required this.onTap,
    required this.title,
  });

  final String menuKey;
  final String riveSrc;
  final String artboard;
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 24),
          child: Divider(color: Colors.white24, height: 1),
        ),
        Stack(
          children: [
            // Indikator Aktif (Glow effect di belakang)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn,
              height: 56,
              width: isActive ? 288 : 0,
              left: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF6792FF),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            ListTile(
              onTap: onTap,
              leading: SizedBox(
                height: 34,
                width: 34,
                child: RiveAnimation.asset(
                  riveSrc,
                  artboard: artboard,
                  onInit: (artboard) {
                    StateMachineController? controller =
                        StateMachineController.fromArtboard(artboard, "State Machine");
                    artboard.addController(controller!);
                    // Trigger input active jika menu dipilih
                    var input = controller.findInput<bool>("active") as SMIBool;
                    input.value = isActive;
                  },
                ),
              ),
              title: Text(
                title,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
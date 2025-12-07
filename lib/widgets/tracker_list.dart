// lib/widgets/tracker_list.dart (BONUS UPGRADE)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../models/user_model.dart';
import '../models/animation_controller_model.dart'; // Import animation controller
import 'metallic_gold.dart';
import 'embun_ui/embun_ui.dart'; // ✅ Import Embun UI

class TrackerList extends StatelessWidget {
  const TrackerList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MetallicGold(
          child: Text(
            "Amalan Fardhu",
            style: TextStyle(
              fontSize: AppFontSizes.xl, 
              fontWeight: FontWeight.bold,
              fontFamily: 'Playfair',
              color: Colors.white
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildFardhuTracker(context, user),
        
        const SizedBox(height: AppSpacing.xl),
        
        const MetallicGold(
          child: Text(
            "Amalan Sunat Pilihan",
            style: TextStyle(
              fontSize: AppFontSizes.xl, 
              fontWeight: FontWeight.bold,
              fontFamily: 'Playfair',
              color: Colors.white
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildOptionalTracker(context, user),
      ],
    );
  }

  Widget _buildFardhuTracker(BuildContext context, UserModel user) {
    final List<String> fardhuAmalan = ['Solat 5 Waktu', 'Puasa Sunat', 'Tilawah Quran'];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: kCardDark.withOpacity(0.7),
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
        border: Border.all(color: Colors.white10),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: fardhuAmalan.length,
        itemBuilder: (context, index) {
          final amalan = fardhuAmalan[index];
          final isDone = user.isFardhuComplete(amalan);
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                const MetallicGold(child: Icon(Icons.star, color: Colors.white, size: AppSizes.iconMd)),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(amalan, style: const TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold)),
                      Text('Amalan wajib/terpenting', style: TextStyle(color: kTextSecondary.withOpacity(0.7), fontSize: AppFontSizes.xs)),
                    ],
                  ),
                ),
                // ✅ LIVING ICON BUTTON untuk Fardhu
                LivingButton(
                  onPressed: () {
                    user.toggleFardhuCompletion(amalan);
                    if (!isDone) {
                       Provider.of<AnimationControllerModel>(context, listen: false)
                        .triggerParticleSpray();
                    }
                  },
                  backgroundColor: Colors.transparent,
                  child: Icon(
                    isDone ? Icons.check_circle : Icons.circle_outlined,
                    color: isDone ? kPrimaryGold : kTextSecondary.withOpacity(0.5),
                    size: 28,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOptionalTracker(BuildContext context, UserModel user) {
    final List<String> sunatAmalan = ['Sedekah Jumaat', 'Dhuha', 'Witir', 'Selawat 100x'];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: kCardDark.withOpacity(0.7),
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
        border: Border.all(color: Colors.white10),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sunatAmalan.length,
        itemBuilder: (context, index) {
          final amalan = sunatAmalan[index];
          
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const MetallicGold(child: Icon(Icons.stars_outlined, color: Colors.white, size: AppSizes.iconMd)),
            title: Text(amalan, style: const TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold)),
            subtitle: Text('Ganjaran tambahan', style: TextStyle(color: kTextSecondary.withOpacity(0.7), fontSize: AppFontSizes.xs)),
            trailing: Switch(
              value: user.isOptionalComplete(amalan),
              onChanged: (val) {
                user.toggleOptionalCompletion(amalan);
              },
              activeColor: kAccentOlive,
              inactiveThumbColor: Colors.white30,
            ),
          );
        },
      ),
    );
  }
}
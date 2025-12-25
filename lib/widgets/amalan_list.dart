// lib/widgets/amalan_list.dart (LIVE DATA)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/daily_content_provider.dart';
import '../utils/constants.dart';

class AmalanList extends StatelessWidget {
  const AmalanList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. Tarik data dari Provider
    final provider = Provider.of<DailyContentProvider>(context);
    final amalanList = provider.todayAmalanList;
    final isLoading = provider.isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 5, bottom: 10),
          child: Text("AMALAN SUNNAH", style: TextStyle(color: kTextSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        ),
        
        if (isLoading)
          const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator(color: kPrimaryGold)))
        else if (amalanList.isEmpty)
           const Padding(padding: EdgeInsets.all(20), child: Text("Tiada amalan khusus disenaraikan.", style: TextStyle(color: Colors.grey)))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: amalanList.length,
            itemBuilder: (context, index) {
              final amalan = amalanList[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: amalan.isCompleted ? kPrimaryGold.withOpacity(0.1) : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: amalan.isCompleted ? kPrimaryGold.withOpacity(0.5) : Colors.white10
                  ),
                ),
                child: ListTile(
                  leading: GestureDetector(
                    onTap: () => provider.toggleAmalan(amalan.id),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: amalan.isCompleted ? kPrimaryGold : Colors.grey, width: 2),
                        color: amalan.isCompleted ? kPrimaryGold : Colors.transparent,
                      ),
                      child: amalan.isCompleted 
                        ? const Icon(Icons.check, size: 14, color: Colors.black)
                        : const Icon(null, size: 14),
                    ),
                  ),
                  title: Text(
                    amalan.title,
                    style: TextStyle(
                      color: amalan.isCompleted ? kPrimaryGold : Colors.white,
                      fontSize: 14,
                      decoration: amalan.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Text(
                    amalan.type.toUpperCase(), // 'HARIAN' atau 'MINGGUAN'
                    style: TextStyle(color: Colors.grey.withOpacity(0.6), fontSize: 10),
                  ),
                  trailing: amalan.source.isNotEmpty 
                    ? const Icon(Icons.info_outline, size: 16, color: Colors.grey)
                    : null,
                ),
              );
            },
          ),
      ],
    );
  }
}

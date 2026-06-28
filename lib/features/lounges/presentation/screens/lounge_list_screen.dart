import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:airport_nav/features/lounges/presentation/providers/lounge_providers.dart';
import 'package:airport_nav/features/lounges/presentation/widgets/lounge_card.dart';

class LoungeListScreen extends ConsumerWidget {
  final String airportCode;

  const LoungeListScreen({
    super.key,
    required this.airportCode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lounges = ref.watch(loungesByAirportProvider(airportCode));

    return Scaffold(
      appBar: AppBar(
        title: Text('Lounges at $airportCode'),
      ),
      body: lounges.isEmpty
          ? const Center(
              child: Text(
                'No lounges found for this airport.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: lounges.length,
              itemBuilder: (context, index) {
                final lounge = lounges[index];
                return LoungeCard(
                  lounge: lounge,
                  onTap: () {
                    context.push('/lounges/${lounge.id}');
                  },
                );
              },
            ),
    );
  }
}

import 'dart:async';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';

class InlineAuctionCountdown extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;

  const InlineAuctionCountdown({
    super.key,
    required this.startDate,
    required this.endDate,
  });

  Stream<Map<String, String>> getTimeStream() async* {
    while (true) {
      yield getFormattedTime();
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Map<String, String> getFormattedTime() {
    final DateTime now = DateTime.now();

    // If auction hasn't started yet, show time until start
    if (now.isBefore(startDate)) {
      final Duration difference = startDate.difference(now);
      return formatDuration(difference, 'Starting in:');
    }

    // If auction has ended, show expired
    if (now.isAfter(endDate)) {
      return {'prefix': '', 'time': 'Auction Ended'};
    }

    // If auction is live, show time until end
    final Duration difference = endDate.difference(now);
    return formatDuration(difference, 'Ending in:');
  }

  Map<String, String> formatDuration(Duration duration, String prefix) {
    final int days = duration.inDays;
    final int hours = duration.inHours % 24;
    final int minutes = duration.inMinutes % 60;
    final int seconds = duration.inSeconds % 60;

    String timeValue;
    if (days > 0) {
      timeValue = '$days days: $hours hrs: $minutes min';
    } else if (hours > 0) {
      timeValue = '$hours hrs: $minutes min: $seconds sec';
    } else {
      timeValue = '$minutes min: $seconds sec';
    }

    return {'prefix': prefix, 'time': timeValue};
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, String>>(
      stream: getTimeStream(),
      initialData: getFormattedTime(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final data = snapshot.data!;
        final prefix = data['prefix']!;
        final timeValue = data['time']!;
        
        // If Auction Ended, display the full text in one go
        if (timeValue == 'Auction Ended') {
          return Text(
            timeValue,
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: primaryVariantColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
          );
        }

        // Display prefix and time in a single line
        return Text(
          '$prefix $timeValue',
          style: Theme.of(context).textTheme.labelSmall!.copyWith(
                color: primaryVariantColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
        );
      },
    );
  }
}

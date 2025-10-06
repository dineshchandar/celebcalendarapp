import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/celebrity.dart';
import '../services/celebrity_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MonthlyViewScreen extends StatelessWidget {
  const MonthlyViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> months = List.generate(
      12,
      (index) => DateFormat('MMMM').format(DateTime(2025, index + 1)),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly View'),
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Daily View'),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3/2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: months.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MonthDetailScreen(monthNumber: index + 1),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      months[index],
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MonthDetailScreen extends StatelessWidget {
  final int monthNumber;

  const MonthDetailScreen({super.key, required this.monthNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('MMMM').format(DateTime(2025, monthNumber))),
      ),
      body: FutureBuilder<List<Celebrity>>(
        future: CelebrityService.getCelebritiesByMonth(monthNumber),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final birthdays = snapshot.data ?? [];

          if (birthdays.isEmpty) {
            return const Center(child: Text('No birthdays this month'));
          }

          return ListView.builder(
            itemCount: birthdays.length,
            itemBuilder: (context, index) {
              final celebrity = birthdays[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(celebrity.imageUrl),
                ),
                title: Text(celebrity.name),
                subtitle: Text('Born ${DateFormat('MMMM d, yyyy').format(celebrity.birthDate)}'),
              );
            },
          );
        },
      ),
    );
  }
}

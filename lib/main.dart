import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'services/celebrity_service.dart';
import 'models/celebrity.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CelebrityService.loadCelebrities();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Celebrity Calendar',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const CelebrityCalendarPage(),
    );
  }
}

class CelebrityCalendarPage extends StatelessWidget {
  const CelebrityCalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              flex: 5,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('EEEE').format(today).toUpperCase(),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      DateFormat('MMMM d').format(today),
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              flex: 5,
              child: FutureBuilder<List<Celebrity>>(
                future: CelebrityService.getTodaysBirthdays(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final birthdays = snapshot.data ?? [];

                  if (birthdays.isEmpty) {
                    return const Center(
                      child: Text('No celebrity birthdays today'),
                    );
                  }

                  return ListView.builder(
                    itemCount: birthdays.length,
                    itemBuilder: (context, index) {
                      final celebrity = birthdays[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              CachedNetworkImageProvider(celebrity.imageUrl),
                        ),
                        title: Text(celebrity.name),
                        subtitle: Text(
                            'Born ${DateFormat('yyyy').format(celebrity.birthDate)}'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

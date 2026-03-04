import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(const ThuLinhThuApp());

class ThuLinhThuApp extends StatelessWidget {
  const ThuLinhThuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thư Linh Thú',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF7B5CFF)),
      home: const MainShell(),
    );
  }
}

class AppState {
  static int linhKhi = 0;
  static int totalReadSeconds = 0;
  static String petName = 'Tiểu Long';
  static int petLevel = 1;

  static void gainReadSeconds(int seconds) {
    totalReadSeconds += seconds;
    linhKhi = totalReadSeconds ~/ 600; // 10 phút = 1 linh khí
    petLevel = 1 + (linhKhi ~/ 10);    // mỗi 10 linh khí lên 1 cấp
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      Home(onGoRead: () => setState(() => tab = 1)),
      Reader(onChanged: () => setState(() {})),
      const Bag(),
      const Profile(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thư Linh Thú'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: Text('⚡ ${AppState.linhKhi}')),
          ),
        ],
      ),
      body: pages[tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Trang chủ'),
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'Đọc'),
          NavigationDestination(icon: Icon(Icons.inventory_2), label: 'Túi đồ'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Hồ sơ'),
        ],
      ),
    );
  }
}

class Home extends StatelessWidget {
  final VoidCallback onGoRead;
  const Home({super.key, required this.onGoRead});

  @override
  Widget build(BuildContext context) {
    final totalMin = AppState.totalReadSeconds ~/ 60;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const CircleAvatar(child: Text('🐉')),
            title: Text('${AppState.petName} (Cấp ${AppState.petLevel})'),
            subtitle: Text('Linh khí: ${AppState.linhKhi} • Đã đọc: $totalMin phút'),
            trailing: FilledButton(
              onPressed: onGoRead,
              child: const Text('Đọc ngay'),
            ),
          ),
        ),
      ],
    );
  }
}

class Reader extends StatefulWidget {
  final VoidCallback onChanged;
  const Reader({super.key, required this.onChanged});

  @override
  State<Reader> createState() => _ReaderState();
}

class _ReaderState extends State<Reader> {
  Timer? timer;
  int session = 0;
  bool running = false;

  void start() {
    if (running) return;
    setState(() => running = true);
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => session++);
      AppState.gainReadSeconds(1);
      widget.onChanged();
    });
  }

  void stop() {
    timer?.cancel();
    timer = null;
    setState(() => running = false);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = session ~/ 60, s = session % 60;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: ListTile(
              title: const Text('Đọc sách (demo)'),
              subtitle: Text('Phiên này: ${m}p ${s}s'),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: SingleChildScrollView(
                  child: Text(
                    'Khung đọc demo.\n\n'
                    'Quy tắc: 10 phút = 1 linh khí.\n'
                    'Mỗi 10 linh khí, linh thú lên 1 cấp.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: running ? null : start,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Bắt đầu'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: running ? stop : null,
                  icon: const Icon(Icons.pause),
                  label: const Text('Tạm dừng'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Bag extends StatelessWidget {
  const Bag({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Túi đồ (demo)'));
  }
}

class Profile extends StatelessWidget {
  const Profile({super.key});
  @override
  Widget build(BuildContext context) {
    final hours = (AppState.totalReadSeconds / 3600).toStringAsFixed(2);
    return Center(child: Text('Tổng thời gian đọc: $hours giờ'));
  }
}

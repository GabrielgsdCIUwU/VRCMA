
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrcma/presentation/state/automation_provider.dart';
import 'package:vrcma/presentation/state/navigation_provider.dart';
import 'package:vrcma/presentation/widgets/home/automation_settings_panel.dart';
import 'package:vrcma/presentation/widgets/home/friends_panel.dart';
import 'package:vrcma/presentation/widgets/home/logs_panel.dart';
import 'package:vrcma/presentation/widgets/home/messages_panel.dart';
import 'package:vrcma/presentation/widgets/home/profile_banner.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});
    
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(automationStateProvider);
    final currentIndex = ref.watch(navigationStackProvider);
    final isWide = MediaQuery.of(context).size.width > 900;
    
    return Scaffold(
      body: SafeArea(
          child: Column(
            children: [
              const ProfileBanner(),
              Expanded(
                child: isWide ? _buildWideLayout() : _buildMobileLayout(currentIndex),
              )
            ],
          )
      ),
      bottomNavigationBar: !isWide ? NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) => ref.read(navigationStackProvider.notifier).setIndex(i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Config',
          ),
          NavigationDestination(
            icon: Icon(Icons.message_outlined),
            selectedIcon: Icon(Icons.message),
            label: 'Messages',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Logs',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Friends',
          )
        ],
      ) : null,
    );
  }
  
  Widget _buildWideLayout() {
    return const Row(
      children: [
        Expanded(flex: 2, child: AutomationSettingsPanel()),
        VerticalDivider(width: 1),
        Expanded(flex: 3, child: _MainWorkspace()),
        VerticalDivider(width: 1),
        Expanded(flex: 2, child: FriendsPanel()),
      ],
    );
  }
  
  Widget _buildMobileLayout(int index) {
    return IndexedStack(
      index: index,
      children: const [
        AutomationSettingsPanel(),
        MessagesPanel(),
        LogsPanel(),
        FriendsPanel(),
      ],
    );
  }
}

class _MainWorkspace extends StatelessWidget {
  const _MainWorkspace();
  
  static const tabs = [
    Tab(icon: Icon(Icons.list_alt), text: "AUTOMATION LOGS"),
    Tab(icon: Icon(Icons.message), text: "MESSAGES & SLOTS"),
  ];
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Column(
        children: [
          const TabBar(tabs: tabs),
          Expanded(
            child: TabBarView(
              children: [
                const LogsPanel(),
                const MessagesPanel(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
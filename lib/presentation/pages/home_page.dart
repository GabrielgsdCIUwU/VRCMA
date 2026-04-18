
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrcma/presentation/state/automation_provider.dart';
import 'package:vrcma/presentation/state/navigation_provider.dart';
import 'package:vrcma/presentation/widgets/home/automation_settings_panel.dart';
import 'package:vrcma/presentation/widgets/home/common/responsive_layout.dart';
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
    
    return Scaffold(
      body: SafeArea(
          child: Column(
            children: [
              const ProfileBanner(),
              Expanded(
                child: ResponsiveLayout(
                    mobile: _buildMobileLayout(currentIndex),
                    desktop: _buildWideLayout()
                ),
              )
            ],
          )
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width <= 900 ? NavigationBar(
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
    Tab(icon: Icon(Icons.message), text: "MESSAGES & SLOTS"),
    Tab(icon: Icon(Icons.list_alt), text: "AUTOMATION LOGS"),
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
                const MessagesPanel(),
                const LogsPanel(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
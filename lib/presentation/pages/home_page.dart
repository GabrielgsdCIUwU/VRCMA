
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrcma/core/l10n/l10n_extension.dart';
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
      bottomNavigationBar: MediaQuery.of(context).size.width <= 1100 ? NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) => ref.read(navigationStackProvider.notifier).setIndex(i),
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: context.l10n.navConfig,
          ),
          NavigationDestination(
            icon: Icon(Icons.message_outlined),
            selectedIcon: Icon(Icons.message),
            label: context.l10n.navMessages,
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: context.l10n.navLogs,
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: context.l10n.navFriends,
          )
        ],
      ) : null,
    );
  }
  
  Widget _buildWideLayout() {
    return const Row(
      children: [
        Expanded(flex: 1, child: AutomationSettingsPanel()),
        VerticalDivider(width: 1),
        Expanded(flex: 3, child: _MainWorkspace()),
        VerticalDivider(width: 1),
        Expanded(flex: 1, child: FriendsPanel()),
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
  
  @override
  Widget build(BuildContext context) {
    final tabs = [
      Tab(icon: Icon(Icons.message), text: context.l10n.workspaceTabMessages.toUpperCase()),
      Tab(icon: Icon(Icons.list_alt), text: context.l10n.workspaceTabLogs.toUpperCase()),
    ];
  
    return DefaultTabController(
      length: tabs.length,
      child: Column(
        children: [
          TabBar(tabs: tabs),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrcma/core/l10n/l10n_extension.dart';
import 'package:vrcma/core/theme/vrc_theme.dart';
import 'package:vrcma/presentation/state/app_settings_provider.dart';
import 'package:vrcma/presentation/state/automation_provider.dart';
import 'package:vrcma/presentation/state/navigation_provider.dart';
import 'package:vrcma/presentation/widgets/home/common/responsive_layout.dart';
import 'package:vrcma/presentation/widgets/home/dashboard_panel.dart';
import 'package:vrcma/presentation/widgets/home/friends_panel.dart';
import 'package:vrcma/presentation/widgets/home/logs_panel.dart';
import 'package:vrcma/presentation/widgets/home/messages_panel.dart';
import 'package:vrcma/presentation/widgets/home/profile_banner.dart';
import 'package:vrcma/presentation/widgets/home/settings_panel.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});
    
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(automationStateProvider);

    return const ResponsiveLayout(mobile: _MobileHomeView(), desktop: _DesktopHomeView());
  }
}

class _ActiveWorkspace extends ConsumerWidget {
  const _ActiveWorkspace();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = ref.watch(navigationStackProvider);

    switch (route) {
      case AppRoute.dashboard:
        return const DashboardPanel();
      
      case AppRoute.messages:
        return const MessagesPanel();

      case AppRoute.logs:
        return const LogsPanel();
      
      case AppRoute.settings:
        return const SettingsPanel();
    }    
  }
}

class _MobileHomeView extends ConsumerWidget {
  const _MobileHomeView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRoute = ref.watch(navigationStackProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: const ProfileBanner(),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.people_alt_outlined),
              tooltip: context.l10n.navFriends,
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      endDrawer: const Drawer(
        width: 320,
        child: SafeArea(child: FriendsPanel()),
      ),
      body: const _ActiveWorkspace(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentRoute.index,
        onDestinationSelected: (idx) {
          ref.read(navigationStackProvider.notifier).setRoute(AppRoute.values[idx]);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: context.l10n.dashboardHeader,
          ),
          NavigationDestination(
            icon: const Icon(Icons.message_outlined),
            selectedIcon: const Icon(Icons.message),
            label: context.l10n.navMessages,
          ),
          NavigationDestination(
            icon: const Icon(Icons.list_alt_outlined),
            selectedIcon: const Icon(Icons.list_alt),
            label: context.l10n.navLogs,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: context.l10n.navConfig,
          ),
        ],
      ),
    );
  }
}

class _DesktopHomeView extends ConsumerWidget {
  const _DesktopHomeView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRoute = ref.watch(navigationStackProvider);
    final collapsed = ref.watch(friendsPanelCollapsedProvider);

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: false,
            elevation: 1,
            backgroundColor: context.colorScheme.surfaceContainerLow,
            selectedIndex: currentRoute.index,
            onDestinationSelected: (idx) {
              ref.read(navigationStackProvider.notifier).setRoute(AppRoute.values[idx]);
            },
            destinations: [
              NavigationRailDestination(
                icon: const Icon(Icons.dashboard_outlined),
                selectedIcon: const Icon(Icons.dashboard),
                label: Text(context.l10n.dashboardHeader),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.message_outlined),
                selectedIcon: const Icon(Icons.message),
                label: Text(context.l10n.navMessages),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.list_alt_outlined),
                selectedIcon: const Icon(Icons.list_alt),
                label: Text(context.l10n.navLogs),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings),
                label: Text(context.l10n.navConfig),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                titleSpacing: 0,
                title: const ProfileBanner(),
                actions: [
                  IconButton(
                    icon: Icon(collapsed ? Icons.people_outline : Icons.people),
                    tooltip: context.l10n.navFriends,
                    onPressed: () {
                      ref.read(friendsPanelCollapsedProvider.notifier).toggle();
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              body: const Column(
                children: [
                  Divider(height: 1),
                  Expanded(child: _ActiveWorkspace()),
                ],
              ),
            ),
          ),
          if (!collapsed) ...[
            const VerticalDivider(width: 1),
            const SizedBox(
              width: 320,
              child: FriendsPanel(),
            )
          ]
        ],
      ),
    );
  }
}
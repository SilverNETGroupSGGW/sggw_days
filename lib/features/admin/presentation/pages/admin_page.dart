import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:sggw_days/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:sggw_days/features/admin/presentation/bloc/admin_event.dart';
import 'package:sggw_days/features/admin/presentation/bloc/admin_state.dart';
import 'package:sggw_days/features/admin/presentation/cubit/admin_auth_cubit.dart';
import 'package:sggw_days/features/admin/presentation/pages/notifications_tab.dart';
import 'package:sggw_days/features/admin/presentation/pages/timetable_events_tab.dart';
import 'package:sggw_days/features/admin/presentation/pages/treasure_points_tab.dart';
import 'package:sggw_days/features/admin/presentation/pages/wiki_articles_tab.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Load initial data
    context.read<AdminBloc>().add(LoadTreasurePoints());
    context.read<AdminBloc>().add(LoadWikiArticles());
    context.read<AdminBloc>().add(LoadTimetableEvents());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          TextButton.icon(
            onPressed: _openPosterGenerator,
            icon: const Icon(Icons.local_printshop_outlined),
            label: const Text('Posters'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AdminBloc>().add(LoadTreasurePoints());
              context.read<AdminBloc>().add(LoadWikiArticles());
              context.read<AdminBloc>().add(LoadTimetableEvents());
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AdminAuthCubit>().logout();
              context.go('/');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.place), text: 'Points'),
            Tab(icon: Icon(Icons.article), text: 'Wiki Articles'),
            Tab(icon: Icon(Icons.event), text: 'Timetable'),
            Tab(icon: Icon(Icons.campaign), text: 'Notify'),
          ],
        ),
      ),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state.status == AdminStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.errorMessage}',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AdminBloc>().add(LoadTreasurePoints());
                      context.read<AdminBloc>().add(LoadWikiArticles());
                      context.read<AdminBloc>().add(LoadTimetableEvents());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: const [
              TreasurePointsTab(),
              WikiArticlesTab(),
              TimetableEventsTab(),
              NotificationsTab(),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openPosterGenerator() async {
    final uri = _posterGeneratorUri();
    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: '_blank',
    );
    if (opened || !mounted) {
      return;
    }

    await Clipboard.setData(ClipboardData(text: uri.toString()));
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Poster generator link copied.')),
    );
  }

  Uri _posterGeneratorUri() {
    if (kIsWeb) {
      final base = Uri.base;
      final isLocalhost =
          base.host == 'localhost' ||
          base.host == '127.0.0.1' ||
          base.host == '0.0.0.0';
      if (!isLocalhost) {
        return base.resolve('/posters/');
      }
    }

    return Uri.https('sggw-days.web.app', '/posters/');
  }
}

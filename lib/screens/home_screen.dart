import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';
import '../services/notification_service.dart';
import '../widgets/animated_background.dart';
import '../widgets/empty_state.dart';
import '../widgets/progress_header.dart';
import '../widgets/task_card.dart';
import '../widgets/task_form_sheet.dart';
import '../utils/app_snackbar.dart';

const _green = Color(0xFF34D399);
const _cyan = Color(0xFF22D3EE);
const _red = Color(0xFFFB7185);
const _pink = Color(0xFFF472B6);
const _muted = Color(0xFFA9A6C8);
const _surface = Color(0x990D1715);

enum _TaskFilter { all, active, favorites, completed }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  _TaskFilter _filter = _TaskFilter.all;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final allTasks = provider.tasks;
    final activeCount = allTasks.where((task) => !task.isDone).length;
    final favoriteCount = allTasks.where((task) => task.isFavorite).length;
    final completedCount = allTasks.where((task) => task.isDone).length;
    final filteredTasks = allTasks.where((task) {
      final matchesFilter = switch (_filter) {
        _TaskFilter.all => true,
        _TaskFilter.active => !task.isDone,
        _TaskFilter.favorites => task.isFavorite,
        _TaskFilter.completed => task.isDone,
      };
      return matchesFilter &&
          task.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF050B0A),
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedBackground()),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
                        children: [
                          _buildTopBar(),
                          const SizedBox(height: 24),
                          ProgressHeader(
                            completed: provider.completedCount,
                            total: provider.totalCount,
                            progress: provider.progress,
                          ),
                          const SizedBox(height: 22),
                          Row(
                            children: [
                              Expanded(child: _buildSearchField()),
                              const SizedBox(width: 8),
                              _buildSortButton(provider),
                            ],
                          ),
                          const SizedBox(height: 18),
                          _buildFilters(
                            allTasks.length,
                            activeCount,
                            favoriteCount,
                            completedCount,
                          ),
                          if (_filter == _TaskFilter.completed &&
                              completedCount > 0)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () => _clearCompleted(context),
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 17,
                                ),
                                label: const Text('Clear completed'),
                                style: TextButton.styleFrom(
                                  foregroundColor: _muted,
                                ),
                              ),
                            ),
                          const SizedBox(height: 18),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 260),
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            transitionBuilder: (child, animation) =>
                                FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, 0.025),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                ),
                            child:
                                filteredTasks.isEmpty &&
                                    _filter == _TaskFilter.favorites
                                ? _favoritesEmptyState()
                                : filteredTasks.isEmpty
                                ? EmptyState(
                                    key: ValueKey(
                                      'empty-${_filter.name}-$_searchQuery',
                                    ),
                                    hasTasks: allTasks.isNotEmpty,
                                  )
                                : Column(
                                    key: ValueKey(
                                      filteredTasks
                                          .map((task) => task.id)
                                          .join(','),
                                    ),
                                    children: filteredTasks.indexed.map((
                                      entry,
                                    ) {
                                      final (index, task) = entry;
                                      return Padding(
                                        key: ValueKey(task.id),
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child:
                                            TaskCard(
                                                  task: task,
                                                  inCompletedTab:
                                                      _filter ==
                                                      _TaskFilter.completed,
                                                )
                                                .animate()
                                                .fadeIn(
                                                  duration: 350.ms,
                                                  delay: Duration(
                                                    milliseconds: (index * 70)
                                                        .clamp(0, 600),
                                                  ),
                                                )
                                                .slideY(
                                                  begin: 0.12,
                                                  end: 0,
                                                  duration: 450.ms,
                                                  curve: Curves.easeOutBack,
                                                  delay: Duration(
                                                    milliseconds: (index * 70)
                                                        .clamp(0, 600),
                                                  ),
                                                ),
                                      );
                                    }).toList(),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 24,
            bottom: 24,
            child: SafeArea(child: _buildNewTaskButton(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    final date = DateTime.now();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final formattedDate =
        '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hello 👋',
                style: TextStyle(color: _muted, fontSize: 14),
              ),
              const SizedBox(height: 3),
              ShaderMask(
                shaderCallback: (bounds) =>
                    const LinearGradient(colors: [_green, _cyan])
                        .createShader(bounds),
                child: const Text(
                  'My Tasks',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Text(
            formattedDate,
            style: const TextStyle(color: _muted, fontSize: 12),
          ),
        ),
        const SizedBox(width: 4),
        PopupMenuButton<String>(
          tooltip: 'More options',
          color: const Color(0xFF16221F),
          icon: const Icon(Icons.more_vert_rounded, color: _muted),
          onSelected: (value) {
            if (value == 'clear') {
              _clearCompleted(context);
            } else if (value == 'test_notification') {
              _testNotification();
            } else {
              _showAbout(context);
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'clear', child: Text('Clear completed')),
            PopupMenuItem(
              value: 'test_notification',
              child: Text('Test notification'),
            ),
            PopupMenuItem(value: 'about', child: Text('About')),
          ],
        ),
      ],
    );
  }

  Future<void> _testNotification() async {
    final service = NotificationService.instance;
    var allowed = await service.areNotificationsAllowed();
    if (!allowed) allowed = await service.requestPermission();
    if (!mounted) return;
    if (!allowed) {
      showAppSnackBar(
        'Notifications are off. Enable them in phone Settings to get reminders.',
        icon: Icons.notifications_off_rounded,
      );
      return;
    }
    await service.showTestNotification();
    if (!mounted) return;
    showAppSnackBar(
      'Test notification sent',
      icon: Icons.notifications_active_rounded,
    );
  }

  Future<void> _clearCompleted(BuildContext context) async {
    final provider = context.read<TaskProvider>();
    if (provider.completedCount == 0) return;
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF16221F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Remove all completed tasks?',
          style: TextStyle(color: Color(0xFFEEECFF)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel', style: TextStyle(color: _muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Clear', style: TextStyle(color: _red)),
          ),
        ],
      ),
    );
    if (!context.mounted || shouldClear != true) return;
    await provider.clearCompleted();
    if (!context.mounted) return;
    showAppSnackBar('Completed tasks cleared');
  }

  void _showAbout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF16221F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('TaskFlow', style: TextStyle(color: _green)),
        content: const Text(
          'Version 1.0.0\nBuilt with Flutter by Muhammad Asrar',
          style: TextStyle(color: Color(0xFFEEECFF), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close', style: TextStyle(color: _cyan)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _searchQuery = value),
      style: const TextStyle(color: Color(0xFFEEECFF)),
      decoration: InputDecoration(
        hintText: 'Search tasks...',
        hintStyle: const TextStyle(color: _muted),
        prefixIcon: const Icon(Icons.search_rounded, color: _muted),
        suffixIcon: _searchQuery.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
                icon: const Icon(Icons.close_rounded, color: _muted),
              ),
        filled: true,
        fillColor: const Color(0x990D1715),
        contentPadding: const EdgeInsets.symmetric(vertical: 17),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: _green),
        ),
      ),
    );
  }

  Widget _buildSortButton(TaskProvider provider) {
    return PopupMenuButton<SortOption>(
      tooltip: 'Sort tasks',
      color: const Color(0xFF16221F),
      icon: const Icon(Icons.sort_rounded, color: _muted),
      onSelected: (option) => provider.setSortOption(option),
      itemBuilder: (context) => [
        _sortMenuItem(provider.sortOption, SortOption.dueDate, 'Due date'),
        _sortMenuItem(provider.sortOption, SortOption.priority, 'Priority'),
        _sortMenuItem(
          provider.sortOption,
          SortOption.newest,
          'Newest first',
        ),
      ],
    );
  }

  PopupMenuItem<SortOption> _sortMenuItem(
    SortOption selected,
    SortOption option,
    String label,
  ) {
    return PopupMenuItem(
      value: option,
      child: Row(
        children: [
          Expanded(child: Text(label)),
          if (selected == option)
            const Icon(Icons.check_rounded, color: _green, size: 18),
        ],
      ),
    );
  }

  Widget _buildFilters(int all, int active, int favorites, int completed) {
    final options = [
      (_TaskFilter.all, 'All', all, null),
      (_TaskFilter.active, 'Active', active, null),
      (_TaskFilter.favorites, 'Favourites', favorites, Icons.favorite_rounded),
      (_TaskFilter.completed, 'Completed', completed, null),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((option) {
          final selected = _filter == option.$1;
          final selectedColor = option.$1 == _TaskFilter.favorites
              ? _pink
              : _green;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _filter = option.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutBack,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: selected ? selectedColor : _surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: selected
                        ? selectedColor
                        : Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (option.$4 != null) ...[
                      Icon(
                        option.$4,
                        size: 15,
                        color: selected ? const Color(0xFF05231A) : _pink,
                      ),
                      const SizedBox(width: 5),
                    ],
                    Text(
                      option.$2,
                      style: TextStyle(
                        color: selected
                            ? const Color(0xFF05231A)
                            : const Color(0xFFEEECFF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${option.$3}',
                      style: TextStyle(
                        color: selected ? const Color(0xFF05231A) : _muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _favoritesEmptyState() => SizedBox(
    height: 250,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeInOut,
          builder: (context, value, child) =>
              Transform.translate(offset: Offset(0, -6 * value), child: child),
          child: const Icon(Icons.favorite_rounded, color: _pink, size: 42),
        ),
        const SizedBox(height: 16),
        const Text(
          'No favourites yet. Tap the heart on a task to add it here',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFEEECFF),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  Widget _buildNewTaskButton(BuildContext context) {
    return _Pressable(
      onTap: () => showTaskFormSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_green, _cyan]),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: _green.withValues(alpha: 0.25),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: Color(0xFF05231A)),
            SizedBox(width: 8),
            Text(
              'New Task',
              style: TextStyle(
                color: Color(0xFF05231A),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pressable extends StatefulWidget {
  const _Pressable({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 120),
    reverseDuration: const Duration(milliseconds: 220),
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 1,
    end: 0.97,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: widget.onTap,
    onTapDown: (_) => _controller.forward(),
    onTapUp: (_) => _controller.reverse(),
    onTapCancel: _controller.reverse,
    child: ScaleTransition(scale: _scale, child: widget.child),
  );
}

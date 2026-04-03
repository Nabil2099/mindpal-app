import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mindpal_app/features/recommendations/domain/models.dart';
import 'package:mindpal_app/features/recommendations/providers/recommendations_providers.dart';
import 'package:mindpal_app/features/recommendations/presentation/widgets/category_selector.dart';
import 'package:mindpal_app/shared/widgets/app_drawer.dart';
import 'package:mindpal_app/shared/widgets/shimmer_loader.dart';
import 'package:mindpal_app/shared/widgets/state_panels.dart';
import 'package:mindpal_app/theme.dart';

class RecommendationsScreen extends ConsumerStatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  ConsumerState<RecommendationsScreen> createState() =>
      _RecommendationsScreenState();
}

class _RecommendationsScreenState extends ConsumerState<RecommendationsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _habitsExpanded = true;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _clampCurrentPage(int batchLength) {
    if (batchLength == 0) {
      _currentPage = 0;
    } else if (_currentPage >= batchLength) {
      _currentPage = batchLength - 1;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_currentPage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recommendationsProvider);
    final notifier = ref.read(recommendationsProvider.notifier);

    // Clamp page index when batch shrinks
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _clampCurrentPage(state.batch.length);
    });

    return Scaffold(
      drawer: const AppDrawer(currentRoute: '/recommendations'),
      drawerEnableOpenDragGesture: true,
      appBar: AppBar(
        title: Text(
          'Today',
          style: GoogleFonts.newsreader(
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: state.loading ? null : notifier.generateBatch,
            child: Text(
              'Refresh',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: MindPalColors.ink700,
              ),
            ),
          ),
        ],
      ),
      body:
          state.loading
              ? const Padding(
                padding: EdgeInsets.all(20),
                child: ShimmerLoader(
                  width: double.infinity,
                  height: 280,
                  radius: 24,
                ),
              )
              : state.error != null
              ? MindPalErrorPanel(
                title: 'Unable to load recommendations',
                message: state.error!,
                onRetry: notifier.refreshBatch,
              )
              : state.batch.isEmpty && state.checklist.isEmpty
              ? MindPalEmptyPanel(
                title: 'No recommendations right now',
                subtitle:
                    'Pull to refresh or generate a new batch tuned to your current mood trend.',
                actionLabel: 'Generate batch',
                icon: Icons.self_improvement_outlined,
                onAction: notifier.generateBatch,
              )
              : RefreshIndicator(
                onRefresh: notifier.refreshBatch,
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  children: [
                    // Recommendation Carousel
                    if (state.batch.isNotEmpty) ...[
                      _RecommendationCarousel(
                        items: state.batch,
                        currentPage: _currentPage,
                        pageController: _pageController,
                        onPageChanged: (index) {
                          setState(() => _currentPage = index);
                        },
                        onComplete: notifier.completeItem,
                        onAdopt: notifier.adoptHabit,
                        onSkip: notifier.skipItem,
                        onNext: () {
                          if (_currentPage < state.batch.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                    // Today's Habits Section
                    _HabitsSection(
                      items: state.checklist,
                      isExpanded: _habitsExpanded,
                      onToggleExpanded: () {
                        setState(() => _habitsExpanded = !_habitsExpanded);
                      },
                      onToggle: notifier.toggleHabit,
                      onAdd: notifier.addHabit,
                      onDelete: notifier.deleteHabit,
                    ),
                    const SizedBox(height: 20),
                    // Category Selector
                    _DirectionCard(
                      selectedCategory: state.selectedCategory,
                      onSelect: notifier.selectCategory,
                      onRefresh: notifier.generateBatch,
                    ),
                  ],
                ),
              ),
    );
  }
}

class _RecommendationCarousel extends StatelessWidget {
  const _RecommendationCarousel({
    required this.items,
    required this.currentPage,
    required this.pageController,
    required this.onPageChanged,
    required this.onComplete,
    required this.onAdopt,
    required this.onSkip,
    required this.onNext,
  });

  final List<RecommendationItem> items;
  final int currentPage;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;
  final Future<void> Function(String itemId) onComplete;
  final Future<void> Function(String itemId) onAdopt;
  final Future<void> Function(String itemId) onSkip;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    final safeCurrentPage = currentPage.clamp(0, items.length - 1);
    final currentItem = items[safeCurrentPage];

    return Column(
      children: [
        // Card Header with pagination
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: MindPalColors.clay200.withValues(alpha: 0.8),
            ),
          ),
          child: Row(
            children: [
              // Item counter
              Text(
                'ITEM ${safeCurrentPage + 1} OF ${items.length}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: MindPalColors.ink700,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '•',
                style: TextStyle(
                  color: MindPalColors.ink700.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(width: 8),
              // Kind label
              Text(
                _formatKind(currentItem.kind).toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: MindPalColors.ink700,
                ),
              ),
              const Spacer(),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: MindPalColors.sand100,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  currentItem.status.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: MindPalColors.ink700,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Progress dots
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              left: BorderSide(
                color: MindPalColors.clay200.withValues(alpha: 0.8),
              ),
              right: BorderSide(
                color: MindPalColors.clay200.withValues(alpha: 0.8),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              items.length,
              (index) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color:
                      index == safeCurrentPage
                          ? MindPalColors.ink900
                          : MindPalColors.clay200,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
        // Page View
        SizedBox(
          height: 340,
          child: PageView.builder(
            controller: pageController,
            onPageChanged: onPageChanged,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _RecommendationPage(
                item: items[index],
                onComplete: onComplete,
                onAdopt: onAdopt,
                onSkip: onSkip,
                onNext: onNext,
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatKind(String kind) {
    return kind.replaceAll('_', ' ');
  }
}

class _RecommendationPage extends StatefulWidget {
  const _RecommendationPage({
    required this.item,
    required this.onComplete,
    required this.onAdopt,
    required this.onSkip,
    required this.onNext,
  });

  final RecommendationItem item;
  final Future<void> Function(String itemId) onComplete;
  final Future<void> Function(String itemId) onAdopt;
  final Future<void> Function(String itemId) onSkip;
  final VoidCallback onNext;

  @override
  State<_RecommendationPage> createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<_RecommendationPage> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
          border: Border.all(
            color:
                _isExpanded
                    ? MindPalColors.ink900.withValues(alpha: 0.3)
                    : MindPalColors.clay200.withValues(alpha: 0.8),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with title and expand icon - tappable
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        widget.item.title,
                        style: GoogleFonts.newsreader(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: MindPalColors.ink900,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Duration and kind tags
                      Wrap(
                        spacing: 8,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: MindPalColors.sand100,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              widget.item.duration.toUpperCase(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                                color: MindPalColors.ink700,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: MindPalColors.clay100,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              widget.item.kind
                                  .replaceAll('_', ' ')
                                  .toUpperCase(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                                color: MindPalColors.ink700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: MindPalColors.ink700,
                  size: 24,
                ),
              ],
            ),
            // Expanded content
            if (_isExpanded) ...[
              const SizedBox(height: 16),
              // Context label
              Text(
                'WHY THIS?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: MindPalColors.ink700.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 6),
              // Rationale
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.rationale,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: MindPalColors.ink700,
                          height: 1.6,
                        ),
                      ),
                      if (widget.item.followUp != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          widget.item.followUp!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: MindPalColors.ink700.withValues(alpha: 0.8),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Action buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      () =>
                          widget.item.kind == 'adopt_habit'
                              ? widget.onAdopt(widget.item.id)
                              : widget.onComplete(widget.item.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MindPalColors.ink900,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    widget.item.kind == 'adopt_habit'
                        ? 'Adopt habit'
                        : 'Mark complete',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => widget.onSkip(widget.item.id),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: MindPalColors.ink800,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: MindPalColors.clay300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: Text(
                        'Skip',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onNext,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: MindPalColors.ink800,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: MindPalColors.clay300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: Text(
                        'Next',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Collapsed hint
              const Spacer(),
              Center(
                child: Text(
                  'Tap to see details',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: MindPalColors.ink700.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HabitsSection extends StatefulWidget {
  const _HabitsSection({
    required this.items,
    required this.isExpanded,
    required this.onToggleExpanded,
    required this.onToggle,
    required this.onAdd,
    required this.onDelete,
  });

  final List<HabitChecklistItem> items;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;
  final Future<void> Function(HabitChecklistItem item, bool checked) onToggle;
  final Future<void> Function(String name) onAdd;
  final Future<void> Function(String id) onDelete;

  @override
  State<_HabitsSection> createState() => _HabitsSectionState();
}

class _HabitsSectionState extends State<_HabitsSection> {
  bool _showAddForm = false;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = widget.items.where((i) => i.completed).length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: MindPalColors.clay200.withValues(alpha: 0.8)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "TODAY'S HABITS",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: MindPalColors.ink700.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$completedCount of ${widget.items.length} completed',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: MindPalColors.ink900,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: widget.onToggleExpanded,
                  child: Text(
                    widget.isExpanded ? 'HIDE' : 'SHOW',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      color: MindPalColors.ink700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Habits list
          if (widget.isExpanded) ...[
            const Divider(height: 1, color: MindPalColors.clay100),
            if (widget.items.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Add a habit below or adopt one from your recommendations.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: MindPalColors.ink700.withValues(alpha: 0.7),
                  ),
                ),
              )
            else
              ...widget.items.map(
                (item) => _HabitRow(
                  item: item,
                  onToggle: widget.onToggle,
                  onDelete: widget.onDelete,
                ),
              ),
            // Add habit form or button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child:
                  _showAddForm
                      ? Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              autofocus: true,
                              decoration: InputDecoration(
                                hintText: 'e.g. Morning Walk',
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100),
                                  borderSide: BorderSide(
                                    color: MindPalColors.clay300,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100),
                                  borderSide: BorderSide(
                                    color: MindPalColors.clay300,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100),
                                  borderSide: BorderSide(
                                    color: MindPalColors.clay400,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              final text = _controller.text.trim();
                              if (text.isEmpty) return;
                              await widget.onAdd(text);
                              if (mounted) {
                                _controller.clear();
                                setState(() => _showAddForm = false);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: MindPalColors.ink900,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              elevation: 0,
                            ),
                            child: const Text('Add'),
                          ),
                          const SizedBox(width: 4),
                          TextButton(
                            onPressed: () {
                              _controller.clear();
                              setState(() => _showAddForm = false);
                            },
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: MindPalColors.ink700),
                            ),
                          ),
                        ],
                      )
                      : GestureDetector(
                        onTap: () => setState(() => _showAddForm = true),
                        child: Row(
                          children: [
                            Text(
                              '+',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: MindPalColors.ink700,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Add habit',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: MindPalColors.ink700,
                              ),
                            ),
                          ],
                        ),
                      ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HabitRow extends StatefulWidget {
  const _HabitRow({
    required this.item,
    required this.onToggle,
    required this.onDelete,
  });

  final HabitChecklistItem item;
  final Future<void> Function(HabitChecklistItem item, bool checked) onToggle;
  final Future<void> Function(String id) onDelete;

  @override
  State<_HabitRow> createState() => _HabitRowState();
}

class _HabitRowState extends State<_HabitRow> {
  bool _isExpanded = false;

  bool get _hasDetails =>
      (widget.item.category != null && widget.item.category!.isNotEmpty) ||
      (widget.item.cueText != null && widget.item.cueText!.isNotEmpty) ||
      (widget.item.reasonText != null && widget.item.reasonText!.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          _hasDetails ? () => setState(() => _isExpanded = !_isExpanded) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: MindPalColors.sand50.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                _isExpanded
                    ? MindPalColors.ink900.withValues(alpha: 0.3)
                    : MindPalColors.clay200.withValues(alpha: 0.7),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    value: widget.item.completed,
                    activeColor: MindPalColors.ink900,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    side: BorderSide(color: MindPalColors.clay300, width: 1.5),
                    onChanged:
                        (value) => widget.onToggle(widget.item, value ?? false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.item.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: MindPalColors.ink900,
                      decoration:
                          widget.item.completed
                              ? TextDecoration.lineThrough
                              : null,
                    ),
                  ),
                ),
                if (_hasDetails)
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: MindPalColors.ink700,
                    size: 20,
                  ),
                TextButton(
                  onPressed: () => widget.onDelete(widget.item.id),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Remove',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: MindPalColors.ink700,
                    ),
                  ),
                ),
              ],
            ),
            if (_isExpanded && _hasDetails) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.item.category != null &&
                        widget.item.category!.isNotEmpty) ...[
                      _DetailRow(
                        label: 'Category',
                        value: widget.item.category!,
                      ),
                    ],
                    if (widget.item.cueText != null &&
                        widget.item.cueText!.isNotEmpty) ...[
                      if (widget.item.category != null)
                        const SizedBox(height: 8),
                      _DetailRow(label: 'Cue', value: widget.item.cueText!),
                    ],
                    if (widget.item.reasonText != null &&
                        widget.item.reasonText!.isNotEmpty) ...[
                      if (widget.item.category != null ||
                          widget.item.cueText != null)
                        const SizedBox(height: 8),
                      _DetailRow(label: 'Why', value: widget.item.reasonText!),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: MindPalColors.ink700.withValues(alpha: 0.6),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: MindPalColors.ink900,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _DirectionCard extends StatelessWidget {
  const _DirectionCard({
    required this.selectedCategory,
    required this.onSelect,
    required this.onRefresh,
  });

  final String selectedCategory;
  final ValueChanged<String> onSelect;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: MindPalColors.clay200.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pick your direction',
            style: GoogleFonts.newsreader(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: MindPalColors.ink900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Keep one category active and focus on one recommendation at a time.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: MindPalColors.ink700,
            ),
          ),
          const SizedBox(height: 16),
          CategorySelector(selected: selectedCategory, onSelect: onSelect),
        ],
      ),
    );
  }
}

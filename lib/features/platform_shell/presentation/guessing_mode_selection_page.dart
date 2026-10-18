import 'package:flutter/material.dart';
import 'package:roundveil/design_system/roundveil_theme.dart';

class GuessingModeOption {
  const GuessingModeOption({
    required this.id,
    required this.title,
    required this.description,
    required this.contentCount,
    required this.roundCount,
    required this.icon,
    required this.isPictureMode,
    this.categoryCounts = const <String, int>{},
  });

  final String id;
  final String title;
  final String description;
  final int contentCount;
  final int roundCount;
  final IconData icon;
  final bool isPictureMode;
  final Map<String, int> categoryCounts;
}

class GuessingModeSelection {
  const GuessingModeSelection({
    required this.formatId,
    required this.category,
    required this.contentCount,
  });

  final String formatId;
  final String category;
  final int contentCount;
}

class GuessingModeSelectionPage extends StatefulWidget {
  const GuessingModeSelectionPage({
    required this.options,
    required this.categories,
    required this.playersForPreview,
    super.key,
  });

  final List<GuessingModeOption> options;
  final List<String> categories;
  final int playersForPreview;

  @override
  State<GuessingModeSelectionPage> createState() =>
      _GuessingModeSelectionPageState();
}

class _GuessingModeSelectionPageState extends State<GuessingModeSelectionPage> {
  String _category = 'All Categories';

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 1100
        ? 3
        : width >= 680
        ? 2
        : 1;
    final options = widget.options;
    return Scaffold(
      appBar: AppBar(
        title: const Text('GUESSING GAMES'),
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: CustomScrollView(
              slivers: <Widget>[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'PICK YOUR CHALLENGE',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: tokens.ink,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Choose one format. Next, select the players for your match.',
                          style: TextStyle(color: tokens.muted),
                        ),
                        const SizedBox(height: 14),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: DropdownButtonFormField<String>(
                            key: const ValueKey<String>(
                              'guessing-picture-category',
                            ),
                            initialValue: _category,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Picture category',
                              helperText: 'Filters Character Picture and Object Picture only.',
                              border: OutlineInputBorder(),
                            ),
                            items: widget.categories
                                .map(
                                  (value) => DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  ),
                                )
                                .toList(growable: false),
                            onChanged: (value) => setState(
                              () => _category = value ?? 'All Categories',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverGrid.builder(
                    itemCount: options.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: 146,
                    ),
                    itemBuilder: (context, index) => _ModeTile(
                      option: options[index],
                      category: _category,
                      players: widget.playersForPreview,
                      tokens: tokens,
                    ),
                  ),
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.option,
    required this.category,
    required this.players,
    required this.tokens,
  });

  final GuessingModeOption option;
  final String category;
  final int players;
  final RoundveilBrandTokens tokens;

  @override
  Widget build(BuildContext context) {
    final availableCount = switch (option.id) {
      'character_picture' => option.contentCountForCategory(category),
      'object_picture' => option.contentCountForCategory(category),
      _ => option.contentCount,
    };
    final maxRounds = option.isPictureMode
        ? (availableCount ~/ players).clamp(0, option.roundCount)
        : option.roundCount;
    final canStart = availableCount > 0 && maxRounds > 0;
    final status = option.isPictureMode
        ? '$availableCount ${availableCount == 1 ? 'image' : 'images'} · up to $maxRounds rounds · $players players'
        : '$availableCount challenges · ${option.roundCount} rounds';
    final reason = availableCount == 0
        ? 'No eligible ${option.isPictureMode ? 'images' : 'content'} in this category yet.'
        : option.isPictureMode && availableCount < players
        ? 'Need at least $players distinct images for $players players.'
        : 'Available for $maxRounds round${maxRounds == 1 ? '' : 's'}.';
    return Semantics(
      button: canStart,
      enabled: canStart,
      label: '${option.title}. ${option.description} $status',
      child: Material(
        color: tokens.surface,
        shape: BeveledRectangleBorder(
          side: BorderSide(
            color: canStart ? tokens.cyan.withValues(alpha: .65) : tokens.muted,
            width: 1,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(7)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: ValueKey<String>('guessing-mode-${option.id}'),
          onTap: canStart
              ? () => Navigator.pop(
                  context,
                  GuessingModeSelection(
                    formatId: option.id,
                    category: category,
                    contentCount: availableCount,
                  ),
                )
              : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: tokens.raised,
                    border: Border.all(
                      color: tokens.orange.withValues(alpha: .6),
                    ),
                  ),
                  child: Icon(
                    option.icon,
                    color: canStart ? tokens.orange : tokens.muted,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        option.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: tokens.ink,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        option.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: tokens.muted, fontSize: 12),
                      ),
                      const Spacer(),
                      Text(
                        canStart ? status : reason,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: canStart ? tokens.cyan : tokens.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  canStart ? Icons.arrow_forward_rounded : Icons.lock_outline,
                  color: canStart ? tokens.orange : tokens.muted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension on GuessingModeOption {
  int contentCountForCategory(String category) => category == 'All Categories'
      ? contentCount
      : categoryCounts[category] ?? 0;
}

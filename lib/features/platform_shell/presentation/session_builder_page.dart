import 'package:flutter/material.dart';
import 'package:roundveil/data/repositories/draft_repository.dart';
import 'package:roundveil/data/repositories/player_profile_repository.dart';
import 'package:roundveil/design_system/roundveil_theme.dart';
import 'package:roundveil/domain/session/session_configuration.dart';
import 'package:roundveil/features/active_match/presentation/active_match_page.dart';
import 'package:roundveil/features/session_builder/application/session_builder_controller.dart';
import 'package:roundveil/l10n/generated/app_localizations.dart';

class SessionBuilderPage extends StatefulWidget {
  const SessionBuilderPage({
    required this.drafts,
    required this.onBack,
    this.profileRepository,
    this.initial,
    this.initialName = '',
    this.templateId,
    this.draftId,
    super.key,
  });

  final DraftRepository drafts;
  final PlayerProfileRepository? profileRepository;
  final VoidCallback onBack;
  final SessionConfiguration? initial;
  final String initialName;
  final String? templateId;
  final String? draftId;

  @override
  State<SessionBuilderPage> createState() => _SessionBuilderPageState();
}

class _SessionBuilderPageState extends State<SessionBuilderPage> {
  late final SessionBuilderController _controller;
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _controller = SessionBuilderController(
      drafts: widget.drafts,
      initial: widget.initial,
      templateId: widget.templateId,
      draftId: widget.draftId,
      name: widget.initialName,
    );
    _nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    final compact = MediaQuery.sizeOf(context).width < 700;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final config = _controller.configuration;
        final issue = _controller.validationMessage;
        final selected = config.selectedModuleIds.toSet();
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            compact ? 18 : 42,
            20,
            compact ? 18 : 42,
            36,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextButton.icon(
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: Text(l10n.back),
                    style: TextButton.styleFrom(
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.templateId == null
                        ? l10n.createGame
                        : l10n.quickGame,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.working,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  _BuilderSection(
                    index: '01',
                    title: l10n.sessionTitle,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextField(
                          controller: _nameController,
                          onChanged: _controller.setName,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: l10n.sessionName,
                            prefixIcon: const Icon(Icons.edit_note_rounded),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: <Widget>[
                            _FormatChip(
                              selected: !_controller.configuration.isMixed,
                              icon: Icons.sports_esports_outlined,
                              label: l10n.singleGame,
                              onTap: () =>
                                  _controller.setFormat(SessionFormat.single),
                            ),
                            _FormatChip(
                              selected: _controller.configuration.isMixed,
                              icon: Icons.shuffle_rounded,
                              label: l10n.mixedGame,
                              onTap: () =>
                                  _controller.setFormat(SessionFormat.mixed),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _BuilderSection(
                    index: '02',
                    title: l10n.selectGames,
                    trailing: Text(
                      '${config.selectedModuleIds.length} ${l10n.selected.toLowerCase()}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = constraints.maxWidth > 790
                            ? 3
                            : constraints.maxWidth > 480
                            ? 2
                            : 1;
                        return Wrap(
                          spacing: 11,
                          runSpacing: 11,
                          children: gameCatalog.map((game) {
                            final isSelected = selected.contains(game.id);
                            final title = _titleFor(l10n, game.titleKey);
                            return SizedBox(
                              width:
                                  (constraints.maxWidth - (columns - 1) * 11) /
                                  columns,
                              child: _GameChoice(
                                title: title,
                                description: game.playable
                                    ? l10n.playablePrototype
                                    : l10n.inFoundation,
                                selected: isSelected,
                                playable: game.playable,
                                onTap: () => _controller.toggleGame(game.id),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final stack = constraints.maxWidth < 680;
                      final playerControl = _BuilderSection(
                        index: '03',
                        title: l10n.players,
                        child: Row(
                          children: <Widget>[
                            IconButton.filledTonal(
                              tooltip: l10n.removePlayer,
                              onPressed: config.players.isEmpty
                                  ? null
                                  : _controller.removePlayer,
                              icon: const Icon(Icons.remove_rounded),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: <Widget>[
                                  for (final player in config.players)
                                    Chip(
                                      avatar: CircleAvatar(
                                        backgroundColor: tokens.cyan.withValues(
                                          alpha: .15,
                                        ),
                                        child: Text(
                                          '${config.players.indexOf(player) + 1}',
                                          style: TextStyle(
                                            color: tokens.cyan,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                      label: Text(player.displayName),
                                    ),
                                  if (config.players.isEmpty)
                                    Text(
                                      l10n.choosePlayer,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton.filledTonal(
                              tooltip: l10n.addPlayer,
                              onPressed: config.players.length >= 12
                                  ? null
                                  : _controller.addPlayer,
                              icon: const Icon(Icons.add_rounded),
                            ),
                          ],
                        ),
                      );
                      final roundControl = _BuilderSection(
                        index: '04',
                        title: l10n.rounds,
                        child: DropdownButtonFormField<int>(
                          initialValue: config.roundCount == 0
                              ? null
                              : config.roundCount,
                          decoration: InputDecoration(labelText: l10n.rounds),
                          items: List<int>.generate(10, (i) => i + 1)
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text('$value'),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) _controller.setRoundCount(value);
                          },
                        ),
                      );
                      if (stack) {
                        return Column(
                          children: <Widget>[
                            playerControl,
                            const SizedBox(height: 14),
                            roundControl,
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(flex: 2, child: playerControl),
                          const SizedBox(width: 14),
                          Expanded(child: roundControl),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  if (selected.any(
                    (id) => !gameCatalog
                        .firstWhere((game) => game.id == id)
                        .playable,
                  ))
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: tokens.cyan.withValues(alpha: .08),
                        border: Border(
                          left: BorderSide(color: tokens.cyan, width: 3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Icon(Icons.info_outline_rounded, color: tokens.cyan),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              l10n.sessionReadyBody,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (issue != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Text(
                        switch (issue) {
                          'player' => l10n.choosePlayer,
                          'game' || 'single' => l10n.chooseOneGame,
                          'mixed' => l10n.chooseTwoGames,
                          _ => l10n.incomplete,
                        },
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  const SizedBox(height: 18),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 12,
                    runSpacing: 10,
                    children: <Widget>[
                      OutlinedButton.icon(
                        onPressed: _controller.canCreate ? _saveDraft : null,
                        icon: const Icon(Icons.bookmark_add_outlined),
                        label: Text(l10n.saveDraft),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(48, 52),
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: _controller.canStartMatch
                            ? _createSession
                            : null,
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: Text(l10n.startSession),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveDraft() async {
    final draft = await _controller.saveDraft();
    if (!mounted || draft == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.draftSaved)),
    );
  }

  Future<void> _createSession() async {
    final configuration = await _controller.startMatch();
    if (!mounted || configuration == null) return;
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ActiveMatchPage(
          configuration: configuration,
          profileRepository: widget.profileRepository,
        ),
      ),
    );
  }
}

class _BuilderSection extends StatelessWidget {
  const _BuilderSection({
    required this.index,
    required this.title,
    required this.child,
    this.trailing,
  });
  final String index;
  final String title;
  final Widget child;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: tokens.surface.withValues(alpha: .88),
        border: Border.all(color: tokens.cyan.withValues(alpha: .16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                index,
                style: TextStyle(
                  color: tokens.orange,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.3,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _FormatChip extends StatelessWidget {
  const _FormatChip({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ChoiceChip(
    selected: selected,
    avatar: Icon(icon, size: 18),
    label: Text(label),
    onSelected: (_) => onTap(),
    showCheckmark: false,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
  );
}

class _GameChoice extends StatelessWidget {
  const _GameChoice({
    required this.title,
    required this.description,
    required this.selected,
    required this.playable,
    required this.onTap,
  });
  final String title;
  final String description;
  final bool selected;
  final bool playable;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          constraints: const BoxConstraints(minHeight: 108),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? tokens.cyan.withValues(alpha: .10)
                : tokens.surface,
            border: Border.all(
              color: selected
                  ? tokens.orange
                  : tokens.cyan.withValues(alpha: .22),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? tokens.orange : tokens.muted,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        if (playable)
                          Icon(
                            Icons.play_circle_outline,
                            size: 17,
                            color: tokens.orange,
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _titleFor(AppLocalizations l10n, String key) => switch (key) {
  'quiz' => l10n.quiz,
  'wordPlay' => l10n.wordPlay,
  'guessCharacter' => l10n.guessCharacter,
  'guessCountry' => l10n.guessCountry,
  _ => key,
};

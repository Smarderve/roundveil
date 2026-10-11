import 'package:flutter/material.dart';
import 'package:roundveil/data/repositories/draft_repository.dart';
import 'package:roundveil/design_system/roundveil_theme.dart';
import 'package:roundveil/features/platform_shell/presentation/cinematic_session_builder_page.dart';
import 'package:roundveil/features/platform_shell/presentation/v5_lobby_page.dart';
import 'package:roundveil/features/session_builder/application/session_builder_controller.dart';
import 'package:roundveil/l10n/generated/app_localizations.dart';

class V5QuickGamesPage extends StatefulWidget {
  const V5QuickGamesPage({
    required this.drafts,
    required this.onBack,
    super.key,
  });
  final DraftRepository drafts;
  final VoidCallback onBack;
  @override
  State<V5QuickGamesPage> createState() => _V5QuickGamesPageState();
}

class _V5QuickGamesPageState extends State<V5QuickGamesPage> {
  bool _mixed = false;
  QuickGameTemplate? _selected;

  List<QuickGameTemplate> get _templates => quickGameTemplates
      .where((template) => (template.moduleIds.length > 1) == _mixed)
      .toList();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    final compact = MediaQuery.sizeOf(context).width < 900;
    final selected = _templates.contains(_selected) ? _selected : null;

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        const V5SceneArt(),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: <Color>[
                Color(0x662C9BEA),
                Color(0xED061226),
                Color(0xF9030916),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(compact ? 14 : 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  IconButton(
                    tooltip: l10n.back,
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          l10n.quickGame.toUpperCase(),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                        ),
                        Text(
                          l10n.templateDescription,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: tokens.muted, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  SegmentedButton<bool>(
                    segments: const <ButtonSegment<bool>>[
                      ButtonSegment<bool>(value: false, label: Text('SINGLE')),
                      ButtonSegment<bool>(value: true, label: Text('MIXED')),
                    ],
                    selected: <bool>{_mixed},
                    onSelectionChanged: (values) => setState(() {
                      _mixed = values.single;
                      _selected = null;
                    }),
                    showSelectedIcon: false,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final narrow = constraints.maxWidth < 720;
                    final gallery = _TemplateGallery(
                      templates: _templates,
                      selected: selected,
                      onSelect: (template) =>
                          setState(() => _selected = template),
                    );
                    final preview = _TemplatePreview(
                      template: selected,
                      onEdit: () {
                        if (selected != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => CinematicSessionBuilderPage(
                                drafts: widget.drafts,
                                initial: selected.configuration,
                                initialName: _title(l10n, selected.titleKey),
                                templateId: selected.id,
                                onBack: () => Navigator.of(context).pop(),
                              ),
                            ),
                          );
                        }
                      },
                    );
                    if (narrow) {
                      return Column(
                        children: <Widget>[
                          SizedBox(
                            height: constraints.maxHeight * .46,
                            child: gallery,
                          ),
                          const SizedBox(height: 8),
                          Expanded(child: preview),
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(flex: 12, child: gallery),
                        const SizedBox(width: 14),
                        Expanded(flex: 8, child: preview),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TemplateGallery extends StatelessWidget {
  const _TemplateGallery({
    required this.templates,
    required this.selected,
    required this.onSelect,
  });
  final List<QuickGameTemplate> templates;
  final QuickGameTemplate? selected;
  final ValueChanged<QuickGameTemplate> onSelect;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.sizeOf(context).width < 700 ? 1 : 2,
        mainAxisExtent: 102,
        crossAxisSpacing: 9,
        mainAxisSpacing: 9,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        final active = selected?.id == template.id;
        final games = template.moduleIds
            .map((id) {
              final game = gameCatalog.firstWhere((item) => item.id == id);
              return _title(l10n, game.titleKey);
            })
            .join('  /  ');
        return Material(
          color: active ? const Color(0xCC123459) : const Color(0xB8061428),
          child: InkWell(
            onTap: () => onSelect(template),
            child: AnimatedContainer(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 170),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: active ? tokens.orange : Colors.transparent,
                    width: 4,
                  ),
                  bottom: BorderSide(
                    color: active
                        ? tokens.cyan
                        : tokens.cyan.withValues(alpha: .2),
                  ),
                ),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    template.moduleIds.length > 1
                        ? Icons.shuffle_rounded
                        : Icons.bolt_rounded,
                    color: active ? tokens.orange : tokens.cyan,
                    size: 23,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          _title(l10n, template.titleKey).toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: .5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          games,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: tokens.cyan, fontSize: 9),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${template.players} ${l10n.players.toLowerCase()} · ${template.rounds} ${l10n.rounds.toLowerCase()}',
                          style: TextStyle(color: tokens.muted, fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                  if (active)
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: tokens.orange,
                      size: 14,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TemplatePreview extends StatelessWidget {
  const _TemplatePreview({required this.template, required this.onEdit});
  final QuickGameTemplate? template;
  final VoidCallback onEdit;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = Theme.of(context).extension<RoundveilBrandTokens>()!;
    if (template == null) {
      return Center(
        child: Text(
          'SELECT A TEMPLATE TO PREVIEW',
          style: TextStyle(color: tokens.muted, fontSize: 11, letterSpacing: 1),
        ),
      );
    }
    final gameNames = template!.moduleIds.map((id) {
      final game = gameCatalog.firstWhere((item) => item.id == id);
      return _title(l10n, game.titleKey);
    }).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: Stack(
            children: <Widget>[
              const Positioned.fill(child: V5SceneArt()),
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[Color(0x66102C52), Color(0xF3051228)],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        'MATCH PREVIEW',
                        style: TextStyle(
                          color: tokens.cyan,
                          fontSize: 9,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _title(l10n, template!.titleKey).toUpperCase(),
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 7),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: <Widget>[
                          for (var i = 0; i < gameNames.length; i++)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xCC07162C),
                                border: Border(
                                  bottom: BorderSide(color: tokens.orange),
                                ),
                              ),
                              child: Text(
                                gameNames[i].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${template!.players} ${l10n.players.toLowerCase()}  ·  ${template!.rounds} ${l10n.rounds.toLowerCase()}',
                        style: TextStyle(color: tokens.muted, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.tune_rounded),
          label: const Text('EDIT & START MATCH'),
          style: FilledButton.styleFrom(
            backgroundColor: tokens.orange,
            foregroundColor: const Color(0xFF16100A),
            minimumSize: const Size.fromHeight(48),
          ),
        ),
      ],
    );
  }
}

String _title(AppLocalizations l10n, String key) => switch (key) {
  'quiz' => l10n.quiz,
  'wordPlay' => l10n.wordPlay,
  'guessCharacter' => l10n.guessCharacter,
  'riddles' => l10n.riddles,
  'memory' => l10n.memory,
  'guessCountry' => l10n.guessCountry,
  'quickQuiz' => l10n.quickQuiz,
  'quickWordPlay' => l10n.quickWordPlay,
  'quickCharacter' => l10n.quickCharacter,
  'quickRiddles' => l10n.quickRiddles,
  'quickMemory' => l10n.quickMemory,
  'quickFlags' => l10n.quickFlags,
  'quickPartyMix' => l10n.quickPartyMix,
  _ => key,
};

import 'package:flutter/material.dart';
import 'package:roundveil/domain/player/player_avatar_catalog.dart';
import 'package:roundveil/domain/player/player_profile.dart';

class CreatePlayerDraft {
  const CreatePlayerDraft({
    required this.displayName,
    required this.avatarId,
    this.gender,
  });

  final String displayName;
  final String avatarId;
  final PlayerGender? gender;
}

Future<CreatePlayerDraft?> showCreatePlayerDialog(
  BuildContext context, {
  required Iterable<PlayerProfile> existingProfiles,
}) {
  final usedAvatarIds = existingProfiles
      .map((profile) => profile.avatarId)
      .toSet();
  final availableAvatars = PlayerAvatarCatalog.all
      .where((avatar) => !usedAvatarIds.contains(avatar.id))
      .toList();
  var draftName = '';
  PlayerGender? gender;
  String? selectedAvatarId;

  return showDialog<CreatePlayerDraft>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) {
        final screen = MediaQuery.sizeOf(context);
        final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
        final contentHeight = keyboardOpen
            ? 64.0
            : (screen.height * .55).clamp(170.0, 420.0);
        return AlertDialog(
          scrollable: true,
          title: const Text('CREATE PLAYER'),
          content: SizedBox(
            width: (screen.width * .82).clamp(300.0, 660.0),
            height: contentHeight,
            child: Column(
              children: <Widget>[
                TextFormField(
                  autofocus: true,
                  maxLength: 24,
                  textInputAction: TextInputAction.done,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'PLAYER NAME',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    counterText: '',
                  ),
                  onChanged: (value) => setDialogState(() => draftName = value),
                  onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                ),
                if (!keyboardOpen) ...<Widget>[
                  DropdownButtonFormField<PlayerGender?>(
                    initialValue: gender,
                    decoration: const InputDecoration(
                      labelText: 'OPTIONAL GENDER',
                      isDense: true,
                    ),
                    items: const <DropdownMenuItem<PlayerGender?>>[
                      DropdownMenuItem(
                        value: null,
                        child: Text('NOT SPECIFIED'),
                      ),
                      DropdownMenuItem(
                        value: PlayerGender.woman,
                        child: Text('WOMAN'),
                      ),
                      DropdownMenuItem(
                        value: PlayerGender.man,
                        child: Text('MAN'),
                      ),
                      DropdownMenuItem(
                        value: PlayerGender.nonBinary,
                        child: Text('NON-BINARY'),
                      ),
                    ],
                    onChanged: (value) => setDialogState(() => gender = value),
                  ),
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('CHOOSE AN UNUSED CHARACTER'),
                  ),
                  const SizedBox(height: 7),
                  Expanded(
                    child: availableAvatars.isEmpty
                        ? const Center(
                            child: Text('All character slots are in use.'),
                          )
                        : GridView.builder(
                            itemCount: availableAvatars.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 5,
                                  crossAxisSpacing: 7,
                                  mainAxisSpacing: 7,
                                  childAspectRatio: .82,
                                ),
                            itemBuilder: (context, index) {
                              final avatar = availableAvatars[index];
                              final selected = selectedAvatarId == avatar.id;
                              return Semantics(
                                button: true,
                                selected: selected,
                                label: '${avatar.name} avatar',
                                child: InkWell(
                                  key: ValueKey<String>(
                                    'new-player-avatar-${avatar.id}',
                                  ),
                                  onTap: () => setDialogState(
                                    () => selectedAvatarId = avatar.id,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: selected
                                            ? const Color(0xFFF49727)
                                            : const Color(0x5537B7E9),
                                        width: selected ? 3 : 1,
                                      ),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Column(
                                      children: <Widget>[
                                        Expanded(
                                          child: Image.asset(
                                            avatar.effectivePortraitAssetPath,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(3),
                                          child: Text(
                                            avatar.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 9),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('CANCEL'),
            ),
            FilledButton(
              onPressed: draftName.trim().isEmpty || selectedAvatarId == null
                  ? null
                  : () => Navigator.of(dialogContext).pop(
                      CreatePlayerDraft(
                        displayName: draftName.trim(),
                        gender: gender,
                        avatarId: selectedAvatarId!,
                      ),
                    ),
              child: const Text('CREATE PLAYER'),
            ),
          ],
        );
      },
    ),
  );
}

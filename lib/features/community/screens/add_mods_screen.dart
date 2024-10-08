import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/utils.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';

class AddModsScreen extends ConsumerStatefulWidget {
  final String name;
  const AddModsScreen({super.key, required this.name});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddModsScreenState();
}

class _AddModsScreenState extends ConsumerState<AddModsScreen> {
  Set<String> uids = {};

  int ctr = 0;

  void addMod(String uid) {
    setState(() {
      uids.add(uid);
    });
  }

  void removeMode(String uid) {
    setState(() {
      uids.remove(uid);
    });
  }

  void saveMods() {
    if (uids.isEmpty) {
      showSnackBar(context, "Please select at least one moderator");
    } else {
      ref
          .read(communityControllerProvider.notifier)
          .addMods(context, widget.name, uids.toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Moderators"),
        actions: [
          IconButton(
            onPressed: saveMods,
            icon: const Icon(Icons.done),
          ),
        ],
      ),
      body: ref.watch(getCommunityByNameProvider(widget.name)).when(
            data: (community) {
              return ListView.builder(
                itemCount: community.members.length,
                itemBuilder: (context, index) {
                  final memberUid = community.members[index];

                  return ref.watch(getUserDataProvider(memberUid)).when(
                      data: (user) {
                        if (community.mods.contains(memberUid) &&
                            ctr <= community.mods.length) {
                          uids.add(memberUid);
                          ctr++;
                        }

                        return CheckboxListTile.adaptive(
                          title: Text(user.name),
                          value: uids.contains(memberUid),
                          onChanged: (value) {
                            if (value!) {
                              addMod(memberUid);
                            } else {
                              removeMode(memberUid);
                            }
                          },
                        );
                      },
                      error: (error, stackTrace) =>
                          ErrorText(error: error.toString()),
                      loading: () => const Loader());
                },
              );
            },
            error: (error, stackTrace) => ErrorText(error: error.toString()),
            loading: () => const Loader(),
          ),
    );
  }
}

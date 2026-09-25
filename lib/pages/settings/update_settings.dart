import 'package:flutter/material.dart';

import 'package:kazumi/bean/settings/settings_detail_scaffold.dart';
import 'package:kazumi/bean/settings/settings_list.dart';
import 'package:kazumi/services/storage/storage.dart';
import 'package:kazumi/utils/zh.dart';

class UpdateSettingsPage extends StatefulWidget {
  const UpdateSettingsPage({super.key});

  @override
  State<UpdateSettingsPage> createState() => _UpdateSettingsPageState();
}

class _UpdateSettingsPageState extends State<UpdateSettingsPage> {
  bool _pluginUpdate =
      GStorage.getSetting(SettingsKeys.checkPluginUpdateOnStartup);

  @override
  Widget build(BuildContext context) => SettingsDetailScaffold(
      title: Text(zh('更新设置')),
        body: SettingsList(
          sections: [
            SettingsSection(
              title: Text(zh('启动时检查更新')),
              tiles: [
                SettingsTile.switchTile(
                  leading: Icons.update_rounded,
                  title: Text(zh('应用更新')),
                  description: Text(zh('Kazumi HK 是固定版本构建，不跟随官方更新频道。')),
                  initialValue: false,
                  enabled: false,
                  onToggle: (_) {},
                ),
                SettingsTile.switchTile(
                  leading: Icons.extension_rounded,
                  title: Text(zh('规则更新')),
                  initialValue: _pluginUpdate,
                  onToggle: (value) {
                    setState(() => _pluginUpdate = value ?? !_pluginUpdate);
                    GStorage.putSetting(
                      SettingsKeys.checkPluginUpdateOnStartup,
                      _pluginUpdate,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      );
}

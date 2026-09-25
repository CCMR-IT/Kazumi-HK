import 'package:kazumi/bean/dialog/dialog_helper.dart';

enum InstallationType {
  windowsMsix,
  windowsPortable,
  linuxDeb,
  linuxTar,
  macosDmg,
  androidApk,
  ios,
  unknown,
}

class UpdateInfo {
  final String version;
  final String description;
  final String downloadUrl;
  final String releaseNotes;
  final String publishedAt;
  final InstallationType? installationType;
  final List<InstallationType> availableInstallationTypes;
  final List<dynamic> assets;

  UpdateInfo({
    required this.version,
    required this.description,
    required this.downloadUrl,
    required this.releaseNotes,
    required this.publishedAt,
    this.installationType,
    this.availableInstallationTypes = const [],
    this.assets = const [],
  });
  InstallationType get recommendedInstallationType {
    if (availableInstallationTypes.isNotEmpty) {
      return availableInstallationTypes.first;
    }
    return installationType ?? InstallationType.unknown;
  }
}

Map<String, dynamic>? getUpdateAssetForType(
    List<dynamic> assets, InstallationType type) {
  final patterns = getUpdateFilePatterns(type).map((p) => p.toLowerCase());

  try {
    final asset = assets.cast<Map<String, dynamic>>().firstWhere((asset) {
      final name = (asset['name'] as String?)?.toLowerCase() ?? '';
      return patterns.every((pattern) => name.contains(pattern));
    });
    return asset;
  } catch (_) {
    return null;
  }
}

String getUpdateDownloadUrlFromAsset(Map<String, dynamic>? asset) {
  if (asset == null) {
    return '';
  }
  final mirrorUrl = asset['mirror_download_url'] as String? ?? '';
  if (mirrorUrl.isNotEmpty) {
    return mirrorUrl;
  }
  return asset['browser_download_url'] as String? ?? '';
}

String getUpdateFileHashFromAsset(Map<String, dynamic> asset) {
  final digest = asset['digest'] as String? ?? '';
  if (digest.startsWith('sha256:')) {
    return digest.substring(7);
  }
  return '';
}

List<String> getUpdateFilePatterns(InstallationType installationType) {
  switch (installationType) {
    case InstallationType.windowsMsix:
      return ['windows', '.msix'];
    case InstallationType.windowsPortable:
      return ['windows', '.zip'];
    case InstallationType.macosDmg:
      return ['macos', '.dmg'];
    case InstallationType.androidApk:
      return ['android', '.apk'];
    case InstallationType.linuxDeb:
    case InstallationType.linuxTar:
    case InstallationType.ios:
    case InstallationType.unknown:
      return [];
  }
}

class AutoUpdater {
  static const String _frozenBuildMessage =
      'Kazumi HK 是固定版本构建，不跟随官方更新频道。';

  static final AutoUpdater _instance = AutoUpdater._internal();

  factory AutoUpdater() => _instance;

  AutoUpdater._internal();

  Future<UpdateInfo?> checkForUpdates() async {
    return null;
  }

  Future<void> autoCheckForUpdates() async {
    return;
  }

  Future<void> manualCheckForUpdates() async {
    KazumiDialog.showToast(message: _frozenBuildMessage);
  }
}

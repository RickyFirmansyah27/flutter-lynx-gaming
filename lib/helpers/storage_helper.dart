import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  static const String _permissionKey = 'storage_permission_granted';

  static Future<bool> _isPermissionPermanentlyGranted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_permissionKey) ?? false;
  }

  static Future<void> _setPermissionPermanentlyGranted(bool granted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_permissionKey, granted);
  }

  static Future<bool> checkStoragePermission() async {
    if (await _isPermissionPermanentlyGranted()) {
      return true;
    }

    final status = await Permission.storage.status;
    if (status.isGranted) {
      await _setPermissionPermanentlyGranted(true);
    }
    return status.isGranted;
  }

  static Future<bool> requestStoragePermission() async {
    if (await _isPermissionPermanentlyGranted()) {
      return true;
    }

    final status = await Permission.storage.request();
    if (status.isGranted) {
      await _setPermissionPermanentlyGranted(true);
    } else if (!status.isPermanentlyDenied) {
      await openAppSettings();
    }
    return status.isGranted;
  }

  static String getAccessStatusMessage(bool hasAccess) {
    return hasAccess
        ? "Memiliki akses ke penyimpanan internal"
        : "Belum memiliki akses ke penyimpanan internal";
  }
}

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

  static Future<bool> checkStoragePermission({required bool isAndroid11OrAbove}) async {
    if (await _isPermissionPermanentlyGranted()) {
      return true;
    }

    final permission = isAndroid11OrAbove ? Permission.manageExternalStorage : Permission.storage;
    final status = await permission.status;
    if (status.isGranted) {
      await _setPermissionPermanentlyGranted(true);
    }
    return status.isGranted;
  }

  static Future<bool> requestStoragePermission({required bool isAndroid11OrAbove}) async {
    if (await _isPermissionPermanentlyGranted()) {
      return true;
    }

    final permission = isAndroid11OrAbove ? Permission.manageExternalStorage : Permission.storage;
    final status = await permission.request();
    if (status.isGranted) {
      await _setPermissionPermanentlyGranted(true);
    }
    return status.isGranted;
  }

  static String getAccessStatusMessage(bool hasAccess, {required bool isAndroid11OrAbove, required String androidVersion}) {
    return hasAccess
        ? "Memiliki akses ${isAndroid11OrAbove ? 'lengkap' : ''} (Android $androidVersion)"
        : "Belum memiliki akses ${isAndroid11OrAbove ? 'lengkap' : ''}";
  }
}

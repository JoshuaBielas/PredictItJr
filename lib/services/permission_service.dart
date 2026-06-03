import 'package:permission_handler/permission_handler.dart';

/// Result of a permission request, in our terms (not the plugin's).
/// Mapping the plugin's enum to ours means the UI doesn't import
/// permission_handler at all — same seam discipline as A6 storage.
enum PermissionOutcome {
  granted,
  denied,              // this time. ask again later if you want.
  permanentlyDenied,   // only Settings can fix. STOP asking.
}

class PermissionService {
  Future<PermissionOutcome> requestCamera() => _request(Permission.camera);
  Future<PermissionOutcome> requestLocation() =>
      _request(Permission.locationWhenInUse);

  Future<PermissionOutcome> _request(Permission permission) async {
    final status = await permission.request();
    if (status.isGranted) return PermissionOutcome.granted;
    if (status.isPermanentlyDenied || status.isRestricted) {
      return PermissionOutcome.permanentlyDenied;
    }
    return PermissionOutcome.denied;
  }

  /// Opens the system Settings app. Called when permanentlyDenied —
  /// the ONLY way the user can change their answer.
  Future<bool> openSettings() => openAppSettings();
}
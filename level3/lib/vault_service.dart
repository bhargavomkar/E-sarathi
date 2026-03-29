import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// ──────────────────────────────────────────────
/// AuthService — local login / register with SharedPreferences
/// ──────────────────────────────────────────────
class AuthService {
  static const _usersKey = 'esarathi_users';
  static const _sessionKey = 'esarathi_session';

  // ── Register a new user ──
  static Future<String?> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    final Map<String, dynamic> users = raw != null
        ? Map<String, dynamic>.from(jsonDecode(raw))
        : {};

    final key = email.toLowerCase().trim();
    if (users.containsKey(key)) return 'Email already registered';

    users[key] = {
      'fullName': fullName.trim(),
      'email': key,
      'password': password,
      'createdAt': DateTime.now().toIso8601String(),
    };

    await prefs.setString(_usersKey, jsonEncode(users));
    return null; // success
  }

  // ── Login ──
  static Future<String?> login({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw == null) return 'No accounts found. Please register first.';

    final Map<String, dynamic> users = Map<String, dynamic>.from(
      jsonDecode(raw),
    );
    final key = email.toLowerCase().trim();
    if (!users.containsKey(key)) return 'Account not found';

    final user = Map<String, dynamic>.from(users[key]);
    if (user['password'] != password) return 'Incorrect password';

    // Save session
    await prefs.setString(_sessionKey, key);
    return null; // success
  }

  // ── Check if user is logged in ──
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionKey) != null;
  }

  // ── Get current user email ──
  static Future<String?> currentUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionKey);
  }

  // ── Get current user name ──
  static Future<String?> currentUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final session = prefs.getString(_sessionKey);
    if (session == null) return null;
    final raw = prefs.getString(_usersKey);
    if (raw == null) return null;
    final users = Map<String, dynamic>.from(jsonDecode(raw));
    if (!users.containsKey(session)) return null;
    return users[session]['fullName'] as String?;
  }

  // ── Logout ──
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}

/// ──────────────────────────────────────────────
/// VaultService — digital vault for user details
/// ──────────────────────────────────────────────
class VaultService {
  static const _vaultPrefix = 'esarathi_vault_';

  static Future<String> _vaultKey() async {
    final email = await AuthService.currentUserEmail() ?? 'default';
    return '$_vaultPrefix$email';
  }

  // ── Save vault data ──
  static Future<void> saveVault(Map<String, String> data) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _vaultKey();
    await prefs.setString(key, jsonEncode(data));
  }

  // ── Load vault data ──
  static Future<Map<String, String>> loadVault() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _vaultKey();
    final raw = prefs.getString(key);
    if (raw == null) return {};
    final decoded = jsonDecode(raw);
    return Map<String, String>.from(decoded);
  }

  // ── Vault field definitions (label → storage key) ──
  static const List<Map<String, String>> vaultFields = [
    {'key': 'fullName', 'label': 'Full Name', 'icon': 'person'},
    {'key': 'fatherName', 'label': "Father's Name", 'icon': 'person_outline'},
    {'key': 'motherName', 'label': "Mother's Name", 'icon': 'person_outline'},
    {'key': 'dob', 'label': 'Date of Birth (DD/MM/YYYY)', 'icon': 'cake'},
    {'key': 'gender', 'label': 'Gender', 'icon': 'wc'},
    {'key': 'email', 'label': 'Email', 'icon': 'email'},
    {'key': 'mobile', 'label': 'Mobile Number', 'icon': 'phone'},
    {'key': 'panNumber', 'label': 'PAN Number', 'icon': 'credit_card'},
    {'key': 'aadhaarNumber', 'label': 'Aadhaar Number', 'icon': 'fingerprint'},
    {'key': 'addressLine1', 'label': 'Address Line 1', 'icon': 'home'},
    {'key': 'addressLine2', 'label': 'Address Line 2', 'icon': 'home'},
    {'key': 'city', 'label': 'City', 'icon': 'location_city'},
    {'key': 'state', 'label': 'State', 'icon': 'map'},
    {'key': 'pincode', 'label': 'Pincode', 'icon': 'pin_drop'},
  ];
}

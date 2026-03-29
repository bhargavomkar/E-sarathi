import 'package:flutter/material.dart';
import 'vault_service.dart';

//////////////////////////////////////////////////////////////
// VAULT SCREEN — Digital Vault for user important details
//////////////////////////////////////////////////////////////

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  final Map<String, TextEditingController> _controllers = {};
  bool _loading = true;
  bool _saving = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    for (var f in VaultService.vaultFields) {
      _controllers[f['key']!] = TextEditingController();
    }
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await VaultService.loadVault();
    if (!mounted) return;
    for (var entry in data.entries) {
      if (_controllers.containsKey(entry.key)) {
        _controllers[entry.key]!.text = entry.value;
      }
    }
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _saved = false;
    });
    final Map<String, String> data = {};
    for (var entry in _controllers.entries) {
      if (entry.value.text.trim().isNotEmpty) {
        data[entry.key] = entry.value.text.trim();
      }
    }
    await VaultService.saveVault(data);
    if (mounted) {
      setState(() {
        _saving = false;
        _saved = true;
      });
      // Auto-dismiss success after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _saved = false);
      });
    }
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  IconData _iconForKey(String iconName) {
    switch (iconName) {
      case 'person':
        return Icons.person_rounded;
      case 'person_outline':
        return Icons.person_outline_rounded;
      case 'cake':
        return Icons.cake_rounded;
      case 'wc':
        return Icons.wc_rounded;
      case 'email':
        return Icons.email_rounded;
      case 'phone':
        return Icons.phone_rounded;
      case 'credit_card':
        return Icons.credit_card_rounded;
      case 'fingerprint':
        return Icons.fingerprint_rounded;
      case 'home':
        return Icons.home_rounded;
      case 'location_city':
        return Icons.location_city_rounded;
      case 'map':
        return Icons.map_rounded;
      case 'pin_drop':
        return Icons.pin_drop_rounded;
      default:
        return Icons.text_fields_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Digital Vault"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_saved)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF4ADE80),
                size: 22,
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
            )
          : Column(
              children: [
                // ── Header ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6C63FF).withAlpha(15),
                        const Color(0xFF4ECDC4).withAlpha(10),
                      ],
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: const Color(0xFF6C63FF).withAlpha(30),
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C63FF).withAlpha(25),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF6C63FF).withAlpha(50),
                              ),
                            ),
                            child: const Icon(
                              Icons.shield_rounded,
                              color: Color(0xFF6C63FF),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                        colors: [
                                          Color(0xFF6C63FF),
                                          Color(0xFF4ECDC4),
                                        ],
                                      ).createShader(bounds),
                                  child: const Text(
                                    "Your Digital Vault",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  "Store your details to auto-fill forms faster",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withAlpha(120),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Fields list ──
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                    itemCount: VaultService.vaultFields.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final field = VaultService.vaultFields[index];
                      final key = field['key']!;
                      final label = field['label']!;
                      final iconName = field['icon']!;

                      // Special handling for gender — show dropdown
                      if (key == 'gender') {
                        return _buildGenderField(label, iconName);
                      }

                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2D42),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF6C63FF).withAlpha(20),
                          ),
                        ),
                        child: TextFormField(
                          controller: _controllers[key],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            labelText: label,
                            labelStyle: TextStyle(
                              color: Colors.white.withAlpha(130),
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              _iconForKey(iconName),
                              color: const Color(0xFF6C63FF).withAlpha(180),
                              size: 20,
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                            enabledBorder: InputBorder.none,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Color(0xFF6C63FF),
                                width: 1.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      // ── Save FAB ──
      floatingActionButton: _loading
          ? null
          : Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withAlpha(80),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          _saved
                              ? Icons.check_circle_rounded
                              : Icons.save_rounded,
                          size: 20,
                        ),
                  label: Text(
                    _saving ? "Saving..." : (_saved ? "Saved!" : "Save Vault"),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildGenderField(String label, String iconName) {
    final ctrl = _controllers['gender']!;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E2D42),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF6C63FF).withAlpha(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Icon(
            _iconForKey(iconName),
            color: const Color(0xFF6C63FF).withAlpha(180),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: ctrl.text.isEmpty ? null : ctrl.text,
              dropdownColor: const Color(0xFF1E2D42),
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(
                  color: Colors.white.withAlpha(130),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              items: const [
                DropdownMenuItem(value: 'Male', child: Text('Male')),
                DropdownMenuItem(value: 'Female', child: Text('Female')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (v) {
                if (v != null) ctrl.text = v;
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'login_screen.dart';
import 'voice_qa_screen.dart';
import 'vault_screen.dart';
import 'vault_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const _primaryDark = Color(0xFF0D1B2A);
  static const _primaryMid = Color(0xFF1B2838);
  static const _accent = Color(0xFF6C63FF);
  static const _accentLight = Color(0xFF8B83FF);
  static const _surface = Color(0xFF162032);
  static const _cardBg = Color(0xFF1E2D42);
  static const _textPrimary = Color(0xFFF0F0F0);
  static const _textSecondary = Color(0xFF8E99A9);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: _primaryDark,
        colorScheme: ColorScheme.dark(
          primary: _accent,
          secondary: _accentLight,
          surface: _surface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: _primaryMid,
          foregroundColor: _textPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Segoe UI',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
            letterSpacing: 0.3,
          ),
        ),
        cardTheme: CardThemeData(
          color: _cardBg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _accent,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _surface,
          labelStyle: const TextStyle(color: _textSecondary),
          hintStyle: TextStyle(color: _textSecondary.withAlpha(120)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _cardBg, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _accent, width: 2),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        dropdownMenuTheme: DropdownMenuThemeData(
          textStyle: const TextStyle(color: _textPrimary),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: _surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? _accent : _surface,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        radioTheme: RadioThemeData(
          fillColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? _accent : _textSecondary,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: _textPrimary),
          bodyMedium: TextStyle(color: _textPrimary),
          bodySmall: TextStyle(color: _textSecondary),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

//////////////////////////////////////////////////////////////
// LANDING SCREEN
//////////////////////////////////////////////////////////////

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1B2A), Color(0xFF162032), Color(0xFF1B2838)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () async {
                        await AuthService.logout();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                            (_) => false,
                          );
                        }
                      },
                      icon: Icon(
                        Icons.logout_rounded,
                        size: 16,
                        color: Colors.white.withAlpha(120),
                      ),
                      label: Text(
                        "Sign Out",
                        style: TextStyle(
                          color: Colors.white.withAlpha(120),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6C63FF).withAlpha(40),
                      const Color(0xFF4ECDC4).withAlpha(40),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withAlpha(60),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  size: 40,
                  color: Color(0xFF6C63FF),
                ),
              ),
              const SizedBox(height: 20),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
                ).createShader(bounds),
                child: const Text(
                  "E-Sarathi+",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Universal Form Engine",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withAlpha(130),
                  letterSpacing: 2,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1923),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: const Color(0xFF6C63FF).withAlpha(30),
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "What would you like to do?",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withAlpha(220),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _LandingCard(
                          icon: Icons.person_add_alt_1_rounded,
                          iconBgColor: const Color(0xFF6C63FF),
                          title: "Register New User",
                          subtitle: "Start a fresh application from scratch",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const UrlInputScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        _LandingCard(
                          icon: Icons.replay_circle_filled_rounded,
                          iconBgColor: const Color(0xFF4ECDC4),
                          title: "Resume Application",
                          subtitle: "Continue a previously started application",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const UrlInputScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        _LandingCard(
                          icon: Icons.shield_rounded,
                          iconBgColor: const Color(0xFFFF6B6B),
                          title: "Digital Vault",
                          subtitle: "Store & manage your important details",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const VaultScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LandingCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _LandingCard({
    required this.icon,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1E2D42),
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        splashColor: iconBgColor.withAlpha(30),
        highlightColor: iconBgColor.withAlpha(15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: iconBgColor.withAlpha(30), width: 1),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: iconBgColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: iconBgColor.withAlpha(40)),
                ),
                child: Icon(icon, color: iconBgColor, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withAlpha(230),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withAlpha(100),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: iconBgColor.withAlpha(150),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// URL INPUT SCREEN
//////////////////////////////////////////////////////////////

class UrlInputScreen extends StatelessWidget {
  const UrlInputScreen({super.key});

  static const List<Map<String, dynamic>> _govApps = [
    {
      'name': 'PAN Card',
      'description': 'New PAN application or correction',
      'url':
          'https://onlineservices.proteantech.in/paam/endUserRegisterContact.html',
      'icon': 0xe19e,
      'color': 0xFF6C63FF,
    },
    {
      'name': 'Passport',
      'description': 'Fresh or re-issue passport application',
      'url': 'https://services2.passportindia.gov.in/forms/registration',
      'icon': 0xe0a1,
      'color': 0xFF4ECDC4,
    },
    {
      'name': 'Aadhaar Update',
      'description': 'Update your Aadhaar details online',
      'url': 'https://tathya.uidai.gov.in/access/login?role=resident',
      'icon': 0xe336,
      'color': 0xFFFF6B6B,
    },
    {
      'name': 'Driving License',
      'description': 'Apply for DL or learner\'s permit',
      'url':
          'https://sarathi.parivahan.gov.in/sarathiservice/stateSelection.do',
      'icon': 0xe1d7,
      'color': 0xFFFFBE0B,
    },
    {
      'name': 'Voter ID (NVSP)',
      'description': 'Register or update voter ID card',
      'url': 'https://voters.eci.gov.in/login',
      'icon': 0xe5c3,
      'color': 0xFF45B7D1,
    },
    {
      'name': 'Income Tax e-Filing',
      'description': 'File returns or register on IT portal',
      'url':
          'https://eportal.incometax.gov.in/iec/foservices/#/e-pay-tax-prelogin/user-details',
      'icon': 0xe04f,
      'color': 0xFF96CEB4,
    },
  ];

  void _openApp(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ScanScreen(url: url)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Application"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
              ).createShader(bounds),
              child: const Text(
                "Select Application",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Choose a government service to auto-fill the form.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withAlpha(140),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: _govApps.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final app = _govApps[index];
                  final Color appColor = Color(app['color'] as int);
                  return Material(
                    color: const Color(0xFF1E2D42),
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      splashColor: appColor.withAlpha(30),
                      highlightColor: appColor.withAlpha(15),
                      onTap: () => _openApp(context, app['url'] as String),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: appColor.withAlpha(40),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: appColor.withAlpha(25),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: appColor.withAlpha(50),
                                ),
                              ),
                              child: Icon(
                                IconData(
                                  app['icon'] as int,
                                  fontFamily: 'MaterialIcons',
                                ),
                                color: appColor,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    app['name'] as String,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white.withAlpha(230),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    app['description'] as String,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withAlpha(100),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: appColor.withAlpha(150),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                "More applications coming soon",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withAlpha(80),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// SCAN SCREEN
//////////////////////////////////////////////////////////////

class ScanScreen extends StatefulWidget {
  final String url;
  const ScanScreen({super.key, required this.url});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  InAppWebViewController? _webController;
  Map<String, Map<String, dynamic>> _allFields = {};
  String _scanStatus = "Loading page...";

  static const String _extractorJS = r"""
  (function(){
    var fields = [];
    var radioGroups = {};
    var seenIds = {};

    function findLabel(el) {
      if (el.id) {
        var lbl = document.querySelector('label[for="' + el.id + '"]');
        if (lbl) {
          var txt = lbl.innerText.trim();
          if (txt.length > 0 && txt.length < 100) return txt;
        }
      }
      var formGroup = el.closest('.form-group');
      if (formGroup) {
        var labels = formGroup.querySelectorAll('label');
        for (var i = 0; i < labels.length; i++) {
          var cls = labels[i].className || '';
          if (cls.indexOf('hidden') >= 0) continue;
          var txt = labels[i].innerText.trim();
          if (txt.length > 0 && txt.length < 100) return txt;
        }
        for (var i = 0; i < labels.length; i++) {
          var txt = labels[i].innerText.trim();
          if (txt.length > 0 && txt.length < 100) return txt;
        }
      }
      var parentLabel = el.closest('label');
      if (parentLabel) {
        var txt = parentLabel.innerText.replace(el.value || '', '').trim();
        if (txt.length > 0 && txt.length < 100) return txt;
      }
      var td = el.closest('td, th');
      if (td) {
        var prev = td.previousElementSibling;
        if (prev) {
          var txt = prev.innerText.trim();
          if (txt.length > 0 && txt.length < 80) return txt;
        }
        var walker = document.createTreeWalker(td, NodeFilter.SHOW_TEXT);
        var texts = [];
        while (walker.nextNode()) {
          var t = walker.currentNode.textContent.trim();
          if (t.length > 0) texts.push(t);
        }
        if (texts.length > 0) return texts.join(' ').trim();
      }
      var parent = el.parentElement;
      if (parent) {
        for (var i = 0; i < parent.children.length; i++) {
          var child = parent.children[i];
          if (child === el) break;
          var t = child.innerText ? child.innerText.trim() : '';
          if (t.length > 0 && t.length < 80) return t;
        }
      }
      var colParent = el.closest('[class*="col-"]');
      if (colParent) {
        var lbl = colParent.querySelector('label, .display-block, .panel-title');
        if (lbl) {
          var txt = lbl.innerText.trim();
          if (txt.length > 0 && txt.length < 100) return txt;
        }
      }
      return el.getAttribute('aria-label') || el.placeholder || '';
    }

    function humanize(name) {
      return name
        .replace(/([a-z])([A-Z])/g, '$1 $2')
        .replace(/_/g, ' ')
        .replace(/\b\w/g, function(c){ return c.toUpperCase(); })
        .trim();
    }

    function isVisible(el) {
      if (!el) return false;
      var style = window.getComputedStyle(el);
      if (style.display === 'none' || style.visibility === 'hidden') return false;
      var p = el.parentElement;
      while (p) {
        var ps = window.getComputedStyle(p);
        if (ps.display === 'none' || ps.visibility === 'hidden') return false;
        p = p.parentElement;
      }
      return true;
    }

    function isFrameworkField(name) {
      var lower = name.toLowerCase();
      var skipExact = ['__viewstate','__eventvalidation','__eventtarget',
        '__requestdigest','__previouspage','__viewstategenerator',
        'uniquekey','saltkey','ivkey',
        'utmsource','utmmedium','utmcampaign','utmterm','utmcontent','utmlink',
        'requestfrom','transactionid','valueforpage','fullformconsent'];
      for (var i = 0; i < skipExact.length; i++) {
        if (lower === skipExact[i]) return true;
      }
      if (lower.indexOf('__viewstate') >= 0) return true;
      if (lower.indexOf('__eventvalidation') >= 0) return true;
      if (lower.indexOf('__eventtarget') >= 0) return true;
      return false;
    }

    var elements = document.querySelectorAll("input, textarea, select");
    elements.forEach(function(el){
      if (el.disabled) return;
      var name = el.name || el.id || '';
      if (!name) return;
      if (el.type === 'hidden') return;
      if (isFrameworkField(name)) return;

      var uniqueKey = name + '|' + (el.id || '') + '|' + el.type;
      var rawLabel = findLabel(el);
      rawLabel = rawLabel.replace(/[*:]/g, '').replace(/\s+/g, ' ').trim();
      var labelText = (rawLabel.length > 0 && rawLabel.length <= 80)
        ? rawLabel
        : humanize(name.split('$').pop());
      var type = el.type || el.tagName.toLowerCase();
      var visible = isVisible(el);
      var hiddenContainerId = '';
      if (!visible) {
        var p = el.parentElement;
        while (p) {
          var ps = window.getComputedStyle(p);
          if (ps.display === 'none') {
            hiddenContainerId = p.id || p.className || '';
            break;
          }
          p = p.parentElement;
        }
      }

      if (type === 'radio') {
        var groupKey = name;
        if (!radioGroups[groupKey]) {
          radioGroups[groupKey] = {
            id: el.id, name: name, label: labelText, type: 'radio',
            options: [], visible: visible, hiddenContainer: hiddenContainerId
          };
        }
        if (visible) radioGroups[groupKey].visible = true;
        var optLabel = '';
        var rl = document.querySelector('label[for="' + el.id + '"]');
        if (rl) {
          optLabel = rl.innerText.trim();
        } else {
          var pl = el.closest('label');
          if (pl) {
            optLabel = pl.innerText.trim();
          } else {
            var ns = el.nextSibling;
            if (ns && ns.nodeType === 3) optLabel = ns.textContent.trim();
            if (!optLabel && el.parentElement) {
              var parentText = '';
              for (var c = 0; c < el.parentElement.childNodes.length; c++) {
                var cn = el.parentElement.childNodes[c];
                if (cn === el) continue;
                if (cn.nodeType === 3) parentText += cn.textContent.trim() + ' ';
              }
              optLabel = parentText.trim();
            }
          }
        }
        radioGroups[groupKey].options.push({
          value: el.value, text: optLabel || el.value
        });
        return;
      }

      if (type === 'select-one' || el.tagName === 'SELECT') {
        var options = [];
        el.querySelectorAll('option').forEach(function(o){
          var txt = o.text.trim();
          var val = o.value;
          if (!val || val === '' || val === '0' || val === 'none') return;
          if (txt.replace(/-/g,'').replace(/please select/i,'').trim() === '') return;
          options.push({value: val, text: txt});
        });
        if (!seenIds[uniqueKey]) {
          seenIds[uniqueKey] = true;
          fields.push({
            id: el.id, name: name, label: labelText, type: 'select',
            options: options, visible: visible, hiddenContainer: hiddenContainerId
          });
        }
        return;
      }

      if (type === 'checkbox') {
        if (!seenIds[uniqueKey]) {
          seenIds[uniqueKey] = true;
          fields.push({
            id: el.id, name: name, label: labelText, type: 'checkbox',
            visible: visible, hiddenContainer: hiddenContainerId
          });
        }
        return;
      }

      if (el.readOnly) return;
      if (!seenIds[uniqueKey]) {
        seenIds[uniqueKey] = true;
        fields.push({
          id: el.id, name: name, label: labelText, type: 'text',
          visible: visible, hiddenContainer: hiddenContainerId
        });
      }
    });

    Object.values(radioGroups).forEach(function(rg){ fields.push(rg); });
    return JSON.stringify(fields);
  })();
  """;

  static const String _getSelectsJS = r"""
  (function(){
    var result = [];
    document.querySelectorAll('select').forEach(function(sel){
      var name = sel.name || sel.id || '';
      if (!name) return;
      var opts = [];
      sel.querySelectorAll('option').forEach(function(o){
        var v = o.value;
        if (!v || v === '' || v === '0' || v === 'none') return;
        if (o.text.trim().replace(/-/g,'').replace(/please select/i,'').trim() === '') return;
        opts.push(v);
      });
      if (opts.length > 0) {
        result.push({name: name, id: sel.id, options: opts, original: sel.value});
      }
    });
    return JSON.stringify(result);
  })();
  """;

  static String _setSelectJS(
    String selectorId,
    String selectorName,
    String value,
  ) {
    return """
    (function(){
      var sel = document.getElementById('$selectorId') || document.getElementsByName('$selectorName')[0];
      if (!sel) return 'false';
      sel.value = '$value';
      ['change','input'].forEach(function(evt){
        sel.dispatchEvent(new Event(evt, {bubbles:true}));
      });
      if (window.jQuery) {
        try { window.jQuery(sel).trigger('change'); } catch(e){}
      }
      if (window.\$) {
        try { window.\$('#$selectorId').trigger('change'); } catch(e){}
      }
      return 'true';
    })();
    """;
  }

  static const String _showTabsJS = r"""
  (function(){
    var panes = document.querySelectorAll('.tab-pane:not(.active)');
    var ids = [];
    for (var i = 0; i < panes.length; i++) {
      var pane = panes[i];
      pane.setAttribute('data-orig-display', pane.style.display);
      pane.setAttribute('data-orig-class', pane.className);
      pane.style.display = 'block';
      pane.classList.add('active');
      ids.push(pane.id || 'tab-' + i);
    }
    return JSON.stringify(ids);
  })();
  """;

  static const String _restoreTabsJS = r"""
  (function(){
    var panes = document.querySelectorAll('.tab-pane[data-orig-display]');
    for (var i = 0; i < panes.length; i++) {
      var pane = panes[i];
      pane.style.display = pane.getAttribute('data-orig-display') || '';
      pane.className = pane.getAttribute('data-orig-class') || pane.className;
      pane.removeAttribute('data-orig-display');
      pane.removeAttribute('data-orig-class');
    }
    return 'done';
  })();
  """;

  List _parseJsResult(dynamic raw) {
    if (raw == null) return [];
    if (raw is String) {
      try {
        var decoded = jsonDecode(raw);
        if (decoded is List) return decoded;
        if (decoded is Map) return [decoded];
        return [];
      } catch (_) {
        return [];
      }
    }
    if (raw is List) return raw;
    if (raw is Map) {
      try {
        return raw.values.toList();
      } catch (_) {
        return [raw];
      }
    }
    return [];
  }

  void _mergeFields(List fields, {String? triggeredBy, String? fromTab}) {
    for (var f in fields) {
      if (f is! Map) continue;
      String key = (f['name'] ?? f['id'] ?? '').toString();
      if (key.isEmpty) continue;
      if (!_allFields.containsKey(key)) {
        var entry = Map<String, dynamic>.from(f);
        if (triggeredBy != null) {
          entry['conditional'] = true;
          entry['triggeredBy'] = triggeredBy;
        }
        if (fromTab != null) {
          entry['conditional'] = true;
          entry['fromTab'] = fromTab;
        }
        _allFields[key] = entry;
      } else {
        var existing = _allFields[key]!;
        var newOpts = (f['options'] is List) ? f['options'] as List : [];
        var existOpts = (existing['options'] is List)
            ? existing['options'] as List
            : [];
        if (newOpts.isNotEmpty) {
          Set<String> existingValues = {};
          for (var o in existOpts) {
            if (o is Map) existingValues.add((o['value'] ?? '').toString());
          }
          List merged = List.from(existOpts);
          for (var o in newOpts) {
            if (o is Map) {
              String val = (o['value'] ?? '').toString();
              if (val.isNotEmpty && !existingValues.contains(val)) {
                merged.add(Map<String, dynamic>.from(o));
                existingValues.add(val);
              }
            }
          }
          existing['options'] = merged;
        }
      }
    }
  }

  Future<void> _doInitialScan() async {
    if (_webController == null) return;
    try {
      if (mounted) setState(() => _scanStatus = "Scanning visible fields...");

      var raw = await _webController!.evaluateJavascript(source: _extractorJS);
      var fields = _parseJsResult(raw);
      _mergeFields(fields);

      if (mounted)
        setState(() => _scanStatus = "Deep scanning dropdown variations...");

      var selectsRaw = await _webController!.evaluateJavascript(
        source: _getSelectsJS,
      );
      var selects = _parseJsResult(selectsRaw);

      for (var sel in selects) {
        if (sel is! Map) continue;
        String selName = (sel['name'] ?? '').toString();
        String selId = (sel['id'] ?? '').toString();
        List options = (sel['options'] is List) ? sel['options'] as List : [];
        String originalVal = (sel['original'] ?? '').toString();

        for (var optVal in options) {
          String val = optVal.toString();
          await _webController!.evaluateJavascript(
            source: _setSelectJS(selId, selName, val),
          );
          await Future.delayed(const Duration(milliseconds: 200));
          var scanRaw = await _webController!.evaluateJavascript(
            source: _extractorJS,
          );
          var newFields = _parseJsResult(scanRaw);
          _mergeFields(newFields, triggeredBy: '$selName=$val');
        }

        await _webController!.evaluateJavascript(
          source: _setSelectJS(selId, selName, originalVal),
        );
        await Future.delayed(const Duration(milliseconds: 150));
      }

      if (mounted) setState(() => _scanStatus = "Scanning additional tabs...");

      var tabIdsRaw = await _webController!.evaluateJavascript(
        source: _showTabsJS,
      );
      var tabIds = _parseJsResult(tabIdsRaw);

      await Future.delayed(const Duration(milliseconds: 200));

      var tabScanRaw = await _webController!.evaluateJavascript(
        source: _extractorJS,
      );
      var tabFields = _parseJsResult(tabScanRaw);
      String tabLabel = tabIds.isNotEmpty
          ? tabIds.first.toString()
          : 'other-tab';
      _mergeFields(tabFields, fromTab: tabLabel);

      await _webController!.evaluateJavascript(source: _restoreTabsJS);

      if (mounted) {
        setState(
          () =>
              _scanStatus = "Scan complete! Found ${_allFields.length} fields.",
        );
      }

      if (_allFields.isNotEmpty && mounted) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                VoiceQAScreen(url: widget.url, fieldsMap: _allFields),
          ),
        );
      } else if (mounted) {
        setState(
          () =>
              _scanStatus = "No fields found. The page may still be loading...",
        );
        await Future.delayed(const Duration(seconds: 3));
        if (mounted && _allFields.isEmpty) {
          var retryRaw = await _webController!.evaluateJavascript(
            source: _extractorJS,
          );
          var retryFields = _parseJsResult(retryRaw);
          _mergeFields(retryFields);
          if (_allFields.isNotEmpty && mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    VoiceQAScreen(url: widget.url, fieldsMap: _allFields),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _scanStatus = "Scan error: $e. Retrying...");
      }
      await Future.delayed(const Duration(seconds: 3));
      if (mounted && _allFields.isEmpty) {
        _doInitialScan();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Opacity(
            opacity: 0.0,
            child: SizedBox(
              height: 1,
              child: InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(widget.url)),
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  useWideViewPort: true,
                  domStorageEnabled: true,
                  javaScriptCanOpenWindowsAutomatically: false,
                ),
                onWebViewCreated: (c) => _webController = c,
                onLoadStop: (c, url) async {
                  await Future.delayed(const Duration(milliseconds: 1500));
                  await _doInitialScan();
                },
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0D1B2A),
                  Color(0xFF162032),
                  Color(0xFF1B2838),
                ],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 2 * 3.14159),
                      duration: const Duration(seconds: 3),
                      builder: (context, value, child) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 120 + (sin(value) * 15),
                              height: 120 + (sin(value) * 15),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF6C63FF).withAlpha(40),
                                  width: 1.5,
                                ),
                              ),
                            ),
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF6C63FF).withAlpha(80),
                                  width: 2,
                                ),
                              ),
                            ),
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF6C63FF).withAlpha(50),
                                    const Color(0xFF4ECDC4).withAlpha(50),
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.radar_rounded,
                                color: Color(0xFF6C63FF),
                                size: 32,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
                      ).createShader(bounds),
                      child: const Text(
                        "Scanning Form",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: Text(
                        _scanStatus,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withAlpha(160),
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: 180,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          minHeight: 4,
                          backgroundColor: const Color(0xFF1E2D42),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF6C63FF),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// REVIEW SCREEN
//////////////////////////////////////////////////////////////

class ReviewScreen extends StatefulWidget {
  final String url;
  final Map<String, Map<String, dynamic>> fieldsMap;

  const ReviewScreen({super.key, required this.url, required this.fieldsMap});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  Map<String, dynamic> values = {};
  late Map<String, Map<String, dynamic>> _fieldsMap;

  static const List<String> _keyFieldHints = [
    "application type",
    "applicant category",
    "pan application",
    "category",
    "type of applicant",
    "select category",
    "select type",
    "requesttype",
    "form type",
    "service type",
    "application for",
    "purpose",
  ];

  @override
  void initState() {
    super.initState();
    _fieldsMap = Map.from(widget.fieldsMap);
    _prePopulateFromVault();
  }

  Future<void> _prePopulateFromVault() async {
    final vault = await VaultService.loadVault();
    if (vault.isEmpty || !mounted) return;

    final Map<String, List<String>> vaultToLabels = {
      'fullName': [
        'full name',
        'name of applicant',
        'applicant name',
        'name',
        'first name',
      ],
      'fatherName': ["father's name", 'father name', 'fathername'],
      'motherName': ["mother's name", 'mother name', 'mothername'],
      'dob': ['date of birth', 'dob', 'birth date', 'birthdate'],
      'gender': ['gender', 'sex'],
      'email': ['email', 'e-mail', 'email id', 'email address'],
      'mobile': [
        'mobile',
        'phone',
        'contact',
        'mobile number',
        'phone number',
        'telephone',
      ],
      'panNumber': ['pan', 'pan number', 'pan no', 'pan card'],
      'aadhaarNumber': [
        'aadhaar',
        'aadhar',
        'aadhaar number',
        'aadhaar no',
        'uid',
      ],
      'addressLine1': [
        'address line 1',
        'address1',
        'flat',
        'house',
        'building',
        'street',
        'address',
      ],
      'addressLine2': [
        'address line 2',
        'address2',
        'locality',
        'area',
        'landmark',
      ],
      'city': ['city', 'town', 'district'],
      'state': ['state', 'province'],
      'pincode': [
        'pincode',
        'pin code',
        'pin',
        'zip',
        'postal code',
        'zip code',
      ],
    };

    setState(() {
      for (var field in _fieldsMap.values) {
        final label = (field['label'] ?? '').toString().toLowerCase().trim();
        final name = (field['name'] ?? '').toString();
        if (label.isEmpty || values.containsKey(name)) continue;

        for (var entry in vaultToLabels.entries) {
          final vaultKey = entry.key;
          final patterns = entry.value;
          final vaultVal = vault[vaultKey];
          if (vaultVal == null || vaultVal.isEmpty) continue;

          bool matched = patterns.any((p) => label.contains(p));
          if (!matched) {
            final lowerName = name.toLowerCase();
            matched = patterns.any(
              (p) => lowerName.contains(p.replaceAll(' ', '')),
            );
          }
          if (matched) {
            values[name] = vaultVal;
            break;
          }
        }
      }
    });
  }

  Future<void> _saveFormToVault() async {
    final vault = await VaultService.loadVault();

    final Map<String, List<String>> labelToVault = {
      'fullName': [
        'full name',
        'name of applicant',
        'applicant name',
        'first name',
      ],
      'fatherName': ["father's name", 'father name', 'fathername'],
      'motherName': ["mother's name", 'mother name', 'mothername'],
      'dob': ['date of birth', 'dob', 'birth date'],
      'gender': ['gender', 'sex'],
      'email': ['email', 'e-mail', 'email id', 'email address'],
      'mobile': ['mobile', 'phone', 'contact', 'mobile number', 'phone number'],
      'panNumber': ['pan', 'pan number', 'pan no'],
      'aadhaarNumber': ['aadhaar', 'aadhar', 'aadhaar number', 'aadhaar no'],
      'addressLine1': [
        'address line 1',
        'address1',
        'flat',
        'house',
        'building',
      ],
      'addressLine2': ['address line 2', 'address2', 'locality', 'area'],
      'city': ['city', 'town', 'district'],
      'state': ['state', 'province'],
      'pincode': ['pincode', 'pin code', 'pin', 'zip', 'postal code'],
    };

    for (var field in _fieldsMap.values) {
      final label = (field['label'] ?? '').toString().toLowerCase().trim();
      final name = (field['name'] ?? '').toString();
      final val = values[name];
      if (val == null || val.toString().trim().isEmpty) continue;

      for (var entry in labelToVault.entries) {
        final vaultKey = entry.key;
        final patterns = entry.value;
        if (vault.containsKey(vaultKey) && vault[vaultKey]!.isNotEmpty)
          continue;

        bool matched = patterns.any((p) => label.contains(p));
        if (!matched) {
          final lowerName = name.toLowerCase();
          matched = patterns.any(
            (p) => lowerName.contains(p.replaceAll(' ', '')),
          );
        }
        if (matched) {
          vault[vaultKey] = val.toString();
          break;
        }
      }
    }

    await VaultService.saveVault(vault);
  }

  bool _isKeyField(String label) {
    String lower = label.toLowerCase().replaceAll(' ', '');
    return _keyFieldHints.any(
      (hint) => lower.contains(hint.replaceAll(' ', '')),
    );
  }

  bool _isConditionalField(Map<String, dynamic> field) {
    return field['conditional'] == true ||
        field['visible'] == false ||
        field['triggeredBy'] != null ||
        field['fromTab'] != null;
  }

  void _onValueChanged(String name, dynamic value, String label) {
    setState(() => values[name] = value);
  }

  List<_FieldSection> _buildSections() {
    List<Map<String, dynamic>> visibleFields = [];
    List<Map<String, dynamic>> conditionalFields = [];
    List<Map<String, dynamic>> tabFields = [];

    for (var field in _fieldsMap.values) {
      if (field['fromTab'] != null) {
        tabFields.add(field);
      } else if (_isConditionalField(field)) {
        conditionalFields.add(field);
      } else {
        visibleFields.add(field);
      }
    }

    List<_FieldSection> sections = [];

    if (visibleFields.isNotEmpty) {
      sections.add(
        _FieldSection(
          title: "Main Form Fields",
          icon: Icons.edit_document,
          color: Colors.indigo,
          fields: visibleFields,
        ),
      );
    }

    if (conditionalFields.isNotEmpty) {
      sections.add(
        _FieldSection(
          title: "Conditional Fields (appear on dropdown change)",
          icon: Icons.visibility,
          color: Colors.orange,
          fields: conditionalFields,
        ),
      );
    }

    if (tabFields.isNotEmpty) {
      sections.add(
        _FieldSection(
          title: "Additional Tab Fields",
          icon: Icons.tab,
          color: Colors.teal,
          fields: tabFields,
        ),
      );
    }

    return sections;
  }

  Widget _buildFieldWidget(Map<String, dynamic> field) {
    String label = field['label'] ?? field['name'] ?? '';
    String name = field['name'] ?? field['id'] ?? '';
    bool isKey = _isKeyField(label);
    bool isConditional = _isConditionalField(field);

    if (field['type'] == 'checkbox') {
      return CheckboxListTile(
        title: Text(label),
        subtitle: isConditional
            ? Text(
                field['triggeredBy'] != null
                    ? "Shown when: ${field['triggeredBy']}"
                    : "Conditional field",
                style: TextStyle(fontSize: 11, color: Colors.orange.shade700),
              )
            : null,
        value: values[name] == true,
        onChanged: (v) {
          setState(() => values[name] = v);
          _onValueChanged(name, v, label);
        },
      );
    }

    if (field['type'] == 'radio') {
      List options = field['options'] as List? ?? [];
      if (options.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (isConditional && field['triggeredBy'] != null)
                  Text(
                    "Shown when: ${field['triggeredBy']}",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.orange.shade700,
                    ),
                  ),
                const SizedBox(height: 8),
                ...options.map<Widget>(
                  (o) => RadioListTile(
                    title: Text(o['text'] ?? o['value'] ?? ''),
                    value: o['value'],
                    groupValue: values[name],
                    onChanged: (v) {
                      setState(() => values[name] = v);
                      _onValueChanged(name, v, label);
                    },
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (field['type'] == 'select') {
      List options = field['options'] as List? ?? [];

      dynamic safeValue = values[name];
      if (safeValue != null && !options.any((o) => o['value'] == safeValue)) {
        safeValue = null;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          values.remove(name);
        });
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isKey)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      "Key field — selecting this reveals more options",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            if (isConditional && field['triggeredBy'] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  "Shown when: ${field['triggeredBy']}",
                  style: TextStyle(fontSize: 11, color: Colors.orange.shade700),
                ),
              ),
            DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: InputDecoration(
                labelText: label,
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: isKey
                        ? Colors.orange
                        : isConditional
                        ? Colors.orange.shade300
                        : Colors.grey,
                    width: isKey ? 2 : 1,
                  ),
                ),
              ),
              value: safeValue,
              hint: Text(
                options.isEmpty ? "Loading options..." : "Please select",
                style: const TextStyle(color: Colors.grey),
              ),
              items: options
                  .map<DropdownMenuItem<String>>(
                    (o) => DropdownMenuItem<String>(
                      value: o['value'].toString(),
                      child: Text(
                        o['text'] ?? o['value'] ?? '',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: options.isEmpty
                  ? null
                  : (v) => _onValueChanged(name, v, label),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isConditional && field['triggeredBy'] != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                "Shown when: ${field['triggeredBy']}",
                style: TextStyle(fontSize: 11, color: Colors.orange.shade700),
              ),
            ),
          TextField(
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: isConditional ? Colors.orange.shade300 : Colors.grey,
                ),
              ),
            ),
            onChanged: (v) => _onValueChanged(name, v, label),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<_FieldSection> sections = _buildSections();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Review & Fill"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF4ADE80).withAlpha(30),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 14,
                  color: Color(0xFF4ADE80),
                ),
                const SizedBox(width: 4),
                Text(
                  "${_fieldsMap.length} fields",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4ADE80),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4ADE80).withAlpha(20),
                  const Color(0xFF4ECDC4).withAlpha(20),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF4ADE80).withAlpha(50)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_rounded,
                  color: Color(0xFF4ADE80),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Deep scan complete. Fill in your details below.",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withAlpha(200),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              children: [
                ...sections.expand(
                  (section) => [
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 24,
                            decoration: BoxDecoration(
                              color: section.color,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            section.icon,
                            size: 18,
                            color: section.color.withAlpha(200),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "${section.title} (${section.fields.length})",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: section.color,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...section.fields.map(
                      (f) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: _buildFieldWidget(f),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            decoration: BoxDecoration(
              color: const Color(0xFF1B2838),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(80),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 52,
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
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      await _saveFormToVault();
                      if (!mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AutoFillScreen(url: widget.url, values: values),
                        ),
                      );
                    },
                    icon: const Icon(Icons.bolt_rounded, size: 22),
                    label: const Text(
                      "Start Intelligent Autofill",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldSection {
  final String title;
  final IconData icon;
  final Color color;
  final List<Map<String, dynamic>> fields;

  _FieldSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.fields,
  });
}

//////////////////////////////////////////////////////////////
// AUTOFILL SCREEN — Fixed post-submit rescan
//////////////////////////////////////////////////////////////

class AutoFillScreen extends StatefulWidget {
  final String url;
  final Map<String, dynamic> values;
  const AutoFillScreen({super.key, required this.url, required this.values});

  @override
  State<AutoFillScreen> createState() => _AutoFillScreenState();
}

class _AutoFillScreenState extends State<AutoFillScreen> {
  InAppWebViewController? controller;
  String _status = "Loading page...";
  bool _fillDone = false;
  bool _captchaSolved = false;
  Timer? _captchaTimer;

  Uint8List? _captchaImageBytes;
  final TextEditingController _captchaTextCtrl = TextEditingController();
  bool _captchaExtracted = false;

  bool _formSubmitted = false;
  String? _lastUrl;
  int _pageCount = 1;

  bool _isFilling = false;

  static const List<String> _priorityFieldPatterns = [
    'requesttype',
    'type',
    'category',
    'cat_applicant',
    'applicationtype',
    'formtype',
    'servicetype',
  ];

  bool _isPriorityField(String name) {
    String lower = name.toLowerCase();
    return _priorityFieldPatterns.any((p) => lower.contains(p));
  }

  Future<void> _rescanNewPage(String newUrl) async {
    if (controller == null || !mounted) return;
    _pageCount++;
    setState(() {
      _status = "📄 Page $_pageCount detected. Scanning for form fields...";
      _fillDone = false;
      _captchaSolved = false;
      _captchaExtracted = false;
      _captchaImageBytes = null;
      _formSubmitted = false;
    });
    _captchaTimer?.cancel();

    try {
      final result = await controller!.evaluateJavascript(
        source: _ScanScreenState._extractorJS,
      );

      if (result == null || !mounted) return;

      List<dynamic> rawFields = [];
      try {
        String str = result.toString();
        if (str.startsWith("'") || str.startsWith('"')) str = str.substring(1);
        if (str.endsWith("'") || str.endsWith('"'))
          str = str.substring(0, str.length - 1);
        rawFields = jsonDecode(str) as List<dynamic>;
      } catch (_) {}

      if (rawFields.isEmpty) {
        if (mounted)
          setState(() => _status = "✅ Form completed! No more pages detected.");
        return;
      }

      final Map<String, Map<String, dynamic>> fieldsMap = {};
      for (var f in rawFields) {
        if (f is Map) {
          final name = f['name']?.toString() ?? f['id']?.toString() ?? '';
          if (name.isEmpty) continue;
          fieldsMap[name] = Map<String, dynamic>.from(f);
        }
      }

      if (fieldsMap.isEmpty) {
        if (mounted)
          setState(() => _status = "✅ Form completed! No more pages detected.");
        return;
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => VoiceQAScreen(url: newUrl, fieldsMap: fieldsMap),
          ),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _status = "⚠️ Scan error on new page: $e");
    }
  }

  @override
  void dispose() {
    _captchaTimer?.cancel();
    _captchaTextCtrl.dispose();
    super.dispose();
  }

  Future<void> _extractCaptchaImage() async {
    if (controller == null) return;
    try {
      final result = await controller!.evaluateJavascript(
        source: r"""
        (function(){
          var selectors = [
            'img[id*="captcha" i]', 'img[id*="Captcha"]', 'img[id*="CAPTCHA"]',
            'img[class*="captcha" i]', 'img[src*="captcha" i]',
            'img[alt*="captcha" i]', 'img[alt*="CAPTCHA"]',
            '.captcha img', '#captcha img', '[class*="captcha"] img',
            'img[src*="Captcha"]', 'img[src*="CAPTCHA"]',
            'img[id*="imgCaptcha"]', 'img[id*="CaptchaImage"]',
            '#CaptchaImage', '#imgCaptcha', '#captchaImg'
          ];
          var captchaImg = null;
          for (var i = 0; i < selectors.length; i++) {
            captchaImg = document.querySelector(selectors[i]);
            if (captchaImg) break;
          }
          if (!captchaImg) return JSON.stringify({status: 'no_captcha_image'});
          try {
            var canvas = document.createElement('canvas');
            var w = captchaImg.naturalWidth || captchaImg.width || 200;
            var h = captchaImg.naturalHeight || captchaImg.height || 60;
            canvas.width = w;
            canvas.height = h;
            var ctx = canvas.getContext('2d');
            ctx.drawImage(captchaImg, 0, 0, w, h);
            var dataUrl = canvas.toDataURL('image/png');
            var base64 = dataUrl.split(',')[1];
            var captchaInput = document.querySelector(
              'input[name*="captcha" i], input[id*="captcha" i], ' +
              'input[name*="Captcha"], input[id*="Captcha"], ' +
              'input[name*="CAPTCHA"], input[id*="CAPTCHA"], ' +
              'input[name*="txtCaptcha"], input[id*="txtCaptcha"]'
            );
            var inputName = captchaInput ? (captchaInput.name || captchaInput.id || '') : '';
            return JSON.stringify({status: 'found', base64: base64, inputName: inputName});
          } catch(e) {
            return JSON.stringify({status: 'canvas_error', error: e.message});
          }
        })();
        """,
      );

      if (result == null) return;
      String resultStr = result.toString();
      if (resultStr.startsWith("'") || resultStr.startsWith('"'))
        resultStr = resultStr.substring(1);
      if (resultStr.endsWith("'") || resultStr.endsWith('"'))
        resultStr = resultStr.substring(0, resultStr.length - 1);
      final data = jsonDecode(resultStr);
      if (data['status'] == 'found' && data['base64'] != null) {
        final bytes = base64Decode(data['base64']);
        if (mounted) {
          setState(() {
            _captchaImageBytes = bytes;
            _captchaExtracted = true;
            _status = "✅ Autofill complete. Enter CAPTCHA below, then submit.";
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _injectCaptchaText(String text) async {
    if (controller == null) return;
    final escaped = text.replaceAll("'", "\\'");
    await controller!.evaluateJavascript(
      source:
          """
      (function(){
        var inputs = document.querySelectorAll(
          'input[name*="captcha" i], input[id*="captcha" i], ' +
          'input[name*="Captcha"], input[id*="Captcha"], ' +
          'input[name*="CAPTCHA"], input[id*="CAPTCHA"], ' +
          'input[name*="txtCaptcha"], input[id*="txtCaptcha"]'
        );
        for (var i = 0; i < inputs.length; i++) {
          if (inputs[i].type !== 'hidden') {
            inputs[i].value = '$escaped';
            inputs[i].dispatchEvent(new Event('input', {bubbles: true}));
            inputs[i].dispatchEvent(new Event('change', {bubbles: true}));
            break;
          }
        }
      })();
      """,
    );
  }

  Future<void> _startCaptchaPolling() async {
    _captchaTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (controller == null || _captchaSolved) return;
      try {
        var result = await controller!.evaluateJavascript(
          source: r"""
          (function(){
            var bodyText = document.body ? document.body.innerText.toLowerCase() : '';
            var isOTP = bodyText.includes('enter otp') ||
                        bodyText.includes('one time password') ||
                        bodyText.includes('verification code') ||
                        (document.querySelector('input[maxlength="6"], input[maxlength="4"]') !== null &&
                         !document.querySelector('.g-recaptcha, [id*="captcha"], [id*="Captcha"]'));
            if (isOTP) return 'otp_page';

            var recaptchaResponse = '';
            try {
              if (typeof grecaptcha !== 'undefined') {
                recaptchaResponse = grecaptcha.getResponse() || '';
              }
            } catch(e){}

            if (!recaptchaResponse) {
              var textarea = document.getElementById('g-recaptcha-response');
              if (textarea) recaptchaResponse = textarea.value || '';
            }

            if (!recaptchaResponse) {
              var captchaInputs = document.querySelectorAll(
                'input[name*="captcha"], input[id*="captcha"], ' +
                'input[name*="Captcha"], input[id*="Captcha"]'
              );
              for (var i = 0; i < captchaInputs.length; i++) {
                if (captchaInputs[i].value && captchaInputs[i].value.length > 0) {
                  recaptchaResponse = captchaInputs[i].value;
                  break;
                }
              }
            }

            var hasCaptcha = document.querySelector(
              '.g-recaptcha, [id*="captcha"], [id*="Captcha"], [name*="captcha"]'
            );
            if (!hasCaptcha) return 'no_captcha';

            return recaptchaResponse.length > 0 ? 'solved' : 'pending';
          })();
          """,
        );

        String status = (result ?? '')
            .toString()
            .replaceAll('"', '')
            .replaceAll("'", '');

        if (status == 'otp_page') {
          _captchaTimer?.cancel();
          if (mounted) {
            setState(
              () => _status =
                  "📱 OTP sent. Enter it in the page above, then tap Verify.",
            );
          }
          return;
        }

        if (status == 'solved' || status == 'no_captcha') {
          _captchaTimer?.cancel();
          if (mounted) {
            setState(() {
              _captchaSolved = true;
              _status = status == 'no_captcha'
                  ? "✅ No CAPTCHA detected. Auto-submitting..."
                  : "✅ CAPTCHA solved! Auto-submitting...";
            });
            await Future.delayed(const Duration(milliseconds: 500));
            if (mounted) await _submitForm();
          }
        }
      } catch (_) {}
    });
  }

  Future<void> _submitForm() async {
    if (controller == null) return;
    setState(() => _status = "Submitting form...");

    try {
      await controller!.evaluateJavascript(
        source: r"""
        (function(){
          var activePane = document.querySelector('.tab-pane.active.in, .tab-pane.active.show, .tab-pane.active');
          var searchRoot = activePane || document;

          function isElVisible(el) {
            if (!el) return false;
            var s = window.getComputedStyle(el);
            if (s.display === 'none' || s.visibility === 'hidden') return false;
            var p = el.parentElement;
            while (p) {
              var ps = window.getComputedStyle(p);
              if (ps.display === 'none' || ps.visibility === 'hidden') return false;
              p = p.parentElement;
            }
            return true;
          }

          var submitBtns = searchRoot.querySelectorAll('input[type="submit"], button[type="submit"]');
          for (var i = 0; i < submitBtns.length; i++) {
            if (isElVisible(submitBtns[i])) { submitBtns[i].click(); return 'clicked_submit_in_active'; }
          }

          var commonIds = ['btnSubmit', 'submitBtn', 'submit', 'Submit', 'btn_submit',
                           'btnsubmit', 'SubmitBtn', 'submitButton', 'btnProceed'];
          for (var i = 0; i < commonIds.length; i++) {
            var btn = searchRoot.querySelector('#' + commonIds[i]);
            if (btn && isElVisible(btn)) { btn.click(); return 'clicked_' + commonIds[i]; }
          }

          var allBtns = searchRoot.querySelectorAll('button, input[type="button"], a.btn, a.button');
          for (var i = 0; i < allBtns.length; i++) {
            if (!isElVisible(allBtns[i])) continue;
            var txt = (allBtns[i].innerText || allBtns[i].value || '').toLowerCase().trim();
            if (txt === 'submit' || txt === 'proceed' || txt === 'continue' ||
                txt === 'next' || txt === 'apply' || txt === 'send') {
              allBtns[i].click();
              return 'clicked_text_' + txt;
            }
          }

          if (typeof submitForm === 'function') {
            try { submitForm(); return 'called_submitForm'; } catch(e){}
          }

          var forms = searchRoot.querySelectorAll('form');
          for (var i = 0; i < forms.length; i++) {
            if (isElVisible(forms[i])) {
              forms[i].submit();
              return 'form_submit_active';
            }
          }

          return 'no_submit_found';
        })();
        """,
      );

      if (mounted) {
        setState(() {
          _status = "✅ Form submitted! Waiting for response...";
          _formSubmitted = true;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _status = "⚠️ Submit error: $e");
    }
  }

  Future<void> fill() async {
    if (controller == null || !mounted) return;

    // ── Detect OTP page at start of fill ──
    try {
      final pageCheck = await controller!.evaluateJavascript(
        source: r"""
        (function(){
          var url = window.location.href.toLowerCase();
          var bodyText = document.body ? document.body.innerText.toLowerCase() : '';
          var isOTP =
            url.includes('otp') ||
            bodyText.includes('enter otp') ||
            bodyText.includes('one time password') ||
            bodyText.includes('verification code') ||
            (document.querySelector('input[maxlength="6"], input[maxlength="4"]') !== null &&
             !document.querySelector('.g-recaptcha, [id*="captcha"], [id*="Captcha"]'));
          return isOTP ? 'otp_page' : 'normal_page';
        })();
      """,
      );

      if (pageCheck.toString().contains('otp_page')) {
        if (mounted) {
          setState(
            () => _status =
                "📱 OTP sent to your mobile/email. Enter it in the page above.",
          );
        }
        _isFilling = false;
        return;
      }
    } catch (_) {}

    setState(() => _status = "Phase 1: Filling key dropdowns first...");

    const String simulateScript = r"""
      function simulateInteraction(el, value) {
        if (!el) return;
        if (el.tagName === 'SELECT') {
          el.value = value;
          ['mousedown','mouseup','focus','change','input','blur'].forEach(function(evt){
            el.dispatchEvent(new Event(evt, {bubbles: true}));
          });
          if (window.jQuery) {
            try { window.jQuery(el).val(value).trigger('change'); } catch(e){}
          }
          return;
        }
        if (el.type === 'checkbox') {
          el.checked = (value === 'true' || value === true);
        } else if (el.type === 'radio') {
          el.checked = true;
          try { el.click(); } catch(e) {}
        } else {
          el.focus();
          el.value = '';
          el.value = value;
        }
        ['mousedown','mouseup','click','focus','input','change','blur'].forEach(function(evt){
          el.dispatchEvent(new Event(evt, {bubbles: true}));
        });
      }

      function findElement(key) {
        var els = document.getElementsByName(key);
        if (els && els.length > 0) return els;
        var byId = document.getElementById(key);
        if (byId) return [byId];
        return null;
      }

      function fillField(key, value) {
        var els = findElement(key);
        if (!els || els.length === 0) return false;
        if (els[0].type === 'radio') {
          for (var i = 0; i < els.length; i++) {
            if (els[i].value == value) {
              simulateInteraction(els[i], value);
              return true;
            }
          }
        } else {
          simulateInteraction(els[0], value);
          return true;
        }
        return false;
      }
    """;

    await controller!.evaluateJavascript(source: simulateScript);

    Map<String, dynamic> priorityFields = {};
    Map<String, dynamic> otherFields = {};

    for (var entry in widget.values.entries) {
      if (_isPriorityField(entry.key)) {
        priorityFields[entry.key] = entry.value;
      } else {
        otherFields[entry.key] = entry.value;
      }
    }

    for (var entry in priorityFields.entries) {
      String key = entry.key;
      String value = entry.value.toString();
      await controller!.evaluateJavascript(
        source: "fillField('$key', '$value');",
      );
      await Future.delayed(const Duration(milliseconds: 800));
    }

    setState(() => _status = "Phase 2: Filling remaining fields...");
    await Future.delayed(const Duration(milliseconds: 500));

    for (var entry in otherFields.entries) {
      if (entry.value == null) continue;
      String key = entry.key;
      String value = entry.value.toString().replaceAll("'", "\\'");
      await controller!.evaluateJavascript(
        source: "fillField('$key', '$value');",
      );
      await Future.delayed(const Duration(milliseconds: 100));
    }

    setState(() => _status = "Phase 3: Verifying all fields...");
    await Future.delayed(const Duration(milliseconds: 500));

    for (var entry in priorityFields.entries) {
      String key = entry.key;
      String value = entry.value.toString();
      await controller!.evaluateJavascript(
        source: "fillField('$key', '$value');",
      );
      await Future.delayed(const Duration(milliseconds: 300));
    }

    for (var entry in otherFields.entries) {
      if (entry.value == null) continue;
      String key = entry.key;
      String value = entry.value.toString().replaceAll("'", "\\'");
      await controller!.evaluateJavascript(
        source: "fillField('$key', '$value');",
      );
    }

    setState(() {
      _fillDone = true;
      _status = "✅ Autofill complete. Solve CAPTCHA if shown, then tap Submit.";
    });

    await _extractCaptchaImage();
    _startCaptchaPolling();
  }

  @override
  Widget build(BuildContext context) {
    final bool isSubmitReady = _captchaSolved;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Autofilling Form"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.url)),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              useWideViewPort: true,
              domStorageEnabled: true,
            ),
            onWebViewCreated: (c) => controller = c,
            // ─────────────────────────────────────────────────
            // FIXED onLoadStop: _formSubmitted is checked FIRST,
            // before the _isFilling guard, so post-submit page
            // loads are never blocked and always trigger rescan.
            // ─────────────────────────────────────────────────
            onLoadStop: (c, url) async {
              final currentUrl = url?.toString() ?? '';
              if (currentUrl.isEmpty) return;
              if (currentUrl == _lastUrl) return;

              // ── PRIORITY: post-submit page → always rescan ──
              if (_formSubmitted) {
                _isFilling = false; // reset guard so rescan proceeds
                _lastUrl = currentUrl;
                await Future.delayed(const Duration(milliseconds: 2000));
                if (!mounted) return;
                await _rescanNewPage(currentUrl);
                return;
              }

              // ── Guard against re-entrant fills ──
              if (_isFilling) return;

              _lastUrl = currentUrl;
              _isFilling = true;

              await Future.delayed(const Duration(milliseconds: 1500));

              // ── Page-type detection ──
              try {
                final pageCheck = await controller!.evaluateJavascript(
                  source: r"""
                  (function(){
                    var url = window.location.href.toLowerCase();
                    var bodyText = document.body ? document.body.innerText.toLowerCase() : '';
                    var isOTP =
                      url.includes('otp') ||
                      bodyText.includes('enter otp') ||
                      bodyText.includes('one time password') ||
                      bodyText.includes('verification code') ||
                      (document.querySelector('input[maxlength="6"], input[maxlength="4"]') !== null &&
                       !document.querySelector('.g-recaptcha, [id*="captcha"], [id*="Captcha"]'));
                    if (isOTP) return 'otp_page';
                    return 'normal_page';
                  })();
                """,
                );

                final pageType = pageCheck
                    .toString()
                    .replaceAll('"', '')
                    .replaceAll("'", '');

                if (pageType == 'otp_page') {
                  if (mounted) {
                    setState(
                      () => _status =
                          "📱 OTP sent to your mobile/email. Enter it in the page above.",
                    );
                  }
                  _isFilling = false;
                  return;
                }
              } catch (_) {}

              await fill();
              _isFilling = false;
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2838),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(120),
                    blurRadius: 30,
                    offset: const Offset(0, -8),
                  ),
                ],
                border: Border(
                  top: BorderSide(color: const Color(0xFF6C63FF).withAlpha(40)),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _fillDone
                                ? (isSubmitReady
                                      ? const Color(0xFF4ADE80)
                                      : const Color(0xFFFBBF24))
                                : const Color(0xFF6C63FF),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (_fillDone
                                            ? (isSubmitReady
                                                  ? const Color(0xFF4ADE80)
                                                  : const Color(0xFFFBBF24))
                                            : const Color(0xFF6C63FF))
                                        .withAlpha(150),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _status,
                            style: TextStyle(
                              color: Colors.white.withAlpha(200),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_fillDone &&
                        _captchaExtracted &&
                        _captchaImageBytes != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF162032),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFFBBF24).withAlpha(40),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.shield_outlined,
                                  color: Color(0xFFFBBF24),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Enter CAPTCHA",
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(200),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: Image.memory(
                                  _captchaImageBytes!,
                                  height: 50,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 44,
                              child: TextField(
                                controller: _captchaTextCtrl,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  letterSpacing: 3,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  hintText: "Type CAPTCHA here",
                                  hintStyle: TextStyle(
                                    color: Colors.white.withAlpha(60),
                                    fontSize: 13,
                                    letterSpacing: 1,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFF1E2D42),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: const Color(
                                        0xFFFBBF24,
                                      ).withAlpha(50),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFFBBF24),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                onChanged: (val) {
                                  if (val.isNotEmpty) _injectCaptchaText(val);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (_fillDone) ...[
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isSubmitReady
                                  ? [
                                      const Color(0xFF4ADE80),
                                      const Color(0xFF22C55E),
                                    ]
                                  : [
                                      const Color(0xFFFBBF24),
                                      const Color(0xFFF59E0B),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (isSubmitReady
                                            ? const Color(0xFF4ADE80)
                                            : const Color(0xFFFBBF24))
                                        .withAlpha(60),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: isSubmitReady
                                  ? const Color(0xFF052E16)
                                  : const Color(0xFF451A03),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _submitForm,
                            icon: Icon(
                              isSubmitReady
                                  ? Icons.send_rounded
                                  : Icons.shield_outlined,
                              size: 20,
                            ),
                            label: Text(
                              isSubmitReady
                                  ? "Submit Form"
                                  : "Solve CAPTCHA & Submit",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

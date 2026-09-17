import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/auth_theme.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../widgets/auth_text_field.dart';

/// Écran unique Connexion / Inscription avec bascule d'onglet, fidèle aux
/// maquettes "connexion_mode_sombre" et "inscription_mode_sombre".
///
/// Aucun backend d'authentification n'existe dans ce projet (le reste de
/// l'app va directement au Dashboard) : la soumission appelle simplement
/// [onAuthenticated].
class AuthPage extends StatefulWidget {
  const AuthPage({super.key, this.onAuthenticated});

  final VoidCallback? onAuthenticated;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _rememberDevice = false;
  bool _localBackup = true;
  bool _acceptTerms = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();

  static const _roles = [
    'Ingénieur QA / Testeur matériel',
    'Développeur Kernel / Bas niveau',
    'Administrateur Systèmes & Infrastructure',
    'Intégrateur OEM / Validation R&D',
    'Chercheur Sécurité / Reverse Engineering',
  ];
  String _selectedRole = _roles.first;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  /// Force du mot de passe, purement indicative (longueur + variété de
  /// caractères), 0 à 3 barres remplies.
  int get _passwordStrength {
    final pwd = _passwordController.text;
    if (pwd.isEmpty) return 0;
    var score = 0;
    if (pwd.length >= 8) score++;
    if (RegExp(r'[0-9]').hasMatch(pwd) && RegExp(r'[A-Z]').hasMatch(pwd)) {
      score++;
    }
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(pwd)) score++;
    return score.clamp(0, 3);
  }

  void _submit() {
    if (!_isLogin && !_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Merci d\'accepter les conditions générales pour continuer.',
          ),
        ),
      );
      return;
    }
    if (widget.onAuthenticated != null) {
      widget.onAuthenticated!.call();
      return;
    }
    // Pas de routeur dédié dans le projet pour l'instant : par défaut,
    // la soumission mène directement au Dashboard.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildTabSwitcher(),
              const SizedBox(height: 20),
              _buildCard(),
              const SizedBox(height: 20),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AuthColors.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.memory, color: AuthColors.primary, size: 26),
        ),
        const SizedBox(height: 12),
        Text(
          _isLogin ? 'Bienvenue sur DeviceSpecs' : 'Créer un compte',
          textAlign: TextAlign.center,
          style: AuthText.headline(),
        ),
        const SizedBox(height: 6),
        Text(
          _isLogin
              ? 'Identifiez-vous pour synchroniser vos diagnostics système et profils matériels.'
              : 'Rejoignez DeviceSpecs pour analyser, archiver et exporter vos rapports matériels.',
          textAlign: TextAlign.center,
          style: AuthText.bodySm(),
        ),
      ],
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AuthColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(child: _tabButton('Connexion', true)),
          Expanded(child: _tabButton('Inscription', false)),
        ],
      ),
    );
  }

  Widget _tabButton(String label, bool isLoginTab) {
    final selected = _isLogin == isLoginTab;
    return GestureDetector(
      onTap: () => setState(() => _isLogin = isLoginTab),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AuthColors.surfaceContainerHighest : null,
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AuthText.body(
            color: selected ? AuthColors.primary : AuthColors.secondary,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AuthColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (_isLogin) ..._loginFields() else ..._signupFields(),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AuthColors.primary,
                foregroundColor: AuthColors.surfaceContainerLowest,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLogin ? 'Se connecter' : 'Créer mon compte',
                    style: AuthText.body(
                      color: AuthColors.surfaceContainerLowest,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),
          if (_isLogin) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _submit,
                icon: const Icon(
                  Icons.fingerprint,
                  color: AuthColors.secondary,
                ),
                label: Text(
                  'Connexion biométrique rapide',
                  style: AuthText.body(color: AuthColors.primary),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: AuthColors.surfaceContainerLow,
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              const Expanded(
                child: Divider(color: AuthColors.surfaceVariant),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  _isLogin ? 'OU CONTINUER AVEC' : "OU S'INSCRIRE AVEC",
                  style: AuthText.labelCaps(),
                ),
              ),
              const Expanded(
                child: Divider(color: AuthColors.surfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ssoButton('Compte Google Workspace'),
          const SizedBox(height: 8),
          _ssoButton('GitHub Enterprise / SSO'),
        ],
      ),
    );
  }

  List<Widget> _loginFields() {
    return [
      AuthTextField(
        label: 'Adresse e-mail professionnelle',
        icon: Icons.alternate_email,
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
      ),
      const SizedBox(height: 14),
      AuthTextField(
        label: 'Mot de passe',
        icon: Icons.lock_outline,
        controller: _passwordController,
        obscureText: _obscurePassword,
        suffixIcon: _obscurePassword
            ? Icons.visibility_outlined
            : Icons.visibility_off_outlined,
        onSuffixTap: () =>
            setState(() => _obscurePassword = !_obscurePassword),
      ),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => setState(() => _rememberDevice = !_rememberDevice),
            child: Row(
              children: [
                Checkbox(
                  value: _rememberDevice,
                  onChanged: (v) =>
                      setState(() => _rememberDevice = v ?? false),
                  activeColor: AuthColors.primary,
                  checkColor: AuthColors.surfaceContainerLowest,
                ),
                Text('Se souvenir de cet appareil', style: AuthText.bodySm()),
              ],
            ),
          ),
          Text(
            'Mot de passe oublié ?',
            style: AuthText.bodySm().copyWith(
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
    ];
  }

  List<Widget> _signupFields() {
    final strength = _passwordStrength;
    return [
      AuthTextField(
        label: 'Nom complet',
        icon: Icons.badge_outlined,
        controller: _fullNameController,
      ),
      const SizedBox(height: 14),
      AuthTextField(
        label: 'Adresse e-mail',
        icon: Icons.mail_outline,
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
      ),
      const SizedBox(height: 14),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RÔLE / SPÉCIALITÉ TECHNIQUE',
            style: AuthText.labelCaps().copyWith(letterSpacing: 0.05),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: AuthColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(6),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedRole,
                isExpanded: true,
                dropdownColor: AuthColors.surfaceContainerHigh,
                icon: const Icon(
                  Icons.expand_more,
                  color: AuthColors.secondary,
                ),
                style: AuthText.body(color: AuthColors.primary),
                items: _roles
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _selectedRole = v ?? _selectedRole),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
      AuthTextField(
        label: 'Mot de passe',
        icon: Icons.lock_outline,
        controller: _passwordController,
        obscureText: _obscurePassword,
        suffixIcon: _obscurePassword
            ? Icons.visibility_outlined
            : Icons.visibility_off_outlined,
        onSuffixTap: () {
          setState(() => _obscurePassword = !_obscurePassword);
        },
      ),
      const SizedBox(height: 6),
      Row(
        children: List.generate(3, (i) {
          final filled = i < strength;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i == 2 ? 0 : 6),
              height: 4,
              decoration: BoxDecoration(
                color: filled
                    ? AuthColors.primary
                    : AuthColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
      const SizedBox(height: 14),
      AuthTextField(
        label: 'Confirmer le mot de passe',
        icon: Icons.check_circle_outline,
        controller: _confirmPasswordController,
        obscureText: _obscureConfirm,
        suffixIcon: _obscureConfirm
            ? Icons.visibility_outlined
            : Icons.visibility_off_outlined,
        onSuffixTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
      ),
      const SizedBox(height: 12),
      _consentCheckbox(
        value: _localBackup,
        onChanged: (v) => setState(() => _localBackup = v),
        label: 'Activer la sauvegarde locale chiffrée des benchmarks',
      ),
      _consentCheckbox(
        value: _acceptTerms,
        onChanged: (v) => setState(() => _acceptTerms = v),
        label:
            "J'accepte les Conditions Générales et la Politique de Confidentialité",
      ),
      const SizedBox(height: 4),
    ];
  }

  Widget _consentCheckbox({
    required bool value,
    required ValueChanged<bool> onChanged,
    required String label,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: value,
              onChanged: (v) => onChanged(v ?? false),
              activeColor: AuthColors.primary,
              checkColor: AuthColors.surfaceContainerLowest,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(label, style: AuthText.bodySm()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ssoButton(String label) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          backgroundColor: AuthColors.surfaceContainerLow,
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: Text(label, style: AuthText.body(color: AuthColors.primary)),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: AuthText.bodySm(),
            children: [
              TextSpan(
                text: _isLogin
                    ? "Vous n'avez pas encore de compte ? "
                    : 'Vous avez déjà un compte ? ',
              ),
              TextSpan(
                text: _isLogin ? 'Créer un compte' : 'Se connecter',
                style: AuthText.bodySm(
                  color: AuthColors.primary,
                ).copyWith(decoration: TextDecoration.underline),
                recognizer: TapGestureRecognizer(
                  onTap: () => setState(() => _isLogin = !_isLogin),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shield_outlined, size: 14, color: AuthColors.secondary),
            const SizedBox(width: 6),
            Text(
              'Chiffrement matériel local AES-256 • Conforme RGPD',
              style: AuthText.labelCaps(),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vihomeapp/core/router/guest_access_guard.dart';
import 'package:vihomeapp/core/theme/app_theme.dart';
import 'package:vihomeapp/core/utils/ui_feedback.dart';
import 'package:vihomeapp/domain/entities/guest_redirect_context.dart';
import 'package:vihomeapp/presentation/widgets/guest_auth_banner.dart';
import '../../providers/auth_provider.dart';
import '../../providers/subscription_provider.dart';

class LoginPage extends StatefulWidget {
  final GuestRedirectContext? redirectContext;

  const LoginPage({
    super.key,
    this.redirectContext,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).clearError();
    });
  }

  @override
  void dispose() {
    GuestAccessGuard.resetDebounce();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleExitAsGuest() {
    GuestAccessGuard.resetDebounce();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError();

    final success = await authProvider.signInWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      final subscriptionProvider =
          Provider.of<SubscriptionProvider>(context, listen: false);
      await subscriptionProvider.initialize(authProvider.user?.id);
      if (mounted) context.go('/home');
    } else if (!success && mounted) {
      context.showError(authProvider.errorMessage ?? 'Error al iniciar sesión');
    }
  }

  Future<void> _handleGoogleLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError();

    final success = await authProvider.signInWithGoogle();

    if (success && mounted) {
      final subscriptionProvider =
          Provider.of<SubscriptionProvider>(context, listen: false);
      await subscriptionProvider.initialize(authProvider.user?.id);
      if (mounted) context.go('/home');
    } else if (!success && mounted) {
      context.showError(
          authProvider.errorMessage ?? 'Error al iniciar sesión con Google');
    }
  }

  Future<void> _handleForgotPassword() async {
    final uri = Uri.parse('https://vihome.web.app/forgot-password');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bannerMessage =
        (widget.redirectContext?.showRestrictionBanner ?? false)
            ? widget.redirectContext?.bannerMessage
            : null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleExitAsGuest();
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: Semantics(
            button: true,
            label: 'Volver a explorar como invitado',
            child: IconButton(
              key: const Key('login_back_button'),
              icon: const Icon(Icons.arrow_back, color: textColor),
              tooltip: 'Volver',
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              onPressed: _handleExitAsGuest,
            ),
          ),
        ),
        body: SafeArea(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 24.0),
              child: Form(
                key: _formKey,
                child: Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (bannerMessage != null && bannerMessage.isNotEmpty) ...[
                          GuestAuthBanner(message: bannerMessage),
                          const SizedBox(height: 16),
                        ],
                        const SizedBox(height: 16),
                        const Icon(
                          Icons.lock_outline,
                          size: 80,
                          color: primaryColor,
                        ),
                    const SizedBox(height: 24),
                    const Text(
                      'Bienvenido',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Inicia sesión en tu cuenta',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu email';
                        }
                        if (!value.contains('@')) {
                          return 'Email inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      obscureText: _obscurePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu contraseña';
                        }
                        if (value.length < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _handleForgotPassword,
                        child: const Text(
                          '¿Olvidaste tu contraseña?',
                          style: TextStyle(color: secondaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: authProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Iniciar Sesión',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(height: 24),
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Flexible(
                          flex: 2,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'O inicia sesión con',
                              style: TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed:
                          authProvider.isLoading ? null : _handleGoogleLogin,
                      icon: Image.network(
                        'https://www.gstatic.com/images/branding/product/1x/gsa_512dp.png',
                        cacheWidth: 48,
                        height: 24,
                        width: 24,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback para cuando no hay internet o en tests de widgets
                          return const Icon(Icons.g_mobiledata,
                              size: 30, color: Colors.blue);
                        },
                      ),
                      label: const Text(
                        'Continuar con Google',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text('¿No tienes cuenta? '),
                        TextButton(
                          onPressed: () {
                            Provider.of<AuthProvider>(context, listen: false)
                                .clearError();
                            context.push('/register');
                          },
                          child: const Text(
                            'Regístrate',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: secondaryColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Semantics(
                      button: true,
                      label: 'Continuar como invitado',
                      child: TextButton(
                        key: const Key('continue_as_guest_button'),
                        onPressed:
                            authProvider.isLoading ? null : _handleExitAsGuest,
                        style: TextButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          foregroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Continuar como invitado',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    ),
  ),
    );
  }
}

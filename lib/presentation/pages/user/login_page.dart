import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vihomeapp/core/theme/app_theme.dart';
import 'package:vihomeapp/core/utils/ui_feedback.dart';
import '../../providers/auth_provider.dart';
import '../../providers/subscription_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _resetPasswordEmailController = TextEditingController();
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
    _emailController.dispose();
    _passwordController.dispose();
    _resetPasswordEmailController.dispose();
    super.dispose();
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

  void _showForgotPasswordDialog() {
    _resetPasswordEmailController.text = _emailController.text;
    final formKey = GlobalKey<FormState>();
    final pageContext = context;

    showDialog(
      context: pageContext,
      builder: (dialogContext) {
        bool isDialogLoading = false;
        String? dialogError;
        bool isSuccess = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: isSuccess
                  ? null
                  : const Row(
                      children: [
                        Icon(Icons.lock_reset_outlined, color: primaryColor),
                        SizedBox(width: 10),
                        Text(
                          'Recuperar contraseña',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
              content: isSuccess
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_outline,
                            color: Colors.green, size: 64),
                        const SizedBox(height: 16),
                        const Text(
                          '¡Correo enviado!',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Hemos enviado un enlace a tu correo electrónico para que puedas restablecer tu contraseña.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    )
                  : Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _resetPasswordEmailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (_) {
                              if (dialogError != null) {
                                setDialogState(() {
                                  dialogError = null;
                                });
                              }
                            },
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
                          if (dialogError != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    dialogError!
                                                .toLowerCase()
                                                .contains('internet') ||
                                            dialogError!
                                                .toLowerCase()
                                                .contains('conexión')
                                        ? Icons.wifi_off_rounded
                                        : Icons.error_outline_rounded,
                                    color: Colors.red.shade700,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      dialogError!,
                                      style: TextStyle(
                                        color: Colors.red.shade800,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
              actions: isSuccess
                  ? [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Entendido'),
                        ),
                      ),
                    ]
                  : [
                      TextButton(
                        onPressed: isDialogLoading
                            ? null
                            : () => Navigator.of(dialogContext).pop(),
                        child: const Text('Cancelar',
                            style: TextStyle(color: Colors.grey)),
                      ),
                      ElevatedButton(
                        onPressed: isDialogLoading
                            ? null
                            : () async {
                                if (isDialogLoading) return;
                                if (!formKey.currentState!.validate()) return;
                                setDialogState(() {
                                  isDialogLoading = true;
                                  dialogError = null;
                                });

                                try {
                                  final authProvider =
                                      Provider.of<AuthProvider>(pageContext,
                                          listen: false);
                                  final success =
                                      await authProvider.resetPassword(
                                          _resetPasswordEmailController.text
                                              .trim());

                                  if (!dialogContext.mounted) return;

                                  setDialogState(() {
                                    isDialogLoading = false;
                                    if (success) {
                                      isSuccess = true;
                                    } else {
                                      dialogError = authProvider.errorMessage ??
                                          'No se pudo enviar el correo de recuperación';
                                    }
                                  });
                                } catch (e) {
                                  if (!dialogContext.mounted) return;
                                  setDialogState(() {
                                    isDialogLoading = false;
                                    dialogError =
                                        'Ocurrió un error inesperado al procesar la solicitud.';
                                  });
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: isDialogLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text('Enviar'),
                      ),
                    ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
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
                        onPressed: _showForgotPasswordDialog,
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
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('O inicia sesión con',
                              style: TextStyle(color: Colors.grey)),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

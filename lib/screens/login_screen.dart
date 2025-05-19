import 'package:flutter/material.dart';
import 'package:lynxgaming/constant/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _gameIdController = TextEditingController();
  final TextEditingController _serverIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? error;

  void handleLogin() {
    final gameId = _gameIdController.text.trim();
    final serverId = _serverIdController.text.trim();
    final password = _passwordController.text;

    if (gameId.isEmpty || serverId.isEmpty || password.isEmpty) {
      setState(() => error = 'Please fill in all fields');
      return;
    }

    // Navigate to main screen
    Navigator.pushReplacementNamed(context, '/tabs');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SizedBox(
            height: 200,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  'https://images.pexels.com/photos/3165335/pexels-photo-3165335.jpeg',
                  fit: BoxFit.cover,
                ),
                Container(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.6),
                  child: Center(
                    child: Text(
                      'LYNX GAMING',
                      style: AppTypography.titleLarge,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.large),
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.large),
                    Text('LOGIN', style: AppTypography.titleMedium),
                    if (error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.medium),
                        child: Text(
                          error!,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.large),
                    _buildInputField('GAME ID', _gameIdController, 'Enter your Game ID'),
                    _buildInputField('SERVER ID', _serverIdController, 'Enter your Server ID'),
                    _buildInputField(
                      'PASSWORD',
                      _passwordController,
                      'Enter your password',
                      obscureText: true,
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.medium),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: handleLogin,
                        child: Text('LOGIN', style: AppTypography.buttonText),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.large),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: AppTypography.bodySmall,
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/register'),
                          child: Text(
                            'Register',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, String hint, {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.caption),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            obscureText: obscureText,
            style: AppTypography.bodyMedium,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTypography.caption,
              filled: true,
              fillColor: AppColors.cardBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.backgroundDarker),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.backgroundDarker),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.accent),
              ),
              contentPadding: const EdgeInsets.all(AppSpacing.medium),
            ),
          ),
        ],
      ),
    );
  }
}

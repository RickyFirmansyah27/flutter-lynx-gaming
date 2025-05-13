

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:lynxgaming/constant/theme.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ConnectionState { disconnected, connecting, connected }

class ActiveConfig {
  final String configUrl;
  final String remark;
  ConnectionState state;
  bool isConnecting;

  ActiveConfig({
    required this.configUrl,
    required this.remark,
    this.state = ConnectionState.disconnected,
    this.isConnecting = false,
  });
}

class VpnManager {
  static final VpnManager _instance = VpnManager._internal();
  factory VpnManager() => _instance;
  VpnManager._internal();

  late FlutterV2ray _flutterV2ray;
  final List<ActiveConfig> activeConfigs = [];
  String connectionStatusText = 'DISCONNECTED';
  Function()? onStatusChangedCallback;

  Future<void> initialize() async {
    _flutterV2ray = FlutterV2ray(
      onStatusChanged: (status) {
        final configIndex = activeConfigs.indexWhere((c) => c.state == ConnectionState.connected || c.isConnecting);
        if (configIndex != -1) {
          activeConfigs[configIndex].state = status.state == 'CONNECTED'
              ? ConnectionState.connected
              : ConnectionState.disconnected;
          activeConfigs[configIndex].isConnecting = false;
          connectionStatusText = status.state;
        } else {
          connectionStatusText = status.state;
        }
        _saveVpnState(status.state);
        onStatusChangedCallback?.call();
      },
    );
    await _flutterV2ray.initializeV2Ray();
    await _restoreVpnState();
  }

  Future<void> _saveVpnState(String status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('vpn_status', status);
    await prefs.setString('last_config', activeConfigs.isNotEmpty ? activeConfigs.last.configUrl : '');
  }

  Future<void> _restoreVpnState() async {
    final prefs = await SharedPreferences.getInstance();
    final status = prefs.getString('vpn_status') ?? 'DISCONNECTED';
    final lastConfig = prefs.getString('last_config') ?? '';
    
    if (status == 'CONNECTED' && lastConfig.isNotEmpty) {
      connectionStatusText = 'CONNECTED';
      final configIndex = activeConfigs.indexWhere((c) => c.configUrl == lastConfig);
      if (configIndex == -1) {
        activeConfigs.add(ActiveConfig(
          configUrl: lastConfig,
          remark: 'Restored Connection',
          state: ConnectionState.connected,
        ));
      } else {
        activeConfigs[configIndex].state = ConnectionState.connected;
      }
    } else {
      connectionStatusText = 'DISCONNECTED';
      for (var config in activeConfigs) {
        config.state = ConnectionState.disconnected;
        config.isConnecting = false;
      }
    }
    onStatusChangedCallback?.call();
  }

  Future<bool> startVpn(V2RayURL v2rayURL) async {
    if (await _flutterV2ray.requestPermission()) {
      try {
        await _flutterV2ray.startV2Ray(
          remark: v2rayURL.remark,
          config: v2rayURL.getFullConfiguration(),
          proxyOnly: false,
          bypassSubnets: ['192.168.0.0/16', '10.0.0.0/8'],
        );
        return true;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  Future<bool> stopVpn() async {
    try {
      await _flutterV2ray.stopV2Ray();
      return true;
    } catch (e) {
      return false;
    }
  }

  V2RayURL? parseConfig(String configUrl) {
    try {
      return FlutterV2ray.parseFromURL(configUrl);
    } catch (e) {
      return null;
    }
  }

  void setStatusChangedCallback(Function() callback) {
    onStatusChangedCallback = callback;
  }

  void clearStatusChangedCallback() {
    onStatusChangedCallback = null;
  }
}

class VpnScreen extends StatefulWidget {
  const VpnScreen({super.key});

  @override
  State<VpnScreen> createState() => _VpnScreenState();
}

class _VpnScreenState extends State<VpnScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  ConnectionState _connectionState = ConnectionState.disconnected;
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;

  String pingResult = '';
  bool _isButtonEnabled = true;
  String selectedConfig = '';
  final Uri testUri = Uri.parse('https://www.google.com');
  final String defaultV2rayShareLink = '';
  final VpnManager _vpnManager = VpnManager();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initVpnManager();
    _initAnimation();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _vpnManager._restoreVpnState().then((_) {
        setState(() {
          _connectionState = _vpnManager.connectionStatusText == 'CONNECTED'
              ? ConnectionState.connected
              : ConnectionState.disconnected;
        });
      });
    }
  }

  Future<void> _initVpnManager() async {
    await _vpnManager.initialize();
    setState(() {
      _connectionState = _vpnManager.connectionStatusText == 'CONNECTED'
          ? ConnectionState.connected
          : ConnectionState.disconnected;
    });
    _vpnManager.setStatusChangedCallback(() {
      if (mounted) {
        setState(() {
          _connectionState = _vpnManager.connectionStatusText == 'CONNECTED'
              ? ConnectionState.connected
              : _vpnManager.connectionStatusText == 'CONNECTING'
                  ? ConnectionState.connecting
                  : ConnectionState.disconnected;
        });
      }
    });
  }

  void _initAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 2.0, end: 12.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _pickConfigFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        allowedExtensions: ['txt'],
        type: FileType.custom,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final configContent = await file.readAsString();
        setState(() {
          selectedConfig = configContent.trim();
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error picking file: $e');
    }
  }

  Future<void> toggleVpn() async {
    if (!_isButtonEnabled) return;

    if (selectedConfig.isEmpty && _connectionState != ConnectionState.connected) {
      _showErrorSnackBar('No config file selected!');
      return;
    }

    final v2rayURL = selectedConfig.isNotEmpty ? _vpnManager.parseConfig(selectedConfig) : null;
    if (v2rayURL == null && _connectionState != ConnectionState.connected) {
      _showErrorSnackBar('Invalid config format');
      return;
    }

    if (_connectionState == ConnectionState.connected) {
      setState(() {
        _isButtonEnabled = false;
        _connectionState = ConnectionState.disconnected;
        _vpnManager.connectionStatusText = 'DISCONNECTING';
      });

      try {
        final success = await _vpnManager.stopVpn().timeout(const Duration(seconds: 10));
        setState(() {
          final configIndex = _vpnManager.activeConfigs.indexWhere((c) => c.configUrl == selectedConfig);
          if (configIndex != -1) {
            _vpnManager.activeConfigs[configIndex].state = ConnectionState.disconnected;
            _vpnManager.activeConfigs[configIndex].isConnecting = false;
          }
          _connectionState = success ? ConnectionState.disconnected : ConnectionState.connected;
          _vpnManager.connectionStatusText = success ? 'DISCONNECTED' : 'CONNECTED';
          _isButtonEnabled = true;
        });
        if (!success) {
          _showErrorSnackBar('Failed to stop VPN');
        }
      } catch (e) {
        setState(() {
          _connectionState = ConnectionState.connected;
          _vpnManager.connectionStatusText = 'CONNECTED';
          _isButtonEnabled = true;
        });
        _showErrorSnackBar('Stop Failed: $e');
      }
      await _saveVpnState();
      return;
    }

    setState(() {
      _isButtonEnabled = false;
      _connectionState = ConnectionState.connecting;
      _vpnManager.connectionStatusText = 'CONNECTING';

      final existingConfigIndex = _vpnManager.activeConfigs.indexWhere((c) => c.configUrl == selectedConfig);
      if (existingConfigIndex == -1) {
        _vpnManager.activeConfigs.add(ActiveConfig(
          configUrl: selectedConfig,
          remark: v2rayURL!.remark,
          state: ConnectionState.connecting,
          isConnecting: true,
        ));
      } else {
        _vpnManager.activeConfigs[existingConfigIndex].state = ConnectionState.connecting;
        _vpnManager.activeConfigs[existingConfigIndex].isConnecting = true;
      }
    });

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final success = await _vpnManager.startVpn(v2rayURL!).timeout(const Duration(seconds: 10));
      setState(() {
        final configIndex = _vpnManager.activeConfigs.indexWhere((c) => c.configUrl == selectedConfig);
        if (success) {
          if (configIndex != -1) {
            _vpnManager.activeConfigs[configIndex].state = ConnectionState.connected;
            _vpnManager.activeConfigs[configIndex].isConnecting = false;
          }
          _connectionState = ConnectionState.connected;
          _vpnManager.connectionStatusText = 'CONNECTED';
          Future.delayed(const Duration(seconds: 1), () {
            if (_connectionState == ConnectionState.connected) checkPing();
          });
        } else {
          if (configIndex != -1) {
            _vpnManager.activeConfigs[configIndex].state = ConnectionState.disconnected;
            _vpnManager.activeConfigs[configIndex].isConnecting = false;
          }
          _connectionState = ConnectionState.disconnected;
          _vpnManager.connectionStatusText = 'DISCONNECTED';
          _showErrorSnackBar('Connection Failed');
        }
        _isButtonEnabled = true;
      });
      await _saveVpnState();
    } catch (e) {
      setState(() {
        final configIndex = _vpnManager.activeConfigs.indexWhere((c) => c.configUrl == selectedConfig);
        if (configIndex != -1) {
          _vpnManager.activeConfigs[configIndex].state = ConnectionState.disconnected;
          _vpnManager.activeConfigs[configIndex].isConnecting = false;
        }
        _connectionState = ConnectionState.disconnected;
        _vpnManager.connectionStatusText = 'DISCONNECTED';
        _isButtonEnabled = true;
      });
      await _saveVpnState();
      _showErrorSnackBar('Connection Failed: $e');
    }
  }

  Future<void> _saveVpnState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('vpn_status', _vpnManager.connectionStatusText);
    await prefs.setString('last_config', selectedConfig);
  }

  void _deleteConfig(String configUrl) {
    setState(() {
      final configIndex = _vpnManager.activeConfigs.indexWhere((c) => c.configUrl == configUrl);
      if (configIndex != -1) {
        if (_vpnManager.activeConfigs[configIndex].state == ConnectionState.connected) {
          _vpnManager.stopVpn();
        }
        _vpnManager.activeConfigs.removeAt(configIndex);
        if (configUrl == selectedConfig) {
          selectedConfig = '';
        }
      }
    });
    _saveVpnState();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTypography.bodySmall),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> checkPing() async {
    setState(() {
      pingResult = 'Checking ping...';
    });

    try {
      final stopwatch = Stopwatch()..start();
      final response = await http.get(testUri).timeout(const Duration(seconds: 5));
      stopwatch.stop();

      setState(() {
        pingResult = response.statusCode == 200
            ? '✅ Ping success: ${stopwatch.elapsedMilliseconds}ms'
            : '⚠️ Ping failed: status ${response.statusCode}';
      });
    } catch (e) {
      setState(() {
        pingResult = '⏱ Timeout: no response within 5s';
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    _vpnManager.clearStatusChangedCallback();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: toggleVpn,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _connectionState == ConnectionState.connecting
                          ? _pulseAnimation.value
                          : 1.0,
                      child: Container(
                        constraints: const BoxConstraints(
                          maxWidth: 150,
                          maxHeight: 150,
                        ),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _getButtonColor(),
                              blurRadius: _glowAnimation.value,
                              spreadRadius: _glowAnimation.value / 2,
                            ),
                          ],
                        ),
                        child: Material(
                          elevation: 8,
                          shape: const CircleBorder(),
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _getButtonColor(),
                                  AppColors.secondary,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _getButtonColor(),
                                width: 2,
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: AppColors.cardBackground,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _connectionState == ConnectionState.connecting
                                        ? CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              AppColors.accent,
                                            ),
                                            strokeWidth: 3,
                                          )
                                        : Icon(
                                            Icons.vpn_lock,
                                            size: 36,
                                            color: _getButtonColor(),
                                          ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _getButtonText(),
                                      style: AppTypography.titleMedium.copyWith(
                                        color: _getButtonColor(),
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              AnimatedOpacity(
                opacity: _connectionState == ConnectionState.connecting ? 0.7 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _vpnManager.connectionStatusText,
                  style: AppTypography.bodySmall.copyWith(
                    color: _getStatusColor(),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _connectionState == ConnectionState.connected ? checkPing : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  textStyle: AppTypography.bodyMedium.copyWith(fontSize: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Check Ping'),
              ),
              const SizedBox(height: 12),
              if (pingResult.isNotEmpty)
                Text(
                  pingResult,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickConfigFile,
                    icon: const Icon(Icons.folder_open),
                    label: const Text('Select Config File (.txt)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      textStyle: AppTypography.bodyMedium.copyWith(fontSize: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (selectedConfig.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Selected: ${selectedConfig.substring(0, selectedConfig.length > 30 ? 30 : selectedConfig.length)}...',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textPrimary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.clear, size: 20, color: AppColors.error),
                            onPressed: () => _deleteConfig(selectedConfig),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getButtonColor() {
    switch (_connectionState) {
      case ConnectionState.connected:
        return AppColors.success;
      case ConnectionState.connecting:
        return AppColors.accent;
      case ConnectionState.disconnected:
        return AppColors.error;
    }
  }

  Color _getStatusColor() {
    switch (_connectionState) {
      case ConnectionState.connected:
        return AppColors.success;
      case ConnectionState.connecting:
        return AppColors.accent;
      case ConnectionState.disconnected:
        return AppColors.error;
    }
  }

  String _getButtonText() {
    switch (_connectionState) {
      case ConnectionState.connected:
        return 'Disconnect';
      case ConnectionState.connecting:
        return 'Connecting';
      case ConnectionState.disconnected:
        return 'Connect';
    }
  }
}
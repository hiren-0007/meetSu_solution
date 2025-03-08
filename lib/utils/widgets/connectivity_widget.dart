import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:meetsu_solutions/services/connectivity/connectivity_service.dart';

class ConnectivityWidget extends StatefulWidget {
  final Widget child;
  final bool showSnackBar;

  const ConnectivityWidget({
    super.key,
    required this.child,
    this.showSnackBar = true,
  });

  @override
  State<ConnectivityWidget> createState() => _ConnectivityWidgetState();
}

class _ConnectivityWidgetState extends State<ConnectivityWidget> {
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _isFirstCheck = true;

  @override
  void initState() {
    super.initState();
    _checkInitialConnectivity();
    _setupConnectivityListener();
  }

  Future<void> _checkInitialConnectivity() async {
    final result = await _connectivityService.checkConnectivity();
    if (result == ConnectivityResult.none) {
      if (mounted) {
        _connectivityService.showNoInternetDialog(context);
      }
    }
    _isFirstCheck = false;
  }

  void _setupConnectivityListener() {
    _connectivityService.connectionStatusStream.listen((ConnectivityResult result) {
      if (_isFirstCheck) return;

      if (result == ConnectivityResult.none) {
        if (mounted) {
          _connectivityService.showNoInternetDialog(context);
        }
      } else {
        if (widget.showSnackBar && mounted) {
          _connectivityService.showConnectivitySnackBar(context, result);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
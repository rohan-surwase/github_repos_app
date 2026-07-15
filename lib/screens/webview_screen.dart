import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewScreen extends StatefulWidget {
  /// The title shown in the app bar (typically the repository name).
  final String title;

  /// The primary URL to attempt to load (expected GitHub Pages site).
  final String primaryUrl;

  /// The URL to fall back to if [primaryUrl] fails to load
  /// (typically the GitHub repository page).
  final String fallbackUrl;

  const WebviewScreen({
    super.key,
    required this.title,
    required this.primaryUrl,
    required this.fallbackUrl,
  });

  @override
  State<WebviewScreen> createState() => _WebviewScreenState();
}

class _WebviewScreenState extends State<WebviewScreen> {
  late final WebViewController _controller;

  bool _isLoading = true;
  bool _usedFallback = false;
  bool _hasFailed = false;
  String _currentUrl = '';

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.primaryUrl;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasFailed = false;
              });
            }
          },
          onWebResourceError: (error) {
            // Only treat main-frame failures as page failures.
            if (error.isForMainFrame == false) return;
            _handleLoadFailure();
          },
          onHttpError: (error) {
  // Ignore HTTP errors on individual resources (images, fonts, etc.)
  // Only real page-load failures (via onWebResourceError) trigger fallback.
},
        ),
      )
      ..loadRequest(Uri.parse(widget.primaryUrl));
  }

  void _handleLoadFailure() {
    if (!mounted || _usedFallback) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasFailed = true;
        });
      }
      return;
    }
    setState(() {
      _usedFallback = true;
      _currentUrl = widget.fallbackUrl;
    });
    _controller.loadRequest(Uri.parse(widget.fallbackUrl));
  }

  Future<void> _openInExternalBrowser() async {
    final uri = Uri.parse(_currentUrl);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the browser.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: 'Reload',
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
          IconButton(
            tooltip: 'Open in browser',
            icon: const Icon(Icons.open_in_browser),
            onPressed: _openInExternalBrowser,
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Align(
              alignment: Alignment.topCenter,
              child: LinearProgressIndicator(minHeight: 3),
            ),
          if (_usedFallback && !_isLoading)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Material(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'The project page was unavailable. Showing the GitHub repository instead.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (_hasFailed && !_isLoading)
            Container(
              color: Theme.of(context).colorScheme.surface,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.wifi_off,
                        size: 48,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'This page could not be loaded.',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _openInExternalBrowser,
                        icon: const Icon(Icons.open_in_browser),
                        label: const Text('Open in browser instead'),
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

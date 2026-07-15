import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../models/repository.dart';
import '../services/github_service.dart';
import '../widgets/repo_card.dart';
import 'webview_screen.dart';

enum _LoadState { loading, loaded, error }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GithubService _service = GithubService();

  _LoadState _state = _LoadState.loading;
  List<Repository> _repositories = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadRepositories();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  Future<void> _loadRepositories() async {
    setState(() {
      _state = _LoadState.loading;
      _errorMessage = '';
    });

    try {
      final repos = await _service.fetchPublicRepositories();
      if (!mounted) return;
      setState(() {
        _repositories = repos;
        _state = _LoadState.loaded;
      });
    } on GithubServiceException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _state = _LoadState.error;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
        _state = _LoadState.error;
      });
    }
  }

  void _openProject(Repository repository) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WebviewScreen(
          title: repository.name,
          primaryUrl: AppConstants.pagesUrlFor(repository.name),
          fallbackUrl: AppConstants.repoUrlFor(repository.name),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('${AppConstants.githubUsername} · Repositories'),
        centerTitle: false,
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    switch (_state) {
      case _LoadState.loading:
        return const Center(child: CircularProgressIndicator());

      case _LoadState.error:
        return _buildErrorState();

      case _LoadState.loaded:
        if (_repositories.isEmpty) {
          return _buildEmptyState();
        }
        return _buildRepositoryList();
    }
  }

  Widget _buildErrorState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          onRefresh: _loadRepositories,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: constraints.maxHeight,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: _loadRepositories,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          onRefresh: _loadRepositories,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: constraints.maxHeight,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.folder_off_outlined,
                          size: 48,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No public repositories found for '
                          '${AppConstants.githubUsername}.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRepositoryList() {
    return RefreshIndicator(
      onRefresh: _loadRepositories,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: _repositories.length,
        itemBuilder: (context, index) {
          final repo = _repositories[index];
          return RepoCard(
            repository: repo,
            onOpenProject: () => _openProject(repo),
          );
        },
      ),
    );
  }
}

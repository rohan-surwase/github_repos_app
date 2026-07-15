import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/constants.dart';
import '../models/repository.dart';

/// Thrown when the GitHub API call fails in a known way.
class GithubServiceException implements Exception {
  final String message;
  GithubServiceException(this.message);

  @override
  String toString() => message;
}

class GithubService {
  final http.Client _client;

  GithubService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches all public, non-fork repositories for [AppConstants.githubUsername]
  /// by paging through the GitHub REST API.
  Future<List<Repository>> fetchPublicRepositories() async {
    final List<Repository> allRepos = [];
    int page = 1;
    const int perPage = 50;

    try {
      while (true) {
        final uri = Uri.parse(
          AppConstants.reposEndpoint(page: page, perPage: perPage),
        );

        final response = await _client.get(
          uri,
          headers: const {
            'Accept': 'application/vnd.github+json',
            'X-GitHub-Api-Version': '2022-11-28',
          },
        ).timeout(const Duration(seconds: 20));

        if (response.statusCode == 404) {
          throw GithubServiceException(
            'GitHub user "${AppConstants.githubUsername}" was not found.',
          );
        }

        if (response.statusCode == 403) {
          throw GithubServiceException(
            'GitHub API rate limit reached. Please try again later.',
          );
        }

        if (response.statusCode != 200) {
          throw GithubServiceException(
            'GitHub API returned an error (status ${response.statusCode}).',
          );
        }

        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        if (data.isEmpty) break;

        final repos = data
            .cast<Map<String, dynamic>>()
            .map(Repository.fromJson)
            .where((repo) => !repo.fork)
            .toList();

        allRepos.addAll(repos);

        if (data.length < perPage) break;
        page += 1;

        // Safety valve so a misconfigured account can't page forever.
        if (page > 20) break;
      }

      allRepos.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
      return allRepos;
    } on GithubServiceException {
      rethrow;
    } catch (e) {
      throw GithubServiceException(
        'Could not load repositories. Check your internet connection.',
      );
    }
  }

  void dispose() {
    _client.close();
  }
}

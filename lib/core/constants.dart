/// App-wide constants.
///
/// To point this app at a different GitHub account, change ONLY this value.
class AppConstants {
  AppConstants._();

  /// The GitHub username whose public repositories are fetched and shown.
  /// This is the single place you need to edit to retarget the app.
  static const String githubUsername = 'octocat';

  /// GitHub REST API base URL.
  static const String githubApiBase = 'https://api.github.com';

  /// Builds the API endpoint for listing a user's public repositories.
  static String reposEndpoint({int page = 1, int perPage = 30}) {
    return '$githubApiBase/users/$githubUsername/repos'
        '?type=owner&sort=updated&per_page=$perPage&page=$page';
  }

  /// Builds the expected GitHub Pages URL for a given repository name.
  static String pagesUrlFor(String repositoryName) {
    return 'https://$githubUsername.github.io/$repositoryName/';
  }

  /// Builds the GitHub repository URL (fallback destination).
  static String repoUrlFor(String repositoryName) {
    return 'https://github.com/$githubUsername/$repositoryName';
  }
}

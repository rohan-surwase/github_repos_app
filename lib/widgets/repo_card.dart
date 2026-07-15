import 'package:flutter/material.dart';

import '../models/repository.dart';

class RepoCard extends StatelessWidget {
  final Repository repository;
  final VoidCallback onOpenProject;

  const RepoCard({
    super.key,
    required this.repository,
    required this.onOpenProject,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.folder_outlined,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    repository.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (repository.language != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    repository.language!,
                    style: theme.textTheme.bodySmall,
                  ),
                  if (repository.stargazersCount > 0) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.star_outline,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${repository.stargazersCount}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonalIcon(
                onPressed: onOpenProject,
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('Open Project'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
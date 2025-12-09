import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repository/map_entry_repository.dart';
import '../models/map_entry.dart' as model;
import '../dialogs/edit_entry_dialog.dart';
import '../providers/theme_provider.dart';
import '../widgets/dark_mode_toggle_button.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  final MapEntryRepository _repository = MapEntryRepository();
  bool _isLoading = true;
  String? _errorMessage;
  List<model.MapEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords({bool forceRefresh = false}) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Get entries from repository (will use cache if offline)
      final entries = await _repository.getAllEntries(
        forceRefresh: forceRefresh,
      );

      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load records: $e';
      });
    }
  }

  void _showEditDialog(model.MapEntry entry) {
    showDialog(
      context: context,
      builder: (context) => EditEntryDialog(
        entry: entry,
        onSuccess: () => _loadRecords(forceRefresh: true),
      ),
    );
  }

  void _showDeleteConfirmation(model.MapEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Landmark'),
        content: Text(
          'Are you sure you want to delete "${entry.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteEntry(entry.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEntry(int id) async {
    try {
      await _repository.deleteEntry(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Landmark deleted successfully')),
        );
        await _loadRecords(forceRefresh: true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting landmark: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // List content
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            bottom: 0,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _errorMessage!,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadRecords,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _entries.isEmpty
                ? Center(
                    child: Text(
                      'No records found',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => _loadRecords(forceRefresh: true),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _entries.length,
                      itemBuilder: (context, index) {
                        return _LandmarkCard(
                          entry: _entries[index],
                          onEdit: () => _showEditDialog(_entries[index]),
                          onDelete: () =>
                              _showDeleteConfirmation(_entries[index]),
                        );
                      },
                    ),
                  ),
          ),
          // Header
          Positioned(
            top: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode
                          ? Colors.grey[900]
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Text(
                      'Records',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  );
                },
              ),
            ),
          ),
          // Dark mode toggle button
          Positioned(top: 30, right: 16, child: const DarkModeToggleButton()),
        ],
      ),
    );
  }
}

class _LandmarkCard extends StatelessWidget {
  final model.MapEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _LandmarkCard({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  Widget _buildImageWidget(model.MapEntry entry) {
    final repository = MapEntryRepository();

    if (entry.image == null || entry.image!.isEmpty) {
      return _buildPlaceholder();
    }

    return FutureBuilder<String?>(
      future: repository.getCachedImagePath(entry.image),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          // Show cached image
          return Image.file(
            File(snapshot.data!),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fall back to network
              return Image.network(
                'https://labs.anontech.info/cse489/t3/${entry.image}',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholder();
                },
              );
            },
          );
        } else {
          // No cached image, try network
          return Image.network(
            'https://labs.anontech.info/cse489/t3/${entry.image}',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholder();
            },
          );
        }
      },
    );
  }

  Widget _buildPlaceholder() {
    return Image.asset(
      'assets/placeholder.jpg',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[300],
          child: const Center(child: Icon(Icons.image_not_supported)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('landmark_${entry.id}'),
      background: Container(
        color: Colors.orange,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.edit, color: Colors.white, size: 30),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swipe right - Edit
          onEdit();
          return false;
        } else {
          // Swipe left - Delete
          onDelete();
          return false;
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side - Image and ID
              Column(
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: _buildImageWidget(entry),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // ID
                  Text(
                    'ID: ${entry.id}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              // Right side - Info and buttons
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      entry.title,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Latitude
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Lat: ${entry.lat.toStringAsFixed(6)}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Longitude
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Lon: ${entry.lon.toStringAsFixed(6)}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Edit button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.yellow[600],
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            iconSize: 20,
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                            onPressed: onEdit,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Delete button
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.white),
                            iconSize: 20,
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                            onPressed: onDelete,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

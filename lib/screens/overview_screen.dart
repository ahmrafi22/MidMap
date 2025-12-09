import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../api/api_service.dart';
import '../models/map_entry.dart' as model;
import '../dialogs/edit_entry_dialog.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  late MapController _mapController;
  bool _isLoading = true;
  String? _errorMessage;
  List<Marker> _markers = [];
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _loadMapData();
  }

  Future<void> _loadMapData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await ApiService.viewAll();
      final entries = response
          .map((json) => model.MapEntry.fromJson(json))
          .toList();

      final markers = <Marker>[];
      for (var entry in entries) {
        markers.add(
          Marker(
            point: LatLng(entry.lat, entry.lon),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () => _showEntityDetails(entry),
              child: Tooltip(
                message: '${entry.title}\nLat: ${entry.lat}, Lon: ${entry.lon}',
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ),
          ),
        );
      }

      setState(() {
        _markers = markers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load map data: $e';
      });
    }
  }

  void _showEntityDetails(model.MapEntry entry) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Latitude: ${entry.lat.toStringAsFixed(6)}',
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  'Longitude: ${entry.lon.toStringAsFixed(6)}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: (entry.image != null && entry.image!.isNotEmpty)
                      ? () {
                          Navigator.pop(context);
                          _showImageDialog(entry);
                        }
                      : null,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: (entry.image != null && entry.image!.isNotEmpty)
                          ? Image.network(
                              'https://labs.anontech.info/cse489/t3/${entry.image}',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/placeholder.jpg',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: Icon(Icons.image_not_supported),
                                      ),
                                    );
                                  },
                                );
                              },
                            )
                          : Image.asset(
                              'assets/placeholder.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(Icons.image_not_supported),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  (entry.image != null && entry.image!.isNotEmpty)
                      ? 'Tap image to view full size'
                      : 'No image available',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Row(
                children: [
                  // Edit button - Yellow
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.yellow[600],
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditDialog(entry);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Delete button - Red
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                        _showDeleteConfirmation(entry);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageDialog(model.MapEntry entry) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(entry.title),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Flexible(
              child: InteractiveViewer(
                child: Image.network(
                  'https://labs.anontech.info/cse489/t3/${entry.image}',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.error)),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(model.MapEntry entry) {
    showDialog(
      context: context,
      builder: (context) =>
          EditEntryDialog(entry: entry, onSuccess: _loadMapData),
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
      await ApiService.deleteEntry(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Landmark deleted successfully')),
        );
        await _loadMapData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting landmark: $e')));
      }
    }
  }

  void _resetMapPosition() {
    try {
      _mapController.rotate(0);
      _mapController.move(const LatLng(23.6850, 90.3563), 7.0);
    } catch (e) {
      debugPrint('Error resetting map position: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadMapData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: const MapOptions(
                    initialCenter: LatLng(23.6850, 90.3563),
                    initialZoom: 7.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: _isDarkMode
                          ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                          : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.midmap',
                      retinaMode: RetinaMode.isHighDensity(context),
                    ),
                    MarkerLayer(markers: _markers),
                  ],
                ),
                Positioned(
                  top: 30,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Overview',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 30,
                  right: 16,
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: FloatingActionButton(
                      mini: true,
                      onPressed: () {
                        setState(() {
                          _isDarkMode = !_isDarkMode;
                        });
                      },
                      child: Icon(
                        _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      ),
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          _resetMapPosition();
          await _loadMapData();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:predictit_jr/models/market.dart';
import 'package:provider/provider.dart';
import '../services/permission_service.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import '../data/market_repository.dart';
import 'package:go_router/go_router.dart';

// I got a lot of help from AI on this

class CreateMarketScreen extends StatefulWidget {
  const CreateMarketScreen({super.key});

  @override
  State<CreateMarketScreen> createState() => _CreateMarketScreenState();
}

// Declare state as each substep needs it — that keeps every
// "run between substeps" free of unused-field warnings. Substep 2
// adds the geolocator import and the _position / _locationStatus fields.
class _CreateMarketScreenState extends State<CreateMarketScreen> {
  String? _imagePath; // null = not chosen yet
  String? _photoStatus; // human-readable status for the demo
  Position? _position; // null = not captured yet
  String? _locationStatus;
  bool _busy = false;
  bool _locationBusy = false;

  final TextEditingController _questionController = TextEditingController();

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source);

    if (!mounted) return;
    setState(() {
      _imagePath = file?.path;
      _photoStatus = file == null ? 'Canceled. No photo.' : 'Photo selected.';
    });
  }

  Future<void> _takePhoto() async {
    setState(() => _busy = true);
    final svc = context.read<PermissionService>();
    final outcome = await svc.requestCamera();

    switch (outcome) {
      case PermissionOutcome.granted:
        await _pickImage(ImageSource.camera);
        break;
      case PermissionOutcome.denied:
        setState(() =>
            _photoStatus = 'No camera access this time. Tap again to retry.',);
        break;
      case PermissionOutcome.permanentlyDenied:
        setState(() => _photoStatus =
            'Camera blocked in Settings. Open Settings to allow it.',);
        break;
    }
    setState(() => _busy = false);
  }

  Future<void> _pickFromGallery() async {
    await _pickImage(ImageSource.gallery);
  }

  Future<void> _choosePhotoSource() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pick from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    if (source == ImageSource.camera) {
      await _takePhoto();
    } else {
      await _pickFromGallery();
    }
  }

  Future<void> _getLocation() async {
    setState(() {
      _locationBusy = true;
      _locationStatus = 'Finding location...';
    });
    final svc = context.read<PermissionService>();
    final outcome = await svc.requestLocation();

    switch (outcome) {
      case PermissionOutcome.granted:
        // Even with permission granted, the platform can fail (no GPS,
        // airplane mode, timeout). Treat the failure as a recoverable
        // 'no location captured' — not a crash.
        try {
          final p = await Geolocator.getCurrentPosition()
              .timeout(const Duration(seconds: 10));
          if (!mounted) return;
          setState(() {
            _position = p;
            _locationStatus = 'Location captured.';
          });
        } catch (e) {
          if (!mounted) return;
          setState(() {
            _position = null;
            _locationStatus = "Couldn't get a location right now.";
          });
        }
        break;
      case PermissionOutcome.denied:
        setState(() => _locationStatus =
            'No location access this time. Tap again to retry.',);
        break;
      case PermissionOutcome.permanentlyDenied:
        setState(() => _locationStatus =
            'Location blocked in Settings. Open Settings to allow it.',);
        break;
    }
    if (mounted) {
      setState(() => _locationBusy = false);
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final question = _questionController.text.trim();

    if (question.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a question first.')),
      );
      return;
    }

    final market = Market(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      title: question,
      description: question,
      category: 'local',
      yesPriceCents: 50,
      volumeShares: 0,
      closesAt: DateTime.now().add(const Duration(days: 7)),
      imageAsset: 'assets/images/campus.svg',
      priceHistory: const [],
      imagePath: _imagePath,
      latitude: _position?.latitude,
      longitude: _position?.longitude,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Created ${market.title}')),
    );
    await MarketRepository().addMarket(market);
    if (!mounted) return;
    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create market')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _questionController,
              decoration: const InputDecoration(
                labelText: 'Question',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.add_a_photo),
              onPressed: _busy ? null : _choosePhotoSource,
              label: const Text('Add photo'),
            ),
            if (_photoStatus != null) ...[
              const SizedBox(height: 8),
              Text(_photoStatus!),
            ],
            if (_imagePath != null) ...[
              const SizedBox(height: 12),
              Container(
                height: 220,
                width: double.infinity,
                color: Colors.black12,
                child: Image.file(
                  File(_imagePath!),
                  fit: BoxFit.contain,
                ),
              ),
            ],
            // Open-settings shortcut only when we've actually hit the
            // permanently-denied state. Don't show it gratuitously.
            if (_photoStatus?.contains('Settings') ?? false)
              TextButton(
                onPressed: () =>
                    context.read<PermissionService>().openSettings(),
                child: const Text('Open Settings'),
              ),

            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.my_location),
              onPressed: _busy ? null : _getLocation,
              label: const Text('Get location'),
            ),
            if (_locationBusy)
              const ListTile(
                leading: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                title: Text('Finding location...'),
              )
            else if (_position != null)
              ListTile(
                leading: const Icon(Icons.place),
                title: Text(
                  'Lat ${_position!.latitude.toStringAsFixed(4)}, '
                  'Lng ${_position!.longitude.toStringAsFixed(4)}',
                ),
              )
            else if (_locationStatus != null)
              Text(_locationStatus!),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _locationBusy ? null : _submit,
              child: const Text('Create market'),
            ),
          ],
        ),
      ),
    );
  }
}

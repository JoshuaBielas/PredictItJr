import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:predictit_jr/widgets/adaptive_shell.dart';
import '../data/market_repository.dart';
import '../models/market.dart';
import '../widgets/market_card.dart';
import '../widgets/market_detail.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../services/permission_service.dart';

class MarketListScreen extends StatefulWidget {
  // const MarketListScreen({super.key});
  final List<Market>? markets; // optional so real app still works
  const MarketListScreen({super.key, this.markets});

  @override
  State<MarketListScreen> createState() => _MarketListScreenState();
}

class _WideMarketLayout extends StatefulWidget {
  const _WideMarketLayout({
    required this.markets,
    this.userLat,
    this.userLng,
  });

  final List<Market> markets;
  final double? userLat;
  final double? userLng;

  @override
  State<_WideMarketLayout> createState() => _WideMarketLayoutState();
}

class _WideMarketLayoutState extends State<_WideMarketLayout> {
  Market? _selectedMarket;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ListView.builder(
            itemCount: widget.markets.length,
            itemBuilder: (context, i) {
              final market = widget.markets[i];

              return MarketCard(
                market: market,
                userLat: widget.userLat,
                userLng: widget.userLng,
                onTap: () {
                  setState(() {
                    _selectedMarket = market;
                  });
                },
              );
            },
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 3,
          child: _selectedMarket == null
              ? const Center(child: Text('Select a market'))
              : MarketDetailBody(market: _selectedMarket!),
        ),
      ],
    );
  }
}

class _MarketListScreenState extends State<MarketListScreen> {
  late Future<List<Market>> _marketsFuture;
  Position? _position;

  // @override
  // void initState() {
  //   super.initState();
  //   _marketsFuture = MarketRepository().loadAll();
  //   _captureListLocation();
  // }
  @override
  void initState() {
    super.initState();
    _marketsFuture = widget.markets != null
        ? Future.value(widget.markets)
        : MarketRepository().loadAll();
    _captureListLocation();
  }

  Future<void> _captureListLocation() async {
    final svc = context.read<PermissionService>();
    final outcome = await svc.requestLocation();

    if (outcome != PermissionOutcome.granted) {
      if (!mounted) return;
      setState(() => _position = null);
      return;
    }

    try {
      final p = await Geolocator.getCurrentPosition()
          .timeout(const Duration(seconds: 10));
      if (!mounted) return;
      setState(() => _position = p);
    } catch (_) {
      if (!mounted) return;
      setState(() => _position = null);
    }
  }

  // I got help from AI for this code.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Markets'),
      ),
      body: FutureBuilder<List<Market>>(
        future: _marketsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load: ${snapshot.error}'));
          }
          final markets = snapshot.data!;
          final wide = MediaQuery.sizeOf(context).width >= kWideBreakpoint;
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _marketsFuture = MarketRepository().loadAll();
              });
              await _marketsFuture;
            },
            child: wide
                ? _WideMarketLayout(
                  markets: markets,
                  userLat: _position?.latitude,
                  userLng: _position?.longitude,
                )
                : ListView.builder(
                    itemCount: markets.length,
                    itemBuilder: (context, i) {
                    final market = markets[i];
                    return MarketCard(
                      market: market,
                      userLat: _position?.latitude,
                      userLng: _position?.longitude,
                    );
                  },
                ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await context.push<bool>('/create');

          if (!mounted) return;
          if (created == true) {
            setState(() {
              _marketsFuture = MarketRepository().loadAll();
            });
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Create'),
      ),
    );
  }
}

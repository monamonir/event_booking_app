import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event_model.dart';
import '../services/api_service.dart';
import '../services/booking_service.dart';
import '../services/auth_service.dart';
import '../widgets/event_card.dart';
import '../widgets/shope_event_card.dart'; // ✅ External component from Shope template
import 'event_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  List<Event> _allEvents = [];
  List<Event> _filtered = [];
  Set<int> _bookedIds = {};
  bool _loading = true;
  String _selectedCategory = 'All';
  final _searchFocus = FocusNode();
  final _searchCtrl = TextEditingController();

  final List<String> _categories = [
    'All',
    'Tech',
    'Music',
    'Business',
    'Health',
    'Food',
    'Art',
    'Sports'
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchCtrl.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> _loadData() async {
    final uid = _uid;
    if (uid == null) return;
    setState(() => _loading = true);
    final events = await ApiService.fetchEvents();
    final bookings = await BookingService.loadBookings(uid);
    if (mounted) {
      setState(() {
        _allEvents = events;
        _bookedIds = bookings.map((b) => b.event.id).toSet().cast<int>();
        _applyFilter();
        _loading = false;
      });
    }
  }

  void _applyFilter() {
    final query = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _allEvents.where((e) {
        final matchCat =
            _selectedCategory == 'All' || e.category == _selectedCategory;
        final matchSearch = query.isEmpty ||
            e.title.toLowerCase().contains(query) ||
            e.location.toLowerCase().contains(query);
        return matchCat && matchSearch;
      }).toList();
    });
  }

  Future<void> _bookEvent(Event event) async {
    final uid = _uid;
    if (uid == null) return;
    await BookingService.addBooking(event, uid);
    setState(() => _bookedIds.add(event.id));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 "${event.title}" booked!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Shared navigation helper used by both ShopeEventCard and EventCard
  void _navigateToDetails(Event event) async {
    _searchFocus.unfocus();
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EventDetailsScreen(event: event)),
    );
    // Refresh booked state on return
    final uid = _uid;
    if (uid != null && mounted) {
      final bookings = await BookingService.loadBookings(uid);
      setState(() {
        _bookedIds = bookings.map((b) => b.event.id).toSet().cast<int>();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final user = AuthService().currentUser;

    // First 4 events shown in the Shope-style featured row
    final featuredEvents = _allEvents.take(4).toList();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: const Color(0xFF6C63FF),
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              // ── Header + Featured section ──────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hello, ${user?.displayName?.split(' ').first ?? 'Explorer'} 👋',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1A2E),
                                  ),
                                ),
                                const Text(
                                  'Find your next event',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C63FF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.notifications_none_rounded,
                              color: Color(0xFF6C63FF),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Search bar
                      TextField(
                        controller: _searchCtrl,
                        focusNode: _searchFocus,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: 'Search events...',
                          hintStyle: const TextStyle(color: Colors.grey),
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.grey),
                          suffixIcon: _searchCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear,
                                      color: Colors.grey),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    _applyFilter();
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                                color: Color(0xFF6C63FF), width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Featured Events row (Shope component) ──────────────
                      // Uses ShopeEventCard adapted from:
                      // Shope Flutter Ecommerce Template by robertodevs
                      // https://github.com/robertodevs/flutter_ecommerce_template
                      // License: MIT
                      if (!_loading && featuredEvents.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Featured Events',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Reset to All category to show everything
                                setState(() => _selectedCategory = 'All');
                                _applyFilter();
                              },
                              child: Text(
                                'See all',
                                style: TextStyle(
                                  fontSize: 13,
                                  color:
                                      const Color(0xFF6C63FF).withOpacity(0.8),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 200,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: featuredEvents.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final event = featuredEvents[index];
                              return ShopeEventCard(
                                event: event,
                                onTap: () => _navigateToDetails(event),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Category chips
                      SizedBox(
                        height: 36,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, i) {
                            final cat = _categories[i];
                            final selected = cat == _selectedCategory;
                            return GestureDetector(
                              onTap: () {
                                setState(() => _selectedCategory = cat);
                                _applyFilter();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? const Color(0xFF6C63FF)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  cat,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        selected ? Colors.white : Colors.grey,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),

                      Text(
                        '${_filtered.length} events found',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),

              // ── All Events list (your custom EventCard) ────────────────────
              if (_loading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF6C63FF)),
                    ),
                  ),
                )
              else if (_filtered.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.search_off_rounded,
                              size: 60, color: Colors.grey),
                          SizedBox(height: 12),
                          Text('No events found',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final event = _filtered[index];
                        return EventCard(
                          event: event,
                          isBooked: _bookedIds.contains(event.id),
                          onTap: () => _navigateToDetails(event),
                          onBook: _bookedIds.contains(event.id)
                              ? null
                              : () => _bookEvent(event),
                        );
                      },
                      childCount: _filtered.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event_model.dart';
import '../services/api_service.dart';
import '../services/booking_service.dart';
import '../services/auth_service.dart';
import '../widgets/event_card.dart';
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
  // FocusNode keeps keyboard behavior isolated from IndexedStack
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

  // Keeps this tab alive in IndexedStack so state is preserved
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
    // Pass uid so bookings are scoped to the current user only
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
    // Pass uid so the booking is stored under this user only
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

  @override
  Widget build(BuildContext context) {
    super.build(context); // required by AutomaticKeepAliveClientMixin
    final user = AuthService().currentUser;

    return Scaffold(
      // resizeToAvoidBottomInset lets the keyboard push content up properly
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: const Color(0xFF6C63FF),
          child: CustomScrollView(
            // Dismiss keyboard when scrolling
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                            child: const Icon(Icons.notifications_none_rounded,
                                color: Color(0xFF6C63FF)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Search bar with explicit focusNode for reliable keyboard
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
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 16),

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
                          onTap: () async {
                            // Dismiss keyboard before navigating
                            _searchFocus.unfocus();
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EventDetailsScreen(event: event),
                              ),
                            );
                            // Refresh booked state when returning from details
                            final uid = _uid;
                            if (uid != null && mounted) {
                              final bookings =
                                  await BookingService.loadBookings(uid);
                              setState(() {
                                _bookedIds = bookings
                                    .map((b) => b.event.id)
                                    .toSet()
                                    .cast<int>();
                              });
                            }
                          },
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

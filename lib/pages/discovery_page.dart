import 'package:flutter/material.dart';

class DiscoveryPage extends StatelessWidget {
  const DiscoveryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Discovery',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black54),
            onPressed: () {
              // Handle search
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black54),
            onPressed: () {
              // Handle filter
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            Container(
              margin: const EdgeInsets.all(16),
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6B73FF), Color(0xFF9DD5FF)],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: 20,
                    top: 20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    bottom: 30,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Discover Amazing',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Places & Experiences',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Categories Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Travel & Places
                  _buildSectionHeader('Travel & Places', Icons.travel_explore),
                  _buildDiscoveryCard(
                    icon: Icons.place,
                    title: 'Explore Destinations',
                    subtitle: 'Find new places to visit around the world',
                    color: Colors.blue,
                  ),
                  _buildDiscoveryCard(
                    icon: Icons.flight,
                    title: 'Flight Deals',
                    subtitle: 'Discover amazing flight offers',
                    color: Colors.indigo,
                  ),
                  _buildDiscoveryCard(
                    icon: Icons.hotel,
                    title: 'Accommodation',
                    subtitle: 'Find the perfect place to stay',
                    color: Colors.purple,
                  ),
                  _buildDiscoveryCard(
                    icon: Icons.map,
                    title: 'Local Attractions',
                    subtitle: 'Must-see spots and hidden gems',
                    color: Colors.teal,
                  ),

                  // Events & Entertainment
                  _buildSectionHeader('Events & Entertainment', Icons.event),
                  _buildDiscoveryCard(
                    icon: Icons.event,
                    title: 'Upcoming Events',
                    subtitle: 'See what\'s happening nearby',
                    color: Colors.orange,
                  ),
                  _buildDiscoveryCard(
                    icon: Icons.music_note,
                    title: 'Concerts & Shows',
                    subtitle: 'Live music and entertainment',
                    color: Colors.pink,
                  ),
                  _buildDiscoveryCard(
                    icon: Icons.sports_soccer,
                    title: 'Sports Events',
                    subtitle: 'Games and tournaments',
                    color: Colors.green,
                  ),
                  _buildDiscoveryCard(
                    icon: Icons.theater_comedy,
                    title: 'Theater & Arts',
                    subtitle: 'Cultural performances and exhibitions',
                    color: Colors.deepPurple,
                  ),

                  // Food & Dining
                  _buildSectionHeader('Food & Dining', Icons.restaurant),
                  _buildDiscoveryCard(
                    icon: Icons.restaurant,
                    title: 'Local Cuisine',
                    subtitle: 'Discover popular restaurants',
                    color: Colors.red,
                  ),
                  _buildDiscoveryCard(
                    icon: Icons.local_cafe,
                    title: 'Coffee & Cafes',
                    subtitle: 'Best coffee spots in town',
                    color: Colors.brown,
                  ),
                  _buildDiscoveryCard(
                    icon: Icons.wine_bar,
                    title: 'Bars & Nightlife',
                    subtitle: 'Evening entertainment venues',
                    color: Colors.deepOrange,
                  ),
                  _buildDiscoveryCard(
                    icon: Icons.bakery_dining,
                    title: 'Street Food',
                    subtitle: 'Authentic local street food',
                    color: Colors.amber,
                  ),

                  // Activities & Recreation
                  _buildSectionHeader('Activities & Recreation', Icons.directions_run),
                  _buildDiscoveryCard(
                    icon: Icons.hiking,
                    title: 'Outdoor Adventures',
                    subtitle: 'Hiking, biking, and nature activities',
                    color: Colors.lightGreen,
                  ),
                  _buildDiscoveryCard(
                    icon: Icons.fitness_center,
                    title: 'Fitness & Wellness',
                    subtitle: 'Gyms, spas, and wellness centers',
                    color: Colors.cyan,
                  ),
                  _buildDiscoveryCard(
                    icon: Icons.pool,
                    title: 'Water Activities',
                    subtitle: 'Swimming, diving, and water sports',
                    color: Colors.lightBlue,
                  ),
                  _buildDiscoveryCard(
                    icon: Icons.games,
                    title: 'Gaming & Fun',
                    subtitle: 'Arcades, escape rooms, and entertainment',
                    color: Colors.lime,
                  ),

                  // Shopping & Services
                  _buildSectionHeader('Shopping & Services', Icons.shopping_bag),
                  _buildDiscoveryCard(
                    icon: Icons.local_mall,
                    title: 'Shopping Centers',
                    subtitle: 'Malls and shopping districts',
                    color: Colors.indigo,
                  ),
                  _buildDiscoveryCard(
                    icon: Icons.store,
                    title: 'Local Markets',
                    subtitle: 'Traditional markets and bazaars',
                    color: Colors.orange,
                  ),
                  _buildDiscoveryCard(
                    icon: Icons.medical_services,
                    title: 'Health Services',
                    subtitle: 'Hospitals, clinics, and pharmacies',
                    color: Colors.red,
                  ),
                  _buildDiscoveryCard(
                    icon: Icons.school,
                    title: 'Educational',
                    subtitle: 'Museums, libraries, and learning centers',
                    color: Colors.blue,
                  ),

                  // Trending Now
                  _buildSectionHeader('Trending Now', Icons.trending_up),
                  _buildDiscoveryCard(
                    icon: Icons.local_fire_department,
                    title: 'Hot Spots',
                    subtitle: 'Currently trending locations',
                    color: Colors.deepOrange,
                  ),
                  _buildDiscoveryCard(
                    icon: Icons.new_releases,
                    title: 'Newly Opened',
                    subtitle: 'Latest additions to your area',
                    color: Colors.green,
                  ),
                  _buildDiscoveryCard(
                    icon: Icons.star,
                    title: 'Top Rated',
                    subtitle: 'Highest rated places by users',
                    color: Colors.amber,
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          
        ],
      ),
    ));
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoveryCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Handle tap
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
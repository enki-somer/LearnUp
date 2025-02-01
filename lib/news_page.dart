import 'package:flutter/material.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  Widget _buildNewsCard({
    required String title,
    required String date,
    required String description,
    required String imageUrl,
    required Color accentColor,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Material(
        borderRadius: BorderRadius.circular(20),
        elevation: 2,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image container with gradient overlay
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  image: DecorationImage(
                    image: AssetImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        accentColor.withOpacity(0.8),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(icon, color: Colors.white, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            date,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            // TODO: Implement read more functionality
                          },
                          icon: Icon(Icons.arrow_forward, color: accentColor),
                          label: Text(
                            'Read More',
                            style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.share_rounded,
                                  color: Colors.grey[600]),
                              onPressed: () {
                                // TODO: Implement share functionality
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.bookmark_border_rounded,
                                  color: Colors.grey[600]),
                              onPressed: () {
                                // TODO: Implement bookmark functionality
                              },
                            ),
                          ],
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

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          floating: true,
          title: const Text(
            'Latest News',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded),
              onPressed: () {
                // TODO: Implement notifications
              },
            ),
          ],
        ),
        // News Content
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildNewsCard(
                title: 'New Python Course Released',
                date: 'March 15, 2024',
                description:
                    'We are excited to announce the release of our comprehensive Python programming course. This course covers everything from basics to advanced topics, including machine learning and data analysis. Join thousands of students who have already started their journey into Python programming.',
                imageUrl: 'assets/images/python_bg.jpg',
                accentColor: Colors.green.shade700,
                icon: Icons.code_rounded,
              ),
              _buildNewsCard(
                title: 'Flutter Development Workshop',
                date: 'March 20, 2024',
                description:
                    'Join us for an interactive workshop on Flutter development. Learn how to build beautiful, natively compiled applications for mobile, web, and desktop from a single codebase. Get hands-on experience with Flutter\'s hot reload feature and widget-based development.',
                imageUrl: 'assets/images/flutter_bg.jpg',
                accentColor: Colors.blue,
                icon: Icons.devices_rounded,
              ),
            ]),
          ),
        ),
        // Bottom padding for navigation bar
        const SliverPadding(
          padding: EdgeInsets.only(bottom: 80),
        ),
      ],
    );
  }
}

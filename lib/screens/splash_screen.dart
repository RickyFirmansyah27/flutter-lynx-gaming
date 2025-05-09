import 'package:flutter/material.dart';
import 'package:lynxgaming/screens/layout_screen.dart';

class OnboardingScreen extends StatelessWidget {
  final List<Map<String, String>> featuredArenas = [
    {
      'id': '1',
      'name': 'Celestial Palace',
      'image':
          'https://i.pinimg.com/736x/ad/8a/07/ad8a07651892ee67933d7c70ca7a0f05.jpg',
    },
  ];

  final List<Map<String, String>> featuredSkins = [
    {
      'id': '1',
      'hero': 'Lucas',
      'description':
          'A divine skin that transforms Beast into a celestial being with ethereal effects.',
      'category': 'Mythic',
      'image':
          'https://i.pinimg.com/736x/56/e1/9a/56e19adc6d51a6265fc1a62bf32d76fa.jpg',
    },
    {
      'id': '2',
      'hero': 'Kalea',
      'description':
          'A divine skin that transforms Beast into a celestial being with ethereal effects.',
      'category': 'Mythic',
      'image':
          'https://i.pinimg.com/736x/8e/3e/10/8e3e10b10297a6b3d4f4d1516828d9d9.jpg',
    },
    {
      'id': '3',
      'hero': 'Suyou',
      'description':
          'A divine skin that transforms Beast into a celestial being with ethereal effects.',
      'category': 'Mythic',
      'image':
          'https://i.pinimg.com/736x/1e/6f/7a/1e6f7a13b1d21b4b22cfa63a2cc8c436.jpg',
    },
  ];

  OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Image
              Container(
                height: 200,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://images.pexels.com/photos/3165335/pexels-photo-3165335.jpeg',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'LYNX GAMING',
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Customize your gaming experience',
                          style: TextStyle(
                            fontFamily: 'Rajdhani',
                            fontSize: 16,
                            color: Colors.amberAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                  border: const Border(
                    left: BorderSide(width: 2, color: Colors.amberAccent),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.info_outline, color: Colors.amberAccent),
                        SizedBox(width: 8),
                        Text(
                          'SYSTEM OVERVIEW',
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Welcome to the Lynx Gaming app. This application allows you to select, download, and install custom arena, skin assets to enhance your gaming experience.',
                      style: TextStyle(
                        fontFamily: 'Rajdhani',
                        fontSize: 16,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.amberAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () {
                       Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TabsScreen(),
                          ),
                        );
                      },
                      child: const Text('EXPLORE NOW'),
                    ),
                  ],
                ),
              ),

              // Featured Arenas
              Text(
                'Featured Arenas',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: featuredArenas.length,
                  itemBuilder: (context, index) {
                    final arena = featuredArenas[index];
                    return Container(
                      width: 150,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              arena['image']!,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/placeholder.png',
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                color: const Color(0xFF1E1E1E),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                width: double.infinity,
                                child: Text(
                                  arena['name']!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Rajdhani',
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Featured Skins
              Text(
                'Featured Skins',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: featuredSkins.length,
                  itemBuilder: (context, index) {
                    final skin = featuredSkins[index];
                    return Container(
                      width: 150,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              skin['image']!,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/placeholder.png',
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                color: const Color(0xFF1E1E1E),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                width: double.infinity,
                                child: Text(
                                  skin['hero']!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Rajdhani',
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
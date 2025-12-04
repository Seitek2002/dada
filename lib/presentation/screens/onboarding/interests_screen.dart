import 'package:flutter/material.dart';
import 'swipe_tutorial_screen.dart';

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  final Set<String> _selectedInterests = {};

  final List<Interest> _interests = [
    Interest(emoji: '🤣', name: 'Comedy', color: Color(0xFFFFD93D)),
    Interest(emoji: '⏰', name: 'Daily Life', color: Color(0xFF9E9E9E)),
    Interest(emoji: '🐱', name: 'Animals', color: Color(0xFF8BC34A)),
    Interest(emoji: '🍔', name: 'Food', color: Color(0xFFFFB84D)),
    Interest(emoji: '🎮', name: 'Gaming', color: Color(0xFF9C27B0)),
    Interest(emoji: '🏖️', name: 'Travel', color: Color(0xFF4DB6AC)),
    Interest(emoji: '✂️', name: 'DIY', color: Color(0xFF6BCF7F)),
    Interest(emoji: '🏀', name: 'Sports', color: Color(0xFFFF6B6B)),
    Interest(emoji: '💄', name: 'Beauty & Style', color: Color(0xFFFF8FAB)),
    Interest(emoji: '👒', name: 'Fashion Accessories', color: Color(0xFFE91E63)),
    Interest(emoji: '🎨', name: 'Art', color: Color(0xFF9B88FA)),
    Interest(emoji: '💻', name: 'Tech', color: Color(0xFF2196F3)),
    Interest(emoji: '🏎️', name: 'Auto', color: Color(0xFF795548)),
    Interest(emoji: '💃', name: 'Dance', color: Color(0xFFC65BCF)),
    Interest(emoji: '😮', name: 'Oddly Satisfying', color: Color(0xFFFFCA28)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Skip button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _selectedInterests.length >= 3 ? _continue : null,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: _selectedInterests.length >= 3
                          ? Colors.grey.shade600
                          : Colors.grey.shade400,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),

            // Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Choose your\ninterests',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.2,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Get personalized video recommendations',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 15,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Interests grid - в стиле TikTok
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.2,
                ),
                itemCount: _interests.length,
                itemBuilder: (context, index) {
                  final interest = _interests[index];
                  final isSelected = _selectedInterests.contains(interest.name);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedInterests.remove(interest.name);
                        } else {
                          _selectedInterests.add(interest.name);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.black : Colors.white,
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.grey.shade300,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            interest.emoji,
                            style: const TextStyle(fontSize: 22),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              interest.name,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Next button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedInterests.length >= 3 ? _continue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFE2C55),
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Next',
                    style: TextStyle(
                      color: _selectedInterests.length >= 3
                          ? Colors.white
                          : Colors.grey.shade500,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _continue() async {
    if (!mounted) return;

    // Переходим на страницу Swipe Tutorial
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SwipeTutorialScreen()),
    );
  }
}

class Interest {
  final String emoji;
  final String name;
  final Color color;

  Interest({
    required this.emoji,
    required this.name,
    required this.color,
  });
}


import 'package:flutter/material.dart';
import 'package:lynxgaming/constant/theme.dart';

class SkinUnlockerScreen extends StatefulWidget {
  const SkinUnlockerScreen({super.key});

  @override
  State<SkinUnlockerScreen> createState() => _SkinUnlockerScreenState();
}

class _SkinUnlockerScreenState extends State<SkinUnlockerScreen> {
  String searchQuery = '';
  String selectedCategory = 'All';

  final List<String> categories = [
    'All',
    'Normal',
    'Elite',
    'Special',
    'Epic',
    'Legend',
    'Mythic',
  ];

  final List<Map<String, String>> skins = [
    {
      'id': '1',
      'hero': 'Lucaz',
      'name': 'Naruto',
      'description':
          'A divine skin that transforms Aurora into a celestial being with ethereal effects.',
      'category': 'Mythic',
      'size': '45 MB',
      'image':
          'https://i.pinimg.com/736x/56/e1/9a/56e19adc6d51a6265fc1a62bf32d76fa.jpg',
    },
    {
      'id': '2',
      'hero': 'Kai',
      'name': 'DRAGON WARRIOR',
      'description':
          'Harness the power of ancient dragons with this legendary skin.',
      'category': 'Legend',
      'size': '38 MB',
      'image':
          'https://i.pinimg.com/736x/8e/3e/10/8e3e10b10297a6b3d4f4d1516828d9d9.jpg',
    },
  ];

  List<Map<String, String>> get filteredSkins {
    return skins.where((skin) {
      final matchesSearch =
          skin['hero']!.toLowerCase().contains(searchQuery.toLowerCase()) ||
          skin['name']!.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory =
          selectedCategory == 'All' || skin['category'] == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SKIN UNLOCKER', style: AppTypography.titleSmall),
              const SizedBox(height: 4),
              Text(
                'Unlock and customize your favorite heroes',
                style: AppTypography.caption,
              ),
              const SizedBox(height: AppSpacing.medium),
              _buildSearchBar(),
              const SizedBox(height: AppSpacing.medium),
              _buildCategoryList(),
              const SizedBox(height: AppSpacing.medium),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredSkins.length,
                  itemBuilder: (context, index) {
                    final skin = filteredSkins[index];
                    return _buildSkinCard(skin);
                  },
                  padding: const EdgeInsets.only(bottom: AppSpacing.large),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.small),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: AppSpacing.small),
          Expanded(
            child: TextField(
              style: AppTypography.bodyMedium,
              decoration: const InputDecoration(
                hintText: 'Search skins or heroes...',
                hintStyle: TextStyle(color: AppColors.textSecondary),
                border: InputBorder.none,
              ),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.small),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isActive = selectedCategory == category;
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = category),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.medium,
                vertical: AppSpacing.small / 2,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isActive ? AppColors.accent : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category,
                style: AppTypography.bodySmall.copyWith(
                  color: isActive ? AppColors.background : AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkinCard(Map<String, String> skin) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.medium),
      padding: const EdgeInsets.all(AppSpacing.small),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(width: 2, color: AppColors.accent)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with Transform.translate to shift downward
          Transform.translate(
            offset: const Offset(0, 4),
            child: Container(
              width: 100,
              height: 140,
              margin: const EdgeInsets.only(right: AppSpacing.small),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
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
                        color: AppColors.cardBackground.withOpacity(0.7),
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        width: double.infinity,
                        child: Text(
                          skin['hero']!,
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Text and button on the right
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  skin['name']!,
                  style: AppTypography.titleSmall.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  skin['description']!,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.small),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      skin['category']!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.secondary,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      skin['size']!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.small),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.download, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'DOWNLOAD',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
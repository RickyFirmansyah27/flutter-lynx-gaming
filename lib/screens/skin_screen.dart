import 'package:lynxgaming/helpers/download_helper.dart';
import 'package:flutter/material.dart';
import 'package:lynxgaming/constant/theme.dart';
import 'package:lynxgaming/services/skins_services.dart';

class SkinUnlockerScreen extends StatefulWidget {
  const SkinUnlockerScreen({super.key});

  @override
  State<SkinUnlockerScreen> createState() => _SkinUnlockerScreenState();
}


class _SkinUnlockerScreenState extends State<SkinUnlockerScreen> {
  String searchQuery = '';
  String selectedCategory = 'All';
  final Map<String, double> downloadProgress = {};

  final List<String> categories = [
    'All',
    'Normal',
    'Elite',
    'Special',
    'Epic',
    'Legend',
    'Mythic',
  ];

  List<Map<String, dynamic>>? _skins;

  List<Map<String, dynamic>> get filteredSkins {
    final skins = _skins ?? [];
    return skins.where((skin) {
      final name = (skin['nama'] ?? '').toString().toLowerCase();
      final hero = (skin['hero'] ?? '').toString().toLowerCase();
      final category = (skin['tag'] ?? '').toString();
      return (name.contains(searchQuery.toLowerCase()) ||
              hero.contains(searchQuery.toLowerCase())) &&
          (selectedCategory == 'All' || category == selectedCategory);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadSkins();
  }

  Future<void> _loadSkins() async {
    final skins = await getAllSkins();
    setState(() {
      _skins = skins;
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
                child: _skins == null
                    ? const Center(child: CircularProgressIndicator())
                    : filteredSkins.isEmpty
                        ? const Center(child: Text('No skins found'))
                        : ListView.builder(
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

  Widget _buildSkinCard(Map<String, dynamic> skin) {
    final skinId = skin['id']?.toString() ?? skin['nama'];
    final progress = downloadProgress[skinId] ?? 0.0;
    final isDownloading = progress > 0 && progress < 1;
    final isComplete = progress >= 1;

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
                      skin['image_url'] ?? '',
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
                          skin['hero'] ?? '',
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  skin['nama'] ?? '',
                  style: AppTypography.titleSmall.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  skin['description'] ?? 'No description available',
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
                      skin['tag'] ?? '',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.secondary,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      skin['size'] ?? '',
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
                  child: _buildDownloadButton(skin, skinId, progress, isDownloading, isComplete),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton(
    Map<String, dynamic> skin,
    String skinId,
    double progress,
    bool isDownloading,
    bool isComplete,
  ) {
    if (isComplete) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check, size: 16),
            SizedBox(width: 8),
            Text(
              'INSTALLED',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    if (isDownloading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '${(progress * 100).toInt()}%',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
              minHeight: 10,
            ),
          ),
        ],
      );
    }

    return ElevatedButton(
     onPressed: downloadProgress.containsKey(skinId) && downloadProgress[skinId]! > 0
    ? null // Disable jika sudah mulai download
    : () async {
        setState(() {
          downloadProgress[skinId] = 0.01; // Tandai mulai download
        });

        final fileName = skin['hero'];
        final fileUrl = skin['config'];

        try {
          await DownloadHelper.downloadAndExtractZip(
            fileUrl,
            '$fileName',
            onProgress: (progress) {
              setState(() {
                downloadProgress[skinId] = progress;
              });
            },
          );

          setState(() {
            downloadProgress[skinId] = 1.0;
          });
        } catch (e) {
          _showMessage('Download error: $e');
          setState(() {
            downloadProgress.remove(skinId); // Hapus jika gagal
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to download skin: $e')),
          );
        }
      },
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
    );
  }
}
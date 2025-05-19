import 'package:lynxgaming/helpers/download_helper.dart';
import 'package:flutter/material.dart';
import 'package:lynxgaming/constant/theme.dart';
import 'package:lynxgaming/helpers/message_helper.dart';
import 'package:lynxgaming/services/arenas_services.dart';

class ArenaUnlockerScreen extends StatefulWidget {
  const ArenaUnlockerScreen({super.key});

  @override
  State<ArenaUnlockerScreen> createState() => _ArenaUnlockerScreenState();
}

class _ArenaUnlockerScreenState extends State<ArenaUnlockerScreen> {
  String searchQuery = '';
  String selectedCategory = 'All';
  final Map<String, double> downloadProgress = {};

  final int _pageSize = 5;
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMoreData = true;
  final ScrollController _scrollController = ScrollController();

  final List<String> categories = ['All', 'Custom', 'Event', 'Internal'];

  List<Map<String, dynamic>> _displayedarenas = [];
  Future<void> _applyFilters() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _displayedarenas = [];
    });

    final arenas = await getAllArenas(
      queryParams: {
        'page': _currentPage,
        'size': _pageSize,
        'search': searchQuery.isNotEmpty ? searchQuery : null,
        'tag': selectedCategory != 'All' ? selectedCategory : null,
      },
    );

    setState(() {
      _displayedarenas = arenas;
      _isLoading = false;
      _hasMoreData = arenas.length >= _pageSize;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadarenas();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMorearenas();
    }
  }

  Future<void> _snackBarAction(message) async {
    if (!mounted) return;
    SnackBarHelper.showMessage(context, message);
  }

  Future<void> _loadarenas() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _displayedarenas = [];
    });

    final arenas = await getAllArenas(
      queryParams: {'page': _currentPage, 'size': _pageSize},
    );

    setState(() {
      _displayedarenas = arenas;
      _isLoading = false;
      _hasMoreData = arenas.length >= _pageSize;
    });
  }

  Future<void> _loadMorearenas() async {
    if (!_isLoading && _hasMoreData) {
      setState(() {
        _isLoading = true;
        _currentPage++;
      });

      final arenas = await getAllArenas(
        queryParams: {'page': _currentPage, 'size': _pageSize},
      );

      setState(() {
        _displayedarenas.addAll(arenas);
        _isLoading = false;
        _hasMoreData = arenas.length >= _pageSize;
      });
    }
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
              Text('ARENA UNLOCKER', style: AppTypography.titleSmall),
              const SizedBox(height: 4),
              Text(
                'Unlock and customize your favorite arenas',
                style: AppTypography.caption,
              ),
              const SizedBox(height: AppSpacing.medium),
              _buildSearchBar(),
              const SizedBox(height: AppSpacing.medium),
              _buildCategoryList(),
              const SizedBox(height: AppSpacing.medium),
              Expanded(
                child:
                    _isLoading && _displayedarenas.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : _displayedarenas.isEmpty
                        ? const Center(child: Text('No arenas found'))
                        : _buildarenasList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildarenasList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _displayedarenas.length + (_hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _displayedarenas.length) {
          // This is the loading indicator at the bottom
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.medium),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final arena = _displayedarenas[index];
        return _buildarenaCard(arena);
      },
      padding: const EdgeInsets.only(bottom: AppSpacing.large),
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
                hintText: 'Search arenas...',
                hintStyle: TextStyle(color: AppColors.textSecondary),
                border: InputBorder.none,
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
                _applyFilters();
              },
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
            onTap: () {
              setState(() {
                selectedCategory = category;
              });
              _applyFilters();
            },
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
                  color:
                      isActive ? AppColors.background : AppColors.textSecondary,
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

  Widget _buildarenaCard(Map<String, dynamic> arena) {
    final arenaId = arena['id']?.toString() ?? arena['nama'];
    final progress = downloadProgress[arenaId] ?? 0.0;
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
                      arena['image_url'] ?? '',
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
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
                        color: AppColors.cardBackground.withAlpha(
                          (0.7 * 255).round(),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        width: double.infinity,
                        child: Text(
                          arena['hero'] ?? '',
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
                  arena['nama'] ?? '',
                  style: AppTypography.titleSmall.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  arena['desc'] ?? 'No description available',
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
                      arena['tag'] ?? '',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.secondary,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      arena['size'] ?? '',
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
                  child: _buildDownloadButton(
                    arena,
                    arenaId,
                    progress,
                    isDownloading,
                    isComplete,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton(
    Map<String, dynamic> arena,
    String arenaId,
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check, size: 16),
            SizedBox(width: 8),
            Text(
              'INSTALLED',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
      onPressed:
          downloadProgress.containsKey(arenaId) && downloadProgress[arenaId]! > 0
              ? null
              : () async {
                setState(() {
                  downloadProgress[arenaId] = 0.01;
                });

                final fileName = arena['nama'];
                final fileUrl = arena['config'];

                try {
                  await DownloadHelper.downloadAndExtractZip(
                    fileUrl,
                    '$fileName',
                    onProgress: (progress) {
                      if (mounted) {
                        setState(() {
                          downloadProgress[arenaId] = progress;
                        });
                      }
                    },
                  );

                  if (mounted) {
                    setState(() {
                      downloadProgress[arenaId] = 1.0;
                    });
                  }
                } catch (e) {
                  if (mounted) {
                    _snackBarAction('Download error: $e');
                    setState(() {
                      downloadProgress.remove(arenaId);
                    });
                  }
                }
              },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.download, size: 16),
          SizedBox(width: 8),
          Text(
            'DOWNLOAD',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

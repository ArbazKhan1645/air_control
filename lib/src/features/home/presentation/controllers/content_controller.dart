import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:air_control/src/features/home/domain/models/content_item.dart';
import 'package:air_control/src/features/home/data/repositories/content_repository.dart';

final contentRepositoryProvider = Provider((ref) => ContentRepository());

final contentListProvider = AsyncNotifierProvider<ContentListController, List<ContentItem>>(() {
  return ContentListController();
});

class ContentListController extends AsyncNotifier<List<ContentItem>> {
  @override
  Future<List<ContentItem>> build() async {
    return ref.watch(contentRepositoryProvider).getContentItems();
  }

  void submitRating(String id, int rating) {
    state.whenData((items) {
      final index = items.indexWhere((item) => item.id == id);
      if (index != -1) {
        final newItems = List<ContentItem>.from(items);
        newItems[index] = newItems[index].copyWith(userRating: rating.toDouble());
        state = AsyncData(newItems);
      }
    });
  }
}

String formatCount(int count) {
  if (count >= 1000000) {
    return '${(count / 1000000).toStringAsFixed(1)}M';
  } else if (count >= 1000) {
    return '${(count / 1000).toStringAsFixed(1)}K';
  }
  return count.toString();
}

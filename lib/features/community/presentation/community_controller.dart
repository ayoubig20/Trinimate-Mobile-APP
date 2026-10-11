import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/community_repository.dart';

final communityRepositoryProvider =
Provider<CommunityRepository>((ref) => CommunityRepository());

final eventsProvider = FutureProvider<List<dynamic>>(
        (ref) => ref.read(communityRepositoryProvider).events());
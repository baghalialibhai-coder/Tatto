// lib/providers/artist_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/artist_model.dart';
import '../services/database/firestore_service.dart';

class ArtistState {
  final List<ArtistModel> artists;
  final bool isLoading;
  final String? error;
  final ArtistModel? selectedArtist;

  ArtistState({
    this.artists = const [],
    this.isLoading = false,
    this.error,
    this.selectedArtist,
  });

  ArtistState copyWith({
    List<ArtistModel>? artists,
    bool? isLoading,
    String? error,
    ArtistModel? selectedArtist,
  }) {
    return ArtistState(
      artists: artists ?? this.artists,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedArtist: selectedArtist ?? this.selectedArtist,
    );
  }
}

class ArtistNotifier extends StateNotifier<ArtistState> {
  ArtistNotifier() : super(ArtistState());

  final FirestoreService _firestore = FirestoreService();

  Future<void> loadArtists() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final artists = await _firestore.getArtists();
      state = state.copyWith(artists: artists, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load artists: $e',
      );
    }
  }

  Future<void> addArtist(ArtistModel artist) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final id = await _firestore.saveArtist(artist);
      final newArtist = artist.copyWith(id: id);
      state = state.copyWith(
        artists: [newArtist, ...state.artists],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to add artist: $e',
      );
      rethrow;
    }
  }

  Future<void> updateArtist(ArtistModel artist) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _firestore.updateArtist(artist);
      final updatedArtists = state.artists.map((a) {
        return a.id == artist.id ? artist : a;
      }).toList();
      state = state.copyWith(
        artists: updatedArtists,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update artist: $e',
      );
      rethrow;
    }
  }

  Future<void> deleteArtist(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _firestore.deleteArtist(id);
      final updatedArtists = state.artists.where((a) => a.id != id).toList();
      state = state.copyWith(
        artists: updatedArtists,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete artist: $e',
      );
      rethrow;
    }
  }
}

final artistProvider = StateNotifierProvider<ArtistNotifier, ArtistState>((ref) {
  return ArtistNotifier();
});

final activeArtistsProvider = Provider<List<ArtistModel>>((ref) {
  final state = ref.watch(artistProvider);
  return state.artists.where((a) => a.isActive).toList();
});
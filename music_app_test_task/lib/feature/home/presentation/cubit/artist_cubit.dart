import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logger/logger.dart';

import '../../../../utils/ui_constants.dart';
import '../../data/models/artist_list_state_model.dart';
import '../../domain/use_cases/load_artist_tracks.dart';
import '../../domain/use_cases/load_artists.dart';

part 'artist_state.dart';
part 'artist_cubit.freezed.dart';

class ArtistCubit extends Cubit<ArtistState> {
  ArtistCubit(
    this._loadArtistsUsecase,
    this._loadArtistTracksUseCase,
  ) : super(
          ArtistState(
            artistListStateModel: ArtistListStateModel(
              value: [],
              artistListState: ListState.initial,
              trackListData: [],
              trackListState: TrackListState.initial,
            ),
          ),
        );

  final LoadArtistsUseCase _loadArtistsUsecase;
  final LoadArtistTracksUseCase _loadArtistTracksUseCase;
  final logger = Logger();

  Future<void> fetchArtists() async {
    emit(
      state.copyWith(
        artistListStateModel: ArtistListStateModel(
          value: null,
          artistListState: ListState.loading,
        ),
      ),
    );
    final artists = await _loadArtistsUsecase();
    artists.fold(
      (l) => {
        emit(
          state.copyWith(
            artistListStateModel: ArtistListStateModel(
              value: null,
              artistListState: ListState.error,
              message: UIConstants.errorMessage,
            ),
          ),
        ),
      },
      (r) => {
        emit(
          state.copyWith(
            artistListStateModel: ArtistListStateModel(
              value: r,
              artistListState: ListState.loaded,
            ),
          ),
        ),
      },
    );
  }

  Future<void> fetchArtistTrackList(String url) async {
    emit(
      state.copyWith(
        artistListStateModel: ArtistListStateModel(
          trackListData: null,
          trackListState: TrackListState.loading,
        ),
      ),
    );
    final tracks = await _loadArtistTracksUseCase(url);
    tracks.fold(
      (l) => {
        emit(
          state.copyWith(
            artistListStateModel: ArtistListStateModel(
              trackListData: null,
              artistListState: ListState.error,
              message: UIConstants.errorMessage,
            ),
          ),
        ),
      },
      (r) => {
        emit(
          state.copyWith(
            artistListStateModel: ArtistListStateModel(
              trackListData: r,
              artistListState: ListState.loaded,
            ),
          ),
        ),
      },
    );
  }
}

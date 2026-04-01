// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insights_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InsightsNotifier)
final insightsProvider = InsightsNotifierProvider._();

final class InsightsNotifierProvider
    extends $NotifierProvider<InsightsNotifier, InsightsState> {
  InsightsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'insightsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$insightsNotifierHash();

  @$internal
  @override
  InsightsNotifier create() => InsightsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InsightsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InsightsState>(value),
    );
  }
}

String _$insightsNotifierHash() => r'e3b0a31837dea4627fa14bded8504cf9969ce00a';

abstract class _$InsightsNotifier extends $Notifier<InsightsState> {
  InsightsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<InsightsState, InsightsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<InsightsState, InsightsState>,
              InsightsState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:feed_app/bloc/preload_bloc.dart' as _i594;
import 'package:feed_app/services/api/navigation_service.dart' as _i384;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

const String _prod = 'prod';

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.lazySingleton<_i384.NavigationService>(() => _i384.NavigationService());
    gh.factory<_i594.PreloadBloc>(
      () => _i594.PreloadBloc(),
      registerFor: {_prod},
    );
    return this;
  }
}

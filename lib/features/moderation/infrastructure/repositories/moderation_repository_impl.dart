import 'package:app/core/errors/exceptions.dart';
import 'package:app/features/moderation/domain/entities/reporte.dart';
import 'package:app/features/moderation/domain/repositories/moderation_repository.dart';
import 'package:app/features/moderation/infrastructure/datasources/moderation_datasource.dart';
import 'package:app/features/moderation/infrastructure/datasources/remote_moderation_datasource.dart';

class ModerationRepositoryImpl implements ModerationRepository {
  final ModerationDataSource dataSource;
  final RemoteModerationDataSource? remoteDataSource;

  ModerationRepositoryImpl(this.dataSource, {this.remoteDataSource});

  @override
  List<Reporte> getReportesSync() => dataSource.getAllReportes();

  @override
  Future<List<Reporte>> getAllReportes() async {
    if (remoteDataSource != null) {
      try {
        final remote = await remoteDataSource!.getAllReportes();
        for (final reporte in remote) {
          dataSource.updateReporte(reporte);
        }
        return remote;
      } catch (e) {
        if (!_shouldFallbackToLocal(e)) rethrow;
      }
    }
    return dataSource.getAllReportes();
  }

  @override
  Future<List<Reporte>> getReportesByUsuario(int userId) async {
    if (remoteDataSource != null) {
      try {
        return await remoteDataSource!.getReportesByUsuario(userId);
      } catch (e) {
        if (!_shouldFallbackToLocal(e)) rethrow;
      }
    }
    return dataSource.getReportesByUsuario(userId);
  }

  @override
  Future<List<Reporte>> getReportesByPromocion(String promotionCode) async {
    if (remoteDataSource != null) {
      try {
        return await remoteDataSource!.getReportesByPromocion(promotionCode);
      } catch (e) {
        if (!_shouldFallbackToLocal(e)) rethrow;
      }
    }
    return dataSource.getReportesByPromocion(promotionCode);
  }

  @override
  Future<void> addReporte(Reporte reporte) async {
    if (remoteDataSource != null) {
      try {
        final created = await remoteDataSource!.addReporte(reporte);
        dataSource.addReporte(created);
        return;
      } catch (e) {
        if (!_shouldFallbackToLocal(e)) rethrow;
      }
    }
    dataSource.addReporte(reporte);
  }

  @override
  Future<void> updateReporte(Reporte reporte) async {
    if (remoteDataSource != null) {
      try {
        final updated = await remoteDataSource!.updateReporte(reporte);
        dataSource.updateReporte(updated);
        return;
      } catch (e) {
        if (!_shouldFallbackToLocal(e)) rethrow;
      }
    }
    dataSource.updateReporte(reporte);
  }

  @override
  Future<void> deleteReporte(int id) async {
    if (remoteDataSource != null) {
      try {
        await remoteDataSource!.deleteReporte(id);
      } catch (e) {
        if (!_shouldFallbackToLocal(e)) rethrow;
      }
    }
    dataSource.deleteReporte(id);
  }

  bool _shouldFallbackToLocal(Object error) {
    return error is NetworkException;
  }
}

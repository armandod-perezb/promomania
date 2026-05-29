import 'package:app/core/errors/exceptions.dart';
import 'package:app/features/comments/domain/entities/comentario.dart';
import 'package:app/features/comments/domain/repositories/comment_repository.dart';
import 'package:app/features/comments/infrastructure/datasources/comment_datasource.dart';
import 'package:app/features/comments/infrastructure/datasources/remote_comment_datasource.dart';

class CommentRepositoryImpl implements CommentRepository {
  final CommentDataSource dataSource;
  final RemoteCommentDataSource? remoteDataSource;

  CommentRepositoryImpl(this.dataSource, {this.remoteDataSource});

  @override
  List<Comentario> getComentariosSync() => dataSource.getAllComments();

  @override
  Future<List<Comentario>> getAllComments() async {
    if (remoteDataSource != null) {
      try {
        final remote = await remoteDataSource!.getAllComments();
        return remote;
      } catch (e) {
        if (!_shouldFallbackToLocal(e)) rethrow;
      }
    }
    return dataSource.getAllComments();
  }

  @override
  Future<List<Comentario>> getCommentsByPromotion(String promotionCode) async {
    if (remoteDataSource != null) {
      try {
        final remote = await remoteDataSource!.getCommentsByPromotion(promotionCode);
        return remote;
      } catch (e) {
        if (!_shouldFallbackToLocal(e)) rethrow;
      }
    }
    return dataSource.getCommentsByPromotion(promotionCode);
  }

  @override
  Future<void> addComment(Comentario comentario) async {
    if (remoteDataSource != null) {
      try {
        final created = await remoteDataSource!.addComment(comentario);
        dataSource.addComment(created);
        return;
      } catch (e) {
        if (!_shouldFallbackToLocal(e)) rethrow;
      }
    }
    dataSource.addComment(comentario);
  }

  @override
  Future<void> deleteComment(int id) async {
    if (remoteDataSource != null) {
      try {
        await remoteDataSource!.deleteComment(id);
      } catch (e) {
        if (!_shouldFallbackToLocal(e)) rethrow;
      }
    }
    dataSource.deleteComment(id);
  }

  bool _shouldFallbackToLocal(Object error) {
    return error is NetworkException;
  }
}

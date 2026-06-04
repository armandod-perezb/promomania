import 'package:flutter/material.dart';
import 'package:app/Core/storage/image_storage_service.dart';
import '../features/promotions/domain/entities/promocion.dart';
import '../features/users/domain/entities/usuario.dart';
import '../features/promotions/domain/entities/supermercado.dart';

/// Widget reutilizable para mostrar una promocion resumida en listas o grillas.
class PromoCard extends StatelessWidget {
  final Promocion promocion;
  final Usuario? usuario;
  final Supermercado? supermercado;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;

  const PromoCard({
    super.key,
    required this.promocion,
    this.usuario,
    this.supermercado,
    this.onTap,
    this.onFavorite,
    this.isFavorite = false,
  });

  ImageProvider? _imageProvider(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final dataUrlBytes = ImageStorageService.dataUrlToBytes(value);
    if (dataUrlBytes != null) return MemoryImage(dataUrlBytes);

    final url = value.trim();
    if (url.toLowerCase().contains('via.placeholder.com')) return null;
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return NetworkImage(url);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = _imageProvider(promocion.foto);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                image: imageProvider != null
                    ? DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {
                          // Fallback
                        },
                      )
                    : null,
              ),
              child: Stack(
                children: [
                  // Descuento badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '-${promocion.descuento ?? 0}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Botón favorito
                  Positioned(
                    top: 8,
                    left: 8,
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white,
                      ),
                      onPressed: onFavorite,
                    ),
                  ),
                ],
              ),
            ),
            // Contenido
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    promocion.titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Store
                  Row(
                    children: [
                      const Icon(Icons.store, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          supermercado?.nombre ?? 'Sin tienda',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Precio
                  Text(
                    '\$${promocion.precio.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Vistas
                  Row(
                    children: [
                      const Icon(Icons.visibility, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${promocion.vistas} vistas',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

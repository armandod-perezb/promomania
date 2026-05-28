import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../features/promotions/domain/entities/promocion.dart';

class PromocionCard extends StatelessWidget {
  final Promocion promocion;

  /// Callback que recibe el código de la promoción y retorna los bytes de imagen.
  /// Desacopla el widget de cualquier servicio concreto de infraestructura.
  final Future<Uint8List?> Function(String codigo) getImageBytes;
  final VoidCallback? onTap;

  const PromocionCard({
    Key? key,
    required this.promocion,
    required this.getImageBytes,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección de la imagen con overlay
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  // Imagen de fondo
                  FutureBuilder<Uint8List?>(
                    future: getImageBytes(promocion.codigo),
                    builder: (context, snapshot) {
                      // Debug logging
                      print(
                        '🔍 PromocionCard: Código=${promocion.codigo}, Foto=${promocion.foto}, EsLocal=${promocion.fotoEsLocal}',
                      );
                      print(
                        '🔍 FutureBuilder: ConnectionState=${snapshot.connectionState}, HasData=${snapshot.hasData}, Data=${snapshot.data != null ? 'bytes[${snapshot.data!.length}]' : 'null'}',
                      );

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.grey[300]!, Colors.grey[400]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (snapshot.hasData && snapshot.data != null) {
                        return Image.memory(
                          snapshot.data!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholder();
                          },
                        );
                      }

                      return _buildPlaceholder();
                    },
                  ),

                  // Overlay con gradiente para el texto
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              promocion.titulo,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (promocion.ubicacion != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      promocion.ubicacion!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey[300]!, Colors.grey[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'Sin imagen',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../Core/Routes/app_routes.dart';
import '../main.dart';
import '../widgets/promo_card.dart';

/// Pantalla de favoritos simplificada
class FavoritosSimplifiedScreen extends StatefulWidget {
  final int idUsuario;

  const FavoritosSimplifiedScreen({super.key, this.idUsuario = 1});

  @override
  State<FavoritosSimplifiedScreen> createState() =>
      _FavoritosSimplifiedScreenState();
}

class _FavoritosSimplifiedScreenState extends State<FavoritosSimplifiedScreen> {
  @override
  Widget build(BuildContext context) {
    final favoritos = promoService.getFavoritosByUsuario(widget.idUsuario);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Favoritos'), elevation: 0),
      body: favoritos.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No tienes favoritos aún'),
                ],
              ),
            )
          : ListView.builder(
              itemCount: favoritos.length,
              itemBuilder: (context, index) {
                final favorito = favoritos[index];
                final promo = promoService.getPromocionByCodigo(
                  favorito.codigoPromocion,
                );
                if (promo == null) return const SizedBox.shrink();

                final supermercado = promoService.getSupermercado(
                  promo.idSupermercado,
                );

                return PromoCard(
                  promocion: promo,
                  supermercado: supermercado,
                  isFavorite: true,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.promotionDetails,
                      arguments: promo.codigo,
                    );
                  },
                  onFavorite: () {
                    promoService.toggleFavorito(widget.idUsuario, promo.codigo);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Eliminado de favoritos')),
                    );
                  },
                );
              },
            ),
    );
  }
}

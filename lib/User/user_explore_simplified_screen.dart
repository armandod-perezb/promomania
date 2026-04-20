import 'package:flutter/material.dart';
import '../main.dart';
import '../widgets/promo_card.dart';

/// Pantalla simplificada que muestra todas las promociones usando PromoService
class ExploreSimplifiedScreen extends StatefulWidget {
  const ExploreSimplifiedScreen({super.key});

  @override
  State<ExploreSimplifiedScreen> createState() =>
      _ExploreSimplifiedScreenState();
}

class _ExploreSimplifiedScreenState extends State<ExploreSimplifiedScreen> {
  @override
  Widget build(BuildContext context) {
    final promociones = promoService.getPromocionesAprobadas();

    return Scaffold(
      appBar: AppBar(title: const Text('Explorar Promociones'), elevation: 0),
      body: promociones.isEmpty
          ? const Center(child: Text('No hay promociones disponibles'))
          : ListView.builder(
              itemCount: promociones.length,
              itemBuilder: (context, index) {
                final promo = promociones[index];
                final supermercado = promoService.getSupermercado(
                  promo.idSupermercado,
                );
                final esFavorito = promoService.isFavorito(1, promo.codigo);

                return PromoCard(
                  promocion: promo,
                  supermercado: supermercado,
                  isFavorite: esFavorito,
                  onTap: () {
                    promoService.incrementarVistas(promo.codigo);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${promo.titulo} - ${promo.vistas + 1} vistas',
                        ),
                      ),
                    );
                  },
                  onFavorite: () {
                    promoService.toggleFavorito(1, promo.codigo);
                    setState(() {});
                  },
                );
              },
            ),
    );
  }
}

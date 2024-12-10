import 'package:flutter/material.dart';

class VentaItemWidget extends StatelessWidget {
  final Map<String, dynamic> venta;
  final VoidCallback onEditarVenta;

  const VentaItemWidget({
    Key? key,
    required this.venta,
    required this.onEditarVenta,
  }) : super(key: key);

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue[500]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.lightBlue.shade50,
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.receipt_long,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Venta #${venta['id']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Lote: ${venta['id_lote']}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              color: Colors.blue,
              onPressed: onEditarVenta,
              style: IconButton.styleFrom(
                backgroundColor: Colors.blue.withOpacity(0.1),
                padding: const EdgeInsets.all(8),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  Icons.person,
                  'Comprador',
                  venta['id_comprador'].toString(),
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.attach_money,
                  'Precio',
                  '\$${venta['precio_venta']}',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.description,
                  'Condiciones',
                  venta['condiciones'] ?? 'No especificado',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
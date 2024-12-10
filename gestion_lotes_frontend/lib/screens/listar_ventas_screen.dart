import 'package:flutter/material.dart';
import 'package:gestion_lotes_frontend/screens/editar_venta_screen.dart';
import 'package:gestion_lotes_frontend/services/ventas_service.dart';
import 'package:gestion_lotes_frontend/components/venta_item_widget.dart';

class ListarVentasScreen extends StatefulWidget {
  final String token;
  final String rol;

  const ListarVentasScreen({
    Key? key,
    required this.token,
    required this.rol,
  }) : super(key: key);

  @override
  _ListarVentasScreenState createState() => _ListarVentasScreenState();
}

class _ListarVentasScreenState extends State<ListarVentasScreen> {
  List<dynamic> ventas = [];
  List<dynamic> filteredVentas = [];
  bool isLoading = true;
  String searchQuery = '';
  String currentSort = 'none';

  @override
  void initState() {
    super.initState();
    fetchVentas();
  }

  void _sortVentas(String sortType) {
    setState(() {
      currentSort = sortType;
      switch (sortType) {
        case 'recent':
          filteredVentas.sort((a, b) => b['id'].compareTo(a['id']));
          break;
        case 'oldest':
          filteredVentas.sort((a, b) => a['id'].compareTo(b['id']));
          break;
        default:
          filteredVentas = List.from(ventas.where((venta) {
            final compradorId = venta['id_comprador'].toString().toLowerCase();
            final loteId = venta['id_lote'].toString().toLowerCase();
            return compradorId.contains(searchQuery) ||
                loteId.contains(searchQuery);
          }));
      }
    });
  }

  Future<void> fetchVentas() async {
    try {
      final fetchedVentas = await VentasService.fetchVentas(widget.token);
      setState(() {
        ventas = fetchedVentas;
        filteredVentas = ventas;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al obtener ventas'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _filterVentas(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredVentas = ventas.where((venta) {
        final compradorId = venta['id_comprador'].toString().toLowerCase();
        final loteId = venta['id_lote'].toString().toLowerCase();
        return compradorId.contains(searchQuery) ||
            loteId.contains(searchQuery);
      }).toList();
      if (currentSort != 'none') {
        _sortVentas(currentSort);
      }
    });
  }

  void _editarVenta(Map<String, dynamic> venta) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarVentaScreen(
          ventaId: venta['id'],
          precio: double.parse(venta['precio_venta'].toString()),
          condiciones: venta['condiciones'],
          token: widget.token,
          rol: widget.rol,
        ),
      ),
    );

    if (result == true) {
      fetchVentas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Lista de Ventas',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.blue.shade600),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade50,
                  Colors.white,
                  Colors.blue.shade50,
                ],
              ),
            ),
          ),
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withOpacity(0.05),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      labelText: 'Buscar por ID de Comprador o Lote',
                      labelStyle: const TextStyle(
                        color: Colors.black,
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.blue,),
                      suffixIcon: PopupMenuButton<String>(
                        color: Colors.blue.shade50,
                        icon: Icon(
                          Icons.filter_list,
                          color: currentSort != 'none' ? Colors.blue : Colors.grey,
                        ),
                        onSelected: _sortVentas,
                        itemBuilder: (BuildContext context) => [
                          const PopupMenuItem(
                            value: 'recent',
                            child: Row(
                              children: [
                                Icon(Icons.arrow_upward, size: 20),
                                SizedBox(width: 8),
                                Text('Más reciente'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'oldest',
                            child: Row(
                              children: [
                                Icon(Icons.arrow_downward, size: 20),
                                SizedBox(width: 8),
                                Text('Más antiguo'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'none',
                            child: Row(
                              children: [
                                Icon(Icons.clear_all, size: 20),
                                SizedBox(width: 8),
                                Text('Sin filtro'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: _filterVentas,
                  ),
                ),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredVentas.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay ventas que coincidan\ncon la búsqueda',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: filteredVentas.length,
                    itemBuilder: (context, index) {
                      return VentaItemWidget(
                        venta: filteredVentas[index],
                        onEditarVenta: () => _editarVenta(filteredVentas[index]),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:gestion_lotes_frontend/components/decorative_background.dart';
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

class _ListarVentasScreenState extends State<ListarVentasScreen>
    with TickerProviderStateMixin {
  List<dynamic> ventas = [];
  List<dynamic> filteredVentas = [];
  bool isLoading = true;
  String searchQuery = '';
  String currentSort = 'none';
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    fetchVentas();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
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
      _fadeController.forward();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('Error al obtener ventas'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
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

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        cursorColor: Colors.blue.shade600,
        decoration: InputDecoration(
          labelText: 'Buscar por ID de Comprador o Lote',
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
          hintText: 'Ingresa tu búsqueda...',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.search,
              color: Colors.blue.shade600,
              size: 22,
            ),
          ),
          suffixIcon: Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: currentSort != 'none'
                  ? Colors.blue.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: PopupMenuButton<String>(
              color: Colors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              icon: Icon(
                Icons.tune,
                color: currentSort != 'none' ? Colors.blue.shade600 : Colors.grey.shade500,
                size: 22,
              ),
              onSelected: _sortVentas,
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: 'recent',
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(Icons.arrow_upward, size: 16, color: Colors.blue.shade600),
                      ),
                      const SizedBox(width: 12),
                      const Text('Más reciente'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'oldest',
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(Icons.arrow_downward, size: 16, color: Colors.blue.shade600),
                      ),
                      const SizedBox(width: 12),
                      const Text('Más antiguo'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'none',
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(Icons.clear_all, size: 16, color: Colors.grey.shade600),
                      ),
                      const SizedBox(width: 12),
                      const Text('Sin filtro'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        onChanged: _filterVentas,
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.lightBlue.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.analytics_outlined,
              color: Colors.blue.shade600,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total de Ventas',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${filteredVentas.length}',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (currentSort != 'none')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                currentSort == 'recent' ? 'Recientes' : 'Antiguos',
                style: TextStyle(
                  color: Colors.blue.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              searchQuery.isEmpty ? Icons.inventory_2_outlined : Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            searchQuery.isEmpty
                ? 'No hay ventas registradas'
                : 'No hay ventas que coincidan\ncon la búsqueda',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isEmpty
                ? 'Las ventas aparecerán aquí cuando se registren'
                : 'Intenta con otros términos de búsqueda',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Lista de Ventas',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.blue.shade600),
        actions: [
          if (!isLoading)
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.blue.shade600),
              onPressed: () {
                setState(() {
                  isLoading = true;
                });
                fetchVentas();
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          DecorativeBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildSearchBar(),
                if (!isLoading && filteredVentas.isNotEmpty) _buildStatsCard(),
                Expanded(
                  child: isLoading
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Cargando ventas...',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                      : filteredVentas.isEmpty
                      ? _buildEmptyState()
                      : FadeTransition(
                    opacity: _fadeAnimation,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16, top: 8),
                      itemCount: filteredVentas.length,
                      itemBuilder: (context, index) {
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 100 + (index * 50)),
                          curve: Curves.easeOutBack,
                          child: VentaItemWidget(
                            venta: filteredVentas[index],
                            onEditarVenta: () => _editarVenta(filteredVentas[index]),
                          ),
                        );
                      },
                    ),
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
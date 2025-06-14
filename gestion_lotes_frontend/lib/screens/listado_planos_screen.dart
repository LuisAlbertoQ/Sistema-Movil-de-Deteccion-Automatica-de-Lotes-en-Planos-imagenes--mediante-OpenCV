import 'package:flutter/material.dart';
import 'package:gestion_lotes_frontend/imagen_completa_screen.dart';
import '../models/plano_model.dart';
import '../services/planos_service.dart';
import '../components/drawer_widget.dart';
import '../components/plano_card_widget.dart';
import '../main.dart';
import 'subir_plano_screen.dart';
class ListadoPlanosScreen extends StatefulWidget {
  final String token;
  final String rol;

  const ListadoPlanosScreen({Key? key, required this.token, required this.rol}) : super(key: key);

  @override
  _ListadoPlanosScreenState createState() => _ListadoPlanosScreenState();
}

class _ListadoPlanosScreenState extends State<ListadoPlanosScreen>
    with SingleTickerProviderStateMixin {
  List<PlanoModel> planos = [];
  bool isLoading = true;
  String? error;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _cargarPlanos();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _cargarPlanos() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final planosObtenidos = await PlanosService.obtenerPlanos(widget.token);

      setState(() {
        planos = planosObtenidos;
        isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
      _mostrarError(e.toString());
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensaje.replaceAll('Exception:', ''),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: 'Reintentar',
          onPressed: _cargarPlanos,
          textColor: Colors.white,
        ),
      ),
    );
  }

  void _navegarAImagenCompleta(PlanoModel plano) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImagenCompletaScreen(
          imageUrl: plano.getImageUrl(PlanosService.getBaseUrl()),
          nombrePlano: plano.displayName,
          planoData: plano.toJson(),
          token: widget.token,
          rol: widget.rol,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: const Text(
        'Planos',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
          letterSpacing: 0.5,
        ),
      ),
      actions: [
        if (widget.rol == 'admin') _buildAddButton(),
      ],
    );
  }

  Widget _buildAddButton() {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(
          Icons.add_circle_outline,
          color: Colors.blue.shade700,
        ),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SubirPlanoScreen(token: widget.token),
            ),
          );
          if (result == true) {
            _cargarPlanos();
          }
        },
      ),
    );
  }

  Widget _buildDrawer() {
    return CustomDrawer(
      token: widget.token,
      rol: widget.rol,
      onLogout: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyApp()),
        );
      },
    );
  }

  Widget _buildBody() {
    return Container(
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
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (planos.isEmpty) {
      return _buildEmptyState();
    }

    return _buildPlanosList();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.blue.shade600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Cargando planos...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
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
          Icon(
            Icons.image_not_supported_outlined,
            size: 80,
            color: Colors.blue.shade200,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay planos disponibles',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[800],
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega un nuevo plano usando el botón +',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanosList() {
    return RefreshIndicator(
      onRefresh: _cargarPlanos,
      color: Colors.blue.shade600,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: planos.length,
        itemBuilder: (context, index) {
          final plano = planos[index];
          return PlanoCardWidget(
            plano: plano,
            index: index,
            totalPlanos: planos.length,
            animationController: _animationController,
            onTap: () => _navegarAImagenCompleta(plano),
          );
        },
      ),
    );
  }
}
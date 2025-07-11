import 'package:flutter/material.dart';
import 'package:gestion_lotes_frontend/core/utils/time_utils.dart';
import '../models/log_actividad_model.dart';

class LogActividadItem extends StatefulWidget {
  final LogActividad log;

  const LogActividadItem({
    Key? key,
    required this.log,
  }) : super(key: key);

  @override
  _LogActividadItemState createState() => _LogActividadItemState();
}

class _LogActividadItemState extends State<LogActividadItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? iconColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: (iconColor ?? Colors.blue).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 16,
              color: iconColor ?? Colors.blue.shade600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  // Método mejorado que usa el campo tipoAccion del backend
  IconData _getActionIcon(String tipoAccion) {
    switch (tipoAccion.toLowerCase()) {
      case 'crear':
      case 'registro':
        return Icons.add_circle_outline;
      case 'editar':
        return Icons.edit_outlined;
      case 'eliminar':
        return Icons.delete_outline;
      case 'login':
        return Icons.login;
      case 'logout':
        return Icons.logout;
      case 'consultar':
        return Icons.visibility_outlined;
      case 'subir':
        return Icons.upload_outlined;
      case 'venta':
        return Icons.monetization_on_outlined;
      default:
        return Icons.history;
    }
  }

  // Método mejorado que usa el campo tipoAccion del backend
  Color _getActionColor(String tipoAccion) {
    switch (tipoAccion.toLowerCase()) {
      case 'crear':
      case 'registro':
        return Colors.green;
      case 'editar':
        return Colors.orange;
      case 'eliminar':
        return Colors.red;
      case 'login':
        return Colors.blue;
      case 'logout':
        return Colors.grey;
      case 'consultar':
        return Colors.purple;
      case 'subir':
        return Colors.teal;
      case 'venta':
        return Colors.amber;
      default:
        return Colors.blue;
    }
  }

  String _getTimeAgo(String fechaISO) {
    try {
      final fecha = TimeUtils.parseFromApi(fechaISO);
      final now = TimeUtils.toLimaTime(DateTime.now());
      final difference = now.difference(fecha);

      if (difference.inMinutes < 1) {
        return 'Hace un momento';
      } else if (difference.inMinutes < 60) {
        return 'Hace ${difference.inMinutes} min';
      } else if (difference.inHours < 24) {
        return 'Hace ${difference.inHours} h';
      } else if (difference.inDays < 7) {
        return 'Hace ${difference.inDays} días';
      } else {
        return TimeUtils.formatToLimaTime(fecha);
      }
    } catch (e) {
      return 'Fecha no válida';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usar el campo tipoAccion del backend
    final actionIcon = _getActionIcon(widget.log.tipoAccion);
    final actionColor = _getActionColor(widget.log.tipoAccion);

    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Card(
            elevation: 3,
            shadowColor: Colors.blue.withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.lightBlue.shade50,
                    Colors.blue.shade50,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header con usuario y tiempo
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                actionColor.withOpacity(0.2),
                                actionColor.withOpacity(0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: actionColor.withOpacity(0.3)),
                          ),
                          child: Icon(
                            actionIcon,
                            color: actionColor.withOpacity(0.6),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Usuario ${widget.log.usuario}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.blue.withOpacity(0.8),
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _getTimeAgo(widget.log.fecha),
                                      style: TextStyle(
                                        color: Colors.blue.shade600,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: actionColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  widget.log.tipoAccion.toUpperCase(),
                                  style: TextStyle(
                                    color: actionColor.withOpacity(0.7),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Detalles
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withOpacity(0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 3,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade600,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Detalles de la Actividad',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            Icons.person_outline,
                            'Usuario ID',
                            widget.log.usuario.toString(),
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            actionIcon,
                            'Descripción',
                            widget.log.accion,
                            iconColor: actionColor,
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            Icons.access_time,
                            'Fecha y Hora',
                            TimeUtils.formatToLimaTime(TimeUtils.parseFromApi(widget.log.fecha)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
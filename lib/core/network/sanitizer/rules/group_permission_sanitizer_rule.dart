import 'package:dio/dio.dart';
import 'package:vrcma/core/network/sanitizer/i_json_sanitizer_rule.dart';

/// Regla para limpiar los permisos de grupos que la API de VRChat ha añadido
/// recientemente pero que la librería vrchat_dart (built_value) aún no soporta,
/// evitando así fallos de parseo.
class GroupPermissionSanitizerRule implements IJsonSanitizerRule {
  
  // Lista de permisos conocidos y soportados por la versión actual de vrchat_dart
  static const Set<String> _knownPermissions = {
    '*',
    'group-announcement-manage',
    'group-audit-view',
    'group-bans-manage',
    'group-calendar-manage',
    'group-data-manage',
    'group-default-role-manage',
    'group-galleries-manage',
    'group-instance-age-gated-create',
    'group-instance-calendar-link',
    'group-instance-join',
    'group-instance-manage',
    'group-instance-moderate',
    'group-instance-open-create',
    'group-instance-plus-create',
    'group-instance-plus-portal',
    'group-instance-plus-portal-unlocked',
    'group-instance-public-create',
    'group-instance-queue-priority',
    'group-instance-restricted-create',
    'group-invites-manage',
    'group-members-manage',
    'group-members-remove',
    'group-members-viewall',
    'group-roles-assign',
    'group-roles-manage',
  };

  @override
  bool canHandle(RequestOptions options) {
    // Aplica si el endpoint contiene '/groups/' y es método GET (ya que es cuando leemos)
    return options.path.contains('/groups/') && options.method.toUpperCase() == 'GET';
  }

  @override
  dynamic sanitize(dynamic data) {
    if (data == null) return data;
    
    // Si la respuesta es un Map (ej: respuesta de getGroup)
    if (data is Map<String, dynamic>) {
      return _sanitizeMap(data);
    } 
    // Si la respuesta es un List (ej: respuesta de getGroups o getGroupRoles)
    else if (data is List) {
      return data.map((item) {
        if (item is Map<String, dynamic>) {
          return _sanitizeMap(item);
        }
        return item;
      }).toList();
    }
    
    return data;
  }

  Map<String, dynamic> _sanitizeMap(Map<String, dynamic> map) {
    final Map<String, dynamic> sanitized = {};

    map.forEach((key, value) {
      if (key == 'permissions' && value is List) {
        // Filtramos la lista para quedarnos solo con los permisos conocidos
        sanitized[key] = value.where((perm) {
          if (perm is String) {
            return _knownPermissions.contains(perm);
          }
          return false;
        }).toList();
      } else if (value is Map<String, dynamic>) {
        sanitized[key] = _sanitizeMap(value);
      } else if (value is List) {
        sanitized[key] = value.map((item) {
          if (item is Map<String, dynamic>) {
            return _sanitizeMap(item);
          }
          return item;
        }).toList();
      } else {
        sanitized[key] = value;
      }
    });

    return sanitized;
  }
}

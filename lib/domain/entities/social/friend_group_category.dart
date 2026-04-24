import 'package:flutter/cupertino.dart';
import 'package:vrcma/domain/entities/auth/vrc_user.dart';

class FriendGroupCategory {
  final String id;
  final String title;
  final IconData icon;
  final List<VrcUser> friends;
  
  const FriendGroupCategory({
    required this.id,
    required this.title,
    required this.icon,
    required this.friends,
  });
}
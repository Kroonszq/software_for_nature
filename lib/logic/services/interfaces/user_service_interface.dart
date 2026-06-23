
import 'package:software_for_nature/data/models/user.dart';

abstract interface class UserServiceInterface {

  Future<List<User>> getAllUsers();

  /// The single "current" user (first in the store), with groups and their
  /// categories hydrated.
  Future<User?> getCurrentUser();

}
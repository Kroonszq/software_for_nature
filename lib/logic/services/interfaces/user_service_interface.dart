
import 'package:software_for_nature/data/models/user.dart';

abstract interface class UserServiceInterface {

  Future<List<User>> getAllUsers();

  Future<User?> getCurrentUser();

}
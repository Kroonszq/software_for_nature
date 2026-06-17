import 'package:software_for_nature/data/models/user.dart';
import 'package:software_for_nature/data/repositories/base_repository.dart';
import 'package:software_for_nature/data/repositories/interfaces/user_repository_interface.dart';

class UserRepository extends BaseRepository<User> implements UserRepositoryInterface {
  UserRepository({required super.jsonClient});
}

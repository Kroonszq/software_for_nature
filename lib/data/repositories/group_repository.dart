
import 'package:software_for_nature/data/models/group.dart';
import 'package:software_for_nature/data/repositories/base_repository.dart';
import 'package:software_for_nature/data/repositories/interfaces/group_repository_interface.dart';

class GroupRepository extends BaseRepository<Group> implements GroupRepositoryInterface {
  GroupRepository({required super.jsonClient});

}
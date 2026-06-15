import 'package:software_for_nature/data/repositories/base_repository.dart';
import 'package:software_for_nature/data/repositories/interfaces/event_post_repository_interface.dart';

import '../models/event_post.dart';

class EventPostRepository extends BaseRepository<EventPost> implements EventPostRepositoryInterface {

  EventPostRepository({required super.jsonClient});

}


import 'package:flutter/material.dart';
import 'package:software_for_nature/data/models/coordinates.dart';
import 'package:software_for_nature/data/models/group.dart';
import '../models/event_post.dart';


class EventPostApiClient {

  Future<EventPost> fetchEarliestEvent() async {
    final events = await fetchEventPosts();

    return events.reduce((a, b) =>
        a.startDuration.isBefore(b.startDuration) ? a : b);
  }

  Future<EventPost> fetchLatestEvent() async {
    final events = await fetchEventPosts();

    return events.reduce((a, b) =>
        a.endDuration.isAfter(b.endDuration) ? a : b);
  }
  
  Future<List<EventPost>> fetchEventPosts() async {
    // simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final basePosts = <EventPost>[
  // ─── Group 1 - Morning events (overlapping) ───
  EventPost(
    id: '1',
    title: 'River Cleanup',
    description: 'Volunteers cleaning the river.',
    timestamp: DateTime.now(),
    startDuration: DateTime.now().subtract(const Duration(hours: 5)),
    endDuration: DateTime.now().subtract(const Duration(hours: 3)),
    coordinates: const Coordinates(lat: 52.0907, lng: 5.1214),
    group: Group(title: "Group 1", color: Colors.red),
  ),
  EventPost(
    id: '2',
    title: 'Forest Walk',
    description: 'Nature observation walk.',
    timestamp: DateTime.now(),
    startDuration: DateTime.now().subtract(const Duration(hours: 5)),
    endDuration: DateTime.now().subtract(const Duration(hours: 2)),
    coordinates: const Coordinates(lat: 52.1000, lng: 5.1100),
    group: Group(title: "Group 1", color: Colors.red),
  ),
  EventPost(
    id: '3',
    title: 'Bird Watching',
    description: 'Observe migratory birds.',
    timestamp: DateTime.now(),
    startDuration: DateTime.now().subtract(const Duration(hours: 4)),
    endDuration: DateTime.now().subtract(const Duration(hours: 2)),
    coordinates: const Coordinates(lat: 52.0800, lng: 5.1300),
    group: Group(title: "Group 1", color: Colors.red),
  ),
  EventPost(
    id: '4',
    title: 'Soil Sample',
    description: 'Collect soil samples.',
    timestamp: DateTime.now(),
    startDuration: DateTime.now().subtract(const Duration(hours: 4)),
    endDuration: DateTime.now().subtract(const Duration(hours: 3)),
    coordinates: const Coordinates(lat: 52.0950, lng: 5.1250),
    group: Group(title: "Group 1", color: Colors.red),
  ),
  EventPost(
    id: '5',
    title: 'Water Test',
    description: 'Test water quality.',
    timestamp: DateTime.now(),
    startDuration: DateTime.now().subtract(const Duration(hours: 3, minutes: 30)),
    endDuration: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
    coordinates: const Coordinates(lat: 52.0920, lng: 5.1220),
    group: Group(title: "Group 1", color: Colors.red),
  ),
  EventPost(
    id: '6',
    title: 'Tree Planting',
    description: 'Plant native trees.',
    timestamp: DateTime.now(),
    startDuration: DateTime.now().subtract(const Duration(hours: 2)),
    endDuration: DateTime.now().subtract(const Duration(hours: 1)),
    coordinates: const Coordinates(lat: 52.0870, lng: 5.1180),
    group: Group(title: "Group 1", color: Colors.red),
  ),
  EventPost(
    id: '7',
    title: 'Insect Count',
    description: 'Count insect species.',
    timestamp: DateTime.now(),
    startDuration: DateTime.now().subtract(const Duration(hours: 2)),
    endDuration: DateTime.now().subtract(const Duration(minutes: 30)),
    coordinates: const Coordinates(lat: 52.0910, lng: 5.1200),
    group: Group(title: "Group 1", color: Colors.red),
  ),
  EventPost(
    id: '8',
    title: 'Trail Mapping',
    description: 'Map new hiking trails.',
    timestamp: DateTime.now(),
    startDuration: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
    endDuration: DateTime.now().subtract(const Duration(minutes: 15)),
    coordinates: const Coordinates(lat: 52.0890, lng: 5.1230),
    group: Group(title: "Group 1", color: Colors.red),
  ),
  EventPost(
    id: '9',
    title: 'Litter Pick',
    description: 'Clean up litter on trails.',
    timestamp: DateTime.now(),
    startDuration: DateTime.now().subtract(const Duration(hours: 1)),
    endDuration: DateTime.now(),
    coordinates: const Coordinates(lat: 52.0930, lng: 5.1210),
    group: Group(title: "Group 1", color: Colors.red),
  ),
  EventPost(
    id: '10',
    title: 'Photo Survey',
    description: 'Document wildlife with photos.',
    timestamp: DateTime.now(),
    startDuration: DateTime.now().subtract(const Duration(minutes: 45)),
    endDuration: DateTime.now(),
    coordinates: const Coordinates(lat: 52.0900, lng: 5.1190),
    group: Group(title: "Group 1", color: Colors.red),
  ),

  // ─── Group 2 - Afternoon events (overlapping) ───
  EventPost(
    id: '11',
    title: 'Canoe Trip',
    description: 'Canoe along the river.',
    timestamp: DateTime.now(),
    startDuration: DateTime.now().subtract(const Duration(hours: 6)),
    endDuration: DateTime.now().subtract(const Duration(hours: 4)),
    coordinates: const Coordinates(lat: 52.1100, lng: 5.1400),
    group: Group(title: "Group 2", color: Colors.green),
  ),
  EventPost(
    id: '12',
    title: 'Fungi Survey',
    description: 'Survey mushroom species.',
    timestamp: DateTime.now(),
    startDuration: DateTime.now().subtract(const Duration(hours: 6)),
    endDuration: DateTime.now().subtract(const Duration(hours: 5)),
    coordinates: const Coordinates(lat: 52.1150, lng: 5.1450),
    group: Group(title: "Group 2", color: Colors.green),
  ),
  EventPost(
    id: '13',
    title: 'Air Quality',
    description: 'Measure air quality levels.',
    timestamp: DateTime.now(),
    startDuration: DateTime.now().subtract(const Duration(hours: 5, minutes: 30)),
    endDuration: DateTime.now().subtract(const Duration(hours: 4, minutes: 30)),
    coordinates: const Coordinates(lat: 52.1120, lng: 5.1420),
    group: Group(title: "Group 2", color: Colors.green),
  ),
  EventPost(
    id: '14',
    title: 'Nest Check',
    description: 'Check bird nesting boxes.',
    timestamp: DateTime.now(),
    startDuration: DateTime.now().subtract(const Duration(hours: 5)),
    endDuration: DateTime.now().subtract(const Duration(hours: 4)),
    coordinates: const Coordinates(lat: 52.1130, lng: 5.1430),
    group: Group(title: "Group 2", color: Colors.green),
  ),
  EventPost(
    id: '15',
    title: 'Seed Collection',
    description: 'Collect native plant seeds.',
    timestamp: DateTime.now(),
    startDuration: DateTime.now().subtract(const Duration(hours: 4, minutes: 30)),
    endDuration: DateTime.now().subtract(const Duration(hours: 3)),
    coordinates: const Coordinates(lat: 52.1110, lng: 5.1410),
    group: Group(title: "Group 2", color: Colors.green),
  ),
  EventPost(
    id: '16',
    title: 'Pond Dip',
    description: 'Sample pond life.',
    timestamp: DateTime.now(),
    startDuration: DateTime.now().subtract(const Duration(hours: 4)),
    endDuration: DateTime.now().subtract(const Duration(hours: 3)),
    coordinates: const Coordinates(lat: 52.1140, lng: 5.1440),
    group: Group(title: "Group 2", color: Colors.green),
  ),
  EventPost(
    id: '17',
    title: 'Weather Log',
    description: 'Log weather conditions.',
    timestamp: DateTime.now(),
    startDuration: DateTime.now().subtract(const Duration(hours: 3, minutes: 30)),
    endDuration: DateTime.now().subtract(const Duration(hours: 2)),
    coordinates: const Coordinates(lat: 52.1160, lng: 5.1460),
    group: Group(title: "Group 2", color: Colors.green),
  ),
  EventPost(
    id: '18',
    title: 'Invasive Species',
    description: 'Remove invasive plants.',
    timestamp: DateTime.now(),
    startDuration: DateTime.now().subtract(const Duration(hours: 3)),
    endDuration: DateTime.now().subtract(const Duration(hours: 2)),
    coordinates: const Coordinates(lat: 52.1125, lng: 5.1425),
    group: Group(title: "Group 2", color: Colors.green),
  ),
  EventPost(
    id: '19',
    title: 'Bat Survey',
    description: 'Survey bat activity.',
    timestamp: DateTime.now(),
    startDuration: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
    endDuration: DateTime.now().subtract(const Duration(hours: 1)),
    coordinates: const Coordinates(lat: 52.1135, lng: 5.1435),
    group: Group(title: "Group 2", color: Colors.green),
  ),
  EventPost(
    id: '20',
    title: 'Hedgerow Check',
    description: 'Inspect hedgerow health.',
    timestamp: DateTime.now(),
    startDuration: DateTime.now().subtract(const Duration(hours: 2)),
    endDuration: DateTime.now().subtract(const Duration(minutes: 30)),
    coordinates: const Coordinates(lat: 52.1145, lng: 5.1445),
    group: Group(title: "Group 2", color: Colors.green),
  ),

  // ─── Group 3 - Evening events (overlapping) ───
  EventPost(
    id: '21',
    title: 'Campfire Talk',
    description: 'Evening nature discussion.',
    timestamp: DateTime.now(),
    startDuration: DateTime.now().subtract(const Duration(hours: 7)),
    endDuration: DateTime.now().subtract(const Duration(hours: 5)),
    coordinates: const Coordinates(lat: 52.0800, lng: 5.1000),
    group: Group(title: "Group 3", color: Colors.blue),
  ),
  EventPost(
    id: '22',
    title: 'Star Gazing',
    description: 'Observe the night sky.',
    timestamp: DateTime.now(),
    startDuration: DateTime.now().subtract(const Duration(hours: 7)),
    endDuration: DateTime.now().subtract(const Duration(hours: 6)),
    coordinates: const Coordinates(lat: 52.0810, lng: 5.1010),
    group: Group(title: "Group 3", color: Colors.blue),
  ),
  EventPost(
    id: '23',
    title: 'Owl Walk',
    description: 'Listen for owls at dusk.',
    timestamp: DateTime.now(),
    startDuration: DateTime.now().subtract(const Duration(hours: 6, minutes: 30)),
    endDuration: DateTime.now().subtract(const Duration(hours: 5)),
    coordinates: const Coordinates(lat: 52.0820, lng: 5.1020),
    group: Group(title: "Group 3", color: Colors.blue),
  ),
  EventPost(
    id: '24',
    title: 'Moth Trap',
    description: 'Set up moth traps.',
    timestamp: DateTime.now(),
    startDuration: DateTime.now().subtract(const Duration(hours: 6)),
    endDuration: DateTime.now().subtract(const Duration(hours: 5)),
    coordinates: const Coordinates(lat: 52.0830, lng: 5.1030),
    group: Group(title: "Group 3", color: Colors.blue),
  ),
  EventPost(
    id: '25',
    title: 'Night Hike',
    description: 'Guided night hike.',
    timestamp: DateTime.now(),
    startDuration: DateTime.now().subtract(const Duration(hours: 5, minutes: 30)),
    endDuration: DateTime.now().subtract(const Duration(hours: 4)),
    coordinates: const Coordinates(lat: 52.0840, lng: 5.1040),
    group: Group(title: "Group 3", color: Colors.blue),
  ),
  EventPost(
    id: '26',
    title: 'Fox Watch',
    description: 'Watch for foxes at dusk.',
    timestamp: DateTime.now(),
    startDuration: DateTime.now().subtract(const Duration(hours: 5)),
    endDuration: DateTime.now().subtract(const Duration(hours: 4)),
    coordinates: const Coordinates(lat: 52.0850, lng: 5.1050),
    group: Group(title: "Group 3", color: Colors.blue),
  ),
  EventPost(
    id: '27',
    title: 'Stream Survey',
    description: 'Survey stream invertebrates.',
    timestamp: DateTime.now(),
    startDuration: DateTime.now().subtract(const Duration(hours: 4, minutes: 30)),
    endDuration: DateTime.now().subtract(const Duration(hours: 3)),
    coordinates: const Coordinates(lat: 52.0860, lng: 5.1060),
    group: Group(title: "Group 3", color: Colors.blue),
  ),
  EventPost(
    id: '28',
    title: 'Dew Pond',
    description: 'Monitor dew pond levels.',
    timestamp: DateTime.now(),
    startDuration: DateTime.now().subtract(const Duration(hours: 4)),
    endDuration: DateTime.now().subtract(const Duration(hours: 3)),
    coordinates: const Coordinates(lat: 52.0870, lng: 5.1070),
    group: Group(title: "Group 3", color: Colors.blue),
  ),
  EventPost(
    id: '29',
    title: 'Frog Count',
    description: 'Count frog populations.',
    timestamp: DateTime.now(),
    startDuration: DateTime.now().subtract(const Duration(hours: 3, minutes: 30)),
    endDuration: DateTime.now().subtract(const Duration(hours: 2)),
    coordinates: const Coordinates(lat: 52.0880, lng: 5.1080),
    group: Group(title: "Group 3", color: Colors.blue),
  ),
  EventPost(
    id: '30',
    title: 'Sunrise Watch',
    description: 'Watch the sunrise together.',
    timestamp: DateTime.now(),
    startDuration: DateTime.now().subtract(const Duration(hours: 3)),
    endDuration: DateTime.now().subtract(const Duration(hours: 1)),
    coordinates: const Coordinates(lat: 52.0890, lng: 5.1090),
    group: Group(title: "Group 3", color: Colors.blue),
  ),
];

    // Integrate tags: give every event its thematic tags.
    return basePosts;
  }
}
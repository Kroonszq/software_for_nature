import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_for_nature/logic/bloc/map/map_bloc.dart';
import 'package:software_for_nature/presentation/widgets/layout.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  Widget build(BuildContext context) {
    return Layout(
      child: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          if (state is MapLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MapLoaded) {
            return ListView(
              children: state.posts.map((post) {
                return ListTile(
                  title: Text(post.title),
                  subtitle: Text(
                    post.coordinates != null
                        ? "Lat: ${post.coordinates!.lat}, Lng: ${post.coordinates!.lng}"
                        : "No location",
                  ),
                  onTap: () {
                    context.read<MapBloc>().add(
                          SelectMapEvent(post),
                        );
                  },
                );
              }).toList(),
            );
          }

          return const Center(child: Text("No map data"));
        },
      ),
    );
  }
}
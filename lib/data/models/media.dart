// ### Raw Image Download (JPG)
// # Serves: /pics/EMOV/20260322/1500/EMOV_20260322-150000.jpg
// GET {{baseUrl}}/pics/EMOV/20260322/1500/EMOV_20260322-150000.jpg

// ### Video File Download (Binary AVI stream)
// # Serves: /multimedia/avi/EMOV_20260322-150000.avi
// # Note: NGINX uses stName, year, month, day, and time to build this exact file name
// GET {{baseUrl}}/video/VideoFile/query
//     ?stName=EMOV
//     &year=2026
//     &month=03
//     &day=22
//     &time=150000

sealed class Media {
  final String id;
  final String title;
  final String altText;
  final String source;

  const Media({
    required this.id,
    required this.title,
    required this.altText,
    required this.source,
  });
}

final class ImageMedia extends Media {


  const ImageMedia({
    required super.id,
    required super.title,
    required super.altText,
    required super.source,
  });
}

final class VideoMedia extends Media {


  const VideoMedia({
    required super.id,
    required super.title,
    required super.altText,
    required super.source,
  });
}

final class PdfMedia extends Media {


  const PdfMedia({
    required super.id,
    required super.title,
    required super.altText,
    required super.source,
  });
}
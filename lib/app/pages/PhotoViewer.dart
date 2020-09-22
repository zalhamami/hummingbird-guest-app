import 'package:hummingbird_guest_apps/app/models/Photo.dart';
import 'package:flutter/widgets.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PhotoViewer extends StatefulWidget {
  final List<Photo> photos;
  final String heroKey;
  final int currentPage;

  PhotoViewer({
    @required this.photos,
    @required this.heroKey,
    this.currentPage = 1,
  })  : assert(photos != null),
        assert(photos.isNotEmpty);

  @override
  _PhotoViewerState createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<PhotoViewer> {
  var photoView;

  @override
  void initState() {
    if (!mounted) return;
    if (widget.photos.length > 1) {
      final _controller = PageController(initialPage: widget.currentPage);
      photoView = Hero(
        tag: widget.heroKey,
        child: PhotoViewGallery(
          pageController: _controller,
          pageOptions: widget.photos
              .map((photo) => PhotoViewGalleryPageOptions(
                    imageProvider: photo.provider,
                  ))
              .toList(),
        ),
      );
    } else {
      photoView = PhotoView(
        imageProvider: widget.photos.first.provider,
        heroAttributes: PhotoViewHeroAttributes(tag: widget.heroKey),
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.expand(
        height: MediaQuery.of(context).size.height,
      ),
      child: photoView,
    );
  }
}

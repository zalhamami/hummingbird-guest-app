import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';

enum PhotoType { Asset, Network, File }

class Photo {
  PhotoType type;
  String path;
  File file;

  Photo({this.type, this.path, this.file});

  Photo.fromNetwork(this.path) : type = PhotoType.Network;
  Photo.fromAsset(this.path) : type = PhotoType.Asset;
  Photo.fromFile(this.file)
      : type = PhotoType.File,
        path = file.path;
  Photo.noAvailable()
      : type = PhotoType.Asset,
        path = 'assets/images/flutter-logo.png';

  ImageProvider get provider {
    ImageProvider provider;

    switch (type) {
      case PhotoType.Network:
        provider = CachedNetworkImageProvider(path);
        break;
      case PhotoType.Asset:
        provider = AssetImage(path);
        break;
      case PhotoType.File:
        provider = FileImage(file);
        break;
    }

    return provider;
  }
}

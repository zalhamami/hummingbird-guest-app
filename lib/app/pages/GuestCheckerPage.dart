import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hummingbird_guest_apps/app/models/Contact.dart';
import 'package:hummingbird_guest_apps/app/models/Guest.dart';
import 'package:hummingbird_guest_apps/app/models/Photo.dart';
import 'package:hummingbird_guest_apps/app/models/Wedding.dart';
import 'package:hummingbird_guest_apps/app/pages/GuestList.dart';
import 'package:hummingbird_guest_apps/app/pages/GuestVerified.dart';
import 'package:hummingbird_guest_apps/app/pages/InvitationDetail.dart';
import 'package:hummingbird_guest_apps/app/pages/MainPage.dart';
import 'package:hummingbird_guest_apps/app/pages/PhotoViewer.dart';
import 'package:hummingbird_guest_apps/app/services/Service.dart';
import 'package:hummingbird_guest_apps/app/states/application/ApplicationStateProvider.dart';
import 'package:hummingbird_guest_apps/app/ui-items/HummingbirdColor.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class GuestCheckerPage extends StatefulWidget {
  final Wedding wedding;

  const GuestCheckerPage({
    Key key,
    this.wedding,
  }) : super(key: key);

  @override
  _GuestCheckerPageState createState() => _GuestCheckerPageState();
}

class _GuestCheckerPageState extends State<GuestCheckerPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController qrController;

  void _openEndDrawer() {
    _scaffoldKey.currentState.openEndDrawer();
  }

  final _menuItems = <MenuItem>[];

  @override
  void dispose() {
    qrController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _menuItems.addAll([
      MenuItem(
        label: 'Detail Undangan',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => InvitationDetail(
              wedding: widget.wedding,
            ),
          ),
        ),
      ),
      MenuItem(
        label: 'Daftar Tamu',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GuestList(
              wedding: widget.wedding,
            ),
          ),
        ),
      ),
      MenuItem(
        label: 'Ganti Wedding Code',
        onTap: () {
          SharedPreferences.getInstance()
              .then((value) => value.remove('weddingCode'));
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => MainPage(),
            ),
          );
        },
      ),
      MenuItem(
        label: 'Bantuan',
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (_) => Container(
              color: HummingbirdColor.black,
              child: FutureBuilder<List<Contact>>(
                future: Service.getContact(),
                builder: (context, snapshot) {
                  if (snapshot.hasError)
                    return Center(child: Text('${snapshot.error}'));

                  if (snapshot.hasData) {
                    final data = snapshot.data;

                    return ListView(
                      shrinkWrap: true,
                      children: data
                          .map((contact) => GestureDetector(
                                onTap: () async {
                                  Navigator.of(context).pop();
                                  final _url = contact.url;
                                  if (await canLaunch(_url)) await launch(_url);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        width: .5,
                                        color: HummingbirdColor.grey,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          right: 10.0,
                                        ),
                                        child: Icon(
                                          contact.icon,
                                          size: 28.0,
                                          color: HummingbirdColor.white,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          contact.label,
                                          style: TextStyle(
                                            color: HummingbirdColor.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ))
                          .toList(),
                    );
                  }

                  return Center(child: CircularProgressIndicator());
                },
              ),
            ),
          );
        },
      ),
    ]);
    super.initState();
  }

  var _qrFlashOn = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBackButton,
      child: SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          endDrawer: _buildDrawer(),
          body: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overScroll) {
              overScroll.disallowGlow();
              return;
            },
            child: DefaultTextStyle(
              style: TextStyle(
                color: HummingbirdColor.white,
              ),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                children: <Widget>[
                  _buildUserHeader(),
                  Padding(padding: const EdgeInsets.symmetric(vertical: 35.0)),
                  ..._buildTitle(),
                  _buildScanQR(),
                  _buildAdditionalButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  final _qrSize = 300.0;

  Widget _buildScanQR() {
    return Container(
      height: _qrSize,
      width: _qrSize,
      margin: const EdgeInsets.symmetric(vertical: 45.0),
      child: Center(
        child: Stack(
          children: <Widget>[
            QRView(
              key: _qrKey,
              onQRViewCreated: (controller) {
                setState(() => this.qrController = controller);
                qrController.scannedDataStream.listen((value) {
                  _doScan(value);
                });
              },
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  height: _qrSize / 1.5,
                  width: _qrSize / 1.5,
                  decoration: BoxDecoration(
                    color: HummingbirdColor.transparent,
                    image: DecorationImage(
                      image: Photo(
                        path: 'assets/images/corner-border.png',
                        type: PhotoType.Asset,
                      ).provider,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalButton() {
    return Center(
      child: IconButton(
        icon: Icon(
          _qrFlashOn ? Icons.flash_on : Icons.flash_off,
          size: 28.0,
          color: HummingbirdColor.white,
        ),
        onPressed: () {
          if (qrController != null) {
            qrController.toggleFlash();
            setState(() => _qrFlashOn = !_qrFlashOn);
          }
        },
      ),
    );
  }

  Future<void> _doScan(String barcode) async {
    if (barcode == null || barcode.isEmpty || !barcode.contains('wedding_code'))
      return;

    qrController?.pauseCamera();

    Guest guest;
    try {
      final qrResult = json.decode(barcode);

      if (qrResult != null && qrResult.containsKey('wedding_code')) {
        final qrWeddingCode = qrResult['wedding_code'];
        final currentWedding = ApplicationStateProvider.of(context).wedding;

        if (currentWedding != null && currentWedding.code == qrWeddingCode)
          guest = await Service.scanQR(qrResult);
      }
    } catch (_) {}

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GuestVerified(
          guest: guest,
        ),
      ),
    );

    qrController?.resumeCamera();
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          color: HummingbirdColor.black,
        ),
        child: Center(
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overScroll) {
              overScroll.disallowGlow();
              return;
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(
                vertical: 50.0,
                horizontal: 25.0,
              ),
              children: <Widget>[
                Text(
                  'Menu',
                  style: TextStyle(
                    color: HummingbirdColor.orange,
                    fontWeight: FontWeight.w400,
                    fontSize: 25.0,
                  ),
                ),
                Padding(padding: const EdgeInsets.only(bottom: 12.0)),
                ..._menuItems.map(_buildMenuItem).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(MenuItem item) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        item.onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 20.0,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: HummingbirdColor.grey,
              width: .5,
            ),
          ),
        ),
        child: Text(
          item.label,
          style: TextStyle(
            color: HummingbirdColor.white,
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }

  final double _featureImageSize = 40.0;

  Widget _buildUserHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 35.0),
      child: Row(
        children: <Widget>[
          Expanded(
              child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PhotoViewer(
                          photos: [widget.wedding.featureImage],
                          heroKey: widget.wedding.heroKey,
                        ),
                      ),
                    );
                  },
                  child: Hero(
                    tag: widget.wedding.heroKey,
                    child: Container(
                      height: _featureImageSize,
                      width: _featureImageSize,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.0),
                        color: HummingbirdColor.white,
                        image: DecorationImage(
                          image: widget.wedding.featureImage.provider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  widget.wedding.featureTitle,
                  style: TextStyle(
                    color: HummingbirdColor.white,
                    fontSize: 18.0,
                  ),
                ),
              ),
            ],
          )),
          IconButton(
            icon: Icon(
              Icons.menu,
            ),
            color: HummingbirdColor.lightGrey,
            onPressed: _openEndDrawer,
          ),
        ],
      ),
    );
  }

  Future<bool> _handleBackButton() async {
    if (_scaffoldKey.currentState.isEndDrawerOpen) {
      Navigator.of(context).pop();
      return false;
    }

    final result = await showDialog(
        context: context,
        builder: (_) => AlertDialog(
              content: Text('Want to exit?'),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('No'),
                ),
                FlatButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Yes'),
                ),
              ],
            ));

    return result == null ? false : result;
  }

  List<Widget> _buildTitle() {
    return [
      Text(
        'Guest Checker',
        style: TextStyle(
          color: HummingbirdColor.orange,
          fontWeight: FontWeight.w400,
          fontSize: 25.0,
        ),
      ),
      Text(
        'Scan QR tamu di sini.',
        style: TextStyle(
          fontSize: 14.0,
        ),
      ),
    ];
  }
}

class MenuItem {
  final String label;
  final GestureTapCallback onTap;

  MenuItem({
    this.label,
    this.onTap,
  });
}

import 'package:flutter/material.dart';
import 'package:hummingbird_guest_apps/app/models/Guest.dart';
import 'package:hummingbird_guest_apps/app/ui-items/HummingbirdColor.dart';

class GuestVerified extends StatelessWidget {
  final Guest guest;

  const GuestVerified({
    Key key,
    this.guest,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor:
            guest == null ? Color(0xFFF2F2F2) : HummingbirdColor.black,
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overScroll) {
            overScroll.disallowGlow();
            return;
          },
          child: DefaultTextStyle(
            style: TextStyle(
              color: HummingbirdColor.white,
            ),
            textAlign: TextAlign.center,
            child: Center(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                shrinkWrap: true,
                children: <Widget>[
                  if (guest == null) ..._build404(),
                  if (guest != null) ..._buildGuestVerifiedItem(),
                  _buildButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FlatButton(
          color: HummingbirdColor.grey,
          padding: const EdgeInsets.symmetric(
            horizontal: 40.0,
            vertical: 15.0,
          ),
          onPressed: () => Navigator.of(context).pop(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: Text(
            guest == null ? 'Kembali' : 'Done',
            style: TextStyle(color: HummingbirdColor.white, fontSize: 16.0),
          ),
        ),
      ],
    );
  }

  Widget _buildResultItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
          Padding(padding: const EdgeInsets.only(bottom: 8.0)),
          Row(
            children: [
              Expanded(
                child: Container(
                  color: HummingbirdColor.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 18.0,
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      color: HummingbirdColor.grey,
                      fontSize: 16.0,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGuestVerifiedItem() {
    return [
      Padding(
        padding: const EdgeInsets.only(bottom: 35.0),
        child: Icon(
          const IconData(
            0xe801,
            fontFamily: 'HummingbirdIcon',
          ),
          color: HummingbirdColor.orange,
          size: 100.0,
        ),
      ),
      Text(
        'Guest Verified',
        style: TextStyle(
          color: HummingbirdColor.orange,
          fontSize: 25.0,
          fontWeight: FontWeight.w400,
        ),
      ),
      Padding(padding: const EdgeInsets.only(bottom: 5.0)),
      Text(
        'Tamu terdaftar di undangan.',
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w300,
        ),
      ),
      Padding(padding: const EdgeInsets.symmetric(vertical: 35.0)),
      _buildResultItem('Nama Lengkap', guest.name),
      _buildResultItem('Kategori', guest.category?.name ?? '-'),
      _buildResultItem('Deskripsi', guest.description),
      Padding(padding: const EdgeInsets.only(bottom: 25.0)),
    ];
  }

  List<Widget> _build404() {
    return [
      Image.asset('assets/images/404.png'),
      Text(
        'Guest Not Found',
        style: TextStyle(
          color: HummingbirdColor.lightGrey,
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 150.0),
      ),
    ];
  }
}

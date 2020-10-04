import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hummingbird_guest_apps/app/models/Wedding.dart';
import 'package:hummingbird_guest_apps/app/models/WeddingStatistic.dart';
import 'package:hummingbird_guest_apps/app/pages/GuestList.dart';
import 'package:hummingbird_guest_apps/app/pages/PhotoViewer.dart';
import 'package:hummingbird_guest_apps/app/services/Service.dart';
import 'package:hummingbird_guest_apps/app/ui-items/HummingbirdAppBar.dart';
import 'package:hummingbird_guest_apps/app/ui-items/HummingbirdColor.dart';

class InvitationDetail extends StatefulWidget {
  final Wedding wedding;

  const InvitationDetail({
    Key key,
    this.wedding,
  }) : super(key: key);

  @override
  _InvitationDetailState createState() => _InvitationDetailState();
}

class _InvitationDetailState extends State<InvitationDetail> {
  Future<WeddingStatistic> _statistic;

  @override
  void initState() {
    _statistic = Service.getStatistic(widget.wedding);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: HummingbirdAppBar(context, 'Detail Undangan'),
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overScroll) {
            overScroll.disallowGlow();
            return;
          },
          child: DefaultTextStyle.merge(
            style: TextStyle(
              fontFamily: 'Raleway',
              color: HummingbirdColor.white,
            ),
            textAlign: TextAlign.center,
            child: Center(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                shrinkWrap: true,
                children: <Widget>[
                  ..._buildBridegroomHeader(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 25.0),
                  ),
                  Center(
                    child: FutureBuilder<WeddingStatistic>(
                      future: _statistic,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) Text('Failed to load data.');

                        if (snapshot.hasData) {
                          var _list = <BridegroomDetailItem>[];

                          final statistic = snapshot.data;

                          _list = <BridegroomDetailItem>[
                            BridegroomDetailItem(
                              'Total Tamu',
                              '${statistic.allGuests}',
                              page: GuestList(wedding: widget.wedding),
                            ),
                            BridegroomDetailItem(
                              'Total Tamu Datang',
                              '${statistic.scannedGuests}',
                              page: GuestList(wedding: widget.wedding),
                            ),
                            BridegroomDetailItem(
                              'Total Tamu Belum Datang',
                              '${statistic.notYetPresentGuests}',
                              page: GuestList(wedding: widget.wedding),
                            ),
                          ];

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _list
                                .map((item) => Row(
                                      children: [
                                        Expanded(
                                          child: _buildBridegroomDetail(item),
                                        ),
                                      ],
                                    ))
                                .toList(),
                          );
                        }

                        return CircularProgressIndicator();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBridegroomDetail(BridegroomDetailItem item) {
    Widget widget = Container(
      padding: const EdgeInsets.symmetric(
        vertical: 25.0,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: .5,
            color: HummingbirdColor.grey,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            item.title,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          Padding(padding: const EdgeInsets.only(bottom: 5.0)),
          Text(
            '${item.description ?? '0'} orang',
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );

    if (item.page != null)
      widget = GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => item.page,
          ),
        ),
        child: widget,
      );

    return widget;
  }

  final double _featureImageSize = 120.0;

  List<Widget> _buildBridegroomHeader() {
    return <Widget>[
      GestureDetector(
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: widget.wedding.heroKey,
              child: Container(
                width: _featureImageSize,
                height: _featureImageSize,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: widget.wedding.featureImage.provider,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(60.0)),
                  color: Colors.redAccent,
                ),
              ),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
        ),
      ),
      Text(
        widget.wedding.featureTitle,
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.w700,
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
      ),
      SelectableText(
        widget.wedding.code,
        style: TextStyle(
          fontSize: 16.0,
        ),
      ),
    ];
  }
}

class BridegroomDetailItem {
  final String title;
  final String description;
  final Widget page;

  BridegroomDetailItem(
    this.title,
    this.description, {
    this.page,
  });
}

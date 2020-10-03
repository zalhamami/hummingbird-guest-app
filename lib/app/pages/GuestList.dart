import 'package:flutter/material.dart';
import 'package:hummingbird_guest_apps/app/exceptions/GeneralException.dart';
import 'package:hummingbird_guest_apps/app/helper/service/Filter.dart';
import 'package:hummingbird_guest_apps/app/helper/service/GeneralResponse.dart';
import 'package:hummingbird_guest_apps/app/models/Category.dart';
import 'package:hummingbird_guest_apps/app/models/Guest.dart';
import 'package:hummingbird_guest_apps/app/models/Wedding.dart';
import 'package:hummingbird_guest_apps/app/services/Service.dart';
import 'package:hummingbird_guest_apps/app/ui-items/HummingbirdColor.dart';
import 'package:pagination/pagination.dart';

class GuestList extends StatefulWidget {
  final Wedding wedding;
  final Filter filter;

  const GuestList({
    Key key,
    this.wedding,
    this.filter,
  }) : super(key: key);

  @override
  _GuestListState createState() => _GuestListState();
}

class _GuestListState extends State<GuestList> {
  final _filterCategoryIdKey = 'category_id';
  final _filterNameKey = 'name';
  final TextEditingController _searchQueryController = TextEditingController();
  Service _guestService, _categoryService;
  bool _isSearching = false;

  @override
  void initState() {
    _guestService = Service<Guest>(
      key: 'guest.getAllByWedding',
      processItem: (item) => Guest.fromResponse(item),
      weddingCode: widget.wedding.code,
    );

    _categoryService = Service<Category>(
      key: 'guestCategory.getAllByWedding',
      processItem: (item) => Category.fromResponse(item),
      weddingCode: widget.wedding.code,
    );
    super.initState();
  }

  final _loading = Center(
    child: Padding(
      padding: EdgeInsets.all(16.0),
      child: CircularProgressIndicator(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _buildAppBar(),
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overScroll) {
            overScroll.disallowGlow();
            return;
          },
          child: DefaultTextStyle.merge(
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Raleway',
              color: HummingbirdColor.white,
            ),
            child: Center(
              child: Stack(
                children: [
                  _buildGuestList(),
                  _buildFilterButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      centerTitle: true,
      shadowColor: HummingbirdColor.transparent,
      backgroundColor: HummingbirdColor.black,
      leading: _buildBackButton(),
      title: _isSearching ? _buildSearchField() : _buildTitle(),
      actions: _buildActions(),
    );
  }

  Widget _buildTitle() {
    var _title = 'Daftar Tamu';

    if (widget.filter != null && widget.filter.queryContainKey(_filterNameKey))
      _title = widget.filter.getQuery(_filterNameKey);

    return Text(
      _title,
      style: TextStyle(
        color: HummingbirdColor.orange,
        fontSize: 20.0,
      ),
    );
  }

  Widget _buildBackButton() {
    return IconButton(
      icon: Icon(
        Icons.keyboard_arrow_left,
        color: HummingbirdColor.white,
        size: 32.0,
      ),
      onPressed: () {
        if (_isSearching)
          setState(() => _isSearching = !_isSearching);
        else
          Navigator.of(context).pop();
      },
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchQueryController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: "Ketik nama tamu",
        border: InputBorder.none,
        hintStyle: TextStyle(
          color: Colors.white30,
          fontSize: 18.0,
        ),
      ),
      style: TextStyle(
        color: HummingbirdColor.white,
        fontSize: 16.0,
      ),
      onSubmitted: (query) => updateSearchQuery(query),
    );
  }

  List<Widget> _buildActions() {
    if (_isSearching)
      return <Widget>[
        IconButton(
          onPressed: () => setState(() => _searchQueryController.clear()),
          icon: const Icon(
            Icons.clear,
            color: HummingbirdColor.white,
            size: 28.0,
          ),
        ),
      ];

    return <Widget>[
      IconButton(
        onPressed: () => setState(() => _isSearching = true),
        icon: Icon(
          Icons.search,
          color: HummingbirdColor.white,
          size: 28.0,
        ),
      )
    ];
  }

  Widget _buildGuestList() {
    return _buildPaginationList<Guest>(
      service: _guestService,
      itemBuilder: _buildGuestItem,
      filter: widget.filter,
    );
  }

  Widget _buildFilterButton() {
    return Positioned(
      bottom: 0.0,
      left: 0.0,
      right: 0.0,
      child: GestureDetector(
        onTap: _onFilterPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 15.0,
          ),
          margin: const EdgeInsets.symmetric(
            horizontal: 120.0,
            vertical: 50.0,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0),
            color: HummingbirdColor.grey,
          ),
          child: Text(
            'Filter',
            style: TextStyle(fontSize: 16.0),
          ),
        ),
      ),
    );
  }

  void updateSearchQuery(String newQuery) {
    if (newQuery == null || newQuery.isEmpty) {
      _isSearching = false;
      return;
    }

    final _filter = (widget.filter ?? Filter()).addFilter(
      _filterNameKey,
      newQuery,
    );

    _doFilter(_filter);
  }

  Widget _buildGuestItem(Guest guest) {
    final backgroundColor =
        guest.scanStatus ? HummingbirdColor.orange : HummingbirdColor.grey;

    final String present = guest.scanStatus ? 'Hadir' : 'Belum Hadir';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 25.0,
        vertical: 15.0,
      ),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guest.name,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: HummingbirdColor.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (guest.category?.name != null &&
                    guest.category.name.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Text(
                      guest.category.name,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Text(
              present,
              style: TextStyle(fontSize: 12.0),
            ),
          ),
        ],
      ),
    );
  }

  void _onFilterPressed() {
    showModalBottomSheet(
      context: context,
      backgroundColor: HummingbirdColor.black,
      clipBehavior: Clip.hardEdge,
      builder: (_) => DefaultTextStyle.merge(
        style: TextStyle(
          fontFamily: 'Raleway',
          color: HummingbirdColor.white,
        ),
        child: _buildCategoryList(),
      ),
    );
  }

  Widget _buildCategoryList() {
    return _buildPaginationList<Category>(
      service: _categoryService,
      itemBuilder: _buildCategoryItem,
    );
  }

  Widget _buildCategoryItem(Category category) {
    return GestureDetector(
      onTap: () {
        if (widget.filter != null &&
            widget.filter.queryContainKey(_filterCategoryIdKey) &&
            widget.filter.getQuery(_filterCategoryIdKey) == '${category.id}')
          Navigator.of(context).pop();
        else
          _onCategoryPressed(category);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
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
        child: Row(
          children: [
            Container(
              width: 30.0,
              height: 30.0,
              margin: const EdgeInsets.only(right: 8.0),
              child: widget.filter != null &&
                      widget.filter.queryContainKey(_filterCategoryIdKey) &&
                      widget.filter.getQuery(_filterCategoryIdKey) ==
                          '${category.id}'
                  ? Icon(
                      Icons.check_circle_outline,
                      color: HummingbirdColor.orange,
                      size: 20.0,
                    )
                  : Container(),
            ),
            Expanded(
              child: Text(
                '${category.name}',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onCategoryPressed(Category category) {
    final _filter = (widget.filter ?? Filter()).addFilter(
      _filterCategoryIdKey,
      '${category.id}',
    );

    Navigator.of(context).pop();
    _doFilter(_filter);
  }

  void _doFilter(Filter filter) {
    final _pageRoute = MaterialPageRoute(
      builder: (_) => GuestList(
        wedding: widget.wedding,
        filter: filter,
      ),
    );

    if (widget.filter != null)
      Navigator.of(context).pushReplacement(_pageRoute);
    else
      Navigator.of(context).push(_pageRoute);
  }

  Widget _buildPaginationList<T>({
    Widget Function(T) itemBuilder,
    Service<T> service,
    Filter filter,
  }) {
    return PaginationList<T>(
      onLoading: _loading,
      onPageLoading: _loading,
      itemBuilder: (context, data) => itemBuilder(data),
      onEmpty: Center(child: Text('Empty ${T.toString()}')),
      onError: (error) {
        var errorMessage = '';

        if (error is GeneralException)
          errorMessage = error.message;
        else
          errorMessage = error;

        return Center(
          child: Text('$errorMessage'),
        );
      },
      pageFetch: (int currentListSize) async {
        final _result = await service.getAll(
          generalResponse: GeneralResponse<T>(
            currentPage: currentListSize,
            filter: filter,
          ),
        );

        return _result.items;
      },
    );
  }
}

class GuestListItem {
  final String name, description;
  final VoidCallback onTap;
  bool present;

  GuestListItem({
    this.name,
    this.description,
    this.onTap,
    this.present,
  });
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'Api_Model/Restaurent/User_restaurent.dart';

class DynamicAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? rightButtonLabel;
  final VoidCallback? onRightButtonPressed;
  final Function(bool)? onStatusChanged;
  final bool showRightButton;

  const DynamicAppBar({
    Key? key,
    this.rightButtonLabel,
    this.onRightButtonPressed,
    this.onStatusChanged,
    this.showRightButton = true,
  }) : super(key: key);

  @override
  State<DynamicAppBar> createState() => _DynamicAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(70);
}

class _DynamicAppBarState extends State<DynamicAppBar> {
  bool _isOpen = false;
  bool _isFirstLoad = true;
  bool _isUpdating = false;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchStatusFromUrl();
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      _fetchStatusFromUrl(background: true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchStatusFromUrl({bool background = false}) async {
    if (!background && mounted) {
      setState(() => _isFirstLoad = true);
    }

    try {
      final sp = await SharedPreferences.getInstance();
      final authToken = sp.getString('auth_token');

      if (authToken == null) return;

      final response = await http.get(
        Uri.parse('https://waitinglist.rektech.work/api/restaurants/my-restaurant'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final restaurantModel = CreateRestaurant.fromJson(jsonData);
        bool serverIsOpen = restaurantModel.data.operationalStatus == 1;

        if (mounted) {
          if (_isFirstLoad || serverIsOpen != _isOpen) {
            setState(() {
              _isOpen = serverIsOpen;
              _isFirstLoad = false;
            });
            widget.onStatusChanged?.call(_isOpen);
          }
        }
      }
    } catch (e) {
      // print("Error fetching status: $e");
      if (mounted && !background) setState(() => _isFirstLoad = false);
    }
  }

  Future<void> _updateStatusOnUrl(int newStatus) async {
    setState(() => _isUpdating = true);

    try {
      final sp = await SharedPreferences.getInstance();
      final authToken = sp.getString('auth_token');

      if (authToken == null) return;

      final response = await http.post(
        Uri.parse('https://waitinglist.rektech.work/api/restaurants/my-restaurant/toggle-status'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'operational_status': newStatus}),
      );

      if (response.statusCode == 200) {
        await _fetchStatusFromUrl(background: true);
        if (mounted) {
          setState(() => _isUpdating = false);
        }
      } else {
        if (mounted) setState(() => _isUpdating = false);
      }
    } catch (e) {
      // print("Error updating status: $e");
      if (mounted) setState(() => _isUpdating = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      toolbarHeight: 70,
      title: Row(
        children: [
          Image.asset("assets/Images/re2.png", height: 40),
          const Spacer(),
          if (widget.showRightButton)
            _isFirstLoad
                ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isOpen ? Colors.green : Colors.red,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onPressed: _isUpdating ? null : () {
                int newStatus = _isOpen ? 0 : 1;
                _updateStatusOnUrl(newStatus);
              },
              child: _isUpdating
                  ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(
                _isOpen ? "We are Open" : "We are Closed",
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
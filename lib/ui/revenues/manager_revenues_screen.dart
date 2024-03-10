import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../shared/app_drawer.dart';

class ManagerRevenuesScreen extends StatefulWidget {
  static const routeName = '/manager-revenues';

  @override
  _ManagerRevenuesScreenState createState() => _ManagerRevenuesScreenState();
}

class _ManagerRevenuesScreenState extends State<ManagerRevenuesScreen> {
  Map<String, dynamic> _revenueData = {};

  @override
  void initState() {
    super.initState();
    _fetchRevenueData();
  }

  Future<void> _fetchRevenueData() async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:8000/api/revenues/1'));

    if (response.statusCode == 200) {
      setState(() {
        _revenueData =
            json.decode(response.body); // Chuyển dữ liệu từ JSON sang Map
      });
    } else {
      setState(() {
        _revenueData = {'error': 'Không thể lấy dữ liệu'};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QL Doanh Thu'),
      ),
      drawer: const AppDrawer(),
      body: DefaultTabController(
        length: 2, // Số lượng tab
        child: Column(
          children: [
            Container(
              color: const Color.fromARGB(255, 253, 255, 232),
              child: const TabBar(
                tabs: [
                  Tab(text: 'Thông tin & DTCN'),
                  Tab(text: 'Doanh thu của NV'),
                ],
                indicatorColor: Colors.blue,
                labelColor: Colors.blue,
                labelStyle: TextStyle(fontSize: 18),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildPersonalInfoTab(),
                  _buildStaffRevenueTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoTab() {
    if (_revenueData['user'] != null) {
      return Padding(
        padding: const EdgeInsets.all(8.0), // Điều chỉnh khoảng cách ở đây
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text('Họ Tên: ${_revenueData['user']['name'] ?? 'N/A'}',
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  Text('Email: ${_revenueData['user']['email'] ?? 'N/A'}',
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  Text('Vai trò: ${_revenueData['user']['role'] ?? 'N/A'}',
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  Text(
                      'Người quản lý: ${_revenueData['user']['manager_name'] ?? 'N/A'}',
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  Text(
                      'Doanh thu cá nhân: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(_revenueData['personal_revenue'] ?? 0)}',
                      style: const TextStyle(fontSize: 18)),
                ],
              ),
            ),
            // _buildPieChart(),
          ],
        ),
      );
    } else {
      return const Center(
        child: Text('Không có dữ liệu người dùng'),
      );
    }
  }

  Widget _buildStaffRevenueTab() {
    if (_revenueData['staffs'] != null) {
      final List<dynamic> staffs = _revenueData['staffs'];
      return ListView.builder(
        itemCount:
            staffs.length + 1, // +1 để bao gồm thông tin về người quản lý
        itemBuilder: (context, index) {
          if (index == 0) {
            // Thông tin về người quản lý
            return ListTile(
              title: Text(
                  'Doanh thu Quản lý: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(_revenueData['manager_revenue'])}',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            );
          }
          final staff = staffs[index - 1];
          String totalSalesText = 'N/A';
          if (staff['total_sales'] != null) {
            totalSalesText = NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                .format(staff['total_sales']);
          }
          return ListTile(
            title: Text('Họ Tên: ${staff['name'] ?? 'N/A'}',
                style: const TextStyle(fontSize: 18)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Vai trò: ${staff['role'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 14)),
                Text('Người quản lý: ${staff['manager_name'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 14)),
              ],
            ),
            trailing:
                Text(totalSalesText, style: const TextStyle(fontSize: 18)),
          );
        },
      );
    } else {
      return const Center(
        child: Text('Không có dữ liệu nhân viên'),
      );
    }
  }
}

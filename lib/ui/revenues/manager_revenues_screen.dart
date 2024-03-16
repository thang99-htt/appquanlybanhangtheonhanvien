import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../auth/auth_manager.dart';

import '../shared/app_drawer.dart';

class ManagerRevenuesScreen extends StatefulWidget {
  static const routeName = '/manager-revenues';

  const ManagerRevenuesScreen({Key? key}) : super(key: key);

  @override
  _ManagerRevenuesScreenState createState() => _ManagerRevenuesScreenState();
}

class _ManagerRevenuesScreenState extends State<ManagerRevenuesScreen> {
  Map<String, dynamic> _revenueData = {};

  @override
  void initState() {
    super.initState();
    _fetchRevenueData(context);
  }

  Future<void> _fetchRevenueData(BuildContext context) async {
    final userId =
        Provider.of<AuthManager>(context, listen: false).authToken?.userId;
    final response =
        await http.get(Uri.parse('http://10.0.2.2:8000/api/revenues/$userId'));

    if (response.statusCode == 200) {
      setState(() {
        _revenueData = json.decode(response.body);
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
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'QL Doanh Thu',
          style: TextStyle(color: Colors.white),
        ),
      ),
      drawer: const AppDrawer(),
      body: DefaultTabController(
        length: 2,
        child: Scaffold(
          body: TabBarView(
            children: [
              _buildPersonalInfoTab(),
              _buildStaffRevenueTab(),
            ],
          ),
          bottomNavigationBar: Container(
            color: Colors.blue, // Màu nền cho TabBar
            child: const Padding(
              padding: EdgeInsets.only(bottom: 0),
              child: TabBar(
                tabs: [
                  Tab(text: 'Thông tin & DTCN'),
                  Tab(text: 'Doanh thu Quản lý'),
                ],
                indicatorColor: Colors.white, // Màu của đường chỉ báo
                labelColor: Colors.white, // Màu chữ khi được chọn
                labelStyle: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoTab() {
    if (_revenueData['user'] != null) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text('Họ Tên: ${_revenueData['user']['name'] ?? ''}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Email: ${_revenueData['user']['email'] ?? ''}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Vai trò: ${_revenueData['user']['role'] ?? ''}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Người quản lý: ${_revenueData['user']['manager_name'] ?? ''}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text(
                'Doanh thu cá nhân: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(_revenueData['personal_revenue'])}',
                style: const TextStyle(fontSize: 18)),
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
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _revenueData['staffs'] != null
                ? _buildPieChart()
                : const SizedBox(), // Sử dụng biểu thức điều kiện để kiểm tra xem _revenueData['staffs'] có dữ liệu và personal_revenue có là true hay không
          ),
          Expanded(
            child: ListView.builder(
              itemCount: staffs.length,
              itemBuilder: (context, index) {
                final staff = staffs[index];
                return Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 5, horizontal: 2), // Margin cho mỗi item
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color.fromARGB(
                            255, 216, 216, 216)), // Border cho mỗi item
                    borderRadius: BorderRadius.circular(8), // Bo góc border
                  ),
                  child: ListTile(
                    title: Text(
                      '${staff['name'] ?? ''}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vai trò: ${staff['role'] ?? ''}',
                          style: const TextStyle(fontSize: 15),
                        ),
                        Text(
                          'Người quản lý: ${staff['manager_name'] ?? ''}',
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                    trailing: Text(
                      staff['total_sales'] != null
                          ? NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                              .format(staff['total_sales'])
                          : '0đ',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    } else {
      return const Center(
        child: Text('Không có dữ liệu nhân viên'),
      );
    }
  }

  Widget _buildPieChart() {
    if (_revenueData['staffs'] != null) {
      final List<dynamic> staffs = _revenueData['staffs'];

      // Tạo danh sách các màu cho từng nhân viên
      List<Color> colors = [
        Colors.green,
        Colors.yellow,
        Colors.orange,
        Colors.blue,
        Colors.red,
        Colors.purple,
        Colors.teal,
        Colors.indigo,
        Colors.pink,
        Colors.cyan
      ];

      // Tạo danh sách dữ liệu cho biểu đồ
      List<PieChartSectionData> pieChartData = [];

      // Tính tổng doanh số
      double totalRevenue = 0;
      for (var staff in staffs) {
        totalRevenue += (staff['total_sales'] ?? 0).toDouble();
      }

      // Kiểm tra nếu tổng doanh số là 0
      if (totalRevenue == 0) {
        return const Center(
          child: Text('Không có dữ liệu doanh thu'),
        );
      }

      // Biến để kiểm tra xem có phần trăm nào bằng 0 hay không
      bool hasNonZeroPercentage = false;

      // Lặp qua các nhân viên và thêm dữ liệu vào biểu đồ
      for (int i = 0; i < staffs.length && i < 10; i++) {
        final staff = staffs[i];
        final String staffName = staff['name'];
        final double totalSales = (staff['total_sales'] ?? 0).toDouble();

        // Tính phần trăm doanh số bán của mỗi nhân viên so với tổng doanh số
        double percentage = totalSales / totalRevenue;

        // Kiểm tra xem phần trăm có khác 0 không
        if (percentage != 0) {
          hasNonZeroPercentage =
              true; // Đặt biến hasNonZeroPercentage thành true
          pieChartData.add(
            PieChartSectionData(
              color: colors[i],
              value: percentage * 100, // Chuyển đổi sang phần trăm
              title: ' $staffName',
              radius: 75,
              titleStyle: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          );
        }
      }

      // Kiểm tra xem có phần trăm nào khác 0 không
      if (!hasNonZeroPercentage) {
        return const Center(
          child: Text('Tất cả các nhân viên đều không có doanh số'),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Doanh thu Quản lý: ${_revenueData['manager_revenue'] != null ? NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(_revenueData['manager_revenue']) : '0đ'}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Top nhân viên doanh thu cao nhất',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 165,
            child: PieChart(
              PieChartData(
                sections: pieChartData,
                centerSpaceRadius: 0,
                borderData: FlBorderData(show: false),
                sectionsSpace: 0,
                startDegreeOffset: 0,
              ),
            ),
          ),
        ],
      );
    } else {
      return const Center(
        child: Text('Không có dữ liệu nhân viên'),
      );
    }
  }
}

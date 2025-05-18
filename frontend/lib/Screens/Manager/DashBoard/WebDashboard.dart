// lib/Screens/Manager/WebDashboard.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Service/user_service.dart';
import '../../../Service/order_service.dart';
import '../../../Service/product_service.dart';
import '../../../models/Order.dart';
import '../../../models/User.dart';
import '../../../models/Category.dart';

enum IntervalType { yearly, quarterly, monthly, weekly, custom }

class WebDashboard extends StatefulWidget {
  const WebDashboard({Key? key}) : super(key: key);

  @override
  State<WebDashboard> createState() => _WebDashboardState();
}
class _WebDashboardState extends State<WebDashboard>
    with SingleTickerProviderStateMixin {
  bool _isAdmin = false;
  int _selectedDrawerIndex = 0;

  // dữ liệu
  List<User> _allUsers = [];
  List<Order> _allOrders = [];
  Map<String, String> _productCategory = {};

  // stats
  int _userCount = 0;
  int _newUserCount = 0;
  int _orderCount = 0;
  double _totalRevenue = 0;

  bool _loading = true;
  String? _error;

  // filter chung cho advanced
  IntervalType _ordersInterval = IntervalType.yearly;
  IntervalType _revenueInterval = IntervalType.yearly;
  IntervalType _regInterval = IntervalType.yearly;
  DateTime? _customStart;
  DateTime? _customEnd;
  late final AnimationController _opacityController;
  late final Animation<double> _opacityAnimation;
  @override
  void initState() {
    super.initState();
    _opacityController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _opacityAnimation = CurvedAnimation(
      parent: _opacityController,
      curve: Curves.easeIn,
    );

    _opacityController.forward();

    _checkAuth();
    _loadStats();
  }

  @override
  void dispose() {
    _opacityController.dispose();
    super.dispose();
  }
  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final role = prefs.getString('role');
    if (token == null || role != 'admin') {
      context.go('/login');
    } else {
      setState(() => _isAdmin = true);
    }
  }

  Future<void> _loadStats() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final users = await UserService().fetchUsers();
      final now = DateTime.now();
      final cutoff = now.subtract(const Duration(days: 30));
      final orders = await OrderService.fetchAllOrders();
      final revenue = orders.fold<double>(0, (sum, o) => sum + (o.totalAmount ?? 0));

      final productIds = orders.expand((o) => o.items.map((i) => i.productId)).toSet().toList();
      final products = await Future.wait(productIds.map((id) => ProductService.getById(id)));
      final categories = await ProductService.fetchAllCategories();
      final lookup = { for (var p in products)
        p.id: categories.firstWhere(
                (c) => c.id == p.categoryId,
            orElse: () => Category(id: p.categoryId, name: 'Unknown', createdAt: now)
        ).name
      };

      setState(() {
        _allUsers = users;
        _userCount = users.length;
        _newUserCount = users.where((u) => u.createdAt.isAfter(cutoff)).length;
        _allOrders = orders;
        _orderCount = orders.length;
        _totalRevenue = revenue;
        _productCategory = lookup;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdmin) return const Scaffold(body: SizedBox.shrink());
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard'), backgroundColor: Colors.deepPurple),
      drawer: _buildDrawer(context),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_error != null
          ? Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Overview ---
            _sectionTitle('Overview'),
            _buildStatCards(),
            const SizedBox(height: 24),
            _buildChartsGrid(),

            // --- Advanced ---
            const Divider(height: 40),
            _sectionTitle('Advanced Filters & Charts'),
            _buildAdvancedCharts(),
            const SizedBox(height: 24),
            // <-- chèn ở đây:
            _buildManagementLinks(context),
          ],
        ),
      )),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.deepPurple),
            child: Text('Admin Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          _drawerItem(context, 'Trang chủ', Icons.dashboard, '/manager/dashboard'),
          _drawerItem(context, 'Quản lý Sản phẩm', Icons.shopping_cart, '/manager/products'),
          _drawerItem(context, 'Quản lý Mã giảm giá', Icons.card_giftcard, '/manager/coupons'),
          _drawerItem(context, 'Quản lý Danh mục', Icons.category, '/manager/categories'),
          _drawerItem(context, 'Quản lý Người dùng', Icons.people, '/manager/users'),
          _drawerItem(context, 'Quản lý Đơn hàng', Icons.receipt, '/manager/orders'),
          _drawerItem(context, 'Hỗ trợ người dùng', Icons.support, '/manager/support'),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Đăng xuất'),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.pop(context); // Đóng drawer
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext context, String title, IconData icon, String? path) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // Đóng drawer
        if (path != null) {
          context.go(path); // Sử dụng GoRouter
        }
      },
    );
  }

  Widget _buildStatCards() {
    final stats = [
      {'title': 'Users', 'value': '$_userCount', 'icon': Icons.people},
      {'title': 'New Users (30d)', 'value': '$_newUserCount', 'icon': Icons.person_add},
      {'title': 'Orders', 'value': '$_orderCount', 'icon': Icons.shopping_cart},
      {'title': 'Revenue', 'value': '₫${_totalRevenue.toStringAsFixed(0)}', 'icon': Icons.attach_money},
    ];
    return LayoutBuilder(builder: (ctx, cons) {
      final itemW = (cons.maxWidth - 48) / 4;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: stats.map((s) {
          return SizedBox(
            width: itemW,
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(s['icon'] as IconData, size: 32, color: Colors.deepPurple),
                    const SizedBox(height: 8),
                    Text(s['title'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(s['value'] as String, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildChartsGrid() {
    final ordersByMonth = _aggOrdersByMonth();
    final revenueByMonth = _aggRevenueByMonth();
    final catShares = _aggCategoryShares();
    final top5Cats = catShares.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return LayoutBuilder(builder: (ctx, cons) {
      final cross = cons.maxWidth > 1200 ? 3 : (cons.maxWidth > 800 ? 2 : 1);
      return GridView.count(
        crossAxisCount: cross,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
        children: [
          _chartCard(
            title: 'Orders (12m)',
            child: LineChart(
              LineChartData(
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (x, _) {
                      final key = ordersByMonth.keys.elementAt(x.toInt().clamp(0, ordersByMonth.length - 1));
                      return Text(key, style: const TextStyle(fontSize: 10));
                    },
                  )),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(ordersByMonth.length,
                            (i) => FlSpot(i.toDouble(), ordersByMonth.values.elementAt(i))),
                    isCurved: true,
                  )
                ],
              ),
            ),
          ),
          _chartCard(
            title: 'Revenue (12m)',
            child: BarChart(
              BarChartData(
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (x, _) {
                      final key = revenueByMonth.keys.elementAt(x.toInt().clamp(0, revenueByMonth.length - 1));
                      return Text(key, style: const TextStyle(fontSize: 10));
                    },
                  )),
                ),
                barGroups: List.generate(revenueByMonth.length, (i) => BarChartGroupData(x: i, barRods: [
                  BarChartRodData(toY: revenueByMonth.values.elementAt(i))
                ])),
              ),
            ),
          ),
          _chartCard(
            title: 'Category Share',
            child: PieChart(PieChartData(
              sections: catShares.entries.map((e) => PieChartSectionData(
                value: e.value.toDouble(),
                title: e.key,
                radius: 40,
                titleStyle: const TextStyle(fontSize: 12),
              )).toList(),
              centerSpaceRadius: 40,
            )),
          ),
          _chartCard(
            title: 'Top 5 Categories',
            child: BarChart(BarChartData(
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (x, _) {
                    final key = top5Cats[x.toInt().clamp(0, top5Cats.length - 1)].key;
                    return Text(key, style: const TextStyle(fontSize: 10));
                  },
                )),
              ),
              barGroups: List.generate(top5Cats.length, (i) => BarChartGroupData(x: i, barRods: [
                BarChartRodData(toY: top5Cats[i].value.toDouble())
              ])),
            )),
          ),
        ],
      );
    });
  }

  Widget _buildAdvancedCharts() {
    return Column(
      children: [
        // Orders over interval
        _filterableChart(
          title: 'Orders over Interval',
          dropdownValue: _ordersInterval,
          onIntervalChanged: (v) {
            if (v != null) setState(() => _ordersInterval = v);
          },
          chart: LineChart(LineChartData(
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (x, _) {
                  final map = _aggByInterval(_ordersInterval, onlyRevenue: false);
                  final key = map.keys.elementAt(x.toInt().clamp(0, map.length - 1));
                  return Text(key, style: const TextStyle(fontSize: 10));
                },
              )),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: List.generate(
                    _aggByInterval(_ordersInterval, onlyRevenue: false).length,
                        (i) => FlSpot(i.toDouble(),
                        _aggByInterval(_ordersInterval, onlyRevenue: false).values.elementAt(i))),
                isCurved: true,
              )
            ],
          )),
        ),
        const SizedBox(height: 16),
        // Revenue vs Profit
        _filterableChart(
          title: 'Revenue vs Profit',
          dropdownValue: _revenueInterval,
          onIntervalChanged: (v) {
            if (v != null) setState(() => _revenueInterval = v);
          },
          chart: BarChart(BarChartData(
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (x, _) {
                  final map = _aggregateRevenueByInterval(_revenueInterval);
                  final key = map.keys.elementAt(x.toInt().clamp(0, map.length - 1));
                  return Text(key, style: const TextStyle(fontSize: 10));
                },
              )),
            ),
            barGroups: List.generate(
              _aggregateRevenueByInterval(_revenueInterval).length,
                  (i) {
                final key = _aggregateRevenueByInterval(_revenueInterval).keys.elementAt(i);
                final rev = _aggregateRevenueByInterval(_revenueInterval)[key]!;
                final prof = rev * 0.2;
                return BarChartGroupData(x: i, barsSpace: 4, barRods: [
                  BarChartRodData(toY: rev, width: 8, color: Colors.blue),
                  BarChartRodData(toY: prof, width: 8, color: Colors.red),
                ]);
              },
            ),
          )),
        ),
        const SizedBox(height: 16),
        // Registrations over interval
        _filterableChart(
          title: 'User Registrations',
          dropdownValue: _regInterval,
          onIntervalChanged: (v) {
            if (v != null) setState(() => _regInterval = v);
          },
          chart: LineChart(LineChartData(
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (x, _) {
                  final map = _aggRegistrationsByInterval(_regInterval);
                  final key = map.keys.elementAt(x.toInt().clamp(0, map.length - 1));
                  return Text(key, style: const TextStyle(fontSize: 10));
                },
              )),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: List.generate(
                    _aggRegistrationsByInterval(_regInterval).length,
                        (i) => FlSpot(i.toDouble(),
                        _aggRegistrationsByInterval(_regInterval).values.elementAt(i))),
                isCurved: true,
              )
            ],
          )),
        ),
      ],
    );
  }

  Widget _filterableChart({
    required String title,
    required IntervalType dropdownValue,
    required ValueChanged<IntervalType?> onIntervalChanged,
    required Widget chart,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const Spacer(),
                DropdownButton<IntervalType>(
                  value: dropdownValue,
                  items: IntervalType.values.map((i) {
                    return DropdownMenuItem(
                      value: i,
                      child: Text(i.toString().split('.').last),
                    );
                  }).toList(),
                  onChanged: onIntervalChanged,
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(height: 200, child: chart),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String txt) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(txt, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  // --- helpers ---

  Map<String, double> _aggOrdersByMonth() {
    final now = DateTime.now();
    final m = <String, double>{};
    for (int i = 11; i >= 0; i--) {
      final dt = DateTime(now.year, now.month - i);
      final key = '${dt.year}-${dt.month.toString().padLeft(2, '0')}';
      m[key] = 0;
    }
    for (var o in _allOrders) {
      final key = '${o.createdAt.year}-${o.createdAt.month.toString().padLeft(2, '0')}';
      if (m.containsKey(key)) m[key] = m[key]! + 1;
    }
    return m;
  }

  Map<String, double> _aggRevenueByMonth() {
    final now = DateTime.now();
    final m = <String, double>{};
    for (int i = 11; i >= 0; i--) {
      final dt = DateTime(now.year, now.month - i);
      final key = '${dt.year}-${dt.month.toString().padLeft(2, '0')}';
      m[key] = 0;
    }
    for (var o in _allOrders) {
      final key = '${o.createdAt.year}-${o.createdAt.month.toString().padLeft(2, '0')}';
      if (m.containsKey(key)) m[key] = m[key]! + (o.totalAmount ?? 0);
    }
    return m;
  }

  Map<String, int> _aggCategoryShares() {
    final cnt = <String, int>{};
    for (var o in _allOrders) {
      for (var i in o.items) {
        final cat = _productCategory[i.productId] ?? 'Unknown';
        cnt[cat] = (cnt[cat] ?? 0) + i.quantity;
      }
    }
    return cnt;
  }

  Map<String, double> _aggRegistrationsByMonth(IntervalType t) {
    final now = DateTime.now();
    final m = <String, double>{};
    for (int i = 11; i >= 0; i--) {
      final dt = DateTime(now.year, now.month - i);
      final key = '${dt.year}-${dt.month.toString().padLeft(2, '0')}';
      m[key] = 0;
    }
    for (var u in _allUsers) {
      final key = '${u.createdAt.year}-${u.createdAt.month.toString().padLeft(2, '0')}';
      if (m.containsKey(key)) m[key] = m[key]! + 1;
    }
    return m;
  }

  Map<String, double> _aggByInterval(IntervalType t, {required bool onlyRevenue}) {
    final out = <String, double>{};
    for (var o in _allOrders) {
      final dt = o.createdAt;
      String key;
      switch (t) {
        case IntervalType.yearly:
          key = '${dt.year}';
          break;
        case IntervalType.quarterly:
          final q = ((dt.month - 1) ~/ 3) + 1;
          key = '${dt.year}-Q$q';
          break;
        case IntervalType.monthly:
          key = '${dt.year}-${dt.month.toString().padLeft(2, '0')}';
          break;
        case IntervalType.weekly:
          final w = ((dt.day - 1) ~/ 7) + 1;
          key = '${dt.year}-W$w';
          break;
        case IntervalType.custom:
          key = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
          break;
      }
      final value = onlyRevenue ? (o.totalAmount ?? 0) : 1;
      out[key] = (out[key] ?? 0) + value;
    }
    return out;
  }

  Map<String, double> _aggregateRevenueByInterval(IntervalType t) {
    final map = _aggByInterval(t, onlyRevenue: true);
    return map;
  }
  Widget _chartCard({required String title, required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize:16,fontWeight:FontWeight.w600)),
            const SizedBox(height:8),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
  /// Gộp số lượt đăng ký user theo interval (yearly, quarterly, monthly, weekly, custom)
  Map<String, double> _aggRegistrationsByInterval(IntervalType t) {
    final now = DateTime.now();
    final out = <String, double>{};
    // Khởi tạo keys cho 12 tháng (nếu muốn last 12) hoặc theo interval
    if (t == IntervalType.monthly) {
      for (int i = 11; i >= 0; i--) {
        final dt = DateTime(now.year, now.month - i);
        final key = '${dt.year}-${dt.month.toString().padLeft(2, '0')}';
        out[key] = 0;
      }
    }
    // Với các interval khác, bạn có thể khởi tạo tương tự hoặc để out rỗng và nó tự sinh keys khi gặp
    for (var u in _allUsers) {
      final dt = u.createdAt;
      String key;
      switch (t) {
        case IntervalType.yearly:
          key = '${dt.year}'; break;
        case IntervalType.quarterly:
          final q = ((dt.month - 1) ~/ 3) + 1;
          key = '${dt.year}-Q$q'; break;
        case IntervalType.monthly:
          key = '${dt.year}-${dt.month.toString().padLeft(2, '0')}'; break;
        case IntervalType.weekly:
          final w = ((dt.day - 1) ~/ 7) + 1;
          key = '${dt.year}-W$w'; break;
        case IntervalType.custom:
          key = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}'; break;
      }
      out[key] = (out[key] ?? 0) + 1;
    }
    return out;
  }

  Widget _buildManagementLinks(BuildContext context) {
    List<Map<String, dynamic>> managements = [
      {"title": "Quản lý Sản phẩm", "path": "/manager/products"},
      {"title": "Quản lý Mã giảm giá", "path": "/manager/coupons"},
      {"title": "Quản lý Danh mục", "path": "/manager/categories"},
      {"title": "Quản lý Người dùng", "path": "/manager/users"},
      {"title": "Quản lý Đơn hàng", "path": "/manager/orders"},
      {"title": "Hỗ trợ người dùng", "path": "/manager/support"},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Lối tắt", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...managements.map((item) {
          return AnimatedBuilder(
            animation: _opacityAnimation,
            builder: (context, _) => Opacity(
              opacity: _opacityAnimation.value,
              child: Card(
                child: ListTile(
                  title: Text(item["title"]),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    context.go(item["path"]); // Sử dụng GoRouter
                  },
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}



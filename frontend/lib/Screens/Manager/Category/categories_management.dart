import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import '../../../widgets/Footer/mobile_navigation_bar.dart';
import 'package:danentang/models/Category.dart' as model;
import 'package:danentang/Service/product_service.dart';

class CategoriesManagement extends StatelessWidget {
  const CategoriesManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveCategoriesScreen();
  }
}

class ResponsiveCategoriesScreen extends StatefulWidget {
  const ResponsiveCategoriesScreen({super.key});

  @override
  State<ResponsiveCategoriesScreen> createState() => _ResponsiveCategoriesScreenState();
}

class _ResponsiveCategoriesScreenState extends State<ResponsiveCategoriesScreen> {
  late Future<List<model.Category>> _futureCategories;

  @override
  void initState() {
    super.initState();
    _futureCategories = ProductService.fetchAllCategories();
  }

  void _refresh() {
    final future = ProductService.fetchAllCategories(); // tạo trước
    setState(() {
      _futureCategories = future; // gán trong setState một cách đồng bộ
    });
  }


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return PageTransitionSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation, secondaryAnimation) => FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          ),
          child: isMobile
              ? MobileCategoriesScreen(
            key: const ValueKey("Di động"),
            categoriesFuture: _futureCategories,
            onRefresh: _refresh,
          )
              : WebCategoriesScreen(
            key: const ValueKey("Website"),
            categoriesFuture: _futureCategories,
            onRefresh: _refresh,
          ),
        );
      },
    );
  }
}

class MobileCategoriesScreen extends StatefulWidget {
  final Future<List<model.Category>> categoriesFuture;
  final VoidCallback onRefresh;
  const MobileCategoriesScreen({super.key, required this.categoriesFuture, required this.onRefresh});

  @override
  State<MobileCategoriesScreen> createState() => _MobileCategoriesScreenState();
}

class _MobileCategoriesScreenState extends State<MobileCategoriesScreen> {
  int _selectedIndex = 0;
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  void _createCategory() async {
    final name = _nameCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    if (name.isEmpty) return;
    final success = await ProductService.createCategory(model.Category(
      name: name,
      description: desc,
      createdAt: DateTime.now(),
    ));
    if (success != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tạo thành công')));
      _nameCtrl.clear();
      _descCtrl.clear();
      widget.onRefresh();
    }
  }

  void _editCategory(model.Category cat) async {
    final nameCtrl = TextEditingController(text: cat.name);
    final descCtrl = TextEditingController(text: cat.description ?? "");

    final updated = await showDialog<model.Category>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sửa danh mục'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên')),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Mô tả')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              final updatedCat = model.Category(
                id: cat.id,
                name: nameCtrl.text.trim(),
                description: descCtrl.text.trim(),
                createdAt: cat.createdAt,
              );
              Navigator.pop(context, updatedCat);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );

    if (updated != null) {
      await ProductService.updateCategory(updated.id!, updated); // ✅ đúng
      widget.onRefresh();
    }

  }

  void _deleteCategory(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc muốn xóa danh mục này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa')),
        ],
      ),
    );
    if (confirmed != true) return;
    final ok = await ProductService.deleteCategory(id);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa danh mục.')));
      widget.onRefresh();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể xóa danh mục.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text("Quản lý danh mục", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => widget.onRefresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                FutureBuilder<List<model.Category>>(
                  future: widget.categoriesFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const CircularProgressIndicator();
                    return Column(
                      children: snapshot.data!
                          .map((cat) => ListTile(
                        title: Text(cat.name),
                        subtitle: Text(cat.description ?? ""),
                        trailing: Wrap(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editCategory(cat),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteCategory(cat.id!),
                            ),
                          ],
                        ),
                      ))
                          .toList(),
                    );
                  },
                ),
                const Divider(height: 32),
                const Text("Thêm danh mục mới", style: TextStyle(fontWeight: FontWeight.bold)),
                TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Tên danh mục')),
                const SizedBox(height: 8),
                TextField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Mô tả')),
                const SizedBox(height: 8),
                ElevatedButton(onPressed: _createCategory, child: const Text("Tạo danh mục")),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: MobileNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        isLoggedIn: true,
        role: 'manager',
      ),
    );
  }
}

class WebCategoriesScreen extends StatelessWidget {
  final Future<List<model.Category>> categoriesFuture;
  final VoidCallback onRefresh;

  const WebCategoriesScreen({super.key, required this.categoriesFuture, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final _nameCtrl = TextEditingController();
    final _descCtrl = TextEditingController();

    void _createCategory() async {
      final name = _nameCtrl.text.trim();
      final desc = _descCtrl.text.trim();
      if (name.isEmpty) return;
      final success = await ProductService.createCategory(model.Category(
        name: name,
        description: desc,
        createdAt: DateTime.now(),
      ));
      if (success != null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tạo thành công')));
        _nameCtrl.clear();
        _descCtrl.clear();
        onRefresh();
      }
    }

    void _deleteCategory(String id) async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Xác nhận'),
          content: const Text('Bạn có chắc muốn xóa danh mục này không?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa')),
          ],
        ),
      );
      if (confirmed != true) return;
      final ok = await ProductService.deleteCategory(id);
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa danh mục.')));
        onRefresh();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể xóa danh mục.')));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý Danh mục", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: Row(
        children: [
          // Danh sách danh mục
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey[100],
              child: FutureBuilder<List<model.Category>>(
                future: categoriesFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: snapshot.data!
                        .map((cat) => ListTile(
                      title: Text(cat.name),
                      subtitle: Text(cat.description ?? ''),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              final nameCtrl = TextEditingController(text: cat.name);
                              final descCtrl = TextEditingController(text: cat.description ?? '');
                              final edited = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Sửa danh mục'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên')),
                                      const SizedBox(height: 8),
                                      TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Mô tả')),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
                                    ElevatedButton(
                                      onPressed: () async {
                                        final name = nameCtrl.text.trim();
                                        final desc = descCtrl.text.trim();
                                        if (name.isEmpty) return;
                                        final success = await ProductService.updateCategory(
                                          cat.id!,
                                          model.Category(
                                            id: cat.id,
                                            name: name,
                                            description: desc,
                                            createdAt: cat.createdAt,
                                          ),
                                        );
                                        if (success) Navigator.pop(context, true);
                                      },
                                      child: const Text('Lưu'),
                                    ),
                                  ],
                                ),
                              );
                              if (edited == true) onRefresh();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteCategory(cat.id!),
                          ),
                        ],
                      ),
                    ))
                        .toList(),
                  );
                },
              ),
            ),
          ),
          // Form tạo mới
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Tạo danh mục mới", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 12),
                  TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Tên danh mục')),
                  const SizedBox(height: 8),
                  TextField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Mô tả')),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: _createCategory, child: const Text("Tạo danh mục")),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:danentang/models/User.dart';
import 'package:danentang/models/Address.dart';
import 'package:danentang/Service/user_service.dart';

class UserInformation extends StatefulWidget {
  final String userId;
  const UserInformation({Key? key, required this.userId}) : super(key: key);

  @override
  State<UserInformation> createState() => _UserInformationState();
}

class _UserInformationState extends State<UserInformation> {
  final _formKey = GlobalKey<FormState>();
  final _svc = UserService();

  bool _loading = true;
  User? _user;

  // controllers for editable fields
  final _fullNameCtrl = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _avatarCtrl   = TextEditingController();
  DateTime? _dob;
  String? _gender;
  String? _status;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final u = await _svc.fetchUserById(widget.userId);
    setState(() {
      _user = u;
      _fullNameCtrl.text = u.fullName;
      _phoneCtrl.text    = u.phoneNumber ?? '';
      _avatarCtrl.text   = u.avatarUrl ?? '';
      _dob    = u.dateOfBirth;
      _gender = u.gender;
      _status = u.status;
      _loading = false;
    });
  }

  /// This does three things:
  ///  1) PUT /api/user/{id} for the profile fields
  ///  2) Sync addresses by diffing old vs new
  ///  3) Reload user
  Future<void> _saveAll() async {
    if (!_formKey.currentState!.validate()) return;

    // 1) Build your edited User object
    final edited = _user!.copyWith(
      fullName:    _fullNameCtrl.text.trim(),
      phoneNumber: _phoneCtrl.text.trim(),
      avatarUrl:   _avatarCtrl.text.trim(),
      dateOfBirth: _dob,
      gender:      _gender,
      status:      _status,
      // role and email remain unchanged
      addresses:   List<Address>.from(_user!.addresses),
    );

    try {
      // 2) Call the new updateUserFull which preserves server‐only fields
      await _svc.updateUserFull(edited);

      // 3) Reload fresh data so UI shows any server‐side changes
      await _loadUser();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật thành công!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật thất bại: $e')),
      );
    }
  }


  Future<void> _pickAvatar() async {
    final p = ImagePicker();
    final x = await p.pickImage(source: ImageSource.gallery);
    if (x == null) return;
    final bytes = await x.readAsBytes();
    final b64 = base64Encode(bytes);
    final ext = x.name.split('.').last;
    setState(() => _avatarCtrl.text = 'data:image/$ext;base64,$b64');
  }

  void _addAddress() {
    final form = GlobalKey<FormState>();
    final recv = TextEditingController();
    final ph   = TextEditingController();
    final line = TextEditingController();
    final comm = TextEditingController();
    final dist = TextEditingController();
    final city = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Thêm địa chỉ'),
        content: Form(
          key: form,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(controller: recv, decoration: const InputDecoration(labelText: 'Người nhận'), validator: (v)=>v!.isEmpty?'Bắt buộc':null),
                TextFormField(controller: ph, decoration: const InputDecoration(labelText: 'SĐT')),
                TextFormField(controller: line, decoration: const InputDecoration(labelText: 'Địa chỉ')),
                TextFormField(controller: comm, decoration: const InputDecoration(labelText: 'Phường/Xã')),
                TextFormField(controller: dist, decoration: const InputDecoration(labelText: 'Quận/Huyện')),
                TextFormField(controller: city, decoration: const InputDecoration(labelText: 'Tỉnh/TP')),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: (){
              if (!form.currentState!.validate()) return;
              setState(() {
                // clear defaults
                for (var a in _user!.addresses) {
                  a.isDefault = false;
                }
                _user!.addresses.add(Address(
                  receiverName: recv.text.trim(),
                  phone: ph.text.trim(),
                  addressLine: line.text.trim(),
                  commune: comm.text.trim(),
                  district: dist.text.trim(),
                  city: city.text.trim(),
                  isDefault: true,
                ));
              });
              Navigator.pop(context);
            },
            child: const Text('Lưu'),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _avatarCtrl.dispose();
    super.dispose();
  }
  void _showEditAddressDialog(int index) {
    final old = _user!.addresses[index];
    final form = GlobalKey<FormState>();
    final recv = TextEditingController(text: old.receiverName);
    final ph   = TextEditingController(text: old.phone);
    final line = TextEditingController(text: old.addressLine);
    final comm = TextEditingController(text: old.commune);
    final dist = TextEditingController(text: old.district);
    final city = TextEditingController(text: old.city);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Chỉnh sửa địa chỉ'),
        content: Form(
          key: form,
          child: SingleChildScrollView(
            child: Column(children: [
              TextFormField(controller: recv, decoration: const InputDecoration(labelText: 'Người nhận'), validator: (v)=>v!.isEmpty?'Bắt buộc':null),
              TextFormField(controller: ph,   decoration: const InputDecoration(labelText: 'SĐT')),
              TextFormField(controller: line, decoration: const InputDecoration(labelText: 'Địa chỉ')),
              TextFormField(controller: comm, decoration: const InputDecoration(labelText: 'Phường/Xã')),
              TextFormField(controller: dist, decoration: const InputDecoration(labelText: 'Quận/Huyện')),
              TextFormField(controller: city, decoration: const InputDecoration(labelText: 'Tỉnh/TP')),
            ]),
          ),
        ),
        actions: [
          TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              if (!form.currentState!.validate()) return;
              setState(() {
                // replace the old address at index
                _user!.addresses[index] = old.copyWith(
                  receiverName: recv.text.trim(),
                  phone: ph.text.trim(),
                  addressLine: line.text.trim(),
                  commune: comm.text.trim(),
                  district: dist.text.trim(),
                  city: city.text.trim(),
                  // keep old.isDefault
                );
              });
              Navigator.pop(context);
            },
            child: const Text('Lưu'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết người dùng'),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _saveAll)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(children: [
            // — Profile —
            TextFormField(
              initialValue: _user!.email,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: _fullNameCtrl,
              decoration: const InputDecoration(labelText: 'Họ tên'),
              validator: (v)=>v!.isEmpty?'Bắt buộc':null,
            ),
            TextFormField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(labelText: 'SĐT'),
            ),
            ListTile(
              title: const Text('Avatar'),
              subtitle: Text(_avatarCtrl.text.isEmpty?'Chưa chọn':'Đã chọn'),
              trailing: const Icon(Icons.image),
              onTap: _pickAvatar,
            ),
            DropdownButtonFormField<String>(
              value: _gender,
              decoration: const InputDecoration(labelText: 'Giới tính'),
              items:['male','female','other']
                  .map((g)=>DropdownMenuItem(value:g,child:Text(g)))
                  .toList(),
              onChanged: (v)=>setState(()=>_gender=v),
            ),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Trạng thái'),
              items:['Active','Banned']
                  .map((s)=>DropdownMenuItem(value:s,child:Text(s)))
                  .toList(),
              onChanged: (v)=>setState(()=>_status=v),
            ),
            ListTile(
              title: Text(_dob == null
                  ? 'Chọn ngày sinh'
                  : 'Ngày sinh: ${DateFormat.yMd().format(_dob!)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _dob ?? DateTime(2000),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (d != null) setState(()=>_dob=d);
              },
            ),

            const Divider(),

            // — Addresses —
            ListTile(
              title: const Text('Địa chỉ'),
              trailing: IconButton(icon: const Icon(Icons.add), onPressed: _addAddress),
            ),

            for (var i = 0; i < _user!.addresses.length; i++)
              Dismissible(
                key: ValueKey(_user!.addresses[i].createdAt.toIso8601String()),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  setState(() {
                    _user!.addresses.removeAt(i);
                  });
                },
                child: ListTile(
                  title: Text(_user!.addresses[i].addressLine),
                  subtitle: Text(
                      '${_user!.addresses[i].commune}, '
                          '${_user!.addresses[i].district}, '
                          '${_user!.addresses[i].city}'
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<int>(
                        value: i,
                        groupValue: _user!.addresses.indexWhere((a) => a.isDefault),
                        onChanged: (v) {
                          setState(() {
                            for (var a in _user!.addresses) a.isDefault = false;
                            _user!.addresses[i].isDefault = true;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _showEditAddressDialog(i),
                      ),
                    ],
                  ),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}

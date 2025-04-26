import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:danentang/models/user_model.dart';
import 'package:danentang/constants/colors.dart';

class ProfileManagementScreen extends StatefulWidget {
  const ProfileManagementScreen({Key? key}) : super(key: key);

  @override
  _ProfileManagementScreenState createState() => _ProfileManagementScreenState();
}

class _ProfileManagementScreenState extends State<ProfileManagementScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? _selectedGender;
  String? _selectedDate;
  String? _avatarUrl;
  bool _hasChanges = false;
  String _selectedSection = 'Personal Info'; // Mục được chọn trong submenu

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserModel>(context, listen: false);
    _nameController.text = user.userName;
    _phoneController.text = user.phoneNumber ?? '';
    _emailController.text = user.email ?? '';
    _selectedGender = user.gender;
    _selectedDate = user.dateOfBirth;
    _avatarUrl = user.avatarUrl;
  }

  Future<void> _pickImage(BuildContext context) async {
    final user = Provider.of<UserModel>(context, listen: false);
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Chọn từ thư viện'),
                  onTap: () async {
                    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setState(() {
                        _avatarUrl = image.path;
                        _hasChanges = true;
                      });
                      user.updateUser(avatarUrl: image.path);
                    }
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Chụp ảnh mới'),
                  onTap: () async {
                    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                    if (image != null) {
                      setState(() {
                        _avatarUrl = image.path;
                        _hasChanges = true;
                      });
                      user.updateUser(avatarUrl: image.path);
                    }
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showChangeDetailDialog(BuildContext context, String field, String? currentValue, Function(String) onSave, String? Function(String?) validator, bool isWeb) {
    final TextEditingController controller = TextEditingController(text: currentValue);
    String? errorMessage;

    if (isWeb) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 400,
                minHeight: 200,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            field,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: field,
                        border: const OutlineInputBorder(),
                        errorText: errorMessage,
                      ),
                      onChanged: (value) {
                        setState(() {
                          errorMessage = validator(value);
                          if (value != currentValue) {
                            _hasChanges = true;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Cancel',
                                style: TextStyle(color: AppColors.greyText),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ElevatedButton(
                              onPressed: errorMessage == null && controller.text.isNotEmpty
                                  ? () {
                                onSave(controller.text);
                                Navigator.pop(context);
                              }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.purpleButton,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Xác nhận'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              field,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: field,
                          border: const OutlineInputBorder(),
                          errorText: errorMessage,
                        ),
                        onChanged: (value) {
                          setState(() {
                            errorMessage = validator(value);
                            if (value != currentValue) {
                              _hasChanges = true;
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(color: AppColors.greyText),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: ElevatedButton(
                                onPressed: errorMessage == null && controller.text.isNotEmpty
                                    ? () {
                                  onSave(controller.text);
                                  Navigator.pop(context);
                                }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.purpleButton,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Xác nhận'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    }
  }

  void _showGenderSelectionDialog(BuildContext context, String? currentGender, Function(String) onSave, bool isWeb) {
    if (isWeb) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 400,
                minHeight: 200,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Giới tính',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Nữ'),
                      onTap: () {
                        setState(() {
                          _selectedGender = 'Nữ';
                          _hasChanges = true;
                        });
                        onSave('Nữ');
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      title: const Text('Nam'),
                      onTap: () {
                        setState(() {
                          _selectedGender = 'Nam';
                          _hasChanges = true;
                        });
                        onSave('Nam');
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      title: const Text('Khác'),
                      onTap: () {
                        setState(() {
                          _selectedGender = 'Khác';
                          _hasChanges = true;
                        });
                        onSave('Khác');
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Cancel',
                                style: TextStyle(color: AppColors.greyText),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ElevatedButton(
                              onPressed: null, // No action needed since selection is handled by ListTile
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.purpleButton,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Xác nhận'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } else {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Giới tính',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Nữ'),
                  onTap: () {
                    setState(() {
                      _selectedGender = 'Nữ';
                      _hasChanges = true;
                    });
                    onSave('Nữ');
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  title: const Text('Nam'),
                  onTap: () {
                    setState(() {
                      _selectedGender = 'Nam';
                      _hasChanges = true;
                    });
                    onSave('Nam');
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  title: const Text('Khác'),
                  onTap: () {
                    setState(() {
                      _selectedGender = 'Khác';
                      _hasChanges = true;
                    });
                    onSave('Khác');
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: AppColors.greyText),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ElevatedButton(
                          onPressed: null, // No action needed since selection is handled by ListTile
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.purpleButton,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Xác nhận'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    }
  }

  void _showDatePickerDialog(BuildContext context, String? currentDate, Function(String) onSave, bool isWeb) {
    DateTime initialDate = DateTime.now();
    if (currentDate != null) {
      final parts = currentDate.split('/');
      if (parts.length == 3) {
        final day = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        final year = int.tryParse(parts[2]);
        if (day != null && month != null && year != null) {
          initialDate = DateTime(year, month, day);
        }
      }
    }

    if (isWeb) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 400,
                minHeight: 200,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Ngày sinh',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: CalendarDatePicker(
                        initialDate: initialDate,
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                        onDateChanged: (DateTime newDate) {
                          final formattedDate = '${newDate.day.toString().padLeft(2, '0')}/${newDate.month.toString().padLeft(2, '0')}/${newDate.year}';
                          setState(() {
                            _selectedDate = formattedDate;
                            _hasChanges = true;
                          });
                          onSave(formattedDate);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Cancel',
                                style: TextStyle(color: AppColors.greyText),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ElevatedButton(
                              onPressed: null, // No action needed since selection is handled by CalendarDatePicker
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.purpleButton,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Xác nhận'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } else {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Ngày sinh',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: CalendarDatePicker(
                    initialDate: initialDate,
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                    onDateChanged: (DateTime newDate) {
                      final formattedDate = '${newDate.day.toString().padLeft(2, '0')}/${newDate.month.toString().padLeft(2, '0')}/${newDate.year}';
                      setState(() {
                        _selectedDate = formattedDate;
                        _hasChanges = true;
                      });
                      onSave(formattedDate);
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: AppColors.greyText),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ElevatedButton(
                          onPressed: null, // No action needed since selection is handled by CalendarDatePicker
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.purpleButton,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Xác nhận'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    }
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    final RegExp phoneRegex = RegExp(r'^\d{10}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Số điện thoại phải có đúng 10 chữ số';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
    }
    final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  Widget _buildMobileLayout(BuildContext context, UserModel user) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => _pickImage(context),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.avatarBackground,
                    backgroundImage: _avatarUrl != null
                        ? (_avatarUrl!.startsWith('http')
                        ? NetworkImage(_avatarUrl!)
                        : FileImage(File(_avatarUrl!)) as ImageProvider)
                        : null,
                    child: _avatarUrl == null
                        ? const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.grey,
                    )
                        : null,
                  ),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.cameraIconBackground,
                    child: Icon(
                      Icons.camera_alt,
                      size: 18,
                      color: AppColors.whiteIcon,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  user.userName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    _showChangeDetailDialog(context, 'Tên', user.userName, (newValue) {
                      setState(() {
                        _nameController.text = newValue;
                        _hasChanges = true;
                      });
                      user.updateUser(userName: newValue);
                    }, (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập tên';
                      }
                      return null;
                    }, false);
                  },
                  child: const Icon(
                    Icons.edit,
                    size: 22,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ListTile(
              title: const Text(
                'Giới tính',
                style: TextStyle(fontSize: 16),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  user.gender ?? 'Chưa cập nhật',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _showGenderSelectionDialog(context, user.gender, (newValue) {
                  user.updateUser(gender: newValue);
                }, false);
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text(
                'Ngày sinh',
                style: TextStyle(fontSize: 16),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  user.dateOfBirth ?? 'Chưa cập nhật',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _showDatePickerDialog(context, user.dateOfBirth, (newValue) {
                  user.updateUser(dateOfBirth: newValue);
                }, false);
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text(
                'SĐT',
                style: TextStyle(fontSize: 16),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  user.phoneNumber ?? 'Chưa cập nhật',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _showChangeDetailDialog(context, 'Số điện thoại', user.phoneNumber, (newValue) {
                  setState(() {
                    _phoneController.text = newValue;
                    _hasChanges = true;
                  });
                  user.updateUser(phoneNumber: newValue);
                }, _validatePhoneNumber, false);
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text(
                'email',
                style: TextStyle(fontSize: 16),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  user.email ?? 'Chưa cập nhật',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _showChangeDetailDialog(context, 'email', user.email, (newValue) {
                  setState(() {
                    _emailController.text = newValue;
                    _hasChanges = true;
                  });
                  user.updateUser(email: newValue);
                }, _validateEmail, false);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection(BuildContext context, UserModel user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 32.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'PROFILE',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        value: 0.75,
                        strokeWidth: 6,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.pink),
                      ),
                    ),
                    const Text(
                      '75%',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'NAME',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _hasChanges = true;
                });
              },
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'EMAIL',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _hasChanges = true;
                });
              },
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'SĐT',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _hasChanges = true;
                });
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Radio<String>(
                        value: 'Nam',
                        groupValue: _selectedGender,
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                            _hasChanges = true;
                          });
                          user.updateUser(gender: value);
                        },
                      ),
                      const Text('Nam'),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Radio<String>(
                        value: 'Nữ',
                        groupValue: _selectedGender,
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                            _hasChanges = true;
                          });
                          user.updateUser(gender: value);
                        },
                      ),
                      const Text('Nữ'),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Radio<String>(
                        value: 'Khác',
                        groupValue: _selectedGender,
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                            _hasChanges = true;
                          });
                          user.updateUser(gender: value);
                        },
                      ),
                      const Text('Khác'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                _showDatePickerDialog(context, user.dateOfBirth, (newValue) {
                  user.updateUser(dateOfBirth: newValue);
                }, true);
              },
              child: AbsorbPointer(
                child: TextField(
                  controller: TextEditingController(text: _selectedDate ?? 'Chưa cập nhật'),
                  decoration: const InputDecoration(
                    labelText: 'NGÀY SINH',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: _hasChanges
                      ? () {
                    setState(() {
                      _hasChanges = false;
                      final user = Provider.of<UserModel>(context, listen: false);
                      _nameController.text = user.userName;
                      _phoneController.text = user.phoneNumber ?? '';
                      _emailController.text = user.email ?? '';
                      _selectedGender = user.gender;
                      _selectedDate = user.dateOfBirth;
                      _avatarUrl = user.avatarUrl;
                    });
                  }
                      : null,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.pink),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  child: const Text(
                    'Discard Changes',
                    style: TextStyle(color: Colors.pink),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _hasChanges
                      ? () {
                    String? emailError = _validateEmail(_emailController.text);
                    String? phoneError = _validatePhoneNumber(_phoneController.text);
                    if (emailError == null && phoneError == null && _nameController.text.isNotEmpty) {
                      user.updateUser(
                        userName: _nameController.text,
                        email: _emailController.text,
                        phoneNumber: _phoneController.text,
                      );
                      setState(() {
                        _hasChanges = false;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            emailError ?? phoneError ?? 'Vui lòng nhập tên',
                          ),
                        ),
                      );
                    }
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderSection(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          const Text('Nội dung cho phần này đang được phát triển.'),
        ],
      ),
    );
  }

  Widget _buildWebLayout(BuildContext context, UserModel user) {
    return Row(
      children: [
        // Thanh điều hướng bên trái với submenu
        Container(
          width: 250,
          color: Colors.grey[100],
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.avatarBackground,
                        backgroundImage: _avatarUrl != null
                            ? (_avatarUrl!.startsWith('http')
                            ? NetworkImage(_avatarUrl!)
                            : FileImage(File(_avatarUrl!)) as ImageProvider)
                            : null,
                        child: _avatarUrl == null
                            ? const Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.grey,
                        )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.userName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                ExpansionTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Profile'),
                  initiallyExpanded: true,
                  children: [
                    ListTile(
                      title: const Text('Personal Info'),
                      selected: _selectedSection == 'Personal Info',
                      selectedTileColor: Colors.pink[50],
                      onTap: () {
                        setState(() {
                          _selectedSection = 'Personal Info';
                        });
                      },
                    ),
                    ListTile(
                      title: const Text('Password'),
                      selected: _selectedSection == 'Password',
                      selectedTileColor: Colors.pink[50],
                      onTap: () {
                        setState(() {
                          _selectedSection = 'Password';
                        });
                      },
                    ),
                  ],
                ),
                ListTile(
                  leading: const Icon(Icons.work),
                  title: const Text('Work Opportunities'),
                  selected: _selectedSection == 'Work Opportunities',
                  selectedTileColor: Colors.pink[50],
                  onTap: () {
                    setState(() {
                      _selectedSection = 'Work Opportunities';
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.share),
                  title: const Text('Social Profiles'),
                  selected: _selectedSection == 'Social Profiles',
                  selectedTileColor: Colors.pink[50],
                  onTap: () {
                    setState(() {
                      _selectedSection = 'Social Profiles';
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Invitations'),
                  selected: _selectedSection == 'Invitations',
                  selectedTileColor: Colors.pink[50],
                  onTap: () {
                    setState(() {
                      _selectedSection = 'Invitations';
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.devices),
                  title: const Text('Sessions'),
                  selected: _selectedSection == 'Sessions',
                  selectedTileColor: Colors.pink[50],
                  onTap: () {
                    setState(() {
                      _selectedSection = 'Sessions';
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.apps),
                  title: const Text('Applications'),
                  selected: _selectedSection == 'Applications',
                  selectedTileColor: Colors.pink[50],
                  onTap: () {
                    setState(() {
                      _selectedSection = 'Applications';
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        // Nội dung chính bên phải
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (_selectedSection == 'Personal Info') _buildPersonalInfoSection(context, user),
                if (_selectedSection == 'Password') _buildPlaceholderSection('Password'),
                if (_selectedSection == 'Work Opportunities') _buildPlaceholderSection('Work Opportunities'),
                if (_selectedSection == 'Social Profiles') _buildPlaceholderSection('Social Profiles'),
                if (_selectedSection == 'Invitations') _buildPlaceholderSection('Invitations'),
                if (_selectedSection == 'Sessions') _buildPlaceholderSection('Sessions'),
                if (_selectedSection == 'Applications') _buildPlaceholderSection('Applications'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý trang cá nhân'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWeb = constraints.maxWidth > 800;
          if (isWeb) {
            return _buildWebLayout(context, user);
          } else {
            return _buildMobileLayout(context, user);
          }
        },
      ),
    );
  }
}
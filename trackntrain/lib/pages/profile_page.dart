import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:trackntrain/utils/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  double _height = 170; 
  double _weight = 70; 
  double _age = 23; 

  void _logout(BuildContext context)async{
    try {
      await AuthService.signOut();
    } catch (e) {
      if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            backgroundColor: Colors.red,
            content: Text(
              e.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
    
  }

  void _deleteAccount() async{
    await AuthService.deleteAccount();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        backgroundColor: Colors.red,
        content: Text(
          'Account deleted successfully',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Profile',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 247, 2, 2),
                Color.fromARGB(255, 220, 20, 20),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey[50]!,
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.grey[50]!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color.fromARGB(255, 247, 2, 2),
                            Color.fromARGB(255, 220, 20, 20),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(36),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(34),
                          child: Image.asset(
                            'assets/images/user.jpg',
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Text(
                      AuthService.currentUser?.displayName ?? 'Manish Jangid',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 247, 2, 2).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        AuthService.currentUser?.email ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 247, 2, 2).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            color: Color.fromARGB(255, 247, 2, 2),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Your Info',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            fontFamily: 'Poppins',
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    _buildSelectorCard(
                      title: 'Height',
                      value: '${_height.toInt()} cm',
                      icon: Icons.height,
                      onTap: () => _showHeightPicker(context),
                    ),
                    
                    _buildSelectorCard(
                      title: 'Weight',
                      value: '${_weight.toInt()} kg',
                      icon: Icons.monitor_weight_outlined,
                      onTap: () => _showWeightPicker(context),
                    ),
                    
                    _buildSelectorCard(
                      title: 'Age',
                      value: '${_age.toInt()} years',
                      icon: Icons.cake_outlined,
                      onTap: () => _showAgePicker(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.grey[50]!,
                            Colors.white,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color.fromARGB(255, 247, 2, 2).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _logout(context);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(255, 247, 2, 2).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.logout,
                                    color: Color.fromARGB(255, 247, 2, 2),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Logout',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 247, 2, 2),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.red[50]!,
                            Colors.white,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _showConfirmationDialog(context);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.delete_forever,
                                    color: Colors.red[600],
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Delete Account',
                                  style: TextStyle(
                                    color: Colors.red[600],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.delete_forever_outlined,
                color: Colors.red,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Delete Account',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Colors.red,
                  Color.fromARGB(255, 180, 10, 10),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  _deleteAccount();
                },
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Delete Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      );
    },
  );
}

  Widget _buildSelectorCard({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[50]!,
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 247, 2, 2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: const Color.fromARGB(255, 247, 2, 2),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 247, 2, 2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Color.fromARGB(255, 247, 2, 2),
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Show height picker dialog
  void _showHeightPicker(BuildContext context) {
    // Determine if we should use Cupertino style (iOS) or Material style (Android)
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    
    if (isIOS) {
      _showCupertinoHeightPicker(context);
    } else {
      _showMaterialHeightPicker(context);
    }
  }
  
  void _showCupertinoHeightPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                height: 50,
                color: Colors.grey[200],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    CupertinoButton(
                      child: const Text('Done'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      _height = 120 + index.toDouble();
                    });
                  },
                  scrollController: FixedExtentScrollController(
                    initialItem: (_height - 120).toInt(),
                  ),
                  children: List<Widget>.generate(121, (int index) {
                    return Center(
                      child: Text(
                        '${120 + index} cm',
                        style: const TextStyle(fontSize: 20),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _showMaterialHeightPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: 350,
              child: Column(
                children: [
                  AppBar(
                    title: const Text('Select Height'),
                    leading: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Done',
                          style: TextStyle(color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 50,
                      perspective: 0.005,
                      diameterRatio: 1.5,
                      physics: const FixedExtentScrollPhysics(),
                      controller: FixedExtentScrollController(
                        initialItem: (_height - 120).toInt(),
                      ),
                      onSelectedItemChanged: (int index) {
                        setModalState(() {
                          _height = 120 + index.toDouble();
                        });
                        setState(() {});
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 121,
                        builder: (context, index) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            alignment: Alignment.center,
                            child: Text(
                              '${120 + index} cm',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: (_height == 120 + index) ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  // Show weight picker dialog
  void _showWeightPicker(BuildContext context) {
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    
    if (isIOS) {
      _showCupertinoWeightPicker(context);
    } else {
      _showMaterialWeightPicker(context);
    }
  }
  
  void _showCupertinoWeightPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                height: 50,
                color: Colors.grey[200],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    CupertinoButton(
                      child: const Text('Done'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      _weight = 30 + index.toDouble();
                    });
                  },
                  scrollController: FixedExtentScrollController(
                    initialItem: (_weight - 30).toInt(),
                  ),
                  children: List<Widget>.generate(171, (int index) {
                    return Center(
                      child: Text(
                        '${30 + index} kg',
                        style: const TextStyle(fontSize: 20),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _showMaterialWeightPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: 350,
              child: Column(
                children: [
                  AppBar(
                    title: const Text('Select Weight'),
                    leading: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Done',
                          style: TextStyle(color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 50,
                      perspective: 0.005,
                      diameterRatio: 1.5,
                      physics: const FixedExtentScrollPhysics(),
                      controller: FixedExtentScrollController(
                        initialItem: (_weight - 30).toInt(),
                      ),
                      onSelectedItemChanged: (int index) {
                        setModalState(() {
                          _weight = 30 + index.toDouble();
                        });
                        setState(() {});
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 171,
                        builder: (context, index) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            alignment: Alignment.center,
                            child: Text(
                              '${30 + index} kg',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: (_weight == 30 + index) ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  // Show age picker dialog
  void _showAgePicker(BuildContext context) {
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    
    if (isIOS) {
      _showCupertinoAgePicker(context);
    } else {
      _showMaterialAgePicker(context);
    }
  }
  
  void _showCupertinoAgePicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                height: 50,
                color: Colors.grey[200],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    CupertinoButton(
                      child: const Text('Done'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      _age = 12 + index.toDouble();
                    });
                  },
                  scrollController: FixedExtentScrollController(
                    initialItem: (_age - 12).toInt(),
                  ),
                  children: List<Widget>.generate(89, (int index) {
                    return Center(
                      child: Text(
                        '${12 + index} years',
                        style: const TextStyle(fontSize: 20),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _showMaterialAgePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: 350,
              child: Column(
                children: [
                  AppBar(
                    title: const Text('Select Age'),
                    leading: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Done',
                          style: TextStyle(color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 50,
                      perspective: 0.005,
                      diameterRatio: 1.5,
                      physics: const FixedExtentScrollPhysics(),
                      controller: FixedExtentScrollController(
                        initialItem: (_age - 12).toInt(),
                      ),
                      onSelectedItemChanged: (int index) {
                        setModalState(() {
                          _age = 12 + index.toDouble();
                        });
                        setState(() {});
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 89,
                        builder: (context, index) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            alignment: Alignment.center,
                            child: Text(
                              '${12 + index} years',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: (_age == 12 + index) ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }
}
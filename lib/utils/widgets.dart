// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parents_app/utils/appstate.dart';

class OvalButton extends StatelessWidget {
  final Color? color;
  final String? text;
  final Function? function;

  const OvalButton(
      {Key? key, this.color = Colors.amber, this.text, this.function})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(), backgroundColor: color),
        onPressed: () {
          function!();
        },
        child: Text(text!));
  }
}

class ElevatedButtonCustomized extends StatelessWidget {
  final dynamic onPressed;
  final String text;
  final Color color;
  final Icon? icon;
  final TextStyle style;
  const ElevatedButtonCustomized({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = Colors.transparent,
    this.icon,
    this.style = const TextStyle(
      fontWeight: FontWeight.bold,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
      height: MediaQuery.of(context).size.width * 0.12,
      child: InkWell(
        onTap: onPressed,
        child: Card(
          shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(15)),
          color: color,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: icon ?? Container(),
              ),
              Text(
                text,
                style: style.copyWith(
                  color: Theme.of(context).dialogBackgroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    required this.phoneController,
  });

  final TextEditingController phoneController;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: phoneController,
      decoration: InputDecoration(
        label: Text("phoneNo".tr),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class CustomDialog extends StatelessWidget {
  final String header;
  final String body;
  final dynamic yesLogic;
  final dynamic noLogic;

  const CustomDialog(
      {super.key,
      required this.header,
      required this.body,
      required this.yesLogic,
      required this.noLogic});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: HeadingText(text: header),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            Text(body),
          ],
        ),
      ),
      actions: [
        TextButton(
          // onPressed: () => SystemNavigator.pop(),
          onPressed: yesLogic,
          child: HeadingText(
            text: "yes".tr,
            color: Colors.green,
            size: 16,
          ),
          // child: HeadingText(text: ""),
        ),
        TextButton(
          // onPressed: () => Navigator.of(context).pop(),
          onPressed: noLogic,
          child: HeadingText(
            text: "no".tr,
            color: Colors.red,
            size: 16,
          ),
        ),
      ],
    );
  }
}

class EditableTextField extends StatefulWidget {
  final String initialValue;
  final int flag;
  const EditableTextField(
      {super.key, required this.initialValue, required this.flag});

  @override
  EditableTextFieldState createState() => EditableTextFieldState();
}

class EditableTextFieldState extends State<EditableTextField> {
  bool isEditing = false;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Editable Text
        TextField(
          style: TextStyle(
            overflow: TextOverflow.ellipsis,
            fontSize: 18,
            color: isEditing
                ? Theme.of(context).textTheme.bodyLarge!.color
                : Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .color!
                    .withOpacity(0.5),
          ),
          controller: _controller,
          enabled: isEditing,
          autofocus: isEditing,
          textAlign: (widget.flag == 0) ? TextAlign.center : TextAlign.left,
          decoration: InputDecoration(
            fillColor: Colors.transparent,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Get.isDarkMode ? Colors.white : Colors.black,
              ), // Add underline.
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Get.isDarkMode ? Colors.white : Colors.black,
              ), // Add underline.
            ),
            border: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            contentPadding: const EdgeInsets.all(8),
            // fillColor: Colors.transparent,
          ),
        ),
        // Edit Icon Button
        Positioned(
          right: -10,
          child: IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              if (isEditing) {
                // Save the text
                if (widget.flag == 0) {
                  AppState().device!.nickname = _controller.text.trim();
                } else if (widget.flag == 1) {
                  AppState().user!.phone = _controller.text.trim();
                } else if (widget.flag == 2) {
                  AppState().user!.email = _controller.text.trim();
                }
              }
              setState(() {
                isEditing = !isEditing;
              });
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class LinkPhoneOrEmail extends StatelessWidget {
  final dynamic onPressed;
  final String text;
  const LinkPhoneOrEmail({
    super.key,
    required this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: text,
            hintStyle: const TextStyle(fontSize: 16),
          ),
          enabled: false,
        ),
        Positioned(
          right: -10,
          child: IconButton(
            icon: const Icon(Icons.link),
            onPressed: onPressed,
          ),
        ),
      ],
    );
  }
}

class ListTileWidget extends StatefulWidget {
  final IconData leadingIcon;
  final String title;
  final String subtitle;
  final bool isSwitched;
  final bool switchAvailable;
  final bool subtitleAvailable;
  final dynamic onChanged;
  final double height;
  final bool isDelete;
  final dynamic onPressDelete;
  final double verticalPadding;

  const ListTileWidget({
    super.key,
    required this.leadingIcon,
    required this.title,
    required this.subtitle,
    required this.isSwitched,
    required this.switchAvailable,
    required this.subtitleAvailable,
    this.height = 70,
    this.onChanged,
    this.isDelete = false,
    this.onPressDelete,
    this.verticalPadding = 12,
  });

  @override
  State<ListTileWidget> createState() => _ListTileWidgetState();
}

class _ListTileWidgetState extends State<ListTileWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: 32, vertical: widget.verticalPadding),
      child: Container(
        // height: widget.height,
        decoration: BoxDecoration(
          color: Get.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
          border: Border.all(
            color: Colors.grey,
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 2.0,
              spreadRadius: 1.0,
              offset: const Offset(0, 2),
            ),
          ],
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        // child: Card(
        // color: Get.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
        // shape: ContinuousRectangleBorder(
        //   borderRadius: BorderRadius.circular(10),
        // ),
        child: ListTile(
          minVerticalPadding: 15,
          leading: Icon(
            widget.leadingIcon,
            size: 28,
          ),
          title: Text(widget.title,
              style:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
          subtitle: widget.subtitleAvailable ? Text(widget.subtitle) : null,
          trailing: widget.switchAvailable
              ? CupertinoSwitch(
                  value: widget.isSwitched,
                  activeColor: Theme.of(context).primaryColor,
                  onChanged: widget.onChanged,
                )
              : widget.isDelete
                  ? IconButton(
                      onPressed: widget.onPressDelete,
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ))
                  : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
        ),
        // ),
      ),
    );
  }
}

class CustomLoadingIndicator extends StatelessWidget {
  final double height;
  final double width;
  final double horizontalPadding;
  final double verticalPadding;
  const CustomLoadingIndicator({
    super.key,
    this.height = 100,
    this.width = 100,
    this.horizontalPadding = 0,
    this.verticalPadding = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        height: height,
        width: width,
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        child: CircularProgressIndicator(
          color: Theme.of(context).primaryColor,
        ));
  }
}

class HeadingText extends StatelessWidget {
  final String text;
  final double size;
  final Color color;
  const HeadingText({
    required this.text,
    this.size = 16.0,
    this.color = Colors.white,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: size,
        color: color,
      ),
    );
  }
}

class CustomCachedImageWidget extends StatefulWidget {
  final String imageId;
  const CustomCachedImageWidget(
      //     {super.key, required this.isUser, this.imageUrl, required this.index});
      {super.key,
      required this.imageId});

  @override
  State<CustomCachedImageWidget> createState() => _CustomCachedImageWidget();
}

class _CustomCachedImageWidget extends State<CustomCachedImageWidget> {
  XFile? image;
  @override
  void initState() {
    super.initState();
    // debugPrint("ImageUrl received by the widget is: ${widget.imageUrl}");
  }

  File? convertXFileToFile(XFile? xFile) {
    if (xFile == null) {
      return null;
    }
    try {
      // Use the File constructor to create a new File object
      File file = File(xFile.path);
      return file;
    } catch (e) {
      debugPrint("Error converting File to XFile: $e");
      return null;
    }
  }

  XFile? convertFileToXFile(File? file) {
    if (file == null) {
      return null;
    }
    try {
      final XFile xFile = XFile(file.path);
      return xFile;
    } catch (e) {
      debugPrint("Error converting File to XFile: $e");
      return null;
    }
  }

  void clearCache() {
    DefaultCacheManager().emptyCache();

    imageCache.clear();
    imageCache.clearLiveImages();
  }

  Future<void> _handleImage(XFile? image) async {
    late File? file;
    if (image != null) {
      file = convertXFileToFile(image);
      // Now, 'file' is a File object that you can work with.
      debugPrint('File path: ${file!.path}');
    } else {
      debugPrint('No image selected.');
    }
    if (image != null && file != null) {
      // Handle the selected image (e.g., display it or save it).
      var value = await AppState().uploadImage(file, widget.imageId);
      if (value) {
        debugPrint("value is $value");
        // AppState().imageUserURL =
        //     "${AppState().baseUrl}/image/${AppState().user!.id}";
        clearCache();
        // debugPrint("deviceImage is fetched");
        // debugPrint("User image url is: ${AppState().imageUserURL}");
      } else {
        Get.snackbar(
          "Error",
          "Display the message here",
          colorText: Colors.red,
          backgroundColor: Colors.transparent.withOpacity(0.9),
        );
      }
      debugPrint("Image file uploaded to server");
    }
    Get.back();
  }

  Future<void> _getImageFromCamera() async {
    image = await ImagePicker().pickImage(source: ImageSource.camera);
    await _handleImage(image);
  }

  Future<void> _getImageFromGallery() async {
    image = await ImagePicker().pickImage(source: ImageSource.gallery);
    await _handleImage(image);
  }

  void _showImageSelectionOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(
                  Icons.camera,
                ),
                title: Text("takepic".tr),
                iconColor: Colors.black,
                textColor: Colors.black,
                onTap: () async {
                  await _getImageFromCamera();
                },
              ),
              const Divider(
                color: Colors.grey,
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: Text("gallery".tr),
                iconColor: Colors.black,
                textColor: Colors.black,
                onTap: () async {
                  await _getImageFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        _showImageSelectionOptions(context);
      },
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Circular Avatar
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: CachedNetworkImage(
              key: UniqueKey(),
              height: 100,
              width: 100,
              fit: BoxFit.cover,
              maxHeightDiskCache: 75,
              imageUrl: "${AppState().baseUrl}/image/${widget.imageId}",
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),

          // Camera-Editing Icon (Translucent)
          Container(
            height: 50,
            width: 100,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              backgroundBlendMode: BlendMode.srcOver,

              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(150.0),
              ),
              // color: Colors.black.withOpacity(0.3), // Translucent background
              color:
                  Colors.transparent.withOpacity(0.2), // Translucent background
            ),
            child: const Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: 28.0,
            ),
          ),
        ],
      ),
    );
  }
}

class DeviceListTile extends StatefulWidget {
  final String deviceBrand;
  final String deviceModel;
  final String deviceName;
  final dynamic onTap;
  final ImageProvider<Object>? image;

  const DeviceListTile({
    Key? key,
    required this.deviceBrand,
    required this.deviceModel,
    required this.deviceName,
    this.onTap,
    this.image,
  }) : super(key: key);

  @override
  DeviceListTileState createState() => DeviceListTileState();
}

class DeviceListTileState extends State<DeviceListTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _animation =
        Tween<double>(begin: 1, end: 0.9).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _animationController.forward();
      },
      onTapUp: (_) async {
        await _animationController.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        _animationController.reverse();
      },
      child: ScaleTransition(
        scale: _animation,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color:
                  Get.isDarkMode ? Colors.grey.shade300 : Colors.grey.shade400,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 2.0,
                spreadRadius: 1.0,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            leading: widget.image == null
                ? null
                : CircleAvatar(
                    backgroundImage: widget.image!,
                    radius: 25,
                  ),
            title: Text(
              widget.deviceName,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${widget.deviceBrand}${widget.deviceBrand.isEmpty ? "" : ","} ${widget.deviceModel}",
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';
import 'package:insta_assets_picker_demo/widgets/crop_result_view.dart';
import 'package:insta_assets_picker_demo/widgets/insta_picker_interface.dart';
import 'package:path/path.dart' as path;

class CameraImagePicker extends StatefulWidget with InstaPickerInterface {
  const CameraImagePicker({super.key});

  @override
  State<CameraImagePicker> createState() => _CameraImagePickerState();

  @override
  PickerDescription get description => const PickerDescription(
        icon: '📷',
        label: 'Camera Image Picker',
        description: 'Picker with a camera button.\n'
            'The camera logic is handled by the `camera` package.',
      );
}

class _CameraImagePickerState extends State<CameraImagePicker> {
  /// Needs a [BuildContext] that is coming from the picker
  Future<void> _pickFromCamera(BuildContext context) async {
    // Feedback.forTap(context);
    final image = await ImagePicker().pickImage(source: ImageSource.camera);

    if (!context.mounted || image == null) return;

    final AssetEntity? entity = await PhotoManager.editor.saveImageWithPath(
      image.path,
      title: path.basename(image.path),
    );

    if (entity == null) return;

    if (context.mounted) {
      await InstaAssetPicker.refreshAndSelectEntity(
        context,
        entity,
      );
    }
  }

  @override
  Widget build(BuildContext context) => widget.buildLayout(
        context,
        onPressed: () => InstaAssetPicker.pickAssets(
          context,
          title: widget.description.fullLabel,
          maxAssets: 4,
          pickerTheme: widget.getPickerTheme(context),
          actionsBuilder: (
            BuildContext context,
            ThemeData? pickerTheme,
            double height,
            VoidCallback unselectAll,
          ) =>
              [
            InstaPickerCircleIconButton.unselectAll(
              onTap: unselectAll,
              theme: pickerTheme,
              size: height,
            ),
            const SizedBox(width: 8),
            InstaPickerCircleIconButton(
              onTap: () => _pickFromCamera(context),
              theme: pickerTheme,
              icon: const Icon(Icons.camera_alt),
              size: height,
            ),
          ],
          specialItemBuilder: (BuildContext context, _, __) {
            // return a button that open the camera
            return ElevatedButton(
              onPressed: () => _pickFromCamera(context),
              style: ElevatedButton.styleFrom(
                shape: const RoundedRectangleBorder(),
                foregroundColor: Colors.white,
                backgroundColor: Colors.transparent,
              ),
              child: FittedBox(
                fit: BoxFit.cover,
                child: Text(
                  InstaAssetPicker.defaultTextDelegate(context)
                      .sActionUseCameraHint,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
          // since the list is revert, use prepend to be at the top
          specialItemPosition: SpecialItemPosition.prepend,
          onCompleted: (cropStream) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PickerCropResultScreen(cropStream: cropStream),
              ),
            );
          },
        ),
      );
}


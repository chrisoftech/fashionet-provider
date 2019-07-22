import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:meta/meta.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:uuid/uuid.dart';

class ImageRepository {
  final FirebaseStorage _firebaseStorage;

  ImageRepository() : _firebaseStorage = FirebaseStorage.instance;

  Future<Uint8List> _compressFile(
      {@required List<int> imageData, int quality = 20}) async {
    List<int> compressedImageData = await FlutterImageCompress.compressWithList(
        imageData,
        quality: quality);

    return Uint8List.fromList(compressedImageData);
  }

  Future<String> saveProfileImage(
      {@required String userId, @required Asset asset}) async {
    final String fileName = 'profiles/$userId/$userId';

    ByteData byteData = await asset.requestOriginal();
    List<int> imageData = byteData.buffer.asUint8List();

    // compress file
    Uint8List compressedFile = await _compressFile(imageData: imageData);

    StorageReference reference = _firebaseStorage.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putData(compressedFile);
    StorageTaskSnapshot storageTaskSnapshot;

    // Release the image data
    // asset.releaseOriginal();

    StorageTaskSnapshot snapshot = await uploadTask.onComplete.timeout(
        const Duration(seconds: 60),
        onTimeout: () =>
            throw ('Upload could not be completed. Operation timeout'));

    if (snapshot.error == null) {
      storageTaskSnapshot = snapshot;
      return await storageTaskSnapshot.ref.getDownloadURL();
    } else {
      throw ('An error occured while uploading image. Upload error');
    }
  }

  Future<String> uploadCategoryImage({@required Asset asset}) async {
    final uuid = Uuid();
    final String fileName = 'categories/${uuid.v1()}';

    ByteData byteData = await asset.requestOriginal();
    List<int> imageData = byteData.buffer.asUint8List();

    // compress file
    Uint8List compressedFile =
        await _compressFile(imageData: imageData, quality: 30);

    StorageReference reference = _firebaseStorage.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putData(compressedFile);
    StorageTaskSnapshot storageTaskSnapshot;

    // Release the image data
    // asset.releaseOriginal();

    StorageTaskSnapshot snapshot = await uploadTask.onComplete.timeout(
        const Duration(seconds: 60),
        onTimeout: () =>
            throw ('Upload could not be completed. Operation timeout'));

    if (snapshot.error == null) {
      storageTaskSnapshot = snapshot;
      return await storageTaskSnapshot.ref.getDownloadURL();
    } else {
      throw ('An error occured while uploading image. Upload error');
    }
  }

  Future<List<String>> uploadPostImages(
      {@required String fileLocation, @required List<Asset> assets}) async {
    List<String> uploadUrls = [];

    await Future.wait(
            assets.map((Asset asset) async {
              ByteData byteData = await asset.requestOriginal();
              List<int> imageData = byteData.buffer.asUint8List();

              // compress file
              Uint8List compressedFile =
                  await _compressFile(imageData: imageData);

              final uuid = Uuid();
              final fileName = 'posts/$fileLocation/${uuid.v1()}';

              StorageReference reference =
                  FirebaseStorage.instance.ref().child(fileName);
              StorageUploadTask uploadTask = reference.putData(compressedFile);
              StorageTaskSnapshot storageTaskSnapshot;

              // Release the image data
              // asset.releaseOriginal();

              StorageTaskSnapshot snapshot = await uploadTask.onComplete.timeout(
                  const Duration(seconds: 180),
                  onTimeout: () =>
                      throw ('Upload could not be completed. Operation timeout'));

              if (snapshot.error == null) {
                storageTaskSnapshot = snapshot;
                final String downloadUrl =
                    await storageTaskSnapshot.ref.getDownloadURL();

                uploadUrls.add(downloadUrl);
                print('Upload success');
              } else {
                print('Error from image repo ${snapshot.error.toString()}');
                throw ('An error occured while uploading image. Upload error');
              }
            }),
            eagerError: true,
            cleanUp: (_) {
              print('eager cleaned up');
            })
        .timeout(const Duration(seconds: 180),
            onTimeout: () =>
                throw ('Upload could not be completed. Operation timeout'));

    return uploadUrls;
  }

  Future<void> deleteImage({@required String imageUrl}) async {
    if (imageUrl.isNotEmpty) {
      final StorageReference reference =
          await FirebaseStorage.instance.getReferenceFromUrl(imageUrl);
      return reference.delete();
    }
  }
}

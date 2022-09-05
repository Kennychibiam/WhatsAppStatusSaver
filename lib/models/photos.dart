class PhotosModel{
  String ?photoPath;
  bool ?isPhotoDownloaded;
  bool?isDownloading;
  DateTime?dateModified;

  PhotosModel({this.photoPath,this.isPhotoDownloaded,required this.isDownloading,this.dateModified});
}
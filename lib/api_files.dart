class LiveApis {
  static const String liveApi = 'https://africanspringsapi.herokuapp.com/api';

  static const String getAllUsers = '$liveApi/user/get/all';
  static const String suspendUser = '$liveApi/user/update/suspension/';
  static const String createAdmin = '$liveApi/admins/register';
  static const String getAllAdmin = '$liveApi/admins/get/all';
  static const String getAdmin = '$liveApi/admins/get/one/';
  static const String suspendAdmin = '$liveApi/admins/update/suspension/';
  static const String updateAdminPost = '$liveApi/admins/update/post/id';
  static const String login = '$liveApi/login';
  static const String getSuperAdmin = '$liveApi/super/admins/get/one/';
  static const String updateSuperAdminPost = '$liveApi/super/admins/update/post/id';
  static const String createPost = '$liveApi/post/create/news';
  static const String getAllPost = '$liveApi/post/get/all/news';
  static const String updatePost = '$liveApi/post/update/news/';
  static const String updateStatus = '$liveApi/post/update/status/';
  static const String updateTrending = '$liveApi/post/update/trending/';
  static const String updateFeatured = '$liveApi/post/update/featured/';
  static const String updateThumbnail = '$liveApi/post/update/thumbnail/';
  static const String deletePost = '$liveApi/post/delete/single/post/';
  static const String general = '$liveApi/general/get/all/news';
  static const String resetPassword = '$liveApi/reset/password/';
  static const String resetSuperImage = '$liveApi/super/admins/update/profile/';
  static const String resetAdminImage = '$liveApi/admins/update/profile/';

}
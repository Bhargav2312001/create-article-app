import 'package:get/get.dart';
import '../modules/create_article/create_article_binding.dart';
import '../modules/create_article/create_article_page.dart';
import '../modules/edit_cover/edit_cover_binding.dart';
import '../modules/edit_cover/edit_cover_page.dart';
import '../modules/edit_thumbnail/edit_thumbnail_binding.dart';
import '../modules/edit_thumbnail/edit_thumbnail_page.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.CREATE_ARTICLE,
      page: () => const CreateArticlePage(),
      binding: CreateArticleBinding(),
    ),
    GetPage(
      name: AppRoutes.EDIT_COVER,
      page: () => const EditCoverPage(),
      binding: EditCoverBinding(),
    ),
    GetPage(
      name: AppRoutes.EDIT_THUMBNAIL,
      page: () => const EditThumbnailPage(),
      binding: EditThumbnailBinding(),
    ),
  ];
}

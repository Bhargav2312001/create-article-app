import 'package:get/get.dart';
import 'edit_thumbnail_controller.dart';
import '../create_article/create_article_controller.dart';
import '../../services/media_service.dart';

class EditThumbnailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditThumbnailController>(
      () => EditThumbnailController(
        createArticleController: Get.find<CreateArticleController>(),
      ),
    );
  }
}

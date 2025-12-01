import 'package:get/get.dart';
import 'edit_cover_controller.dart';
import '../create_article/create_article_controller.dart';

class EditCoverBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditCoverController>(
      () => EditCoverController(
        createArticleController: Get.find<CreateArticleController>(),
      ),
    );
  }
}

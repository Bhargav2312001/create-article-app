import 'package:get/get.dart';
import 'create_article_controller.dart';
import '../../services/media_service.dart';

class CreateArticleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MediaService>(() => MediaService());
    Get.lazyPut<CreateArticleController>(() => CreateArticleController());
  }
}

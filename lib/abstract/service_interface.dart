/// 服务接口抽象类 - 提供统一的服务生命周期管理
/// 所有服务类必须实现该接口以保证资源管理的一致性
abstract class ServiceInterface {
  /// 初始化服务
  /// - 加载配置
  /// - 分配资源
  /// - 建立连接
  /// 必须在UI主线程中调用
  Future<void> initialize();

  /// 清理资源
  void dispose();
}
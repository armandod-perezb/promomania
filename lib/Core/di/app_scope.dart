import 'package:app/core/network/api_client.dart';
import 'package:app/core/storage/session_manager.dart';
import 'package:app/features/auth/domain/usecases/auth_usecases.dart';
import 'package:app/features/auth/infrastructure/datasources/auth_session_datasource.dart';
import 'package:app/features/auth/infrastructure/datasources/auth_user_datasource.dart';
import 'package:app/features/auth/infrastructure/datasources/remote_login_datasource.dart';
import 'package:app/features/auth/infrastructure/repositories/auth_repository_impl.dart';
import 'package:app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:app/features/Settings/settings_controller.dart';
import 'package:app/features/catalog/domain/usecases/catalog_usecases.dart';
import 'package:app/features/catalog/infrastructure/datasources/catalog_datasource.dart';
import 'package:app/features/catalog/infrastructure/repositories/catalog_repository_impl.dart';
import 'package:app/features/catalog/presentation/controllers/catalog_controller.dart';
import 'package:app/features/comments/domain/usecases/comment_usecases.dart';
import 'package:app/features/comments/infrastructure/datasources/comment_datasource.dart';
import 'package:app/features/comments/infrastructure/repositories/comment_repository_impl.dart';
import 'package:app/features/comments/presentation/controllers/comments_controller.dart';
import 'package:app/features/interactions/domain/usecases/interaction_usecases.dart';
import 'package:app/features/interactions/infrastructure/datasources/interaction_datasource.dart';
import 'package:app/features/interactions/infrastructure/repositories/interaction_repository_impl.dart';
import 'package:app/features/interactions/presentation/controllers/interactions_controller.dart';
import 'package:app/features/moderation/domain/usecases/moderation_usecases.dart';
import 'package:app/features/moderation/infrastructure/datasources/moderation_datasource.dart';
import 'package:app/features/moderation/infrastructure/repositories/moderation_repository_impl.dart';
import 'package:app/features/moderation/presentation/controllers/moderation_controller.dart';
import 'package:app/features/notifications/domain/usecases/notification_usecases.dart';
import 'package:app/features/notifications/infrastructure/datasources/notification_datasource.dart';
import 'package:app/features/notifications/infrastructure/repositories/notification_repository_impl.dart';
import 'package:app/features/notifications/presentation/controllers/notifications_controller.dart';
import 'package:app/features/promotions/domain/usecases/promotion_usecases.dart';
import 'package:app/features/promotions/infrastructure/datasources/promo_local_datasource.dart';
import 'package:app/features/promotions/infrastructure/repositories/promotion_service_repository_adapter.dart';
import 'package:app/features/promotions/infrastructure/services/promo_service.dart';
import 'package:app/features/promotions/presentation/controllers/promotions_controller.dart';
import 'package:app/features/users/domain/usecases/user_usecases.dart';
import 'package:app/features/users/infrastructure/datasources/remote_user_datasource.dart';
import 'package:app/features/users/infrastructure/datasources/user_datasource.dart';
import 'package:app/features/users/infrastructure/repositories/user_repository_impl.dart';
import 'package:app/features/users/presentation/controllers/users_controller.dart';

class AppScope {
  static final SessionManager sessionManager = SessionManager();
  static final ApiClient apiClient = ApiClient.instance;
  static final PromoService promoService = PromoService(
    dataSource: PromoLocalDataSource(apiClient: ApiClient.instance),
  );

  static final PromoAuthUserDataSource authUserDataSource =
      PromoAuthUserDataSource(promoService);
  static final LocalAuthSessionDataSource authSessionDataSource =
      LocalAuthSessionDataSource(sessionManager);
  static final ApiRemoteLoginDataSource remoteLoginDataSource =
      ApiRemoteLoginDataSource(ApiClient.instance);

  static final AuthRepositoryImpl authRepository = AuthRepositoryImpl(
    userDataSource: authUserDataSource,
    sessionDataSource: authSessionDataSource,
    remoteLoginDataSource: remoteLoginDataSource,
  );

  static final AuthController authController = AuthController(
    loginUseCase: LoginUseCase(authRepository),
    registerUseCase: RegisterUseCase(authRepository),
    sendRecoveryCodeUseCase: SendRecoveryCodeUseCase(authRepository),
    verifyRecoveryCodeUseCase: VerifyRecoveryCodeUseCase(authRepository),
    resetPasswordUseCase: ResetPasswordUseCase(authRepository),
    logoutUseCase: LogoutUseCase(authRepository),
  );
  static final SettingsController settingsController = SettingsController(
    authController,
  );

  static final PromoCatalogDataSource catalogDataSource =
      PromoCatalogDataSource(promoService);
  static final CatalogRepositoryImpl catalogRepository = CatalogRepositoryImpl(
    catalogDataSource,
  );
  static final CatalogController catalogController = CatalogController(
    getCategoriasUseCase: GetCategoriasUseCase(catalogRepository),
    getTiposPromocionUseCase: GetTiposPromocionUseCase(catalogRepository),
    getCategoriaByIdUseCase: GetCategoriaByIdUseCase(catalogRepository),
    getTipoPromocionByIdUseCase: GetTipoPromocionByIdUseCase(catalogRepository),
    getCategoriaByIdSyncUseCase: GetCategoriaByIdSyncUseCase(catalogRepository),
    getCategoriaStyleUseCase: GetCategoriaStyleUseCase(catalogRepository),
  );

  static final PromoCommentDataSource commentsDataSource =
      PromoCommentDataSource(promoService);
  static final CommentRepositoryImpl commentsRepository = CommentRepositoryImpl(
    commentsDataSource,
  );
  static final CommentsController commentsController = CommentsController(
    getComentariosSyncUseCase: GetComentariosSyncUseCase(commentsRepository),
    getAllCommentsUseCase: GetAllCommentsUseCase(commentsRepository),
    getCommentsByPromotionUseCase: GetCommentsByPromotionUseCase(
      commentsRepository,
    ),
    addCommentUseCase: AddCommentUseCase(commentsRepository),
    deleteCommentUseCase: DeleteCommentUseCase(commentsRepository),
  );

  static final PromoInteractionDataSource interactionsDataSource =
      PromoInteractionDataSource(promoService);
  static final InteractionRepositoryImpl interactionsRepository =
      InteractionRepositoryImpl(interactionsDataSource);
  static final InteractionsController interactionsController =
      InteractionsController(
        getFavoritosByUsuarioSyncUseCase: GetFavoritosByUsuarioSyncUseCase(
          interactionsRepository,
        ),
        isFavoritoSyncUseCase: IsFavoritoSyncUseCase(interactionsRepository),
        getValoracionesByPromocionSyncUseCase:
            GetValoracionesByPromocionSyncUseCase(interactionsRepository),
        getAllValoracionesSyncUseCase: GetAllValoracionesSyncUseCase(
          interactionsRepository,
        ),
        getFavoritosByUsuarioUseCase: GetFavoritosByUsuarioUseCase(
          interactionsRepository,
        ),
        isFavoritoUseCase: IsFavoritoUseCase(interactionsRepository),
        toggleFavoritoUseCase: ToggleFavoritoUseCase(interactionsRepository),
        getValoracionesByPromocionUseCase: GetValoracionesByPromocionUseCase(
          interactionsRepository,
        ),
        countPositiveRatingsUseCase: CountPositiveRatingsUseCase(
          interactionsRepository,
        ),
        countNegativeRatingsUseCase: CountNegativeRatingsUseCase(
          interactionsRepository,
        ),
        addValoracionUseCase: AddValoracionUseCase(interactionsRepository),
        deleteValoracionUseCase: DeleteValoracionUseCase(
          interactionsRepository,
        ),
      );

  static final PromoModerationDataSource moderationDataSource =
      PromoModerationDataSource(promoService);
  static final ModerationRepositoryImpl moderationRepository =
      ModerationRepositoryImpl(moderationDataSource);
  static final ModerationController moderationController = ModerationController(
    getReportesSyncUseCase: GetReportesSyncUseCase(moderationRepository),
    getAllReportesUseCase: GetAllReportesUseCase(moderationRepository),
    getReportesByUsuarioUseCase: GetReportesByUsuarioUseCase(
      moderationRepository,
    ),
    getReportesByPromocionUseCase: GetReportesByPromocionUseCase(
      moderationRepository,
    ),
    addReporteUseCase: AddReporteUseCase(moderationRepository),
    updateReporteUseCase: UpdateReporteUseCase(moderationRepository),
    deleteReporteUseCase: DeleteReporteUseCase(moderationRepository),
  );

  static final PromoNotificationDataSource notificationsDataSource =
      PromoNotificationDataSource(promoService);
  static final NotificationRepositoryImpl notificationsRepository =
      NotificationRepositoryImpl(notificationsDataSource);
  static final NotificationsController notificationsController =
      NotificationsController(
        getAdminSummaryUseCase: GetAdminNotificationSummaryUseCase(
          notificationsRepository,
        ),
        getReportesBadgeCountUseCase: GetReportesBadgeCountUseCase(
          notificationsRepository,
        ),
      );

  static final PromotionServiceRepositoryAdapter promotionsRepository =
      PromotionServiceRepositoryAdapter(promoService);
  static final PromotionsController promotionsController = PromotionsController(
    getActivePromotionsUseCase: GetActivePromotionsUseCase(
      promotionsRepository,
    ),
    getPromotionByCodeUseCase: GetPromotionByCodeUseCase(promotionsRepository),
    createPromotionUseCase: CreatePromotionUseCase(promotionsRepository),
    updatePromotionUseCase: UpdatePromotionUseCase(promotionsRepository),
    deletePromotionUseCase: DeletePromotionUseCase(promotionsRepository),
    incrementPromotionViewsUseCase: IncrementPromotionViewsUseCase(
      promotionsRepository,
    ),
    getPromotionsByUserUseCase: GetPromotionsByUserUseCase(
      promotionsRepository,
    ),
    approvePromotionUseCase: ApprovePromotionUseCase(promotionsRepository),
    rejectPromotionUseCase: RejectPromotionUseCase(promotionsRepository),
    getPromotionsByCategoryUseCase: GetPromotionsByCategoryUseCase(
      promotionsRepository,
    ),
    getPromotionsBySupermarketUseCase: GetPromotionsBySupermarketUseCase(
      promotionsRepository,
    ),
    addPromocionHorarioUseCase: AddPromocionHorarioUseCase(
      promotionsRepository,
    ),
    savePromotionImageUseCase: SavePromotionImageUseCase(promotionsRepository),
    getPromotionImageBytesUseCase: GetPromotionImageBytesUseCase(
      promotionsRepository,
    ),
    addSupermercadoUseCase: AddSupermercadoUseCase(promotionsRepository),
    updateSupermercadoUseCase: UpdateSupermercadoUseCase(promotionsRepository),
    deleteSupermercadoUseCase: DeleteSupermercadoUseCase(promotionsRepository),
    reinitializeUseCase: ReinitializePromotionsUseCase(promotionsRepository),
    isLoadedUseCase: IsLoadedUseCase(promotionsRepository),
    getLoadErrorUseCase: GetLoadErrorUseCase(promotionsRepository),
    getActivePromotionsSyncUseCase: GetActivePromotionsSyncUseCase(
      promotionsRepository,
    ),
    getAllPromotionsSyncUseCase: GetAllPromotionsSyncUseCase(
      promotionsRepository,
    ),
    getPromotionByCodeSyncUseCase: GetPromotionByCodeSyncUseCase(
      promotionsRepository,
    ),
    getFlashDealsSyncUseCase: GetFlashDealsSyncUseCase(promotionsRepository),
    getNearbyStoresSyncUseCase: GetNearbyStoresSyncUseCase(
      promotionsRepository,
    ),
    getPromocionUrgencyUseCase: GetPromocionUrgencyUseCase(
      promotionsRepository,
    ),
    getPromocionesByUrgencySyncUseCase: GetPromocionesByUrgencySyncUseCase(
      promotionsRepository,
    ),
    getPromocionRatingSyncUseCase: GetPromocionRatingSyncUseCase(
      promotionsRepository,
    ),
    getPrecioConDescuentoUseCase: GetPrecioConDescuentoUseCase(
      promotionsRepository,
    ),
    getHorariosByCodigoUseCase: GetPromocionesHorariosByCodigoUseCase(
      promotionsRepository,
    ),
    getNextHorarioIdUseCase: GetNextHorarioIdUseCase(promotionsRepository),
    getSupermercadoSyncUseCase: GetSupermercadoSyncUseCase(
      promotionsRepository,
    ),
    getSupermercadosSyncUseCase: GetSupermercadosSyncUseCase(
      promotionsRepository,
    ),
    getCachedImageBytesUseCase: GetCachedImageBytesUseCase(
      promotionsRepository,
    ),
  );

  static final PromoUserDataSource usersDataSource = PromoUserDataSource(
    promoService,
  );
  static final ApiRemoteUserDataSource remoteUserDataSource =
      ApiRemoteUserDataSource(ApiClient.instance);
  static final UserRepositoryImpl usersRepository = UserRepositoryImpl(
    dataSource: usersDataSource,
    sessionManager: sessionManager,
    remoteDataSource: remoteUserDataSource,
  );
  static final UsersController usersController = UsersController(
    getUserByIdUseCase: GetUserByIdUseCase(usersRepository),
    getAllUsersUseCase: GetAllUsersUseCase(usersRepository),
    updateUserProfileUseCase: UpdateUserProfileUseCase(usersRepository),
    changePasswordUseCase: ChangePasswordUseCase(usersRepository),
    deactivateUserUseCase: DeactivateUserUseCase(usersRepository),
    getUsersByCityUseCase: GetUsersByCityUseCase(usersRepository),
    getUsersSyncUseCase: GetUsersSyncUseCase(usersRepository),
    getUserByIdSyncUseCase: GetUserByIdSyncUseCase(usersRepository),
    addUserUseCase: AddUserUseCase(usersRepository),
    deleteUserUseCase: DeleteUserUseCase(usersRepository),
  );

  static Future<void> bootstrap() async {
    await SessionManager.init();
    ApiClient.instance.setToken(sessionManager.token);
    await promoService.init();
  }
}

// Compatibilidad temporal: acceso global a controllers sin importar clases de infraestructura.
final sessionManager = AppScope.sessionManager;
final promoService = AppScope.promoService;
final authController = AppScope.authController;
final settingsController = AppScope.settingsController;
final usersController = AppScope.usersController;
final promotionsController = AppScope.promotionsController;
final catalogController = AppScope.catalogController;
final commentsController = AppScope.commentsController;
final interactionsController = AppScope.interactionsController;
final moderationController = AppScope.moderationController;
final notificationsController = AppScope.notificationsController;

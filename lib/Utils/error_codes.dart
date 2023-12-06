class ErrorCodes {
  static final String OPERATION_OK = 'E-000';
  static final String LOGIN_FAIL_NO_USER = 'E-001';
  static final String LOGIN_FAIL_PASSWORD_INCORRECT = 'E-002';
  static final String LOGIN_FAIL_USER_DEACTIVATED_DELETED = 'E-003';
  static final String LOGIN_FAIL_API_CONNECTION = 'E-004';
  static final String REGISTER_FAIL_USER_EXISTS = 'E-005';
  static final String REGISTER_FAIL_API_CONNECTION = 'E-006';
  static final String CREATE_ORDER_FAIL_BACKEND = 'E-007';
  static final String CREATE_ORDER_FAIL_API_CONNECTION = 'E-008';
  static final String UPDATE_NUM_ORDER_FOOD_ITEM_FAIL_BACKEND = 'E-009';
  static final String UPDATE_NUM_ORDER_FOOD_ITEM_FAIL_API_CONNECTION = 'E-010';
  static final String EDIT_ORDER_FAIL_BACKEND = 'E-011';
  static final String EDIT_ORDER_FAIL_API_CONNECTION = 'E-012';
  static final String DELETE_ORDER_FAIL_BACKEND = 'E=020';
  static final String DELETE_ORDER_FAIL_API_CONNECTION = 'E-021';
  static final String REDEEM_VOUCHER_FAIL_BACKEND = 'E-013';
  static final String REDEEM_VOUCHER_FAIL_API_CONNECTION = 'E-014';
  static final String UPDATE_VOUCHER_AVAILABLE_STATUS_FAIL_BACKEND = 'E-018';
  static final String UPDATE_VOUCHER_AVAILABLE_STATUS_FAIL_API_CONNECTION = 'E-019';
  static final String CHANGE_PASSWORD_FAIL_BACKEND = 'E-015';
  static final String CHANGE_PASSWORD_FAIL_API_CONNECTION = 'E-016';
  static final String OLD_PASSWORD_DOES_NOT_MATCH_DIALOG = 'E-017';
  static final String FORGOT_PASSWORD_INVALID_USER_FAIL_BACKEND = 'E-018';
  static final String FORGOT_PASSWORD_FAIL_API_CONNECTION = 'E-019';
}
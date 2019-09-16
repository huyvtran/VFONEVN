//
//  AppString.h
//  VoIPAPP
//
//  Created by OS on 9/3/19.
//  Copyright © 2019 OS. All rights reserved.
//

#ifndef AppString_h
#define AppString_h

#define SFM(format, ...) [NSString stringWithFormat:(format), ##__VA_ARGS__]
#define IS_IPHONE ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPhone" ] )
#define IS_IPOD   ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPod touch" ] )
#define IS_IOS7   ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

#define link_files_server   @"https://api.websudo.xyz"
#define cloudcall_bundle    @"com.nhanhoa.cloudcall"

#define SILENCE_RINGTONE    @"silence.mp3"
#define DEFAULT_RINGTONE    @"DEFAULT_RINGTONE"
#define key_sound_call      @"key_sound_call"

#define UserActivity        @"UserActivity"
#define UserActivityName    @"UserActivityName"

#define PBX_ID_CONTACT      @"PBX_ID_CONTACT"
#define PBX_SERVER          @"PBX_SERVER"
#define SIP_NUMBER          @"SIP_NUMBER"

#define keySyncPBX          @"keySyncPBX"
#define sort_group          @"sort_group"
#define sort_pbx            @"sort_pbx"
#define switch_dnd          @"switch_dnd"

#define ringtonesFolder     @"ringtones"
#define recordsFolderName   @"RecordsFiles"
#define logsFolderName      @"LogFiles"

#define TURN_OFF_ACC        @"TURN_OFF_ACC"
#define key_login           @"key_login"
#define key_password        @"key_password"
#define key_domain          @"key_domain"
#define key_port            @"key_port"

#define language_key        @"language_key"
#define key_en              @"en"
#define key_vi              @"vi"

#define type_phone_home     @"home"
#define type_phone_work     @"work"
#define type_phone_fax      @"fax"
#define type_phone_mobile   @"mobile"
#define type_phone_other    @"other"

#define text_mobile         @"Di động"
#define text_work           @"Công ty"
#define text_home           @"Nhà"
#define text_fax            @"Fax"
#define text_other          @"Khác"

#define USERNAME    ([[NSUserDefaults standardUserDefaults] objectForKey:key_login])
#define PASSWORD    ([[NSUserDefaults standardUserDefaults] objectForKey:key_password])
#define SIP_DOMAIN  ([[NSUserDefaults standardUserDefaults] objectForKey:key_domain])
#define SIP_PORT    ([[NSUserDefaults standardUserDefaults] objectForKey:key_port])

#define HelveticaNeue           @"HelveticaNeue"
#define HelveticaNeueBold       @"HelveticaNeue-Bold"
#define HelveticaNeueConBold    @"HelveticaNeue-CondensedBold"
#define HelveticaNeueItalic     @"HelveticaNeue-Italic"
#define HelveticaNeueLight      @"HelveticaNeue-Light"
#define HelveticaNeueThin       @"HelveticaNeue-Thin"

#define simulator       @"x86_64"
#define Iphone4s        @"iPhone4,1"
#define Iphone5_1       @"iPhone5,1"
#define Iphone5_2       @"iPhone5,2"
#define Iphone5c_1      @"iPhone5,3"
#define Iphone5c_2      @"iPhone5,4"
#define Iphone5s_1      @"iPhone6,1"
#define Iphone5s_2      @"iPhone6,2"
#define Iphone6         @"iPhone7,2"
#define Iphone6_Plus    @"iPhone7,1"
#define Iphone6s        @"iPhone8,1"
#define Iphone6s_Plus   @"iPhone8,2"
#define IphoneSE        @"iPhone8,4"
#define Iphone7_1       @"iPhone9,1"
#define Iphone7_2       @"iPhone9,3"
#define Iphone7_Plus1   @"iPhone9,2"
#define Iphone7_Plus2   @"iPhone9,4"
#define Iphone8_1       @"iPhone10,1"
#define Iphone8_2       @"iPhone10,4"
#define Iphone8_Plus1   @"iPhone10,2"
#define Iphone8_Plus2   @"iPhone10,5"
#define IphoneX_1       @"iPhone10,3"
#define IphoneX_2       @"iPhone10,6"
#define IphoneXR        @"iPhone11,8"
#define IphoneXS        @"iPhone11,2"
#define IphoneXS_Max1   @"iPhone11,6"
#define IphoneXS_Max2   @"iPhone11,4"

#define CALL_INV_STATE_NULL         @"PJSIP_INV_STATE_NULL"
#define CALL_INV_STATE_CALLING      @"PJSIP_INV_STATE_CALLING"
#define CALL_INV_STATE_INCOMING     @"PJSIP_INV_STATE_INCOMING"
#define CALL_INV_STATE_EARLY        @"PJSIP_INV_STATE_EARLY"
#define CALL_INV_STATE_CONNECTING   @"PJSIP_INV_STATE_CONNECTING"
#define CALL_INV_STATE_CONFIRMED    @"PJSIP_INV_STATE_CONFIRMED"
#define CALL_INV_STATE_DISCONNECTED @"PJSIP_INV_STATE_DISCONNECTED"

#define AUDIO_CALL_TYPE         1
#define VIDEO_CALL_TYPE         2

#define TAG_STAR_BUTTON         10
#define TAG_HASH_BUTTON         11

#define DAY_FOR_LOGS            7

#define AES_KEY                 @"App@123"
#define nameContactSyncPBX      @"VFONE.VN PBX"
#define nameSyncCompany         @"Nhan Hoa Software Company"

#define missed_call             @"Missed"
#define success_call            @"Success"
#define aborted_call            @"Aborted"
#define declined_call           @"Declined"
#define not_answer_call         @"NotAnswer"

#define incomming_call          @"Incomming"
#define outgoing_call           @"Outgoing"

#define text_calling            @"Đang gọi..."
#define text_ringing            @"Đang đổ chuông..."
#define text_user_busy          @"Người dùng đang bận"
#define text_terminated         @"Cuộc gọi kết thúc"
#define text_connected          @"Đã kết nối"
#define text_call_terminated    @"Cuộc gọi đã kết thúc"
#define text_user_busy          @"Người dùng đang bận"

#define text_speaker_is_on      @"Loa ngoài đã được bật"
#define text_speaker_is_off     @"Loa ngoài đã được tắt"
#define text_microphone_is_on   @"Microphone đã được bật"
#define text_microphone_is_off  @"Microphone đã được tắt"
#define text_failed             @"Thất bại!"

#define link_introduce          @"https://vfone.vn/about.html"
#define link_policy             @"https://vfone.vn/privacy.html"

#define link_api                @"https://api.vfone.vn:51100"
#define login_func              @"logininfo"
#define decryptRSA_func         @"decryptrsa"
#define get_didlist_func        @"getdidlist"
#define update_token_func       @"updatepushtoken"
#define get_contacts_func       @"getservercontacts"
#define GetServerGroup          @"getservergroup"
#define get_list_record_file    @"getlistrecordfile"
#define get_file_record         @"getfilerecord"

#define notifRegistrationStateChange    @"notifRegistrationStateChange"
#define notifCallStateChanged           @"notifCallStateChanged"
#define updateMissedCallBadge           @"updateMissedCallBadge"
#define networkChanged                  @"networkChanged"
#define reloadHistoryCall               @"reloadHistoryCall"
#define finishLoadContacts              @"finishLoadContacts"
#define searchContactWithValue          @"searchContactWithValue"
#define finishGetPBXContacts            @"finishGetPBXContacts"

#define GRAY_245 [UIColor colorWithRed:(245/255.0) green:(245/255.0) blue:(245/255.0) alpha:1.0]
#define GRAY_240 [UIColor colorWithRed:(240/255.0) green:(240/255.0) blue:(240/255.0) alpha:1.0]
#define GRAY_235 [UIColor colorWithRed:(235/255.0) green:(235/255.0) blue:(235/255.0) alpha:1.0]
#define GRAY_230 [UIColor colorWithRed:(230/255.0) green:(230/255.0) blue:(230/255.0) alpha:1.0]
#define GRAY_225 [UIColor colorWithRed:(225/255.0) green:(225/255.0) blue:(225/255.0) alpha:1.0]
#define GRAY_220 [UIColor colorWithRed:(220/255.0) green:(220/255.0) blue:(220/255.0) alpha:1.0]
#define GRAY_215 [UIColor colorWithRed:(215/255.0) green:(215/255.0) blue:(215/255.0) alpha:1.0]
#define GRAY_210 [UIColor colorWithRed:(210/255.0) green:(210/255.0) blue:(210/255.0) alpha:1.0]
#define GRAY_200 [UIColor colorWithRed:(200/255.0) green:(200/255.0) blue:(200/255.0) alpha:1.0]

#define ORANGE_COLOR        [UIColor colorWithRed:(249/255.0) green:(157/255.0) blue:(28/255.0) alpha:1.0]
#define BLUE_COLOR          [UIColor colorWithRed:(42/255.0) green:(122/255.0) blue:(219/255.0) alpha:1.0]
#define ProgressHUD_BG      [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2]

#define MENU_ACTIVE_COLOR   [UIColor colorWithRed:(50/255.0) green:(196/255.0) blue:(124/255.0) alpha:1.0]
#define MENU_DEFAULT_COLOR  [UIColor colorWithRed:(172/255.0) green:(185/255.0) blue:(202/255.0) alpha:1.0]

#define text_online             @"Sẵn sàng"
#define text_offline            @"Chưa kết nối"
#define text_connecting         @"Đang kết nối"
#define text_disabled           @"Không làm phiền"
#define text_no_network         @"Không internet"

#define text_menu_dialer        @"Bàn phím"
#define text_menu_history       @"Lịch sử"
#define text_menu_contacts      @"Danh bạ"
#define text_menu_more          @"Xem thêm"

#define text_choose_DID         @"Chọn số gọi ra"
#define text_default            @"Mặc định"
#define text_version            @"Phiên bản"
#define text_release_date       @"Ngày phát hành"
#define text_unknown            @"Không xác định"

#define hotline                 @"19006680"

#define pls_fill_full_info      @"Vui lòng nhập đầy đủ thông tin"
#define text_slogent            @"Dịch vụ tổng đài số hàng đầu Việt Nam.\nCung cấp dịch vụ thoại qua Internet tiên tiến nhất."
#define text_start              @"Bắt đầu"
#define text_welcome            @"Xin chào!\nĐăng nhập để trải nghiệm."
#define text_account            @"Tài khoản"
#define text_password           @"Mật khẩu"
#define text_sign_in            @"Đăng nhập"
#define text_cancel             @"Hủy bỏ"
#define text_scan_from_photo    @"QUÉT ẢNH CÓ SẴN"
#define cannot_access_camera    @"Không thể truy cập camera. Vui lòng kiểm tra lại quyền của ứng dụng!"
#define cannot_detect_QRCode    @"Không thể kiểm tra QRCode. Vui lòng kiểm tra lại!"
#define or_sign_in_with_QRCode  @"Hoặc đăng nhập với mã QR"
#define text_waiting            @"Vui lòng chờ..."
#define text_downloading        @"Đang tải..."
#define user_or_pass_is_wrong   @"Sai tên đăng nhập hoặc mật khẩu"
#define pls_check_signin_info   @"Vui lòng kiểm tra thông tin đăng nhập"
#define get_did_list_fail       @"Không thể lấy danh sách đầu số"
#define cant_make_call_yourself @"Không thể gọi cho chính bạn!"

#define text_do_not_disturb     @"Không làm phiền"
#define text_choose_ringtone    @"Chọn nhạc chuông"
#define text_call_settings      @"Cài đặt cuộc gọi"
#define text_app_info           @"Thông tin ứng dụng"
#define text_send_reports       @"Gửi reports"
#define text_sign_out           @"Đăng xuất"
#define text_privacy_policy     @"Chính sách bảo mật"
#define text_introduction       @"Giới thiệu"
#define text_on                 @"Bật"
#define text_off                @"Tắt"
#define text_close              @"Đóng"
#define text_setup              @"Cài đặt"
#define text_go_to_settings     @"Đi đến cài đặt"
#define text_silent             @"Im lặng"
#define text_hide               @"Ẩn"
#define text_check_for_update   @"Kiểm tra cập nhật"
#define text_update             @"Cập nhật"
#define text_newest_version     @"Bạn đang sử dụng phiên bản mới nhất.\nXin cảm ơn!"
#define text_send_logs          @"Gửi nhật ký ứng dụng"
#define text_send               @"Gửi"

#define search_name_or_phone    @"Tìm tên hoặc số điện thoại"
#define count_all_contacts      @"Tất cả liên hệ"
#define text_no_contacts        @"Không có liên hệ"
#define text_all_contacts       @"Danh bạ máy"
#define text_pbx_contacts       @"Nội bộ"
#define text_pbx_groups         @"Nhóm nội bộ"
#define text_company            @"Công ty"
#define text_email              @"Email"
#define text_sync_contacts      @"Đồng bộ"
#define text_successful         @"Thành công"
#define text_syncing_contacts   @"Đang đồng bộ danh bạ"

#define text_all_call           @"Tất cả"
#define text_missed_call        @"Gọi nhỡ"
#define text_record_call        @"Ghi âm"
#define text_no_calls           @"Không có cuộc gọi"
#define text_no_missed_calls    @"Không có cuộc gọi nhỡ"

#define text_today              @"Hôm nay"
#define text_yesterday          @"Hôm qua"
#define text_call_details       @"Chi tiết cuộc gọi"
#define text_hotline            @"Hotline"

#define text_delete             @"Xóa"
#define text_no                 @"Không"
#define text_yes                @"Có"

#define text_or                 @"hoặc"
#define text_and                @"và"
#define text_others             @"người khác"
#define text_sec                @"giây"
#define text_hours              @"giờ"
#define text_hour               @"giờ"
#define text_minutes            @"phút"
#define text_minute             @"phút"

#define text_start_date         @"Ngày bắt đầu"
#define text_end_date           @"Ngày kết thúc"
#define text_choose_time        @"Chọn thời gian"
#define text_search             @"Tìm kiếm"
#define text_saved_list         @"Danh sách đã lưu"
#define text_no_data            @"Chưa có dữ liệu"
#define text_choose             @"Chọn"
#define text_no_account         @"Không có tài khoản"
#define text_have_not_synced    @"Chưa đồng bộ"

#define pls_check_your_network_connection   @"Vui lòng kiểm tra kết nối mạng của bạn!"
#define pls_sign_in_to_make_call            @"Vui lòng đăng nhập để thực hiện cuộc gọi!"
#define can_not_make_call_at_this_time      @"Không thể thực hiện cuộc gọi vào lúc này"
#define phone_number_can_not_empty          @"Số điện thoại không được rỗng"
#define phone_number_is_invalid             @"Số điện thoại không hợp lệ"

#define text_can_not_send_email             @"Không thể gửi email. Vui lòng kiểm tra lại tài khoản email của bạn!"
#define text_can_not_send_email_check_later @"Không thể gửi email. Vui lòng thử lại sau!"
#define text_email_was_sent                 @"Email của bạn đã được gửi. Xin cảm ơn!"
#define do_you_want_to_delete_call_history  @"Bạn có muốn xoá lịch sử cuộc gọi này không?"
#define text_confirm_sign_out               @"Bạn có muốn đăng xuất hay không?"
#define text_can_not_signout_at_this_time   @"Đã có lỗi trong quá trình đăng xuất. Vui lòng thử lại!"
#define text_token_is_not_exists            @"Token không tồn tại. Vui lòng thử lại sau!"

#endif /* AppString_h */

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get navQueue => '队列';

  @override
  String get navCharacters => '角色';

  @override
  String get navSettings => '设置';

  @override
  String get retry => '重试';

  @override
  String nasUnavailable(String error) {
    return 'NAS 不可用：$error';
  }

  @override
  String get promptLabel => '物品提示词';

  @override
  String get categoriesLabel => '类别';

  @override
  String get catHelmet => '头盔';

  @override
  String get catBack => '翅膀／背部';

  @override
  String get catSword => '剑';

  @override
  String get catFront => '胸甲';

  @override
  String get catHat => '帽子';

  @override
  String get catHair => '头发（有风险）';

  @override
  String get styleLabel => '风格';

  @override
  String get collectionLabel => '系列';

  @override
  String get radialTitle => '环绕装饰';

  @override
  String get radialSubtitle => '放射对称 – 蛋糕、皇冠';

  @override
  String variantsPerCategory(int count) {
    return '每个类别的变体数：$count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '生成 $count 个物品',
    );
    return '$_temp0（约 $minutes 分钟）';
  }

  @override
  String composerSent(int sent) {
    return '已发送任务：$sent – Spark 正在生成（每件约 4 分钟，依次进行）';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return '已发送：$sent，错误：$errors';
  }

  @override
  String get queueEmpty => 'NAS 上还没有任何内容 – 请在 Composer 中发送一批。';

  @override
  String get stNew => '等待分拣';

  @override
  String get stRemeshing => '正在 TRELLIS 中重新计算（约 4 分钟）';

  @override
  String get stApproved => '排队等待转换';

  @override
  String get stConverting => '正在转换';

  @override
  String get stConverted => '已转换 – 等待 3D 审阅';

  @override
  String get stPacked => '已为 Studio 打包';

  @override
  String get stFailed => '失败';

  @override
  String get stRejected => '已拒绝';

  @override
  String get stRerolled => '已重新生成';

  @override
  String get tapFor3d => '点按查看 3D';

  @override
  String get pack => '打包';

  @override
  String sparkSection(int count) {
    return '正在 Spark 上制作（$count）';
  }

  @override
  String get sgQueued => '在队列中等待';

  @override
  String get sgConcept => '正在绘制概念图';

  @override
  String get sgCleanplate => '正在去除背景';

  @override
  String get sgMesh => '正在建 3D 模型（约 4 分钟）';

  @override
  String get sgPush => '正在发送到 NAS';

  @override
  String get sgDone => '完成';

  @override
  String get sgFailed => '失败';

  @override
  String get reviewTris => '三角面';

  @override
  String get reviewTexture => '纹理';

  @override
  String get reviewSymmetry => '对称';

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String seamVerts(String symmetry, int count) {
    return '$symmetry（接缝顶点：$count）';
  }

  @override
  String get reconvertAgain => '重新转换';

  @override
  String get reconvertSymmetry => '带对称重新转换';

  @override
  String get radialMenu => '环绕装饰（放射）';

  @override
  String get noSymmetry => '无对称';

  @override
  String get backToConcept => '返回概念图';

  @override
  String get show3d => '显示 3D 模型';

  @override
  String get rejectedToast => '已拒绝';

  @override
  String get rerollToast => '重新生成请求已发送到 Spark';

  @override
  String get approvedToast => '已批准 → 转换';

  @override
  String errorPrefix(String error) {
    return '错误：$error';
  }

  @override
  String get allSorted => '全部分拣完毕。要在 Composer 中发送新的一批吗？';

  @override
  String get newShort => '新建';

  @override
  String get charactersEmpty => '还没有角色。\n请从人形角色的照片或图片开始。';

  @override
  String get newCharacter => '新角色';

  @override
  String get creating => '正在创建…';

  @override
  String get generate => '生成';

  @override
  String get nameLabel => '名称';

  @override
  String get prepPhoto => '准备照片';

  @override
  String get prepPhotoHelp =>
      '去除背景；如果手臂贴在身体上，会把它们拉开成 A 字姿势；如果脚踝以下缺少腿部，会补全。没有这一步，肢体粘连时骨骼绑定经常失败。';

  @override
  String get animationsLabel => '动画';

  @override
  String libraryLoadFailed(String error) {
    return '无法加载资源库：$error';
  }

  @override
  String get libraryEmpty => '资源库为空。片段通过 NAS 上的 seed_animlib.py 脚本注册。';

  @override
  String get gallery => '相册';

  @override
  String get camera => '相机';

  @override
  String get characterFallback => '角色';

  @override
  String get downloadGlb => '下载 GLB';

  @override
  String get downloadFbx => '下载 FBX';

  @override
  String get downloadZip => '全部下载（ZIP）';

  @override
  String get sendRoblox => '发送到 Roblox';

  @override
  String get sendLuanti => '发送到 Luanti';

  @override
  String exportQueued(String target) {
    return '导出到 $target 已加入队列';
  }

  @override
  String get clipsTitle => '片段';

  @override
  String get exportsTitle => '导出';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step（第 $attempt 次尝试）';
  }

  @override
  String get retryStep => '重试此步骤';

  @override
  String stepOf(int step, int total) {
    return '第 $step 步，共 $total 步';
  }

  @override
  String get cfAccessHelp => '仅 ugc.ol1n.com 需要（不通过 Tailscale 访问时）。';

  @override
  String get saveAndTest => '保存并测试';

  @override
  String connOk(int count) {
    return '连接正常（已加载任务：$count）';
  }

  @override
  String connFailed(String error) {
    return '不可用：$error';
  }
}

/// The translations for Chinese, using the Han script (`zh_Hans`).
class AppLocalizationsZhHans extends AppLocalizationsZh {
  AppLocalizationsZhHans() : super('zh_Hans');

  @override
  String get navQueue => '队列';

  @override
  String get navCharacters => '角色';

  @override
  String get navSettings => '设置';

  @override
  String get retry => '重试';

  @override
  String nasUnavailable(String error) {
    return 'NAS 不可用：$error';
  }

  @override
  String get promptLabel => '物品提示词';

  @override
  String get categoriesLabel => '类别';

  @override
  String get catHelmet => '头盔';

  @override
  String get catBack => '翅膀／背部';

  @override
  String get catSword => '剑';

  @override
  String get catFront => '胸甲';

  @override
  String get catHat => '帽子';

  @override
  String get catHair => '头发（有风险）';

  @override
  String get styleLabel => '风格';

  @override
  String get collectionLabel => '系列';

  @override
  String get radialTitle => '环绕装饰';

  @override
  String get radialSubtitle => '放射对称 – 蛋糕、皇冠';

  @override
  String variantsPerCategory(int count) {
    return '每个类别的变体数：$count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '生成 $count 个物品',
    );
    return '$_temp0（约 $minutes 分钟）';
  }

  @override
  String composerSent(int sent) {
    return '已发送任务：$sent – Spark 正在生成（每件约 4 分钟，依次进行）';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return '已发送：$sent，错误：$errors';
  }

  @override
  String get queueEmpty => 'NAS 上还没有任何内容 – 请在 Composer 中发送一批。';

  @override
  String get stNew => '等待分拣';

  @override
  String get stRemeshing => '正在 TRELLIS 中重新计算（约 4 分钟）';

  @override
  String get stApproved => '排队等待转换';

  @override
  String get stConverting => '正在转换';

  @override
  String get stConverted => '已转换 – 等待 3D 审阅';

  @override
  String get stPacked => '已为 Studio 打包';

  @override
  String get stFailed => '失败';

  @override
  String get stRejected => '已拒绝';

  @override
  String get stRerolled => '已重新生成';

  @override
  String get tapFor3d => '点按查看 3D';

  @override
  String get pack => '打包';

  @override
  String sparkSection(int count) {
    return '正在 Spark 上制作（$count）';
  }

  @override
  String get sgQueued => '在队列中等待';

  @override
  String get sgConcept => '正在绘制概念图';

  @override
  String get sgCleanplate => '正在去除背景';

  @override
  String get sgMesh => '正在建 3D 模型（约 4 分钟）';

  @override
  String get sgPush => '正在发送到 NAS';

  @override
  String get sgDone => '完成';

  @override
  String get sgFailed => '失败';

  @override
  String get reviewTris => '三角面';

  @override
  String get reviewTexture => '纹理';

  @override
  String get reviewSymmetry => '对称';

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String seamVerts(String symmetry, int count) {
    return '$symmetry（接缝顶点：$count）';
  }

  @override
  String get reconvertAgain => '重新转换';

  @override
  String get reconvertSymmetry => '带对称重新转换';

  @override
  String get radialMenu => '环绕装饰（放射）';

  @override
  String get noSymmetry => '无对称';

  @override
  String get backToConcept => '返回概念图';

  @override
  String get show3d => '显示 3D 模型';

  @override
  String get rejectedToast => '已拒绝';

  @override
  String get rerollToast => '重新生成请求已发送到 Spark';

  @override
  String get approvedToast => '已批准 → 转换';

  @override
  String errorPrefix(String error) {
    return '错误：$error';
  }

  @override
  String get allSorted => '全部分拣完毕。要在 Composer 中发送新的一批吗？';

  @override
  String get newShort => '新建';

  @override
  String get charactersEmpty => '还没有角色。\n请从人形角色的照片或图片开始。';

  @override
  String get newCharacter => '新角色';

  @override
  String get creating => '正在创建…';

  @override
  String get generate => '生成';

  @override
  String get nameLabel => '名称';

  @override
  String get prepPhoto => '准备照片';

  @override
  String get prepPhotoHelp =>
      '去除背景；如果手臂贴在身体上，会把它们拉开成 A 字姿势；如果脚踝以下缺少腿部，会补全。没有这一步，肢体粘连时骨骼绑定经常失败。';

  @override
  String get animationsLabel => '动画';

  @override
  String libraryLoadFailed(String error) {
    return '无法加载资源库：$error';
  }

  @override
  String get libraryEmpty => '资源库为空。片段通过 NAS 上的 seed_animlib.py 脚本注册。';

  @override
  String get gallery => '相册';

  @override
  String get camera => '相机';

  @override
  String get characterFallback => '角色';

  @override
  String get downloadGlb => '下载 GLB';

  @override
  String get downloadFbx => '下载 FBX';

  @override
  String get downloadZip => '全部下载（ZIP）';

  @override
  String get sendRoblox => '发送到 Roblox';

  @override
  String get sendLuanti => '发送到 Luanti';

  @override
  String exportQueued(String target) {
    return '导出到 $target 已加入队列';
  }

  @override
  String get clipsTitle => '片段';

  @override
  String get exportsTitle => '导出';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step（第 $attempt 次尝试）';
  }

  @override
  String get retryStep => '重试此步骤';

  @override
  String stepOf(int step, int total) {
    return '第 $step 步，共 $total 步';
  }

  @override
  String get cfAccessHelp => '仅 ugc.ol1n.com 需要（不通过 Tailscale 访问时）。';

  @override
  String get saveAndTest => '保存并测试';

  @override
  String connOk(int count) {
    return '连接正常（已加载任务：$count）';
  }

  @override
  String connFailed(String error) {
    return '不可用：$error';
  }
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get navQueue => '佇列';

  @override
  String get navCharacters => '角色';

  @override
  String get navSettings => '設定';

  @override
  String get retry => '重試';

  @override
  String nasUnavailable(String error) {
    return 'NAS 無法使用：$error';
  }

  @override
  String get promptLabel => '物品提示詞';

  @override
  String get categoriesLabel => '類別';

  @override
  String get catHelmet => '頭盔';

  @override
  String get catBack => '翅膀／背部';

  @override
  String get catSword => '劍';

  @override
  String get catFront => '胸甲';

  @override
  String get catHat => '帽子';

  @override
  String get catHair => '頭髮（有風險）';

  @override
  String get styleLabel => '風格';

  @override
  String get collectionLabel => '系列';

  @override
  String get radialTitle => '環繞裝飾';

  @override
  String get radialSubtitle => '放射對稱 – 蛋糕、皇冠';

  @override
  String variantsPerCategory(int count) {
    return '每個類別的變體數：$count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '產生 $count 個物品',
    );
    return '$_temp0（約 $minutes 分鐘）';
  }

  @override
  String composerSent(int sent) {
    return '已傳送任務：$sent – Spark 正在產生（每件約 4 分鐘，依序進行）';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return '已傳送：$sent，錯誤：$errors';
  }

  @override
  String get queueEmpty => 'NAS 上還沒有任何內容 – 請在 Composer 中傳送一批。';

  @override
  String get stNew => '等待分揀';

  @override
  String get stRemeshing => '正在 TRELLIS 中重新計算（約 4 分鐘）';

  @override
  String get stApproved => '排隊等待轉換';

  @override
  String get stConverting => '正在轉換';

  @override
  String get stConverted => '已轉換 – 等待 3D 審閱';

  @override
  String get stPacked => '已為 Studio 打包';

  @override
  String get stFailed => '失敗';

  @override
  String get stRejected => '已拒絕';

  @override
  String get stRerolled => '已重新產生';

  @override
  String get tapFor3d => '點一下查看 3D';

  @override
  String get pack => '打包';

  @override
  String sparkSection(int count) {
    return '正在 Spark 上製作（$count）';
  }

  @override
  String get sgQueued => '在佇列中等待';

  @override
  String get sgConcept => '正在繪製概念圖';

  @override
  String get sgCleanplate => '正在去除背景';

  @override
  String get sgMesh => '正在建 3D 模型（約 4 分鐘）';

  @override
  String get sgPush => '正在傳送到 NAS';

  @override
  String get sgDone => '完成';

  @override
  String get sgFailed => '失敗';

  @override
  String get reviewTris => '三角面';

  @override
  String get reviewTexture => '紋理';

  @override
  String get reviewSymmetry => '對稱';

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String seamVerts(String symmetry, int count) {
    return '$symmetry（接縫頂點：$count）';
  }

  @override
  String get reconvertAgain => '重新轉換';

  @override
  String get reconvertSymmetry => '帶對稱重新轉換';

  @override
  String get radialMenu => '環繞裝飾（放射）';

  @override
  String get noSymmetry => '無對稱';

  @override
  String get backToConcept => '返回概念圖';

  @override
  String get show3d => '顯示 3D 模型';

  @override
  String get rejectedToast => '已拒絕';

  @override
  String get rerollToast => '重新產生請求已傳送到 Spark';

  @override
  String get approvedToast => '已核准 → 轉換';

  @override
  String errorPrefix(String error) {
    return '錯誤：$error';
  }

  @override
  String get allSorted => '全部分揀完畢。要在 Composer 中傳送新的一批嗎？';

  @override
  String get newShort => '新增';

  @override
  String get charactersEmpty => '還沒有角色。\n請從人形角色的照片或圖片開始。';

  @override
  String get newCharacter => '新角色';

  @override
  String get creating => '正在建立…';

  @override
  String get generate => '產生';

  @override
  String get nameLabel => '名稱';

  @override
  String get prepPhoto => '準備照片';

  @override
  String get prepPhotoHelp =>
      '去除背景；如果手臂貼在身體上，會把它們拉開成 A 字姿勢；如果腳踝以下缺少腿部，會補全。沒有這一步，肢體黏連時骨架綁定經常失敗。';

  @override
  String get animationsLabel => '動畫';

  @override
  String libraryLoadFailed(String error) {
    return '無法載入資源庫：$error';
  }

  @override
  String get libraryEmpty => '資源庫是空的。片段透過 NAS 上的 seed_animlib.py 指令碼註冊。';

  @override
  String get gallery => '相簿';

  @override
  String get camera => '相機';

  @override
  String get characterFallback => '角色';

  @override
  String get downloadGlb => '下載 GLB';

  @override
  String get downloadFbx => '下載 FBX';

  @override
  String get downloadZip => '全部下載（ZIP）';

  @override
  String get sendRoblox => '傳送到 Roblox';

  @override
  String get sendLuanti => '傳送到 Luanti';

  @override
  String exportQueued(String target) {
    return '匯出到 $target 已加入佇列';
  }

  @override
  String get clipsTitle => '片段';

  @override
  String get exportsTitle => '匯出';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step（第 $attempt 次嘗試）';
  }

  @override
  String get retryStep => '重試此步驟';

  @override
  String stepOf(int step, int total) {
    return '第 $step 步，共 $total 步';
  }

  @override
  String get cfAccessHelp => '僅 ugc.ol1n.com 需要（不透過 Tailscale 存取時）。';

  @override
  String get saveAndTest => '儲存並測試';

  @override
  String connOk(int count) {
    return '連線正常（已載入任務：$count）';
  }

  @override
  String connFailed(String error) {
    return '無法使用：$error';
  }
}

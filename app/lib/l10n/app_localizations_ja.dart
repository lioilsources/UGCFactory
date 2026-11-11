// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get navQueue => 'キュー';

  @override
  String get navCharacters => 'キャラクター';

  @override
  String get navSettings => '設定';

  @override
  String get retry => '再試行';

  @override
  String nasUnavailable(String error) {
    return 'NAS に接続できません：$error';
  }

  @override
  String get promptLabel => 'アイテムのプロンプト';

  @override
  String get categoriesLabel => 'カテゴリ';

  @override
  String get catHelmet => 'ヘルメット';

  @override
  String get catBack => '翼／背中';

  @override
  String get catSword => '剣';

  @override
  String get catFront => '胸当て';

  @override
  String get catHat => '帽子';

  @override
  String get catHair => '髪（リスクあり）';

  @override
  String get styleLabel => 'スタイル';

  @override
  String get collectionLabel => 'コレクション';

  @override
  String get radialTitle => '全周の装飾';

  @override
  String get radialSubtitle => '放射対称 – ケーキ、王冠';

  @override
  String variantsPerCategory(int count) {
    return 'カテゴリごとのバリエーション：$count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count個のアイテムを生成',
    );
    return '$_temp0（約$minutes分）';
  }

  @override
  String composerSent(int sent) {
    return '送信したジョブ：$sent – Spark が生成中（1つあたり約4分、順番に処理）';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return '送信：$sent、エラー：$errors';
  }

  @override
  String get queueEmpty => 'NAS にはまだ何もありません – Composer からバッチを送信してください。';

  @override
  String get stNew => 'トリアージ待ち';

  @override
  String get stRemeshing => 'TRELLIS で再計算中（約4分）';

  @override
  String get stApproved => '変換待ち';

  @override
  String get stConverting => '変換中';

  @override
  String get stConverted => '変換済み – 3D レビュー待ち';

  @override
  String get stPacked => 'Studio 用にパック済み';

  @override
  String get stFailed => '失敗';

  @override
  String get stRejected => '却下';

  @override
  String get stRerolled => '再生成済み';

  @override
  String get tapFor3d => 'タップで 3D 表示';

  @override
  String get pack => 'パック';

  @override
  String sparkSection(int count) {
    return 'Spark で作成中（$count）';
  }

  @override
  String get sgQueued => 'キューで待機中';

  @override
  String get sgConcept => 'コンセプトを描画中';

  @override
  String get sgCleanplate => '背景を除去中';

  @override
  String get sgMesh => '3D モデリング中（約4分）';

  @override
  String get sgPush => 'NAS へ送信中';

  @override
  String get sgDone => '完了';

  @override
  String get sgFailed => '失敗';

  @override
  String get reviewTris => '三角形';

  @override
  String get reviewTexture => 'テクスチャ';

  @override
  String get reviewSymmetry => '対称性';

  @override
  String get yes => 'はい';

  @override
  String get no => 'いいえ';

  @override
  String seamVerts(String symmetry, int count) {
    return '$symmetry（継ぎ目の頂点：$count）';
  }

  @override
  String get reconvertAgain => '再変換';

  @override
  String get reconvertSymmetry => '対称性を付けて再実行';

  @override
  String get radialMenu => '全周の装飾（放射）';

  @override
  String get noSymmetry => '対称性なし';

  @override
  String get backToConcept => 'コンセプトに戻る';

  @override
  String get show3d => '3D モデルを表示';

  @override
  String get rejectedToast => '却下しました';

  @override
  String get rerollToast => 'リロールを Spark に送信しました';

  @override
  String get approvedToast => '承認しました → 変換';

  @override
  String errorPrefix(String error) {
    return 'エラー：$error';
  }

  @override
  String get allSorted => 'すべて仕分け済みです。Composer から新しいバッチを送信しますか？';

  @override
  String get newShort => '新規';

  @override
  String get charactersEmpty => 'キャラクターはまだありません。\n人型キャラクターの写真か画像から始めましょう。';

  @override
  String get newCharacter => '新しいキャラクター';

  @override
  String get creating => '作成中…';

  @override
  String get generate => '生成';

  @override
  String get nameLabel => '名前';

  @override
  String get prepPhoto => '写真を準備';

  @override
  String get prepPhotoHelp =>
      '背景を除去します。腕が体にくっついている場合は A ポーズに離し、足首から下の脚が欠けている場合は補います。これがないと、手足がつながっているものではリグが失敗しやすくなります。';

  @override
  String get animationsLabel => 'アニメーション';

  @override
  String libraryLoadFailed(String error) {
    return 'ライブラリを読み込めませんでした：$error';
  }

  @override
  String get libraryEmpty =>
      'ライブラリは空です。クリップは NAS 上のスクリプト seed_animlib.py で登録します。';

  @override
  String get gallery => 'ギャラリー';

  @override
  String get camera => 'カメラ';

  @override
  String get characterFallback => 'キャラクター';

  @override
  String get downloadGlb => 'GLB をダウンロード';

  @override
  String get downloadFbx => 'FBX をダウンロード';

  @override
  String get downloadZip => 'すべてダウンロード（ZIP）';

  @override
  String get sendRoblox => 'Roblox に送信';

  @override
  String get sendLuanti => 'Luanti に送信';

  @override
  String exportQueued(String target) {
    return '$target へのエクスポートをキューに追加しました';
  }

  @override
  String get clipsTitle => 'クリップ';

  @override
  String get exportsTitle => 'エクスポート';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step（$attempt回目）';
  }

  @override
  String get retryStep => 'ステップを再試行';

  @override
  String stepOf(int step, int total) {
    return 'ステップ $step / $total';
  }

  @override
  String get cfAccessHelp => 'ugc.ol1n.com にのみ必要です（Tailscale を使わないアクセス）。';

  @override
  String get saveAndTest => '保存してテスト';

  @override
  String connOk(int count) {
    return '接続 OK（読み込んだジョブ：$count）';
  }

  @override
  String connFailed(String error) {
    return '利用できません：$error';
  }
}

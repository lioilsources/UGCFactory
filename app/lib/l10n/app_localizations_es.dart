// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get navQueue => 'Cola';

  @override
  String get navCharacters => 'Personajes';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get retry => 'Reintentar';

  @override
  String nasUnavailable(String error) {
    return 'NAS no disponible: $error';
  }

  @override
  String get promptLabel => 'Prompt del ítem';

  @override
  String get categoriesLabel => 'Categorías';

  @override
  String get catHelmet => 'Casco';

  @override
  String get catBack => 'Alas / espalda';

  @override
  String get catSword => 'Espada';

  @override
  String get catFront => 'Peto';

  @override
  String get catHat => 'Gorro';

  @override
  String get catHair => 'Pelo (riesgo)';

  @override
  String get styleLabel => 'Estilo';

  @override
  String get collectionLabel => 'Colección';

  @override
  String get radialTitle => 'Decoración envolvente';

  @override
  String get radialSubtitle => 'simetría radial: tartas, coronas';

  @override
  String variantsPerCategory(int count) {
    return 'Variantes por categoría: $count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Generar $count ítems',
      one: 'Generar $count ítem',
    );
    return '$_temp0 (~$minutes min)';
  }

  @override
  String composerSent(int sent) {
    return 'Tareas enviadas: $sent – Spark está generando (~4 min por pieza, de una en una)';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return 'Enviadas: $sent, errores: $errors';
  }

  @override
  String get queueEmpty =>
      'Aún no hay nada en el NAS: envía un lote desde el Composer.';

  @override
  String get stNew => 'Esperando el triaje';

  @override
  String get stRemeshing => 'Recalculándose en TRELLIS (~4 min)';

  @override
  String get stApproved => 'En cola para la conversión';

  @override
  String get stConverting => 'Convirtiendo';

  @override
  String get stConverted => 'Convertido: esperando la revisión 3D';

  @override
  String get stPacked => 'Empaquetado para Studio';

  @override
  String get stFailed => 'Fallido';

  @override
  String get stRejected => 'Rechazado';

  @override
  String get stRerolled => 'Regenerado';

  @override
  String get tapFor3d => 'toca para ver en 3D';

  @override
  String get pack => 'Empaquetar';

  @override
  String sparkSection(int count) {
    return 'Se está fabricando en Spark ($count)';
  }

  @override
  String get sgQueued => 'esperando en la cola';

  @override
  String get sgConcept => 'dibujando el concepto';

  @override
  String get sgCleanplate => 'quitando el fondo';

  @override
  String get sgMesh => 'modelando en 3D (~4 min)';

  @override
  String get sgPush => 'enviando al NAS';

  @override
  String get sgDone => 'listo';

  @override
  String get sgFailed => 'fallido';

  @override
  String get reviewTris => 'triángulos';

  @override
  String get reviewTexture => 'textura';

  @override
  String get reviewSymmetry => 'simetría';

  @override
  String get yes => 'sí';

  @override
  String get no => 'no';

  @override
  String seamVerts(String symmetry, int count) {
    return '$symmetry (vértices de costura: $count)';
  }

  @override
  String get reconvertAgain => 'Convertir de nuevo';

  @override
  String get reconvertSymmetry => 'De nuevo con simetría';

  @override
  String get radialMenu => 'Decoración envolvente (radial)';

  @override
  String get noSymmetry => 'Sin simetría';

  @override
  String get backToConcept => 'Volver al concepto';

  @override
  String get show3d => 'Mostrar el modelo 3D';

  @override
  String get rejectedToast => 'Rechazado';

  @override
  String get rerollToast => 'Reroll enviado a Spark';

  @override
  String get approvedToast => 'Aprobado → conversión';

  @override
  String errorPrefix(String error) {
    return 'Error: $error';
  }

  @override
  String get allSorted =>
      'Todo clasificado. ¿Enviar un lote nuevo desde el Composer?';

  @override
  String get newShort => 'Nuevo';

  @override
  String get charactersEmpty =>
      'Aún no hay ningún personaje.\nEmpieza con una foto o imagen de un personaje humanoide.';

  @override
  String get newCharacter => 'Personaje nuevo';

  @override
  String get creating => 'Creando…';

  @override
  String get generate => 'Generar';

  @override
  String get nameLabel => 'Nombre';

  @override
  String get prepPhoto => 'Preparar la foto';

  @override
  String get prepPhotoHelp =>
      'Quita el fondo; si los brazos están pegados al cuerpo, los separa a una A-pose, y si faltan las piernas por debajo de los tobillos, las completa. Sin esto el rig suele fallar con extremidades fusionadas.';

  @override
  String get animationsLabel => 'Animaciones';

  @override
  String libraryLoadFailed(String error) {
    return 'No se pudo cargar la biblioteca: $error';
  }

  @override
  String get libraryEmpty =>
      'La biblioteca está vacía. Los clips se registran con el script seed_animlib.py en el NAS.';

  @override
  String get gallery => 'Galería';

  @override
  String get camera => 'Cámara';

  @override
  String get characterFallback => 'Personaje';

  @override
  String get downloadGlb => 'Descargar GLB';

  @override
  String get downloadFbx => 'Descargar FBX';

  @override
  String get downloadZip => 'Descargar todo (ZIP)';

  @override
  String get sendRoblox => 'Enviar a Roblox';

  @override
  String get sendLuanti => 'Enviar a Luanti';

  @override
  String exportQueued(String target) {
    return 'Exportación a $target en cola';
  }

  @override
  String get clipsTitle => 'Clips';

  @override
  String get exportsTitle => 'Exportaciones';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step (intento $attempt)';
  }

  @override
  String get retryStep => 'Reintentar el paso';

  @override
  String stepOf(int step, int total) {
    return 'paso $step de $total';
  }

  @override
  String get cfAccessHelp =>
      'Solo hace falta para ugc.ol1n.com (acceso sin Tailscale).';

  @override
  String get saveAndTest => 'Guardar y probar';

  @override
  String connOk(int count) {
    return 'Conexión correcta (tareas cargadas: $count)';
  }

  @override
  String connFailed(String error) {
    return 'No disponible: $error';
  }
}

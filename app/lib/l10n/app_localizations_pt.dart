// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get navQueue => 'Fila';

  @override
  String get navCharacters => 'Personagens';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get retry => 'Tentar de novo';

  @override
  String nasUnavailable(String error) {
    return 'NAS indisponível: $error';
  }

  @override
  String get promptLabel => 'Prompt do item';

  @override
  String get categoriesLabel => 'Categorias';

  @override
  String get catHelmet => 'Capacete';

  @override
  String get catBack => 'Asas / costas';

  @override
  String get catSword => 'Espada';

  @override
  String get catFront => 'Peitoral';

  @override
  String get catHat => 'Gorro';

  @override
  String get catHair => 'Cabelo (arriscado)';

  @override
  String get styleLabel => 'Estilo';

  @override
  String get collectionLabel => 'Coleção';

  @override
  String get radialTitle => 'Ornamento ao redor';

  @override
  String get radialSubtitle => 'simetria radial – bolos, coroas';

  @override
  String variantsPerCategory(int count) {
    return 'Variantes por categoria: $count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Gerar $count itens',
      one: 'Gerar $count item',
    );
    return '$_temp0 (~$minutes min)';
  }

  @override
  String composerSent(int sent) {
    return 'Tarefas enviadas: $sent – o Spark está gerando (~4 min por peça, uma de cada vez)';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return 'Enviadas: $sent, erros: $errors';
  }

  @override
  String get queueEmpty =>
      'Ainda não há nada no NAS – envie um lote pelo Composer.';

  @override
  String get stNew => 'Aguardando triagem';

  @override
  String get stRemeshing => 'Sendo recalculado no TRELLIS (~4 min)';

  @override
  String get stApproved => 'Na fila para conversão';

  @override
  String get stConverting => 'Convertendo';

  @override
  String get stConverted => 'Convertido – aguardando revisão 3D';

  @override
  String get stPacked => 'Empacotado para o Studio';

  @override
  String get stFailed => 'Falhou';

  @override
  String get stRejected => 'Rejeitado';

  @override
  String get stRerolled => 'Gerado de novo';

  @override
  String get tapFor3d => 'toque para ver em 3D';

  @override
  String get pack => 'Empacotar';

  @override
  String sparkSection(int count) {
    return 'Sendo feito no Spark ($count)';
  }

  @override
  String get sgQueued => 'aguardando na fila';

  @override
  String get sgConcept => 'desenhando o conceito';

  @override
  String get sgCleanplate => 'removendo o fundo';

  @override
  String get sgMesh => 'modelando em 3D (~4 min)';

  @override
  String get sgPush => 'enviando ao NAS';

  @override
  String get sgDone => 'pronto';

  @override
  String get sgFailed => 'falhou';

  @override
  String get reviewTris => 'triângulos';

  @override
  String get reviewTexture => 'textura';

  @override
  String get reviewSymmetry => 'simetria';

  @override
  String get yes => 'sim';

  @override
  String get no => 'não';

  @override
  String seamVerts(String symmetry, int count) {
    return '$symmetry (vértices de costura: $count)';
  }

  @override
  String get reconvertAgain => 'Converter de novo';

  @override
  String get reconvertSymmetry => 'De novo com simetria';

  @override
  String get radialMenu => 'Ornamento ao redor (radial)';

  @override
  String get noSymmetry => 'Sem simetria';

  @override
  String get backToConcept => 'Voltar ao conceito';

  @override
  String get show3d => 'Mostrar o modelo 3D';

  @override
  String get rejectedToast => 'Rejeitado';

  @override
  String get rerollToast => 'Reroll enviado ao Spark';

  @override
  String get approvedToast => 'Aprovado → conversão';

  @override
  String errorPrefix(String error) {
    return 'Erro: $error';
  }

  @override
  String get allSorted => 'Tudo triado. Enviar um novo lote pelo Composer?';

  @override
  String get newShort => 'Novo';

  @override
  String get charactersEmpty =>
      'Ainda não há personagens.\nComece com uma foto ou imagem de um personagem humanoide.';

  @override
  String get newCharacter => 'Novo personagem';

  @override
  String get creating => 'Criando…';

  @override
  String get generate => 'Gerar';

  @override
  String get nameLabel => 'Nome';

  @override
  String get prepPhoto => 'Preparar a foto';

  @override
  String get prepPhotoHelp =>
      'Remove o fundo; se os braços estiverem colados ao corpo, afasta-os para uma A-pose, e se faltarem as pernas abaixo dos tornozelos, completa-as. Sem isso o rig costuma falhar com membros fundidos.';

  @override
  String get animationsLabel => 'Animações';

  @override
  String libraryLoadFailed(String error) {
    return 'Não foi possível carregar a biblioteca: $error';
  }

  @override
  String get libraryEmpty =>
      'A biblioteca está vazia. Os clipes são registrados com o script seed_animlib.py no NAS.';

  @override
  String get gallery => 'Galeria';

  @override
  String get camera => 'Câmera';

  @override
  String get characterFallback => 'Personagem';

  @override
  String get downloadGlb => 'Baixar GLB';

  @override
  String get downloadFbx => 'Baixar FBX';

  @override
  String get downloadZip => 'Baixar tudo (ZIP)';

  @override
  String get sendRoblox => 'Enviar ao Roblox';

  @override
  String get sendLuanti => 'Enviar ao Luanti';

  @override
  String exportQueued(String target) {
    return 'Exportação para $target colocada na fila';
  }

  @override
  String get clipsTitle => 'Clipes';

  @override
  String get exportsTitle => 'Exportações';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step (tentativa $attempt)';
  }

  @override
  String get retryStep => 'Tentar a etapa de novo';

  @override
  String stepOf(int step, int total) {
    return 'etapa $step de $total';
  }

  @override
  String get cfAccessHelp =>
      'Necessário só para ugc.ol1n.com (acesso sem Tailscale).';

  @override
  String get saveAndTest => 'Salvar e testar';

  @override
  String connOk(int count) {
    return 'Conexão OK (tarefas carregadas: $count)';
  }

  @override
  String connFailed(String error) {
    return 'Indisponível: $error';
  }
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String get navQueue => 'Fila';

  @override
  String get navCharacters => 'Personagens';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get retry => 'Tentar de novo';

  @override
  String nasUnavailable(String error) {
    return 'NAS indisponível: $error';
  }

  @override
  String get promptLabel => 'Prompt do item';

  @override
  String get categoriesLabel => 'Categorias';

  @override
  String get catHelmet => 'Capacete';

  @override
  String get catBack => 'Asas / costas';

  @override
  String get catSword => 'Espada';

  @override
  String get catFront => 'Peitoral';

  @override
  String get catHat => 'Gorro';

  @override
  String get catHair => 'Cabelo (arriscado)';

  @override
  String get styleLabel => 'Estilo';

  @override
  String get collectionLabel => 'Coleção';

  @override
  String get radialTitle => 'Ornamento ao redor';

  @override
  String get radialSubtitle => 'simetria radial – bolos, coroas';

  @override
  String variantsPerCategory(int count) {
    return 'Variantes por categoria: $count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Gerar $count itens',
      one: 'Gerar $count item',
    );
    return '$_temp0 (~$minutes min)';
  }

  @override
  String composerSent(int sent) {
    return 'Tarefas enviadas: $sent – o Spark está gerando (~4 min por peça, uma de cada vez)';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return 'Enviadas: $sent, erros: $errors';
  }

  @override
  String get queueEmpty =>
      'Ainda não há nada no NAS – envie um lote pelo Composer.';

  @override
  String get stNew => 'Aguardando triagem';

  @override
  String get stRemeshing => 'Sendo recalculado no TRELLIS (~4 min)';

  @override
  String get stApproved => 'Na fila para conversão';

  @override
  String get stConverting => 'Convertendo';

  @override
  String get stConverted => 'Convertido – aguardando revisão 3D';

  @override
  String get stPacked => 'Empacotado para o Studio';

  @override
  String get stFailed => 'Falhou';

  @override
  String get stRejected => 'Rejeitado';

  @override
  String get stRerolled => 'Gerado de novo';

  @override
  String get tapFor3d => 'toque para ver em 3D';

  @override
  String get pack => 'Empacotar';

  @override
  String sparkSection(int count) {
    return 'Sendo feito no Spark ($count)';
  }

  @override
  String get sgQueued => 'aguardando na fila';

  @override
  String get sgConcept => 'desenhando o conceito';

  @override
  String get sgCleanplate => 'removendo o fundo';

  @override
  String get sgMesh => 'modelando em 3D (~4 min)';

  @override
  String get sgPush => 'enviando ao NAS';

  @override
  String get sgDone => 'pronto';

  @override
  String get sgFailed => 'falhou';

  @override
  String get reviewTris => 'triângulos';

  @override
  String get reviewTexture => 'textura';

  @override
  String get reviewSymmetry => 'simetria';

  @override
  String get yes => 'sim';

  @override
  String get no => 'não';

  @override
  String seamVerts(String symmetry, int count) {
    return '$symmetry (vértices de costura: $count)';
  }

  @override
  String get reconvertAgain => 'Converter de novo';

  @override
  String get reconvertSymmetry => 'De novo com simetria';

  @override
  String get radialMenu => 'Ornamento ao redor (radial)';

  @override
  String get noSymmetry => 'Sem simetria';

  @override
  String get backToConcept => 'Voltar ao conceito';

  @override
  String get show3d => 'Mostrar o modelo 3D';

  @override
  String get rejectedToast => 'Rejeitado';

  @override
  String get rerollToast => 'Reroll enviado ao Spark';

  @override
  String get approvedToast => 'Aprovado → conversão';

  @override
  String errorPrefix(String error) {
    return 'Erro: $error';
  }

  @override
  String get allSorted => 'Tudo triado. Enviar um novo lote pelo Composer?';

  @override
  String get newShort => 'Novo';

  @override
  String get charactersEmpty =>
      'Ainda não há personagens.\nComece com uma foto ou imagem de um personagem humanoide.';

  @override
  String get newCharacter => 'Novo personagem';

  @override
  String get creating => 'Criando…';

  @override
  String get generate => 'Gerar';

  @override
  String get nameLabel => 'Nome';

  @override
  String get prepPhoto => 'Preparar a foto';

  @override
  String get prepPhotoHelp =>
      'Remove o fundo; se os braços estiverem colados ao corpo, afasta-os para uma A-pose, e se faltarem as pernas abaixo dos tornozelos, completa-as. Sem isso o rig costuma falhar com membros fundidos.';

  @override
  String get animationsLabel => 'Animações';

  @override
  String libraryLoadFailed(String error) {
    return 'Não foi possível carregar a biblioteca: $error';
  }

  @override
  String get libraryEmpty =>
      'A biblioteca está vazia. Os clipes são registrados com o script seed_animlib.py no NAS.';

  @override
  String get gallery => 'Galeria';

  @override
  String get camera => 'Câmera';

  @override
  String get characterFallback => 'Personagem';

  @override
  String get downloadGlb => 'Baixar GLB';

  @override
  String get downloadFbx => 'Baixar FBX';

  @override
  String get downloadZip => 'Baixar tudo (ZIP)';

  @override
  String get sendRoblox => 'Enviar ao Roblox';

  @override
  String get sendLuanti => 'Enviar ao Luanti';

  @override
  String exportQueued(String target) {
    return 'Exportação para $target colocada na fila';
  }

  @override
  String get clipsTitle => 'Clipes';

  @override
  String get exportsTitle => 'Exportações';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step (tentativa $attempt)';
  }

  @override
  String get retryStep => 'Tentar a etapa de novo';

  @override
  String stepOf(int step, int total) {
    return 'etapa $step de $total';
  }

  @override
  String get cfAccessHelp =>
      'Necessário só para ugc.ol1n.com (acesso sem Tailscale).';

  @override
  String get saveAndTest => 'Salvar e testar';

  @override
  String connOk(int count) {
    return 'Conexão OK (tarefas carregadas: $count)';
  }

  @override
  String connFailed(String error) {
    return 'Indisponível: $error';
  }
}

/// The translations for Portuguese, as used in Portugal (`pt_PT`).
class AppLocalizationsPtPt extends AppLocalizationsPt {
  AppLocalizationsPtPt() : super('pt_PT');

  @override
  String get navQueue => 'Fila';

  @override
  String get navCharacters => 'Personagens';

  @override
  String get navSettings => 'Definições';

  @override
  String get retry => 'Tentar novamente';

  @override
  String nasUnavailable(String error) {
    return 'NAS indisponível: $error';
  }

  @override
  String get promptLabel => 'Prompt do item';

  @override
  String get categoriesLabel => 'Categorias';

  @override
  String get catHelmet => 'Capacete';

  @override
  String get catBack => 'Asas / costas';

  @override
  String get catSword => 'Espada';

  @override
  String get catFront => 'Peitoral';

  @override
  String get catHat => 'Gorro';

  @override
  String get catHair => 'Cabelo (arriscado)';

  @override
  String get styleLabel => 'Estilo';

  @override
  String get collectionLabel => 'Coleção';

  @override
  String get radialTitle => 'Ornamento à volta';

  @override
  String get radialSubtitle => 'simetria radial – bolos, coroas';

  @override
  String variantsPerCategory(int count) {
    return 'Variantes por categoria: $count';
  }

  @override
  String generateItems(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Gerar $count itens',
      one: 'Gerar $count item',
    );
    return '$_temp0 (~$minutes min)';
  }

  @override
  String composerSent(int sent) {
    return 'Tarefas enviadas: $sent – o Spark está a gerar (~4 min por peça, uma de cada vez)';
  }

  @override
  String composerSentErrors(int sent, String errors) {
    return 'Enviadas: $sent, erros: $errors';
  }

  @override
  String get queueEmpty =>
      'Ainda não há nada no NAS – envie um lote a partir do Composer.';

  @override
  String get stNew => 'A aguardar triagem';

  @override
  String get stRemeshing => 'A ser recalculado no TRELLIS (~4 min)';

  @override
  String get stApproved => 'Na fila para conversão';

  @override
  String get stConverting => 'A converter';

  @override
  String get stConverted => 'Convertido – a aguardar revisão 3D';

  @override
  String get stPacked => 'Empacotado para o Studio';

  @override
  String get stFailed => 'Falhou';

  @override
  String get stRejected => 'Rejeitado';

  @override
  String get stRerolled => 'Gerado de novo';

  @override
  String get tapFor3d => 'toque para ver em 3D';

  @override
  String get pack => 'Empacotar';

  @override
  String sparkSection(int count) {
    return 'A ser feito no Spark ($count)';
  }

  @override
  String get sgQueued => 'a aguardar na fila';

  @override
  String get sgConcept => 'a desenhar o conceito';

  @override
  String get sgCleanplate => 'a remover o fundo';

  @override
  String get sgMesh => 'a modelar em 3D (~4 min)';

  @override
  String get sgPush => 'a enviar para o NAS';

  @override
  String get sgDone => 'concluído';

  @override
  String get sgFailed => 'falhou';

  @override
  String get reviewTris => 'triângulos';

  @override
  String get reviewTexture => 'textura';

  @override
  String get reviewSymmetry => 'simetria';

  @override
  String get yes => 'sim';

  @override
  String get no => 'não';

  @override
  String seamVerts(String symmetry, int count) {
    return '$symmetry (vértices de costura: $count)';
  }

  @override
  String get reconvertAgain => 'Converter novamente';

  @override
  String get reconvertSymmetry => 'Novamente com simetria';

  @override
  String get radialMenu => 'Ornamento à volta (radial)';

  @override
  String get noSymmetry => 'Sem simetria';

  @override
  String get backToConcept => 'Voltar ao conceito';

  @override
  String get show3d => 'Mostrar o modelo 3D';

  @override
  String get rejectedToast => 'Rejeitado';

  @override
  String get rerollToast => 'Reroll enviado para o Spark';

  @override
  String get approvedToast => 'Aprovado → conversão';

  @override
  String errorPrefix(String error) {
    return 'Erro: $error';
  }

  @override
  String get allSorted =>
      'Tudo triado. Enviar um novo lote a partir do Composer?';

  @override
  String get newShort => 'Nova';

  @override
  String get charactersEmpty =>
      'Ainda não há personagens.\nComece com uma foto ou imagem de uma personagem humanoide.';

  @override
  String get newCharacter => 'Nova personagem';

  @override
  String get creating => 'A criar…';

  @override
  String get generate => 'Gerar';

  @override
  String get nameLabel => 'Nome';

  @override
  String get prepPhoto => 'Preparar a foto';

  @override
  String get prepPhotoHelp =>
      'Remove o fundo; se os braços estiverem colados ao corpo, afasta-os para uma A-pose, e se faltarem as pernas abaixo dos tornozelos, completa-as. Sem isto o rig falha muitas vezes com membros fundidos.';

  @override
  String get animationsLabel => 'Animações';

  @override
  String libraryLoadFailed(String error) {
    return 'Não foi possível carregar a biblioteca: $error';
  }

  @override
  String get libraryEmpty =>
      'A biblioteca está vazia. Os clipes são registados com o script seed_animlib.py no NAS.';

  @override
  String get gallery => 'Galeria';

  @override
  String get camera => 'Câmara';

  @override
  String get characterFallback => 'Personagem';

  @override
  String get downloadGlb => 'Transferir GLB';

  @override
  String get downloadFbx => 'Transferir FBX';

  @override
  String get downloadZip => 'Transferir tudo (ZIP)';

  @override
  String get sendRoblox => 'Enviar para o Roblox';

  @override
  String get sendLuanti => 'Enviar para o Luanti';

  @override
  String exportQueued(String target) {
    return 'Exportação para $target colocada em fila';
  }

  @override
  String get clipsTitle => 'Clipes';

  @override
  String get exportsTitle => 'Exportações';

  @override
  String stepAttempt(String step, int attempt) {
    return '$step (tentativa $attempt)';
  }

  @override
  String get retryStep => 'Tentar o passo novamente';

  @override
  String stepOf(int step, int total) {
    return 'passo $step de $total';
  }

  @override
  String get cfAccessHelp =>
      'Necessário apenas para ugc.ol1n.com (acesso sem Tailscale).';

  @override
  String get saveAndTest => 'Guardar e testar';

  @override
  String connOk(int count) {
    return 'Ligação OK (tarefas carregadas: $count)';
  }

  @override
  String connFailed(String error) {
    return 'Indisponível: $error';
  }
}

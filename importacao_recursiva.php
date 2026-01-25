<?php
// Arquivo: importacao_recursiva.php
// Local: Raiz do projeto
// Função: Mapeamento com Regras Específicas (ASO, DOC., etc) + Arquivos Soltos

require 'backend/db_config.php';

// Configurações
set_time_limit(0); 
ini_set('memory_limit', '1024M');

// --- 1. CARREGA FUNCIONÁRIOS (Para o relatório de faltantes) ---
$stmtAll = $pdo->query("SELECT id, nome FROM funcionarios ORDER BY nome ASC");
$todosFuncionarios = $stmtAll->fetchAll(PDO::FETCH_ASSOC);
$idsEncontrados = [];

// --- 2. MAPA DE TRADUÇÃO (Aqui estão as suas regras) ---
function normalizarNomePasta($nomeOriginal) {
    // Converte para minúsculo para facilitar a comparação
    $nomeLower = mb_strtolower(trim($nomeOriginal), 'UTF-8');

    $mapa = [
        // REGRA: ASO -> Atestado
        'aso' => 'Atestado',
        'asos' => 'Atestado',
        'atestado' => 'Atestado',
        'atestados' => 'Atestado',
        
        // REGRA: Certidões e Doc. Admissionais -> Contrato
        'certidoes' => 'Contrato',
        'certidões' => 'Contrato',
        'doc. admissionais' => 'Contrato', // Com ponto
        'doc admissionais' => 'Contrato',  // Sem ponto (garantia)
        'docs admissionais' => 'Contrato',
        'documentos admissionais' => 'Contrato',
        'admissional' => 'Contrato',
        'contrato' => 'Contrato',
        'contratos' => 'Contrato',
        
        // REGRA: Doc. Pessoais -> Documentos Pessoais
        'doc. pessoais' => 'Documentos Pessoais', // Com ponto
        'doc pessoais' => 'Documentos Pessoais',  // Sem ponto
        'docs pessoais' => 'Documentos Pessoais',
        'documentos pessoais' => 'Documentos Pessoais',
        'documentos' => 'Documentos Pessoais',

        // Outros padrões comuns
        'holerite' => 'Holerites',
        'holerites' => 'Holerites',
        'recibo de pagamento' => 'Holerites',
        'ferias' => 'Férias',
        'férias' => 'Férias',
        'ponto' => 'Ponto',
        'folha de ponto' => 'Ponto',
        'treinamento' => 'Treinamento',
        'treinamentos' => 'Treinamento',
        'disciplinar' => 'Disciplinar',
        'sinistro' => 'Sinistro',
        'outros' => 'Outros'
    ];

    // Se o nome estiver na lista, retorna o traduzido. Se não, retorna o original.
    return $mapa[$nomeLower] ?? $nomeOriginal;
}

function corrigirEncoding($nome) {
    if (!mb_detect_encoding($nome, 'UTF-8', true)) {
        return mb_convert_encoding($nome, 'UTF-8', 'Windows-1252');
    }
    return $nome;
}

$ds = DIRECTORY_SEPARATOR;
$pastaUploads = __DIR__ . $ds . 'uploads' . $ds;

$totalArquivos = 0;
$pastasIgnoradas = [];

if (!is_dir($pastaUploads)) mkdir($pastaUploads, 0777, true);

// =================================================================================
// FUNÇÃO RECURSIVA PRINCIPAL
// =================================================================================
function processarPasta($caminhoFisicoAtual, $caminhoRelativoAtual, $pastaDbIdPai, $funcionarioId, $isRootLevel = false) {
    global $pdo, $totalArquivos, $ds;
    
    $itens = scandir($caminhoFisicoAtual);

    foreach ($itens as $item) {
        if ($item === '.' || $item === '..') continue;

        $caminhoItemFisico = $caminhoFisicoAtual . $ds . $item;
        $caminhoItemRelativo = $caminhoRelativoAtual . '/' . $item;
        $nomeReal = corrigirEncoding($item);
        
        // Aplica a tradução do nome da pasta
        $nomeParaBanco = normalizarNomePasta($nomeReal);

        if (is_dir($caminhoItemFisico)) {
            // --- É UMA PASTA ---
            
            // Verifica ou Cria a pasta no Banco (com o nome traduzido)
            $stmt = $pdo->prepare("SELECT id FROM pastas WHERE funcionario_id = ? AND parent_id = ? AND nome_pasta = ? LIMIT 1");
            $stmt->execute([$funcionarioId, $pastaDbIdPai, $nomeParaBanco]);
            $pastaDb = $stmt->fetch(PDO::FETCH_ASSOC);

            $idDessaPasta = null;

            if ($pastaDb) {
                $idDessaPasta = $pastaDb['id'];
            } else {
                $stmtInsert = $pdo->prepare("INSERT INTO pastas (funcionario_id, parent_id, nome_pasta) VALUES (?, ?, ?)");
                if ($stmtInsert->execute([$funcionarioId, $pastaDbIdPai, $nomeParaBanco])) {
                    $idDessaPasta = $pdo->lastInsertId();
                    
                    // Log para conferência
                    $msgExtra = ($nomeReal !== $nomeParaBanco) ? " <small>(Era: $nomeReal)</small>" : "";
                    echo "<div style='margin-left:20px; color:#d63384;'>📂 Pasta Mapeada: <b>$nomeParaBanco</b>$msgExtra</div>";
                }
            }

            // Entra na pasta (não é mais raiz)
            if ($idDessaPasta) {
                processarPasta($caminhoItemFisico, $caminhoItemRelativo, $idDessaPasta, $funcionarioId, false);
            }

        } elseif (is_file($caminhoItemFisico)) {
            // --- É UM ARQUIVO ---
            
            $pastaDestinoId = $pastaDbIdPai;
            $logMsg = "";

            // REGRA: Arquivos soltos na raiz vão para OUTROS
            if ($isRootLevel) {
                // Busca ID da pasta Outros
                $stmtOutros = $pdo->prepare("SELECT id FROM pastas WHERE funcionario_id = ? AND nome_pasta = 'Outros' LIMIT 1");
                $stmtOutros->execute([$funcionarioId]);
                $pastaOutros = $stmtOutros->fetch(PDO::FETCH_ASSOC);

                if ($pastaOutros) {
                    $pastaDestinoId = $pastaOutros['id'];
                    $logMsg = " -> <b>Enviado para Outros</b>";
                } else {
                    // Se não existir, cria
                    $pdo->prepare("INSERT INTO pastas (funcionario_id, parent_id, nome_pasta) VALUES (?, ?, 'Outros')")->execute([$funcionarioId, $pastaDbIdPai]);
                    $pastaDestinoId = $pdo->lastInsertId();
                    $logMsg = " -> <b>Enviado para Outros (Criada)</b>";
                }
            }

            $ext = strtolower(pathinfo($item, PATHINFO_EXTENSION));
            $permitidos = ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx', 'xls', 'xlsx', 'txt'];

            if (in_array($ext, $permitidos)) {
                $caminhoWeb = 'uploads/' . $caminhoItemRelativo;
                $mime = mime_content_type($caminhoItemFisico) ?: 'application/octet-stream';

                // Verifica duplicidade
                $check = $pdo->prepare("SELECT id FROM documentos WHERE pasta_id = ? AND caminho_arquivo = ?");
                $check->execute([$pastaDestinoId, $caminhoWeb]);
                
                if (!$check->fetch()) {
                    $stmtDoc = $pdo->prepare("INSERT INTO documentos (pasta_id, nome_original, caminho_arquivo, tipo_arquivo) VALUES (?, ?, ?, ?)");
                    if($stmtDoc->execute([$pastaDestinoId, $nomeReal, $caminhoWeb, $mime])) {
                        echo "<div style='margin-left:40px; color:green;'>✅ Arquivo: $nomeReal $logMsg</div>";
                        $totalArquivos++;
                    }
                }
            }
        }
    }
}

// =================================================================================
// EXECUÇÃO
// =================================================================================
echo "<body style='font-family:monospace; padding:20px; background:#f5f5f5;'>";
echo "<h1>🚀 Mapeamento com Regras Personalizadas</h1>";
echo "<ul>
        <li><b>ASO</b> → Atestado</li>
        <li><b>DOC. ADMISSIONAIS / CERTIDÕES</b> → Contrato</li>
        <li><b>DOC. PESSOAIS</b> → Documentos Pessoais</li>
        <li><b>Arquivos soltos</b> → Outros</li>
      </ul><hr>";

$itensNaRaiz = scandir($pastaUploads);

foreach ($itensNaRaiz as $nomeItem) {
    if ($nomeItem === '.' || $nomeItem === '..' || !is_dir($pastaUploads . $nomeItem)) continue;

    $nomeFunc = corrigirEncoding($nomeItem);
    echo "<hr><h3>👤 Verificando: $nomeFunc</h3>";

    $nomeBusca = trim($nomeFunc);
    $stmt = $pdo->prepare("SELECT id, nome FROM funcionarios WHERE nome LIKE ? LIMIT 1");
    $stmt->execute([$nomeBusca]); 
    $dadosFunc = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$dadosFunc) {
        $stmt->execute(["%" . $nomeBusca . "%"]);
        $dadosFunc = $stmt->fetch(PDO::FETCH_ASSOC);
    }

    if ($dadosFunc) {
        $funcId = $dadosFunc['id'];
        $idsEncontrados[] = $funcId;
        
        // Garante Raiz
        $stmtR = $pdo->prepare("SELECT id FROM pastas WHERE funcionario_id = ? AND parent_id IS NULL LIMIT 1");
        $stmtR->execute([$funcId]);
        $raizId = $stmtR->fetchColumn();

        if (!$raizId) {
            $pdo->prepare("INSERT INTO pastas (funcionario_id, parent_id, nome_pasta) VALUES (?, NULL, 'Raiz')")->execute([$funcId]);
            $raizId = $pdo->lastInsertId();
            // Garante pastas padrão essenciais
            $padroes = ['Atestado','Contrato','Disciplinar','Documentos Pessoais','Férias','Holerites','Ponto','Sinistro','Treinamento','Outros'];
            foreach($padroes as $p) {
                $pdo->prepare("INSERT INTO pastas (funcionario_id, parent_id, nome_pasta) VALUES (?, ?, ?)")->execute([$funcId, $raizId, $p]);
            }
        }

        // Processa (TRUE indica raiz para jogar arquivos soltos em Outros)
        processarPasta($pastaUploads . $nomeItem, $nomeItem, $raizId, $funcId, true);

    } else {
        echo "<b style='color:red'>❌ Pasta ignorada (Sem funcionário correspondente).</b>";
        $pastasIgnoradas[] = $nomeFunc;
    }
}

// =================================================================================
// RELATÓRIO FINAL
// =================================================================================
$funcionariosFaltantes = [];
foreach ($todosFuncionarios as $f) {
    if (!in_array($f['id'], $idsEncontrados)) {
        $funcionariosFaltantes[] = $f['nome'];
    }
}

echo "<hr><div style='background:#fff; border:2px solid #ccc; padding:20px; margin-top:20px;'>";
echo "<h2>📊 Relatório Final</h2>";
echo "<p>Total de Arquivos Mapeados: <b>$totalArquivos</b></p>";

if (!empty($pastasIgnoradas)) {
    echo "<h3 style='color:red'>⚠️ Pastas físicas sem dono:</h3><ul>";
    foreach ($pastasIgnoradas as $n) echo "<li style='color:red'>$n</li>";
    echo "</ul>";
}

if (!empty($funcionariosFaltantes)) {
    echo "<div style='background: #fff3cd; border: 1px solid #ffeeba; padding: 15px; margin-top: 15px;'>";
    echo "<h3 style='color: #856404; margin-top: 0;'>📂 Funcionários no Banco SEM Pasta (" . count($funcionariosFaltantes) . ")</h3>";
    echo "<ul style='columns: 2; font-size: 0.9em;'>";
    foreach ($funcionariosFaltantes as $nome) echo "<li style='color: #856404;'>$nome</li>";
    echo "</ul></div>";
} else {
    echo "<h3 style='color:green'>✅ Todos os funcionários do banco possuem pasta!</h3>";
}
echo "</div></body>";
?>
<?php
// backend/api.php - Versão Final (Segurança, Logs, Sem Backup)

define('RHID_BASE_URL', 'https://www.rhid.com.br/v2');
define('RHID_EMAIL', 'viniciusdesouza1906@gmail.com');
define('RHID_PASS', '12345');
define('RHID_DOMAIN', 'gsm_integracao');


session_start();

function callAPI($method, $url, $data = false, $token = null) {
        $curl = curl_init();
        $headers = ['Content-Type: application/json'];
        if ($token) {
            $headers[] = "Authorization: Bearer " . $token;
        }

        $opts = [
            CURLOPT_URL => $url,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_ENCODING => '',
            CURLOPT_MAXREDIRS => 10,
            CURLOPT_TIMEOUT => 30,
            CURLOPT_FOLLOWLOCATION => true,
            CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
            CURLOPT_CUSTOMREQUEST => $method,
            CURLOPT_HTTPHEADER => $headers,
        ];

        if ($data) {
            $opts[CURLOPT_POSTFIELDS] = json_encode($data);
        }

        curl_setopt_array($curl, $opts);
        $response = curl_exec($curl);
        $err = curl_error($curl);
        curl_close($curl);

        if ($err) {
            throw new Exception("Erro cURL: " . $err);
        }
        return json_decode($response, true);
    }

    // Função Auxiliar para chamadas RAW (Para baixar o arquivo de texto AFD)
    function callAPIRaw($method, $url, $token = null) {
        $curl = curl_init();
        $headers = [];
        if ($token) {
            $headers[] = "Authorization: Bearer " . $token;
        }

        $opts = [
            CURLOPT_URL => $url,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_ENCODING => '',
            CURLOPT_TIMEOUT => 60, // Tempo maior para download de arquivo
            CURLOPT_CUSTOMREQUEST => $method,
            CURLOPT_HTTPHEADER => $headers,
        ];

        curl_setopt_array($curl, $opts);
        $response = curl_exec($curl);
        $err = curl_error($curl);
        curl_close($curl);

        if ($err) {
            throw new Exception("Erro cURL Raw: " . $err);
        }
        return $response;
    }

// --- 1. CONFIGURAÇÃO DE ERROS E SEGURANÇA ---
set_error_handler(function($severity, $message, $file, $line) {
    if (!(error_reporting() & $severity)) return;
    throw new ErrorException($message, 0, $severity, $file, $line);
});

// Gera Token CSRF se não existir (para proteger formulários)
if (empty($_SESSION['csrf_token'])) {
    $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
}

try {
    ini_set('display_errors', 0); // Desativado para produção
    error_reporting(E_ALL);

    require 'db_config.php';
    header('Content-Type: application/json');

    $action = $_REQUEST['action'] ?? '';
    $public_routes = ['login', 'check_session', 'esqueci_senha'];

    // Verifica Sessão (Bloqueia acesso se não estiver logado)
    if (!in_array($action, $public_routes) && !isset($_SESSION['user_id'])) {
        http_response_code(401);
        echo json_encode(['success' => false, 'message' => 'Acesso não autorizado.']);
        exit();
    }

    // --- 2. PROTEÇÃO CSRF (Para todas as requisições POST) ---
    /*if ($_SERVER['REQUEST_METHOD'] === 'POST' && !in_array($action, ['login'])) {
        $headers = getallheaders();
        $token_enviado = $_POST['csrf_token'] ?? $headers['X-CSRF-Token'] ?? '';
        
        if (!hash_equals($_SESSION['csrf_token'], $token_enviado)) {
            http_response_code(403);
            echo json_encode(['success' => false, 'message' => 'Sessão expirada ou inválida (Erro CSRF). Recarregue a página.']);
            exit();
        }
    }*/

    // --- FUNÇÃO AUXILIAR: LOG DE AUDITORIA ---
    function registrarLog($pdo, $acao, $detalhes = '') {
        try {
            $stmt = $pdo->prepare("INSERT INTO logs (usuario_id, usuario_nome, acao, detalhes) VALUES (?, ?, ?, ?)");
            $stmt->execute([
                $_SESSION['user_id'] ?? 0,
                $_SESSION['user_nome'] ?? 'Sistema',
                $acao,
                $detalhes
            ]);
        } catch (Exception $e) {
            // Falha silenciosa no log para não travar o sistema principal
        }
    }

    switch ($action) {
        // --- AUTENTICAÇÃO ---
        case 'login':
            $email = $_POST['email'] ?? '';
            $senha = $_POST['senha'] ?? '';
            $stmt = $pdo->prepare("SELECT * FROM usuario WHERE email = ?");
            $stmt->execute([$email]);
            $usuario = $stmt->fetch();
            
            if ($usuario && password_verify($senha, $usuario['senha'])) {
                $_SESSION['user_id'] = $usuario['id'];
                $_SESSION['user_nome'] = $usuario['nome'];
                $_SESSION['csrf_token'] = bin2hex(random_bytes(32)); // Regenera token no login por segurança
                
                registrarLog($pdo, 'LOGIN', "Usuário {$usuario['nome']} realizou login.");
                echo json_encode(['success' => true, 'redirect_url' => 'index.php']);
            } else {
                echo json_encode(['success' => false, 'message' => 'E-mail ou senha inválidos.']);
            }
            break;

        case 'logout':
            registrarLog($pdo, 'LOGOUT', "Usuário saiu do sistema.");
            session_destroy();
            echo json_encode(['success' => true]);
            break;

        case 'check_session':
            if (isset($_SESSION['user_id'])) {
                echo json_encode([
                    'success' => true, 
                    'data' => ['nome' => $_SESSION['user_nome']],
                    'csrf_token' => $_SESSION['csrf_token'] // Envia token para o front
                ]);
            } else {
                echo json_encode(['success' => false]);
            }
            break;

        case 'esqueci_senha':
            // Simulação de envio de e-mail
            echo json_encode(['success' => true, 'message' => 'Funcionalidade simulada: Link enviado (Verifique logs do servidor).']);
            break;

        // --- GESTÃO DE FUNCIONÁRIOS (COM ESCALABILIDADE) ---
        
        // Nova rota paginada (Melhor para muitos registros)
        case 'get_funcionarios_paginated':
            try {
                $page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
                $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 20;
                $offset = ($page - 1) * $limit;
                
                $status = $_GET['status'] ?? 'ativo';
                $params = [$status];
                $where = "WHERE status = ?";
                
                // Filtros Server-Side
                if (!empty($_GET['nome'])) {
                    $where .= " AND nome LIKE ?";
                    $params[] = '%' . $_GET['nome'] . '%';
                }
                if (!empty($_GET['empresa']) && $_GET['empresa'] !== 'Todas') {
                    $where .= " AND empresa = ?";
                    $params[] = $_GET['empresa'];
                }
                if (!empty($_GET['unidade']) && $_GET['unidade'] !== 'Todos') {
                    $where .= " AND local = ?";
                    $params[] = $_GET['unidade'];
                }
                
                // Contagem
                $stmtCount = $pdo->prepare("SELECT COUNT(*) FROM funcionarios $where");
                $stmtCount->execute($params);
                $totalRecords = $stmtCount->fetchColumn();
                $totalPages = ceil($totalRecords / $limit);

                // Busca Paginada
                $sql = "SELECT * FROM funcionarios $where ORDER BY nome ASC LIMIT $limit OFFSET $offset";
                $stmt = $pdo->prepare($sql);
                $stmt->execute($params);
                $funcionarios = $stmt->fetchAll();

                echo json_encode([
                    'success' => true,
                    'data' => $funcionarios,
                    'pagination' => [
                        'current_page' => $page,
                        'total_pages' => $totalPages,
                        'total_records' => $totalRecords
                    ]
                ]);
            } catch (PDOException $e) {
                echo json_encode(['success' => false, 'message' => 'Erro: ' . $e->getMessage()]);
            }
            break;

        // Rota clássica (Carrega tudo - mantida para compatibilidade com seu JS atual)
        case 'get_all_funcionarios':
            try {
                $stmt = $pdo->query("SELECT * FROM funcionarios ORDER BY nome ASC");
                $funcionarios = $stmt->fetchAll();
                
                $response = ['ativos' => [], 'afastados' => [], 'inativos' => []];
                foreach ($funcionarios as $func) {
                    if ($func['status'] === 'ativo') $response['ativos'][] = $func;
                    elseif ($func['status'] === 'afastado') $response['afastados'][] = $func;
                    else $response['inativos'][] = $func;
                }
                echo json_encode(['success' => true, 'data' => $response]);
            } catch (PDOException $e) {
                echo json_encode(['success' => false, 'message' => 'Erro: ' . $e->getMessage()]);
            }
            break;

        case 'get_filtered_funcionarios':
             try {
                $status = $_GET['status'] ?? 'ativo';
                $base_sql = "SELECT * FROM funcionarios WHERE status = ?";
                $params = [$status];
        
                if (!empty($_GET['nome'])) { $base_sql .= " AND nome LIKE ?"; $params[] = '%' . $_GET['nome'] . '%'; }
                // Adicione outros filtros aqui conforme necessário

                $stmt = $pdo->prepare($base_sql);
                $stmt->execute($params);
                echo json_encode(['success' => true, 'data' => $stmt->fetchAll()]);
            } catch (PDOException $e) {
                echo json_encode(['success' => false, 'message' => $e->getMessage()]);
            }
            break;

        case 'get_funcionario':
            $id = $_GET['id'] ?? 0;
            $stmt = $pdo->prepare("SELECT * FROM funcionarios WHERE id = ?");
            $stmt->execute([$id]);
            echo json_encode(['success' => true, 'data' => $stmt->fetch()]);
            break;
        
        case 'add_funcionario':
            $pdo->beginTransaction();
            try {
                $dados = $_POST;
                unset($dados['action'], $dados['id'], $dados['csrf_token'], $dados['tem_filhos']); 
                
                // Lógica de datas admissão/demissão
                if (isset($dados['data_movimentacao'])) {
                    if ($dados['status'] !== 'inativo') {
                         $dados['data_admissao'] = $dados['data_movimentacao'];
                    } else {
                        $dados['data_demissao'] = $dados['data_movimentacao'];
                    }
                    unset($dados['data_movimentacao']);
                }
                
                // Construção dinâmica da query
                $colunas = []; $placeholders = []; $valores = [];
                foreach ($dados as $coluna => $valor) {
                    if ($valor !== '') {
                        $colunas[] = "`" . $coluna . "`"; 
                        $placeholders[] = "?"; 
                        $valores[] = $valor;
                    }
                }
                
                $sql = sprintf('INSERT INTO funcionarios (%s) VALUES (%s)', implode(', ', $colunas), implode(', ', $placeholders));
                $stmt = $pdo->prepare($sql);
                $stmt->execute($valores);
                
                $novo_id = $pdo->lastInsertId();

                // Criação automática de pastas
                $stmt_raiz = $pdo->prepare("INSERT INTO pastas (funcionario_id, nome_pasta) VALUES (?, 'Raiz')");
                $stmt_raiz->execute([$novo_id]);
                $id_raiz = $pdo->lastInsertId();

                $pastas = ["Atestado", "Contrato", "Disciplinar", "Documentos Pessoais", "Férias", "Holerites", "Ponto", "Sinistro", "Treinamento", "Outros"];
                $stmt_sub = $pdo->prepare("INSERT INTO pastas (funcionario_id, parent_id, nome_pasta) VALUES (?, ?, ?)");
                foreach ($pastas as $p) {
                    $stmt_sub->execute([$novo_id, $id_raiz, $p]);
                }

                registrarLog($pdo, 'ADD_FUNCIONARIO', "Adicionado ID: $novo_id - " . ($dados['nome'] ?? ''));
                $pdo->commit();
                echo json_encode(['success' => true, 'message' => 'Funcionário criado com sucesso!']);

            } catch (Exception $e) {
                $pdo->rollBack();
                echo json_encode(['success' => false, 'message' => 'Erro: ' . $e->getMessage()]);
            }
            break;

        case 'update_funcionario':
            try {
                $dados = $_POST;
                $id = $dados['id'];
                unset($dados['action'], $dados['id'], $dados['csrf_token'], $dados['tem_filhos']);

                if (isset($dados['data_movimentacao'])) {
                    if ($dados['status'] === 'inativo') { $dados['data_demissao'] = $dados['data_movimentacao']; }
                    else { $dados['data_admissao'] = $dados['data_movimentacao']; }
                    unset($dados['data_movimentacao']);
                }
                
                $set = []; $vals = [];
                foreach ($dados as $c => $v) {
                    $set[] = "`$c` = ?";
                    $vals[] = ($v === '') ? null : $v;
                }
                $vals[] = $id;

                if (count($set) > 0) {
                    $sql = sprintf('UPDATE funcionarios SET %s WHERE id = ?', implode(', ', $set));
                    $stmt = $pdo->prepare($sql);
                    $stmt->execute($vals);
                    
                    registrarLog($pdo, 'UPDATE_FUNCIONARIO', "ID: $id");
                    echo json_encode(['success' => true, 'message' => 'Atualizado com sucesso!']);
                } else {
                    echo json_encode(['success' => false, 'message' => 'Nada a atualizar.']);
                }
            } catch (PDOException $e) {
                echo json_encode(['success' => false, 'message' => 'Erro: ' . $e->getMessage()]);
            }
            break;

        case 'terminate_funcionario':
            $id = $_POST['id'] ?? 0;
            $data = $_POST['data_demissao'] ?? null;
            $motivo = $_POST['motivo_demissao'] ?? null;
            $recontrata = $_POST['elegivel_recontratacao'] ?? null;
            
            $stmt = $pdo->prepare("UPDATE funcionarios SET status = 'inativo', data_demissao = ?, motivo_demissao = ?, elegivel_recontratacao = ? WHERE id = ?");
            $success = $stmt->execute([$data, $motivo, $recontrata, $id]);
            
            registrarLog($pdo, 'ENCERRAR_CONTRATO', "ID: $id | Motivo: $motivo");
            echo json_encode(['success' => $success, 'message' => 'Contrato encerrado.']);
            break;
            
        case 'delete_funcionario':
            $id = $_POST['id'];
            $stmt = $pdo->prepare("DELETE FROM funcionarios WHERE id = ?");
            $success = $stmt->execute([$id]);
            registrarLog($pdo, 'EXCLUIR_FUNCIONARIO', "ID Removido: $id");
            echo json_encode(['success' => $success]);
            break;

        // --- GESTÃO DE ARQUIVOS E PASTAS ---
        case 'get_folder_id_by_name':
            $func_id = $_GET['funcionario_id'] ?? 0;
            $name = $_GET['folder_name'] ?? '';
            
            $stmt = $pdo->prepare("SELECT id FROM pastas WHERE funcionario_id = ? AND parent_id IS NULL");
            $stmt->execute([$func_id]);
            $raiz = $stmt->fetch();
            $raiz_id = $raiz ? $raiz['id'] : null;

            if (!$raiz_id) {
                $stmt = $pdo->prepare("INSERT INTO pastas (funcionario_id, nome_pasta) VALUES (?, 'Raiz')");
                $stmt->execute([$func_id]);
                $raiz_id = $pdo->lastInsertId();
            }
            
            $stmt = $pdo->prepare("SELECT id FROM pastas WHERE funcionario_id = ? AND nome_pasta = ? AND parent_id = ?");
            $stmt->execute([$func_id, $name, $raiz_id]);
            $pasta = $stmt->fetch();
            
            if (!$pasta) {
                $stmt = $pdo->prepare("INSERT INTO pastas (funcionario_id, parent_id, nome_pasta) VALUES (?, ?, ?)");
                $stmt->execute([$func_id, $raiz_id, $name]);
                echo json_encode(['success' => true, 'folder_id' => $pdo->lastInsertId()]);
            } else {
                echo json_encode(['success' => true, 'folder_id' => $pasta['id']]);
            }
            break;

        case 'listar_pastas_e_arquivos':
            $func_id = $_GET['funcionario_id'] ?? 0;
            $parent_id = isset($_GET['parent_id']) && $_GET['parent_id'] !== 'null' ? $_GET['parent_id'] : null;
            
            if ($parent_id === null) {
                $stmt = $pdo->prepare("SELECT id FROM pastas WHERE funcionario_id = ? AND parent_id IS NULL LIMIT 1");
                $stmt->execute([$func_id]);
                $raiz = $stmt->fetch();
                $parent_id = $raiz['id'] ?? null;
            }
            
            $resp = ['pastas' => [], 'documentos' => [], 'current_folder_id' => $parent_id];
            
            if ($parent_id) {
                $stmt = $pdo->prepare("SELECT * FROM pastas WHERE parent_id = ? ORDER BY nome_pasta ASC");
                $stmt->execute([$parent_id]);
                $resp['pastas'] = $stmt->fetchAll();

                $stmt = $pdo->prepare("SELECT * FROM documentos WHERE pasta_id = ? ORDER BY nome_original ASC");
                $stmt->execute([$parent_id]);
                $resp['documentos'] = $stmt->fetchAll();
            }
            echo json_encode(['success' => true, 'data' => $resp]);
            break;

        case 'criar_pasta':
            $func_id = $_POST['funcionario_id'];
            $parent_id = $_POST['parent_id'];
            $nome = trim($_POST['nome_pasta']);
            
            $stmt = $pdo->prepare("INSERT INTO pastas (funcionario_id, parent_id, nome_pasta) VALUES (?, ?, ?)");
            $success = $stmt->execute([$func_id, $parent_id, $nome]);
            registrarLog($pdo, 'CRIAR_PASTA', "Nome: $nome | FuncID: $func_id");
            echo json_encode(['success' => $success]);
            break;

        case 'rename_folder':
            $id = $_POST['pasta_id'];
            $nome = trim($_POST['novo_nome']);
            $stmt = $pdo->prepare("UPDATE pastas SET nome_pasta = ? WHERE id = ?");
            $success = $stmt->execute([$nome, $id]);
            registrarLog($pdo, 'RENOMEAR_PASTA', "ID: $id -> $nome");
            echo json_encode(['success' => $success]);
            break;

        // --- 4. UPLOAD COM VALIDAÇÃO DE SEGURANÇA (Whitelist) ---
        case 'upload_arquivo':
            $pasta_id = $_POST['pasta_id'] ?? 0;
            if (empty($pasta_id) || !isset($_FILES['arquivo']) || $_FILES['arquivo']['error'] !== UPLOAD_ERR_OK) {
                throw new Exception('Erro no envio do arquivo.');
            }

            $arquivo = $_FILES['arquivo'];
            $nome_orig = basename($arquivo['name']);
            $ext = strtolower(pathinfo($nome_orig, PATHINFO_EXTENSION));
            
            // LISTA BRANCA DE EXTENSÕES PERMITIDAS
            $permitidos = ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx', 'xls', 'xlsx', 'txt', 'csv'];
            if (!in_array($ext, $permitidos)) {
                echo json_encode(['success' => false, 'message' => 'Extensão de arquivo não permitida por segurança.']);
                exit;
            }

            $upload_dir = dirname(__DIR__) . '/uploads/';
            if (!is_dir($upload_dir)) mkdir($upload_dir, 0755, true);

            $nome_seguro = uniqid('doc_', true) . '.' . $ext;
            $destino = $upload_dir . $nome_seguro;
            $db_path = 'uploads/' . $nome_seguro;
            
            if (move_uploaded_file($arquivo['tmp_name'], $destino)) {
                $stmt = $pdo->prepare("INSERT INTO documentos (pasta_id, nome_original, caminho_arquivo, tipo_arquivo) VALUES (?, ?, ?, ?)");
                $stmt->execute([$pasta_id, $nome_orig, $db_path, $arquivo['type']]);
                
                registrarLog($pdo, 'UPLOAD', "Arquivo: $nome_orig (ID Pasta: $pasta_id)");
                echo json_encode(['success' => true]);
            } else {
                throw new Exception('Falha ao salvar arquivo no servidor.');
            }
            break;
        
        case 'excluir_pasta':
            $id = $_POST['pasta_id'];
            // Verifica se está vazia
            $stmt = $pdo->prepare("SELECT (SELECT COUNT(*) FROM pastas WHERE parent_id = ?) + (SELECT COUNT(*) FROM documentos WHERE pasta_id = ?)");
            $stmt->execute([$id, $id]);
            $count = $stmt->fetchColumn();

            if ($count == 0) {
                $stmt = $pdo->prepare("DELETE FROM pastas WHERE id = ?");
                $stmt->execute([$id]);
                registrarLog($pdo, 'EXCLUIR_PASTA', "ID: $id");
                echo json_encode(['success' => true]);
            } else {
                echo json_encode(['success' => false, 'message' => 'A pasta não está vazia.']);
            }
            break;
            
        case 'excluir_arquivo':
            $id = $_POST['documento_id'];
            $stmt = $pdo->prepare("SELECT caminho_arquivo, nome_original FROM documentos WHERE id = ?");
            $stmt->execute([$id]);
            $doc = $stmt->fetch();

            if ($doc) {
                $path = dirname(__DIR__) . '/' . $doc['caminho_arquivo'];
                $pdo->prepare("DELETE FROM documentos WHERE id = ?")->execute([$id]);
                if (file_exists($path)) unlink($path);
                
                registrarLog($pdo, 'EXCLUIR_ARQUIVO', "Arquivo: {$doc['nome_original']}");
                echo json_encode(['success' => true]);
            } else {
                echo json_encode(['success' => false, 'message' => 'Arquivo não encontrado.']);
            }
            break;

        // --- DASHBOARD E NOTIFICAÇÕES ---
        case 'get_status_diario':
            $data = $_GET['data'] ?? date('Y-m-d');
            $unidade = $_GET['unidade'] ?? 'Todos';
            $stmt = $pdo->prepare("SELECT * FROM status_diario WHERE data = ? AND unidade = ?");
            $stmt->execute([$data, $unidade]);
            echo json_encode(['success' => true, 'data' => $stmt->fetch() ?: null]);
            break;

        case 'save_status_diario':
            $data = $_POST['data'];
            $unidade = $_POST['unidade'];
            $sql = "INSERT INTO status_diario (data, unidade, presentes, ferias, atestado, afastados, folga, falta_injustificada)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                    ON DUPLICATE KEY UPDATE
                    presentes = VALUES(presentes), ferias = VALUES(ferias), atestado = VALUES(atestado), 
                    afastados = VALUES(afastados), folga = VALUES(folga), falta_injustificada = VALUES(falta_injustificada)";
            
            $stmt = $pdo->prepare($sql);
            $success = $stmt->execute([
                $data, $unidade, 
                $_POST['presentes'] ?? 0, $_POST['ferias'] ?? 0, $_POST['atestado'] ?? 0, 
                $_POST['afastados'] ?? 0, $_POST['folga'] ?? 0, $_POST['falta_injustificada'] ?? 0
            ]);
            registrarLog($pdo, 'DASHBOARD_SAVE', "$data - $unidade");
            echo json_encode(['success' => $success]);
            break;

        case 'get_notifications':
            try {
                $date30 = date('Y-m-d', strtotime('+30 days'));
                $date10 = date('Y-m-d', strtotime('+10 days'));
                
                // Query unificada de vencimentos
                $sql = "
                    (SELECT id, nome, 'CNH' as tipo, validade_cnh as data_evento FROM funcionarios WHERE status = 'ativo' AND validade_cnh IS NOT NULL AND validade_cnh <= ?)
                    UNION ALL
                    (SELECT id, nome, 'Exame Clínico' as tipo, validade_exame_clinico as data_evento FROM funcionarios WHERE status = 'ativo' AND validade_exame_clinico IS NOT NULL AND validade_exame_clinico <= ?)
                    UNION ALL
                    (SELECT id, nome, 'Audiometria' as tipo, validade_audiometria as data_evento FROM funcionarios WHERE status = 'ativo' AND validade_audiometria IS NOT NULL AND validade_audiometria <= ?)
                    UNION ALL
                    (SELECT id, nome, 'Contrato de Exp.' as tipo, validade_contrato_experiencia as data_evento FROM funcionarios WHERE status = 'ativo' AND validade_contrato_experiencia IS NOT NULL AND validade_contrato_experiencia <= ?)
                    ORDER BY data_evento ASC
                "; 

                $params = array_fill(0, 3, $date30);
                $params[] = $date10;
                
                $stmt = $pdo->prepare($sql);
                $stmt->execute($params);
                $vencimentos = $stmt->fetchAll();

                // Query de Aniversários
                $hoje = date('m-d');
                $futuro = date('m-d', strtotime('+30 days'));
                $sql_niver = "SELECT id, nome, 'Aniversário' as tipo, data_nascimento as data_evento FROM funcionarios WHERE status = 'ativo' AND data_nascimento IS NOT NULL";
                if ($hoje <= $futuro) {
                    $sql_niver .= " AND DATE_FORMAT(data_nascimento, '%m-%d') BETWEEN ? AND ?";
                    $params_niver = [$hoje, $futuro];
                } else {
                    $sql_niver .= " AND (DATE_FORMAT(data_nascimento, '%m-%d') >= ? OR DATE_FORMAT(data_nascimento, '%m-%d') <= ?)";
                    $params_niver = [$hoje, $futuro];
                }
                $stmt_niver = $pdo->prepare($sql_niver);
                $stmt_niver->execute($params_niver);

                echo json_encode(['success' => true, 'data' => [
                    'vencimentos' => $vencimentos, 
                    'datas_importantes' => $stmt_niver->fetchAll()
                ]]);

            } catch (PDOException $e) {
                echo json_encode(['success' => false, 'message' => $e->getMessage()]);
            }
            break;

            case 'sync_rhid':
                try {
                    $dataRef = $_POST['data'] ?? date('Y-m-d');
                    $filtroUnidade = $_POST['unidade'] ?? '';
                    $filtroEmpresa = $_POST['empresa'] ?? '';

                    // Data no formato da API (YYYYMMDD)
                    $dataApi = date('Ymd', strtotime($dataRef));

                    // 1. Login
                    $loginData = ["email" => RHID_EMAIL, "password" => RHID_PASS, "domain" => RHID_DOMAIN];
                    $authResponse = callAPI('POST', RHID_BASE_URL . '/login.svc/', $loginData);
                    
                    if (!isset($authResponse['accessToken'])) {
                        throw new Exception("Falha na autenticação Control iD.");
                    }
                    $token = $authResponse['accessToken'];

                    // 2. Mapeamento de PIS e ID para CPF
                    // Baixa lista de funcionários ativos para cruzar os dados
                    $rhidEmployeesResponse = callAPI('GET', RHID_BASE_URL . '/customerdb/person.svc/a_status/ativo?limit=5000', false, $token);
                    
                    $mapPisToCpf = []; // PIS -> CPF
                    $mapIdToCpf = [];  // ID -> CPF

                    if (isset($rhidEmployeesResponse['data'])) {
                        foreach ($rhidEmployeesResponse['data'] as $p) {
                            $cleanCpf = preg_replace('/[^0-9]/', '', $p['cpf'] ?? '');
                            $cleanPis = preg_replace('/[^0-9]/', '', $p['pis'] ?? '');
                            
                            if ($cleanPis) $mapPisToCpf[$cleanPis] = $cleanCpf;
                            if ($p['id']) $mapIdToCpf[$p['id']] = $cleanCpf;
                        }
                    }

                    // 3. Buscar AFD (Arquivo Fonte de Dados)
                    // Pega as batidas reais do dia selecionado
                    $urlAfd = RHID_BASE_URL . "/report.svc/exporta_arquivo/?tipo=afd&ini=$dataApi&fim=$dataApi";
                    $afdContent = callAPIRaw('POST', $urlAfd, $token);
                    
                    $cpfsComBatida = [];

                    if ($afdContent) {
                        $linhas = explode("\n", $afdContent);
                        foreach ($linhas as $linha) {
                            $linha = trim($linha);
                            // Registro tipo '3' = Marcação de Ponto (Portaria 1510)
                            if (substr($linha, 0, 1) === '3') {
                                // PIS está na posição 23 (index 22) com tamanho 12
                                $pisNaBatida = substr($linha, 22, 12);
                                
                                if (isset($mapPisToCpf[$pisNaBatida])) {
                                    $cpf = $mapPisToCpf[$pisNaBatida];
                                    if ($cpf) $cpfsComBatida[] = $cpf;
                                }
                            }
                        }
                    }
                    $cpfsComBatida = array_unique($cpfsComBatida);

                    // 4. Buscar Justificativas
                    $justData = ["ini" => $dataApi, "fim" => $dataApi, "limit" => 5000];
                    $justificativasResponse = callAPI('POST', RHID_BASE_URL . '/customerdb/justification.svc/list', $justData, $token);
                    
                    $cpfsJustificativas = []; 
                    if (isset($justificativasResponse['data'])) {
                        foreach ($justificativasResponse['data'] as $just) {
                            $rId = $just['idPerson'];
                            if (isset($mapIdToCpf[$rId])) {
                                $cpfsJustificativas[$mapIdToCpf[$rId]] = $just['idJustificationType'];
                            }
                        }
                    }

                    // 5. Cruzar com Banco de Dados Local
                    $sqlLocal = "SELECT * FROM funcionarios WHERE status = 'ativo'";
                    $paramsLocal = [];
                    // Filtros de Unidade e Empresa do Dashboard
                    if ($filtroUnidade && $filtroUnidade !== 'Todos' && $filtroUnidade !== 'Todas as Unidades') {
                        $sqlLocal .= " AND local = ?";
                        $paramsLocal[] = $filtroUnidade;
                    }
                    if ($filtroEmpresa && $filtroEmpresa !== 'Todos' && $filtroEmpresa !== 'Todas as Empresas') {
                        $sqlLocal .= " AND empresa = ?";
                        $paramsLocal[] = $filtroEmpresa;
                    }
                    
                    $stmtLocal = $pdo->prepare($sqlLocal);
                    $stmtLocal->execute($paramsLocal);
                    $funcionariosLocais = $stmtLocal->fetchAll();

                    // 6. Calcular Estatísticas Finais
                    $stats = [
                        'presentes' => 0,
                        'faltas' => 0,
                        'afastados' => 0,
                        'folga' => 0,
                        'ferias' => 0,
                        'atestado' => 0
                    ];

                    foreach ($funcionariosLocais as $func) {
                        $cpf = preg_replace('/[^0-9]/', '', $func['cpf']); 
                        
                        $temBatida = in_array($cpf, $cpfsComBatida);
                        $justificativaType = $cpfsJustificativas[$cpf] ?? null;

                        if ($temBatida) {
                            $stats['presentes']++;
                        } elseif ($justificativaType) {
                            // IDs baseados na documentação padrão RHiD
                            if ($justificativaType == 4) { $stats['ferias']++; }
                            elseif ($justificativaType == 5) { $stats['atestado']++; }
                            elseif ($justificativaType == 6 || $justificativaType == 7) { $stats['afastados']++; }
                            elseif ($justificativaType == 11) { $stats['folga']++; }
                            else { $stats['folga']++; } // Outras justificativas (banco de horas, etc)
                        } else {
                            // Se não tem batida e não tem justificativa
                            $diaSemana = date('w', strtotime($dataRef));
                            // Fim de semana (Dom=0, Sab=6) não conta falta se não tiver batida
                            if ($diaSemana != 0 && $diaSemana != 6) { 
                                $stats['faltas']++; 
                            } else {
                                $stats['folga']++;
                            }
                        }
                    }

                    echo json_encode([
                        'success' => true, 
                        'data' => $stats,
                        'message' => 'Sincronização realizada com sucesso!'
                    ]);

                } catch (Exception $e) {
                    echo json_encode(['success' => false, 'message' => 'Erro na sincronização: ' . $e->getMessage()]);
                }
            break;

        default:
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Ação desconhecida.']);
            break;
    }

} catch (Throwable $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Erro interno: ' . $e->getMessage()
    ]);
}
?>

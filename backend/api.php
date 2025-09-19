<?php
    // backend/api.php - Versão Final com Sistema de Login Completo

    session_start();

    ini_set('display_errors', 1);
    error_reporting(E_ALL);

    require 'db_config.php';
    header('Content-Type: application/json');
    $action = $_REQUEST['action'] ?? '';

    $public_routes = ['login', 'check_session', 'esqueci_senha'];

    if (!in_array($action, $public_routes) && !isset($_SESSION['user_id'])) {
        http_response_code(401);
        echo json_encode(['success' => false, 'message' => 'Acesso não autorizado.']);
        exit();
    }

    switch ($action) {
        case 'login':
            $email = $_POST['email'] ?? '';
            $senha = $_POST['senha'] ?? '';
            $stmt = $pdo->prepare("SELECT * FROM usuario WHERE email = ?");
            $stmt->execute([$email]);
            $usuario = $stmt->fetch();
            if ($usuario && password_verify($senha, $usuario['senha'])) {
                $_SESSION['user_id'] = $usuario['id'];
                $_SESSION['user_nome'] = $usuario['nome'];
                echo json_encode(['success' => true]);
            } else {
                echo json_encode(['success' => false, 'message' => 'E-mail ou senha inválidos.']);
            }
            break;

        case 'logout':
            session_destroy();
            echo json_encode(['success' => true]);
            break;

        case 'check_session':
            if (isset($_SESSION['user_id'])) {
                echo json_encode(['success' => true, 'data' => ['nome' => $_SESSION['user_nome']]]);
            } else {
                echo json_encode(['success' => false]);
            }
            break;

        case 'esqueci_senha':
            // A lógica de envio de e-mail não funcionará em localhost sem configuração.
            // Este código está preparado para um servidor real.
            echo json_encode(['success' => true, 'message' => 'Se o e-mail existir, um link de recuperação foi enviado. (Funcionalidade de envio de e-mail desativada em ambiente local)']);
            break;

    case 'get_all_funcionarios':
        try {
            $stmt = $pdo->query("SELECT * FROM funcionarios ORDER BY nome ASC");
            $funcionarios = $stmt->fetchAll();
            $response = ['ativos' => [], 'inativos' => []];
            foreach ($funcionarios as $func) {
                if ($func['status'] === 'ativo') {
                    $response['ativos'][] = $func;
                } else {
                    $response['inativos'][] = $func;
                }
            }
            echo json_encode(['success' => true, 'data' => $response]);
        } catch (PDOException $e) {
            echo json_encode(['success' => false, 'message' => 'Erro ao buscar funcionários: ' . $e->getMessage()]);
        }
        break;

    case 'get_filtered_funcionarios':
        try {
            $status = $_GET['status'] ?? 'ativo';
            $base_sql = "SELECT * FROM funcionarios WHERE status = ?";
            $params = [$status];
    
            if (!empty($_GET['nome'])) {
                $base_sql .= " AND nome LIKE ?";
                $params[] = '%' . $_GET['nome'] . '%';
            }
            if (!empty($_GET['unidade']) && $_GET['unidade'] !== 'Todos') {
                $base_sql .= " AND local = ?";
                $params[] = $_GET['unidade'];
            }
            if (!empty($_GET['empresa']) && $_GET['empresa'] !== 'Todas') {
            $base_sql .= " AND empresa = ?";
            $params[] = $_GET['empresa'];
            }
            if (!empty($_GET['genero'])) {
                $base_sql .= " AND genero = ?";
                $params[] = $_GET['genero'];
            }
            if (!empty($_GET['cidade'])) {
                $base_sql .= " AND cidade LIKE ?";
                $params[] = '%' . $_GET['cidade'] . '%';
            }
            if (!empty($_GET['estado'])) {
                $base_sql .= " AND estado = ?";
                $params[] = $_GET['estado'];
            }
            if (!empty($_GET['vencimento'])) {
                $coluna = $_GET['vencimento'];
                $colunas_permitidas = ['validade_cnh', 'validade_exame_medico', 'validade_treinamento', 'validade_cct', 'validade_contrato_experiencia'];
                if (in_array($coluna, $colunas_permitidas)) {
                    $base_sql .= " AND {$coluna} IS NOT NULL AND {$coluna} <= CURDATE()";
                }
            }
            
            $base_sql .= " ORDER BY nome ASC";
    
            $stmt = $pdo->prepare($base_sql);
            $stmt->execute($params);
            $funcionarios = $stmt->fetchAll();
    
            echo json_encode(['success' => true, 'data' => $funcionarios]);
    
        } catch (PDOException $e) {
            echo json_encode(['success' => false, 'message' => 'Erro ao filtrar funcionários: ' . $e->getMessage()]);
        }
        break;

    case 'get_funcionario':
        $id = $_GET['id'] ?? 0;
        $stmt = $pdo->prepare("SELECT * FROM funcionarios WHERE id = ?");
        $stmt->execute([$id]);
        $funcionario = $stmt->fetch();
        echo json_encode(['success' => true, 'data' => $funcionario]);
        break;
    
    case 'add_funcionario':
    $pdo->beginTransaction();
    try {
        $dados = $_POST;
        unset($dados['action'], $dados['id']);
        unset($dados['tem_filhos']);
            if (isset($dados['data_movimentacao'])) {
                if ($dados['status'] === 'ativo') { $dados['data_admissao'] = $dados['data_movimentacao']; }
                else { $dados['data_demissao'] = $dados['data_movimentacao']; }
                unset($dados['data_movimentacao']);
            }
            
            $colunas = []; $placeholders = []; $valores = [];
            foreach ($dados as $coluna => $valor) {
                if ($valor !== '') {
                    $colunas[] = "`" . $coluna . "`"; $placeholders[] = "?"; $valores[] = $valor;
                }
            }
            
            $sql = sprintf('INSERT INTO funcionarios (%s) VALUES (%s)', implode(', ', $colunas), implode(', ', $placeholders));
            $stmt = $pdo->prepare($sql);
            $stmt->execute($valores);
            
            $novo_funcionario_id = $pdo->lastInsertId();

            $stmt_raiz = $pdo->prepare("INSERT INTO pastas (funcionario_id, nome_pasta) VALUES (?, 'Raiz')");
            $stmt_raiz->execute([$novo_funcionario_id]);
            $id_pasta_raiz = $pdo->lastInsertId();

            $pastas_padrao = ["Atestado", "Contrato", "Disciplinar", "Documentos Pessoais", "Férias", "Holerites", "Ponto", "Sinistro", "Treinamento", "Outros"];
            $stmt_subpasta = $pdo->prepare("INSERT INTO pastas (funcionario_id, parent_id, nome_pasta) VALUES (?, ?, ?)");
            foreach ($pastas_padrao as $nome_pasta) {
                $stmt_subpasta->execute([$novo_funcionario_id, $id_pasta_raiz, $nome_pasta]);
            }

            $pdo->commit();
            echo json_encode(['success' => true, 'message' => 'Funcionário e estrutura de pastas criados com sucesso!']);

        } catch (Exception $e) {
            $pdo->rollBack();
            echo json_encode(['success' => false, 'message' => 'Erro no servidor: ' . $e->getMessage()]);
        }
        break;

    case 'update_funcionario':
        try {
            $dados = $_POST;
            $id = $dados['id'];
            unset($dados['action'], $dados['id']);
            unset($dados['tem_filhos']);
            if (isset($dados['data_movimentacao'])) {
                if ($dados['status'] === 'ativo') { $dados['data_admissao'] = $dados['data_movimentacao']; }
                else { $dados['data_demissao'] = $dados['data_movimentacao']; }
                unset($dados['data_movimentacao']);
            }
            
            $set_parts = [];
            $valores = [];
            foreach ($dados as $coluna => $valor) {
                $set_parts[] = "`" . $coluna . "`" . " = ?";
                $valores[] = ($valor === '') ? null : $valor;
            }
            $valores[] = $id;

            if (count($set_parts) > 0) {
                $sql = sprintf('UPDATE funcionarios SET %s WHERE id = ?', implode(', ', $set_parts));
                $stmt = $pdo->prepare($sql);
                $success = $stmt->execute($valores);
                echo json_encode(['success' => $success, 'message' => 'Funcionário atualizado com sucesso!']);
            } else {
                 echo json_encode(['success' => false, 'message' => 'Nenhum dado para atualizar.']);
            }
        } catch (PDOException $e) {
            echo json_encode(['success' => false, 'message' => 'Erro no servidor: ' . $e->getMessage()]);
        }
        break;

    case 'terminate_funcionario':
        $id = $_POST['id'] ?? 0;
        $data_demissao = $_POST['data_demissao'] ?? null;
        $motivo_demissao = $_POST['motivo_demissao'] ?? null;
        $elegivel_recontratacao = $_POST['elegivel_recontratacao'] ?? null;
        
        $stmt = $pdo->prepare(
            "UPDATE funcionarios 
             SET status = 'inativo', 
                 data_demissao = ?, 
                 motivo_demissao = ?, 
                 elegivel_recontratacao = ? 
             WHERE id = ?"
        );
        $params = [$data_demissao, $motivo_demissao, $elegivel_recontratacao, $id];
        $success = $stmt->execute($params);
        echo json_encode(['success' => $success, 'message' => 'Contrato encerrado com sucesso.']);
        break;
        
    case 'delete_funcionario':
        $id = $_POST['id'];
        $stmt = $pdo->prepare("DELETE FROM funcionarios WHERE id = ?");
        $success = $stmt->execute([$id]);
        echo json_encode(['success' => $success]);
        break;

    // --- AÇÕES PARA GESTÃO DE DOCUMENTOS ---
    case 'get_folder_id_by_name':
        $funcionario_id = $_GET['funcionario_id'] ?? 0;
        $folder_name = $_GET['folder_name'] ?? '';
    
        $stmt_raiz = $pdo->prepare("SELECT id FROM pastas WHERE funcionario_id = ? AND parent_id IS NULL");
        $stmt_raiz->execute([$funcionario_id]);
        $raiz = $stmt_raiz->fetch();
        
        if (!$raiz) {
            $stmt_cria_raiz = $pdo->prepare("INSERT INTO pastas (funcionario_id, nome_pasta) VALUES (?, 'Raiz')");
            $stmt_cria_raiz->execute([$funcionario_id]);
            $id_pasta_raiz = $pdo->lastInsertId();
        } else {
            $id_pasta_raiz = $raiz['id'];
        }
    
        $stmt_pasta = $pdo->prepare("SELECT id FROM pastas WHERE funcionario_id = ? AND nome_pasta = ? AND parent_id = ?");
        $stmt_pasta->execute([$funcionario_id, $folder_name, $id_pasta_raiz]);
        $pasta = $stmt_pasta->fetch();
    
        if (!$pasta) {
            $stmt_cria_pasta = $pdo->prepare("INSERT INTO pastas (funcionario_id, parent_id, nome_pasta) VALUES (?, ?, ?)");
            $stmt_cria_pasta->execute([$funcionario_id, $id_pasta_raiz, $folder_name]);
            $id_nova_pasta = $pdo->lastInsertId();
            echo json_encode(['success' => true, 'folder_id' => $id_nova_pasta]);
        } else {
            echo json_encode(['success' => true, 'folder_id' => $pasta['id']]);
        }
        break;

    case 'listar_pastas_e_arquivos':
        $funcionario_id = $_GET['funcionario_id'] ?? 0;
        $parent_id = isset($_GET['parent_id']) && $_GET['parent_id'] !== 'null' ? $_GET['parent_id'] : null;

        $response = ['pastas' => [], 'documentos' => [], 'current_folder_id' => null];

        if ($parent_id === null) {
            $stmt_raiz = $pdo->prepare("SELECT id FROM pastas WHERE funcionario_id = ? AND parent_id IS NULL LIMIT 1");
            $stmt_raiz->execute([$funcionario_id]);
            $pasta_raiz = $stmt_raiz->fetch();
            if ($pasta_raiz) {
                $parent_id = $pasta_raiz['id'];
            }
        }
        
        $response['current_folder_id'] = $parent_id;

        if ($parent_id) {
            $stmt_pastas = $pdo->prepare("SELECT * FROM pastas WHERE parent_id = ? ORDER BY nome_pasta ASC");
            $stmt_pastas->execute([$parent_id]);
            $response['pastas'] = $stmt_pastas->fetchAll();

            $stmt_docs = $pdo->prepare("SELECT * FROM documentos WHERE pasta_id = ? ORDER BY nome_original ASC");
            $stmt_docs->execute([$parent_id]);
            $response['documentos'] = $stmt_docs->fetchAll();
        }
        
        echo json_encode(['success' => true, 'data' => $response]);
        break;

    case 'criar_pasta':
        $funcionario_id = $_POST['funcionario_id'] ?? 0;
        $parent_id = $_POST['parent_id'] ?? 0;
        $nome_pasta = trim($_POST['nome_pasta'] ?? '');

        if (!empty($nome_pasta) && !empty($funcionario_id) && !empty($parent_id)) {
            $stmt = $pdo->prepare("INSERT INTO pastas (funcionario_id, parent_id, nome_pasta) VALUES (?, ?, ?)");
            $success = $stmt->execute([$funcionario_id, $parent_id, $nome_pasta]);
            echo json_encode(['success' => $success]);
        } else {
            echo json_encode(['success' => false, 'message' => 'Dados insuficientes.']);
        }
        break;
        
    case 'upload_arquivo':
        $pasta_id = $_POST['pasta_id'] ?? 0;
        
        if (empty($pasta_id) || !isset($_FILES['arquivo']) || $_FILES['arquivo']['error'] !== UPLOAD_ERR_OK) {
            echo json_encode(['success' => false, 'message' => 'Erro no envio do arquivo ou pasta de destino inválida.']);
            exit();
        }

        $arquivo = $_FILES['arquivo'];
        $nome_original = basename($arquivo['name']);
        $tipo_arquivo = $arquivo['type'];
        $nome_temporario = $arquivo['tmp_name'];
        
        $upload_dir = dirname(__DIR__) . '/uploads/';
        if (!is_dir($upload_dir)) {
            mkdir($upload_dir, 0755, true);
        }

        $extensao = strtolower(pathinfo($nome_original, PATHINFO_EXTENSION));
        $nome_seguro = uniqid('', true) . '.' . $extensao;
        $caminho_destino = $upload_dir . $nome_seguro;
        $caminho_para_db = 'uploads/' . $nome_seguro;
        
        if (move_uploaded_file($nome_temporario, $caminho_destino)) {
            $stmt = $pdo->prepare("INSERT INTO documentos (pasta_id, nome_original, caminho_arquivo, tipo_arquivo) VALUES (?, ?, ?, ?)");
            $success = $stmt->execute([$pasta_id, $nome_original, $caminho_para_db, $tipo_arquivo]);
            echo json_encode(['success' => $success]);
        } else {
            echo json_encode(['success' => false, 'message' => 'Falha ao mover o arquivo. Verifique as permissões da pasta uploads.']);
        }
        break;

    case 'renomear_pasta':
        $pasta_id = $_POST['pasta_id'] ?? 0;
        $novo_nome = trim($_POST['novo_nome'] ?? '');
        if (!empty($pasta_id) && !empty($novo_nome)) {
            $stmt = $pdo->prepare("UPDATE pastas SET nome_pasta = ? WHERE id = ?");
            $success = $stmt->execute([$novo_nome, $pasta_id]);
            echo json_encode(['success' => $success]);
        } else {
            echo json_encode(['success' => false, 'message' => 'ID ou novo nome da pasta não fornecido.']);
        }
        break;
    
    case 'excluir_pasta':
        $pasta_id = $_POST['pasta_id'] ?? 0;
        if (empty($pasta_id)) {
            echo json_encode(['success' => false, 'message' => 'ID da pasta não fornecido.']);
            exit();
        }

        $stmt_subpastas = $pdo->prepare("SELECT COUNT(*) FROM pastas WHERE parent_id = ?");
        $stmt_subpastas->execute([$pasta_id]);
        $num_subpastas = $stmt_subpastas->fetchColumn();

        $stmt_docs = $pdo->prepare("SELECT COUNT(*) FROM documentos WHERE pasta_id = ?");
        $stmt_docs->execute([$pasta_id]);
        $num_docs = $stmt_docs->fetchColumn();

        if ($num_subpastas == 0 && $num_docs == 0) {
            $stmt = $pdo->prepare("DELETE FROM pastas WHERE id = ?");
            $success = $stmt->execute([$pasta_id]);
            echo json_encode(['success' => $success]);
        } else {
            echo json_encode(['success' => false, 'message' => 'Não é possível excluir. A pasta não está vazia.']);
        }
        break;
        
    case 'excluir_arquivo':
        $documento_id = $_POST['documento_id'] ?? 0;
        if (empty($documento_id)) {
            echo json_encode(['success' => false, 'message' => 'ID do documento não fornecido.']);
            exit();
        }

        $pdo->beginTransaction();
        try {
            $stmt_doc = $pdo->prepare("SELECT caminho_arquivo FROM documentos WHERE id = ?");
            $stmt_doc->execute([$documento_id]);
            $documento = $stmt_doc->fetch();

            if ($documento) {
                $caminho_arquivo = dirname(__DIR__) . '/' . $documento['caminho_arquivo'];
                
                $stmt_delete = $pdo->prepare("DELETE FROM documentos WHERE id = ?");
                $stmt_delete->execute([$documento_id]);

                if (file_exists($caminho_arquivo)) {
                    unlink($caminho_arquivo);
                }
                
                $pdo->commit();
                echo json_encode(['success' => true]);
            } else {
                throw new Exception('Documento não encontrado.');
            }
        } catch(Exception $e) {
            $pdo->rollBack();
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
        break;

    // --- AÇÕES DO DASHBOARD ---
    case 'get_status_diario':
        $data = $_GET['data'] ?? date('Y-m-d');
        $unidade = $_GET['unidade'] ?? 'Todos';
        
        $stmt = $pdo->prepare("SELECT * FROM status_diario WHERE data = ? AND unidade = ?");
        $stmt->execute([$data, $unidade]);
        $status = $stmt->fetch();
        
        echo json_encode(['success' => true, 'data' => $status ?: null]);
        break;

    case 'save_status_diario':
        $data = $_POST['data'];
        $unidade = $_POST['unidade'];

        $sql = "INSERT INTO status_diario (data, unidade, presentes, ferias, atestado, folga, falta_injustificada)
                VALUES (?, ?, ?, ?, ?, ?, ?)
                ON DUPLICATE KEY UPDATE
                presentes = VALUES(presentes), ferias = VALUES(ferias), atestado = VALUES(atestado), 
                folga = VALUES(folga), falta_injustificada = VALUES(falta_injustificada)";
        
        $stmt = $pdo->prepare($sql);
        $success = $stmt->execute([
            $data, $unidade, $_POST['presentes'] ?? 0, $_POST['ferias'] ?? 0,
            $_POST['atestado'] ?? 0, $_POST['folga'] ?? 0, $_POST['falta_injustificada'] ?? 0
        ]);

        echo json_encode(['success' => $success]);
        break;
               
    default:
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Ação não reconhecida.']);
        break;
}
?>

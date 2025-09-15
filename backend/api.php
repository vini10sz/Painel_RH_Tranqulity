<?php
// backend/api.php - Versão Completa e Final

// Garante que erros do PHP sejam reportados para facilitar a depuração
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

require 'db_config.php';
header('Content-Type: application/json');
$action = $_REQUEST['action'] ?? '';

switch ($action) {

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
            if (!empty($_GET['genero'])) {
                $base_sql .= " AND genero = ?";
                $params[] = $_GET['genero'];
            }
            if (!empty($_GET['status_filhos'])) {
                if ($_GET['status_filhos'] === 'sim') {
                     $base_sql .= " AND quantidade_filhos > 0";
                } else if ($_GET['status_filhos'] === 'nao') {
                     $base_sql .= " AND (quantidade_filhos = 0 OR quantidade_filhos IS NULL)";
                }
            }
            if (!empty($_GET['cidade'])) {
                $base_sql .= " AND cidade LIKE ?";
                $params[] = '%' . $_GET['cidade'] . '%';
            }
            if (!empty($_GET['estado'])) {
                $base_sql .= " AND estado = ?";
                $params[] = $_GET['estado'];
            }
            if (!empty($_GET['aniversario_mes']) && $_GET['aniversario_mes'] === 'sim') {
                $base_sql .= " AND MONTH(data_nascimento) = MONTH(CURDATE())";
            }
            if (!empty($_GET['vencimento'])) {
                $coluna = $_GET['vencimento'];
                // ATUALIZADO: 'validade_sst' trocado por 'validade_cct'
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
        try {
            $dados = $_POST;
            unset($dados['action'], $dados['id']);

            if (isset($dados['data_movimentacao']) && !empty($dados['data_movimentacao'])) {
                if ($dados['status'] === 'ativo') {
                    $dados['data_admissao'] = $dados['data_movimentacao'];
                } else {
                    $dados['data_demissao'] = $dados['data_movimentacao'];
                }
            }
            unset($dados['data_movimentacao']);
            unset($dados['tem_filhos']); // Garante que o campo do seletor não seja salvo

            $colunas = [];
            $placeholders = [];
            $valores = [];

            foreach ($dados as $coluna => $valor) {
                if ($valor !== '') {
                    $colunas[] = "`" . $coluna . "`";
                    $placeholders[] = "?";
                    $valores[] = ($valor === '') ? null : $valor;
                }
            }

            if (count($colunas) > 0) {
                $sql = sprintf(
                    'INSERT INTO funcionarios (%s) VALUES (%s)',
                    implode(', ', $colunas),
                    implode(', ', $placeholders)
                );
                
                $stmt = $pdo->prepare($sql);
                $success = $stmt->execute($valores);
                echo json_encode(['success' => $success, 'message' => 'Funcionário adicionado com sucesso!']);
            } else {
                echo json_encode(['success' => false, 'message' => 'Nenhum dado para adicionar.']);
            }

        } catch (PDOException $e) {
            echo json_encode(['success' => false, 'message' => 'Erro no servidor: ' . $e->getMessage()]);
        }
        break;

    case 'update_funcionario':
        try {
            $dados = $_POST;
            $id = $dados['id'];
            unset($dados['action'], $dados['id']);

            if (isset($dados['data_movimentacao']) && !empty($dados['data_movimentacao'])) {
                if ($dados['status'] === 'ativo') {
                    $dados['data_admissao'] = $dados['data_movimentacao'];
                } else {
                    $dados['data_demissao'] = $dados['data_movimentacao'];
                }
            }
            unset($dados['data_movimentacao']);
            unset($dados['tem_filhos']);
            
            $set_parts = [];
            $valores = [];
            foreach ($dados as $coluna => $valor) {
                $set_parts[] = "`" . $coluna . "`" . " = ?";
                $valores[] = ($valor === '') ? null : $valor;
            }
            $valores[] = $id;

            if (count($set_parts) > 0) {
                $sql = sprintf(
                    'UPDATE funcionarios SET %s WHERE id = ?',
                    implode(', ', $set_parts)
                );

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
            $data,
            $unidade,
            $_POST['presentes'] ?? 0,
            $_POST['ferias'] ?? 0,
            $_POST['atestado'] ?? 0,
            $_POST['folga'] ?? 0,
            $_POST['falta_injustificada'] ?? 0
        ]);

        echo json_encode(['success' => $success]);
        break;
        
    default:
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Ação não reconhecida.']);
        break;
}
?>

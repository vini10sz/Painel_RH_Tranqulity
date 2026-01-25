<?php
// backend/db_config.php

define('DB_HOST', 'localhost');
define('DB_USER', 'root'); // <-- Verifique se este é seu usuário do MySQL
define('DB_PASS', 'root');     // <-- Verifique se esta é sua senha do MySQL (geralmente vazia)
define('DB_NAME', 'tranquility_rh_db');

try {
    $pdo = new PDO("mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8mb4", DB_USER, DB_PASS);
    // Configura o PDO para lançar exceções em caso de erro
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    // Garante que o fetch padrão seja um array associativo (AGORA CORRIGIDO)
    $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC); // <-- CORRETO
} catch (PDOException $e) {

    header('Content-Type: application/json');
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Erro de conexão com o banco de dados.']);
    exit();
}

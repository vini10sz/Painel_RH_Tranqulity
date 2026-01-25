<?php
// setup_admin.php
// Este script cria OU atualiza o usuário administrador.
// ATENÇÃO: APAGUE ESTE ARQUIVO IMEDIATAMENTE APÓS O USO!

// --- Estilização para uma resposta clara ---
echo "<!DOCTYPE html><html lang='pt-br'><head><meta charset='UTF-8'><title>Setup do Administrador</title>";
echo "<style>body { font-family: sans-serif; padding: 20px; line-height: 1.6; } h1 { color: #2c3e50; } p { font-size: 1.1em; } strong { color: #c0392b; } .success { color: #27ae60; }</style></head><body>";

// O require funciona porque este arquivo está na raiz do projeto
require 'backend/db_config.php'; 

// --- Configurações do Administrador ---
$email_admin = "admin@empresa.com.br";
$nome_admin = "Administrador";
$senha_pura = "senhaforte123";
// ------------------------------------

// Gera o hash seguro da senha
$senha_hash = password_hash($senha_pura, PASSWORD_DEFAULT);

try {
    // 1. Verifica se o usuário já existe
    $stmt_check = $pdo->prepare("SELECT id FROM usuario WHERE email = ?");
    $stmt_check->execute([$email_admin]);
    $usuario_existente = $stmt_check->fetch();

    if ($usuario_existente) {
        // 2. Se EXISTE, atualiza a senha
        $stmt_update = $pdo->prepare("UPDATE usuario SET senha = ?, nome = ? WHERE email = ?");
        $stmt_update->execute([$senha_hash, $nome_admin, $email_admin]);

        echo "<h1 class='success'>Sucesso!</h1>";
        echo "<p>O usuário '{$email_admin}' já existia e sua senha foi <strong>ATUALIZADA</strong>.</p>";

    } else {
        // 3. Se NÃO EXISTE, cria o usuário
        $stmt_insert = $pdo->prepare("INSERT INTO usuario (nome, email, senha) VALUES (?, ?, ?)");
        $stmt_insert->execute([$nome_admin, $email_admin, $senha_hash]);

        echo "<h1 class='success'>Sucesso!</h1>";
        echo "<p>O usuário '{$email_admin}' foi <strong>CRIADO</strong> no banco de dados.</p>";
    }

    echo "<p>A senha foi definida para: '{$senha_pura}'</p>";
    echo "<p>Você já pode fechar esta aba e tentar fazer o login.</p>";
    echo "<strong><p>POR SEGURANÇA, APAGUE ESTE ARQUIVO (setup_admin.php) AGORA!</p></strong>";

} catch (PDOException $e) {
    echo "<h1>Erro Crítico!</h1>";
    echo "<p>Ocorreu um erro ao tentar acessar o banco de dados:</p>";
    echo "<p>" . $e->getMessage() . "</p>";
}

echo "</body></html>";
?>

<?php
// criar_admin.php
require 'backend/db_config.php';

$nome = "Administrador";
$email = "admin@empresa.com.br";
$senha_pura = "senhaforte123"; // Defina sua senha aqui

$senha_criptografada = password_hash($senha_pura, PASSWORD_DEFAULT);

try {
    $stmt_check = $pdo->prepare("SELECT id FROM usuario WHERE email = ?");
    $stmt_check->execute([$email]);
    if ($stmt_check->fetch()) {
        echo "Erro: O e-mail '{$email}' já existe.";
    } else {
        $stmt_insert = $pdo->prepare("INSERT INTO usuario (nome, email, senha) VALUES (?, ?, ?)");
        $stmt_insert->execute([$nome, $email, $senha_criptografada]);
        echo "<h1>Sucesso!</h1><p>Usuário '{$nome}' criado com o e-mail '{$email}' e a senha '{$senha_pura}'.</p><strong>APAGUE ESTE ARQUIVO AGORA.</strong>";
    }
} catch (PDOException $e) {
    echo "Erro: " . $e->getMessage();
}
?>
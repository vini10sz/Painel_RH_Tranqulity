<?php

namespace Controller;
session_start(); 
header('Content-Type: application/json');


class AuthController{

    public static function login($data)
    {
        global $pdo;


        if (!isset($data['username'], $data['password'])) {
            echo json_encode(['success' => false, 'message' => 'Usuário ou senha não enviados']);
            exit;
        }

        try {
            $stmt = $pdo->prepare("SELECT * FROM administradores WHERE email = ?");
            $stmt->execute([$data['username']]);
            $user = $stmt->fetch(\PDO::FETCH_ASSOC);

            if (!$user) {
                echo json_encode(['success' => false, 'message' => 'Usuário não encontrado']);
                exit;
            }

            if ($data['password'] !== $user['senha']) {
                echo json_encode(['success' => false, 'message' => 'Email ou Senha incorretos']);
                exit;
            }

            $_SESSION['user_id'] = $user['id'];
            $_SESSION['nome'] = $user['nome'];
            $_SESSION['email'] = $user['email'];

            echo json_encode([
                'success' => true,
                'message' => 'Login efetuado com sucesso!',
                'user' => [
                    'id' => $user['id'],
                    'username' => $user['nome'],
                    'email' => $user['email']
                ]
            ]);

        } catch (\PDOException $e) {
            echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    }

    
}
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Painel RH - Grupo Tranquility</title>
    <link rel="icon" href="assets/imagens/imagens.png" sizes="32x32" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body>
    
    <div id="login-container">
        <div class="login-box">
            <img src="assets/imagens/imagens.png" alt="Logo" class="login-logo">
            <h2>Painel de Gestão RH</h2>
            <p class="login-subtitle">Acesse com suas credenciais.</p>
            <form id="login-form">
                <div class="input-group">
                    <i class="fas fa-envelope"></i>
                    <input type="email" id="email" name="email" placeholder="E-mail" required>
                </div>
                <div class="input-group">
                    <i class="fas fa-lock"></i>
                    <input type="password" id="password" name="senha" placeholder="Senha" required>
                    <button type="button" id="toggle-password" class="toggle-password-btn"><i class="fas fa-eye"></i></button>
                </div>
                <button type="submit" class="login-button">Entrar <i class="fas fa-arrow-right"></i></button>
                <p id="login-error" class="login-error-message"></p>
            </form>
            <div class="login-footer-links">
                <a href="#" id="forgot-password-link">Esqueci minha senha</a>
            </div>
        </div>
    </div>

    <div id="toast"></div>

    <script src="https://unpkg.com/imask"></script>
    <script src="assets/js/script.js" defer></script>
</body>
</html>

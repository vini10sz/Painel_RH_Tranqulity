-- ======================================================================================
-- SCRIPT COMPLETO DO BANCO DE DADOS
-- PROJETO: PAINEL DE GESTÃO RH - GRUPO TRANQUILITY
-- ======================================================================================

-- ======================================================================================
-- PARTE 1: ESTRUTURA DO BANCO DE DADOS (CRIAÇÃO DAS TABELAS)
-- ======================================================================================

-- Apaga o banco de dados se ele já existir, para garantir um começo limpo
DROP DATABASE IF EXISTS `tranquility_rh_db`;

-- Cria o novo banco de dados com o padrão de caracteres correto
CREATE DATABASE `tranquility_rh_db` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Seleciona o banco de dados para uso
USE `tranquility_rh_db`;

--
-- Tabela 1: `funcionarios`
-- Armazena todos os dados cadastrais dos colaboradores.
--
CREATE TABLE `funcionarios` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(255) NOT NULL,
  `funcao` VARCHAR(100) DEFAULT NULL,
  `status` ENUM('ativo', 'inativo', 'afastado') NOT NULL DEFAULT 'ativo',
  `empresa` VARCHAR(100) DEFAULT NULL,
  `local` VARCHAR(100) DEFAULT NULL,
  `horario` VARCHAR(100) DEFAULT NULL, 
  `data_admissao` DATE DEFAULT NULL,
  `data_inicio` DATE DEFAULT NULL,
  `data_demissao` DATE DEFAULT NULL,
  `data_nascimento` DATE DEFAULT NULL,
  `genero` VARCHAR(20) DEFAULT NULL,
  `rg` VARCHAR(20) DEFAULT NULL,
  `cpf` VARCHAR(14) DEFAULT NULL,
  `pis` VARCHAR(20) DEFAULT NULL,
  `cnh_numero` VARCHAR(100) DEFAULT NULL,
  `estado_civil` VARCHAR(50) DEFAULT NULL,
  `dados_conjuge` VARCHAR(255) DEFAULT NULL COMMENT 'JSON com nome e nascimento',
  `quantidade_filhos` INT DEFAULT 0,
  `nome_filhos` TEXT DEFAULT NULL COMMENT 'JSON com lista de filhos',
  `email_pessoal` VARCHAR(255) DEFAULT NULL,
  `telefone_1` VARCHAR(20) DEFAULT NULL,
  `telefone_2` VARCHAR(20) DEFAULT NULL,
  `telefone_3` VARCHAR(20) DEFAULT NULL,
  `cep` VARCHAR(9) DEFAULT NULL,
  `rua` VARCHAR(255) DEFAULT NULL,
  `numero` VARCHAR(20) DEFAULT NULL,
  `complemento` VARCHAR(100) DEFAULT NULL,
  `bairro` VARCHAR(100) DEFAULT NULL,
  `cidade` VARCHAR(100) DEFAULT NULL,
  `estado` VARCHAR(2) DEFAULT NULL,
  `opcao_transporte` ENUM('Não Optante', 'Vale Transporte', 'Auxílio Combustível') DEFAULT 'Não Optante',
  `meio_transporte` VARCHAR(255) DEFAULT NULL,
  `qtd_transporte` INT DEFAULT NULL,
  `valor_transporte` VARCHAR(50) DEFAULT NULL,
  `validade_cnh` DATE DEFAULT NULL,
  `validade_exame_clinico` DATE DEFAULT NULL,
  `validade_audiometria` DATE DEFAULT NULL,
  `validade_eletrocardiograma` DATE DEFAULT NULL,
  `validade_eletroencefalograma` DATE DEFAULT NULL,
  `validade_glicemia` DATE DEFAULT NULL,
  `validade_acuidade_visual` DATE DEFAULT NULL,
  `validade_treinamento` DATE DEFAULT NULL,
  `validade_contrato_experiencia` DATE DEFAULT NULL,
  `motivo_demissao` TEXT DEFAULT NULL,
  `elegivel_recontratacao` ENUM('Sim', 'Não', 'Avaliar') DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Tabela 2: `status_diario`
-- Armazena os dados diários do dashboard de ponto.
--
CREATE TABLE `status_diario` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `data` DATE NOT NULL,
  `unidade` VARCHAR(255) NOT NULL,
  `presentes` INT DEFAULT 0,
  `ferias` INT DEFAULT 0,
  `atestado` INT DEFAULT 0,
  `afastados` INT DEFAULT 0, -- ADICIONADO AQUI
  `folga` INT DEFAULT 0,
  `falta_injustificada` INT DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `data_unidade_unique` (`data`, `unidade`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


--
-- Tabela 3: `pastas`
-- Organiza as pastas e subpastas de cada funcionário.
--
CREATE TABLE `pastas` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `funcionario_id` INT NOT NULL,
  `parent_id` INT DEFAULT NULL COMMENT 'ID da pasta pai (se for uma subpasta)',
  `nome_pasta` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`funcionario_id`) REFERENCES `funcionarios`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


--
-- Tabela 4: `documentos`
-- Armazena as informações de cada documento enviado (upload).
--
CREATE TABLE `documentos` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `pasta_id` INT NOT NULL,
  `nome_original` VARCHAR(255) NOT NULL COMMENT 'Nome original do arquivo',
  `caminho_arquivo` VARCHAR(255) NOT NULL COMMENT 'Caminho do arquivo salvo no servidor',
  `tipo_arquivo` VARCHAR(100) NOT NULL,
  `data_upload` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`pasta_id`) REFERENCES `pastas`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ======================================================================================
-- CRIAÇÃO DA TABELA DE USUÁRIOS PARA LOGIN NO SISTEMA
-- ======================================================================================

CREATE TABLE `usuario` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(255) NOT NULL,
  `email` VARCHAR(255) NOT NULL,
  `senha` VARCHAR(255) NOT NULL COMMENT 'Armazenar SEMPRE a senha criptografada (hash)',
  PRIMARY KEY (`id`),
  UNIQUE KEY `email_unique` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ======================================================================================
-- PARTE 2: DESATIVAÇÃO E REATIVAÇÃO DA TRAVA DE SEGURANÇA
-- ======================================================================================

-- ETAPA 1: PREPARAÇÃO DO AMBIENTE
SET SQL_SAFE_UPDATES = 0;

-- ETAPA 5: REATIVA A SEGURANÇA
SET SQL_SAFE_UPDATES = 1;

-- ======================================================================================
-- PARTE 3: SCRIPT DE MIGRAÇÃO (PARA RODAR APÓS INSERIR OS DADOS)
-- Cria a estrutura de pastas padrão para os funcionários inseridos na Parte 2.
-- ======================================================================================

-- Garante que a pasta "Raiz" exista para todos os funcionários
INSERT INTO pastas (funcionario_id, parent_id, nome_pasta)
SELECT 
    f.id, 
    NULL, 
    'Raiz'
FROM 
    funcionarios f
WHERE NOT EXISTS (
    SELECT 1 FROM pastas p WHERE p.funcionario_id = f.id AND p.parent_id IS NULL
);

-- Insere as pastas padrão para cada funcionário, somente se elas ainda não existirem
INSERT INTO pastas (funcionario_id, parent_id, nome_pasta)
SELECT
    f.id AS funcionario_id,
    p_raiz.id AS parent_id,
    pastas_padrao.nome_pasta
FROM
    funcionarios AS f
JOIN
    pastas AS p_raiz ON f.id = p_raiz.funcionario_id AND p_raiz.parent_id IS NULL
CROSS JOIN
    (
        SELECT 'Atestado' AS nome_pasta UNION ALL
        SELECT 'Contrato' UNION ALL
        SELECT 'Disciplinar' UNION ALL
        SELECT 'Documentos Pessoais' UNION ALL
        SELECT 'Férias' UNION ALL
        SELECT 'Holerites' UNION ALL
        SELECT 'Ponto' UNION ALL
        SELECT 'Sinistro' UNION ALL
        SELECT 'Treinamento' UNION ALL
        SELECT 'Outros'
    ) AS pastas_padrao
LEFT JOIN
    pastas AS p_exist ON f.id = p_exist.funcionario_id AND pastas_padrao.nome_pasta = p_exist.nome_pasta AND p_exist.parent_id = p_raiz.id
WHERE
    p_exist.id IS NULL;

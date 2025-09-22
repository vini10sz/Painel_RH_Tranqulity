-- ======================================================================================
-- SCRIPT COMPLETO E ATUALIZADO DO BANCO DE DADOS
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
  `status` ENUM('ativo', 'inativo') NOT NULL DEFAULT 'ativo',
  `empresa` VARCHAR(100) DEFAULT NULL,
  `local` VARCHAR(100) DEFAULT NULL,
  `data_admissao` DATE DEFAULT NULL,
  `data_demissao` DATE DEFAULT NULL,
  `data_nascimento` DATE DEFAULT NULL,
  `rg` VARCHAR(20) DEFAULT NULL,
  `cpf` VARCHAR(14) DEFAULT NULL,
  `cnh_numero` VARCHAR(100) DEFAULT NULL,
  `estado_civil` VARCHAR(50) DEFAULT NULL,
  `dados_conjuge` VARCHAR(255) DEFAULT NULL COMMENT 'Armazena dados do cônjuge em formato JSON',
  `quantidade_filhos` INT DEFAULT 0,
  `nome_filhos` TEXT DEFAULT NULL COMMENT 'Armazena dados dos filhos em formato JSON',
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
  `genero` VARCHAR(20) DEFAULT NULL,
  `validade_cnh` DATE DEFAULT NULL,
  `validade_exame_medico` DATE DEFAULT NULL,
  `validade_treinamento` DATE DEFAULT NULL,
  `validade_cct` DATE DEFAULT NULL COMMENT 'Antiga validade_sst',
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
-- PARTE 2: INSERÇÃO DE DADOS DE AMOSTRA (POPULAÇÃO DAS TABELAS)
-- (Cole aqui o script com os 40 funcionários de exemplo)
-- ======================================================================================

-- ETAPA 1: PREPARAÇÃO DO AMBIENTE
SET SQL_SAFE_UPDATES = 0;

-- ETAPA 2: LIMPEZA DAS TABELAS
DELETE FROM documentos;
DELETE FROM pastas;
DELETE FROM funcionarios;

-- ETAPA 3: RESET DOS CONTADORES
ALTER TABLE funcionarios AUTO_INCREMENT = 1;
ALTER TABLE pastas AUTO_INCREMENT = 1;
ALTER TABLE documentos AUTO_INCREMENT = 1;

-- ETAPA 4: INSERÇÃO DOS NOVOS FUNCIONÁRIOS (VERSÃO CORRIGIDA)
INSERT INTO `funcionarios` 
(`nome`, `funcao`, `status`, `empresa`, `local`, `data_admissao`, `data_demissao`, `validade_cnh`, `validade_exame_medico`, `validade_cct`, `validade_contrato_experiencia`, `data_nascimento`, `rg`, `cpf`, `estado_civil`, `dados_conjuge`, `quantidade_filhos`, `nome_filhos`, `cnh_numero`, `telefone_1`, `cep`, `rua`, `numero`, `complemento`, `bairro`, `cidade`, `estado`, `email_pessoal`, `genero`, `motivo_demissao`, `elegivel_recontratacao`) 
VALUES
-- =================================== FUNCIONÁRIOS ATIVOS (20) ===================================
-- Empresa: Tranquility (6)
('Ana Clara Ribeiro', 'Operadora de Caixa', 'ativo', 'Tranquility', 'IGESP - Hospital Praia Grande', '2023-05-10', NULL, DATE_ADD(CURDATE(), INTERVAL 1 YEAR), DATE_ADD(CURDATE(), INTERVAL 6 MONTH), DATE_ADD(CURDATE(), INTERVAL 1 YEAR), NULL, '1998-09-15', '45.123.456-7', '123.456.789-10', 'Solteiro(a)', NULL, 0, NULL, '987654321', '(11) 98877-6655', '11702-050', 'Avenida Marechal Mallet', '500', NULL, 'Canto do Forte', 'Praia Grande', 'SP', 'ana.clara@email.com', 'Feminino', NULL, NULL),
('Bruno Costa e Silva', 'Gerente de Pátio', 'ativo', 'Tranquility', 'Hapvida', '2021-11-20', NULL, DATE_ADD(CURDATE(), INTERVAL 2 YEAR), DATE_ADD(CURDATE(), INTERVAL 1 YEAR), DATE_ADD(CURDATE(), INTERVAL 1 YEAR), NULL, '1985-07-22', '34.567.890-1', '234.567.890-12', 'Casado(a)', '{"nome": "Juliana Costa", "data_nascimento": "1987-08-30"}', 2, '[{"nome": "Lucas", "data_nascimento": "2017-06-18"}, {"nome": "Beatriz", "data_nascimento": "2020-11-02"}]', '123456789', '(11) 91234-5678', '07170-350', 'Avenida Monteiro', '250', NULL, 'Cumbica', 'Guarulhos', 'SP', 'bruno.costa@email.com', 'Masculino', NULL, NULL),
('Mariana Lima', 'Manobrista', 'ativo', 'Tranquility', 'Espaço HAOC', '2024-01-15', NULL, DATE_SUB(CURDATE(), INTERVAL 1 MONTH), DATE_ADD(CURDATE(), INTERVAL 5 MONTH), DATE_ADD(CURDATE(), INTERVAL 1 YEAR), NULL, '2001-03-12', '56.789.012-3', '345.678.901-23', 'Solteiro(a)', NULL, 0, NULL, '876543210', '(11) 98765-4321', '01307-002', 'Rua Frei Caneca', '1200', 'Apto 10', 'Consolação', 'São Paulo', 'SP', 'mariana.lima@email.com', 'Feminino', NULL, NULL),
('Carlos Eduardo Pereira', 'Segurança', 'ativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '2022-08-01', NULL, DATE_ADD(CURDATE(), INTERVAL 3 YEAR), DATE_SUB(CURDATE(), INTERVAL 15 DAY), DATE_ADD(CURDATE(), INTERVAL 1 YEAR), NULL, '1990-11-05', '12.345.678-9', '456.789.012-34', 'Divorciado(a)', NULL, 1, '[{"nome": "Gabriel", "data_nascimento": "2015-02-20"}]', '765432109', '(11) 97654-3210', '03102-002', 'Rua Visconde de Parnaíba', '1500', NULL, 'Mooca', 'São Paulo', 'SP', 'carlos.eduardo@email.com', 'Masculino', NULL, NULL),
('Rafaela Gomes', 'Atendimento', 'ativo', 'Tranquility', 'São Carlos - Santa Casa', '2025-08-18', NULL, NULL, DATE_ADD(CURDATE(), INTERVAL 10 MONTH), DATE_ADD(CURDATE(), INTERVAL 1 YEAR), DATE_ADD(CURDATE(), INTERVAL 10 DAY), '2003-02-25', '23.456.789-0', '567.890.123-45', 'Solteiro(a)', NULL, 0, NULL, NULL, '(16) 96543-2109', '13560-231', 'Rua Paulino dos Santos', '500', NULL, 'Centro', 'São Carlos', 'SP', 'rafaela.gomes@email.com', 'Feminino', NULL, NULL),
('Lucas Martins', 'Manobrista', 'ativo', 'Tranquility', 'IGESP - Pronto Atendimento Congonhas', '2023-12-01', NULL, DATE_ADD(CURDATE(), INTERVAL 6 MONTH), DATE_ADD(CURDATE(), INTERVAL 6 MONTH), DATE_ADD(CURDATE(), INTERVAL 1 YEAR), NULL, CONCAT('1999-', LPAD(MONTH(CURDATE()), 2, '0'), '-05'), '56.321.789-4', '890.123.456-78', 'Solteiro(a)', NULL, 0, NULL, '432109876', '(11) 93210-9876', '04626-000', 'Avenida Washington Luís', 'S/N', NULL, 'Vila Congonhas', 'São Paulo', 'SP', 'lucas.martins@email.com', 'Masculino', NULL, NULL),
-- Empresa: GSM (5)
('Juliana Santos', 'Supervisora', 'ativo', 'GSM', 'Grupo Santa Marcelina Itaquera - Sede', '2019-06-25', NULL, DATE_ADD(CURDATE(), INTERVAL 2 YEAR), DATE_ADD(CURDATE(), INTERVAL 8 MONTH), DATE_ADD(CURDATE(), INTERVAL 1 YEAR), NULL, '1992-04-18', '45.678.901-2', '789.012.345-67', 'Casado(a)', '{"nome": "Ricardo Mendes", "data_nascimento": "1991-03-15"}', 0, NULL, '543210987', '(11) 94321-0987', '08270-070', 'Rua Santa Marcelina', '177', NULL, 'Vila Carmosina', 'São Paulo', 'SP', 'juliana.santos@email.com', 'Feminino', NULL, NULL),
('Thiago Rocha', 'Segurança', 'ativo', 'GSM', 'Grupo Santa Marcelina Itaquera - AME', '2023-09-18', NULL, DATE_ADD(CURDATE(), INTERVAL 1 YEAR), DATE_ADD(CURDATE(), INTERVAL 11 MONTH), DATE_SUB(CURDATE(), INTERVAL 2 MONTH), NULL, '1997-06-20', '23.876.543-2', '012.345.678-90', 'Solteiro(a)', NULL, 0, NULL, '321098765', '(11) 91098-7654', '08270-070', 'Rua Santa Marcelina', '180', NULL, 'Vila Carmosina', 'São Paulo', 'SP', 'thiago.rocha@email.com', 'Masculino', NULL, NULL),
('Larissa Mendes', 'Líder de Equipe', 'ativo', 'GSM', 'Grupo Santa Marcelina Itaquera - Instituto', '2018-07-30', NULL, DATE_ADD(CURDATE(), INTERVAL 4 YEAR), DATE_ADD(CURDATE(), INTERVAL 9 MONTH), DATE_ADD(CURDATE(), INTERVAL 1 YEAR), NULL, '1993-08-01', '34.765.432-1', '123.456.789-00', 'Casado(a)', '{"nome": "Felipe Souza", "data_nascimento": "1992-07-10"}', 1, '[{"nome": "Sofia", "data_nascimento": "2023-04-11"}]', '210987654', '(11) 90987-6543', '08270-070', 'Rua Santa Marcelina', '190', NULL, 'Vila Carmosina', 'São Paulo', 'SP', 'larissa.mendes@email.com', 'Feminino', NULL, NULL),
('Roberto Dias', 'Manobrista', 'ativo', 'GSM', 'Grupo Santa Marcelina Itaquera - Torre', '2024-03-01', NULL, DATE_ADD(CURDATE(), INTERVAL 1 YEAR), DATE_ADD(CURDATE(), INTERVAL 1 YEAR), DATE_ADD(CURDATE(), INTERVAL 1 YEAR), DATE_SUB(CURDATE(), INTERVAL 20 DAY), '1996-10-28', '45.654.321-0', '234.567.890-11', 'Divorciado(a)', NULL, 0, NULL, '109876543', '(11) 99876-5432', '08270-070', 'Rua Santa Marcelina', '200', NULL, 'Vila Carmosina', 'São Paulo', 'SP', 'roberto.dias@email.com', 'Masculino', NULL, NULL),
('Rodrigo Nogueira', 'Analista Financeiro', 'ativo', 'GSM', 'Grupo Santa Marcelina Itaquera - Faculdade Santa Marcelina', '2022-10-03', NULL, NULL, DATE_ADD(CURDATE(), INTERVAL 1 YEAR), DATE_ADD(CURDATE(), INTERVAL 2 YEAR), NULL, '1991-05-14', '22.333.444-5', '555.666.777-88', 'Casado(a)', '{"nome": "Camila Nogueira", "data_nascimento": "1992-06-20"}', 0, NULL, NULL, '(11) 98765-1111', '08270-070', 'Rua Santa Marcelina', '210', NULL, 'Vila Carmosina', 'São Paulo', 'SP', 'rodrigo.n@email.com', 'Masculino', NULL, NULL),
-- Empresa: Protector (5)
('Sofia Bernardes', 'Jovem Aprendiz', 'ativo', 'Protector', 'Grupo Santa Marcelina Regionais - Hospital Cidade Tiradentes', '2025-08-18', NULL, NULL, DATE_ADD(CURDATE(), INTERVAL 25 DAY), DATE_ADD(CURDATE(), INTERVAL 1 YEAR), DATE_ADD(CURDATE(), INTERVAL 60 DAY), '2005-08-19', '55.444.333-2', '888.777.666-55', 'Solteiro(a)', NULL, 0, NULL, NULL, '(11) 95555-4444', '08471-410', 'Avenida dos Metalúrgicos', '2300', NULL, 'Cidade Tiradentes', 'São Paulo', 'SP', 'sofia.b@email.com', 'Feminino', NULL, NULL),
('Ricardo Andrade', 'Coordenador de Operações', 'ativo', 'Protector', 'Grupo Santa Marcelina Regionais - Hospital Itaim', '2017-02-15', NULL, DATE_ADD(CURDATE(), INTERVAL 1 YEAR), DATE_ADD(CURDATE(), INTERVAL 7 MONTH), DATE_ADD(CURDATE(), INTERVAL 1 YEAR), NULL, '1982-01-25', '11.222.333-4', '444.555.666-77', 'Casado(a)', '{"nome": "Patrícia Andrade", "data_nascimento": "1984-03-10"}', 3, '[{"nome": "Gustavo", "data_nascimento": "2013-03-12"}, {"nome": "Helena", "data_nascimento": "2016-07-09"}, {"nome": "Miguel", "data_nascimento": "2021-01-04"}]', '554433221', '(11) 93333-2222', '08121-000', 'Avenida Marechal Tito', '6000', NULL, 'Itaim Paulista', 'São Paulo', 'SP', 'ricardo.a@email.com', 'Masculino', NULL, NULL),
('José Ferreira', 'Segurança', 'ativo', 'Protector', 'Grupo Santa Marcelina Regionais - Hospital Itaquá', '2015-09-01', NULL, DATE_ADD(CURDATE(), INTERVAL 6 MONTH), DATE_ADD(CURDATE(), INTERVAL 4 MONTH), DATE_ADD(CURDATE(), INTERVAL 1 YEAR), NULL, '1975-12-07', '66.777.888-9', '999.888.777-66', 'Viúvo(a)', NULL, 2, '[{"nome": "Eduardo", "data_nascimento": "2003-01-10"}, {"nome": "Letícia", "data_nascimento": "2006-05-25"}]', '998877665', '(11) 92222-1111', '08577-000', 'Rua Estados Unidos', '100', NULL, 'Vila Zeferina', 'Itaquaquecetuba', 'SP', 'jose.f@email.com', 'Masculino', NULL, NULL),
('Isabela Pereira', 'Assistente Administrativo', 'ativo', 'Protector', 'Grupo Santa Marcelina Regionais - Hospital Neomater SBC', '2023-08-20', NULL, NULL, DATE_ADD(CURDATE(), INTERVAL 10 MONTH), DATE_ADD(CURDATE(), INTERVAL 1 YEAR), NULL, '1999-11-30', '77.888.999-0', '111.222.333-44', 'Solteiro(a)', NULL, 0, NULL, NULL, '(11) 98123-4567', '09710-011', 'Rua Marechal Deodoro', '1200', NULL, 'Centro', 'São Bernardo do Campo', 'SP', 'isabela.p@email.com', 'Feminino', NULL, NULL),
('Fábio Junior Martins', 'Manobrista', 'ativo', 'Protector', 'IGESP - Pronto Atendimento Santo André', '2024-06-10', NULL, DATE_ADD(CURDATE(), INTERVAL 5 YEAR), DATE_ADD(CURDATE(), INTERVAL 1 YEAR), DATE_ADD(CURDATE(), INTERVAL 1 YEAR), DATE_ADD(CURDATE(), INTERVAL 20 DAY), '1994-04-04', NULL, NULL, 'Não informar', NULL, 0, NULL, '778899001', '(11) 96666-7777', '09015-020', 'Avenida Dom Pedro II', '500', NULL, 'Jardim', 'Santo André', 'SP', 'fabio.jm@email.com', 'Masculino', NULL, NULL),
-- Empresa: GS1 (4)
('Ana Luíza Vasconcelos', 'Recepcionista', 'ativo', 'GS1', 'São Carlos - CID', '2024-02-05', NULL, NULL, DATE_ADD(CURDATE(), INTERVAL 9 MONTH), DATE_ADD(CURDATE(), INTERVAL 1 YEAR), NULL, '2000-09-09', '99.000.111-2', '333.444.555-66', 'Casado(a)', '{"nome": "Pedro Vasconcelos", "data_nascimento": "1998-10-10"}', 0, NULL, NULL, '(16) 98888-9999', '13566-590', 'Passeio dos Flamboyants', '60', NULL, 'Parque Faber Castell I', 'São Carlos', 'SP', 'analu.v@email.com', 'Feminino', NULL, NULL),
('Samantha Jones', 'Consultora de RH', 'ativo', 'GS1', 'São Carlos - Onovolab', '2024-05-20', NULL, NULL, DATE_ADD(CURDATE(), INTERVAL 11 MONTH), DATE_ADD(CURDATE(), INTERVAL 1 YEAR), DATE_ADD(CURDATE(), INTERVAL 45 DAY), '1995-10-25', '21.222.333-4', '555.666.777-88', 'Divorciado(a)', NULL, 1, '[{"nome": "Leo", "data_nascimento": "2019-03-14"}]', NULL, '(16) 97777-1111', '13560-251', 'Avenida Doutor Carlos Botelho', '1800', NULL, 'Centro', 'São Carlos', 'SP', 'samantha.j@email.com', 'Outro', NULL, NULL),
('Vinicius Moraes', 'Manobrista', 'ativo', 'GS1', 'IGESP - Pronto Atendimento Anália Franco', '2023-03-15', NULL, DATE_ADD(CURDATE(), INTERVAL 2 YEAR), DATE_ADD(CURDATE(), INTERVAL 10 MONTH), DATE_ADD(CURDATE(), INTERVAL 1 YEAR), NULL, '1998-04-22', '33.444.555-6', '666.777.888-99', 'Solteiro(a)', NULL, 0, NULL, '665544332', '(11) 98888-7777', '03337-000', 'Rua Emília Marengo', '400', NULL, 'Vila Regente Feijó', 'São Paulo', 'SP', 'vinicius.m@email.com', 'Masculino', NULL, NULL),
('Tatiane Alves', 'Recepcionista', 'ativo', 'GS1', 'IGESP - Pronto Atendimento Santos', '2022-09-01', NULL, NULL, DATE_ADD(CURDATE(), INTERVAL 5 MONTH), DATE_ADD(CURDATE(), INTERVAL 1 YEAR), NULL, '1996-02-14', '44.555.666-7', '777.888.999-00', 'Solteiro(a)', NULL, 0, NULL, NULL, '(13) 97777-6666', '11060-002', 'Avenida Ana Costa', '400', NULL, 'Gonzaga', 'Santos', 'SP', 'tatiane.a@email.com', 'Feminino', NULL, NULL),

-- =================================== FUNCIONÁRIOS INATIVOS (20) ===================================
-- Empresa: Tranquility (5)
('Fernando Oliveira', 'Manobrista', 'inativo', 'Tranquility', 'Espaço HAOC', '2020-03-10', '2025-06-15', '2022-05-20', '2023-11-15', '2023-03-10', NULL, '1995-01-30', '34.123.567-8', '678.901.234-56', 'Solteiro(a)', NULL, 0, NULL, '654321098', '(11) 95432-1098', '01504-001', 'Rua Vergueiro', '1000', NULL, 'Liberdade', 'São Paulo', 'SP', 'fernando.o@email.com', 'Masculino', 'Baixo desempenho e faltas recorrentes.', 'Não'),
('Alexandre Peixoto', 'Manobrista', 'inativo', 'Tranquility', 'IGESP - Hospital Praia Grande', '2023-07-07', '2024-06-30', '2025-01-01', '2024-01-07', '2024-07-07', NULL, '1988-03-03', '10.111.222-3', '444.555.666-77', 'Solteiro(a)', NULL, 0, NULL, '334455667', '(11) 95555-6666', '11700-100', 'Avenida Presidente Costa e Silva', '800', NULL, 'Boqueirão', 'Praia Grande', 'SP', 'alexandre.p@email.com', 'Masculino', 'Pedido de demissão para outra oportunidade.', 'Sim'),
('Jorge Benario', 'Supervisor', 'inativo', 'Tranquility', 'Hapvida', '2019-11-11', '2023-12-20', '2023-01-15', '2023-05-11', '2022-11-11', NULL, '1980-01-01', '25.369.852-1', '741.852.963-22', 'Casado(a)', '{"nome": "Marta Benario", "data_nascimento": "1981-02-02"}', 1, '[{"nome": "Daniel", "data_nascimento": "2010-10-10"}]', '258963147', '(11) 98529-6314', '07190-100', 'Rodovia Hélio Smidt', 'S/N', NULL, 'Aeroporto', 'Guarulhos', 'SP', 'jorge.b@email.com', 'Masculino', 'Redução de quadro. Bom funcionário.', 'Avaliar'),
('William Bonner', 'Segurança', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '2018-03-25', '2023-10-05', '2023-01-01', '2023-03-25', '2022-03-25', NULL, '1984-06-12', '36.914.725-8', '963.741.852-55', 'Casado(a)', '{"nome": "Fátima Bernardes", "data_nascimento": "1985-07-13"}', 0, NULL, '987654321', '(11) 98765-4321', '03102-002', 'Rua Visconde de Parnaíba', '1600', NULL, 'Mooca', 'São Paulo', 'SP', 'william.b@email.com', 'Masculino', 'Aposentadoria.', 'Não'),
('Fátima Gomes', 'Recepcionista', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '2019-09-02', '2024-02-28', NULL, '2023-09-02', '2023-09-02', NULL, '1997-11-15', '14.258.369-1', '852.963.741-66', 'Solteiro(a)', NULL, 0, NULL, NULL, '(11) 93636-3636', '03102-002', 'Rua Visconde de Parnaíba', '1700', NULL, 'Mooca', 'São Paulo', 'SP', 'fatima.g@email.com', 'Feminino', 'Fim de contrato.', 'Sim'),
-- Empresa: GSM (5)
('Beatriz Almeida', 'Atendimento', 'inativo', 'GSM', 'Grupo Santa Marcelina Itaquera - Sede', '2022-02-20', '2025-08-17', NULL, '2024-01-10', '2024-02-20', NULL, '2000-12-10', '12.987.654-3', '901.234.567-89', 'Solteiro(a)', NULL, 0, NULL, NULL, '(11) 92109-8765', '08270-070', 'Rua Santa Marcelina', '177', NULL, 'Vila Carmosina', 'São Paulo', 'SP', 'beatriz.a@email.com', 'Feminino', 'Não se adaptou à cultura da empresa.', 'Não'),
('Eduardo Santos', 'Caixa', 'inativo', 'GSM', 'Grupo Santa Marcelina Itaquera - AME', '2021-04-12', '2024-05-30', NULL, '2023-10-01', '2023-04-12', NULL, '2002-07-07', '88.999.000-1', '222.333.444-55', 'Solteiro(a)', NULL, 0, NULL, NULL, '(11) 97777-8888', '08270-070', 'Rua Santa Marcelina', '180', NULL, 'Vila Carmosina', 'São Paulo', 'SP', 'eduardo.s@email.com', 'Masculino', 'Abandono de emprego.', 'Não'),
('Vanessa Ramos', 'Atendimento', 'inativo', 'GSM', 'Grupo Santa Marcelina Regionais - Hospital Cidade Tiradentes', '2021-06-14', '2024-01-15', NULL, '2023-06-14', '2023-06-14', NULL, '1999-07-19', '36.147.258-3', '963.852.741-11', 'Solteiro(a)', NULL, 0, NULL, NULL, '(11) 96396-3963', '08471-410', 'Avenida dos Metalúrgicos', '2300', NULL, 'Cidade Tiradentes', 'São Paulo', 'SP', 'vanessa.r@email.com', 'Feminino', 'Mudança de carreira.', 'Sim'),
('Otávio Mesquita', 'Gerente Regional', 'inativo', 'GSM', 'Grupo Santa Marcelina Itaquera - Sede', '2015-01-20', '2022-11-30', '2022-06-01', '2022-01-20', '2021-01-20', NULL, '1975-04-16', '14.725.836-9', '852.741.963-33', 'Divorciado(a)', NULL, 2, '[{"nome": "Carla", "data_nascimento": "2000-01-01"}, {"nome": "Pedro", "data_nascimento": "2003-03-03"}]', '369852147', '(11) 98585-8585', '08270-070', 'Rua Santa Marcelina', '177', NULL, 'Vila Carmosina', 'São Paulo', 'SP', 'otavio.m@email.com', 'Masculino', 'Reestruturação do setor.', 'Avaliar'),
('Carolina Diegues', 'Analista de RH', 'inativo', 'GSM', 'Grupo Santa Marcelina Itaquera - Sede', '2020-08-03', '2024-03-10', NULL, '2023-08-03', '2023-08-03', NULL, '1994-09-28', '25.836.914-7', '741.963.852-44', 'Solteiro(a)', NULL, 0, NULL, NULL, '(11) 91425-3678', '08270-070', 'Rua Santa Marcelina', '177', NULL, 'Vila Carmosina', 'São Paulo', 'SP', 'carolina.d@email.com', 'Feminino', 'Recebeu proposta melhor.', 'Sim'),
-- Empresa: Protector (5)
('Adriana Lima', 'Líder de Caixa', 'inativo', 'Protector', 'IGESP - Pronto Atendimento Santo André', '2019-05-20', '2025-07-30', NULL, '2025-05-20', '2025-05-20', NULL, '1991-03-15', '88.777.666-5', '556.657.758-09', 'Divorciado(a)', NULL, 1, '[{"nome": "Alice", "data_nascimento": "2015-06-01"}]', NULL, '(11) 98877-3344', '09015-020', 'Avenida Dom Pedro II', '510', NULL, 'Jardim', 'Santo André', 'SP', 'adriana.l@email.com', 'Feminino', 'Reestruturação de equipe e corte de custos.', 'Avaliar'),
('Julio Cesar Almeida', 'Líder de Atendimento', 'inativo', 'Protector', 'Grupo Santa Marcelina Regionais - Hospital Itaim', '2022-08-15', '2025-01-01', '2025-02-15', '2024-08-15', '2024-08-15', NULL, '1993-04-12', '33.222.111-0', '001.002.003-04', 'Solteiro(a)', NULL, 0, NULL, '123456789', '(11) 98765-1122', '08121-000', 'Avenida Marechal Tito', '6100', NULL, 'Itaim Paulista', 'São Paulo', 'SP', 'julio.cesar@email.com', 'Masculino', 'Problemas de relacionamento com a equipe.', 'Não'),
('Vanessa Martins', 'Recepcionista', 'inativo', 'Protector', 'Grupo Santa Marcelina Regionais - Hospital Itaquá', '2023-01-09', '2025-08-20', NULL, '2025-01-09', '2025-01-09', NULL, '2002-05-21', '44.333.222-1', '112.213.314-05', 'Solteiro(a)', NULL, 0, NULL, NULL, '(11) 95544-3322', '08577-000', 'Rua Estados Unidos', '110', NULL, 'Vila Zeferina', 'Itaquaquecetuba', 'SP', 'vanessa.m@email.com', 'Feminino', 'Pedido de demissão para mudança de cidade.', 'Sim'),
('Leandro Barbosa', 'Manobrista', 'inativo', 'Protector', 'Grupo Santa Marcelina Regionais - Hospital Neomater SBC', '2023-10-02', '2025-09-01', '2026-10-02', '2024-10-02', '2024-10-02', NULL, '1995-11-18', '55.444.333-2', '223.324.425-06', 'Casado(a)', '{"nome": "Cláudia Barbosa", "data_nascimento": "1996-10-05"}', 2, '[{"nome": "Davi", "data_nascimento": "2022-08-10"}, {"nome": "Heloísa", "data_nascimento": "2024-01-20"}]', '987654321', '(11) 93322-1100', '09710-011', 'Rua Marechal Deodoro', '1210', NULL, 'Centro', 'São Bernardo do Campo', 'SP', 'leandro.b@email.com', 'Masculino', 'Fim de contrato.', 'Avaliar'),
('Fernanda Gonçalves', 'Auxiliar Administrativo', 'inativo', 'Protector', 'Grupo Santa Marcelina Regionais - Hospital Cidade Tiradentes', '2024-01-22', '2025-07-22', NULL, '2025-01-22', '2025-01-22', NULL, '1999-06-03', '66.555.444-3', '334.435.536-07', 'Solteiro(a)', NULL, 0, NULL, NULL, '(11) 98877-6655', '08471-410', 'Avenida dos Metalúrgicos', '2310', NULL, 'Cidade Tiradentes', 'São Paulo', 'SP', 'fernanda.g@email.com', 'Feminino', 'Não cumpriu o período de experiência.', 'Não'),
-- Empresa: GS1 (5)
('Diego Souza', 'Manobrista', 'inativo', 'GS1', 'São Carlos - Santa Casa', '2024-03-01', '2025-02-28', '2026-03-01', '2025-03-01', '2025-03-01', NULL, '2004-02-10', '77.666.555-4', '445.546.647-08', 'Solteiro(a)', NULL, 0, NULL, '776655443', '(16) 94433-2211', '13560-231', 'Rua Paulino dos Santos', '510', NULL, 'Centro', 'São Carlos', 'SP', 'diego.s@email.com', 'Masculino', 'Recebeu outra proposta.', 'Sim'),
('Sérgio Lopes', 'Manobrista Noturno', 'inativo', 'GS1', 'São Carlos - CID', '2021-08-19', '2024-08-18', '2024-08-19', '2023-08-19', '2023-08-19', NULL, '1992-06-08', '66.777.888-9', '999.000.111-22', 'Divorciado(a)', NULL, 0, NULL, '221133445', '(16) 95555-4444', '13566-590', 'Passeio dos Flamboyants', '70', NULL, 'Parque Faber Castell I', 'São Carlos', 'SP', 'sergio.l@email.com', 'Masculino', 'Redução de quadro.', 'Avaliar'),
('Helena Martins', 'Recepcionista', 'inativo', 'GS1', 'São Carlos - Onovolab', '2023-11-05', '2025-05-04', NULL, '2024-11-05', '2024-11-05', NULL, '1997-01-20', '77.888.999-0', '000.111.222-33', 'Solteiro(a)', NULL, 0, NULL, NULL, '(16) 94444-3333', '13560-251', 'Avenida Doutor Carlos Botelho', '1810', NULL, 'Centro', 'São Carlos', 'SP', 'helena.m@email.com', 'Feminino', 'Insatisfação com o salário.', 'Avaliar'),
('Anderson Lima', 'Porteiro', 'inativo', 'GS1', 'IGESP - Pronto Atendimento Santos', '2020-10-20', '2025-04-19', NULL, '2024-10-20', '2024-10-20', NULL, '1986-07-14', '88.999.000-1', '111.222.333-44', 'Casado(a)', '{"nome": "Vanessa Lima", "data_nascimento": "1988-08-15"}', 1, '[{"nome": "Pedro", "data_nascimento": "2018-12-25"}]', NULL, '(13) 93333-2222', '11060-002', 'Avenida Ana Costa', '410', NULL, 'Gonzaga', 'Santos', 'SP', 'anderson.l@email.com', 'Masculino', 'Mudança de cidade.', 'Sim'),
('Gabriela Azevedo', 'Auxiliar de Serviços Gerais', 'inativo', 'GS1', 'IGESP - Hospital Praia Grande', '2023-01-30', '2025-01-29', NULL, '2024-01-30', '2024-01-30', NULL, '2001-05-18', '99.000.111-2', '222.333.444-55', 'Solteiro(a)', NULL, 0, NULL, NULL, '(13) 92222-1111', '11702-050', 'Avenida Marechal Mallet', '510', NULL, 'Canto do Forte', 'Praia Grande', 'SP', 'gabriela.a@email.com', 'Feminino', 'Justa causa - Faltas excessivas.', 'Não');

-- ETAPA 5: REATIVA A SEGURANÇA
SET SQL_SAFE_UPDATES = 1;

-- MENSAGEM DE SUCESSO
SELECT 'Tabelas limpas e 40 novos funcionários inseridos com sucesso!' AS Resultado;

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



-- ======================================================================================
-- PARTE 4: CONSULTAS (SELECTs) PARA DEMONSTRAÇÃO
-- ======================================================================================

-- 1️⃣ PAINEL DE CONTROLE GERENCIAL (Dashboard Rápido)
-- 💡 Utilidade: Mostra os indicadores mais importantes (KPIs) do RH em uma única tela. Ideal para a página inicial de um relatório ou para a diretoria.
SELECT 
    (SELECT COUNT(*) FROM funcionarios WHERE status = 'ativo') AS Total_Ativos,
    (SELECT COUNT(*) FROM funcionarios WHERE status = 'inativo') AS Total_Inativos,
    (SELECT COUNT(*) FROM funcionarios WHERE MONTH(data_nascimento) = MONTH(CURDATE()) AND status = 'ativo') AS Aniversariantes_do_Mes,
    (SELECT COUNT(*) FROM funcionarios WHERE validade_contrato_experiencia BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 30 DAY)) AS Exp_Vencendo_30_Dias,
    (SELECT COUNT(*) FROM funcionarios WHERE validade_cnh < CURDATE()) AS Total_CNHs_Vencidas;

-- ------------------------------------------------------------------------------------

-- 2️⃣ ALERTAS GERAIS DE DOCUMENTAÇÃO
-- 💡 Utilidade: A ferramenta mais poderosa para o RH! Consolida todas as pendências de todos os funcionários em um só lugar, permitindo ações rápidas e evitando multas ou problemas legais.
SELECT nome, 'CNH Vencida' AS Alerta, validade_cnh AS Data_Vencimento
FROM funcionarios WHERE status = 'ativo' AND validade_cnh < CURDATE()
UNION ALL
SELECT nome, 'Exame Médico Vencido' AS Alerta, validade_exame_medico AS Data_Vencimento
FROM funcionarios WHERE status = 'ativo' AND validade_exame_medico < CURDATE()
UNION ALL
SELECT nome, 'CCT Vencida' AS Alerta, validade_cct AS Data_Vencimento
FROM funcionarios WHERE status = 'ativo' AND validade_cct < CURDATE()
UNION ALL
SELECT nome, 'Contrato de Experiência a Vencer' AS Alerta, validade_contrato_experiencia AS Data_Vencimento
FROM funcionarios WHERE status = 'ativo' AND validade_contrato_experiencia BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 30 DAY)
ORDER BY Data_Vencimento ASC;

-- ------------------------------------------------------------------------------------

-- 3️⃣ DISTRIBUIÇÃO DE FUNCIONÁRIOS POR UNIDADE
-- 💡 Utilidade: Ajuda a gestão a entender a alocação de pessoal e onde a maior parte da equipe está concentrada, facilitando o planejamento de recursos.
SELECT 
    local AS Unidade,
    COUNT(*) AS Quantidade_de_Funcionarios,
    SUM(CASE WHEN status = 'ativo' THEN 1 ELSE 0 END) AS Ativos,
    SUM(CASE WHEN status = 'inativo' THEN 1 ELSE 0 END) AS Inativos
FROM funcionarios
GROUP BY local
ORDER BY Quantidade_de_Funcionarios DESC;

-- ------------------------------------------------------------------------------------

-- 4️⃣ ANÁLISE DE TEMPO DE CASA (SENIORIDADE)
-- 💡 Utilidade: Mostra quem são os funcionários mais antigos e mais novos, útil para programas de reconhecimento ou integração.
SELECT
    nome,
    funcao,
    data_admissao,
    CONCAT(
        TIMESTAMPDIFF(YEAR, data_admissao, CURDATE()), ' anos e ',
        MOD(TIMESTAMPDIFF(MONTH, data_admissao, CURDATE()), 12), ' meses'
    ) AS Tempo_de_Casa
FROM funcionarios
WHERE status = 'ativo'
ORDER BY data_admissao ASC;

-- ------------------------------------------------------------------------------------

-- 5️⃣ ANÁLISE DEMOGRÁFICA POR ESTADO CIVIL
-- 💡 Utilidade: Fornece uma visão da composição da empresa, útil para planejamento de benefícios e eventos corporativos.
SELECT 
    estado_civil,
    COUNT(*) as Total,
    ROUND((COUNT(*) / (SELECT COUNT(*) FROM funcionarios WHERE status = 'ativo' AND estado_civil IS NOT NULL AND estado_civil != '')) * 100, 1) AS 'Porcentagem (%)'
FROM funcionarios
WHERE status = 'ativo' AND estado_civil IS NOT NULL AND estado_civil != ''
GROUP BY estado_civil
ORDER BY Total DESC;

-- ------------------------------------------------------------------------------------

-- 6️⃣ LISTA COMPLETA DE FUNCIONÁRIOS ATIVOS
-- 💡 Utilidade: A visão padrão para o dia a dia, mostrando quem faz parte da equipe atualmente.
SELECT id, nome, funcao, local, telefone_1, email_pessoal
FROM funcionarios
WHERE status = 'ativo'
ORDER BY nome ASC;

-- ------------------------------------------------------------------------------------

-- 7️⃣ HISTÓRICO DE FUNCIONÁRIOS INATIVOS
-- 💡 Utilidade: Permite consultar o histórico de ex-funcionários, suas funções e datas de desligamento.
SELECT nome, funcao, data_admissao, data_demissao
FROM funcionarios
WHERE status = 'inativo'
ORDER BY data_demissao DESC;

-- ------------------------------------------------------------------------------------

-- 8️⃣ CONSULTA DE HISTÓRICO DE PONTO DE UMA UNIDADE
-- 💡 Utilidade: Permite analisar a frequência de uma unidade específica ao longo do tempo. (Lembre-se de trocar os valores de exemplo).
SELECT data, presentes, falta_injustificada, atestado, folga
FROM status_diario
WHERE unidade = 'Garagem Centro' -- << Troque pelo nome da unidade desejada
ORDER BY data DESC;

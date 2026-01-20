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
  `tamanho_camisa` VARCHAR(10) DEFAULT NULL,
  `tamanho_calca` VARCHAR(10) DEFAULT NULL,
  `tamanho_jaqueta` VARCHAR(10) DEFAULT NULL,
  `tamanho_bota` VARCHAR(10) DEFAULT NULL,
  `data_entrega_uniforme` DATE DEFAULT NULL,
  `data_devolucao_uniforme` DATE DEFAULT NULL,
  `data_reposicao_uniforme` DATE DEFAULT NULL,
  `motivo_reposicao_uniforme` TEXT DEFAULT NULL,
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
-- Tabela 3: `logs`
-- Quem fez o que no sistema.
--
CREATE TABLE `logs` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `usuario_id` INT DEFAULT NULL,
  `usuario_nome` VARCHAR(255) DEFAULT NULL,
  `acao` VARCHAR(50) NOT NULL,
  `detalhes` TEXT DEFAULT NULL,
  `data_hora` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


--
-- Tabela 4: `pastas`
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
-- Tabela 5: `documentos`
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
    
    
    
    
    
    
    
    
    
    
    
    
    
  
  
  -- GS1

INSERT INTO `funcionarios` (
    `nome`, `funcao`, `status`, `empresa`, `local`, `horario`, 
    `data_admissao`, `data_inicio`, `data_demissao`, `data_nascimento`, 
    `genero`, `rg`, `cpf`, `pis`, `cnh_numero`, 
    `estado_civil`, `dados_conjuge`, `quantidade_filhos`, `nome_filhos`, 
    `email_pessoal`, `telefone_1`, `telefone_2`, `telefone_3`, 
    `cep`, `rua`, `numero`, `complemento`, `bairro`, `cidade`, `estado`, 
    `opcao_transporte`, `meio_transporte`, `qtd_transporte`, `valor_transporte`, 
    `data_entrega_uniforme`, `data_devolucao_uniforme`, `data_reposicao_uniforme`, `motivo_reposicao_uniforme`, 
    `tamanho_camisa`, `tamanho_calca`, `tamanho_jaqueta`, `tamanho_bota`, 
    `validade_cnh`, `validade_exame_clinico`, `validade_audiometria`, `validade_eletrocardiograma`, 
    `validade_eletroencefalograma`, `validade_glicemia`, `validade_acuidade_visual`, 
    `validade_treinamento`, `validade_contrato_experiencia`, 
    `motivo_demissao`, `elegivel_recontratacao`
) VALUES 
-- 1. Luiz Claudio Bastos Gomide
(
    'Luiz Claudio Bastos Gomide',
    'Lavador De Veículos',
    'ativo',
    'GS1',
    'GS1',
    '08:00 às 18:00',
    '2025-02-03', '2025-02-03', NULL, '1977-11-02',
    'Masculino',
    '29.356.517-X', '274.495.028-95', '126.28967.85-7', NULL,
    'Solteiro(a)',
    NULL, 
    1, '[{"nome": "Luiz Henrique", "data_nascimento": "2004-01-06"}]',
    'LC3325577@gmail.com', '(11) 96072-5666', '(11) 96423-2125', '(11) 91857-5270',
    '08330-390', 'Rua Ursa Maior', '111', 'Casa', 'Cidade Satelite Santa Barbara', 'São Paulo', 'SP',
    'Vale Transporte', 'Onibus', 2, '10.71',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, '40',
    NULL, '2026-01-29', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 2. Diego Ferreira Izaias
(
    'Diego Ferreira Izaias',
    'Lavador De Veículos',
    'ativo',
    'GS1',
    'GS1',
    '08:00 às 18:00',
    '2025-02-14', '2025-02-14', NULL, '2003-05-14',
    'Masculino',
    '38.609.727-6', '524.773.198-09', '268.62462.48-0', '78150611203',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    NULL, '(11) 96038-3232', NULL, NULL,
    '08246-070', 'Rua Goiata', '153', 'Casa', 'Parada XV De Novembro', 'São Paulo', 'SP',
    'Vale Transporte', 'Onibus, Metro', 4, '21.40',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, '43',
    '2031-05-27', '2026-02-11', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 3. Carlos Alberto De Mello Turini
(
    'Carlos Alberto De Mello Turini',
    'Encarregado',
    'ativo',
    'GS1',
    'GS1',
    '08:00 às 18:00',
    '2023-02-01', '2023-02-01', NULL, '1993-06-11',
    'Masculino',
    '49.329.116-7', '402.569.218-06', '210.69067.24-7', NULL,
    'Solteiro(a)',
    NULL, 
    1, '[{"nome": "Ana Beatriz Silva Turini", "data_nascimento": "2019-02-18"}]',
    NULL, NULL, NULL, NULL,
    '08121-460', 'Rua Felizardo Ribeiro Lisboa', '40', 'Casa', 'Jardim Camargo Novo', 'São Paulo', 'SP',
    'Não Optante', NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    NULL, '2026-02-04', NULL, NULL, NULL, NULL, NULL,
    '2026-02-04', NULL,
    NULL, NULL
),

-- 4. Wosley Alves Marcelo
(
    'Wosley Alves Marcelo',
    'Instalador De Acessórios',
    'ativo',
    'GS1',
    'GS1',
    '08:00 às 18:00',
    '2023-11-14', '2023-11-14', NULL, '1979-04-22',
    'Masculino',
    '28.470.771-2', '067.031.528-37', NULL, '02365927669',
    'Casado(a)',
    '{"nome": "Girlangela Macena Venancio", "data_nascimento": "1981-07-24"}', 
    2, '[{"nome": "Wesley Alves Marcelo Macena", "data_nascimento": "2011-10-06"}, {"nome": "Emily Alves Macena", "data_nascimento": "2017-08-26"}]',
    'Wosleytop12@gmail.com', '(11) 93011-6135', NULL, NULL,
    '02857-090', 'Rua O', '78', 'Casa 2', 'Jardim Vitória Régia', 'São Paulo', 'SP',
    'Não Optante', NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2033-03-23', NULL, NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
);
















-- Protector

INSERT INTO `funcionarios` (
    `nome`, `funcao`, `status`, `empresa`, `local`, `horario`, 
    `data_admissao`, `data_inicio`, `data_demissao`, `data_nascimento`, 
    `genero`, `rg`, `cpf`, `pis`, `cnh_numero`, 
    `estado_civil`, `dados_conjuge`, `quantidade_filhos`, `nome_filhos`, 
    `email_pessoal`, `telefone_1`, `telefone_2`, `telefone_3`, 
    `cep`, `rua`, `numero`, `complemento`, `bairro`, `cidade`, `estado`, 
    `opcao_transporte`, `meio_transporte`, `qtd_transporte`, `valor_transporte`, 
    `data_entrega_uniforme`, `data_devolucao_uniforme`, `data_reposicao_uniforme`, `motivo_reposicao_uniforme`, 
    `tamanho_camisa`, `tamanho_calca`, `tamanho_jaqueta`, `tamanho_bota`, 
    `validade_cnh`, `validade_exame_clinico`, `validade_audiometria`, `validade_eletrocardiograma`, 
    `validade_eletroencefalograma`, `validade_glicemia`, `validade_acuidade_visual`, 
    `validade_treinamento`, `validade_contrato_experiencia`, 
    `motivo_demissao`, `elegivel_recontratacao`
) VALUES 
-- 1. Viviane Aparecida Camilo Peckolt Campos
(
    'Viviane Aparecida Camilo Peckolt Campos',
    'Coordenadora De Estacionamento',
    'ativo',
    'Protector',
    'São Carlos - Santa Casa',
    '06:30 às 18:30',
    '2021-07-23', '2021-07-23', NULL, '1974-03-21',
    'Feminino',
    '22.645.813-1', '191.418.928-01', '124.10442.48-1', '2262189671',
    'Casado(a)',
    '{"nome": "Vinícius Peckolt Campos", "data_nascimento": "1976-04-29"}', 
    2, '[{"nome": "Heloisa Camilo Malerva", "data_nascimento": "2003-01-27"}, {"nome": "Helena Camilo Peckolt Campos", "data_nascimento": "2015-04-01"}]',
    NULL, '(16) 99733-4509', NULL, NULL,
    '13566-730', 'Rua Porti Rico', '1402', 'Casa', 'Jardim Brasilia', 'São Carlos', 'SP',
    'Vale Transporte', 'Onibus', 2, '8.20',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2026-01-01', '2025-11-19', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 2. Sandra Aparecida Dos Santos Fernandes
(
    'Sandra Aparecida Dos Santos Fernandes',
    'Operador De Estacionamento',
    'ativo',
    'Protector',
    'São Carlos - Santa Casa',
    '07:00 às 17:00',
    '2025-08-01', '2025-08-01', NULL, '1977-09-17',
    'Feminino',
    '29.464.639-5', '141.821.378-09', '127.30803.16-7', '4414436684',
    'Casado(a)',
    '{"nome": "Carlos Henrique Fernandes", "data_nascimento": "1969-04-25"}', 
    1, '[{"nome": "Ana Maria Fernandes", "data_nascimento": "2004-12-21"}]',
    NULL, NULL, NULL, NULL,
    '13569-270', 'Rua Eugenio Franco De Camargo', '1200', 'AP 136', 'Jardim Brasilia', 'São Carlos', 'SP',
    'Auxílio Combustível', NULL, NULL, '100.00',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2033-03-21', '2026-07-28', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 3. Leandro Eduardo Ortiz
(
    'Leandro Eduardo Ortiz',
    'Operador De Estacionamento',
    'ativo',
    'Protector',
    'São Carlos - Santa Casa',
    '06:30 às 18:30',
    '2025-04-25', '2025-04-25', NULL, '1996-09-19',
    'Masculino',
    '45.936.614-2', '446.833.078-39', '267.79553.93-8', '6368604010',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    NULL, '(16) 98208-9790', '(16) 3361-1560', '(16) 99942-0441',
    '13564-520', 'Rua Rodolpho Luporini', '320', 'Casa', 'Parque Industrial', 'São Carlos', 'SP',
    'Não Optante', NULL, NULL, NULL,
    '2025-04-25', NULL, NULL, NULL,
    'GG', NULL, NULL, '42',
    '2035-02-05', NULL, NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 4. Jose Eduardo De Oliveira Da Silva Filho
(
    'Jose Eduardo De Oliveira Da Silva Filho',
    'Operador De Estacionamento',
    'ativo',
    'Protector',
    'São Carlos - Santa Casa',
    '18:30 às 06:30',
    '2025-03-07', '2025-03-07', NULL, '2003-07-08',
    'Masculino',
    '57.943.495-3', '566.457.098-97', '143.05992.55-4', NULL,
    'Solteiro(a)',
    NULL, 
    0, NULL,
    'je8710375@gmail.com', '(16) 99374-0861', '(16) 99744-5891', NULL,
    '13575-570', 'Avenida Marcello Foccorini', '13', 'Casa', 'Jardim Das Torres', 'São Carlos', 'SP',
    'Auxílio Combustível', NULL, NULL, '100.00',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2031-07-19', '2026-03-06', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 5. Carlos Roberto Malerva
(
    'Carlos Roberto Malerva',
    'Operador De Estacionamento',
    'ativo',
    'Protector',
    'São Carlos - Santa Casa',
    '06:30 às 18:30',
    '2022-08-22', '2022-08-22', NULL, '1996-11-04',
    'Masculino',
    '17.551.685-6', '098.910.608-02', '123.64853.80-1', '3468023855',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    NULL, NULL, NULL, NULL,
    '13561-180', 'Rua Maestro João Seppe', '603', 'Casa', 'Jardim Paraíso', 'São Carlos', 'SP',
    'Auxílio Combustível', NULL, NULL, '100.00',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2026-01-01', '2025-11-19', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 6. Aparecido Luiz Pereira Do Amaral
(
    'Aparecido Luiz Pereira Do Amaral',
    'Operador De Estacionamento',
    'ativo',
    'Protector',
    'São Carlos - Santa Casa',
    '06:30 às 18:30',
    '2025-07-11', '2025-07-11', NULL, '1986-03-05',
    'Masculino',
    '45.650.334-1', '356.114.508-65', '206.61109.45-8', '4890955933',
    'Solteiro(a)',
    NULL, 
    1, '[{"nome": "Ana Laura Russo Do Amaral", "data_nascimento": "2012-12-31"}]',
    'cidopamaral@gmail.com', '(16) 99720-8290', '(16) 99260-3764', NULL,
    '13560-000', 'Rua Soldado Eliseu Da Silva', '765', 'QT 31 Lote 26', 'Residencial Deputado Jose Zavaglia', 'São Carlos', 'SP',
    'Auxílio Combustível', NULL, NULL, '100.00',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2034-08-07', '2026-07-10', '2026-07-10', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 7. Andre Henrique Victor Da Silva
(
    'Andre Henrique Victor Da Silva',
    'Operador De Estacionamento',
    'ativo',
    'Protector',
    'São Carlos - Santa Casa',
    '06:30 às 18:30',
    '2025-03-28', '2025-03-28', NULL, '2003-11-17',
    'Masculino',
    '59.345.434-4', '045.624.523-82', '320.78737.32-2', '78631486412',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    'andrevics@gmail.com', '(16) 99106-0738', '(16) 99358-6894', '(16) 99432-6216',
    '13563-303', 'Rua Domingos Diegues', '209', 'Casa', 'Parque Santa Felicia Jardim', 'São Carlos', 'SP',
    'Auxílio Combustível', NULL, NULL, '100.00',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2026-01-01', '2026-03-27', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 8. Alan Cesar Marolde
(
    'Alan Cesar Marolde',
    'Operador De Estacionamento',
    'ativo',
    'Protector',
    'São Carlos - Santa Casa',
    '07:30 às 17:30',
    '2025-09-24', '2025-09-24', NULL, '1997-04-23',
    'Masculino',
    '45.487.617-8', '404.451.138-12', '134.41084.83-6', '07028264211',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    NULL, '(19) 98997-9947', '(19) 99924-3202', NULL,
    '13575-332', 'Rua Doutor Pedro Raimundo', '270', 'Casa', 'Vila Carmem', 'São Carlos', 'SP',
    'Auxílio Combustível', NULL, NULL, '100.00',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2026-09-19', '2026-09-19', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
);




























-- Tranquility

INSERT INTO `funcionarios` (
    `nome`, `funcao`, `status`, `empresa`, `local`, `horario`, 
    `data_admissao`, `data_inicio`, `data_demissao`, `data_nascimento`, 
    `genero`, `rg`, `cpf`, `pis`, `cnh_numero`, 
    `estado_civil`, `dados_conjuge`, `quantidade_filhos`, `nome_filhos`, 
    `email_pessoal`, `telefone_1`, `telefone_2`, `telefone_3`, 
    `cep`, `rua`, `numero`, `complemento`, `bairro`, `cidade`, `estado`, 
    `opcao_transporte`, `meio_transporte`, `qtd_transporte`, `valor_transporte`, 
    `data_entrega_uniforme`, `data_devolucao_uniforme`, `data_reposicao_uniforme`, `motivo_reposicao_uniforme`, 
    `tamanho_camisa`, `tamanho_calca`, `tamanho_jaqueta`, `tamanho_bota`, 
    `validade_cnh`, `validade_exame_clinico`, `validade_audiometria`, `validade_eletrocardiograma`, 
    `validade_eletroencefalograma`, `validade_glicemia`, `validade_acuidade_visual`, 
    `validade_treinamento`, `validade_contrato_experiencia`, 
    `motivo_demissao`, `elegivel_recontratacao`
) VALUES 
-- 1. Luiz Henrique Da Silva Reis
(
    'Luiz Henrique Da Silva Reis',
    'Operador De Estacionamento',
    'ativo',
    'Tranquility',
    'IGESP - Pronto Atendimento Congonhas',
    '06:30 as 15:30',
    '2024-09-06', '2024-09-06', NULL, '1995-06-25',
    'Masculino',
    '47.899.541-6', '443.105.318-22', '207.24647.67-2', '6251038620',
    'Solteiro(a)',
    NULL, 
    2, '[{"nome": "Sofia Aguiar da Silva Reis", "data_nascimento": "2021-03-19"}, {"nome": "Isaac Gabriel Aguiar Reis", "data_nascimento": "2016-10-09"}]',
    'henriquepereirazk@gmail.com', '(11) 97703-8200', '(11) 24568-100', NULL,
    '05813-045', 'Rua Um', '195', 'Casa', 'Jardim São Luis', 'São Paulo', 'SP',
    'Auxílio Combustível', NULL, NULL, '120.00',
    '2025-02-18', NULL, NULL, NULL,
    'G', '42', 'G', '40',
    '2033-11-21', '2025-07-05', '2025-07-05', '2026-07-05', '2026-07-05', '2025-07-05', '2025-07-05',
    NULL, NULL,
    NULL, NULL
),

-- 2. Adolpho Pereira De Aguiar
(
    'Adolpho Pereira De Aguiar',
    'Operador De Estacionamento',
    'ativo',
    'Tranquility',
    'IGESP - Pronto Atendimento Congonhas',
    '06:30 as 15:30',
    '2024-09-13', '2024-09-13', NULL, '1987-04-20',
    'Masculino',
    '40.642.049-X', '361.095.408-62', '134.84899.81-5', '3665393180',
    'Divorciado(a)',
    NULL, 
    0, NULL,
    'finho65ff@gmail.com', '(11) 95878-4959', '(11) 40565-295', NULL,
    '09910-460', 'Rua Visconde De Inhauma', '59', 'Casa 2', 'Jardim Rey', 'Diadema', 'SP',
    'Auxílio Combustível', NULL, NULL, '120.00',
    '2025-02-10', NULL, NULL, NULL,
    'G', '42', 'M', '41',
    '2031-06-22', '2025-09-12', '2025-09-12', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 3. Aldivan Da Silva
(
    'Aldivan Da Silva',
    'Operador De Estacionamento',
    'ativo',
    'Tranquility',
    'Prevent Sênior - Hospital Madri',
    '22:00 as 06:00',
    '2025-01-23', '2025-01-23', NULL, '1982-07-14',
    'Masculino',
    '39.998.886-5', '306.654.088-03', '131.00064.60-6', '3641496840',
    'Solteiro(a)',
    NULL, 
    1, '[{"nome": "Ryan Carvalho da Silva", "data_nascimento": "2012-07-25"}]',
    'aldivansilva391@gmail.com', '(11) 99368-7206', '(11) 24568-100', NULL,
    '05840-020', 'Rua Aristodemo Gazzoti', '94', 'Casa 9', 'Vila Das Belezas', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus, Metrô', 4, '21.42',
    '2025-01-23', NULL, NULL, NULL,
    'GG', '42', 'M', '40',
    '2033-01-20', '2026-01-21', '2026-01-21', '2026-02-23', '2026-02-23', '2025-02-23', '2025-02-23',
    NULL, NULL,
    NULL, NULL
),

-- 4. Andre Henrique Comitre Montanher
(
    'Andre Henrique Comitre Montanher',
    'Operador De Estacionamento',
    'ativo',
    'Tranquility',
    'Prevent Sênior - Hospital Madri',
    '14:00 as 22:20',
    '2024-11-19', '2024-11-19', NULL, '1990-12-03',
    'Masculino',
    '36.379.949-7', '358.097.918-32', '212.20110.77-0', '04622491311',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    'ahc.montanher@gmail.com', '(11) 96853-2823', '(11) 96871-7553', NULL,
    '08061-310', 'Rua Caramboleira', '159', 'Casa 2', 'Jardim Pedro Jose Nunes', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus, Metrô', 4, '19.66',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, '42',
    '2029-05-04', '2025-11-18', '2025-11-18', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 5. Andre Luis Dos Santos
(
    'Andre Luis Dos Santos',
    'Operador De Estacionamento',
    'ativo',
    'Tranquility',
    'IGESP - Hospital Praia Grande',
    '14:00 as 22:20',
    '2024-12-13', '2024-12-13', NULL, '1977-03-31',
    'Masculino',
    '25.828.538-2', '264.049.428-79', '125.10030.49-5', '01724931042',
    'Casado(a)',
    '{"nome": "Geane Lima de França", "data_nascimento": "1979-08-31"}', 
    2, '[{"nome": "Jaqueline Lais Lima dos Santos", "data_nascimento": "1996-09-14"}, {"nome": "João Vitor Lima dos Santos", "data_nascimento": "2002-05-02"}]',
    'a0536088@gmail.com', '(11) 97790-2272', '(11) 95267-9357', NULL,
    '11717-075', 'Rua Lazurita', '489', 'Casa', 'Nova Mirim', 'Praia Grande', 'SP',
    'Vale Transporte', 'Ônibus', 2, '12.50',
    '2025-04-24', NULL, NULL, NULL,
    'G', '50', 'EG', '42',
    '2033-10-04', NULL, NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 6. Antonia Vitoria De Lima Moreira
(
    'Antonia Vitoria De Lima Moreira',
    'Operador De Caixa',
    'ativo',
    'Tranquility',
    'Prevent Sênior - Hospital Madri',
    '07:00 as 14:00',
    '2024-11-23', '2024-11-23', NULL, '2002-01-19',
    'Feminino',
    '20.087.861-9', '075.547.033-82', '238.68504.15-6', NULL,
    'Solteiro(a)',
    NULL, 
    0, NULL,
    'v948081878@gmail.com', '(11) 94999-0860', '(11) 24568-100', NULL,
    '01321-020', 'Rua Vicente Prado', '124', 'Casa', 'Bela Vista', 'São Paulo', 'SP',
    'Não Optante', NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    NULL, '2025-12-10', '2025-07-11', NULL, NULL, NULL, '2025-07-11',
    NULL, NULL,
    NULL, NULL
),

-- 7. Luiz Americo Nicolo Vasone
(
    'Luiz Americo Nicolo Vasone',
    'Operador De Estacionamento',
    'ativo',
    'Tranquility',
    'Prevent Sênior - Hospital Madri',
    '14:00 as 22:20',
    '2025-11-12', '2025-11-12', NULL, '1972-10-22',
    'Masculino',
    '21.768.266-2', '118.060.208-07', '122.98697.49-5', '03550836545',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    'luizvasone@gmail.com', '(11) 98677-5736', NULL, NULL,
    '05532-000', 'Rua Jacob Maris', '369', 'Casa', 'Butantã', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus, Metrô', 4, '21.42',
    '2025-11-12', NULL, NULL, NULL,
    'G', '42', 'M', NULL,
    '2030-01-15', '2026-11-10', '2026-11-10', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 8. Marcos Luis Lacerda Arrais
(
    'Marcos Luis Lacerda Arrais',
    'Operador De Estacionamento',
    'ativo',
    'Tranquility',
    'Prevent Sênior - Hospital Madri',
    '14:00 as 22:20',
    '2025-09-08', '2025-09-08', NULL, '1970-01-03',
    'Masculino',
    '23.470.683-1', '249.602.048-18', '123.87823.20-7', '379611962',
    'Casado(a)',
    '{"nome": "Marli Marques Arrais", "data_nascimento": "1960-02-01"}', 
    0, NULL,
    NULL, '(11) 98744-8658', NULL, NULL,
    '08410-280', 'Rua Tupinambaras', '33', 'Casa 1', 'Vila Lourdes', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus, Trem', 4, '21.42',
    '2025-09-08', NULL, NULL, NULL,
    'P', '38', 'P', '38',
    '2025-11-23', '2026-09-08', '2026-09-08', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 9. Nicolas Henrique Batista De Souza
(
    'Nicolas Henrique Batista De Souza',
    'Operador De Estacionamento',
    'afastado',
    'Tranquility',
    'IGESP - Hospital Praia Grande',
    '10:00 às 18:20',
    '2025-04-03', '2025-04-03', NULL, '2004-01-28',
    'Masculino',
    '39.174.399-5', '241.610.528-04', '237.26391.25-4', '08346074912',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    'nicolashenrique.ana3005@gmail.com', '(13) 98167-3414', '(11) 94329-7956', '(11) 95130-9216',
    '11705-360', 'Rua José Agapito Cardoso', '326', 'Casa', 'Maracanã', 'Praia Grande', 'SP',
    'Auxílio Combustível', NULL, NULL, '150.00',
    '2025-04-03', NULL, NULL, NULL,
    'M', '40', 'M', NULL,
    '2033-04-12', '2026-04-02', '2026-04-02', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 10. Priscila Alves Da Natividade Farias
(
    'Priscila Alves Da Natividade Farias',
    'Operador De Caixa',
    'ativo',
    'Tranquility',
    'Prevent Sênior - Hospital Madri',
    '06:00 às 15:00',
    '2025-09-01', '2025-09-01', NULL, '1986-05-12',
    'Feminino',
    '54.870.184-2', '662.282.140-21', '166.03453.31-3', '6732008756',
    'Casado(a)',
    '{"nome": "Sidnei Nascimento Farias", "data_nascimento": "1972-03-05"}', 
    1, '[{"nome": "Ester Beatriz De Lima", "data_nascimento": "2006-07-24"}]',
    'pri_ester_@hotmail.com', '(11) 99583-9424', '(11) 97506-7424', '(11) 97675-1001',
    '08320-270', 'Rua Francisco Aguiar De Barros', '370', 'Casa 3', 'Parque São Rafael', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus', 2, '10.00',
    '2025-09-01', NULL, NULL, NULL,
    'M', '38', 'P', NULL,
    '2021-06-29', '2026-04-29', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 11. Lucas De Oliveira Fernandes
(
    'Lucas De Oliveira Fernandes',
    'Encarregado Estacionamento Pleno',
    'ativo',
    'Tranquility',
    'IGESP - Hospital Praia Grande',
    '06:00 as 14:20',
    '2025-03-24', '2025-03-24', NULL, '1992-02-08',
    'Masculino',
    '36.077.798-3', '414.341.228-40', '210.72650.18-7', '05066864324',
    'Casado(a)',
    '{"nome": "Mayara Camboim Fernandes", "data_nascimento": "1990-03-29"}', 
    0, NULL,
    'fer081992@gmail.com', '(11) 94737-7431', '(11) 96067-2482', '(11) 3203-0556',
    '11730-000', 'Av Jose Bonifacio', '2526', 'Casa', 'Jardim Leonor', 'Mongagua', 'SP',
    'Auxílio Combustível', NULL, NULL, '150.00',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, '41',
    '2025-07-22', '2026-03-21', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 12. Olinto Geraldo Cordeiro De Oliveira
(
    'Olinto Geraldo Cordeiro De Oliveira',
    'Operador De Estacionamento',
    'ativo',
    'Tranquility',
    'Prevent Sênior - Hospital Madri',
    '10:00 às 18:20',
    '2024-08-21', '2024-08-21', NULL, '1964-12-04',
    'Masculino',
    '29.472.245-2', '541.798.826-04', '121.94138.28-7', '03923430513',
    'Casado(a)',
    '{"nome": "Regiana Maria Cintra de Oliveira", "data_nascimento": "1969-06-17"}', 
    0, NULL,
    NULL, '(11) 94609-8215', '(11) 95872-9867', NULL,
    '08663-375', 'Rua Waldemar Seraphim', '213', 'Casa', 'Casa Branca', 'Suzano', 'SP',
    'Vale Transporte', 'Ônibus', 2, '12.00',
    '2025-01-31', NULL, NULL, NULL,
    'G', '42', 'G', '41',
    '2027-06-09', '2025-08-20', '2025-08-20', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 13. Ricardo Gomes De Sousa
(
    'Ricardo Gomes De Sousa',
    'Operador De Estacionamento',
    'ativo',
    'Tranquility',
    'Prevent Sênior - Hospital Madri',
    '12:00 às 18:20',
    '2025-04-01', '2025-04-01', NULL, '1977-03-26',
    'Masculino',
    '30.786.252-5', '261.065.038-85', '125.96587.60-4', '0101759010588',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    NULL, '(11) 97519-0099', NULL, NULL,
    '08250-540', 'Rua Arturo Vital', '7844', '4A, Conjunto Residencial José Bonifácio', 'Itaquera', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus, Metrô', 6, '20.40',
    '2025-01-09', NULL, NULL, NULL,
    'M', '40', 'P', '39',
    '2031-05-20', '2026-03-28', '2026-03-28', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 14. Thiago Herbert Dos Santos Rebustine
(
    'Thiago Herbert Dos Santos Rebustine',
    'Operador De Estacionamento',
    'ativo',
    'Tranquility',
    'Prevent Sênior - Hospital Madri',
    '14:00 as 22:20',
    '2025-12-08', '2025-12-08', NULL, '1988-12-15',
    'Masculino',
    '44.521.959-2', '376.633.608-85', NULL, '05272515402',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    'orebustine@uol.com.br', '(11) 94801-1882', '(11) 2994-0927', NULL,
    '02353-040', 'Rua Lourdes Vieira', '47', 'Casa', 'Parque Ramos Freitas', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus, Metrô', 4, '20.40',
    '2025-12-08', NULL, NULL, NULL,
    'M', '36', 'G', '41',
    '2026-03-09', '2026-12-05', '2026-12-05', NULL, NULL, NULL, NULL,
    '2026-02-05', NULL,
    NULL, NULL
),

-- 15. Lilian De Moura Pereira
(
    'Lilian De Moura Pereira',
    'Controlador De Acesso',
    'ativo',
    'Tranquility',
    'Prevent Sênior - Hospital Madri',
    '08:00 as 18:00',
    '2025-08-11', '2025-08-11', NULL, '1982-03-24',
    'Feminino',
    '33.089.102-9', '304.735.818-41', '126.91198.85-7', NULL,
    'Casado(a)',
    '{"nome": "Fabio Pereira Bizerra", "data_nascimento": "1978-05-03"}', 
    1, '[{"nome": "Kássia de Moura Pereira", "data_nascimento": "2009-03-20"}]',
    NULL, '(11) 94635-2283', '(11) 96564-8387', '(11) 96938-3296',
    '08461-650', 'Av Jose Higino Neves', '960', 'AP 31B', 'Jardim São Paulo (Zona Leste)', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus, Trem', 4, '17.80',
    '2025-08-11', NULL, NULL, NULL,
    'XG', 'XGG', 'G', NULL,
    NULL, '2026-08-07', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 16. Thiago Cavalcante Almeida
(
    'Thiago Cavalcante Almeida',
    'Operador De Estacionamento',
    'ativo',
    'Tranquility',
    'Prevent Sênior - Hospital Madri',
    '06:00 as 14:20',
    '2025-01-09', '2025-01-09', NULL, '2000-07-05',
    'Masculino',
    '38.808.242-2', '492.634.468-81', '236.23496.52-5', '7887097603',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    'thiagoalmeida7@gmail.com', '(11) 98298-5146', '(11) 94930-0846', NULL,
    '04474-018', 'Avenida Professor Cardozo De Mello Neto', '1039', 'Casa', 'Jardim Santa Terezinha', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus, Metrô', 4, '10.70',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2025-09-16', '2026-01-07', '2026-01-07', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
);


INSERT INTO `funcionarios` (
    `nome`, `funcao`, `status`, `empresa`, `local`, `horario`, 
    `data_admissao`, `data_inicio`, `data_demissao`, `data_nascimento`, 
    `genero`, `rg`, `cpf`, `pis`, `cnh_numero`, 
    `estado_civil`, `dados_conjuge`, `quantidade_filhos`, `nome_filhos`, 
    `email_pessoal`, `telefone_1`, `telefone_2`, `telefone_3`, 
    `cep`, `rua`, `numero`, `complemento`, `bairro`, `cidade`, `estado`, 
    `opcao_transporte`, `meio_transporte`, `qtd_transporte`, `valor_transporte`, 
    `data_entrega_uniforme`, `data_devolucao_uniforme`, `data_reposicao_uniforme`, `motivo_reposicao_uniforme`, 
    `tamanho_camisa`, `tamanho_calca`, `tamanho_jaqueta`, `tamanho_bota`, 
    `validade_cnh`, `validade_exame_clinico`, `validade_audiometria`, `validade_eletrocardiograma`, 
    `validade_eletroencefalograma`, `validade_glicemia`, `validade_acuidade_visual`, 
    `validade_treinamento`, `validade_contrato_experiencia`, 
    `motivo_demissao`, `elegivel_recontratacao`
) VALUES 
-- 1. Vagner Vieira Correa
(
    'Vagner Vieira Correa',
    'Operador De Estacionamento',
    'ativo',
    'Tranquility',
    'IGESP - Hospital Praia Grande',
    '07:00 as 15:20',
    '2025-03-26', '2025-03-26', NULL, '1998-06-08',
    'Masculino',
    '53.352.199-3', '472.763.098-27', '190.59042.95-9', '08709956452',
    'Solteiro(a)',
    NULL, 
    1, '[{"nome": "Ana Liz Santana Vieira", "data_nascimento": "2021-12-22"}]',
    'vagnervieira0002@gmail.com', '(13) 99199-1688', '(13) 98868-8940', '(13) 97412-0368',
    '11347-020', 'Rua Antonio Riscalle Husne', '91', 'Casa', 'Jardim Rio Branco', 'São Vicente', 'SP',
    'Vale Transporte', 'Ônibus', 3, '15.35',
    '2025-03-26', NULL, NULL, NULL,
    'M', '40', 'M', '40',
    '2025-08-05', '2026-03-25', '2026-03-25', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 2. Leandro Candido Cesario
(
    'Leandro Candido Cesario',
    'Operador De Estacionamento',
    'ativo',
    'Tranquility',
    'IGESP - Hospital Praia Grande',
    '22:00 as 06:20',
    '2025-04-24', '2025-04-24', NULL, '1985-07-22',
    'Masculino',
    '33.621.819-9', '328.417.868-62', '132.55851.77-6', '03587389642',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    'leandrocesario2207@gmail.com', '(13) 99187-7981', '(11) 24568-100', NULL,
    '11704-160', 'Rua Guimaraes Rosa', '370', 'AP 83', 'OCIAN', 'Praia Grande', 'SP',
    'Vale Transporte', 'Ônibus', 2, '10.50',
    '2025-04-23', NULL, NULL, NULL,
    'GG', '48', 'GG', '43',
    '2035-02-11', '2026-04-23', '2026-04-23', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 3. Vinicius Gonçalves Araujo
(
    'Vinicius Gonçalves Araujo',
    'Operador De Estacionamento',
    'ativo',
    'Tranquility',
    'IGESP - Hospital Praia Grande',
    '14:00 as 22:20',
    '2025-01-17', '2025-01-17', NULL, '1998-07-01',
    'Masculino',
    '54.548.608-7', '508.449.408-01', '204.31638.31-9', '08719654357',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    'vinibaixada0133@gmail.com', '(11) 97353-8465', '(11) 99540-5576', '(11) 99793-2682',
    '11713-560', 'Rua Alcindo Guanabara', '220', 'Casa', 'Esmeralda', 'Praia Grande', 'SP',
    'Auxílio Combustível', NULL, NULL, '150.00',
    '2025-01-16', NULL, NULL, NULL,
    'M', '40', 'M', '39',
    '2025-08-15', '2026-01-15', '2026-01-15', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 4. Willian Bertolacci
(
    'Willian Bertolacci',
    'Operador De Estacionamento',
    'ativo',
    'Tranquility',
    'IGESP - Hospital Praia Grande',
    '06:00 as 14:20',
    '2024-11-06', '2024-11-06', NULL, '1998-09-07',
    'Masculino',
    '55.766.663-6', '512.783.818-48', '210.11098.52-2', '07141248510',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    NULL, '(13) 99662-5526', '(11) 24568-100', NULL,
    '11702-840', 'Rua Thome De Souza', '399', 'Casa', 'Aviação', 'Praia Grande', 'SP',
    'Auxílio Combustível', NULL, NULL, '150.00',
    '2025-05-23', NULL, NULL, NULL,
    'GG', '48', 'GG', '44',
    '2033-05-08', '2025-09-05', '2025-09-05', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 5. Victor Da Silva Jesus
(
    'Victor Da Silva Jesus',
    'Operador De Estacionamento',
    'ativo',
    'Tranquility',
    'Prevent Sênior - Hospital Madri',
    '07:00 as 15:20',
    '2024-09-20', '2024-09-20', NULL, '1986-10-20',
    'Masculino',
    '41.001.087-X', '228.811.468-13', '204.37586.45-0', '6616380635',
    'Casado(a)',
    '{"nome": "Maria José Lima Da Silva", "data_nascimento": "1983-12-04"}', 
    1, '[{"nome": "Yasmin Vitoria Silva De Jesus", "data_nascimento": "2012-07-18"}]',
    NULL, '(11) 98601-5221', '(12) 4568-100', NULL,
    '08572-680', 'Rua Amazonas', '169', 'Casa', 'Jardim Do Algarve', 'Itaquaquecetuba', 'SP',
    'Vale Transporte', 'Trem', 2, '10.98',
    NULL, NULL, NULL, NULL,
    NULL, '42', NULL, '40',
    '2025-09-01', '2025-07-17', '2025-07-17', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 6. Vinicius Pereira De Moraes
(
    'Vinicius Pereira De Moraes',
    'Operador De Estacionamento',
    'ativo',
    'Tranquility',
    'IGESP - Hospital Praia Grande',
    '06:00 as 14:20',
    '2025-04-14', '2025-04-14', NULL, '1996-03-23',
    'Masculino',
    '50.104.268-4', '452.969.078-41', '267.63648.50-0', '06490703989',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    'gabitransporte@gmail.com', '(11) 96289-8531', '(11) 96078-2604', '(11) 98144-3848',
    '11702-750', 'Rua Carlos José Borstens', '40', 'AP 23', 'Aviação', 'Praia Grande', 'SP',
    'Auxílio Combustível', NULL, NULL, '150.00',
    '2025-04-24', NULL, NULL, NULL,
    'GG', '40', 'G', '42',
    '2035-02-12', '2026-04-11', '2026-04-11', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 7. Emily Vitoria Costa Silva
(
    'Emily Vitoria Costa Silva',
    'Operador De Caixa',
    'ativo',
    'Tranquility',
    'IGESP - Hospital Praia Grande',
    '07:00 as 17:00',
    '2025-04-23', '2025-04-23', NULL, '2003-03-29',
    'Feminino',
    '64.833.451-X', '557.409.728-17', NULL, NULL,
    'Solteiro(a)',
    NULL, 
    1, '[{"nome": "Isis Costa De Souza", "data_nascimento": "2022-01-06"}]',
    'belicavitoria1230@icloud.com', '(13) 99679-9972', '(13) 99758-0533', '(13) 99665-3838',
    '11347-490', 'Rua Nove', '320', 'Casa', 'Jardim Irma Dolores', 'São Vicente', 'SP',
    'Vale Transporte', 'Ônibus', 4, '21.60',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    NULL, '2026-04-17', '2026-04-17', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 8. Dafny Estefany Gomes Lopes Bezerra
(
    'Dafny Estefany Gomes Lopes Bezerra',
    'Operador De Estacionamento',
    'afastado',
    'Tranquility',
    'IGESP - Pronto Atendimento Santos',
    '14:00 as 22:20',
    '2025-05-13', '2025-05-13', NULL, '2003-04-29',
    'Feminino',
    '59.097.681-3', '503.983.708-93', '212.14927.30-2', '07843082471',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    'dafnygomes29@gmail.com', '(13) 99709-7966', '(13) 97812-3023', NULL,
    '11712-170', 'Rua Leopoldo Augusto Miguez', '9279', 'Casa', 'Jardim Melvi', 'Praia Grande', 'SP',
    'Auxílio Combustível', NULL, NULL, '150.00',
    '2025-05-13', NULL, NULL, NULL,
    'P', '36', 'P', NULL,
    '2031-09-29', '2026-05-08', '2026-05-08', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 9. Jacinto Lutanidio Bailo Kandulo
(
    'Jacinto Lutanidio Bailo Kandulo',
    'Operador De Estacionamento',
    'ativo',
    'Tranquility',
    'Prevent Sênior - Hospital Madri',
    '08:00 às 16:20',
    '2025-08-06', '2025-08-06', NULL, '2000-11-10',
    'Masculino',
    NULL, '902.013.848-09', '214.31918.71-9', '08739746740',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    NULL, '(11) 99181-6574', NULL, NULL,
    '01318-001', 'Avenida Brigadeiro Luis Antonio', '1224', 'Casa', 'Bela Vista', 'São Paulo', 'SP',
    'Vale Transporte', 'Metrô', 2, '10.98',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2034-08-06', '2026-08-06', '2026-08-06', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 10. Erick Gustavo Nascimento
(
    'Erick Gustavo Nascimento',
    'Operador De Estacionamento',
    'ativo',
    'Tranquility',
    'IGESP - Hospital Praia Grande',
    '10:00 às 18:20',
    '2025-04-03', '2025-04-03', NULL, '1993-09-28',
    'Masculino',
    '41.283.860-6', '406.180.918-07', '161.61809.84-3', '06657609004',
    'Casado(a)',
    '{"nome": "Karen Leticia Gonçalves Cardozo", "data_nascimento": "1993-02-13"}', 
    3, '[{"nome": "Heitor Gonçalves Nascimento", "data_nascimento": "2020-05-02"}, {"nome": "Antonella Gonçalves Nascimento", "data_nascimento": "2022-09-10"}, {"nome": "Ramon Gonçalves Nascimento", "data_nascimento": "2024-03-08"}]',
    'erick.gustavonasc@gmail.com', '(13) 97413-4506', '(13) 97414-1300', '(13) 99108-4342',
    '11713-210', 'Rua Heitor Vila-Lobos', '105', 'Casa 6', 'Samambaia', 'Praia Grande', 'SP',
    'Vale Transporte', 'Ônibus', 2, '10.50',
    '2025-04-24', NULL, NULL, NULL,
    'M', '38', 'P', '41',
    '2025-12-04', '2026-04-01', '2026-04-01', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 11. Carlos Sanmamed Santos
(
    'Carlos Sanmamed Santos',
    'Operador De Estacionamento',
    'ativo',
    'Tranquility',
    'IGESP - Pronto Atendimento Santos',
    '22:00 as 06:20',
    '2025-05-15', '2025-05-15', NULL, '1985-04-24',
    'Masculino',
    '44.454.596-7', '341.276.988-61', '133.58768.77-4', '03733712421',
    'Solteiro(a)',
    NULL, 
    1, '[{"nome": "Carlos Sanmamed Santos", "data_nascimento": "2011-11-30"}]',
    NULL, '(13) 99615-3110', NULL, NULL,
    '11350-570', 'Rua Dilson Marone (Tancredo Neves)', '100', 'Casa', 'Cidade Nautica', 'São Vicente', 'SP',
    'Auxílio Combustível', NULL, NULL, '150.00',
    '2025-05-15', NULL, NULL, NULL,
    'GG', '46', 'GG', '43',
    '2032-10-11', NULL, NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 12. Jeferson Bezerra Da Silva
(
    'Jeferson Bezerra Da Silva',
    'Encarregado Estacionamento Junior',
    'ativo',
    'Tranquility',
    'IGESP - Hospital Praia Grande',
    '14:00 as 22:20',
    '2025-03-24', '2025-03-24', NULL, '1995-08-04',
    'Masculino',
    '36.665.363-5', '461.029.218-10', '209.79843.86-8', '07695710659',
    'Solteiro(a)',
    NULL, 
    1, '[{"nome": "Icaro Davi Santos Bezerra", "data_nascimento": "2018-05-04"}]',
    'jefersonbezerradasilva2017@gmail.com', '(13) 99760-9752', '(11) 97683-5326', '(13) 99696-0486',
    '11713-300', 'Avenida Zelia Giglioli Galves', '7000', 'Casa', 'Esmeralda', 'Praia Grande', 'SP',
    'Auxílio Combustível', NULL, NULL, '150.00',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, '42',
    '2025-10-23', '2026-03-20', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
);


INSERT INTO `funcionarios` (
    `nome`, `funcao`, `status`, `empresa`, `local`, `horario`, 
    `data_admissao`, `data_inicio`, `data_demissao`, `data_nascimento`, 
    `genero`, `rg`, `cpf`, `pis`, `cnh_numero`, 
    `estado_civil`, `dados_conjuge`, `quantidade_filhos`, `nome_filhos`, 
    `email_pessoal`, `telefone_1`, `telefone_2`, `telefone_3`, 
    `cep`, `rua`, `numero`, `complemento`, `bairro`, `cidade`, `estado`, 
    `opcao_transporte`, `meio_transporte`, `qtd_transporte`, `valor_transporte`, 
    `data_entrega_uniforme`, `data_devolucao_uniforme`, `data_reposicao_uniforme`, `motivo_reposicao_uniforme`, 
    `tamanho_camisa`, `tamanho_calca`, `tamanho_jaqueta`, `tamanho_bota`, 
    `validade_cnh`, `validade_exame_clinico`, `validade_audiometria`, `validade_eletrocardiograma`, 
    `validade_eletroencefalograma`, `validade_glicemia`, `validade_acuidade_visual`, 
    `validade_treinamento`, `validade_contrato_experiencia`, 
    `motivo_demissao`, `elegivel_recontratacao`
) VALUES 
-- 1. Jose Edvan Santos Monteiro
(
    'Jose Edvan Santos Monteiro',
    'Operador De Estacionamento',
    'ativo',
    'Tranquility',
    'IGESP - Hospital Praia Grande',
    '14:00 as 22:20',
    '2024-12-27', '2024-12-27', NULL, '1966-08-29',
    'Masculino',
    '18.760.659-6', '756.173.183-31', '205.94736.26-0', '4223268827',
    'Casado(a)',
    '{"nome": "Maria de Lourdes Carvalho Monteiro", "data_nascimento": "1961-12-16"}', 
    0, NULL,
    'monteiroedvan93@gmail.com', '(11) 95233-9347', '(13) 98122-2559', NULL,
    '11730-000', 'Rua Santa Eunice', '1599', 'Casa', 'Agenor De Campos', 'Mongaguá', 'SP',
    'Auxílio Combustível', NULL, NULL, '150.00',
    '2025-04-30', NULL, NULL, NULL,
    'G', '42', 'G', '39',
    '2028-02-01', NULL, NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 2. Fabio Andre Paulino Dos Santos
(
    'Fabio Andre Paulino Dos Santos',
    'Operador De Estacionamento',
    'ativo',
    'Tranquility',
    'Prevent Sênior - Hospital Madri',
    '14:00 as 22:21',
    '2025-08-12', '2025-08-12', NULL, '1982-07-25',
    'Masculino',
    '45.480.418-0', '299.859.738-60', '130.33536.89-0', '3093908020',
    'Solteiro(a)',
    NULL, 
    1, '[{"nome": "Yasmin Honorio Santos", "data_nascimento": "2011-12-19"}]',
    'andrefabio246@gmail.com', '(11) 96794-0444', NULL, NULL,
    '03717-010', 'Rua Corintios', '42', 'Casa 2', 'Jardim Piratininga', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus, Metrô', 4, '21.40',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2034-04-30', '2026-08-08', '2026-08-08', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 3. Jose Eduardo Da Silva
(
    'Jose Eduardo Da Silva',
    'Operador De Estacionamento',
    'ativo',
    'Tranquility',
    'Prevent Sênior - Hospital Madri',
    '06:00 as 14:20',
    '2025-09-05', '2025-09-05', NULL, '1961-12-16',
    'Masculino',
    '69.320.675-5', '748.020.897-91', '107.92603.46-7', '0128671404',
    'Casado(a)',
    '{"nome": "Andreia De Camargo", "data_nascimento": "1970-04-18"}', 
    0, NULL,
    NULL, '(21) 96417-6592', '(11) 98342-0425', NULL,
    '02418-100', 'Rua Adolfo Samuel', '61', 'Casa', 'Parque Mandaqui', 'São Paulo', 'SP',
    'Não Optante', NULL, NULL, NULL,
    '2025-09-05', NULL, NULL, NULL,
    'G', '46', 'G', '41',
    '2028-10-20', '2026-09-04', '2026-09-04', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 4. Gedeon Gomes Ferreira
(
    'Gedeon Gomes Ferreira',
    'Operador De Estacionamento',
    'ativo',
    'Tranquility',
    'IGESP - Hospital Praia Grande',
    '14:00 as 22:20',
    '2025-01-03', '2025-01-03', NULL, '1985-03-25',
    'Masculino',
    '48.436.690-7', '331.674.458-40', '200.89082.16-2', '3643830709',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    NULL, '(13) 98119-9249', '(13) 3034-3051', NULL,
    '11704-625', 'Rua Vinte De Janeiro', '2269', 'Casa', 'Vila Mirim', 'Praia Grande', 'SP',
    'Auxílio Combustível', NULL, NULL, '150.00',
    '2025-01-03', NULL, NULL, NULL,
    'M', '42', 'M', '42',
    '2031-06-16', '2026-01-02', '2026-01-02', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 5. Caio Emmanoel Goncalves Silva
(
    'Caio Emmanoel Goncalves Silva',
    'Operador De Estacionamento',
    'ativo',
    'Tranquility',
    'Prevent Sênior - Hospital Madri',
    '15:00 as 23:20',
    '2025-02-05', '2025-02-05', NULL, '1998-02-12',
    'Masculino',
    '54.067.875-2', '899.648.444-02', '034.18122.20-0', '6638635151',
    'Solteiro(a)',
    NULL, 
    1, '[{"nome": "Mauricio Ferreira Goncalves", "data_nascimento": "2018-05-26"}]',
    'caioemmanoel22@gmail.com', '(11) 98699-5142', NULL, NULL,
    '01306-001', 'Rua Avanhandava', '921', 'AP 88', 'Bela Vista', 'São Paulo', 'SP',
    'Vale Transporte', 'Metrô', 2, '11.40',
    '2025-02-05', NULL, NULL, NULL,
    'G', '42', NULL, NULL,
    '2033-04-19', '2026-02-04', '2026-02-04', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 6. Bianca Campos Dos Santos
(
    'Bianca Campos Dos Santos',
    'Operador De Caixa',
    'ativo',
    'Tranquility',
    'Prevent Sênior - Hospital Madri',
    '07:00 as 16:00',
    '2024-08-08', '2024-08-08', NULL, '2004-09-14',
    'Feminino',
    '53.758.165-0', '420.657.528-23', '161.52674.26-4', NULL,
    'Solteiro(a)',
    NULL, 
    0, NULL,
    'bianquinha3005@gmail.com', '(11) 96878-3814', '(11) 93460-1409', '(11) 99005-1189',
    '05800-000', 'Rua Bonifacio De Montferrat', '138', 'C3', 'Jardim Klein', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus, Metrô', 3, '16.16',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    NULL, '2026-01-23', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 7. Antonio Carlos Goes
(
    'Antonio Carlos Goes',
    'Operador De Estacionamento',
    'ativo',
    'Tranquility',
    'Prevent Sênior - Hospital Madri',
    '11:00 as 19:20',
    '2025-11-19', '2025-11-19', NULL, '1963-04-10',
    'Masculino',
    '12.854.052-7', '352.487.488-61', '197.88961.10-0', '2817305477',
    'Divorciado(a)',
    NULL, 
    0, NULL,
    'acimagerun@gmail.com', '(11) 95107-9513', '(11) 97997-7154', NULL,
    '05056-001', 'Rua Tonelero', '1335', 'Casa 1', 'Vila Ipojuca', 'São Paulo', 'SP',
    'Não Optante', NULL, NULL, NULL,
    '2025-11-19', NULL, NULL, NULL,
    'G', '44', 'G', '42',
    '2029-11-21', '2026-11-17', '2026-11-17', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 8. Antonio Giuvan Gomes
(
    'Antonio Giuvan Gomes',
    'Operador De Estacionamento',
    'ativo',
    'Tranquility',
    'Prevent Sênior - Hospital Madri',
    '04:00 as 12:20',
    '2025-01-27', '2025-01-27', NULL, '1968-08-12',
    'Masculino',
    '30.240.744-3', '266.956.888-26', '123.50730.02-8', '2585919493',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    NULL, '(11) 95923-2975', '(11) 98191-2730', NULL,
    '01316-000', 'Rua Franscisca Miquelina', '197', 'AP 403', 'Bela Vista', 'São Paulo', 'SP',
    'Não Optante', NULL, NULL, NULL,
    '2025-01-22', NULL, NULL, NULL,
    'G', '44', NULL, '40',
    '2028-05-02', '2024-07-27', '2024-07-27', '2025-07-27', '2025-07-27', '2024-07-27', '2024-07-27',
    '2024-07-27', NULL,
    NULL, NULL
),

-- 9. Carlos Eduardo Wichinieski
(
    'Carlos Eduardo Wichinieski',
    'Operador De Estacionamento',
    'ativo',
    'Tranquility',
    'IGESP - Hospital Praia Grande',
    '14:00 as 22:20',
    '2025-03-21', '2025-03-21', NULL, '1978-06-05',
    'Masculino',
    '29.827.766-9', '273.169.868-32', '133.25089.56-8', '0675220029',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    NULL, '(11) 99819-2953', NULL, NULL,
    '11708-040', 'Rua Florida', '504', 'AP 104', 'Real', 'Praia Grande', 'SP',
    'Auxílio Combustível', NULL, NULL, '150.00',
    '2025-03-21', NULL, NULL, NULL,
    'M', '40', 'M', '38',
    '2032-12-22', '2026-03-21', '2025-03-24', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 10. Francisco Iago Gomes De Castro
(
    'Francisco Iago Gomes De Castro',
    'Operador De Estacionamento',
    'ativo',
    'Tranquility',
    'Prevent Sênior - Hospital Madri',
    '06:00 as 14:20',
    '2025-02-24', '2025-02-24', NULL, '2002-02-12',
    'Masculino',
    '20.070.616-1', '836.696.638-01', '484.26842.98-0', '7762521690',
    'Solteiro(a)',
    NULL, 
    1, '[{"nome": "Aylla Oliveira Castro", "data_nascimento": "2021-07-21"}]',
    NULL, '(88) 9408-6653', NULL, NULL,
    '01019-010', 'Rua Das Flores', '27', 'Casa 2', 'Sé', 'São Paulo', 'SP',
    'Vale Transporte', 'Metrô', 2, '10.40',
    '2025-01-09', NULL, NULL, NULL,
    'G', '42', 'G', '44',
    '2026-03-04', '2026-02-21', '2026-02-21', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 11. Lucas De Jesus Santos
(
    'Lucas De Jesus Santos',
    'Encarregado De Estacionamento',
    'ativo',
    'Tranquility',
    'Prevent Sênior - Hospital Madri',
    '08:00 as 17:00',
    '2020-07-13', '2020-07-13', NULL, '2002-01-16',
    'Masculino',
    '54.664.015-1', '433.182.008-40', NULL, '7662830869',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    'lucasdejesus@gmail.com', '(11) 97849-0246', '(11) 99345-6217', '(11) 99351-8137',
    '01137-040', 'Rua Padre Luis Laves De Siqueira', '953', 'Casa', 'Barra Funda', 'São Paulo', 'SP',
    'Não Optante', NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2025-03-05', NULL, NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
);
































-- GSM

INSERT INTO `funcionarios` (
    `nome`, `funcao`, `status`, `empresa`, `local`, `horario`, 
    `data_admissao`, `data_inicio`, `data_demissao`, `data_nascimento`, 
    `genero`, `rg`, `cpf`, `pis`, `cnh_numero`, 
    `estado_civil`, `dados_conjuge`, `quantidade_filhos`, `nome_filhos`, 
    `email_pessoal`, `telefone_1`, `telefone_2`, `telefone_3`, 
    `cep`, `rua`, `numero`, `complemento`, `bairro`, `cidade`, `estado`, 
    `opcao_transporte`, `meio_transporte`, `qtd_transporte`, `valor_transporte`, 
    `data_entrega_uniforme`, `data_devolucao_uniforme`, `data_reposicao_uniforme`, `motivo_reposicao_uniforme`, 
    `tamanho_camisa`, `tamanho_calca`, `tamanho_jaqueta`, `tamanho_bota`, 
    `validade_cnh`, `validade_exame_clinico`, `validade_audiometria`, `validade_eletrocardiograma`, 
    `validade_eletroencefalograma`, `validade_glicemia`, `validade_acuidade_visual`, 
    `validade_treinamento`, `validade_contrato_experiencia`, 
    `motivo_demissao`, `elegivel_recontratacao`
) VALUES 
-- 1. Jaqueline Andrade Da Silva
(
    'Jaqueline Andrade Da Silva',
    'Operador De Caixa',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Itaquera - Sede',
    '06:00 às 15:00',
    '2024-03-15', '2024-03-15', NULL, '1977-03-07',
    'Feminino',
    '28.467.929-3', '181.714.738-22', '127.49418.81-1', NULL,
    'Divorciado(a)',
    NULL, 
    1, '[{"nome": "Esther Andrade Da SIlva", "data_nascimento": "2016-11-23"}]',
    'jackandrade925@gmail.com', '(11) 96443-4999', NULL, NULL,
    '08452-140', 'Rua Capitão Mor Mascarenhas Homem', '13', 'Casa', 'Lajeado', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus, Trem', 4, '16.40',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2025-03-14', NULL, NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 2. Anderson Aparecido Cosme Manoel
(
    'Anderson Aparecido Cosme Manoel',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Itaquera - Sede',
    '11:00 as 19:00',
    '2023-03-24', '2023-03-24', NULL, '1987-11-27',
    'Masculino',
    '34.670.802-3', '379.327.178-17', '135.94154.93-8', '06900594901',
    'Casado(a)',
    NULL, 
    1, '[{"nome": "Felipe Anderson de Lima Manoel", "data_nascimento": "2018-02-22"}]',
    'andersonaparecido2711@gmail.com', '(11) 94945-7542', NULL, NULL,
    '03585-130', 'Rua Joao Chagas', '23', 'Casa', 'Jardim Brasilia', 'São Paulo', 'SP',
    'Auxílio Combustível', NULL, NULL, '110.00',
    '2025-03-22', NULL, NULL, NULL,
    'M', '44', 'G', NULL,
    '2032-03-04', '2025-03-07', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 3. Lucas Barbosa Fontellas
(
    'Lucas Barbosa Fontellas',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Regionais - Hospital Cidade Tiradentes',
    '11:00 as 19:00',
    '2022-06-24', '2022-06-24', NULL, '1998-06-01',
    'Masculino',
    '38.458.473-1', '486.279.128-07', '209.74405.61-7', '06947139259',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    'lucasfontellas786@gmail.com', '(11) 98998-6252', NULL, NULL,
    '08120-270', 'Rua Jandia', '162', 'Casa', 'Jardim Camargo Novo', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus', 4, '17.60',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2032-03-31', '2026-10-31', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 4. Guilherme Alves Garcia
(
    'Guilherme Alves Garcia',
    'Controlador De Acesso',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Itaquera - Sede',
    '08:00 as 16:00',
    '2025-01-13', '2025-01-13', NULL, '2004-06-16',
    'Masculino',
    '60.351.310-4', '568.606.648-51', '236.25100.63-7', NULL,
    'Solteiro(a)',
    NULL, 
    0, NULL,
    'guialves1212@gmail.com', '(11) 98451-1641', '(11) 97706-0813', NULL,
    '08081-655', 'Rua São João', '6', 'Complemento A', 'Vila Bela', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus', 2, '10.00',
    '2025-01-10', NULL, NULL, NULL,
    'M', '38', 'P', NULL,
    NULL, '2026-06-27', '2026-06-27', '2027-06-27', '2027-06-27', '2026-06-27', '2026-06-27',
    NULL, NULL,
    NULL, NULL
),

-- 5. Alan Oliveira Freire
(
    'Alan Oliveira Freire',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Itaquera - Sede',
    '14:00 as 22:00',
    '2025-09-23', '2025-09-23', NULL, '1991-11-11',
    'Masculino',
    '48.371.279-6', '417.399.918-69', '212.90760.04-9', '06005119218',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    NULL, '(11) 98570-5828', NULL, NULL,
    '08373-210', 'Rua Valdete', '63', 'Complemento A', 'Jardim Nova Vitoria', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus', 2, '10.00',
    '2025-09-23', NULL, NULL, NULL,
    'G', '42', 'G', NULL,
    '2035-06-23', '2026-09-17', '2026-09-17', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 6. Julio Cesar Barboza Da Silva
(
    'Julio Cesar Barboza Da Silva',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Regionais - Hospital Cidade Tiradentes',
    '14:00 as 22:00',
    '2025-12-01', '2025-12-01', NULL, '1986-11-29',
    'Masculino',
    '49.605.504-5', '363.201.348-95', NULL, '08632837133',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    'jcbarbozasilvaa@gmail.com', '(11) 95902-7852', '(11) 98149-1431', NULL,
    '08430-025', 'Rua Marinho Arcanjo Dos Santos', '41', 'Bloco 2 Ap 12B', 'Jardim Santa Terezinha', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus', 4, '10.98',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2031-06-05', '2026-11-25', '2026-11-25', NULL, NULL, NULL, NULL,
    '2026-01-29', NULL,
    NULL, NULL
),

-- 7. Gerson Da Silva
(
    'Gerson Da Silva',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'IGESP - Pronto Atendimento Santos',
    '14:00 as 22:20',
    '2025-09-24', '2025-09-24', NULL, '1968-12-12',
    'Masculino',
    '18.601.470-3', '118.561.608-07', '123.40641.45-6', '01821549102',
    'Casado(a)',
    '{"nome": "Shirlei Assunção Aguiar da Silva", "data_nascimento": "1966-09-21"}', 
    2, '[{"nome": "Thiago Assunção Aguiar da Silva", "data_nascimento": "1987-04-08"}, {"nome": "Deivid Assunção Aguiar da Silva", "data_nascimento": "2002-12-19"}]',
    'gerson9100@gmail.com', '(13) 99752-2489', NULL, NULL,
    '11380-000', 'Avenida Prefeito José Monteiro', '548', 'Ap 13', 'Jardim Independência', 'São Vicente', 'SP',
    'Vale Transporte', 'Ônibus', 2, '13.00',
    '2025-09-24', NULL, NULL, NULL,
    'G', '42', 'G', NULL,
    '2032-11-29', '2026-09-19', '2026-09-19', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 8. Alexandre Ruas Dos Santos
(
    'Alexandre Ruas Dos Santos',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Itaquera - Sede',
    '06:00 as 14:20',
    '2021-03-01', '2021-03-01', NULL, '1980-08-17',
    'Masculino',
    '34.065.166-0', '305.751.658-04', '129.12630.85-3', '05445158093',
    'Solteiro(a)',
    NULL, 
    1, '[{"nome": "Esther Andrade Santos", "data_nascimento": "2016-08-01"}]',
    NULL, NULL, NULL, NULL,
    '03717-010', 'Rua Olga Artacho', '24', 'Casa', 'Jardim Piratininga', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus, Trem', 4, '18.80',
    '2022-05-18', NULL, NULL, NULL,
    'G', NULL, 'M', NULL,
    '2021-03-11', '2025-07-10', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 9. Genilson Silva Sousa
(
    'Genilson Silva Sousa',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'IGESP - Hospital Santo Amaro',
    '08:30 as 17:30',
    '2025-11-18', '2025-11-18', NULL, '1979-05-14',
    'Masculino',
    '39.670.456-6', '285.240.418-46', '129.89486.85-4', '05781255100',
    'Casado(a)',
    '{"nome": "Maria Jose da Silva", "data_nascimento": "1970-01-06"}', 
    1, '[{"nome": "Jessica da Silva Sousa", "data_nascimento": "2004-12-03"}]',
    'genilsonsouza0516@gmail.com', '(11) 94511-7891', '(11) 96016-9709', '1',
    '05797-380', 'Rua Lerici', '58', 'Casa', 'Jardim Ipê', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus', 4, '10.98',
    '2025-11-18', NULL, NULL, NULL,
    'GG', '46', 'G', NULL,
    '2025-11-05', '2026-11-13', '2026-11-13', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 10. Julio Gabriel De Souza Pereira
(
    'Julio Gabriel De Souza Pereira',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Regionais - Hospital Cidade Tiradentes',
    '14:00 as 22:00',
    '2024-07-12', '2024-07-12', NULL, '1995-09-22',
    'Masculino',
    '52.850.150-1', '138.896.764-22', '128.06467.58-0', '6693209229',
    'Casado(a)',
    '{"nome": "Flávia de Jesus Machado Coutinho", "data_nascimento": "1994-06-09"}', 
    3, '[{"nome": "Davi Gabriel Pereira Machado", "data_nascimento": "2019-10-11"}, {"nome": "Matteo Pereira Machado", "data_nascimento": "2024-06-08"}, {"nome": "Antony Pereira Machado", "data_nascimento": "2024-06-08"}]',
    'julio.davifilho1019@gmail.com', '(11) 96481-0604', '(11) 93427-4837', NULL,
    '08473-620', 'Rua Ricardo Da Costa', '68', 'Casa 2, Conjunto Habitacional Barro Branco 2', 'Barro Branco', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus', 2, '9.66',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2034-01-12', '2025-02-11', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 11. Felipe Castro Santos
(
    'Felipe Castro Santos',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Regionais - Hospital Neomater SBC',
    '14:00 as 22:00',
    '2025-12-01', '2025-12-01', NULL, '1997-08-09',
    'Masculino',
    '38.897.794-2', '458.836.218-64', NULL, '06666849867',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    'felipetkd14@hotmail.com', '(11) 99253-4834', '(11) 94831-6668', NULL,
    '09580-540', 'Rua Jose Salustiano Santana', '259', 'Casa', 'Maua', 'São Caetano Do Sul', 'SP',
    'Não Optante', NULL, NULL, NULL,
    '2025-12-01', NULL, NULL, NULL,
    'P', '42', NULL, NULL,
    '2035-09-12', '2026-11-25', '2026-11-25', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
);


INSERT INTO `funcionarios` (
    `nome`, `funcao`, `status`, `empresa`, `local`, `horario`, 
    `data_admissao`, `data_inicio`, `data_demissao`, `data_nascimento`, 
    `genero`, `rg`, `cpf`, `pis`, `cnh_numero`, 
    `estado_civil`, `dados_conjuge`, `quantidade_filhos`, `nome_filhos`, 
    `email_pessoal`, `telefone_1`, `telefone_2`, `telefone_3`, 
    `cep`, `rua`, `numero`, `complemento`, `bairro`, `cidade`, `estado`, 
    `opcao_transporte`, `meio_transporte`, `qtd_transporte`, `valor_transporte`, 
    `data_entrega_uniforme`, `data_devolucao_uniforme`, `data_reposicao_uniforme`, `motivo_reposicao_uniforme`, 
    `tamanho_camisa`, `tamanho_calca`, `tamanho_jaqueta`, `tamanho_bota`, 
    `validade_cnh`, `validade_exame_clinico`, `validade_audiometria`, `validade_eletrocardiograma`, 
    `validade_eletroencefalograma`, `validade_glicemia`, `validade_acuidade_visual`, 
    `validade_treinamento`, `validade_contrato_experiencia`, 
    `motivo_demissao`, `elegivel_recontratacao`
) VALUES 
-- 1. Jose Da Silva
(
    'Jose Da Silva',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Itaquera - Faculdade Santa Marcelina',
    '14:00 as 22:00',
    '2024-12-06', '2024-12-06', NULL, '1956-01-08',
    'Masculino',
    '19.832.438-8', '035.314.678-16', '120.21351.47-7', '01658325059',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    'j_silva_36@gmail.com', '(11) 98351-9639', NULL, NULL,
    '08460-345', 'Rua Angelo Pedroso', '3', 'Casa 2', 'Vila ABC', 'São Paulo', 'SP',
    'Não Optante', NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2026-06-04', '2025-12-05', '2025-12-05', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 2. Antonio Lemos Filho
(
    'Antonio Lemos Filho',
    'Coordenador De Estacionamento',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Itaquera - Sede',
    '08:00 as 18:00',
    '2022-07-15', '2022-07-15', NULL, '1984-11-17',
    'Masculino',
    '42.262.357-X', '324.805.068-35', '203.44014.74-0', '02920100298',
    'Casado(a)',
    '{"nome": "Miriam Pereira Lemos", "data_nascimento": "1987-04-01"}', 
    2, '[{"nome": "Bernardo Pereira Lemos", "data_nascimento": "2025-11-03"}, {"nome": "Leonardo Pereira Lemos", "data_nascimento": "2023-12-12"}]',
    'antoniolemos84@gmail.com', '(11) 98293-8408', '(11) 98465-8238', NULL,
    '08526-230', 'Rua Sergio De Cenco Filho', '118', 'Casa', 'Parque Sao Francisco', 'Ferraz De Vasconcelos', 'SP',
    'Não Optante', NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2032-04-07', '2026-12-17', '2026-12-17', '2027-12-17', '2027-12-17', '2026-12-17', '2026-12-17',
    NULL, NULL,
    NULL, NULL
),

-- 3. Jeferson Rondinone
(
    'Jeferson Rondinone',
    'Operador De Estacionamento Folguista',
    'ativo',
    'GSM',
    'Operador (a) Folguista',
    '00:00 as 23:59',
    '2025-11-18', '2025-11-18', NULL, '1979-08-10',
    'Masculino',
    '33.667.447-8', '306.836.018-81', '130.48557.85-6', '0203085075510',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    'jeffersonrondinone275@gmail.com', '(11) 95373-4432', '(11) 95195-7338', NULL,
    '03683-020', 'Rua Cristalandia Do Piaui', '558', 'Casa', 'Vila União', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus', 4, '21.42',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2034-12-04', '2026-11-13', '2026-11-13', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 4. Everaldo Rodrigues Pinto
(
    'Everaldo Rodrigues Pinto',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'Espaço HAOC',
    '12:00 as 21:00',
    '2025-11-05', '2025-11-05', NULL, '1960-10-21',
    'Masculino',
    '15.303.383-6', '035.709.968-08', '120.38968.84-7', '03163627050',
    'Casado(a)',
    '{"nome": "Railda Ventura Santos", "data_nascimento": "1967-04-19"}', 
    2, '[{"nome": "Ana Paula Santos Rodrigues", "data_nascimento": "1996-12-30"}, {"nome": "Eduardo Santos Rodrigues", "data_nascimento": "1993-12-25"}]',
    'everaldo.rodrigues21@hotmail.com', '(11) 94864-1559', '(11) 96391-5449', NULL,
    '05775-200', 'Rua Professor Leitão Da Cunha', '108', 'Casa 1', 'Parque Regina', 'São Paulo', 'SP',
    'Não Optante', NULL, NULL, NULL,
    '2025-11-05', NULL, NULL, NULL,
    'P', '38', 'G', '39',
    '2029-05-10', '2026-10-24', '2026-10-24', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 5. Gabriela Lopes Da Silva
(
    'Gabriela Lopes Da Silva',
    'Assistente Recursos Humanos Senior',
    'ativo',
    'GSM',
    'Administrativo',
    '08:00 as 17:00',
    '2023-11-13', '2023-11-13', NULL, '1995-09-14',
    'Feminino',
    '39.186.688-6', '442.645.998-22', '119.99721.58-0', NULL,
    'Solteiro(a)',
    NULL, 
    0, NULL,
    'gabrielalopes.silva95@gmail.com', '(11) 96754-7872', NULL, NULL,
    '02810-000', 'Avenida Elisio Teixeira Leite', '4474', 'Casa', 'Sitio Morro Grande', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus, Metrô', 4, '9.24',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    NULL, '2025-11-26', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 6. Gilmar Cezario Garcia
(
    'Gilmar Cezario Garcia',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Itaquera - Faculdade Santa Marcelina',
    '06:00 as 14:20',
    '2021-03-01', '2021-03-01', NULL, '1972-03-09',
    'Masculino',
    '20.961.670-2', '255.325.948-48', '123.24723.49-4', '02541339539',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    NULL, NULL, NULL, NULL,
    '08270-260', 'Rua Mato Grosso', '100', 'Casa', 'Vila Carmosina', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus', 2, '8.80',
    '2023-05-30', NULL, NULL, NULL,
    'GG', '44', 'G', NULL,
    '2021-06-28', '2025-11-22', '2025-11-22', NULL, NULL, NULL, '2025-11-22',
    NULL, NULL,
    NULL, NULL
),

-- 7. Elias Vieira De Souza
(
    'Elias Vieira De Souza',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Itaquera - Instituto',
    '13:40 as 22:00',
    '2021-03-01', '2021-03-01', NULL, '1996-09-25',
    'Masculino',
    '38.751.550-1', '465.541.888-51', '120.41624.91-3', '06657122924',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    NULL, NULL, NULL, NULL,
    '08270-370', 'Rua André Brasili', '68', 'Casa', 'Vila Chuca', 'São Paulo', 'SP',
    'Auxílio Combustível', NULL, NULL, '110.00',
    '2022-01-14', NULL, NULL, NULL,
    'G', '44', 'G', NULL,
    '2031-08-13', '2025-10-04', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 8. Clodoaldo Macedo De Oliveira
(
    'Clodoaldo Macedo De Oliveira',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Itaquera - AME',
    '14:00 as 22:00',
    '2025-12-01', '2025-12-01', NULL, '1972-11-16',
    'Masculino',
    '20.538.994-6', '115.760.528-18', NULL, '00857606804',
    'Divorciado(a)',
    NULL, 
    0, NULL,
    'clodoaldomacedo.oliveira011@gmail.com', '(11) 94553-4420', '(11) 91508-5957', NULL,
    '08151-010', 'Rua Jose Soares De Macedo', '281', 'Casa 5', 'Vila Conceição', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus', 4, '10.98',
    '2025-12-01', NULL, NULL, NULL,
    'P', '42', NULL, NULL,
    '2029-07-30', '2026-11-26', '2026-11-26', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 9. Dene Ferraz Riserio
(
    'Dene Ferraz Riserio',
    'Auxiliar De Escritorio',
    'ativo',
    'GSM',
    'Administrativo',
    '08:00 as 18:00',
    '2023-03-01', '2023-03-01', NULL, '1961-08-17',
    'Feminino',
    '01.250.166-2', '020.740.867-50', '410.76661.29-6', NULL,
    'Viúvo(a)',
    NULL, 
    0, NULL,
    'deneriserio@hotmail.com', '(11) 91453-0571', '(11) 24568-100', NULL,
    '02462-080', 'Rua Nova Dos Portugueses', '180', 'Casa 07', 'Chora Menino', 'São Paulo', 'SP',
    'Não Optante', NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    NULL, '2025-08-13', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 10. Daniel Rodrigues Da Silva
(
    'Daniel Rodrigues Da Silva',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Itaquera - Sede',
    '14:00 as 22:00',
    '2024-10-07', '2024-10-07', NULL, '1979-11-17',
    'Masculino',
    '35.905.917-3', '052.186.787-81', '350.28689.20-8', '439623370',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    'dianaaparecida515@gmail.com', '(18) 99161-7444', NULL, NULL,
    '08122-230', 'Rua Sarapos', '127', 'Casa', 'Jardim Das Oliveiras', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus', 2, '8.80',
    '2024-10-04', NULL, NULL, NULL,
    'M', '38', 'G', NULL,
    '2024-12-16', '2025-10-04', '2025-10-04', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 11. Daniel Soares Milrot
(
    'Daniel Soares Milrot',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'Hapvida',
    '11:00 as 19:00',
    '2025-10-16', '2025-10-16', NULL, '1977-10-19',
    'Masculino',
    '25.467.600-5', '289.682.318-26', '133.85885.85-9', '01184940656',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    'Danielmilrot77@hotmail.com', '(11) 97230-1339', NULL, NULL,
    '03378-050', 'Rua Dom Estevao Pimentel', '49', 'Ap 25 A', 'Chacara Belenzinho', 'São Paulo', 'SP',
    'Auxílio Combustível', NULL, NULL, '180.00',
    '2025-10-16', NULL, NULL, NULL,
    'G', '44', 'G', NULL,
    '2027-10-31', '2026-10-14', '2026-10-14', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 12. Carlos Augusto Delgado De Campos
(
    'Carlos Augusto Delgado De Campos',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Regionais - Hospital Itaim',
    '14:00 as 22:00',
    '2023-06-01', '2023-06-01', NULL, '1969-04-19',
    'Masculino',
    '18.464.000-3', '030.091.998-05', '120.67877.64-1', '04644058067',
    'Casado(a)',
    '{"nome": "Rosemeire Pereira Alves Delgado de Campos", "data_nascimento": null}', 
    1, '[{"nome": "Juan Carlos Alves Delgado de Campos", "data_nascimento": "2011-05-23"}]',
    'carlosaugustocampos43@gmail.com', '(11) 99270-4713', NULL, NULL,
    '08190-000', 'Rua Cordão De São Francisco', '1169', 'Casa', 'Vila Aimoré', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus', 2, '9.24',
    '2023-05-30', NULL, NULL, NULL,
    'GG', '48', 'EG', NULL,
    '2024-07-23', '2024-05-29', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
);


INSERT INTO `funcionarios` (
    `nome`, `funcao`, `status`, `empresa`, `local`, `horario`, 
    `data_admissao`, `data_inicio`, `data_demissao`, `data_nascimento`, 
    `genero`, `rg`, `cpf`, `pis`, `cnh_numero`, 
    `estado_civil`, `dados_conjuge`, `quantidade_filhos`, `nome_filhos`, 
    `email_pessoal`, `telefone_1`, `telefone_2`, `telefone_3`, 
    `cep`, `rua`, `numero`, `complemento`, `bairro`, `cidade`, `estado`, 
    `opcao_transporte`, `meio_transporte`, `qtd_transporte`, `valor_transporte`, 
    `data_entrega_uniforme`, `data_devolucao_uniforme`, `data_reposicao_uniforme`, `motivo_reposicao_uniforme`, 
    `tamanho_camisa`, `tamanho_calca`, `tamanho_jaqueta`, `tamanho_bota`, 
    `validade_cnh`, `validade_exame_clinico`, `validade_audiometria`, `validade_eletrocardiograma`, 
    `validade_eletroencefalograma`, `validade_glicemia`, `validade_acuidade_visual`, 
    `validade_treinamento`, `validade_contrato_experiencia`, 
    `motivo_demissao`, `elegivel_recontratacao`
) VALUES 
-- 1. Denise Alves Do Nascimento Martini
(
    'Denise Alves Do Nascimento Martini',
    'Coordenadora De Recursos Humanos',
    'ativo',
    'GSM',
    'Administrativo',
    '08:00 as 18:00',
    '2025-09-04', '2025-09-04', NULL, '1985-04-16',
    'Feminino',
    '45.380.199-7', '317.748.438-46', '130.88290.85-0', NULL,
    'Casado(a)',
    '{"nome": "Patrick Paneque Martini", "data_nascimento": "1982-04-21"}', 
    0, NULL,
    'danm.rh.sp@gmail.com', '(11) 94266-4127', '(11) 95195-5029', NULL,
    '02950-000', 'Avenida Miguel De Castro', '218', 'Casa Superior', 'Vila Pereira Barreto', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus, Metrô', 4, '20.40',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    NULL, '2026-09-04', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 2. Brendon Santos De Oliveira
(
    'Brendon Santos De Oliveira',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Regionais - Hospital Itaquá',
    '14:00 as 22:00',
    '2024-09-26', '2024-09-26', NULL, '1996-06-24',
    'Masculino',
    '39.650.638-0', '438.019.418-33', '209.78173.25-7', '07418922660',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    'brendonoliveira458@yahoo.com', '(11) 93961-0053', '(11) 95794-0329', NULL,
    '08142-232', 'Rua Mario Sammarco', '115', 'Casa 2', 'Jardim Nelia', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus, Metrô', 4, '21.86',
    '2024-09-25', NULL, NULL, NULL,
    'M', '40', 'M', NULL,
    '2024-09-16', '2025-09-25', '2025-09-25', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 3. Danilo Rafael Ferreira De Morais
(
    'Danilo Rafael Ferreira De Morais',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'IGESP - Pronto Atendimento Santos',
    '06:00 as 14:20',
    '2025-09-19', '2025-09-19', NULL, '1988-08-19',
    'Masculino',
    '43.947.367-6', '367.452.138-50', '207.86813.89-4', '05003300010',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    'daniloferreiramorais@hotmail.com', '(11) 24568-100', NULL, NULL,
    '11065-200', 'Av Presidente Wilson', '59', 'AP 22', 'Gonzaga', 'Santos', 'SP',
    'Vale Transporte', 'Ônibus', 2, '11.90',
    '2025-09-19', NULL, NULL, NULL,
    'GG', '40', NULL, NULL,
    '2035-03-05', '2026-09-17', '2026-09-17', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 4. Jessica Dos Santos Pinto
(
    'Jessica Dos Santos Pinto',
    'Assistente Recursos Humanos',
    'ativo',
    'GSM',
    'Administrativo',
    '08:00 as 18:00',
    '2023-02-16', '2023-02-16', NULL, '1999-04-04',
    'Feminino',
    '38.696.856-1', '433.627.348-04', '163.43328.10-3', NULL,
    'Solteiro(a)',
    NULL, 
    1, '[{"nome": "Aghata Sophia Santos Da Silva", "data_nascimento": "2015-08-25"}]',
    NULL, '(11) 96326-5045', '(11) 24568-100', NULL,
    '05212-060', 'Rua Estados Unidos', '30', 'Casa', 'Jardim Da Conquista', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus, Metrô', 4, '18.48',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    NULL, '2025-03-11', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 5. Fernanda Veras Livramento Maciel
(
    'Fernanda Veras Livramento Maciel',
    'Operador De Caixa',
    'ativo',
    'GSM',
    'IGESP - Hospital Santo Amaro',
    '06:00 as 14:00',
    '2023-01-16', '2023-01-16', NULL, '1999-01-14',
    'Feminino',
    '52.052.465-2', '486.706.338-09', '201.15675.29-3', NULL,
    'Solteiro(a)',
    NULL, 
    2, '[{"nome": "Maria Eduarda Veras de Melo", "data_nascimento": "2016-06-27"}, {"nome": "Gael Veras Moura", "data_nascimento": "2021-02-06"}]',
    'eduardaveras4@gmail.com', '(11) 95453-6749', NULL, NULL,
    '05879-450', 'Rua Luar Do Sertao', '591', 'Casa 3', 'Chacara Santa Maria', 'Sao Paulo', 'SP',
    'Vale Transporte', 'Ônibus, Metrô', 4, '18.48',
    '2023-02-16', NULL, NULL, NULL,
    'PPP', NULL, NULL, NULL,
    NULL, '2024-01-13', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 6. Caio Ianni Guerreiro
(
    'Caio Ianni Guerreiro',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Regionais - Hospital Cidade Tiradentes',
    '12:00 as 20:00',
    '2025-11-18', '2025-11-18', NULL, '1992-08-17',
    'Masculino',
    '49.221.632-0', '412.111.338-18', '207.88976.14-6', '05224495517',
    'Solteiro(a)',
    NULL, 
    1, '[{"nome": "Julia Isis dos Santos Guerreiro", "data_nascimento": "2025-09-09"}]',
    'caioianniguerreiro1992@gmail.com', '(11) 94035-7813', NULL, NULL,
    '08490-800', 'Rua Jua Mirim', '385', 'Ap 2006, Torre B', 'Jardim Pedra Branca', 'São Paulo', 'SP',
    'Não Optante', NULL, NULL, NULL,
    '2025-11-18', NULL, NULL, NULL,
    'G', '44', 'G', NULL,
    '2026-03-15', '2026-12-13', '2026-12-13', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 7. Antonio Carlos Barreto De Sousa
(
    'Antonio Carlos Barreto De Sousa',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Regionais - Hospital Cidade Tiradentes',
    '14:00 as 22:00',
    '2025-08-27', '2025-08-27', NULL, '1966-09-14',
    'Masculino',
    '35.710.038-4', '378.077.575-15', '123.70530.10-5', '03096534680',
    'Solteiro(a)',
    NULL, 
    1, '[{"nome": "Jessica Ines de Sousa", "data_nascimento": null}]',
    NULL, NULL, NULL, NULL,
    '08471-740', 'Rua Rene Toledo', '586', 'Casa', 'Cidade Tiradentes', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus', 2, '10.00',
    '2025-08-27', NULL, NULL, NULL,
    'GG', '48', 'G', NULL,
    '2026-11-24', '2026-08-12', '2026-08-12', '2027-08-12', '2027-08-12', '2026-08-12', '2026-08-12',
    NULL, NULL,
    NULL, NULL
),

-- 8. Bruno Wenceslau Agra
(
    'Bruno Wenceslau Agra',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Regionais - Hospital Itaim',
    '14:00 as 19:00',
    '2023-04-12', '2023-04-12', NULL, '1996-11-12',
    'Masculino',
    '37.398.481-9', '450.343.368-71', '167.59452.54-3', '06398351711',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    NULL, NULL, NULL, NULL,
    '08130-230', 'Rua Marco Antonio Setti', '116', 'Casa', 'Cidade Kemel', 'São Paulo', 'SP',
    'Auxílio Combustível', NULL, NULL, '150.00',
    '2023-04-10', NULL, NULL, NULL,
    'EG', '52', 'EXG', NULL,
    '2025-02-17', '2024-04-10', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 9. David Nathal Junior
(
    'David Nathal Junior',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Regionais - Hospital Neomater SBC',
    '11:00 as 19:00',
    '2025-07-29', '2025-07-29', NULL, '1992-08-24',
    'Masculino',
    '35.315.633-4', '413.936.338-03', '167.57053.57-9', '05250629112',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    'dnathaltop@gmail.com', '(11) 93011-0488', NULL, NULL,
    '09626-030', 'Rua Quatorze De Julho', '37', 'AP 23 AN 2 BL 1', 'Rudge Ramos', 'Sao Bernardo Do Campo', 'SP',
    'Auxílio Combustível', NULL, NULL, '110.00',
    '2025-07-29', NULL, NULL, NULL,
    'G', '48', 'G', NULL,
    '2032-02-15', '2026-07-25', '2026-07-25', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 10. Franciele Da Silva Santos
(
    'Franciele Da Silva Santos',
    'Auxiliar De Recursos Humanos',
    'ativo',
    'GSM',
    'Administrativo',
    '08:00 as 18:00',
    '2025-11-03', '2025-11-03', NULL, '1993-07-12',
    'Feminino',
    '49.288.484-5', '401.909.088-23', '200.70584.79-0', '0107891919083',
    'Solteiro(a)',
    NULL, 
    1, '[{"nome": "Lorena dos Santos Silva", "data_nascimento": "2013-10-06"}]',
    'franciloli06@gmail.com', '(11) 96265-5693', '(11) 97785-4188', '(11) 96263-4996',
    '05207-190', 'Rua Bananal Do Rio', '185', 'Ap 608, Torre 1', 'Vila Caiuba', 'São Paulo', 'SP',
    'Vale Transporte', 'Trem, Metrô', 4, '10.40',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2026-01-22', '2026-10-30', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 11. Edvania Dias Figueiredo Moraes
(
    'Edvania Dias Figueiredo Moraes',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Itaquera - Sede',
    '14:00 as 22:00',
    '2024-06-18', '2024-06-18', NULL, '1967-03-12',
    'Feminino',
    '22.911.761-2', '274.987.858-62', '116.67462.90-8', '01774132152',
    'Casado(a)',
    '{"nome": "José Lins de Moraes", "data_nascimento": "1961-04-12"}', 
    0, NULL,
    NULL, '(11) 96984-1014', '(11) 94600-6115', NULL,
    '08215-460', 'Rua Antonio Gandini', '557', 'Casa', 'Itaquera', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus', 2, '8.80',
    '2024-06-17', NULL, NULL, NULL,
    'M', 'M', 'M', NULL,
    '2026-11-29', '2025-06-14', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 12. Felipe Alves Carlos
(
    'Felipe Alves Carlos',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'IGESP - Pronto Atendimento Santos',
    '08:00 as 18:00',
    '2025-09-15', '2025-09-15', NULL, '1988-10-22',
    'Masculino',
    '34.494.395-1', '366.412.228-37', '135.20539.85-2', '04254846750',
    'Solteiro(a)',
    NULL, 
    1, '[{"nome": "Arthur Farinas Carlos", "data_nascimento": "2015-10-28"}]',
    'felipealvesc@gmail.com', '(13) 99101-5969', NULL, NULL,
    '11380-320', 'Rua Morvan Dias De Figueiredo', '75', 'Casa 1', 'Vila Voturua', 'Sao Vicente', 'SP',
    'Auxílio Combustível', NULL, NULL, '150.00',
    '2025-09-15', NULL, NULL, NULL,
    'P', '40', 'P', NULL,
    '2033-02-02', '2026-09-12', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 13. Filipe Rodrigues Da Silva Santos
(
    'Filipe Rodrigues Da Silva Santos',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Regionais - Hospital Neomater SBC',
    '11:00 as 19:00',
    '2025-12-18', '2025-12-18', NULL, '1998-06-03',
    'Masculino',
    '53.808.758-4', '475.776.698-06', NULL, '07062764903',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    'ffelipesilva146@gmail.com', '(11) 98909-4170', NULL, NULL,
    '09890-941', 'Rua Ismael Emiliano Da Silva', '127', 'AP 11 Bloco 5', 'Vila Jerusálem', 'São Bernado Do Campo', 'SP',
    'Vale Transporte', 'Ônibus', 2, '11.90',
    '2025-12-18', NULL, NULL, NULL,
    NULL, '50', 'EXG', '43',
    '2032-08-25', '2026-11-25', '2026-11-25', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 14. Elias Portela Vieira
(
    'Elias Portela Vieira',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Itaquera - Instituto',
    '15:00 as 23:00',
    '2021-10-18', '2021-10-18', NULL, '1992-07-02',
    'Masculino',
    '34.785.209-9', '408.904.008-65', '203.91651.95-6', '05178728692',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    NULL, '(11) 95165-5560', '(11) 94634-4522', NULL,
    '08270-150', 'Rua Joao Abreu Castelo Branco', '343', 'Casa', 'Vila Carmosina', 'São Paulo', 'SP',
    'Auxílio Combustível', NULL, NULL, '110.00',
    '2025-07-03', NULL, NULL, NULL,
    'G', '46', 'G', NULL,
    '2021-10-03', '2025-10-14', '2025-10-14', '2026-10-14', '2026-10-14', '2025-10-21', '2025-10-14',
    NULL, NULL,
    NULL, NULL
),

-- 15. Francisco De Abreu Cardoso
(
    'Francisco De Abreu Cardoso',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Itaquera - Instituto',
    '15:00 as 23:00',
    '2025-10-03', '2025-10-03', NULL, '1955-04-20',
    'Masculino',
    '19.008.352-9', '036.649.498-89', '107.47864.18-4', '01583264195',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    NULL, NULL, NULL, NULL,
    '08270-260', 'Rua Mato Grosso', '20', 'Casa 2', 'Vila Carmosina', 'São Paulo', 'SP',
    'Não Optante', NULL, NULL, NULL,
    '2025-10-03', NULL, NULL, NULL,
    'M', '42', 'G', NULL,
    '2029-01-16', '2026-09-30', '2026-09-30', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
);


INSERT INTO `funcionarios` (
    `nome`, `funcao`, `status`, `empresa`, `local`, `horario`, 
    `data_admissao`, `data_inicio`, `data_demissao`, `data_nascimento`, 
    `genero`, `rg`, `cpf`, `pis`, `cnh_numero`, 
    `estado_civil`, `dados_conjuge`, `quantidade_filhos`, `nome_filhos`, 
    `email_pessoal`, `telefone_1`, `telefone_2`, `telefone_3`, 
    `cep`, `rua`, `numero`, `complemento`, `bairro`, `cidade`, `estado`, 
    `opcao_transporte`, `meio_transporte`, `qtd_transporte`, `valor_transporte`, 
    `data_entrega_uniforme`, `data_devolucao_uniforme`, `data_reposicao_uniforme`, `motivo_reposicao_uniforme`, 
    `tamanho_camisa`, `tamanho_calca`, `tamanho_jaqueta`, `tamanho_bota`, 
    `validade_cnh`, `validade_exame_clinico`, `validade_audiometria`, `validade_eletrocardiograma`, 
    `validade_eletroencefalograma`, `validade_glicemia`, `validade_acuidade_visual`, 
    `validade_treinamento`, `validade_contrato_experiencia`, 
    `motivo_demissao`, `elegivel_recontratacao`
) VALUES 
-- 1. Alex Silveira De Camargo
(
    'Alex Silveira De Camargo',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Itaquera - Instituto',
    '10:00 as 19:00',
    '2021-07-19', '2021-07-19', NULL, '1979-07-09',
    'Masculino',
    '27.525.214-0', '282.169.528-48', '129.73224.85-5', '0101044421321',
    'Casado(a)',
    '{"nome": "Lucineide de Campos", "data_nascimento": "1984-09-03"}', 
    1, '[{"nome": "Ana Carolina Vitoria de Campos Camargo", "data_nascimento": "2006-07-08"}]',
    NULL, '(11) 98492-0162', NULL, NULL,
    '03965-000', 'Rua Tita Ruffo', '40', 'Casa 3', 'Cidade São Mateus', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus', 2, '8.80',
    '2021-09-27', NULL, NULL, NULL,
    'GG', '44', 'G', NULL,
    '2026-01-08', '2025-09-18', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 2. Elias Santos Ribeiro
(
    'Elias Santos Ribeiro',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Regionais - Hospital Cidade Tiradentes',
    '15:30 as 23:30',
    '2023-01-12', '2023-01-12', NULL, '1983-04-05',
    'Masculino',
    '42.873.670-1', '298.890.298-47', '131.18133.77-4', '04114489798',
    'Casado(a)',
    '{"nome": "Eliane Souza Geglio Ribeiro", "data_nascimento": "1980-11-26"}', 
    2, '[{"nome": "Jessika Eliana Geglio Ribeiro", "data_nascimento": "2002-10-12"}, {"nome": "Mariana Souza Geglio Ribeiro", "data_nascimento": "2008-01-14"}]',
    'eliasrib83@gmail.com', '(11) 98082-1057', '(11) 91580-6359', '(11) 93023-1364',
    '08131-370', 'Rua Dom Joao Peres De Aboim', '20', 'AP 104 BL 1 B', 'Itaim Paulista', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus', 2, '9.66',
    '2023-01-10', NULL, NULL, NULL,
    'G', '44', 'G', NULL,
    '2022-03-14', '2025-01-08', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 3. Julia Nascimento Da Silva
(
    'Julia Nascimento Da Silva',
    'Financeiro',
    'ativo',
    'GSM',
    'Administrativo',
    '07:00 as 17:00',
    '2021-08-17', '2021-08-17', NULL, '2000-12-06',
    'Feminino',
    '38.272.048-9', '403.067.268-07', '139.83273.54-7', '07349306273',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    'julia@gsmnewparking.com.br', '(11) 99727-3061', '(21) 19947-0050', '011949528324',
    '02413-000', 'Avenida Engenheiro Caetano Alvares', '4579', 'AP 42 Bloco B', 'Imirim', 'São Paulo', 'SP',
    'Não Optante', NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2024-05-09', '2024-12-04', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 4. Eduardo Gomes Da Silva
(
    'Eduardo Gomes Da Silva',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'Espaço HAOC',
    '10:00 as 19:00',
    '2026-01-07', '2026-01-07', NULL, '1984-05-31',
    'Masculino',
    '38.043.968-2', '332.984.768-97', '200.34235.72-2', '0204467768175',
    'Solteiro(a)',
    NULL, 
    2, '[{"nome": "Sophia Lopes Da Rocha Gomes", "data_nascimento": "2012-05-05"}, {"nome": "João Pedro Lopes Da Rocha Gomes", "data_nascimento": "2017-10-05"}]',
    'gomeseduardo1984@gmail.com', '(11) 96196-9718', NULL, NULL,
    '04168-040', 'Rua General Enrico Caviglia', '425', 'Casa', 'Vila Morais', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus, Metrô', 4, '10.00',
    '2026-01-07', NULL, NULL, NULL,
    'GG', '46', NULL, NULL,
    '2032-11-14', '2026-12-29', '2026-12-29', NULL, NULL, NULL, NULL,
    '2026-03-07', NULL,
    NULL, NULL
),

-- 5. Leandro Dos Santos Barcelar Teodoro
(
    'Leandro Dos Santos Barcelar Teodoro',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Regionais - Hospital Itaim',
    '06:00 as 14:00',
    '2023-05-15', '2023-05-15', NULL, '1995-11-22',
    'Masculino',
    '49.167.236-6', '426.771.158-59', '210.72863.47-4', '06378998871',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    NULL, NULL, NULL, NULL,
    '08121-009', 'Rua Carlos Maria Alvear', '133', 'Casa', 'Jardim São Luís', 'São Paulo', 'SP',
    'Não Optante', NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2025-03-19', '2025-06-11', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 6. Leonardo Cavalcante Dos Santos
(
    'Leonardo Cavalcante Dos Santos',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Itaquera - Instituto',
    '07:00 as 15:00',
    '2023-09-01', '2023-09-01', NULL, '1986-11-07',
    'Masculino',
    '40.587.632-4', '228.299.228-83', '207.89795.18-8', '03555858204',
    'Casado(a)',
    '{"nome": "Francyelle Gomes da Silva", "data_nascimento": "1986-07-04"}', 
    0, NULL,
    NULL, '(11) 98526-6188', NULL, NULL,
    '08290-530', 'Rua Iná', '42', 'Casa 3', 'Itaquera', 'São Paulo', 'SP',
    'Não Optante', NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2032-09-20', '2024-08-28', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 7. Nathalia De Oliveira Scaglione
(
    'Nathalia De Oliveira Scaglione',
    'Assistente Administrativo',
    'afastado',
    'GSM',
    'Administrativo',
    '08:00 as 18:00',
    '2024-12-09', '2024-12-09', NULL, '2000-10-05',
    'Feminino',
    '50.771.515-9', '491.182.398-46', '207.79639.88-4', NULL,
    'Solteiro(a)',
    NULL, 
    1, '[{"nome": "Miguel De Oliveira Araujo", "data_nascimento": "2025-12-02"}]',
    'nathalia.scaglione33@gmail.com', '(11) 98875-7897', '(11) 94722-1899', NULL,
    '07155-000', 'Avenida Salgado Filho', '2790', 'AP 154 AN 15 BL A', 'Centro', 'Guarulhos', 'SP',
    'Vale Transporte', 'Ônibus, Metrô', 4, '22.80',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    NULL, '2025-12-05', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 8. Mike Ferreira Dos Santos
(
    'Mike Ferreira Dos Santos',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Regionais - Hospital Itaim',
    '14:00 as 22:00',
    '2025-12-01', '2025-12-01', NULL, '1996-09-19',
    'Masculino',
    '38.729.040-0', '545.924.298-17', '148.73918.92-4', '06702776910',
    'Casado(a)',
    '{"nome": "Daniele Silva dos Santos", "data_nascimento": "1994-06-29"}', 
    1, '[{"nome": "Bernardo dos Santos", "data_nascimento": "2019-06-26"}]',
    'mike.frrsantos@gmail.com', '(11) 95224-4478', NULL, NULL,
    '08121-210', 'Rua Agrolandia', '3', 'Casa', 'Jardim Camargo Novo', 'São Paulo', 'SP',
    'Não Optante', NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2026-04-07', '2026-11-25', '2026-11-25', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 9. Mozar Alvim Lima
(
    'Mozar Alvim Lima',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Regionais - Hospital Neomater SBC',
    '14:00 as 22:00',
    '2024-11-11', '2024-11-11', NULL, '1962-10-25',
    'Masculino',
    '13.364.864-3', '008.721.618-38', '108.41057.29-7', '02613923945',
    'Casado(a)',
    '{"nome": "Fabiana Cristina Marane", "data_nascimento": null}', 
    2, '[{"nome": "Amanda de Souza Lima", "data_nascimento": "2000-01-01"}, {"nome": "Daniel de Souza Lima", "data_nascimento": "2002-01-01"}]',
    'mozarccb@hotmail.com', '(11) 97803-0562', '(11) 95445-7422', NULL,
    '09572-480', 'Rua Jurua', '91', 'Casa', 'Nova Gerty', 'São Caetano Do Sul', 'SP',
    'Auxílio Combustível', NULL, NULL, '110.00',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2027-09-01', '2025-11-08', '2025-11-08', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 10. Luiz Miguel Ferreira Da Silva Oliveira
(
    'Luiz Miguel Ferreira Da Silva Oliveira',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'IGESP - Pronto Atendimento Santos',
    '06:30 as 15:30',
    '2025-12-01', '2025-12-01', NULL, '1983-09-22',
    'Masculino',
    '35.398.814-5', '323.025.578-08', NULL, '02621106690',
    'Solteiro(a)',
    NULL, 
    2, '[{"nome": "Enzo Gabriel Rodrigues de Oliveira", "data_nascimento": "2013-08-07"}, {"nome": "Luiz Miguel Ferreira da Silva Oliveira Junior", "data_nascimento": "2025-12-25"}]', -- Data ajustada para formato válido
    NULL, '(13) 97403-8624', NULL, NULL,
    '11320-007', 'Rua Benedito Calixto', '239', 'AP 33', 'Centro', 'São Vicente', 'SP',
    'Vale Transporte', 'Onibus', 2, '10.70',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2031-10-13', '2026-11-25', '2026-11-25', NULL, NULL, NULL, NULL,
    '2026-01-29', NULL,
    NULL, NULL
),

-- 11. Paulo Henrique Alauk
(
    'Paulo Henrique Alauk',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'Espaço HAOC',
    '12:00 as 21:00',
    '2023-06-01', '2023-06-01', NULL, '1971-02-14',
    'Masculino',
    '18.355.717-7', '116.149.885-01', '228.98801.69-0', '02227777307',
    'Casado(a)',
    NULL, 
    3, '[{"nome": "Karen Receba Rodrigues Alauk", "data_nascimento": "2008-03-08"}]',
    NULL, '(11) 99122-9188', '(11) 98865-9292', NULL,
    '08050-050', 'Rua Fruta Do Paraiso', '530', 'A', 'Vila Jacui', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus', 2, '9.24',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2024-09-17', '2025-06-11', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 12. Pamela Vitoria Faustino Bretas
(
    'Pamela Vitoria Faustino Bretas',
    'Operador De Caixa',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Itaquera - Torre',
    '12:00 as 22:00',
    '2023-01-16', '2023-01-16', NULL, '1999-12-20',
    'Feminino',
    '54.742.197-7', '485.832.828-70', '238.23147.14-1', NULL,
    'Solteiro(a)',
    NULL, 
    0, NULL,
    NULL, NULL, NULL, NULL,
    '08370-250', 'Rua Jose Carlos Peixoto Spinardi', '111', 'Casa', 'Jardim Sao Joao (Sao Rafael)', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus', 2, '9.66',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    NULL, '2025-01-11', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 13. Vanderson Esteves Do Nascimento
(
    'Vanderson Esteves Do Nascimento',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'IGESP - Pronto Atendimento Anália Franco',
    '06:30 as 15:30',
    '2025-12-10', '2025-12-10', NULL, '1986-09-08',
    'Masculino',
    '43.225.249-6', '355.898.278-92', '135.05444.85-4', '03581444276',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    'vanderson040981@gmail.com', '(11) 97029-4346', '(11) 96834-4646', NULL,
    '03174-000', 'Rua Serra Da Bocaina', '547', 'Ap 802', 'Quarta Parada', 'São Paulo', 'SP',
    'Vale Transporte', 'Onibus, Metro', 4, '20.40',
    '2025-12-10', NULL, NULL, NULL,
    'M', '42', '42', NULL,
    '2032-08-19', NULL, NULL, NULL, NULL, NULL, NULL,
    '2026-01-29', NULL,
    NULL, NULL
),

-- 14. Nelson Cristiano Olimpio
(
    'Nelson Cristiano Olimpio',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'IGESP - Hospital Santo Amaro',
    '06:30 as 15:30',
    '2025-11-11', '2025-11-11', NULL, '1982-11-15',
    'Masculino',
    '33.537.742-7', '221.170.468-94', '132.79998.93-9', '06949965468',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    'nelsonguerreiro91@hotmail.com', '(11) 98171-5780', NULL, NULL,
    '04852-000', 'Rua Engenheiro Guaracy Torres', '32', 'Viela 337', 'Jardim Shangrila', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus', 2, '10.00',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2034-11-26', '2026-11-06', '2026-11-06', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 15. Luiz Marcos Querino De Araujo
(
    'Luiz Marcos Querino De Araujo',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Regionais - Hospital Itaquá',
    '11:00 as 20:00',
    '2021-11-01', '2021-11-01', NULL, '1993-10-09',
    'Masculino',
    '49.581.087-3', '428.181.038-27', '204.91232.78-5', '05736593368',
    'Solteiro(a)',
    NULL, 
    1, '[{"nome": "Enzo Querino de Araujo Gomes", "data_nascimento": "2018-10-05"}]',
    NULL, '(11) 95246-2163', NULL, NULL,
    '08576-250', 'Rua Coringa', '38', 'Casa', 'Vila Virginia', 'Itaquaquecetuba', 'SP',
    'Vale Transporte', 'Onibus', 2, '10.00',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2033-02-02', '2025-11-19', '2025-11-19', '2026-11-19', '2026-11-19', '2025-11-19', '2025-11-19',
    NULL, NULL,
    NULL, NULL
);


INSERT INTO `funcionarios` (
    `nome`, `funcao`, `status`, `empresa`, `local`, `horario`, 
    `data_admissao`, `data_inicio`, `data_demissao`, `data_nascimento`, 
    `genero`, `rg`, `cpf`, `pis`, `cnh_numero`, 
    `estado_civil`, `dados_conjuge`, `quantidade_filhos`, `nome_filhos`, 
    `email_pessoal`, `telefone_1`, `telefone_2`, `telefone_3`, 
    `cep`, `rua`, `numero`, `complemento`, `bairro`, `cidade`, `estado`, 
    `opcao_transporte`, `meio_transporte`, `qtd_transporte`, `valor_transporte`, 
    `data_entrega_uniforme`, `data_devolucao_uniforme`, `data_reposicao_uniforme`, `motivo_reposicao_uniforme`, 
    `tamanho_camisa`, `tamanho_calca`, `tamanho_jaqueta`, `tamanho_bota`, 
    `validade_cnh`, `validade_exame_clinico`, `validade_audiometria`, `validade_eletrocardiograma`, 
    `validade_eletroencefalograma`, `validade_glicemia`, `validade_acuidade_visual`, 
    `validade_treinamento`, `validade_contrato_experiencia`, 
    `motivo_demissao`, `elegivel_recontratacao`
) VALUES 
-- 1. Wilgner Da Silva Stadler
(
    'Wilgner Da Silva Stadler',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'Hapvida',
    '07:00 as 15:00',
    '2025-12-18', '2025-12-18', NULL, '2001-09-07',
    'Masculino',
    '37.963.584-7', '447.847.648-95', '210.66950.89-1', '07690496310',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    'wilgner.stadler@hotmail.com', '(11) 94172-3611', '(11) 99703-6185', NULL,
    '09484-524', 'Rua Ipê Roxo', '249', 'Casa', 'Dos Casas', 'São Bernardo Do Campo', 'SP',
    'Não Optante', NULL, NULL, NULL,
    '2025-12-18', NULL, NULL, NULL,
    'M', '46', 'G', '42',
    '2035-11-17', '2026-12-15', '2026-12-15', NULL, NULL, NULL, NULL,
    '2026-02-15', NULL,
    NULL, NULL
),

-- 2. Nelson Do Nascimento Moia
(
    'Nelson Do Nascimento Moia',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Itaquera - AME',
    '11:00 as 19:00',
    '2023-01-16', '2023-01-16', NULL, '1966-05-31',
    'Masculino',
    '16.635.153-2', '051.156.348-56', '120.38750.91-4', '04222213203',
    'Casado(a)',
    NULL, 
    0, NULL,
    NULL, '(11) 93803-8423', '(11) 24568-100', NULL,
    '08285-010', 'Rua Serrana', '1414', 'Casa', 'Cidade Lider', 'São Paulo', 'SP',
    'Não Optante', NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2027-07-14', '2025-01-11', '2025-01-11', '2026-01-11', '2026-01-11', '2025-01-11', '2025-01-11',
    NULL, NULL,
    NULL, NULL
),

-- 3. Wellington Calixto Moreira
(
    'Wellington Calixto Moreira',
    'Faxineiro(a)',
    'ativo',
    'GSM',
    'Faxineiro (a) Rotativo',
    '07:00 as 17:00',
    '2025-12-01', '2025-12-01', NULL, '1986-04-20',
    'Masculino',
    '42.710.374-5', '342.187.358-59', '209.79889.92-2', NULL,
    'Casado(a)',
    '{"nome": "Juliana dos Santos Teodoro", "data_nascimento": "1988-01-16"}', 
    2, '[{"nome": "Ana Carolina Teodoro Moreira", "data_nascimento": "2006-11-14"}, {"nome": "Nicolas Gabriel Teodoro Moreira", "data_nascimento": "2009-09-18"}]',
    'jhonnywilly24@gmail.com', '(11) 98230-3941', '(11) 98520-9170', NULL,
    '08570-663', 'Rua Ipiau', '17', 'Casa', 'Vila Esperança', 'Itaquaquecetuba', 'SP',
    'Vale Transporte', 'Onibus, Trem', 4, '22.70',
    '2025-12-01', NULL, NULL, NULL,
    'GG', '44', NULL, '42',
    NULL, '2026-10-26', NULL, NULL, NULL, NULL, NULL,
    '2026-01-29', NULL,
    NULL, NULL
),

-- 4. Maria Aparecida Da Silva Santos
(
    'Maria Aparecida Da Silva Santos',
    'Operador De Caixa',
    'ativo',
    'GSM',
    'IGESP - Pronto Atendimento Anália Franco',
    '07:00 as 17:00',
    '2025-08-27', '2025-08-27', NULL, '1987-10-28',
    'Feminino',
    '58.563.487-7', '046.320.935-48', '163.74097.69-7', NULL,
    'Casado(a)',
    '{"nome": "Gilvan de Sousa Damasceno", "data_nascimento": "1982-10-06"}', 
    2, '[{"nome": "Camila Santos Damasceno", "data_nascimento": "2008-03-21"}, {"nome": "Heitor Santos Damasceno", "data_nascimento": "2018-07-19"}]',
    NULL, '(11) 96228-0340', NULL, NULL,
    '08421-155', 'Rua Brasil', '120', 'Ap 42, Bloco 1', 'Vila Cosmopolita', 'São Paulo', 'SP',
    'Vale Transporte', 'Onibus, Metrô, Trem', 6, '32.40',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    NULL, '2026-08-28', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 5. Ronaldo Rocha Da Silva
(
    'Ronaldo Rocha Da Silva',
    'Analista De Departamento Pessoal',
    'ativo',
    'GSM',
    'Administrativo',
    '08:00 as 18:00',
    '2025-10-27', '2025-10-27', NULL, '1974-01-21',
    'Masculino',
    '23.693.518-5', '496.468.693-00', '123.92715.36-1', '01966967290',
    'Solteiro(a)',
    NULL, 
    3, '[{"nome": "Pedro Henrique Rocha Fernandes", "data_nascimento": "2006-11-16"}, {"nome": "Andre Rocha Fernandes", "data_nascimento": "2012-12-17"}, {"nome": "Roberto Augusto Ribeiro da Silva", "data_nascimento": "2019-10-30"}]',
    'ronaldorsrochall@gmail.com', '(11) 99588-1244', '(11) 2949-7192', NULL,
    '02210-070', 'Rua Marisa De Sousa', '139', 'Casa 1', 'Jardim Brasil', 'São Paulo', 'SP',
    'Vale Transporte', 'Onibus, Metro', 4, '21.42',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2026-02-12', '2026-10-23', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 6. Vinicius Vieira De Melo
(
    'Vinicius Vieira De Melo',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'IGESP - Pronto Atendimento Santos',
    '09:00 as 17:00',
    '2025-12-18', '2025-12-18', NULL, '1994-04-11',
    'Masculino',
    '43.861.277-2', '424.561.358-06', '207.86809.61-7', '05900402247',
    'Solteiro(a)',
    NULL, 
    1, '[{"nome": "Luna Cavalcanti Vieira", "data_nascimento": "2023-02-28"}]',
    NULL, '(13) 98225-3586', NULL, NULL,
    '11095-215', 'Caminho São Manoel', '118', 'Casa 8, Beco 118', 'São Manoel', 'Santos', 'SP',
    'Vale Transporte', 'Ônibus', 4, '10.50',
    '2025-12-18', NULL, NULL, NULL,
    'G', '40', NULL, NULL,
    '2035-03-05', '2026-12-15', '2026-12-15', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 7. Steffany Lais Pereira Da Silva
(
    'Steffany Lais Pereira Da Silva',
    'Operador De Caixa',
    'ativo',
    'GSM',
    'IGESP - Pronto Atendimento Congonhas',
    '07:00 as 17:00',
    '2025-12-01', '2025-12-01', NULL, '2004-06-02',
    'Feminino',
    '57.283.675-2', '504.360.598-78', '236.83699.10-4', NULL,
    'Solteiro(a)',
    NULL, 
    0, NULL,
    'steffanylais62@gmail.com', '(11) 98478-0206', '(11) 98674-5663', '(11) 95880-2083',
    '05212-060', 'Rua Estados Unidos', '30', 'Casa 1', 'Jardim Da Conquista', 'São Paulo', 'SP',
    'Vale Transporte', 'Onibus, Trem', 6, '32.40',
    '2025-12-01', NULL, NULL, NULL,
    'M', '40', 'M', NULL,
    NULL, '2026-11-27', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 8. Tainara Larissa Da Conceição
(
    'Tainara Larissa Da Conceição',
    'Auxiliar De Escritório',
    'ativo',
    'GSM',
    'Administrativo',
    '08:00 as 18:00',
    '2025-09-04', '2025-09-04', NULL, '1996-05-19',
    'Feminino',
    '39.201.049-5', '458.248.728-99', '236.15427.83-8', NULL,
    'Solteiro(a)',
    NULL, 
    1, '[{"nome": "Henrique Conceição dos Reis", "data_nascimento": "2017-02-08"}]',
    'tainara_larissa@hotmail.com.br', '(11) 97739-6949', '(11) 97759-9962', NULL,
    '08050-715', 'Travessa Flor De Pessego', '134', 'Casa 3', 'Jardim Das Camelas', 'São Paulo', 'SP',
    'Vale Transporte', 'Onibus, Metrô', 4, '21.42',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    NULL, '2026-08-01', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 9. Rogerio Dos Santos Moreira
(
    'Rogerio Dos Santos Moreira',
    'Encarregado De Estacionamento',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Regionais - Hospital Neomater SBC',
    '08:00 as 18:00',
    '2022-05-16', '2022-05-16', NULL, '1986-05-12',
    'Masculino',
    '42.962.303-3', '331.256.908-70', '207.33963.01-8', '04039639037',
    'Solteiro(a)',
    NULL, 
    1, '[{"nome": "Vinicius Rodrigues Moreira", "data_nascimento": "2007-10-17"}]',
    NULL, '(11) 97675-1001', NULL, NULL,
    '01137-040', 'Rua Padre Luis Alves De Siqueira', '953', 'Casa', 'Barra Funda', 'São Paulo', 'SP',
    'Não Optante', NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2022-12-18', '2025-06-10', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 10. Rubens Soares
(
    'Rubens Soares',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Itaquera - Sede',
    '10:00 as 18:00',
    '2023-02-01', '2023-02-01', NULL, '1963-07-20',
    'Masculino',
    '16.952.827-3', '054.684.578-90', '107.94111.21-9', '01230321498',
    'Solteiro(a)',
    NULL, 
    1, '[{"nome": "Samuel Henrique Soares", "data_nascimento": "2010-05-20"}]',
    'rubenssoares007mundial@gmail.com', '(11) 99348-6487', '(11) 95946-5223', NULL,
    '03986-200', 'Rua Marcondes Machado', '234', 'Casa', 'Vila Alzira', 'São Paulo', 'SP',
    'Vale Transporte', 'Onibus', 2, '10.40',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2025-01-17', '2024-01-27', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 11. Marcelo Da Silva Santos
(
    'Marcelo Da Silva Santos',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Itaquera - Sede',
    '11:00 as 19:00',
    '2024-02-01', '2024-02-01', NULL, '1970-06-14',
    'Masculino',
    '23.260.142-2', '134.920.038-77', '123.73380.89-9', '03045090670',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    'celinhorcp@yahoo.com.br', '(11) 98483-2698', NULL, NULL,
    '03474-020', 'Rua Coronel João De Oliveira Melo', '451', 'Casa', 'Vila Antonieta', 'São Paulo', 'SP',
    'Auxílio Combustível', NULL, NULL, '105.00',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2026-03-19', '2026-01-26', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 12. Thamiris Lima Da Silva Santos
(
    'Thamiris Lima Da Silva Santos',
    'Operador De Caixa',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Itaquera - Sede',
    '06:00 as 15:00',
    '2025-10-01', '2025-10-01', NULL, '1992-08-30',
    'Feminino',
    '48.295.219-2', '425.097.538-00', '206.82364.50-3', NULL,
    'Casado(a)',
    '{"nome": "Vanderson Silva dos Santos", "data_nascimento": "1982-10-27"}', 
    2, '[{"nome": "Luisa Lima dos Santos", "data_nascimento": "2021-09-16"}, {"nome": "Victor Hugo Lima dos Santos", "data_nascimento": "2017-04-25"}]',
    NULL, '(11) 95474-4020', '(11) 98474-0413', NULL,
    '08451-250', 'Rua Francisco Godinho', '355', 'Casa', 'Lajeado', 'São Paulo', 'SP',
    'Vale Transporte', 'Onibus, Trem', 6, '32.40',
    '2025-10-01', NULL, NULL, NULL,
    'P', '36', 'PP', NULL,
    NULL, '2026-09-26', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
);


INSERT INTO `funcionarios` (
    `nome`, `funcao`, `status`, `empresa`, `local`, `horario`, 
    `data_admissao`, `data_inicio`, `data_demissao`, `data_nascimento`, 
    `genero`, `rg`, `cpf`, `pis`, `cnh_numero`, 
    `estado_civil`, `dados_conjuge`, `quantidade_filhos`, `nome_filhos`, 
    `email_pessoal`, `telefone_1`, `telefone_2`, `telefone_3`, 
    `cep`, `rua`, `numero`, `complemento`, `bairro`, `cidade`, `estado`, 
    `opcao_transporte`, `meio_transporte`, `qtd_transporte`, `valor_transporte`, 
    `data_entrega_uniforme`, `data_devolucao_uniforme`, `data_reposicao_uniforme`, `motivo_reposicao_uniforme`, 
    `tamanho_camisa`, `tamanho_calca`, `tamanho_jaqueta`, `tamanho_bota`, 
    `validade_cnh`, `validade_exame_clinico`, `validade_audiometria`, `validade_eletrocardiograma`, 
    `validade_eletroencefalograma`, `validade_glicemia`, `validade_acuidade_visual`, 
    `validade_treinamento`, `validade_contrato_experiencia`, 
    `motivo_demissao`, `elegivel_recontratacao`
) VALUES 
-- 1. Marcio Gerson Da Silva
(
    'Marcio Gerson Da Silva',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Regionais - Hospital Cidade Tiradentes',
    '07:00 as 19:00',
    '2021-10-31', '2021-10-31', NULL, '1975-03-23',
    'Masculino',
    '27.858.890-6', '173.568.528-37', '124.26392.16-0', '01064545404',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    NULL, '(11) 98503-9301', NULL, NULL,
    '08474-130', 'Rua Ave De Prata', '86', 'Casa', 'Conjunto Habitacional Castro A', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus', 2, '8.80',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2025-11-09', '2025-11-29', '2025-11-29', '2026-11-29', '2026-11-29', '2025-11-29', '2025-11-29',
    NULL, NULL,
    NULL, NULL
),

-- 2. Scarlett Rodrigues Da Silva
(
    'Scarlett Rodrigues Da Silva',
    'Operador De Caixa',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Itaquera - Sede',
    '07:00 as 17:00',
    '2022-04-11', '2022-04-11', NULL, '1997-07-01',
    'Feminino',
    '52.816.824-1', '484.417.668-43', '137.99537.50-2', NULL,
    'Solteiro(a)',
    NULL, 
    1, '[{"nome": "Alice Valentina Rodrigues dos Santos", "data_nascimento": "2016-07-19"}]',
    'scarlettrodrigues511@gmail.com', '(11) 94052-4610', '(11) 99411-3867', NULL,
    '08460-528', 'Travessa Maria Leneru', '19', 'Casa', 'Jardim Recanto Das Rosas', 'São Paulo', 'SP',
    'Vale Transporte', 'Onibus, Trem', 4, '37.80',
    '2022-04-26', NULL, '2024-01-11', 'DESGASTES TEMPO DE USO',
    'M', '38', 'G', NULL,
    NULL, '2024-04-07', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 3. Rodrigo Maia Lima Batista
(
    'Rodrigo Maia Lima Batista',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Regionais - Hospital Cidade Tiradentes',
    '14:00 as 22:00',
    '2025-10-16', '2025-10-16', NULL, '1984-04-25',
    'Masculino',
    '34.098.547-1', '330.670.268-45', '138.96424.85-7', '02463873227',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    'rodirgomaialima33@gmail.com', '(11) 95495-2626', NULL, NULL,
    '08255-200', 'Rua Bob Marley', '21', 'AP 21B', 'Conjunto Residencial Jose Bonifacio', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus', 4, '22.00',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2032-03-24', '2026-10-14', '2026-10-14', NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 4. Valdemir De Freitas Pereira
(
    'Valdemir De Freitas Pereira',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Itaquera - AME',
    '06:00 as 14:20',
    '2021-03-01', '2021-03-01', NULL, '1959-06-27',
    'Masculino',
    '12.427.562-X', '011.230.228-95', '106.15897.78-6', '00672882994',
    'Divorciado(a)',
    NULL, 
    0, NULL,
    NULL, NULL, NULL, NULL,
    '03689-060', 'Rua Ibiranhem', '140', 'Casa A', 'Jardim Nordeste', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus', 2, '8.80',
    '2022-03-03', NULL, NULL, NULL,
    'GG', '54', '55', NULL,
    '2024-07-15', '2025-11-06', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 5. Wellington Martins De Santana
(
    'Wellington Martins De Santana',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Regionais - Hospital Itaquá',
    '07:00 as 19:00',
    '2021-11-01', '2021-11-01', NULL, '1993-06-03',
    'Masculino',
    '49.747.279-X', '422.465.918-21', '165.54930.40-0', '05813916362',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    NULL, '(11) 98386-4979', NULL, NULL,
    '08597-020', 'Rua Do Sol', '735', 'Casa', 'Vila Celeste', 'Itaquaquecetuba', 'SP',
    'Vale Transporte', 'Ônibus', 2, '8.80',
    '2021-10-26', NULL, NULL, NULL,
    'GG', '54', 'GG', NULL,
    '2023-02-07', '2024-11-01', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 6. Paulo Carlos Rodrigues Barros
(
    'Paulo Carlos Rodrigues Barros',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Regionais - Hospital Itaim',
    '06:00 as 18:00',
    '2021-11-26', '2021-11-26', NULL, '1980-10-23',
    'Masculino',
    '42.338.153-2', '226.265.138-81', '130.01269.85-4', '06589151108',
    'Casado(a)',
    '{"nome": "Kelma da Silva Viana", "data_nascimento": "1987-11-29"}', 
    3, '[{"nome": "Carlos Eduardo Rodrigues Da Silva Barros", "data_nascimento": "2012-12-18"}, {"nome": "Steffany Cicera da Silva Barros", "data_nascimento": "2003-02-06"}, {"nome": "Kamilly Vitoria da Silva Barros", "data_nascimento": "2005-02-27"}]',
    'paulocarlos2921@gmail.com', '(11) 96724-2517', NULL, NULL,
    '08121-007', 'Rua Espumas', '5B', NULL, 'Jardim Sao Luis', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus', 2, '8.80',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2025-12-03', '2025-12-12', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 7. Samira Ferreira Oliveira Da Silva
(
    'Samira Ferreira Oliveira Da Silva',
    'Operador De Caixa',
    'ativo',
    'GSM',
    'Hapvida',
    '09:00 as 17:20',
    '2025-05-27', '2025-05-27', NULL, '2004-08-14',
    'Feminino',
    '63.657.107-5', '573.593.298-50', '272.77803.98-7', NULL,
    'Solteiro(a)',
    NULL, 
    0, NULL,
    'ferreirasamira979@gmail.com', '(11) 91697-7587', '(11) 94817-7762', '(19) 99708-2438',
    '09850-370', 'Rua George VI', '99', 'Casa', 'Alves Dias', 'São Bernardo Do Campo', 'SP',
    'Vale Transporte', 'Onibus', 2, '11.90',
    '2025-05-26', NULL, NULL, NULL,
    'M', '44', 'M', NULL,
    NULL, '2026-05-23', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 8. Sidnei Fernandes
(
    'Sidnei Fernandes',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Itaquera - Sede',
    '07:00 as 15:00',
    '2022-04-15', '2022-04-15', NULL, '1952-10-14',
    'Masculino',
    '63.685.401-6', '829.739.489-11', '043.68763.34-0', '5151944834',
    'Casado(a)',
    '{"nome": "Rafaela Fernandes", "data_nascimento": null}', 
    0, NULL,
    NULL, NULL, NULL, NULL,
    '08461-170', 'Rua Cacarema', '298', 'Casa 04', 'Vila Popular', 'São Paulo', 'SP',
    'Auxílio Combustível', NULL, NULL, '110.00',
    '2025-04-15', NULL, NULL, NULL,
    'M', '42', 'M', NULL,
    '2026-11-10', '2023-04-12', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 9. Robson Dos Santos Azevedo
(
    'Robson Dos Santos Azevedo',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'Hapvida',
    '14:00 as 22:00',
    '2024-04-10', '2024-04-10', NULL, '1979-07-26',
    'Masculino',
    '32.701.568-8', '269.085.518-65', '127.28413.81-0', '00837183889',
    'Viúvo(a)',
    NULL, 
    0, NULL,
    'arobsondossantosazevedo@gmail.com', '(11) 94738-2771', '(11) 95951-886', NULL,
    '09822-045', 'Rua Pavuna', '28', 'Casa 4', 'Jardim Jussara', 'São Bernardo Do Campo', 'SP',
    'Não Optante', NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2031-09-03', '2025-04-09', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
),

-- 10. Reanto Barbosa De Souza
(
    'Reanto Barbosa De Souza',
    'Operador De Estacionamento',
    'ativo',
    'GSM',
    'Grupo Santa Marcelina Itaquera - Instituto',
    '15:00 as 23:00',
    '2022-11-10', '2022-11-10', NULL, '1985-09-11',
    'Masculino',
    '44.125.374-X', '328.363.268-59', '133.73322.77-3', '03140373831',
    'Solteiro(a)',
    NULL, 
    0, NULL,
    NULL, '(11) 97681-4893', NULL, NULL,
    '08430-110', 'Rua Jose Martins Dos Santos', '346', 'C3', 'Jardim Santa Terezinha', 'São Paulo', 'SP',
    'Auxílio Combustível', NULL, NULL, '110.00',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2032-03-14', '2025-10-28', '2025-10-28', '2026-10-28', '2026-10-28', '2025-10-28', '2025-10-28',
    NULL, NULL,
    NULL, NULL
),

-- 11. Rosemeire Martins Gomes De Araujo
(
    'Rosemeire Martins Gomes De Araujo',
    'Auxiliar De Serviços Gerais',
    'ativo',
    'GSM',
    'Faxineiro (a) Rotativo',
    '08:00 as 18:00',
    '2025-12-01', '2025-12-01', NULL, '1980-11-01',
    'Feminino',
    '32.632.058-7', '280.837.778-97', '271.00630.12-1', NULL,
    'Divorciado(a)',
    NULL, 
    2, '[{"nome": "Brenda Martins De Araujo", "data_nascimento": "2002-06-24"}, {"nome": "Bianca Vitoria Gomes De Araujo", "data_nascimento": "2003-12-29"}]',
    'gavetavitoria4@gmail.com', '(11) 95795-6083', NULL, NULL,
    '04851-501', 'Estrada Da Ligação', '115', 'Casa', 'Jardim Monte Verde', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus', 2, '8.80',
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    NULL, '2026-11-26', NULL, NULL, NULL, NULL, NULL,
    NULL, NULL,
    NULL, NULL
);






-- GSM

INSERT INTO funcionarios (
    nome, funcao, status, empresa, local, horario, 
    data_admissao, data_inicio, data_demissao, data_nascimento, 
    genero, rg, cpf, pis, cnh_numero, 
    estado_civil, dados_conjuge, quantidade_filhos, nome_filhos, 
    email_pessoal, telefone_1, telefone_2, telefone_3, 
    cep, rua, numero, complemento, bairro, cidade, estado, 
    opcao_transporte, meio_transporte, qtd_transporte, valor_transporte, 
    data_entrega_uniforme, data_devolucao_uniforme, data_reposicao_uniforme, motivo_reposicao_uniforme, 
    tamanho_camisa, tamanho_calca, tamanho_jaqueta, tamanho_bota, 
    validade_cnh, validade_exame_clinico, validade_audiometria, validade_eletrocardiograma, 
    validade_eletroencefalograma, validade_glicemia, validade_acuidade_visual, 
    validade_treinamento, validade_contrato_experiencia, 
    motivo_demissao, elegivel_recontratacao
) VALUES 
-- 1. Gutierres Adolfo Oliveira
(
    'Gutierres Adolfo Oliveira', 'Operador de Estacionamento', 'inativo', 'GSM', 'Grupo Santa Marcelina Itaquera - Sede', '14:00 as 22:00',
    '2025-07-18', '2025-07-18', '2025-12-17', '1988-11-06',
    'Masculino', '44.479.608-3', '365.476.418-56', '162.19168.82-9', '07654187584',
    'Solteiro', NULL, 1, '[{"nome": "Diogo Matheus De Santana Oliveira", "data_nascimento": "2012-06-05"}]',
    NULL, '(11) 91322-6934', '(11) 95472-2213', NULL,
    '08040-620', 'Rua Cajazeiras', '125', 'AP 41 Bloco 6', 'Jardim Casa Pintada', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus', 2, 'R$ 10,00',
    NULL, '2025-12-17', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2031-07-25', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'JC2 - Comportamento Indisciplinar', 'Não'
),
-- 2. Carlos Daniel Reis De Oliveira
(
    'Carlos Daniel Reis De Oliveira', 'Operador de Estacionamento', 'inativo', 'GSM', 'IGESP - Hospital Praia Grande', '12:00 as 21:00',
    '2024-07-01', '2024-07-01', '2025-05-13', '1999-11-15',
    'Masculino', '53.769.441-9', '480.211.518-03', '143.01297.83-5', '07432261199',
    'Solteiro', NULL, 0, NULL,
    'carloz.reis.2026@gmail.com', '(13) 97825-4169', '(13) 97825-4169', '(13) 98803-1030',
    '11350-200', 'Rua Guilherme Raposo', '701', 'Casa', 'Cidade Da Nautica', 'São Vicente', 'SP',
    'Auxílio Combustível', NULL, NULL, 'R$ 150,00',
    NULL, '2025-05-13', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2024-12-21', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'SJ2 - Demissão Sem Justa Causa', 'Avaliar'
),
-- 3. Alan Cesar Delfino (2 Filhos)
(
    'Alan Cesar Delfino', 'Operador de Estacionamento', 'inativo', 'GSM', 'Grupo Santa Marcelina Regionais - Hospital Itaim', '14:00 as 22:00',
    '2025-09-16', '2025-09-16', '2025-11-14', '1979-04-04',
    'Masculino', '29.710.631-4', '283.699.288-38', '128.90426.81-7', '00842746760',
    'Solteiro', NULL, 2, '[{"nome": "Victor Augusto Sousa Delfino", "data_nascimento": "2012-10-03"}, {"nome": "Gustavo Sousa Delfino", "data_nascimento": "2017-03-23"}]',
    NULL, '(11) 94911-1885', '(11) 96108-4664', NULL,
    '08121-120', 'Rua Palmeira Tucuim', '58', 'Casa', 'Jardim Camargo Novo', 'São Paulo', 'SP',
    'Não Optante', NULL, NULL, NULL,
    '2025-11-14', NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2032-09-17', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'PD0 - extinção do ctt de experiência', 'Avaliar'
),
-- 4. Erick Xavier Pires De Alcantara
(
    'Erick Xavier Pires De Alcantara', 'Operador de Estacionamento', 'inativo', 'GSM', 'Grupo Santa Marcelina Itaquera - Sede', '15:00 as 23:00',
    '2024-08-30', '2024-08-30', '2024-09-16', '1991-09-19',
    'Masculino', '48.311.790-3', '855.237.280-01', '538.71331.09-0', '5203533714',
    'Solteiro', NULL, 0, NULL,
    'erickxavierssp1@outlook.com', '(11) 94811-4051', '(11) 98392-6051', NULL,
    '08220-010', 'Rua Patativa', '282', 'Casa', 'Arthur Alvin', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus', 2, 'R$ 9,66',
    NULL, '2024-09-19', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2029-02-21', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'RA1 - pedido de demissão do funcionário', 'Avaliar'
),
-- 5. Marcio Araujo Dos Santos
(
    'Marcio Araujo Dos Santos', 'Operador de Estacionamento', 'inativo', 'GSM', 'Prevent Sênior - Hospital Madri', '06:00 as 14:20',
    '2024-07-18', '2024-07-18', '2024-09-15', '1988-03-13',
    'Masculino', '43.109.347-7', '377.919.678-63', '237.33263.64-9', '06649836805',
    'Solteiro', NULL, 1, '[{"nome": "Maya Araujo Delgado", "data_nascimento": "2016-11-21"}]',
    NULL, NULL, NULL, NULL,
    '06773-080', 'Rua João Del Porto', '423', 'Casa 1', 'Jardim Suina', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus/Trem', 4, 'R$ 23,40',
    NULL, '2024-09-15', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2024-12-12', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'PD0 - extinção do contrato de experiência', 'Avaliar'
),
-- 6. Alerrandro Martins Silva Lima
(
    'Alerrandro Martins Silva Lima', 'Operador de Estacionamento', 'inativo', 'GSM', 'Grupo Santa Marcelina Regionais - Hospital Itaim', '14:00 as 22:00',
    '2025-02-06', '2025-02-06', '2025-07-18', '2000-11-21',
    'Masculino', '38.462.022-X', '401.345.618-48', '268.20867.07-5', '07278910811',
    'Solteiro', NULL, 0, NULL,
    'alerrandro.lele@hotmail.com', '(11) 94801-1442', '(11) 25554-857', NULL,
    '08490-003', 'Rua Do Cobre', '120', 'Casa', 'Conjunto Residencial Prestes Maia', 'São Paulo', 'SP',
    NULL, NULL, NULL, NULL,
    NULL, '2025-07-18', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2034-02-15', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'SJ1 - pedido de demissão do funcionário', 'Avaliar'
),
-- 7. Luis Fernando Quixaba Da Conceicao
(
    'Luis Fernando Quixaba Da Conceicao', 'Operador de Estacionamento', 'inativo', 'GSM', 'Grupo Santa Marcelina Regionais - Hospital Neomater SBC', '11:00 as 19:00',
    '2024-12-02', '2024-12-02', '2025-07-03', '1973-04-04',
    'Masculino', '25.982.431-8', '171.260.388-44', '123.28897.65-9', '03581364842',
    'Solteiro', NULL, 1, '[{"nome": "Luis Miguel Pereira Da Conceicao", "data_nascimento": "2011-03-17"}]',
    'luisfernandoquixaba65@gmail.com', '(11) 99663-6478', '(11) 95661-2959', NULL,
    '09668-070', 'Rua Presidente Wenceslau', '17', 'Casa 1', 'Taboao', 'São Bernardo Do Campo', 'SP',
    'Não Optante', NULL, NULL, NULL,
    NULL, '2025-07-03', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2028-11-22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'SJ2 - Demissão sem justa causa', 'Avaliar'
),
-- 8. Carlos Henrique Lima Oliva
(
    'Carlos Henrique Lima Oliva', 'Operador de Estacionamento', 'inativo', 'GSM', 'Espaço HAOC', '10:00 as 19:00',
    '2025-11-11', '2025-11-11', '2025-12-05', '1998-11-23',
    'Masculino', '55.026.018-3', '478.805.648-88', '150.55207.98-5', '08143387405',
    'Solteiro', NULL, 1, '[{"nome": "Bernardo Oliva Jesus", "data_nascimento": "2023-05-30"}]',
    'carloshenriquelima1558@gmail.com', '(11) 99334-7498', NULL, NULL,
    '05759-230', 'Rua Gilson Rocha Pitta', '19', 'Casa B', 'Jardim Martinica', 'São Paulo', 'SP',
    'Vale Transporte', 'Onibus', 4, 'R$ 20,00',
    NULL, '2025-12-05', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2032-08-13', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'RA2 - pedido de demissão do funcionário', 'Avaliar'
),
-- 9. Elvis De Souza Ferreira
(
    'Elvis De Souza Ferreira', 'Operador de Estacionamento', 'inativo', 'GSM', 'Grupo Santa Marcelina Regionais - Hospital Itaim', '14:00 as 22:00',
    '2025-11-18', '2025-11-18', '2025-11-22', '1974-02-24',
    'Masculino', '21.961.797-1', '142.358.088-50', '123.87881.88-7', '02265049221',
    'Solteiro', NULL, 1, '[{"nome": "Victoria Rosa Ferreira", "data_nascimento": "2006-10-14"}]',
    'ecvv.ferreira@gmail.com', '(11) 95468-8247', '(11) 97342-5404', NULL,
    '08537-010', 'Rua Edmundo Germano Heymer', '131', 'Casa', 'Vila Andrea', 'Ferraz De Vasconcelos', 'SP',
    'Não Optante', NULL, NULL, NULL,
    NULL, '2025-11-22', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2029-03-13', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'SJ2 - demissão sem justa causa', 'Avaliar'
),
-- 10. Daniel Santana Dos Santos
(
    'Daniel Santana Dos Santos', 'Faxineiro (a)', 'inativo', 'GSM', 'Grupo Santa Marcelina Itaquera - Sede', '07:00 as 17:00',
    '2025-10-29', '2025-10-29', '2025-11-06', '1987-06-06',
    'Masculino', '44.362.364-8', '393.843.638-71', '209.79254.24-2', '08225534096',
    'Solteiro', NULL, 0, NULL,
    'dnsantos38@gmail.com', '(11) 95351-4967', '(13) 98137-6910', NULL,
    '08032-004', 'Rua Luiz Bonadiez', '22', 'Casa 2', 'Vila Curuça', 'São Paulo', 'SP',
    'Vale Transporte', 'Onibus', 4, 'R$ 10,98',
    NULL, '2025-11-06', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2033-03-22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'RA1 - pedido de demissão do funcionário', 'Avaliar'
),
-- 11. Christian Beraldo Santiago
(
    'Christian Beraldo Santiago', 'Operador de Estacionamento', 'inativo', 'GSM', 'Espaço HAOC', '06:30 as 15:30',
    '2025-10-13', '2025-10-13', '2025-10-27', '1975-07-01',
    'Masculino', '27.169.580-8', '183.507.678-55', '124.98882.40-7', '03622799402',
    'Solteiro', NULL, 0, NULL,
    'chrisberaldosantiago@gmail.com', '(11) 98210-1834', '(11) 98230-6584', NULL,
    '04455-060', 'Rua Cenerino Branco De Araujo', '617', 'Casa 1', 'Vila Campo Grande', 'São Paulo', 'SP',
    'Não Optante', NULL, NULL, NULL,
    NULL, '2025-10-27', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2033-07-26', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'SJ1 - pedido de demissão do funcionário', 'Avaliar'
),
-- 12. Andre Luis Dadona
(
    'Andre Luis Dadona', 'Operador de Estacionamento', 'inativo', 'GSM', 'Grupo Santa Marcelina Itaquera - Sede', '06:00 as 14:20',
    '2025-04-22', '2025-04-22', '2025-04-22', '1977-12-21',
    'Masculino', '28.960.201-4', '271.418.418-90', '125.14904.94-5', '04380585895',
    'Solteiro', NULL, 0, NULL,
    'andreluisdadona@gmail.com', '(11) 91324-5291', NULL, NULL,
    '03814-000', 'Rua Sampei Sato', '150', 'apto 103', 'Jardim Matarazzo', 'São Paulo', 'SP',
    'Não Optante', NULL, NULL, NULL,
    NULL, '2025-04-22', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2034-04-11', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'SJ2 - Demissão sem justa causa', 'Não'
),
-- 13. Mateus Vitor Paulino De Brito
(
    'Mateus Vitor Paulino De Brito', 'Operador de Estacionamento', 'inativo', 'GSM', 'Grupo Santa Marcelina Itaquera - Sede', '15:00 as 23:00',
    '2024-09-27', '2024-09-27', '2025-04-01', '1999-06-15',
    'Masculino', '37.479.862-X', '445.048.228-06', '237.44192.27-6', '07181478595',
    'Solteiro', NULL, 0, NULL,
    'mateusvitorpaulino@gmail.com', '(11) 98577-0267', NULL, NULL,
    '08215-440', 'Rua Almadina', '57', 'Casa', 'Itaquera', 'São Paulo', 'SP',
    'Vale Transporte', 'Onibus', 2, 'R$ 8,80',
    NULL, '2025-04-01', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2024-10-31', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'JC2 - Demissão com justa causa', 'Não'
);

INSERT INTO funcionarios (
    nome, funcao, status, empresa, local, horario, 
    data_admissao, data_inicio, data_demissao, data_nascimento, 
    genero, rg, cpf, pis, cnh_numero, 
    estado_civil, dados_conjuge, quantidade_filhos, nome_filhos, 
    email_pessoal, telefone_1, telefone_2, telefone_3, 
    cep, rua, numero, complemento, bairro, cidade, estado, 
    opcao_transporte, meio_transporte, qtd_transporte, valor_transporte, 
    data_entrega_uniforme, data_devolucao_uniforme, data_reposicao_uniforme, motivo_reposicao_uniforme, 
    tamanho_camisa, tamanho_calca, tamanho_jaqueta, tamanho_bota, 
    validade_cnh, validade_exame_clinico, validade_audiometria, validade_eletrocardiograma, 
    validade_eletroencefalograma, validade_glicemia, validade_acuidade_visual, 
    validade_treinamento, validade_contrato_experiencia, 
    motivo_demissao, elegivel_recontratacao
) VALUES 
(
    'Igor Alexandre Silva', 'Operador de Estacionamento', 'inativo', 'GSM', 'Grupo Santa Marcelina Regionais - Hospital Cidade Tiradentes', '14:00 as 22:00',
    '2025-04-24', '2025-04-24', '2025-10-28', '2004-02-19',
    'Masculino', '57.624.262-7', '547.598.058-69', '220.21050.11-3', '08264762857',
    'Solteiro', NULL, 0, NULL,
    'igor.alexandre9000@gmail.com', '(11) 96127-9421', '(11) 96887-0040', '(11) 96979-2983',
    '08121-620', 'Rua Eugenio Darodes', '299', 'Casa 1', 'Jardim Mabel', 'São Paulo', 'SP',
    'Vale Transporte', 'Onibus', 4, 'R$ 20,00',
    NULL, '2025-10-28', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2033-02-22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'SJ1 - pedido de demissão do funcionário', 'Avaliar'
),
(
    'Tayna Barbosa Da Silva Lopes Lima', 'Operador de Estacionamento', 'inativo', 'GSM', 'IGESP - Hospital Praia Grande', '07:00 as 15:20',
    '2024-03-01', '2024-03-01', '2025-03-30', NULL,
    'Feminino', '36.227.297-9', '468.104.668-00', '267.34587.13-2', '07102818141',
    'Casado(a)', '{"nome": "Vitor Tadeu Lopes Lima", "data_nascimento": "1995-03-06"}', 2, '[{"nome": "Noah Barbosa Lopes Lima", "data_nascimento": "2019-03-05"}, {"nome": "Kalleb Barbosa Lopes Lima", "data_nascimento": "2022-06-18"}]',
    'Lopes.tv@gmail.com', '(13) 99130-5320', '(13) 99167-9041', NULL,
    '11730-000', 'Rua A Bal Regina Maria', '92', 'Casa', 'Mongagua', 'Mongagua', 'SP',
    'Não Optante', NULL, NULL, NULL,
    NULL, '2025-02-03', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2033-10-26', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'SJ2 - Demissão sem justa causa', 'Avaliar'
),
(
    'Kevin Cintra De Oliveira', 'Operador de Estacionamento', 'inativo', 'GSM', 'Grupo Santa Marcelina Itaquera - Sede', '14:00 as 22:20',
    '2024-11-21', '2024-11-21', '2025-06-28', '2000-12-27',
    'Masculino', '39.091.079-X', '448.962.758-02', '165.13946.63-9', '07728090524',
    'Solteiro', NULL, 0, NULL,
    NULL, '(11) 94609-8215', '(11) 94018-8998', NULL,
    '08663-375', 'Rua Waldemar Seraphim', '213', 'Casa', 'Parque Residencial Casa Branca', 'Suzano', 'SP',
    'Vale Transporte', 'Onibus', 4, 'R$ 30,28',
    NULL, '2025-06-28', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2025-11-13', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'JC2 - demissão por justa causa', 'Não'
),
(
    'Equer Gonçalves Junior', 'Faxineiro (a)', 'inativo', 'GSM', 'Grupo Santa Marcelina Itaquera - Sede', '08:00 as 18:00',
    '2025-03-25', '2025-03-25', '2025-08-19', '1982-04-19',
    'Masculino', '32.683.235-X', '314.306.668-70', '136.88031.81-3', NULL,
    'Casado(a)', '{"nome": "Antonia Jardeane Cavalcante Carvalho Gonçalves", "data_nascimento": "1989-04-14"}', 3, '[{"nome": "Keizy Izabelli Gonçalves Cavalcante Carvalho", "data_nascimento": "2010-08-21"}, {"nome": "Keilly Sophia Gonçalves Cavalcante Carvalho", "data_nascimento": "2013-01-23"}, {"nome": "Kristopher Samuel Gonçalves Cavalcante Carvalho", "data_nascimento": "2018-02-26"}]',
    NULL, '(11) 93490-0661', '(11) 96294-6990', NULL,
    '08070-090', 'Rua Pico Da Neblina', '75', 'Casa', 'Parque Cruzeiro Do Sul', 'São Paulo', 'SP',
    'Vale Transporte', 'Onibus', 4, 'R$ 21,96',
    NULL, '2025-08-19', NULL, NULL,
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'SJ2 - demissão sem justa causa', 'Avaliar'
),
(
    'Jose Benedito Da Cruz Rocha', 'Operador de Estacionamento', 'inativo', 'GSM', 'Grupo Santa Marcelina Itaquera - Sede', '14:00 as 22:00',
    '2025-06-05', '2025-06-05', '2025-06-05', '1966-12-10',
    'Masculino', '16.109.649-9', '086.431.908-88', '120.56291.89-6', '06598598970',
    'Solteiro', NULL, 0, NULL,
    NULL, '(11) 96764-6727', '(11) 25616-057', NULL,
    '08151-602', 'Rua Areias', '91', 'Ap 43, Bloco E', 'Jardim Campos', 'São Paulo', 'SP',
    'Vale Transporte', 'Onibus', 4, 'R$ 10,00',
    NULL, '2025-06-05', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2027-05-11', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'SJ1 - pedido de demissão do funcionário', 'Avaliar'
),
(
    'Gabriel Henrique Barbosa', 'Operador de Estacionamento', 'inativo', 'GSM', 'Grupo Santa Marcelina Regionais - Hospital Cidade Tiradentes', '13:00 as 22:00',
    '2024-08-15', '2024-08-15', '2025-10-02', '1998-03-18',
    'Masculino', '57.189.157-3', '483.609.638-35', '267.98714.14-3', NULL,
    'Solteiro', NULL, 0, NULL,
    'gabrielhenriqueb1133@gmail.com', '(11) 95994-6998', '(11) 94922-9113', NULL,
    '08475-550', 'Rua Apostolo Andre', '330', 'Casa 4', 'Cidade Tiradentes', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus/Trem', 4, 'R$ 23,40',
    NULL, '2025-10-02', NULL, NULL,
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'SJ1 - pedido de demissão do funcionário', 'Avaliar'
),
(
    'Paulo Ricardo Pereira Silva', 'Operador de Estacionamento', 'inativo', 'GSM', 'IGESP - Hospital Praia Grande', '14:00 as 22:00',
    '2024-06-07', '2024-06-07', '2024-07-07', '1997-05-28',
    'Masculino', '52.709.095-5', '458.104.238-09', '210.69859.54-2', '07220414544',
    'Casado(a)', '{"nome": "Luanna Santana Santos", "data_nascimento": "1996-11-05"}', 1, '[{"nome": "Benicio Santana Silva", "data_nascimento": "2019-11-06"}]',
    'paulo.123.delete@gmail.com', '(13) 99166-9765', '(11) 24568-100', NULL,
    '11365-140', 'Av Sambaiatuba', '84', 'Casa 7', 'Jockey Clube', 'São Vicente', 'SP',
    'Auxílio Combustível', NULL, NULL, 'R$ 150,00',
    NULL, '2024-07-07', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2033-05-29', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'PD0 - extinção do ctt de experiência', 'Avaliar'
),
(
    'Edimar Silva Freires', 'Faxineiro (a)', 'inativo', 'GSM', 'Grupo Santa Marcelina Itaquera - Instituto', '07:00 as 17:00',
    '2025-08-19', '2025-08-19', '2025-10-09', '1985-05-14',
    'Masculino', '54.069.165-3', NULL, '025.55666.54-0', NULL,
    'Casado(a)', '{"nome": "Luzinete Dos Santos Silva Freires", "data_nascimento": "1977-09-24"}', 0, NULL,
    NULL, '(11) 96762-0257', NULL, NULL,
    '05212-010', 'Travessa Da Divisa', '17', 'Casa 1', 'Recanto Do Paraiso', 'São Paulo', 'SP',
    'Vale Transporte', 'Onibus, Trem', 6, 'R$ 27,80',
    NULL, '2025-10-09', NULL, NULL,
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'RA1 - pedido de demissão do funcionário', 'Avaliar'
),
(
    'Eduardo Ernesto Oliveira Rocha', 'Operador de Estacionamento', 'inativo', 'GSM', 'IGESP - Hospital Praia Grande', '10:00 as 18:00',
    '2024-06-07', '2024-06-07', '2024-08-15', '1988-09-23',
    'Masculino', '42.050.583-3', '549.037.481-02', '120.23425.33-0', '05434088698',
    'Casado(a)', '{"nome": "Débora Ribeiro De Oliveira", "data_nascimento": "1997-03-19"}', 0, NULL,
    'duardocite123@gmail.com', '(13) 99100-9399', '(13) 95761-8615', NULL,
    '11724-465', 'Rua Cantora Carmem Miranda', '4807', 'Casa', 'Tupiry', 'Praia Grande', 'SP',
    'Não Optante', NULL, NULL, NULL,
    NULL, '2024-08-15', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2027-12-29', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'PD0 - extinção do ctt de experiência', 'Avaliar'
),
(
    'Raphael Aparecido Marchesoni', 'Operador de Estacionamento', 'inativo', 'GSM', 'Grupo Santa Marcelina Regionais - Hospital Cidade Tiradentes', '15:30 as 23:30',
    '2024-06-06', '2024-06-06', '2024-08-08', '1994-09-15',
    'Masculino', '39.652.952-5', '427.251.718-06', '132.68941.17-5', '06884704430',
    'Solteiro', NULL, 1, '[{"nome": "Raphaela Louize De Paula Ferreira Marchesoni", "data_nascimento": "2021-05-16"}]',
    NULL, '(11) 99163-1229', NULL, NULL,
    '08473-090', 'Rua Conjunto Sitio Conceição', '89', 'B12', 'Conjunto Habitacional Sitio Conceição', 'São Paulo', 'SP',
    'Não Optante', NULL, NULL, NULL,
    NULL, '2024-08-08', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2034-07-25', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'PD0 - extinção do ctt de experiência', 'Avaliar'
),
(
    'Charles Oliveira Alves De Moura', 'Operador de Estacionamento', 'inativo', 'GSM', 'Espaço HAOC', '12:00 as 21:00',
    '2024-09-03', '2024-09-03', '2024-10-03', '1955-04-06',
    'Masculino', '77.560.528-2', '630.989.380-71', '056.34606.41-0', '01299119255',
    'Solteiro', NULL, 0, NULL,
    NULL, '(11) 95899-3871', NULL, NULL,
    '01529-000', 'Rua Pires Da Mota', '780', 'Casa', 'Aclimacao', 'São Paulo', 'SP',
    'Não Optante', NULL, NULL, NULL,
    NULL, '2024-10-03', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2027-11-21', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'PD0 - extinção do ctt de experiência', 'Avaliar'
),
(
    'Jordy Crispim De Lima', 'Operador de Estacionamento', 'inativo', 'GSM', 'Hapvida', '07:00 as 15:00',
    '2025-07-21', '2025-07-21', '2025-12-09', '2000-11-24',
    'Masculino', '55.513.338-2', '446.406.208-37', '210.66942.12-0', '07264883458',
    'Solteiro', NULL, 0, NULL,
    NULL, '(11) 92002-7598', '(11) 98418-9957', NULL,
    '09810-555', 'Rua Cristiano Angeli', '551', 'Casa', 'Assunção', 'São Bernardo Do Campo', 'SP',
    'Auxílio Combustível', NULL, NULL, 'R$ 180,00',
    NULL, '2025-12-09', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2033-12-11', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'SJ1 - pedido de demissão do funcionário', 'Avaliar'
),
(
    'Joseniz Dias De Sousa', 'Operador de Estacionamento', 'inativo', 'GSM', 'Grupo Santa Marcelina Itaquera - Sede', '06:00 as 15:00',
    '2025-08-20', '2025-08-20', '2025-10-18', '1977-01-23',
    'Feminino', '37.789.126-5', '329.707.878-22', '163.47994.20-9', '09015500571',
    'Solteiro', NULL, 3, '[{"nome": "Alessandra De Souza Pinheiro", "data_nascimento": "2001-11-04"}, {"nome": "Aline De Souza Pinheiro", "data_nascimento": "2003-04-16"}, {"nome": "Andreina Dias De Souza", "data_nascimento": "2000-01-31"}]',
    NULL, '(11) 97559-6997', NULL, NULL,
    '08223-000', 'Av Caititu', '2225', 'Casa', 'Cidade Antonio Estevao De Carvalho', 'São Paulo', 'SP',
    'Não Optante', NULL, NULL, NULL,
    NULL, '2025-10-18', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2025-10-17', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'PD0 - extinção do ctt de experiência', 'Avaliar'
);












INSERT INTO funcionarios (
    nome, funcao, status, empresa, local, horario, 
    data_admissao, data_inicio, data_demissao, data_nascimento, 
    genero, rg, cpf, pis, cnh_numero, 
    estado_civil, dados_conjuge, quantidade_filhos, nome_filhos, 
    email_pessoal, telefone_1, telefone_2, telefone_3, 
    cep, rua, numero, complemento, bairro, cidade, estado, 
    opcao_transporte, meio_transporte, qtd_transporte, valor_transporte, 
    data_entrega_uniforme, data_devolucao_uniforme, data_reposicao_uniforme, motivo_reposicao_uniforme, 
    tamanho_camisa, tamanho_calca, tamanho_jaqueta, tamanho_bota, 
    validade_cnh, validade_exame_clinico, validade_audiometria, validade_eletrocardiograma, 
    validade_eletroencefalograma, validade_glicemia, validade_acuidade_visual, 
    validade_treinamento, validade_contrato_experiencia, 
    motivo_demissao, elegivel_recontratacao
) VALUES 
-- 1. Weslley Henrique De Jesus Viana
(
    'Weslley Henrique De Jesus Viana', 'Operador de Estacionamento', 'inativo', 'GSM', 'Hapvida', '12:00 as 20:00',
    '2025-09-08', '2025-09-08', '2025-11-06', '1997-03-11',
    'Masculino', '49.201.750-5', '451.435.808-89', NULL, '06515449721',
    'Solteiro', NULL, 0, NULL,
    NULL, NULL, NULL, NULL,
    '09862-570', 'Rua General Lecor', '61', 'Casa 2', 'Independencia', 'São Bernardo Do Campo', 'SP',
    'Auxílio Combustível', NULL, NULL, 'R$ 110,00',
    NULL, '2025-11-06', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2032-07-19', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'PD0 - extinção do ctt de experiência', 'Avaliar'
),
-- 2. Ricardo Das Neves Estudino
(
    'Ricardo Das Neves Estudino', 'Operador de Estacionamento', 'inativo', 'GSM', 'Prevent Sênior - Hospital Madri', '08:30 as 17:30',
    '2025-12-04', '2025-12-04', '2025-12-16', '1980-03-01',
    'Masculino', '32.465.427-3', '291.191.028-10', '136.17890.89-9', '00687185107',
    'Solteiro', NULL, 0, NULL,
    'ricneves2020@gmail.com', '(11) 99003-9559', NULL, NULL,
    '01251-030', 'Rua Ilheus', '207', 'Casa', 'Sumaré', 'São Paulo', 'SP',
    'Vale Transporte', 'Metrô', 2, 'R$ 10,40',
    NULL, '2025-12-16', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2034-02-21', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'RA1 - pedido de demissão do funcionário', 'Avaliar'
),
-- 3. Wellington Sousa Da Silva
(
    'Wellington Sousa Da Silva', 'Operador de Estacionamento', 'inativo', 'GSM', 'Grupo Santa Marcelina Regionais - Hospital Itaim', '14:00 as 22:00',
    '2025-08-12', '2025-08-12', '2025-08-21', '1985-05-26',
    'Masculino', '42.875.270-6', '349.970.538-99', '135.08992.85-2', '04193627750',
    'Divorciado(a)', NULL, 0, NULL,
    NULL, '(11) 97171-9759', '(11) 96447-8701', NULL,
    '08576-640', 'Rua Cananeia', '49', 'Casa', 'Jardim Nossa Senhora D’ajuda', 'Itaquaquecetuba', 'SP',
    'Vale Transporte', 'Onibus', 2, 'R$ 14,00',
    NULL, '2025-08-21', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2033-10-17', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'RA1 - pedido de demissão do funcionário', 'Avaliar'
),
-- 4. Italo Ferreira Porto
(
    'Italo Ferreira Porto', 'Operador de Estacionamento', 'inativo', 'GSM', 'Grupo Santa Marcelina Itaquera - Sede', '14:00 as 22:20',
    '2025-03-18', '2025-03-18', '2025-09-04', '2005-01-17',
    'Masculino', '56.355.446-0', '242.954.678-71', '207.40225.11-6', '08123173305',
    'Solteiro', NULL, 0, NULL,
    NULL, '(11) 98672-7744', '(11) 96820-9710', '(11) 2944-3051',
    '08270-085', 'Rua Santa Marcelina', '709', 'Casa A', 'Vila Carmosina', 'São Paulo', 'SP',
    'Não Optante', NULL, NULL, NULL,
    NULL, '2025-09-04', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2033-01-20', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'SJ2 - demissão sem justa causa', 'Avaliar'
),
-- 5. Sandra Bispo Dos Santos
(
    'Sandra Bispo Dos Santos', 'Operador de Estacionamento', 'inativo', 'GSM', 'Espaço HAOC', '06:30 as 15:30',
    '2025-09-11', '2025-09-11', '2025-09-15', '1978-06-09',
    'Feminino', '30.229.443-0', '246.814.468-66', '128.39292.77-9', '01507417676',
    'Solteiro', NULL, 1, '[{"nome": "Julia Santos Rodrigues", "data_nascimento": "2006-06-22"}]',
    NULL, '(11) 95114-7797', '(11) 95498-7165', '(11) 95298-2301',
    '04429-030', 'Rua Fanfula', '220', 'Casa', 'Americanopolis', 'São Paulo', 'SP',
    'Não Optante', NULL, NULL, NULL,
    NULL, '2025-09-15', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2033-06-27', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'RA1 - pedido de demissão do funcionário', 'Avaliar'
),
-- 6. Patrick Doin
(
    'Patrick Doin', 'Operador de Estacionamento', 'inativo', 'GSM', 'IGESP - Hospital Praia Grande', '06:00 as 14:20',
    '2025-09-17', '2025-09-17', '2025-11-15', '1972-06-04',
    'Masculino', '25.812.068-X', '153.819.148-22', '125.52627.59-7', '02120327014',
    'Divorciado(a)', NULL, 0, NULL,
    NULL, '(13) 98217-2007', '(11) 98174-9425', NULL,
    '11075-003', 'Avenida Senador Pinheiro Machado', '819', 'AP 21', 'Campo Grande', 'Santos', 'SP',
    'Vale Transporte', 'Onibus', 2, 'R$ 11,00',
    NULL, '2025-11-15', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2027-06-16', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'PD0 - extinção do ctt de experiência', 'Avaliar'
),
-- 7. Tarcisio Pedro Ciqueira
(
    'Tarcisio Pedro Ciqueira', 'Operador de Estacionamento', 'inativo', 'GSM', 'Espaço HAOC', '12:00 as 21:00',
    '2024-11-28', '2024-11-28', '2025-07-18', '1988-04-11',
    'Masculino', '42.413.019-1', '380.222.198-27', '166.44649.20-4', '05531893867',
    'Casado(a)', '{"nome": "Evelyn Martins Da Silva", "data_nascimento": "1997-01-11"}', 2, '[{"nome": "Arthur Albuquerque Ciqueira", "data_nascimento": "2016-01-30"}, {"nome": "Alice Martins Ciqueira", "data_nascimento": "2024-04-05"}]',
    NULL, '(11) 93923-2627', '(11) 95810-5553', NULL,
    '05833-280', 'Rua Murilo Alvarenga', '199', 'C/4', 'Jardim Vaz De Lima', 'São Paulo', 'SP',
    'Auxílio Combustível', NULL, NULL, 'R$ 120,00',
    NULL, '2025-07-21', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2031-11-26', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'SJ1 - pedido de demissão do funcionário', 'Avaliar'
),
-- 8. Paulo Vinicius De Oliveira Almeida
(
    'Paulo Vinicius De Oliveira Almeida', 'Operador de Estacionamento', 'inativo', 'GSM', 'Grupo Santa Marcelina Regionais - Hospital Itaim', '14:00 as 22:00',
    '2025-04-30', '2025-04-30', '2025-12-15', '1993-10-17',
    'Masculino', '49.316.194-6', '405.980.608-04', '210.69561.19-5', '06168641813',
    'Solteiro', NULL, 0, NULL,
    NULL, '(11) 96335-9305', NULL, NULL,
    '08121-000', 'Rua Manuel Bueno Da Fonseca', '34', 'Casa', 'Jardim São Luis', 'São Paulo', 'SP',
    'Não Optante', NULL, NULL, NULL,
    NULL, '2025-12-15', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2034-05-18', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'SJ1 - pedido de demissão do funcionário', 'Avaliar'
),
-- 9. Marcos Domingues Tomaz Dos Santos
(
    'Marcos Domingues Tomaz Dos Santos', 'Operador de Estacionamento', 'inativo', 'GSM', 'Grupo Santa Marcelina Itaquera - Sede', '06:00 as 14:00',
    '2024-01-30', '2024-01-30', '2025-11-06', '1988-11-27',
    'Masculino', '42.113.843-9', '388.930.558-05', '136.97203.81-8', '06618883112',
    'Casado(a)', '{"nome": "Evellyn Tomaz Dos Santos", "data_nascimento": "1993-11-24"}', 4, '[{"nome": "Yasmim Vitoria Tomaz Dos Santos", "data_nascimento": "2011-11-09"}, {"nome": "Arthur Marcos Domingues Tomaz Dos Santos", "data_nascimento": "2017-06-30"}, {"nome": "Bianca Nicolly Domingues Tomaz Dos Santos", "data_nascimento": "2018-08-25"}, {"nome": "Sabrina Myrella Domingues Tomaz Dos Santos", "data_nascimento": "2021-01-31"}]',
    'evellyndomingues1993@gmail.com', '(11) 96335-3607', '(11) 2079-3728', NULL,
    '08247-035', 'Rua Quatro De Julho', '20', 'Casa', 'Vila Santa Teresinha', 'São Paulo', 'SP',
    'Vale Transporte', 'Onibus', 2, 'R$ 8,80',
    NULL, '2025-11-06', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2032-07-26', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'SJ2 - demissão sem justa causa', 'Avaliar'
),
-- 10. Moises Oliveira Dos Santos
(
    'Moises Oliveira Dos Santos', 'Operador de Estacionamento', 'inativo', 'GSM', 'IGESP - Hospital Praia Grande', '06:00 as 14:20',
    '2024-08-20', '2024-08-20', '2024-10-30', '2003-08-26',
    'Masculino', '53.533.450-3', '417.301.048-60', '210.12361.98-7', '07929186292',
    'Solteiro', NULL, 0, NULL,
    'oliveirasantos021021@gmail.com', '(13) 99210-5958', '(13) 99103-7463', NULL,
    '11722-395', 'Rua Antonio Alves Nunes', '20', 'Casa', 'Vila Sonia', 'Praia Grande', 'SP',
    'Auxílio Combustível', NULL, NULL, 'R$ 150,00',
    NULL, '2024-10-30', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2031-09-03', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'PD0 - extinção do ctt de experiência', 'Avaliar'
),
-- 11. Marcos Vinicius Garcia Bueno
(
    'Marcos Vinicius Garcia Bueno', 'Operador de Estacionamento', 'inativo', 'GSM', 'Prevent Sênior - Hospital Madri', '06:30 as 15:30',
    '2025-08-27', '2025-08-27', '2025-11-07', '2000-01-13',
    'Masculino', '38.660.048-X', '328.105.548-62', NULL, '07206088850',
    'Solteiro', NULL, 0, NULL,
    NULL, '(11) 96261-3524', NULL, NULL,
    '03525-160', 'Rua Rolarite', '120', 'Casa 2', 'Jardim Maringa', 'São Paulo', 'SP',
    'Vale Transporte', 'Onibus', 2, 'R$ 10,00',
    NULL, '2025-11-07', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2033-03-20', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'SJ1 - pedido de demissão do funcionário', 'Avaliar'
),
-- 12. Ricardo Carlos Santarena
(
    'Ricardo Carlos Santarena', 'Operador de Estacionamento', 'inativo', 'GSM', 'Grupo Santa Marcelina Itaquera - Sede', '14:00 as 22:00',
    '2024-04-10', '2024-04-10', '2024-05-08', '1980-07-12',
    'Masculino', '30.928.435-1', '217.667.378-62', '133.03939.85-2', '01225330368',
    'Divorciado(a)', NULL, 1, '[{"nome": "Gabriella Pereira Santarena", "data_nascimento": "2003-10-08"}]',
    'santarenaricardo2@gmail.com', '(11) 97700-9094', NULL, NULL,
    '08050-220', 'Rua Dos Calamos', '180', 'Casa', 'Vila Jacui', 'São Paulo', 'SP',
    'Vale Transporte', 'Onibus', 2, 'R$ 8,80',
    NULL, '2024-05-08', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2024-10-25', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'SJ1 - pedido de demissão do funcionário', 'Avaliar'
),
-- 13. Lucio Mario Silva Conceição
(
    'Lucio Mario Silva Conceição', 'Operador de Estacionamento', 'inativo', 'GSM', 'Espaço HAOC', '08:30 as 17:30',
    '2025-10-09', '2025-10-09', '2025-11-07', '1972-01-29',
    'Masculino', '23.246.524-1', '176.198.498-58', '123.87099.73-9', '06483763594',
    'Divorciado(a)', NULL, 0, NULL,
    'lucioconceicao@uol.com.br', '(11) 94253-3060', '(11) 5891-8788', NULL,
    '05832-250', 'Rua Cristianopolis', '54', 'Casa', 'Jardim Boa Vista', 'São Paulo', 'SP',
    'Vale Transporte', 'Onibus', 2, 'R$ 10,00',
    NULL, '2025-11-07', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2028-08-14', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'PD0 - extinção do ctt de experiência', 'Avaliar'
);


INSERT INTO funcionarios (
    nome, funcao, status, empresa, local, horario, 
    data_admissao, data_inicio, data_demissao, data_nascimento, 
    genero, rg, cpf, pis, cnh_numero, 
    estado_civil, dados_conjuge, quantidade_filhos, nome_filhos, 
    email_pessoal, telefone_1, telefone_2, telefone_3, 
    cep, rua, numero, complemento, bairro, cidade, estado, 
    opcao_transporte, meio_transporte, qtd_transporte, valor_transporte, 
    data_entrega_uniforme, data_devolucao_uniforme, data_reposicao_uniforme, motivo_reposicao_uniforme, 
    tamanho_camisa, tamanho_calca, tamanho_jaqueta, tamanho_bota, 
    validade_cnh, validade_exame_clinico, validade_audiometria, validade_eletrocardiograma, 
    validade_eletroencefalograma, validade_glicemia, validade_acuidade_visual, 
    validade_treinamento, validade_contrato_experiencia, 
    motivo_demissao, elegivel_recontratacao
) VALUES 
-- 1. Reinaldo Jorge De Oliveira
(
    'Reinaldo Jorge De Oliveira', 'Operador de Estacionamento', 'inativo', 'GSM', 'Grupo Santa Marcelina Itaquera - Instituto', '15:00 as 23:00',
    '2025-01-20', '2025-01-20', '2025-07-31', '1980-06-12',
    'Masculino', '26.464.126-7', '218.384.048-05', '125.45914.38-1', '01037336399',
    'Solteiro', NULL, 2, '[{"nome": "Rebeca Aparecida De Oliveira", "data_nascimento": "2005-12-26"}, {"nome": "Hector De Oliveira", "data_nascimento": "2011-02-15"}]',
    NULL, NULL, NULL, NULL,
    '08535-400', 'Rua Guapore', '197', 'Casa', 'Vila Mariana', 'Ferraz De Vasconcelos', 'SP',
    'Vale Transporte', 'Onibus, Trem', 4, 'R$ 21,42',
    NULL, '2025-07-31', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2031-07-08', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'SJ1 - pedido de demissão do funcionário', 'Avaliar'
),
-- 2. Gabriel Pimentel Martins
(
    'Gabriel Pimentel Martins', 'Operador de Estacionamento', 'inativo', 'GSM', 'Grupo Santa Marcelina Itaquera - Sede', '14:00 as 22:00',
    '2024-02-01', '2024-02-01', '2024-03-12', '1993-09-13',
    'Masculino', '49.325.815-2', '404.864.908-66', '162.19134.64-9', '05479661782',
    'Casado(a)', '{"nome": "Mayone Loreilhe De Sousa", "data_nascimento": null}', 2, '[{"nome": "Lavinia Isabelly Loreilhe Martins", "data_nascimento": "2017-01-18"}, {"nome": "Manuelly Victoria Loreilhe Martins", "data_nascimento": "2013-11-13"}]',
    'gabrielpimentel5000@yahoo.com.br', '(11) 97734-0894', '(11) 95236-3731', NULL,
    '08245-200', 'Rua Trussu', '274', 'Casa', 'Vila Progresso', 'São Paulo', 'SP',
    'Vale Transporte', 'Onibus', 2, 'R$ 8,80',
    NULL, '2024-03-12', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2032-10-18', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'SJ1 - pedido de demissão do funcionário', 'Avaliar'
),
-- 3. Italo Silva Amaral (CPF recuperado do texto)
(
    'Italo Silva Amaral', 'Operador de Estacionamento', 'inativo', 'GSM', 'Grupo Santa Marcelina Itaquera - Sede', '15:00 as 23:00',
    '2024-05-07', '2024-05-07', '2024-07-21', '2003-01-24',
    'Masculino', '39.036.647-X', '240.305.498-45', NULL, '08015029206',
    'Solteiro', NULL, 0, NULL,
    NULL, '(11) 95465-6009', NULL, NULL,
    '03756-030', 'Rua Nova Cruz', '284', 'Casa', 'Jardim Gonzaga', 'São Paulo', 'SP',
    'Vale Transporte', 'Onibus', 2, 'R$ 10,00',
    NULL, '2024-07-21', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2031-10-14', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'SJ2 - demissão sem justa causa', 'Avaliar'
),
-- 4. Gustavo Ferreira Da Silva
(
    'Gustavo Ferreira Da Silva', 'Operador de Estacionamento', 'inativo', 'GSM', 'IGESP - Hospital Praia Grande', '14:00 as 22:00',
    '2024-08-20', '2024-08-20', '2024-12-24', '2000-09-21',
    'Masculino', '50.979.155-4', '491.684.378-97', '154.51090.73-8', '07464375847',
    'Solteiro', NULL, 0, NULL,
    'eigustas@gmail.com', '(13) 99131-2001', '(13) 99622-5240', NULL,
    '11730-000', 'Rua Marcelo Batista', '178', 'Casa', 'Itaoca', 'Mongaguá', 'SP',
    'Vale Transporte', 'Onibus', 2, 'R$ 18,20',
    NULL, '2024-12-24', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2034-07-02', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'SJ1 - pedido de demissão do funcionário', 'Avaliar'
),
-- 5. Gabriel Gomes Feitoza
(
    'Gabriel Gomes Feitoza', 'Operador de Estacionamento', 'inativo', 'GSM', 'Prevent Sênior - Hospital Madri', '14:00 as 22:20',
    '2024-08-13', '2024-08-13', '2024-10-11', '1996-08-28',
    'Masculino', '52.326.571-2', '468.343.758-99', '209.80595.27-9', '06474434615',
    'Solteiro', NULL, 0, NULL,
    'jesusefiel2896@gmail.com', '(11) 97829-1949', '(11) 95956-6502', '(11) 98650-0359',
    '08452-640', 'Travessa Dos Teixas', '5', 'Casa', 'Vila Lourdes', 'São Paulo', 'SP',
    'Vale Transporte', 'Onibus, Metrô', 4, 'R$ 21,42',
    NULL, '2024-10-11', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2025-11-09', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'PD0 - extinção do ctt de experiência', 'Avaliar'
),
-- 6. Carlos Francisco Madeira Junior
(
    'Carlos Francisco Madeira Junior', 'Operador de Estacionamento', 'inativo', 'GSM', 'Grupo Santa Marcelina Itaquera - Sede', '15:00 as 23:20',
    '2024-08-01', '2024-08-01', '2024-08-30', '1972-07-31',
    'Masculino', '21.567.176-4', '183.110.648-57', '126.98776.93-7', '02474994230',
    'Solteiro', NULL, 0, NULL,
    'carframadwrkjc_8ia@indeedemail.com', '(11) 98508-5102', NULL, NULL,
    '08051-560', 'Rua Padre Orlando Nogueira', '274', 'Casa', 'Limoeiro', 'São Paulo', 'SP',
    'Vale Transporte', 'Onibus', 2, 'R$ 8,80',
    NULL, '2024-08-30', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2032-10-20', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'PD0 - extinção do ctt de experiência', 'Avaliar'
),
-- 7. Murcio De Jesus Souza (Data Nasc corrigida de 2024 para 1984)
(
    'Murcio De Jesus Souza', 'Operador de Estacionamento', 'inativo', 'GSM', 'Grupo Santa Marcelina Itaquera - Sede', '14:00 as 22:00',
    '2024-05-07', '2024-05-07', '2024-07-05', '1984-05-08', -- Corrigido ano
    'Masculino', '47.192.984-0', '052.108.415-61', '210.72951.24-1', '06571686032',
    'Solteiro', NULL, 1, '[{"nome": "Maria Clara Souza De Rocha", "data_nascimento": "2013-05-24"}]',
    NULL, '(11) 99194-7911', NULL, NULL,
    '05412-002', 'Rua João Moura', '1076', 'Casa', 'Pinheiros', 'São Paulo', 'SP',
    'Não Optante', NULL, NULL, NULL,
    NULL, '2024-07-05', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2024-07-11', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'PD0 - extinção do ctt de experiência', 'Avaliar'
),
-- 8. Mayara Gabriela De Sousa Silva
(
    'Mayara Gabriela De Sousa Silva', 'Operador (a) de Caixa', 'inativo', 'GSM', 'Grupo Santa Marcelina Itaquera - AME', '07:00 as 15:45',
    '2024-08-07', '2024-08-07', '2024-12-19', '2000-07-12',
    'Feminino', '54.294.591-5', '503.086.608-62', '143.02449.39-6', NULL,
    'Solteiro', NULL, 0, NULL,
    'mabysilvasousa@gmail.com', '(11) 95866-7153', '(11) 98603-5416', '(11) 98378-3062',
    '08475-280', 'Rua São Clodoaldo', '188', 'Casa', 'Cidade Tiradentes', 'São Paulo', 'SP',
    'Vale Transporte', 'Onibus, Metrô', 4, 'R$ 21,42',
    NULL, '2024-12-19', NULL, NULL,
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'SJ2 - demissão sem justa causa', 'Avaliar'
),
-- 9. Andre Lucas Braga Dos Santos
(
    'Andre Lucas Braga Dos Santos', 'Operador de Estacionamento', 'inativo', 'GSM', 'Prevent Sênior - Hospital Madri', '06:00 as 14:20',
    '2024-08-15', '2024-08-15', '2024-10-13', '1995-12-27',
    'Masculino', '38.194.657-5', '059.502.303-70', '212.51317.79-2', '08105553827',
    'Solteiro', NULL, 1, '[{"nome": "Gael Alves Dos Santos", "data_nascimento": "2024-08-07"}]',
    NULL, '(11) 96337-3139', NULL, NULL,
    '08465-000', 'Avenida Utaro Kanai', '8754', '1B', 'Conjunto Habitacional Juscelino Kubitschek', 'São Paulo', 'SP',
    'Não Optante', NULL, NULL, NULL,
    NULL, '2024-10-13', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2034-04-13', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'PD0 - extinção do ctt de experiência', 'Avaliar'
),
-- 10. Alake Yle Maryus Oliveira Marcelino
(
    'Alake Yle Maryus Oliveira Marcelino', 'Operador de Estacionamento', 'inativo', 'GSM', 'Prevent Sênior - Hospital Madri', '14:00 as 22:20',
    '2024-08-28', '2024-08-28', '2024-09-26', '1991-09-12',
    'Masculino', '36.078.509-8', '403.612.048-41', '132.10471.53-2', '05595150960',
    'Solteiro', NULL, 0, NULL,
    'alake.oliveira@outlook.com', '(11) 93096-0015', '(11) 96796-9366', NULL,
    '02347-010', 'Rua Herbert Hoover', '80', 'Casa', 'Jardim Leonor Mendes De Barros', 'São Paulo', 'SP',
    'Vale Transporte', 'Onibus, Metrô', 4, 'R$ 21,42',
    NULL, '2024-09-26', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2032-05-12', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'PD0 - extinção do ctt de experiência', 'Avaliar'
),
-- 11. Alexandre Junior Dos Santos Rocha
(
    'Alexandre Junior Dos Santos Rocha', 'Operador de Estacionamento', 'inativo', 'GSM', 'IGESP - Hospital Praia Grande', '14:00 as 22:00',
    '2024-06-07', '2024-06-07', '2024-09-20', '2004-03-29',
    'Masculino', '54.652.158-7', '445.999.078-47', '270.49696.71-0', '08287272304',
    'Solteiro', NULL, 0, NULL,
    'alexandrejdsrochasz@gmail.com', '(13) 99640-1816', NULL, NULL,
    '11704-500', 'Avenida Presidente Castelo Branco', '12468', 'AP 74', 'Vila Caiçara', 'Praia Grande', 'SP',
    'Vale Transporte', 'Onibus', 2, 'R$ 10,00',
    NULL, '2024-09-20', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2024-09-02', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'SJ1 - pedido de demissão do funcionário', 'Avaliar'
),
-- 12. Breno Angelus Nieba
(
    'Breno Angelus Nieba', 'Operador de Estacionamento', 'inativo', 'GSM', 'IGESP - Hospital Praia Grande', '11:00 as 19:00',
    '2024-04-26', '2024-04-26', '2024-05-29', '2002-11-25',
    'Masculino', '50.125.055-4', '482.128.778-17', '207.23698.35-4', '2518735827',
    'Solteiro', NULL, 0, NULL,
    NULL, '(13) 99122-7754', NULL, NULL,
    '11705-510', 'Rua Cesar Rodrigues Reis', '1049', 'Casa', 'Maracanã', 'Praia Grande', 'SP',
    'Não Optante', NULL, NULL, NULL,
    NULL, '2024-05-29', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2025-12-05', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'RA1 - pedido de demissão do funcionário', 'Avaliar'
),
-- 13. Michael Gonçalves Jacinto
(
    'Michael Gonçalves Jacinto', 'Operador de Estacionamento', 'inativo', 'GSM', 'Grupo Santa Marcelina Itaquera - Sede', '14:00 as 22:00',
    '2024-04-23', '2024-04-23', '2025-02-22', '1994-11-28',
    'Masculino', '43.597.116-4', '428.577.788-62', '093.86179.79-0', '07815025050',
    'Solteiro', NULL, 0, NULL,
    'pandagostanada6@gmail.com', '(11) 97741-4821', NULL, NULL,
    '03721-080', 'Rua Luciano Nogueira', '273', 'Casa 3', 'Jardim Janiopolis', 'São Paulo', 'SP',
    'Não Optante', NULL, NULL, NULL,
    NULL, '2025-02-22', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2026-04-09', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'SJ2 - demissão sem justa causa', 'Avaliar'
);






























-- Protector
INSERT INTO funcionarios (
    nome, funcao, status, empresa, local, horario, 
    data_admissao, data_inicio, data_demissao, data_nascimento, 
    genero, rg, cpf, pis, cnh_numero, 
    estado_civil, dados_conjuge, quantidade_filhos, nome_filhos, 
    email_pessoal, telefone_1, telefone_2, telefone_3, 
    cep, rua, numero, complemento, bairro, cidade, estado, 
    opcao_transporte, meio_transporte, qtd_transporte, valor_transporte, 
    data_entrega_uniforme, data_devolucao_uniforme, data_reposicao_uniforme, motivo_reposicao_uniforme, 
    tamanho_camisa, tamanho_calca, tamanho_jaqueta, tamanho_bota, 
    validade_cnh, validade_exame_clinico, validade_audiometria, validade_eletrocardiograma, 
    validade_eletroencefalograma, validade_glicemia, validade_acuidade_visual, 
    validade_treinamento, validade_contrato_experiencia, 
    motivo_demissao, elegivel_recontratacao
) VALUES 
-- 1. Paulo Rogerio Ananias
(
    'Paulo Rogerio Ananias', 'Operador de Estacionamento', 'inativo', 'Protector', 'São Carlos - Santa Casa', '06:30 as 18:30',
    '2024-07-01', '2024-07-01', '2025-03-10', '1990-04-14',
    'Masculino', '47.678.180-2', '373.378.418-93', '206.30689.21-5', '06705942750',
    'Casado(a)', '{"nome": "Michele Rosa Ananias", "data_nascimento": "1989-01-02"}', 1, '[{"nome": "Celina Rosa Ananias", "data_nascimento": "2023-01-14"}]',
    'paulobci018@gmail.com', '(16) 99347-5596', '(16) 99778-9315', NULL,
    '14815-000', 'Rua Descalvado', '10', 'Casa B', 'Jardim Cruzado', 'Ibaté', 'SP',
    'Não Optante', NULL, NULL, NULL,
    NULL, '2025-03-10', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2026-01-29', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'SJ1 - pedido de demissão do funcionário', 'Avaliar'
),
-- 2. Bruno Klabacher
(
    'Bruno Klabacher', 'Operador de Estacionamento', 'inativo', 'Protector', 'São Carlos - Santa Casa', '07:30 as 16:30',
    '2024-06-24', '2024-06-24', '2024-08-28', '1985-11-18',
    'Masculino', '30.197.309-X', '328.245.598-45', '131.93078.89-0', '03308459138',
    'Solteiro', NULL, 2, '[{"nome": "Henry Vilella Klabacher", "data_nascimento": "2014-01-04"}, {"nome": "Helena Vilella Klabacher", "data_nascimento": "2021-04-22"}]',
    'brunoklabacher02@gmail.com', '(11) 98770-8298', NULL, NULL,
    '04315-000', 'Rua Doutor Jose Bento Ferreira', '223', 'Casa', 'Vila Agua Funda', 'São Paulo', 'SP',
    'Vale Transporte', 'Onibus', 2, 'R$ 8,80',
    NULL, '2024-08-28', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2032-07-27', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'SJ1 - pedido de demissão do funcionário', 'Avaliar'
),
-- 3. Diego Carlos Da Silva
(
    'Diego Carlos Da Silva', 'Operador de Estacionamento', 'inativo', 'Protector', 'São Carlos - Santa Casa', '10:00 as 19:00',
    '2024-07-01', '2024-07-01', '2024-07-30', '1994-09-19',
    'Masculino', '39.842.174-2', '424.965.618-73', '160.90813.06-1', '06013744404',
    'Solteiro', NULL, 0, NULL,
    'diegocaarlos77@gmail.com', '(11) 95879-4922', NULL, NULL,
    '04917-140', 'Rua João Chammas', '244', 'Casa 2', 'Jardim Souza', 'São Paulo', 'SP',
    'Vale Transporte', 'Onibus', 2, 'R$ 9,66',
    NULL, '2024-07-30', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2024-09-20', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'PD0 - extinção do ctt de experiência', 'Avaliar'
),
-- 4. Jhonatas Henrique Cardoso
(
    'Jhonatas Henrique Cardoso', 'Operador de Estacionamento', 'inativo', 'Protector', 'São Carlos - Santa Casa', '07:30 as 17:30',
    '2025-09-03', '2025-09-03', '2025-10-02', '1990-12-05',
    'Masculino', '47.103.726-6', '365.035.208-75', '204.13355.65-3', '06892635466',
    'Divorciado(a)', NULL, 0, NULL,
    NULL, '(11) 95740-6616', NULL, NULL,
    '13562-430', 'Rua Ethiwaldo Alexandre Martins', '3222', 'Casa', 'Jardim Santa Felicia', 'São Carlos', 'SP',
    'Vale Transporte', 'Trem, Metrô', 4, 'R$ 10,40',
    NULL, '2025-10-02', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2031-04-16', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'RA1 - pedido de demissão do funcionário', 'Avaliar'
),
-- 5. Vagner Santos Rigaud
(
    'Vagner Santos Rigaud', 'Operador de Estacionamento', 'inativo', 'Protector', 'São Carlos - Santa Casa', '14:00 as 22:20',
    '2024-06-24', '2024-06-24', '2024-08-20', '1981-09-11',
    'Masculino', '55.631.631-9', '816.394.655-53', '207.45099.01-1', '04076095200',
    'Solteiro', NULL, 0, NULL,
    NULL, '(11) 96760-7419', '(11) 96949-1341', NULL,
    '04474-410', 'Avenida Coronel Astolfo Araujo Filho', '18', 'Casa 3', 'Praia Do Leblon', 'São Paulo', 'SP',
    'Não Optante', NULL, NULL, NULL,
    NULL, '2024-08-20', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2029-04-23', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'PD0 - extinção do ctt de experiência', 'Avaliar'
),
-- 6. Luis Henrique De Oliveira
(
    'Luis Henrique De Oliveira', 'Operador de Estacionamento', 'inativo', 'Protector', 'São Carlos - Santa Casa', '12:00 as 21:00',
    '2024-07-11', '2024-07-11', '2024-08-27', '1981-06-30',
    'Masculino', '45.428.586-3', '224.704.458-17', '129.15538.50-8', '07137076832',
    'Solteiro', NULL, 0, NULL,
    NULL, '(11) 99300-1750', NULL, NULL,
    '04421-070', 'Rua Pascoal Valva', '389', 'Casa 5', 'Jardim Luso', 'São Paulo', 'SP',
    'Vale Transporte', 'Onibus', 2, 'R$ 9,66',
    NULL, '2024-08-27', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2034-03-04', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'RA1 - pedido de demissão do funcionário', 'Avaliar'
),
-- 7. Marcos Roberto Martins De Souza
(
    'Marcos Roberto Martins De Souza', 'Operador de Estacionamento', 'inativo', 'Protector', 'São Carlos - Santa Casa', '06:30 as 18:30',
    '2024-03-25', '2024-03-25', '2024-08-26', '2000-10-23',
    'Masculino', '45.352.192-7', '501.512.138-52', '206.59117.54-6', '07309500324',
    'Solteiro', NULL, 1, '[{"nome": "Eliza Ibelli De Souza", "data_nascimento": "2020-02-15"}]',
    'nicolyibelli14@gmail.com', '(16) 99360-6889', NULL, NULL,
    '14818-100', 'Rua Sao Carlos', '785', 'Casa', 'Jardim Cruzado', 'Ibate', 'SP',
    'Auxílio Combustível', NULL, NULL, 'R$ 100,00',
    NULL, '2024-08-26', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2024-03-01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'SJ1 - pedido de demissão do funcionário', 'Avaliar'
),
-- 8. Osvaldo Augusto Da Silva
(
    'Osvaldo Augusto Da Silva', 'Operador de Estacionamento', 'inativo', 'Protector', 'São Carlos - Santa Casa', '06:30 as 18:30',
    '2024-11-12', '2024-11-12', '2025-01-10', '1964-10-07',
    'Masculino', '16.672.149-9', '815.604.580-71', '084.01617.40-0', '02569129280',
    'Solteiro', NULL, 0, NULL,
    'osvaldoaugusto1964@gmail.com', '(16) 99722-1511', NULL, NULL,
    '13560-298', 'Rua Rafael De Abreu Sampaio Vidal', '412', 'FD A', 'Vila Monteiro', 'São Carlos', 'SP',
    'Não Optante', NULL, NULL, NULL,
    NULL, '2025-01-10', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2028-03-20', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'PD0 - extinção do ctt de experiência', 'Avaliar'
),
-- 9. Jonatas Da Silva Santos
(
    'Jonatas Da Silva Santos', 'Operador de Estacionamento', 'inativo', 'Protector', 'São Carlos - Santa Casa', '06:30 as 18:30',
    '2024-09-13', '2024-09-13', '2024-11-11', '1995-05-27',
    'Masculino', '45.944.483-9', '432.231.088-58', '163.02716.36-6', '07414479440',
    'Solteiro', NULL, 2, '[{"nome": "Jonas Miguel Almeida Da Silva", "data_nascimento": "2021-05-18"}, {"nome": "Maria Eloa Almeida Da Silva", "data_nascimento": "2022-05-23"}]',
    NULL, '(16) 99639-8521', NULL, NULL,
    '14818-260', 'Rua Eneas Dias Torres', '123', 'Casa', 'Jardim Primavera', 'Ibaté', 'SP',
    'Vale Transporte', 'Onibus', 2, 'R$ 13,80',
    NULL, '2024-11-11', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2033-09-22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'PD0 - extinção do ctt de experiência', 'Avaliar'
),
-- 10. Geovanna Hellen Fernandes
(
    'Geovanna Hellen Fernandes', 'Operador de Estacionamento', 'inativo', 'Protector', 'São Carlos - Santa Casa', '06:30 as 18:30',
    '2025-03-07', '2025-03-07', '2025-03-25', '2004-01-24',
    'Feminino', '56.172.759-4', '451.550.068-64', '236.94349.50-9', '07920015234',
    'Solteiro', NULL, 0, NULL,
    NULL, '(16) 98185-4379', '(19) 98296-3259', NULL,
    '13566-490', 'Rua Bernandino Fernandes Nunes', '130', 'AP 17', 'Cidade Jardim', 'São Carlos', 'SP',
    'Auxílio Combustível', NULL, NULL, 'R$ 100,00',
    NULL, '2025-03-25', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2031-06-30', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'RA1 - pedido de demissão do funcionário', 'Avaliar'
),
-- 11. Leiriane Denis Rodrigues Correa (Cidade Corrigida para São Carlos)
(
    'Leiriane Denis Rodrigues Correa', 'Operador de Estacionamento', 'inativo', 'Protector', 'São Carlos - Santa Casa', '07:00 as 17:00',
    '2025-02-17', '2025-02-17', '2025-08-29', '1986-03-15',
    'Feminino', '44.097.993-6', '328.593.698-30', '127.87375.15-6', '04479281270',
    'Casado(a)', '{"nome": "Cesar Henrique Basilio Correa", "data_nascimento": "1981-07-29"}', 2, '[{"nome": "Victor Hugo Rodrigues Correa", "data_nascimento": "2012-11-08"}, {"nome": "Vinicuis Eduardo Rodrigues Correa", "data_nascimento": "2003-10-21"}]',
    'leirianerodrigues_2010@hotmail.com', '(16) 99345-6671', NULL, NULL,
    '13572-541', 'Rua Mauricio Valente Osorio', '291', 'Casa', 'Vila Conceicao', 'São Carlos', 'SP',
    'Auxílio Combustível', NULL, NULL, 'R$ 100,00',
    NULL, '2025-08-29', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2034-05-15', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'SJ1 - pedido de demissão do funcionário', 'Avaliar'
),
-- 12. Vicente Enzo Panerari Tomo
(
    'Vicente Enzo Panerari Tomo', 'Operador de Estacionamento', 'inativo', 'Protector', 'São Carlos - Santa Casa', '06:30 as 18:30',
    '2025-02-17', '2025-02-17', '2025-03-18', '1998-04-23',
    'Masculino', '39.012.129-0', '365.781.538-45', '147.11749.19-1', '06976019728',
    'Solteiro', NULL, 1, '[{"nome": "Heloisa Vitória Mascia Tomo", "data_nascimento": "2025-01-17"}]',
    NULL, '(16) 99337-7227', '(16) 99184-7761', '(16) 99458-1414',
    '13572-370', 'Rua Ceará', '570', 'Casa', 'Jardim Pacaembu', 'São Carlos', 'SP',
    'Auxílio Combustível', NULL, NULL, 'R$ 100,00',
    NULL, '2025-03-18', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2033-07-24', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'PD0 - extinção do ctt de experiência', 'Avaliar'
),
-- 13. Fernanda Fernandes Mascia Mio
(
    'Fernanda Fernandes Mascia Mio', 'Operador de Estacionamento', 'inativo', 'Protector', 'São Carlos - Santa Casa', '07:30 as 17:30',
    '2024-10-14', '2024-10-14', '2025-06-04', '1994-09-12',
    'Feminino', '42.356.077-4', '258.025.887-62', '207.87420.21-7', '06265619587',
    'Solteiro', NULL, 0, NULL,
    'fervictorwes@gmail.com', '(16) 99351-1022', NULL, NULL,
    '13562-530', 'Avenida João Stella', '480', 'Ap 103, Bloco 1', 'Residencial Romeu Tortorelli', 'São Carlos', 'SP',
    'Não Optante', NULL, NULL, NULL,
    NULL, '2025-06-04', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2034-04-30', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'SJ1 - pedido de demissão do funcionário', 'Avaliar'
),
-- 14. Fabricio Ponciano
(
    'Fabricio Ponciano', 'Operador de Estacionamento', 'inativo', 'Protector', 'São Carlos - Santa Casa', '06:30 as 18:30',
    '2024-03-04', '2024-03-04', '2025-06-06', '1989-06-22',
    'Masculino', '44.492.888-7', '371.367.588-07', '209.54053.40-5', '04727301875',
    'Solteiro', NULL, 0, NULL,
    NULL, '(16) 99458-1414', NULL, NULL,
    '13571-639', 'Rua Ana Aparecida Prado Cantador', '215', 'Casa', 'Jardim Tijuca', 'São Carlos', 'SP',
    'Auxílio Combustível', NULL, NULL, 'R$ 100,00',
    NULL, '2025-06-06', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2033-08-31', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'SJ2 - demissão sem justa causa', 'Avaliar'
),
-- 15. Jhonatan Rodrigo Sartoni
(
    'Jhonatan Rodrigo Sartoni', 'Operador de Estacionamento', 'inativo', 'Protector', 'São Carlos - Santa Casa', '18:30 as 06:30',
    '2025-03-10', '2025-03-10', '2025-05-30', '2000-04-20',
    'Masculino', '59.533.027-7', '534.262.968-37', '207.77883.03-6', '07220061690',
    'Solteiro', NULL, 1, '[{"nome": "Jade Alves Sartoni", "data_nascimento": "2025-03-11"}]',
    NULL, '(16) 98104-7723', '(16) 98803-5026', NULL,
    '13563-303', 'Rua Domingos Diegues', '600', 'Casa', 'Parque Santa Felicia', 'São Carlos', 'SP',
    'Não Optante', NULL, NULL, NULL,
    NULL, '2025-05-30', NULL, NULL,
    NULL, NULL, NULL, NULL,
    '2025-12-08', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'SJ1 - pedido de demissão do funcionário', 'Avaliar'
);


-- GS1

INSERT INTO funcionarios (
    nome, funcao, status, empresa, local, horario, 
    data_admissao, data_inicio, data_demissao, data_nascimento, 
    genero, rg, cpf, pis, cnh_numero, 
    estado_civil, dados_conjuge, quantidade_filhos, nome_filhos, 
    email_pessoal, telefone_1, telefone_2, telefone_3, 
    cep, rua, numero, complemento, bairro, cidade, estado, 
    opcao_transporte, meio_transporte, qtd_transporte, valor_transporte, 
    data_entrega_uniforme, data_devolucao_uniforme, data_reposicao_uniforme, motivo_reposicao_uniforme, 
    tamanho_camisa, tamanho_calca, tamanho_jaqueta, tamanho_bota, 
    validade_cnh, validade_exame_clinico, validade_audiometria, validade_eletrocardiograma, 
    validade_eletroencefalograma, validade_glicemia, validade_acuidade_visual, 
    validade_treinamento, validade_contrato_experiencia, 
    motivo_demissao, elegivel_recontratacao
) VALUES 
-- 1. Wellington Francisco Gomes
(
    'Wellington Francisco Gomes', 'Lavador de Veiculos', 'inativo', 'GS1', 'GS1', '08:00 as 17:00',
    '2024-02-01', '2024-02-01', '2024-03-13', '1978-06-19',
    'Masculino', '30.050.820-7', '307.581.618-32', '125.52706.94-2', NULL,
    'Solteiro', NULL, 0, NULL,
    NULL, NULL, NULL, NULL,
    '02879-080', 'Rua Emilio Castro', '375', 'Casa', 'Jardim Damasceno', 'São Paulo', 'SP',
    'Não Optante', NULL, NULL, NULL,
    NULL, '2024-03-13', NULL, NULL,
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'RA2 - pedido de demissão do funcionário', 'Avaliar'
),
-- 2. Lucas Oliveira Dos Santos
(
    'Lucas Oliveira Dos Santos', 'Lavador de Veiculos', 'inativo', 'GS1', 'GS1', '09:00 as 18:00',
    '2025-02-20', '2025-02-20', '2025-11-14', '1997-08-11',
    'Masculino', '50.577.447-1', '464.134.948-75', '228.15099.06-2', NULL,
    'Solteiro', NULL, 0, NULL,
    'Lucas.santos0625@gmail.com', '(11) 95256-8716', NULL, NULL,
    '04370-003', 'Av Joao Barreto De Menezes', '1065', 'Casa 06', 'Vila Santa Catarina', 'São Paulo', 'SP',
    'Vale Transporte', 'Ônibus', 2, 'R$ 10,71',
    NULL, '2025-11-14', NULL, NULL,
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'JC2 - Demissão com justa causa', 'Não'
),
-- 3. Jonatas Macena Venancio
(
    'Jonatas Macena Venancio', 'Auxiliar Administrativo', 'inativo', 'GS1', 'Administrativo', '08:00 as 18:00',
    '2024-08-01', '2024-08-01', '2025-03-20', '2006-03-29',
    'Masculino', '52.024.770-00', '385.880.038-48', '220.23043.00-9', NULL,
    'Solteiro', NULL, 0, NULL,
    'Jonatasmacena373@gmail.com', '(11) 94063-7614', NULL, NULL,
    '02857-090', 'Rua O (Conj Hab Nova Uniao)', '78', 'Casa 2', 'Jardim Brasilia', 'São Paulo', 'SP',
    'Não Optante', NULL, NULL, NULL,
    NULL, '2025-03-20', NULL, NULL,
    NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    'RA2 - pedido de demissão do funcionário', 'Avaliar'
);
































-- Tranquility




INSERT INTO `funcionarios` (
    `nome`, `funcao`, `status`, `empresa`, `local`, `horario`, 
    `data_admissao`, `data_inicio`, `data_demissao`, `data_nascimento`, 
    `genero`, `rg`, `cpf`, `pis`, `cnh_numero`, 
    `estado_civil`, `dados_conjuge`, `quantidade_filhos`, `nome_filhos`, 
    `email_pessoal`, `telefone_1`, `telefone_2`, `telefone_3`, 
    `cep`, `rua`, `numero`, `complemento`, `bairro`, `cidade`, `estado`, 
    `opcao_transporte`, `meio_transporte`, `qtd_transporte`, `valor_transporte`, 
    `motivo_reposicao_uniforme`, `data_entrega_uniforme`, `data_devolucao_uniforme`, 
    `validade_cnh`, `validade_contrato_experiencia`, 
    `motivo_demissao`, `elegivel_recontratacao`
) VALUES 

-- 1. RAFAEL HENRIQUE MUNIZ GUEDES
('Rafael Henrique Muniz Guedes', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'Administrativo', '06:00 às 14:20', '2024-09-14', '2024-09-14', '2024-10-13', '1997-06-12', 'Masculino', '36.643.275-4', '461.790.886-22', '206.42355.78-1', '06613433765', 'Solteiro(a)', NULL, 1, '[{"nome": "Kevin Henrique Moreira Guedes", "data_nascimento": "2021-06-12"}]', NULL, '(11) 94916-9779', NULL, NULL, '05221-000', 'Rua Avenida Pavão', '157', 'Casa', 'Recanto Dos Humildes Perus', 'São Paulo', 'SP', 'Vale Transporte', 'Ônibus, Trem', 4, 'R$ 19,68', NULL, NULL, '2024-10-13', '2032-02-25', NULL, 'PD0 - Demissão sem justa causa', 'Avaliar'),

-- 2. LEONARDO DE PAULA PEREIRA
('Leonardo De Paula Pereira', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'IGESP - Hospital Praia Grande', '06:00 às 14:00', '2024-10-21', '2024-10-21', '2024-11-22', '1999-12-08', 'Masculino', '55.766.272-2', '483.594.118-75', '268.00000.00-0', '07218004911', 'Solteiro(a)', NULL, 0, NULL, 'leo.97208001@gmail.com', '(13) 97419-2191', NULL, NULL, '11713-070', 'Av. Pedro Américo', '1406', 'Casa', 'Samambaia', 'Praia Grande', 'SP', 'Auxílio Combustível', NULL, NULL, 'R$ 150,00', NULL, NULL, '2024-11-22', '2034-07-10', NULL, 'JC2 - Demissão com justa causa', 'Não'),

-- 3. ALEXANDRE MARTINS DOS SANTOS
('Alexandre Martins Dos Santos', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '14:00 às 22:20', '2025-01-20', '2025-01-20', '2025-02-18', '1982-07-24', 'Masculino', '32.196.543-7', '307.427.798-07', '129.91689.93-7', '01984416821', 'Solteiro(a)', NULL, 0, NULL, 'alemartins778@gmail.com', '(11) 93438-2101', '(11) 95700-0000', NULL, '04813-140', 'Rua Vitorino Nemésio', '60', 'Casa 1', 'Jardim São Judas Tadeu', 'São Paulo', 'SP', 'Vale Transporte', 'Ônibus, Trem', 2, 'R$ 21,42', NULL, NULL, '2025-02-18', '2032-06-09', NULL, 'PD0 - extinção do ctt de experiência', 'Avaliar'),

-- 4. MARCOS DAVI DE OLIVEIRA FRASSETO
('Marcos Davi De Oliveira Frasseto', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '06:00 às 14:20', '2025-01-13', '2025-01-13', '2025-03-13', '1973-08-26', 'Masculino', '22.761.341-7', '262.255.408-73', '124.98719.43-4', '01006249000', 'Solteiro(a)', NULL, 0, NULL, 'marcosdofrasseto@gmail.com', '(11) 98548-2519', '(11) 3115-1745', NULL, '01316-000', 'Rua Francisca Miquelina', '355', 'Ap 101', 'Bela Vista', 'São Paulo', 'SP', 'Vale Transporte', 'Ônibus', 2, 'R$ 10,00', NULL, NULL, '2025-03-13', '2031-08-06', NULL, 'PD0 - extinção do ctt de experiência', 'Avaliar'),

-- 5. LEONARDO REIS RODRIGUES
('Leonardo Reis Rodrigues', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'IGESP - Hospital Praia Grande', '14:00 às 22:20', '2024-11-28', '2024-11-28', '2025-01-28', '2001-12-11', 'Masculino', '52.199.825-6', '506.263.978-63', '238.34433.21-3', '08151248438', 'Solteiro(a)', NULL, 0, NULL, NULL, '(13) 98881-0169', NULL, NULL, '11705-630', 'Rua José Demar Peres', '724', 'Casa', 'Maracanã', 'Praia Grande', 'SP', 'Auxílio Combustível', NULL, NULL, 'R$ 150,00', NULL, NULL, '2025-01-28', '2025-10-27', NULL, 'PD0 - extinção do ctt de experiência', 'Avaliar'),

-- 6. JONATAS GONÇALVES MENDONÇA
('Jonatas Gonçalves Mendonça', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '10:00 às 18:20', '2024-11-06', '2024-11-06', '2024-11-11', '1992-09-24', 'Masculino', '48.186.418-0', '427.233.568-50', '210.71378.23-8', '05804361719', 'Solteiro(a)', NULL, 0, NULL, 'jhonatacauter@gmail.com', '(11) 91148-0809', '(11) 98232-7172', NULL, '04410-000', 'Rua Virgílio Gonçalves Leite', '1049', 'Casa 2', 'Americanópolis', 'São Paulo', 'SP', 'Não Optante', NULL, NULL, NULL, NULL, NULL, '2024-11-11', '2032-10-26', NULL, 'RA1 - pedido de demissão do funcionário', 'Avaliar'),

-- 7. CARLOS VIEIRA DA CUNHA
('Carlos Vieira Da Cunha', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '14:00 às 22:00', '2025-05-02', '2025-05-02', '2025-05-31', '1975-04-18', 'Masculino', '25.266.180-1', '254.169.928-08', '124.00000.00-0', '0003132612022', 'Solteiro(a)', NULL, 0, NULL, 'carlosvcunha75@gmail.com', '(11) 98587-1026', '(11) 2456-8100', NULL, '04017-080', 'Rua Professor Sud Mennucci', '314', 'Casa 18', 'Vila Mariana', 'São Paulo', 'SP', 'Vale Transporte', 'Metrô', 2, 'R$ 10,40', NULL, NULL, '2025-06-04', '2031-08-19', NULL, 'PD0 - extinção do contrato de experiência', 'Avaliar'),

-- 8. CARLOS EDUARDO VEIGA RODRIGUES
('Carlos Eduardo Veiga Rodrigues', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '14:00 às 22:20', '2025-02-03', '2025-02-03', '2025-03-14', '1978-11-07', 'Masculino', '25.871.558-3', '263.702.058-00', '125.19846.61-7', '00838676060', 'Divorciado(a)', NULL, 1, '[{"nome": "Luara Alves Barbosa", "data_nascimento": "2011-01-01"}]', 'carloseduluara@gmail.com', '(11) 91025-6787', '(11) 95022-1313', NULL, '02043-005', 'Travessa Franciso Maria Moraes Parra', '44', 'Casa', 'Jardim São Paulo', 'São Paulo', 'SP', 'Vale Transporte', 'Metrô', 2, 'R$ 10,40', NULL, NULL, '2025-03-14', '2033-07-21', NULL, 'RA1 - pedido de demissão do funcionário', 'Avaliar'),

-- 9. JEFERSON TADEU BERNARDO ROSA
('Jeferson Tadeu Bernardo Rosa', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'IGESP - Hospital Praia Grande', '11:00 às 19:00', '2024-10-18', '2024-10-18', '2025-02-28', '1976-10-27', 'Masculino', '24.493.723-0', '249.120.338-39', '125.01176.00-8', '00001021421821', 'Solteiro(a)', NULL, 1, '[{"nome": "Sarah Goncalves Rosa", "data_nascimento": "2021-07-26"}]', 'jefersontadeu76@gmail.com', '(13) 98215-8389', '(13) 98192-7247', NULL, '11706-150', 'Rua Santo Agostinho', '81', 'Casa', 'Caiçara', 'Praia Grande', 'SP', 'Vale Transporte', 'Ônibus', 2, 'R$ 9,60', NULL, NULL, '2025-02-28', '2029-10-01', NULL, 'SJ2 - Demissão sem justa causa', 'Avaliar'),

-- 10. MARCELLO MARTINS QUEIROZ
('Marcello Martins Queiroz', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '14:00 às 22:20', '2025-06-26', '2025-06-26', '2025-08-12', '1983-10-05', 'Masculino', '53.382.360-2', '055.910.636-08', '137.15565.93-3', '05125635395', 'Solteiro(a)', NULL, 0, NULL, NULL, '(11) 93219-8097', NULL, NULL, '05282-040', 'Rua Clara Nunes', '208', 'Casa 3', 'Residencial Sol Nascente', 'São Paulo', 'SP', 'Vale Transporte', 'Ônibus, Metrô', 4, 'R$ 21,42', NULL, NULL, '2025-08-12', '2025-12-15', NULL, 'RA1 - pedido de demissão do funcionário', 'Avaliar'),

-- 11. MARCUS PAULO FERNANDES
('Marcus Paulo Fernandes', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '14:00 às 22:20', '2025-01-17', '2025-01-17', '2025-08-28', '2000-12-06', 'Masculino', '55.445.303-4', '514.622.348-36', '207.80899.54-1', '07951634522', 'Solteiro(a)', NULL, 0, NULL, NULL, '(11) 98520-0372', '(11) 2456-8100', NULL, '08420-240', 'Rua Sebastião De Barros', '409', 'Casa', 'Jardim Helena', 'São Paulo', 'SP', 'Vale Transporte', 'Trem', 2, 'R$ 11,70', NULL, NULL, '2025-08-28', '2026-03-09', NULL, 'SJ1 - pedido de demissão do funcionário', 'Avaliar'),

-- 12. FABIO COSTA PEREIRA
('Fabio Costa Pereira', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '14:00 às 22:20', '2024-11-21', '2024-11-21', '2025-12-23', '1985-03-22', 'Masculino', '29.380.258-0', '362.246.558-12', '133.51894.89-8', '04344504370', 'Solteiro(a)', NULL, 0, NULL, NULL, '(11) 91129-2125', NULL, NULL, '08081-000', 'Rua São Gonçalo Do Rio Das Pedras', '60', 'Casa 2', 'Jardim Helena', 'São Paulo', 'SP', 'Vale Transporte', 'Ônibus, Metrô', 4, 'R$ 21,42', NULL, NULL, '2025-12-30', '2033-08-04', NULL, 'JC2 - Demissão com justa causa', 'Não'),

-- 13. EDMAR FERREIRA GOMES
('Edmar Ferreira Gomes', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'IGESP - Hospital Praia Grande', '06:00 às 14:20', '2024-12-02', '2024-12-02', '2025-07-08', '1956-05-20', 'Masculino', '69.094.452-4', '587.555.007-49', '107.45931.89-5', '00171362002', 'Casado(a)', '{"nome": "Eliana Furtado Goncalves Gomes", "data_nascimento": "1960-01-15"}', 0, NULL, NULL, '(13) 99164-9038', NULL, NULL, '11703-360', 'Rua Botocudo', '155', 'APTO 24', 'Tupi', 'Praia Grande', 'SP', 'Auxílio Combustível', NULL, NULL, 'R$ 150,00', NULL, NULL, '2025-07-08', '2024-04-05', NULL, 'SJ1 - pedido de demissão do funcionário', 'Avaliar'),

-- 14. ALEXANDRE SOUZA SALES
('Alexandre Souza Sales', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '14:00 às 22:20', '2025-05-14', '2025-05-14', '2025-06-12', '1994-10-23', 'Masculino', '53.632.653-8', '419.049.118-70', '138.75189.81-6', '06166239245', 'Divorciado(a)', NULL, 2, '[{"nome": "Isaac Alexandre dos Santos Sales", "data_nascimento": "2015-03-22"}, {"nome": "Ana Livia Borges Sales", "data_nascimento": "2019-07-16"}]', NULL, '(11) 91890-3629', '(11) 94282-2590', '(11) 5971-0103', '04829-490', 'Rua Macarena', '14', 'Casa A', 'Jardim Da Imbuias', 'São Paulo', 'SP', 'Vale Transporte', 'Onibus, Metrô', 4, 'R$ 21,42', NULL, NULL, '2025-06-12', '2031-05-14', NULL, 'PD0 - extinção do ctt de experiência', 'Avaliar'),

-- 15. RAFAELA LEME DE OLIVEIRA ROCHA
('Rafaela Leme De Oliveira Rocha', 'Operador (a) De Caixa', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '13:00 às 22:00', '2024-10-28', '2024-10-28', '2025-08-04', '1997-08-27', 'Feminino', '52.325.505-6', '462.961.228-96', '136.96283.05-2', NULL, 'Casado(a)', '{"nome": "Gabriel Zanette", "data_nascimento": ""}', 0, NULL, 'rafaelaoliverleme97@gmail.com', '(11) 98710-4664', '(11) 2456-8100', NULL, '03367-000', 'Av. Henrique Morize', '156', 'Casa', 'Vila Formosa', 'São Paulo', 'SP', 'Vale Transporte', 'Ônibus, Metrô', 4, 'R$ 19,68', NULL, NULL, '2025-01-29', NULL, NULL, 'SJ2 - Demissão sem justa causa', 'Avaliar'),

-- 16. MATHEUS DA SILVA BASTOS
('Matheus Da Silva Bastos', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '14:00 às 22:20', '2025-09-25', '2025-09-25', '2025-10-24', '1998-07-11', 'Masculino', '52.459.127-1', '485.537.178-52', '210.20418.77-1', '0770995059', 'Solteiro(a)', NULL, 2, '[{"nome": "Miguel Lorenzo de Oliveira Bastos", "data_nascimento": "2017-07-07"}, {"nome": "Nathan Gabriel de Oliveira Bastos", "data_nascimento": "2018-11-03"}]', 'psiu.djc@gmail.com', '(11) 98411-2410', NULL, NULL, '02976-240', 'Rua Kalore', '20', 'Casa', 'Vila Zat', 'São Paulo', 'SP', 'Vale Transporte', 'Onibus, Metrô', 4, 'R$ 21,42', NULL, NULL, '2025-10-24', '2034-11-28', NULL, 'PD0 - extinção do ctt de experiência', 'Avaliar'),

-- 17. JONNATHAN ALVES DE JESUS
('Jonnathan Alves De Jesus', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '14:00 às 22:20', '2025-07-08', '2025-07-08', '2025-08-18', '1989-07-24', 'Masculino', '49.201.360-3', '385.361.468-00', '162.19453.20-5', '07893362610', 'Divorciado(a)', NULL, 1, '[{"nome": "Isabelly Santana Alves", "data_nascimento": "2020-12-10"}]', 'jonnathan.alves24@gmail.com', '(11) 97657-0231', '(11) 94171-7011', NULL, '08235-550', 'Rua Flor De Júpiter', '47', 'Casa 3', 'Parque Guarani', 'São Paulo', 'SP', 'Vale Transporte', 'Onibus, Metrô', 4, 'R$ 20,40', NULL, NULL, '2025-08-18', '2025-09-17', NULL, 'SJ1 - pedido de demissão do funcionário', 'Avaliar'),

-- 18. MARCOS PINTO JUNIOR
('Marcos Pinto Junior', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '06:00 às 14:20', '2025-08-28', '2025-08-28', '2025-10-23', '2001-01-20', 'Masculino', '57.295.332-8', '851.133.319-88', '207.26754.39-1', '00000000000', 'Solteiro(a)', NULL, 0, NULL, NULL, '(11) 93094-0199', '(11) 94343-4064', NULL, '07090-020', 'Rua Jorge Street', '145', 'Antigo 141', 'Jardim Gumercindo', 'Guarulhos', 'SP', 'Auxílio Combustível', NULL, NULL, 'R$ 120,00', NULL, NULL, '2025-10-23', '2032-02-06', NULL, 'SJ1 - pedido de demissão do funcionário', 'Avaliar'),

-- 19. JOALBERT CASTRO JIMENEZ
('Joalbert Castro Jimenez', 'Operador (a) De Caixa', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '13:00 às 22:00', '2025-08-19', '2025-08-19', '2025-12-05', '1995-07-30', 'Masculino', 'F787950 - U', '901.521.358-55', NULL, '08760791197', 'Solteiro(a)', NULL, 0, NULL, 'joalbertcastro3@gmail.com', '(93) 98126-7137', '(11) 91713-1033', NULL, '04216-001', 'Rua Mil Oitocentos E Vinte E Dois', '895', 'Ap 1304', 'Ipiranga', 'São Paulo', 'SP', 'Vale Transporte', 'Onibus, Metrô', 4, 'R$ 21,42', NULL, NULL, '2025-12-05', '2025-10-01', NULL, 'SJ1 - pedido de demissão do funcionário', 'Avaliar'),

-- 20. EDUARDO BALEK DE MIRANDA
('Eduardo Balek De Miranda', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'Administrativo', '08:30 às 17:30', '2025-08-22', '2025-08-22', '2025-12-01', '1980-09-26', 'Masculino', '30.316.276-4', '300.339.388-06', '128.90537.89-9', '03625246808', 'Solteiro(a)', NULL, 2, '[{"nome": "Nathan Marquezani de Miranda", "data_nascimento": "2007-12-12"}, {"nome": "Matheus Marquezani de Miranda", "data_nascimento": "2009-06-02"}]', NULL, '(11) 97619-1388', NULL, NULL, '03411-020', 'Rua Maria Guilhermina', '74', 'Casa', 'Chácara Santo Antônio', 'São Paulo', 'SP', 'Vale Transporte', 'Ônibus', 4, 'R$ 20,00', NULL, NULL, '2025-12-01', '2031-10-07', NULL, 'SJ1 - pedido de demissão do funcionário', 'Avaliar'),

-- 21. FABIO ANDRE PAULINO DOS SANTOS
('Fabio Andre Paulino Dos Santos', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '07:00 às 15:20', '2025-08-12', '2025-08-12', '2026-01-08', '1982-07-25', 'Masculino', '45.480.418-0', '299.859.738-60', '130.33536.89-0', '03093908020', 'Solteiro(a)', NULL, 1, '[{"nome": "Yasmin Honorio Santos", "data_nascimento": "2011-12-19"}]', 'andrefabio246@gmail.com', '(11) 96794-0444', '(11) 98739-8986', '(19) 98167-5165', '03717-010', 'Rua Coríntios', '42', 'Casa 2', 'Jardim Piratininga', 'São Paulo', 'SP', 'Não Optante', NULL, NULL, NULL, NULL, NULL, '2026-01-08', '2034-04-30', NULL, 'SJ1 - pedido de demissão do funcionário', 'Avaliar'),

-- 22. MARLOS THENER PRADO DOS SANTOS
('Marlos Thener Prado Dos Santos', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '14:00 às 22:20', '2025-05-15', '2025-05-15', '2025-07-13', '1982-01-18', 'Masculino', '33.624.533-6', '287.334.998-02', '132.35428.93-2', '03350333699', 'Solteiro(a)', NULL, 2, '[{"nome": "Mylena Cecilia Godoy Prado dos Santos", "data_nascimento": "2011-09-26"}, {"nome": "Miguel Godoy Prado dos Santos", "data_nascimento": "2013-10-31"}]', 'marlosthener29@gmail.com', '(11) 95953-6959', NULL, NULL, '08588-340', 'Rua Padre João Manoel', '126', 'Casa', 'Jardim Carolina', 'Itaquaquecetuba', 'SP', 'Vale Transporte', 'Ônibus, Trem', 4, 'R$ 23,40', NULL, NULL, '2025-07-13', '2031-07-30', NULL, 'PD0 - extinção do ctt de experiência', 'Avaliar'),

-- 23. GIOVANA MUNIZ BARRETO SILVA
('Giovana Muniz Barreto Silva', 'Operador (a) De Caixa', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '07:00 às 16:00', '2025-08-04', '2025-08-04', '2025-09-12', '2006-12-04', 'Feminino', '60.435.251-7', '436.597.658-30', '270.65667.16-8', NULL, 'Solteiro(a)', NULL, 0, NULL, 'fabi.pdg@gmail.com', '(11) 97371-3526', '(11) 94433-5662', NULL, '08250-540', 'Rua Arturo Vital', '126', '51 B', 'Conjunto Residencial José Bonifácio', 'São Paulo', 'SP', 'Não Optante', NULL, NULL, NULL, NULL, NULL, '2025-09-12', NULL, NULL, 'RA2 - recisão antecipada', 'Avaliar'),

-- 24. ISMENIA BARBOSA
('Ismenia Barbosa', 'Operador (a) De Caixa', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '13:00 às 22:00', '2025-12-02', '2025-12-02', '2025-12-05', '2003-04-05', 'Feminino', '67.405.973-6', '108.281.215-32', '162.59352.08-6', NULL, 'Solteiro(a)', NULL, 0, NULL, 'ismeniasouza0504@gmail.com', '(11) 95481-1719', NULL, NULL, '04218-000', 'Rua Comandante Taylor', '711', 'Casa', 'Ipiranga', 'São Paulo', 'SP', 'Não Optante', NULL, NULL, NULL, NULL, NULL, '2025-12-05', NULL, NULL, 'RA1 - pedido de demissão do funcionário', 'Avaliar'),

-- 25. BRUNO NOGUEIRA DOS SANTOS
('Bruno Nogueira Dos Santos', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'IGESP - Pronto Atendimento Congonhas', '10:00 às 19:00', '2025-03-29', '2025-03-29', '2025-10-24', '2004-02-01', 'Masculino', '52.130.299-7', '377.870.058-82', '212.65975.44-4', '08939249208', 'Solteiro(a)', NULL, 0, NULL, 'rmandala2001@gmail.com', '(11) 99559-5355', '(11) 97234-0664', NULL, '04251-080', 'Rua Manhuaçu', '104', 'Casa', 'Vila Natalia', 'São Paulo', 'SP', 'Vale Transporte', 'Onibus', 4, 'R$ 26,10', NULL, NULL, '2025-10-24', '2026-03-17', NULL, 'SJ1 - pedido de demissão do funcionário', 'Avaliar'),

-- 26. CRISTIANO SEBASTIÃO GONÇALVES
('Cristiano Sebastião Gonçalves', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '14:00 às 22:20', '2025-08-19', '2025-08-19', '2025-11-14', '1977-05-18', 'Masculino', '25.766.030-6', '278.774.718-31', '125.32400.10-4', '04127504603', 'Solteiro(a)', NULL, 2, '[{"nome": "Sarah Wine Novais Gonçalves", "data_nascimento": "2015-10-30"}, {"nome": "Pedro Gustavo Loureiro Gonçalves", "data_nascimento": "2007-11-02"}]', NULL, '(11) 98816-0747', '(11) 99952-0802', NULL, '01320-010', 'Rua Conde De São Joaquim', '140', 'Ap 113, Bloco A', 'Bela Vista', 'São Paulo', 'SP', 'Vale Transporte', 'Onibus', 2, 'R$ 10,00', NULL, NULL, '2025-11-14', '2031-06-16', NULL, 'SJ1 - pedido de demissão do funcionário', 'Avaliar'),

-- 27. VIRNIA DE LIMA MOREIRA
('Virnia De Lima Moreira', 'Operador (a) De Caixa', 'inativo', 'Tranquility', 'IGESP - Pronto Atendimento Congonhas', '07:00 às 17:00', '2024-09-28', '2024-09-28', '2025-12-05', '2002-01-19', 'Feminino', '2008786189 - 0', '755.474.635-91', '666.86613.36-0', NULL, 'Solteiro(a)', NULL, 0, NULL, 'lvirna391@gmail.com', '(11) 95819-3710', '(11) 94998-9860', NULL, '01321-020', 'Rua Vicente Prado', '124', 'Casa', 'Bela Vista', 'São Paulo', 'SP', 'Não Optante', NULL, NULL, NULL, NULL, NULL, '2025-12-05', NULL, NULL, 'SJ2 - demissão sem justa causa', 'Avaliar'),

-- 28. RYAN RODRIGO MAIA ESTEVEZ
('Ryan Rodrigo Maia Estevez', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'IGESP - Pronto Atendimento Santos', '06:00 às 14:20', '2025-05-13', '2025-05-13', '2025-08-22', '2001-07-05', 'Masculino', '57.135.771-4', '574.320.368-70', '134.48499.30-6', '07987716802', 'Solteiro(a)', NULL, 0, NULL, 'ryan.estevez07@gmail.com', '(13) 98191-2657', '(13) 99112-2418', '(13) 99121-0747', '11390-050', 'Rua José Gonçalves Da Mota Junior', '60', 'Casa', 'Vila Valença', 'São Vicente', 'SP', 'Vale Transporte', 'Onibus', 2, 'R$ 10,00', NULL, NULL, '2025-08-22', '2025-10-05', NULL, 'SJ1 - pedido de demissão do funcionário', 'Avaliar'),

-- 29. DANIEL DA SILVA MARTINS
('Daniel Da Silva Martins', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '14:00 às 22:20', '2025-02-26', '2025-02-26', '2025-10-12', '1999-09-07', 'Masculino', '38.609.245-4', '758.806.780-22', '374.15753.87-0', '07069304690', 'Solteiro(a)', NULL, 0, NULL, 'danielsilvam@gmail.com', '(11) 95227-4380', '(11) 98331-7378', '(31) 12553-6344', '08420-500', 'Avenida Ribeiro Itaquera', '14', 'Casa 1', 'Parque Central', 'São Paulo', 'SP', 'Vale Transporte', 'Ônibus, Trem', 2, 'R$ 21,42', NULL, NULL, '2025-10-12', '2023-03-31', NULL, 'SJ2 - demissão sem justa causa', 'Avaliar'),

-- 30. DOUGLAS RODRIGUES DUQUE
('Douglas Rodrigues Duque', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '14:00 às 22:00', '2025-09-24', '2025-09-24', '2025-12-23', '1981-08-21', 'Masculino', '55.471.913-7', '533.444.365-71', '289.80033.46-0', '07385177683', 'Solteiro(a)', NULL, 1, '[{"nome": "Enzo Gabriel Rodrigues Duque", "data_nascimento": "2017-11-07"}]', 'douglasrd@gmail.com', '(11) 91252-9041', '(31) 98243-3248', NULL, '01508-030', 'Rua Fagundes', '206', 'Casa', 'Liberdade', 'São Paulo', 'SP', 'Não Optante', NULL, NULL, NULL, NULL, NULL, '2025-12-23', '2024-06-19', NULL, 'SJ1 - pedido de demissão do funcionário', 'Avaliar'),

-- 31. ALEX SANDRO SOBREIRA DANTAS
('Alex Sandro Sobreira Dantas', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'IGESP - Pronto Atendimento Anália Franco', '06:30 às 15:30', '2025-07-03', '2025-07-03', '2025-07-25', '1990-03-04', 'Masculino', '37.856.682-5', '388.895.378-25', '207.89611.05-2', '04387974472', 'Solteiro(a)', NULL, 1, '[{"nome": "Sofia Gomes Dantas", "data_nascimento": "2015-03-07"}]', 'alexdantas0712@gmail.com', '(11) 98432-0004', NULL, NULL, '03330-000', 'Av. Álvaro Ramos', '1096', 'Casa', 'Quarta Parada', 'São Paulo', 'SP', 'Vale Transporte', 'Onibus', 2, 'R$ 10,00', NULL, NULL, '2025-07-25', '2031-06-24', NULL, 'RA2 - recisão antecipada', 'Avaliar'),

-- 32. CAIO VINICIUS GALASSO
('Caio Vinicius Galasso', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'IGESP - Hospital Praia Grande', '10:00 às 18:20', '2025-05-16', '2025-05-16', '2025-12-04', '2003-07-23', 'Masculino', '63.492.944-6', '557.048.368-36', '270.16258.57-8', '08844357510', 'Solteiro(a)', NULL, 0, NULL, 'caiogalasso14@gmail.com', '(13) 98859-9831', '(13) 99682-1177', '(13) 99648-9766', '11330-709', 'Rua Cidade De Santos', '1197', 'Casa', 'Vila Margarida', 'São Vicente', 'SP', 'Vale Transporte', 'Onibus', 2, 'R$ 13,00', NULL, NULL, '2025-12-04', '2025-12-15', NULL, 'SJ1 - pedido de demissão do funcionário', 'Avaliar'),

-- 33. ALEXANDRE BEZERRA DA SILVA
('Alexandre Bezerra Da Silva', 'Encarregado De Estacionamento', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '07:00 às 16:00', '2025-10-06', '2025-10-06', '2025-10-20', '1986-07-29', 'Masculino', '45.833.957-3', '580.325.981-01', '351.05719.31-0', '05593661677', 'Solteiro(a)', NULL, 1, '[{"nome": "Miguel Gomes Da Silva", "data_nascimento": "2017-02-13"}]', 'alexandrebs2020@hotmail.com', '(11) 94794-3617', '(11) 94775-7273', NULL, '05528-001', 'Rua Edvard Carmilo', '520', 'Torre B Ap 405', 'Jardim Celeste', 'São Paulo', 'SP', 'Vale Transporte', 'Onibus, Metrô', 4, 'R$ 21,42', NULL, NULL, '2025-10-20', '2032-07-20', NULL, 'SJ1 - pedido de demissão do funcionário', 'Avaliar'),

-- 34. ALEXANDRE HENRIQUE MACEDO
('Alexandre Henrique Macedo', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '06:00 às 14:20', '2025-02-25', '2025-02-25', '2025-07-13', '1987-09-11', 'Masculino', '29.447.197-2', '350.906.638-31', '138.03736.81-0', '04211127708', 'Solteiro(a)', NULL, 0, NULL, NULL, '(11) 98846-1024', '(11) 97593-0484', NULL, '03759-030', 'Rua Jácome Teles Menezes', '251', 'Casa', 'Jardim Penha', 'São Paulo', 'SP', 'Vale Transporte', 'Onibus, Metrô', 4, 'R$ 21,42', NULL, NULL, '2025-07-14', '2033-10-23', NULL, 'JC2 - Demissão com justa causa', 'Não'),

-- 35. THIAGO VICTOR GOMES DA SILVA
('Thiago Victor Gomes Da Silva', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'IGESP - Pronto Atendimento Congonhas', '10:00 às 19:00', '2025-02-13', '2025-02-13', '2025-04-13', '1997-10-29', 'Masculino', '38.447.901-7', '344.876.098-60', '141.09516.44-3', '06971689810', 'Solteiro(a)', NULL, 0, NULL, NULL, '(11) 96449-4689', NULL, NULL, '04814-690', 'Rua Dinalva Oliveira Teixeira', '363', 'Casa', 'Jardim Ganhembu', 'São Paulo', 'SP', 'Auxílio Combustível', NULL, NULL, 'R$ 120,00', NULL, NULL, '2025-04-13', '2032-05-10', NULL, 'PD0 - extinção do ctt de experiência', 'Avaliar'),

-- 36. WILLISON SILVA OLIVEIRA
('Willison Silva Oliveira', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '06:00 às 14:20', '2024-11-23', '2024-11-23', '2025-11-08', '1997-07-01', 'Masculino', '37.798.830-3', '397.643.498-11', '207.25469.02-6', '06641913329', 'Solteiro(a)', NULL, 1, '[{"nome": "Lucas Silva Barbosa", "data_nascimento": "2019-06-26"}]', 'willisonb7@gmail.com', '(11) 97014-1408', '(11) 3203-0556', NULL, '05877-170', 'Rua Battista Malatesta', '228', 'F', 'Jardim Guarujá', 'São Paulo', 'SP', 'Auxílio Combustível', NULL, NULL, 'R$ 120,00', NULL, NULL, '2025-11-07', '2032-04-04', NULL, 'SJ2 - demissão sem justa causa', 'Avaliar'),

-- 37. WAGNER APARECIDO DE JESUS
('Wagner Aparecido De Jesus', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '14:00 às 22:20', '2025-10-16', '2025-10-16', '2025-11-06', '1969-01-09', 'Masculino', '19.550.347-8', '113.148.658-70', '122.40493.49-8', '01285700687', 'Solteiro(a)', NULL, 1, '[{"nome": "Isabelly Santos Silva de Jesus", "data_nascimento": "2007-10-01"}]', 'kwayjesus@gmail.com', '(11) 97632-1378', '(11) 99334-0802', NULL, '03756-030', 'Rua Nova Cruz', '195', 'Casa', 'Jardim Gonzaga', 'São Paulo', 'SP', 'Vale Transporte', 'Onibus', 2, 'R$ 10,40', NULL, NULL, '2025-11-06', '2027-07-18', NULL, 'RA1 - pedido de demissão do funcionário', 'Avaliar'),

-- 38. ODESIO RESENDE ALVES BATISTA
('Odesio Resende Alves Batista', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '15:00 às 23:20', '2025-05-19', '2025-05-19', '2025-08-27', '1987-08-23', 'Masculino', '33.751.584-0', '359.962.608-16', '134.96677.77-4', '05010707445', 'Divorciado(a)', NULL, 1, '[{"nome": "Ana Beatriz Resende da Silva Alves", "data_nascimento": "2007-08-31"}]', 'odesiofamilia2308@gmail.com', '(11) 98815-1532', '(11) 95698-9220', NULL, '04831-100', 'Rua Frei Luís De Granada', '317', 'Casa', 'Jardim Vista Alegre', 'São Paulo', 'SP', 'Vale Transporte', 'Onibus, Metrô', 4, 'R$ 21,42', NULL, NULL, '2025-08-27', '2031-10-07', NULL, 'SJ1 - pedido de demissão do funcionário', 'Avaliar'),

-- 39. GABRIEL DE CARVALHO MUNIZ SANTOS
('Gabriel De Carvalho Muniz Santos', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '14:00 às 22:00', '2024-09-16', '2024-09-16', '2025-01-22', '1998-10-10', 'Masculino', '53.276.111-X', '490.480.288-84', '162.43921.50-7', '06968123503', 'Solteiro(a)', NULL, 1, '[{"nome": "Nicholas Dos Santos Carvalho", "data_nascimento": "2016-06-07"}]', NULL, '(11) 99359-9881', '(11) 93036-5889', NULL, '06773-230', 'Rua Gilson Gasparini', '114', 'Casa 5', 'Parque São Joaquim', 'Taboão Da Serra', 'SP', 'Vale Transporte', 'Onibus, Metrô', 4, 'R$ 21,42', NULL, NULL, '2025-01-22', '2032-04-20', NULL, 'JC2 - Demissão com justa causa', 'Não'),

-- 40. JOSE EDSON FIRMINO DA SILVA
('Jose Edson Firmino Da Silva', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '14:00 às 22:20', '2024-11-08', '2024-11-08', '2024-12-04', '1983-01-14', 'Masculino', '36.574.389-6', '339.188.238-73', '133.88043.85-9', '04932014136', 'Solteiro(a)', NULL, 2, '[{"nome": "Marina Santos Silva", "data_nascimento": "2009-12-31"}, {"nome": "Eduardo Mariano Santos Silva", "data_nascimento": "2016-08-10"}]', 'joseedsonfirminosilva@gmail.com', '(11) 94626-0220', '(11) 94071-4670', NULL, '04019-000', 'Rua Doutor Mário Cardim', '2', 'Casa 19', 'Vila Mariana', 'São Paulo', 'SP', 'Vale Transporte', 'Onibus', 4, 'R$ 21,42', NULL, NULL, '2024-12-04', '2024-11-09', NULL, 'RA1 - pedido de demissão do funcionário', 'Avaliar'),

-- 41. ONER BOZKURT
('Oner Bozkurt', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '14:00 às 22:20', '2025-01-16', '2025-01-16', '2025-03-11', '1981-08-31', 'Masculino', NULL, '236.045.938-40', NULL, '06702410274', 'Casado(a)', '{"nome": "Marcela Prado Stefanelli", "data_nascimento": "1972-01-24"}', 0, NULL, 'marcela.stefanelli@gmail.com', '(11) 95026-6033', '(11) 97183-1435', NULL, '01546-020', 'Rua Alcindo Guanabara', '36', 'Ap 602', 'Jardim Da Glória', 'São Paulo', 'SP', 'Vale Transporte', 'Onibus', 2, 'R$ 10,71', NULL, NULL, '2025-03-11', '2025-08-28', NULL, 'RA1 - pedido de demissão do funcionário', 'Avaliar'),

-- 42. GUILHERME SILVA DO NASCIMENTO
('Guilherme Silva Do Nascimento', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '06:00 às 14:20', '2024-11-27', '2024-11-27', '2024-12-13', '1996-08-31', 'Masculino', '37.735.890-3', '471.982.128-67', '267.34181.06-3', '37735890', 'Solteiro(a)', NULL, 0, NULL, 'guitricoloresilva@hotmail.com', '(11) 96649-6005', '(11) 98547-1949', NULL, '03728-000', 'Rua São José Do Campestre', '92', 'Casa', 'Jardim Danfer', 'São Paulo', 'SP', 'Vale Transporte', 'Onibus, Metrô', 4, 'R$ 19,68', NULL, NULL, '2024-12-17', '2025-03-03', NULL, 'JC2 - Demissão com justa causa', 'Não'),

-- 43. NILTON ANJOS DE JESUS
('Nilton Anjos De Jesus', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '14:00 às 22:20', '2024-10-23', '2024-10-23', '2024-11-14', '1970-10-22', 'Masculino', '24.366.515-5', '116.801.678-98', '123.98457.98-4', '04162279553', 'Solteiro(a)', NULL, 2, '[{"nome": "Rafaela Ferreira de Jesus", "data_nascimento": "2019-06-12"}, {"nome": "Nicolas Ferreira de Jesus", "data_nascimento": "2011-09-10"}]', 'niltonanjosdejesus@gmail.com', '(11) 98785-4385', NULL, NULL, '04949-000', 'Avenida M\'Boi Guaçu', '793', 'Casa', 'Jardim Aracati', 'São Paulo', 'SP', 'Não Optante', NULL, NULL, NULL, NULL, NULL, '2024-11-14', '2029-05-13', NULL, 'RA1 - pedido de demissão do funcionário', 'Avaliar'),

-- 44. DOUGLAS CRISPINIANO DA SILVA LIMA
('Douglas Crispiniano Da Silva Lima', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '14:00 às 22:20', '2024-12-20', '2024-12-20', '2025-01-18', '1988-07-09', 'Masculino', '43.755.147-7', '360.189.148-40', '201.17241.91-6', '04122162762', 'Casado(a)', '{"nome": "Claudiana Alves Lima", "data_nascimento": "1983-09-27"}', 3, '[{"nome": "Jamilly Julia da Silva Lima", "data_nascimento": "2008-05-20"}, {"nome": "Davi da Silva Lima", "data_nascimento": "2011-07-11"}, {"nome": "Vitoria Gabrielly da Silva Lima", "data_nascimento": "2017-03-15"}]', 'crispinianodouglas@gmail.com', '(11) 98613-8358', '(11) 98777-4714', NULL, '05856-160', 'Rua Vozes D\'África', '50', 'Casa 2', 'Parque Sônia', 'São Paulo', 'SP', 'Vale Transporte', 'Onibus, Metrô', 4, 'R$ 19,68', NULL, NULL, '2025-02-11', '2032-11-10', NULL, 'PD0 - extinção do ctt de experiência', 'Avaliar'),

-- 45. WELLINGTON JOÃO DE CASTRO
('Wellington João De Castro', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '14:00 às 22:20', '2024-09-19', '2024-09-19', '2024-10-03', '1975-06-02', 'Masculino', '27.462.019-4', '141.904.988-74', '124.26114.33-0', '02109422832', 'Divorciado(a)', NULL, 0, NULL, 'welligtonjdec06@gmail.com', '(11) 96274-9646', '(11) 2456-8100', NULL, '04425-010', 'Rua Estrela Solitária', '1028', 'Casa', 'Cidade Júlia', 'São Paulo', 'SP', 'Vale Transporte', 'Onibus, Metrô', 4, 'R$ 19,68', NULL, NULL, '2024-10-03', '2027-04-07', NULL, 'RA1 - pedido de demissão do funcionário', 'Avaliar'),

-- 46. RICARDO VIANNA VIEIRA
('Ricardo Vianna Vieira', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '10:00 às 19:00', '2024-09-19', '2024-09-19', '2024-09-16', '1989-01-04', 'Masculino', '44.699.417-0', '399.136.108-69', '165.92106.47-7', '05279545297', 'Solteiro(a)', NULL, 3, '[{"nome": "Laura Vianna de Souza", "data_nascimento": "2013-06-30"}, {"nome": "Livia Vianna de Souza", "data_nascimento": "2017-11-23"}, {"nome": "Lohan Vianna de Souza", "data_nascimento": "2022-04-22"}]', 'talita_julia@hotmail.com', '(11) 91434-0606', '(11) 2456-8100', NULL, '04433-250', 'Rua Pedro Gonçalves Meira', '810', 'Casa', 'Jardim São Carlos', 'São Paulo', 'SP', 'Auxílio Combustível', NULL, NULL, 'R$ 120,00', NULL, NULL, '2024-09-16', '2032-06-30', NULL, 'PD0 - extinção do ctt de experiência', 'Avaliar'),

-- 47. CAIO CANDIDO REZENDE
('Caio Candido Rezende', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '14:00 às 22:20', '2024-10-30', '2024-10-30', '2024-12-10', '1974-05-26', 'Masculino', '35.857.428-6', '025.497.676-08', '124.09924.39-7', '02641950944', 'Solteiro(a)', NULL, 1, '[{"nome": "Laura Ramos Rezende", "data_nascimento": "2004-07-15"}]', 'pptcaio2@gmail.com', '(11) 91609-9621', NULL, NULL, '04653-050', 'Rua Dr. José Vicente De Barros Filho', '34', 'Casa 1', 'Vila Inglesa', 'São Paulo', 'SP', 'Vale Transporte', 'Onibus, Metrô', 4, 'R$ 19,68', NULL, NULL, '2024-12-10', '2033-03-16', NULL, 'RA1 - pedido de demissão do funcionário', 'Avaliar'),

-- 48. SANDRA ANTONIO CARDOSO
('Sandra Antonio Cardoso', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '15:00 às 23:20', '2024-09-16', '2024-09-16', '2024-09-18', '1980-02-26', 'Feminino', '34.727.627-1', '287.933.858-11', '127.55452.81-3', '05966904041', 'Casado(a)', '{"nome": "Eudes Pereira Nunes", "data_nascimento": "1978-01-29"}', 1, '[{"nome": "Vitoria Cardoso Nunes", "data_nascimento": "2006-10-09"}]', 'sandra.antonio565@gmail.com', '(11) 95215-2622', '(11) 2456-8100', NULL, '02543-004', 'Travessa Roda Viva', '28', 'Casa', 'Vila Celeste', 'São Paulo', 'SP', 'Não Optante', NULL, NULL, NULL, NULL, NULL, '2024-09-18', '2034-02-26', NULL, 'RA1 - pedido de demissão do funcionário', 'Avaliar'),

-- 49. ROBERTO DE OLIVEIRA LOPES
('Roberto De Oliveira Lopes', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'IGESP - Hospital Praia Grande', '06:00 às 14:00', '2024-10-28', '2024-10-28', '2024-11-22', '2000-01-10', 'Masculino', '55.624.621-4', '317.491.248-23', '138.99629.64-6', '07279222879', 'Solteiro(a)', NULL, 0, NULL, 'diverlopes01@gmail.com', '(13) 99138-9797', '(13) 3466-1215', NULL, '11310-070', 'Rua Jacob Emerick', '154', 'Ap 1403', 'São Vicente', 'São Vicente', 'SP', 'Auxílio Combustível', NULL, NULL, 'R$ 150,00', NULL, NULL, '2024-11-22', '2033-08-18', NULL, 'JC2 - Demissão com justa causa', 'Não'),

-- 50. ROGERIO DO AMARAL RODRIGUES
('Rogerio Do Amaral Rodrigues', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'IGESP - Pronto Atendimento Congonhas', '10:00 às 19:00', '2025-01-15', '2025-01-15', '2025-02-11', '1990-07-25', 'Masculino', '36.685.411-2', '408.667.398-31', '137.32031.89-5', '06176329975', 'Solteiro(a)', NULL, 0, NULL, 'rogerioamaral10@gmail.com', '(11) 94908-4004', '(11) 96466-9547', NULL, '04689-050', 'Rua Itabapoana', '256', 'Casa 2', 'Vila Isa', 'São Paulo', 'SP', 'Vale Transporte', 'Onibus', 2, 'R$ 10,71', NULL, NULL, '2025-02-11', '2024-12-05', NULL, 'RA2 - pedido de demissão do funcionário', 'Avaliar'),

-- 51. ALEXANDRE NASCIMENTO DA SILVA
('Alexandre Nascimento Da Silva', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'IGESP - Pronto Atendimento Congonhas', '10:00 às 19:00', '2024-10-08', '2024-10-08', '2024-12-27', '1975-06-16', 'Masculino', '26.398.167-8', '249.343.098-02', '128.50631.81-9', '03448065239', 'Casado(a)', '{"nome": "Ana Paula Nascimento da Silva", "data_nascimento": "1975-03-23"}', 0, NULL, NULL, '(11) 95276-5220', '(11) 2456-8100', NULL, '01050-070', 'Rua Álvaro De Carvalho', '427', 'Apto 604', 'Centro', 'São Paulo', 'SP', 'Vale Transporte', 'Metrô', 2, 'R$ 10,99', NULL, NULL, '2024-12-27', '2032-02-16', NULL, 'SJ1 - pedido de demissão do funcionário', 'Avaliar'),

-- 52. GIOVANNY NICACIO BERTULINO
('Giovanny Nicacio Bertulino', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '11:00 às 19:20', '2024-09-30', '2024-09-30', '2025-06-07', '2000-08-06', 'Masculino', '37.293.011-4', '880.676.888-31', '626.83339.78-0', '07273376621', 'Solteiro(a)', NULL, 0, NULL, 'giovannybertulino06@gmail.com', '(11) 95550-3421', '(11) 2456-8100', NULL, '08215-150', 'Rua Narciso Araújo', '830', 'AP 51 BL 2B', 'Itaquera', 'São Paulo', 'SP', 'Vale Transporte', 'Onibus, Metrô', 4, 'R$ 19,00', NULL, NULL, '2025-06-12', '2033-12-08', NULL, 'SJ2 - demissão sem justa causa', 'Avaliar'),

-- 53. CELIO ROBERTO MARTINS DE SOUZA
('Celio Roberto Martins De Souza', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '10:00 às 18:20', '2024-10-08', '2024-10-08', '2025-02-12', '1979-06-19', 'Masculino', '26.351.022-0', '286.712.828-56', '126.98808.93-6', '00617552675', 'Solteiro(a)', NULL, 0, NULL, 'celiorobertomartinsdesouza@gmail.com', '(11) 93222-0870', '(11) 93943-640', NULL, '07992-050', 'Rua Sebastião Queiroz', '821', 'Casa 2', 'Jardim Olga', 'Francisco Morato', 'SP', 'Vale Transporte', 'Onibus, Trem, Metrô', 6, 'R$ 30,28', NULL, NULL, '2025-02-12', '2033-09-13', NULL, 'SJ1 - pedido de demissão do funcionário', 'Avaliar'),

-- 54. GUSTAVO TADEU CARVALHO PRUCHINSKI
('Gustavo Tadeu Carvalho Pruchinski', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '14:00 às 22:20', '2024-10-12', '2024-10-12', '2025-01-28', '1974-02-15', 'Masculino', '36.814.877-4', '276.929.268-40', '125.25574.44-5', '03846641732', 'Casado(a)', '{"nome": "Alessandra Rodrigues de Sousa Pruchinski", "data_nascimento": ""}', 3, '[{"nome": "Joao Gabriel Souza Prunchinski", "data_nascimento": "2002-10-25"}, {"nome": "Paulo Vitor Souza Prunchinski", "data_nascimento": "2011-01-22"}, {"nome": "Pedro Lucas Souza Prunchinski", "data_nascimento": "2002-10-25"}]', 'gustavoguga251002@gmail.com', '(11) 96567-2852', '(11) 2456-8100', NULL, '02731-020', 'Rua Diogo Domingues', '86', 'Casa 1', 'Vila Albertina', 'São Paulo', 'SP', 'Vale Transporte', 'Onibus, Metrô', 4, 'R$ 19,66', NULL, NULL, '2025-01-28', '2032-05-10', NULL, 'JC2 - Demissão com justa causa', 'Não'),

-- 55. MARCO ANTONIO SOUZA SANTOS
('Marco Antonio Souza Santos', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '06:00 às 14:20', '2025-03-19', '2025-03-19', '2025-05-06', '1976-06-22', 'Masculino', '23.556.500-3', '172.580.918-40', '124.38582.98-9', '03042511395', 'Solteiro(a)', NULL, 2, '[{"nome": "Bruna Caroline Oliveira Santos", "data_nascimento": "2005-04-11"}, {"nome": "Lara Leticia Brito Oliveira dos Santos", "data_nascimento": "2010-07-16"}]', 'marchav456@gmail.com', '(11) 96158-6573', NULL, NULL, '01306-010', 'Rua Paim', '235', 'AP 2503 R', 'Bela Vista', 'São Paulo', 'SP', 'Não Optante', NULL, NULL, NULL, NULL, NULL, '2025-05-06', '2025-08-27', NULL, 'RA1 - pedido de demissão do funcionário', 'Avaliar'),

-- 56. ERIC MICHEL CHRISTOPHE SCHMITT
('Eric Michel Christophe Schmitt', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'IGESP - Hospital Praia Grande', '06:00 às 14:20', '2025-03-28', '2025-03-28', '2025-04-27', '1968-02-07', 'Masculino', 'W228436B', '582.288.886-01', '122.03682.60-6', '04416682823', 'Casado(a)', '{"nome": "Claudia Maria de Souza", "data_nascimento": "1973-04-19"}', 1, '[{"nome": "Henry Michel Cristophe Souz Schmitt", "data_nascimento": "2016-04-05"}]', 'schmitteric@gmail.com', '(13) 99636-7791', '(13) 99727-1434', '(13) 99182-7188', '11713-070', 'Avenida Pedro Américo', '104', '45B', 'Parque Das Américas', 'Praia Grande', 'SP', 'Vale Transporte', 'Onibus', 2, 'R$ 10,50', NULL, NULL, '2025-04-27', '2028-06-01', NULL, 'PD0 - extinção do ctt de experiência', 'Avaliar'),

-- 57. LUIZ CONRADO AUGUSTO FILHO
('Luiz Conrado Augusto Filho', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '14:00 às 22:20', '2025-04-10', '2025-04-10', '2025-05-09', '1988-04-04', 'Masculino', '40.574.636-2', '371.420.448-29', '204.35014.95-6', '04864983454', 'Solteiro(a)', NULL, 1, '[{"nome": "Isabella Fatima de Andrade Augusto", "data_nascimento": "2009-08-04"}]', 'i.konrado.augusto@gmail.com', '(11) 94141-4349', NULL, NULL, '04293-000', 'Rua Do Boqueirão', '439', 'Casa', 'Saúde', 'São Paulo', 'SP', 'Vale Transporte', 'Onibus, Metrô', 4, 'R$ 21,42', NULL, NULL, '2025-05-09', '2035-01-08', NULL, 'PD0 - extinção do ctt de experiência', 'Avaliar'),

-- 58. NATHALIA GUERRA
('Nathalia Guerra', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'IGESP - Pronto Atendimento Santos', '06:00 às 14:20', '2025-04-09', '2025-04-09', '2025-06-07', '1998-11-06', 'Feminino', '54.354.148-4', '486.354.008-60', '212.89586.61-8', '08432958221', 'Solteiro(a)', NULL, 1, '[{"nome": "Enzo Teixeira Guerra", "data_nascimento": "2016-05-27"}]', NULL, '(13) 98224-2525', NULL, NULL, '11310-100', 'Av. Presidente Getúlio Vargas', '253', 'AP 1607', 'Morro Dos Barbosas', 'São Vicente', 'SP', 'Auxílio Combustível', NULL, NULL, 'R$ 150,00', NULL, NULL, '2025-06-07', '2025-11-18', NULL, 'PD0 - extinção do ctt de experiência', 'Avaliar'),

-- 59. WILSON ROGERIO GOMES PEREIRA
('Wilson Rogerio Gomes Pereira', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '14:00 às 22:20', '2025-04-14', '2025-04-14', '2025-04-28', '1970-01-01', 'Masculino', '24.735.897-6', '139.133.278-43', '123.84178.55-7', '02714895170', 'Solteiro(a)', NULL, 1, '[{"nome": "Maria Clara Ferreira Gomes Pereira", "data_nascimento": "2006-11-17"}]', NULL, NULL, NULL, NULL, '07115-000', 'Avenida Salgado Filho', '3938', 'AP12 BL3', 'Centro', 'Guarulhos', 'SP', 'Vale Transporte', 'Onibus, Metrô', 4, 'R$ 19,00', NULL, NULL, '2025-04-28', '2031-03-25', NULL, 'RA1 - pedido de demissão do funcionário', 'Avaliar'),

-- 60. WASHINGTON AUGUSTO COELHO
('Washington Augusto Coelho', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'IGESP - Pronto Atendimento Congonhas', '06:30 às 15:30', '2025-05-27', '2025-05-27', '2025-06-25', '1991-05-28', 'Masculino', '47.404.475-0', '387.457.688-46', '207.79860.21-1', '07243454717', 'Solteiro(a)', NULL, 1, '[{"nome": "Davi Luccas da Silva Coelho", "data_nascimento": "2022-01-09"}]', 'guttocoelho@yahoo.com', '(11) 95284-0686', NULL, NULL, '04847-040', 'Rua Gabriel Mattel', '70', 'Casa', 'Parque Novo Grajaú', 'São Paulo', 'SP', 'Vale Transporte', 'Onibus', 2, 'R$ 10,00', NULL, NULL, '2025-06-25', '2027-07-30', NULL, 'PD0 - extinção do ctt de experiência', 'Avaliar'),

-- 61. ELERSON CARDOSO DOS REIS
('Elerson Cardoso Dos Reis', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '06:00 às 14:20', '2024-12-20', '2024-12-20', '2025-05-09', '1998-06-30', 'Masculino', '50.952.942-2', '477.658.228-70', '204.85736.32-7', '07381509336', 'Casado(a)', '{"nome": "Victoria Regina Santos dos Reis", "data_nascimento": "2002-06-28"}', 0, NULL, 'elersonx14@gmail.com', '(11) 95145-6319', NULL, NULL, '07991-050', 'Rua Felizardo Rodrigues Vieira', '75', 'Casa 8', 'Jardim Rosa', 'Francisco Morato', 'SP', 'Vale Transporte', 'Onibus, Metrô', 4, 'R$ 20,00', NULL, NULL, '2025-05-09', '2034-11-14', NULL, 'SJ2 - demissão sem justa causa', 'Avaliar'),

-- 62. ULISSES DE ALMEIDA
('Ulisses De Almeida', 'Operador De Estacionamento', 'inativo', 'Tranquility', 'IGESP - Pronto Atendimento Santos', '14:00 às 22:20', '2025-05-14', '2025-05-14', '2025-05-28', '1988-08-16', 'Masculino', '44.778.067-0', '340.403.288-84', '165.70629.55-8', '08579509705', 'Solteiro(a)', NULL, 5, '[{"nome": "Ana Carolina Nascimento Santos de Almeida", "data_nascimento": "2010-05-01"}, {"nome": "Anthony Gabriel Nascimento Santos de Almeida", "data_nascimento": "2022-01-18"}, {"nome": "Luana Gabriely Nascimento Santos de Almeida", "data_nascimento": "2015-06-29"}, {"nome": "Maria Luiza Nascimento Santos de Almeida", "data_nascimento": "2011-05-22"}, {"nome": "Wesley Miguel Nascimento Santos de Almeida", "data_nascimento": "2013-10-22"}]', 'ulissesnascimento16@gmail.com', '(13) 99612-3605', NULL, NULL, '11082-300', 'Av. Nossa Senhora Do Monte Serrat', '37', 'Casa 2', 'Morro São Bento', 'Santos', 'SP', 'Vale Transporte', 'Onibus', 2, 'R$ 27,90', NULL, NULL, '2025-05-28', '2033-07-06', NULL, 'RA2 - recisão antecipada', 'Avaliar');




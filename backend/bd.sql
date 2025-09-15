-- ======================================================================================
-- SCRIPT COMPLETO E ATUALIZADO DO BANCO DE DADOS
-- PROJETO: PAINEL DE GESTÃO RH - TRANQUILITY PARKING LOT
-- DATA: 15/07/2025
-- ======================================================================================


-- ======================================================================================
-- PARTE 1: ESTRUTURA DO BANCO DE DADOS (CRIAÇÃO DAS TABELAS)
-- ======================================================================================

-- Apaga o banco de dados se ele já existir, para garantir um começo limpo
DROP DATABASE IF EXISTS `tranquility_rh_db`;

-- Cria o novo banco de dados
CREATE DATABASE `tranquility_rh_db` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Seleciona o banco de dados para uso
USE `tranquility_rh_db`;

--
-- Criação da tabela `funcionarios` com todas as colunas finais
--
CREATE TABLE `funcionarios` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(255) NOT NULL,
  `funcao` VARCHAR(100) DEFAULT NULL,
  `local` VARCHAR(100) DEFAULT NULL,
  `status` ENUM('ativo', 'inativo') NOT NULL DEFAULT 'ativo',
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
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


--
-- Criação da tabela `status_diario` para o dashboard de ponto
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



-- Script para adicionar as colunas de histórico de demissão na tabela `funcionarios`
ALTER TABLE funcionarios
ADD COLUMN motivo_demissao TEXT DEFAULT NULL,
ADD COLUMN elegivel_recontratacao ENUM('Sim', 'Não', 'Avaliar') DEFAULT NULL;




-- ======================================================================================
-- PARTE 2: CONSULTAS (SELECTs) PARA DEMONSTRAÇÃO
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




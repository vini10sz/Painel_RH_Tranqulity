-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:8889
-- Tempo de geração: 18/09/2025 às 00:19
-- Versão do servidor: 8.0.40
-- Versão do PHP: 8.3.14

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Banco de dados: `tranquility_rh_db`
--

-- --------------------------------------------------------

--
-- Estrutura para tabela `administradores`
--

CREATE TABLE `administradores` (
  `id` int NOT NULL,
  `nome` varchar(55) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(55) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `senha` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `administradores`
--

INSERT INTO `administradores` (`id`, `nome`, `email`, `senha`) VALUES
(1, 'admin', 'admin@gmail.com', 'admin');

-- --------------------------------------------------------

--
-- Estrutura para tabela `documentos`
--

CREATE TABLE `documentos` (
  `id` int NOT NULL,
  `pasta_id` int NOT NULL,
  `nome_original` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Nome original do arquivo',
  `caminho_arquivo` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Caminho do arquivo salvo no servidor',
  `tipo_arquivo` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `data_upload` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estrutura para tabela `funcionarios`
--

CREATE TABLE `funcionarios` (
  `id` int NOT NULL,
  `nome` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `funcao` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('ativo','inativo') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ativo',
  `empresa` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `local` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `data_admissao` date DEFAULT NULL,
  `data_demissao` date DEFAULT NULL,
  `data_nascimento` date DEFAULT NULL,
  `rg` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cpf` varchar(14) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cnh_numero` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `estado_civil` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dados_conjuge` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Armazena dados do cônjuge em formato JSON',
  `quantidade_filhos` int DEFAULT '0',
  `nome_filhos` text COLLATE utf8mb4_unicode_ci COMMENT 'Armazena dados dos filhos em formato JSON',
  `email_pessoal` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `telefone_1` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `telefone_2` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `telefone_3` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cep` varchar(9) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rua` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `numero` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `complemento` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bairro` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cidade` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `estado` varchar(2) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `genero` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `validade_cnh` date DEFAULT NULL,
  `validade_exame_medico` date DEFAULT NULL,
  `validade_treinamento` date DEFAULT NULL,
  `validade_cct` date DEFAULT NULL COMMENT 'Antiga validade_sst',
  `validade_contrato_experiencia` date DEFAULT NULL,
  `motivo_demissao` text COLLATE utf8mb4_unicode_ci,
  `elegivel_recontratacao` enum('Sim','Não','Avaliar') COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `funcionarios`
--

INSERT INTO `funcionarios` (`id`, `nome`, `funcao`, `status`, `empresa`, `local`, `data_admissao`, `data_demissao`, `data_nascimento`, `rg`, `cpf`, `cnh_numero`, `estado_civil`, `dados_conjuge`, `quantidade_filhos`, `nome_filhos`, `email_pessoal`, `telefone_1`, `telefone_2`, `telefone_3`, `cep`, `rua`, `numero`, `complemento`, `bairro`, `cidade`, `estado`, `genero`, `validade_cnh`, `validade_exame_medico`, `validade_treinamento`, `validade_cct`, `validade_contrato_experiencia`, `motivo_demissao`, `elegivel_recontratacao`) VALUES
(1, 'Ana Clara Ribeiro', 'Operadora de Caixa', 'ativo', 'Tranquility', 'IGESP - Hospital Praia Grande', '2023-05-10', NULL, '1998-09-15', '45.123.456-7', '123.456.789-10', '987654321', 'Solteiro(a)', NULL, 0, NULL, 'ana.clara@email.com', '(11) 98877-6655', NULL, NULL, '11702-050', 'Avenida Marechal Mallet', '500', NULL, 'Canto do Forte', 'Praia Grande', 'SP', 'Feminino', '2026-09-17', '2026-03-17', NULL, '2026-09-17', NULL, NULL, NULL),
(2, 'Bruno Costa e Silva', 'Gerente de Pátio', 'ativo', 'Tranquility', 'Hapvida', '2021-11-20', NULL, '1985-07-22', '34.567.890-1', '234.567.890-12', '123456789', 'Casado(a)', '{\"nome\": \"Juliana Costa\", \"data_nascimento\": \"1987-08-30\"}', 2, '[{\"nome\": \"Lucas\", \"data_nascimento\": \"2017-06-18\"}, {\"nome\": \"Beatriz\", \"data_nascimento\": \"2020-11-02\"}]', 'bruno.costa@email.com', '(11) 91234-5678', NULL, NULL, '07170-350', 'Avenida Monteiro', '250', NULL, 'Cumbica', 'Guarulhos', 'SP', 'Masculino', '2027-09-17', '2026-09-17', NULL, '2026-09-17', NULL, NULL, NULL),
(3, 'Mariana Lima', 'Manobrista', 'ativo', 'Tranquility', 'Espaço HAOC', '2024-01-15', NULL, '2001-03-12', '56.789.012-3', '345.678.901-23', '876543210', 'Solteiro(a)', NULL, 0, NULL, 'mariana.lima@email.com', '(11) 98765-4321', NULL, NULL, '01307-002', 'Rua Frei Caneca', '1200', 'Apto 10', 'Consolação', 'São Paulo', 'SP', 'Feminino', '2025-08-17', '2026-02-17', NULL, '2026-09-17', NULL, NULL, NULL),
(4, 'Carlos Eduardo Pereira', 'Segurança', 'ativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '2022-08-01', NULL, '1990-11-05', '12.345.678-9', '456.789.012-34', '765432109', 'Divorciado(a)', NULL, 1, '[{\"nome\": \"Gabriel\", \"data_nascimento\": \"2015-02-20\"}]', 'carlos.eduardo@email.com', '(11) 97654-3210', NULL, NULL, '03102-002', 'Rua Visconde de Parnaíba', '1500', NULL, 'Mooca', 'São Paulo', 'SP', 'Masculino', '2028-09-17', '2025-09-02', NULL, '2026-09-17', NULL, NULL, NULL),
(5, 'Rafaela Gomes', 'Atendimento', 'ativo', 'Tranquility', 'São Carlos - Santa Casa', '2025-08-18', NULL, '2003-02-25', '23.456.789-0', '567.890.123-45', NULL, 'Solteiro(a)', NULL, 0, NULL, 'rafaela.gomes@email.com', '(16) 96543-2109', NULL, NULL, '13560-231', 'Rua Paulino dos Santos', '500', NULL, 'Centro', 'São Carlos', 'SP', 'Feminino', NULL, '2026-07-17', NULL, '2026-09-17', '2025-09-27', NULL, NULL),
(6, 'Lucas Martins', 'Manobrista', 'ativo', 'Tranquility', 'IGESP - Pronto Atendimento Congonhas', '2023-12-01', NULL, '1999-09-05', '56.321.789-4', '890.123.456-78', '432109876', 'Solteiro(a)', NULL, 0, NULL, 'lucas.martins@email.com', '(11) 93210-9876', NULL, NULL, '04626-000', 'Avenida Washington Luís', 'S/N', NULL, 'Vila Congonhas', 'São Paulo', 'SP', 'Masculino', '2026-03-17', '2026-03-17', NULL, '2026-09-17', NULL, NULL, NULL),
(7, 'Juliana Santos', 'Supervisora', 'ativo', 'GSM', 'Grupo Santa Marcelina Itaquera - Sede', '2019-06-25', NULL, '1992-04-18', '45.678.901-2', '789.012.345-67', '543210987', 'Casado(a)', '{\"nome\": \"Ricardo Mendes\", \"data_nascimento\": \"1991-03-15\"}', 0, NULL, 'juliana.santos@email.com', '(11) 94321-0987', NULL, NULL, '08270-070', 'Rua Santa Marcelina', '177', NULL, 'Vila Carmosina', 'São Paulo', 'SP', 'Feminino', '2027-09-17', '2026-05-17', NULL, '2026-09-17', NULL, NULL, NULL),
(8, 'Thiago Rocha', 'Segurança', 'ativo', 'GSM', 'Grupo Santa Marcelina Itaquera - AME', '2023-09-18', NULL, '1997-06-20', '23.876.543-2', '012.345.678-90', '321098765', 'Solteiro(a)', NULL, 0, NULL, 'thiago.rocha@email.com', '(11) 91098-7654', NULL, NULL, '08270-070', 'Rua Santa Marcelina', '180', NULL, 'Vila Carmosina', 'São Paulo', 'SP', 'Masculino', '2026-09-17', '2026-08-17', NULL, '2025-07-17', NULL, NULL, NULL),
(9, 'Larissa Mendes', 'Líder de Equipe', 'ativo', 'GSM', 'Grupo Santa Marcelina Itaquera - Instituto', '2018-07-30', NULL, '1993-08-01', '34.765.432-1', '123.456.789-00', '210987654', 'Casado(a)', '{\"nome\": \"Felipe Souza\", \"data_nascimento\": \"1992-07-10\"}', 1, '[{\"nome\": \"Sofia\", \"data_nascimento\": \"2023-04-11\"}]', 'larissa.mendes@email.com', '(11) 90987-6543', NULL, NULL, '08270-070', 'Rua Santa Marcelina', '190', NULL, 'Vila Carmosina', 'São Paulo', 'SP', 'Feminino', '2029-09-17', '2026-06-17', NULL, '2026-09-17', NULL, NULL, NULL),
(10, 'Roberto Dias', 'Manobrista', 'ativo', 'GSM', 'Grupo Santa Marcelina Itaquera - Torre', '2024-03-01', NULL, '1996-10-28', '45.654.321-0', '234.567.890-11', '109876543', 'Divorciado(a)', NULL, 0, NULL, 'roberto.dias@email.com', '(11) 99876-5432', NULL, NULL, '08270-070', 'Rua Santa Marcelina', '200', NULL, 'Vila Carmosina', 'São Paulo', 'SP', 'Masculino', '2026-09-17', '2026-09-17', NULL, '2026-09-17', '2025-08-28', NULL, NULL),
(11, 'Rodrigo Nogueira', 'Analista Financeiro', 'ativo', 'GSM', 'Grupo Santa Marcelina Itaquera - Faculdade Santa Marcelina', '2022-10-03', NULL, '1991-05-14', '22.333.444-5', '555.666.777-88', NULL, 'Casado(a)', '{\"nome\": \"Camila Nogueira\", \"data_nascimento\": \"1992-06-20\"}', 0, NULL, 'rodrigo.n@email.com', '(11) 98765-1111', NULL, NULL, '08270-070', 'Rua Santa Marcelina', '210', NULL, 'Vila Carmosina', 'São Paulo', 'SP', 'Masculino', NULL, '2026-09-17', NULL, '2027-09-17', NULL, NULL, NULL),
(12, 'Sofia Bernardes', 'Jovem Aprendiz', 'ativo', 'Protector', 'Grupo Santa Marcelina Regionais - Hospital Cidade Tiradentes', '2025-08-18', NULL, '2005-08-19', '55.444.333-2', '888.777.666-55', NULL, 'Solteiro(a)', NULL, 0, NULL, 'sofia.b@email.com', '(11) 95555-4444', NULL, NULL, '08471-410', 'Avenida dos Metalúrgicos', '2300', NULL, 'Cidade Tiradentes', 'São Paulo', 'SP', 'Feminino', NULL, '2025-10-12', NULL, '2026-09-17', '2025-11-16', NULL, NULL),
(13, 'Ricardo Andrade', 'Coordenador de Operações', 'ativo', 'Protector', 'Grupo Santa Marcelina Regionais - Hospital Itaim', '2017-02-15', NULL, '1982-01-25', '11.222.333-4', '444.555.666-77', '554433221', 'Casado(a)', '{\"nome\": \"Patrícia Andrade\", \"data_nascimento\": \"1984-03-10\"}', 3, '[{\"nome\": \"Gustavo\", \"data_nascimento\": \"2013-03-12\"}, {\"nome\": \"Helena\", \"data_nascimento\": \"2016-07-09\"}, {\"nome\": \"Miguel\", \"data_nascimento\": \"2021-01-04\"}]', 'ricardo.a@email.com', '(11) 93333-2222', NULL, NULL, '08121-000', 'Avenida Marechal Tito', '6000', NULL, 'Itaim Paulista', 'São Paulo', 'SP', 'Masculino', '2026-09-17', '2026-04-17', NULL, '2026-09-17', NULL, NULL, NULL),
(14, 'José Ferreira', 'Segurança', 'ativo', 'Protector', 'Grupo Santa Marcelina Regionais - Hospital Itaquá', '2015-09-01', NULL, '1975-12-07', '66.777.888-9', '999.888.777-66', '998877665', 'Viúvo(a)', NULL, 2, '[{\"nome\": \"Eduardo\", \"data_nascimento\": \"2003-01-10\"}, {\"nome\": \"Letícia\", \"data_nascimento\": \"2006-05-25\"}]', 'jose.f@email.com', '(11) 92222-1111', NULL, NULL, '08577-000', 'Rua Estados Unidos', '100', NULL, 'Vila Zeferina', 'Itaquaquecetuba', 'SP', 'Masculino', '2026-03-17', '2026-01-17', NULL, '2026-09-17', NULL, NULL, NULL),
(15, 'Isabela Pereira', 'Assistente Administrativo', 'ativo', 'Protector', 'Grupo Santa Marcelina Regionais - Hospital Neomater SBC', '2023-08-20', NULL, '1999-11-30', '77.888.999-0', '111.222.333-44', NULL, 'Solteiro(a)', NULL, 0, NULL, 'isabela.p@email.com', '(11) 98123-4567', NULL, NULL, '09710-011', 'Rua Marechal Deodoro', '1200', NULL, 'Centro', 'São Bernardo do Campo', 'SP', 'Feminino', NULL, '2026-07-17', NULL, '2026-09-17', NULL, NULL, NULL),
(16, 'Fábio Junior Martins', 'Manobrista', 'ativo', 'Protector', 'IGESP - Pronto Atendimento Santo André', '2024-06-10', NULL, '1994-04-04', NULL, NULL, '778899001', 'Não informar', NULL, 0, NULL, 'fabio.jm@email.com', '(11) 96666-7777', NULL, NULL, '09015-020', 'Avenida Dom Pedro II', '500', NULL, 'Jardim', 'Santo André', 'SP', 'Masculino', '2030-09-17', '2026-09-17', NULL, '2026-09-17', '2025-10-07', NULL, NULL),
(17, 'Ana Luíza Vasconcelos', 'Recepcionista', 'ativo', 'GS1', 'São Carlos - CID', '2024-02-05', NULL, '2000-09-09', '99.000.111-2', '333.444.555-66', NULL, 'Casado(a)', '{\"nome\": \"Pedro Vasconcelos\", \"data_nascimento\": \"1998-10-10\"}', 0, NULL, 'analu.v@email.com', '(16) 98888-9999', NULL, NULL, '13566-590', 'Passeio dos Flamboyants', '60', NULL, 'Parque Faber Castell I', 'São Carlos', 'SP', 'Feminino', NULL, '2026-06-17', NULL, '2026-09-17', NULL, NULL, NULL),
(18, 'Samantha Jones', 'Consultora de RH', 'ativo', 'GS1', 'São Carlos - Onovolab', '2024-05-20', NULL, '1995-10-25', '21.222.333-4', '555.666.777-88', NULL, 'Divorciado(a)', NULL, 1, '[{\"nome\": \"Leo\", \"data_nascimento\": \"2019-03-14\"}]', 'samantha.j@email.com', '(16) 97777-1111', NULL, NULL, '13560-251', 'Avenida Doutor Carlos Botelho', '1800', NULL, 'Centro', 'São Carlos', 'SP', 'Outro', NULL, '2026-08-17', NULL, '2026-09-17', '2025-11-01', NULL, NULL),
(19, 'Vinicius Moraes', 'Manobrista', 'ativo', 'GS1', 'IGESP - Pronto Atendimento Anália Franco', '2023-03-15', NULL, '1998-04-22', '33.444.555-6', '666.777.888-99', '665544332', 'Solteiro(a)', NULL, 0, NULL, 'vinicius.m@email.com', '(11) 98888-7777', NULL, NULL, '03337-000', 'Rua Emília Marengo', '400', NULL, 'Vila Regente Feijó', 'São Paulo', 'SP', 'Masculino', '2027-09-17', '2026-07-17', NULL, '2026-09-17', NULL, NULL, NULL),
(20, 'Tatiane Alves', 'Recepcionista', 'ativo', 'GS1', 'IGESP - Pronto Atendimento Santos', '2022-09-01', NULL, '1996-02-14', '44.555.666-7', '777.888.999-00', NULL, 'Solteiro(a)', NULL, 0, NULL, 'tatiane.a@email.com', '(13) 97777-6666', NULL, NULL, '11060-002', 'Avenida Ana Costa', '400', NULL, 'Gonzaga', 'Santos', 'SP', 'Feminino', NULL, '2026-02-17', NULL, '2026-09-17', NULL, NULL, NULL),
(21, 'Fernando Oliveira', 'Manobrista', 'inativo', 'Tranquility', 'Espaço HAOC', '2020-03-10', '2025-06-15', '1995-01-30', '34.123.567-8', '678.901.234-56', '654321098', 'Solteiro(a)', NULL, 0, NULL, 'fernando.o@email.com', '(11) 95432-1098', NULL, NULL, '01504-001', 'Rua Vergueiro', '1000', NULL, 'Liberdade', 'São Paulo', 'SP', 'Masculino', '2022-05-20', '2023-11-15', NULL, '2023-03-10', NULL, 'Baixo desempenho e faltas recorrentes.', 'Não'),
(22, 'Alexandre Peixoto', 'Manobrista', 'inativo', 'Tranquility', 'IGESP - Hospital Praia Grande', '2023-07-07', '2024-06-30', '1988-03-03', '10.111.222-3', '444.555.666-77', '334455667', 'Solteiro(a)', NULL, 0, NULL, 'alexandre.p@email.com', '(11) 95555-6666', NULL, NULL, '11700-100', 'Avenida Presidente Costa e Silva', '800', NULL, 'Boqueirão', 'Praia Grande', 'SP', 'Masculino', '2025-01-01', '2024-01-07', NULL, '2024-07-07', NULL, 'Pedido de demissão para outra oportunidade.', 'Sim'),
(23, 'Jorge Benario', 'Supervisor', 'inativo', 'Tranquility', 'Hapvida', '2019-11-11', '2023-12-20', '1980-01-01', '25.369.852-1', '741.852.963-22', '258963147', 'Casado(a)', '{\"nome\": \"Marta Benario\", \"data_nascimento\": \"1981-02-02\"}', 1, '[{\"nome\": \"Daniel\", \"data_nascimento\": \"2010-10-10\"}]', 'jorge.b@email.com', '(11) 98529-6314', NULL, NULL, '07190-100', 'Rodovia Hélio Smidt', 'S/N', NULL, 'Aeroporto', 'Guarulhos', 'SP', 'Masculino', '2023-01-15', '2023-05-11', NULL, '2022-11-11', NULL, 'Redução de quadro. Bom funcionário.', 'Avaliar'),
(24, 'William Bonner', 'Segurança', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '2018-03-25', '2023-10-05', '1984-06-12', '36.914.725-8', '963.741.852-55', '987654321', 'Casado(a)', '{\"nome\": \"Fátima Bernardes\", \"data_nascimento\": \"1985-07-13\"}', 0, NULL, 'william.b@email.com', '(11) 98765-4321', NULL, NULL, '03102-002', 'Rua Visconde de Parnaíba', '1600', NULL, 'Mooca', 'São Paulo', 'SP', 'Masculino', '2023-01-01', '2023-03-25', NULL, '2022-03-25', NULL, 'Aposentadoria.', 'Não'),
(25, 'Fátima Gomes', 'Recepcionista', 'inativo', 'Tranquility', 'Prevent Sênior - Hospital Madri', '2019-09-02', '2024-02-28', '1997-11-15', '14.258.369-1', '852.963.741-66', NULL, 'Solteiro(a)', NULL, 0, NULL, 'fatima.g@email.com', '(11) 93636-3636', NULL, NULL, '03102-002', 'Rua Visconde de Parnaíba', '1700', NULL, 'Mooca', 'São Paulo', 'SP', 'Feminino', NULL, '2023-09-02', NULL, '2023-09-02', NULL, 'Fim de contrato.', 'Sim'),
(26, 'Beatriz Almeida', 'Atendimento', 'inativo', 'GSM', 'Grupo Santa Marcelina Itaquera - Sede', '2022-02-20', '2025-08-17', '2000-12-10', '12.987.654-3', '901.234.567-89', NULL, 'Solteiro(a)', NULL, 0, NULL, 'beatriz.a@email.com', '(11) 92109-8765', NULL, NULL, '08270-070', 'Rua Santa Marcelina', '177', NULL, 'Vila Carmosina', 'São Paulo', 'SP', 'Feminino', NULL, '2024-01-10', NULL, '2024-02-20', NULL, 'Não se adaptou à cultura da empresa.', 'Não'),
(27, 'Eduardo Santos', 'Caixa', 'inativo', 'GSM', 'Grupo Santa Marcelina Itaquera - AME', '2021-04-12', '2024-05-30', '2002-07-07', '88.999.000-1', '222.333.444-55', NULL, 'Solteiro(a)', NULL, 0, NULL, 'eduardo.s@email.com', '(11) 97777-8888', NULL, NULL, '08270-070', 'Rua Santa Marcelina', '180', NULL, 'Vila Carmosina', 'São Paulo', 'SP', 'Masculino', NULL, '2023-10-01', NULL, '2023-04-12', NULL, 'Abandono de emprego.', 'Não'),
(28, 'Vanessa Ramos', 'Atendimento', 'inativo', 'GSM', 'Grupo Santa Marcelina Regionais - Hospital Cidade Tiradentes', '2021-06-14', '2024-01-15', '1999-07-19', '36.147.258-3', '963.852.741-11', NULL, 'Solteiro(a)', NULL, 0, NULL, 'vanessa.r@email.com', '(11) 96396-3963', NULL, NULL, '08471-410', 'Avenida dos Metalúrgicos', '2300', NULL, 'Cidade Tiradentes', 'São Paulo', 'SP', 'Feminino', NULL, '2023-06-14', NULL, '2023-06-14', NULL, 'Mudança de carreira.', 'Sim'),
(29, 'Otávio Mesquita', 'Gerente Regional', 'inativo', 'GSM', 'Grupo Santa Marcelina Itaquera - Sede', '2015-01-20', '2022-11-30', '1975-04-16', '14.725.836-9', '852.741.963-33', '369852147', 'Divorciado(a)', NULL, 2, '[{\"nome\": \"Carla\", \"data_nascimento\": \"2000-01-01\"}, {\"nome\": \"Pedro\", \"data_nascimento\": \"2003-03-03\"}]', 'otavio.m@email.com', '(11) 98585-8585', NULL, NULL, '08270-070', 'Rua Santa Marcelina', '177', NULL, 'Vila Carmosina', 'São Paulo', 'SP', 'Masculino', '2022-06-01', '2022-01-20', NULL, '2021-01-20', NULL, 'Reestruturação do setor.', 'Avaliar'),
(30, 'Carolina Diegues', 'Analista de RH', 'inativo', 'GSM', 'Grupo Santa Marcelina Itaquera - Sede', '2020-08-03', '2024-03-10', '1994-09-28', '25.836.914-7', '741.963.852-44', NULL, 'Solteiro(a)', NULL, 0, NULL, 'carolina.d@email.com', '(11) 91425-3678', NULL, NULL, '08270-070', 'Rua Santa Marcelina', '177', NULL, 'Vila Carmosina', 'São Paulo', 'SP', 'Feminino', NULL, '2023-08-03', NULL, '2023-08-03', NULL, 'Recebeu proposta melhor.', 'Sim'),
(31, 'Adriana Lima', 'Líder de Caixa', 'inativo', 'Protector', 'IGESP - Pronto Atendimento Santo André', '2019-05-20', '2025-07-30', '1991-03-15', '88.777.666-5', '556.657.758-09', NULL, 'Divorciado(a)', NULL, 1, '[{\"nome\": \"Alice\", \"data_nascimento\": \"2015-06-01\"}]', 'adriana.l@email.com', '(11) 98877-3344', NULL, NULL, '09015-020', 'Avenida Dom Pedro II', '510', NULL, 'Jardim', 'Santo André', 'SP', 'Feminino', NULL, '2025-05-20', NULL, '2025-05-20', NULL, 'Reestruturação de equipe e corte de custos.', 'Avaliar'),
(32, 'Julio Cesar Almeida', 'Líder de Atendimento', 'inativo', 'Protector', 'Grupo Santa Marcelina Regionais - Hospital Itaim', '2022-08-15', '2025-01-01', '1993-04-12', '33.222.111-0', '001.002.003-04', '123456789', 'Solteiro(a)', NULL, 0, NULL, 'julio.cesar@email.com', '(11) 98765-1122', NULL, NULL, '08121-000', 'Avenida Marechal Tito', '6100', NULL, 'Itaim Paulista', 'São Paulo', 'SP', 'Masculino', '2025-02-15', '2024-08-15', NULL, '2024-08-15', NULL, 'Problemas de relacionamento com a equipe.', 'Não'),
(33, 'Vanessa Martins', 'Recepcionista', 'inativo', 'Protector', 'Grupo Santa Marcelina Regionais - Hospital Itaquá', '2023-01-09', '2025-08-20', '2002-05-21', '44.333.222-1', '112.213.314-05', NULL, 'Solteiro(a)', NULL, 0, NULL, 'vanessa.m@email.com', '(11) 95544-3322', NULL, NULL, '08577-000', 'Rua Estados Unidos', '110', NULL, 'Vila Zeferina', 'Itaquaquecetuba', 'SP', 'Feminino', NULL, '2025-01-09', NULL, '2025-01-09', NULL, 'Pedido de demissão para mudança de cidade.', 'Sim'),
(34, 'Leandro Barbosa', 'Manobrista', 'inativo', 'Protector', 'Grupo Santa Marcelina Regionais - Hospital Neomater SBC', '2023-10-02', '2025-09-01', '1995-11-18', '55.444.333-2', '223.324.425-06', '987654321', 'Casado(a)', '{\"nome\": \"Cláudia Barbosa\", \"data_nascimento\": \"1996-10-05\"}', 2, '[{\"nome\": \"Davi\", \"data_nascimento\": \"2022-08-10\"}, {\"nome\": \"Heloísa\", \"data_nascimento\": \"2024-01-20\"}]', 'leandro.b@email.com', '(11) 93322-1100', NULL, NULL, '09710-011', 'Rua Marechal Deodoro', '1210', NULL, 'Centro', 'São Bernardo do Campo', 'SP', 'Masculino', '2026-10-02', '2024-10-02', NULL, '2024-10-02', NULL, 'Fim de contrato.', 'Avaliar'),
(35, 'Fernanda Gonçalves', 'Auxiliar Administrativo', 'inativo', 'Protector', 'Grupo Santa Marcelina Regionais - Hospital Cidade Tiradentes', '2024-01-22', '2025-07-22', '1999-06-03', '66.555.444-3', '334.435.536-07', NULL, 'Solteiro(a)', NULL, 0, NULL, 'fernanda.g@email.com', '(11) 98877-6655', NULL, NULL, '08471-410', 'Avenida dos Metalúrgicos', '2310', NULL, 'Cidade Tiradentes', 'São Paulo', 'SP', 'Feminino', NULL, '2025-01-22', NULL, '2025-01-22', NULL, 'Não cumpriu o período de experiência.', 'Não'),
(36, 'Diego Souza', 'Manobrista', 'inativo', 'GS1', 'São Carlos - Santa Casa', '2024-03-01', '2025-02-28', '2004-02-10', '77.666.555-4', '445.546.647-08', '776655443', 'Solteiro(a)', NULL, 0, NULL, 'diego.s@email.com', '(16) 94433-2211', NULL, NULL, '13560-231', 'Rua Paulino dos Santos', '510', NULL, 'Centro', 'São Carlos', 'SP', 'Masculino', '2026-03-01', '2025-03-01', NULL, '2025-03-01', NULL, 'Recebeu outra proposta.', 'Sim'),
(37, 'Sérgio Lopes', 'Manobrista Noturno', 'inativo', 'GS1', 'São Carlos - CID', '2021-08-19', '2024-08-18', '1992-06-08', '66.777.888-9', '999.000.111-22', '221133445', 'Divorciado(a)', NULL, 0, NULL, 'sergio.l@email.com', '(16) 95555-4444', NULL, NULL, '13566-590', 'Passeio dos Flamboyants', '70', NULL, 'Parque Faber Castell I', 'São Carlos', 'SP', 'Masculino', '2024-08-19', '2023-08-19', NULL, '2023-08-19', NULL, 'Redução de quadro.', 'Avaliar'),
(38, 'Helena Martins', 'Recepcionista', 'inativo', 'GS1', 'São Carlos - Onovolab', '2023-11-05', '2025-05-04', '1997-01-20', '77.888.999-0', '000.111.222-33', NULL, 'Solteiro(a)', NULL, 0, NULL, 'helena.m@email.com', '(16) 94444-3333', NULL, NULL, '13560-251', 'Avenida Doutor Carlos Botelho', '1810', NULL, 'Centro', 'São Carlos', 'SP', 'Feminino', NULL, '2024-11-05', NULL, '2024-11-05', NULL, 'Insatisfação com o salário.', 'Avaliar'),
(39, 'Anderson Lima', 'Porteiro', 'inativo', 'GS1', 'IGESP - Pronto Atendimento Santos', '2020-10-20', '2025-04-19', '1986-07-14', '88.999.000-1', '111.222.333-44', NULL, 'Casado(a)', '{\"nome\": \"Vanessa Lima\", \"data_nascimento\": \"1988-08-15\"}', 1, '[{\"nome\": \"Pedro\", \"data_nascimento\": \"2018-12-25\"}]', 'anderson.l@email.com', '(13) 93333-2222', NULL, NULL, '11060-002', 'Avenida Ana Costa', '410', NULL, 'Gonzaga', 'Santos', 'SP', 'Masculino', NULL, '2024-10-20', NULL, '2024-10-20', NULL, 'Mudança de cidade.', 'Sim'),
(40, 'Gabriela Azevedo', 'Auxiliar de Serviços Gerais', 'inativo', 'GS1', 'IGESP - Hospital Praia Grande', '2023-01-30', '2025-01-29', '2001-05-18', '99.000.111-2', '222.333.444-55', NULL, 'Solteiro(a)', NULL, 0, NULL, 'gabriela.a@email.com', '(13) 92222-1111', NULL, NULL, '11702-050', 'Avenida Marechal Mallet', '510', NULL, 'Canto do Forte', 'Praia Grande', 'SP', 'Feminino', NULL, '2024-01-30', NULL, '2024-01-30', NULL, 'Justa causa - Faltas excessivas.', 'Não');

-- --------------------------------------------------------

--
-- Estrutura para tabela `pastas`
--

CREATE TABLE `pastas` (
  `id` int NOT NULL,
  `funcionario_id` int NOT NULL,
  `parent_id` int DEFAULT NULL COMMENT 'ID da pasta pai (se for uma subpasta)',
  `nome_pasta` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `pastas`
--

INSERT INTO `pastas` (`id`, `funcionario_id`, `parent_id`, `nome_pasta`) VALUES
(1, 1, NULL, 'Raiz'),
(2, 2, NULL, 'Raiz'),
(3, 3, NULL, 'Raiz'),
(4, 4, NULL, 'Raiz'),
(5, 5, NULL, 'Raiz'),
(6, 6, NULL, 'Raiz'),
(7, 7, NULL, 'Raiz'),
(8, 8, NULL, 'Raiz'),
(9, 9, NULL, 'Raiz'),
(10, 10, NULL, 'Raiz'),
(11, 11, NULL, 'Raiz'),
(12, 12, NULL, 'Raiz'),
(13, 13, NULL, 'Raiz'),
(14, 14, NULL, 'Raiz'),
(15, 15, NULL, 'Raiz'),
(16, 16, NULL, 'Raiz'),
(17, 17, NULL, 'Raiz'),
(18, 18, NULL, 'Raiz'),
(19, 19, NULL, 'Raiz'),
(20, 20, NULL, 'Raiz'),
(21, 21, NULL, 'Raiz'),
(22, 22, NULL, 'Raiz'),
(23, 23, NULL, 'Raiz'),
(24, 24, NULL, 'Raiz'),
(25, 25, NULL, 'Raiz'),
(26, 26, NULL, 'Raiz'),
(27, 27, NULL, 'Raiz'),
(28, 28, NULL, 'Raiz'),
(29, 29, NULL, 'Raiz'),
(30, 30, NULL, 'Raiz'),
(31, 31, NULL, 'Raiz'),
(32, 32, NULL, 'Raiz'),
(33, 33, NULL, 'Raiz'),
(34, 34, NULL, 'Raiz'),
(35, 35, NULL, 'Raiz'),
(36, 36, NULL, 'Raiz'),
(37, 37, NULL, 'Raiz'),
(38, 38, NULL, 'Raiz'),
(39, 39, NULL, 'Raiz'),
(40, 40, NULL, 'Raiz'),
(64, 40, 40, 'Atestado'),
(65, 39, 39, 'Atestado'),
(66, 38, 38, 'Atestado'),
(67, 37, 37, 'Atestado'),
(68, 36, 36, 'Atestado'),
(69, 35, 35, 'Atestado'),
(70, 34, 34, 'Atestado'),
(71, 33, 33, 'Atestado'),
(72, 32, 32, 'Atestado'),
(73, 31, 31, 'Atestado'),
(74, 30, 30, 'Atestado'),
(75, 29, 29, 'Atestado'),
(76, 28, 28, 'Atestado'),
(77, 27, 27, 'Atestado'),
(78, 26, 26, 'Atestado'),
(79, 25, 25, 'Atestado'),
(80, 24, 24, 'Atestado'),
(81, 23, 23, 'Atestado'),
(82, 22, 22, 'Atestado'),
(83, 21, 21, 'Atestado'),
(84, 20, 20, 'Atestado'),
(85, 19, 19, 'Atestado'),
(86, 18, 18, 'Atestado'),
(87, 17, 17, 'Atestado'),
(88, 16, 16, 'Atestado'),
(89, 15, 15, 'Atestado'),
(90, 14, 14, 'Atestado'),
(91, 13, 13, 'Atestado'),
(92, 12, 12, 'Atestado'),
(93, 11, 11, 'Atestado'),
(94, 10, 10, 'Atestado'),
(95, 9, 9, 'Atestado'),
(96, 8, 8, 'Atestado'),
(97, 7, 7, 'Atestado'),
(98, 6, 6, 'Atestado'),
(99, 5, 5, 'Atestado'),
(100, 4, 4, 'Atestado'),
(101, 3, 3, 'Atestado'),
(102, 2, 2, 'Atestado'),
(103, 1, 1, 'Atestado'),
(104, 40, 40, 'Contrato'),
(105, 39, 39, 'Contrato'),
(106, 38, 38, 'Contrato'),
(107, 37, 37, 'Contrato'),
(108, 36, 36, 'Contrato'),
(109, 35, 35, 'Contrato'),
(110, 34, 34, 'Contrato'),
(111, 33, 33, 'Contrato'),
(112, 32, 32, 'Contrato'),
(113, 31, 31, 'Contrato'),
(114, 30, 30, 'Contrato'),
(115, 29, 29, 'Contrato'),
(116, 28, 28, 'Contrato'),
(117, 27, 27, 'Contrato'),
(118, 26, 26, 'Contrato'),
(119, 25, 25, 'Contrato'),
(120, 24, 24, 'Contrato'),
(121, 23, 23, 'Contrato'),
(122, 22, 22, 'Contrato'),
(123, 21, 21, 'Contrato'),
(124, 20, 20, 'Contrato'),
(125, 19, 19, 'Contrato'),
(126, 18, 18, 'Contrato'),
(127, 17, 17, 'Contrato'),
(128, 16, 16, 'Contrato'),
(129, 15, 15, 'Contrato'),
(130, 14, 14, 'Contrato'),
(131, 13, 13, 'Contrato'),
(132, 12, 12, 'Contrato'),
(133, 11, 11, 'Contrato'),
(134, 10, 10, 'Contrato'),
(135, 9, 9, 'Contrato'),
(136, 8, 8, 'Contrato'),
(137, 7, 7, 'Contrato'),
(138, 6, 6, 'Contrato'),
(139, 5, 5, 'Contrato'),
(140, 4, 4, 'Contrato'),
(141, 3, 3, 'Contrato'),
(142, 2, 2, 'Contrato'),
(143, 1, 1, 'Contrato'),
(144, 40, 40, 'Disciplinar'),
(145, 39, 39, 'Disciplinar'),
(146, 38, 38, 'Disciplinar'),
(147, 37, 37, 'Disciplinar'),
(148, 36, 36, 'Disciplinar'),
(149, 35, 35, 'Disciplinar'),
(150, 34, 34, 'Disciplinar'),
(151, 33, 33, 'Disciplinar'),
(152, 32, 32, 'Disciplinar'),
(153, 31, 31, 'Disciplinar'),
(154, 30, 30, 'Disciplinar'),
(155, 29, 29, 'Disciplinar'),
(156, 28, 28, 'Disciplinar'),
(157, 27, 27, 'Disciplinar'),
(158, 26, 26, 'Disciplinar'),
(159, 25, 25, 'Disciplinar'),
(160, 24, 24, 'Disciplinar'),
(161, 23, 23, 'Disciplinar'),
(162, 22, 22, 'Disciplinar'),
(163, 21, 21, 'Disciplinar'),
(164, 20, 20, 'Disciplinar'),
(165, 19, 19, 'Disciplinar'),
(166, 18, 18, 'Disciplinar'),
(167, 17, 17, 'Disciplinar'),
(168, 16, 16, 'Disciplinar'),
(169, 15, 15, 'Disciplinar'),
(170, 14, 14, 'Disciplinar'),
(171, 13, 13, 'Disciplinar'),
(172, 12, 12, 'Disciplinar'),
(173, 11, 11, 'Disciplinar'),
(174, 10, 10, 'Disciplinar'),
(175, 9, 9, 'Disciplinar'),
(176, 8, 8, 'Disciplinar'),
(177, 7, 7, 'Disciplinar'),
(178, 6, 6, 'Disciplinar'),
(179, 5, 5, 'Disciplinar'),
(180, 4, 4, 'Disciplinar'),
(181, 3, 3, 'Disciplinar'),
(182, 2, 2, 'Disciplinar'),
(183, 1, 1, 'Disciplinar'),
(184, 40, 40, 'Documentos Pessoais'),
(185, 39, 39, 'Documentos Pessoais'),
(186, 38, 38, 'Documentos Pessoais'),
(187, 37, 37, 'Documentos Pessoais'),
(188, 36, 36, 'Documentos Pessoais'),
(189, 35, 35, 'Documentos Pessoais'),
(190, 34, 34, 'Documentos Pessoais'),
(191, 33, 33, 'Documentos Pessoais'),
(192, 32, 32, 'Documentos Pessoais'),
(193, 31, 31, 'Documentos Pessoais'),
(194, 30, 30, 'Documentos Pessoais'),
(195, 29, 29, 'Documentos Pessoais'),
(196, 28, 28, 'Documentos Pessoais'),
(197, 27, 27, 'Documentos Pessoais'),
(198, 26, 26, 'Documentos Pessoais'),
(199, 25, 25, 'Documentos Pessoais'),
(200, 24, 24, 'Documentos Pessoais'),
(201, 23, 23, 'Documentos Pessoais'),
(202, 22, 22, 'Documentos Pessoais'),
(203, 21, 21, 'Documentos Pessoais'),
(204, 20, 20, 'Documentos Pessoais'),
(205, 19, 19, 'Documentos Pessoais'),
(206, 18, 18, 'Documentos Pessoais'),
(207, 17, 17, 'Documentos Pessoais'),
(208, 16, 16, 'Documentos Pessoais'),
(209, 15, 15, 'Documentos Pessoais'),
(210, 14, 14, 'Documentos Pessoais'),
(211, 13, 13, 'Documentos Pessoais'),
(212, 12, 12, 'Documentos Pessoais'),
(213, 11, 11, 'Documentos Pessoais'),
(214, 10, 10, 'Documentos Pessoais'),
(215, 9, 9, 'Documentos Pessoais'),
(216, 8, 8, 'Documentos Pessoais'),
(217, 7, 7, 'Documentos Pessoais'),
(218, 6, 6, 'Documentos Pessoais'),
(219, 5, 5, 'Documentos Pessoais'),
(220, 4, 4, 'Documentos Pessoais'),
(221, 3, 3, 'Documentos Pessoais'),
(222, 2, 2, 'Documentos Pessoais'),
(223, 1, 1, 'Documentos Pessoais'),
(224, 40, 40, 'Férias'),
(225, 39, 39, 'Férias'),
(226, 38, 38, 'Férias'),
(227, 37, 37, 'Férias'),
(228, 36, 36, 'Férias'),
(229, 35, 35, 'Férias'),
(230, 34, 34, 'Férias'),
(231, 33, 33, 'Férias'),
(232, 32, 32, 'Férias'),
(233, 31, 31, 'Férias'),
(234, 30, 30, 'Férias'),
(235, 29, 29, 'Férias'),
(236, 28, 28, 'Férias'),
(237, 27, 27, 'Férias'),
(238, 26, 26, 'Férias'),
(239, 25, 25, 'Férias'),
(240, 24, 24, 'Férias'),
(241, 23, 23, 'Férias'),
(242, 22, 22, 'Férias'),
(243, 21, 21, 'Férias'),
(244, 20, 20, 'Férias'),
(245, 19, 19, 'Férias'),
(246, 18, 18, 'Férias'),
(247, 17, 17, 'Férias'),
(248, 16, 16, 'Férias'),
(249, 15, 15, 'Férias'),
(250, 14, 14, 'Férias'),
(251, 13, 13, 'Férias'),
(252, 12, 12, 'Férias'),
(253, 11, 11, 'Férias'),
(254, 10, 10, 'Férias'),
(255, 9, 9, 'Férias'),
(256, 8, 8, 'Férias'),
(257, 7, 7, 'Férias'),
(258, 6, 6, 'Férias'),
(259, 5, 5, 'Férias'),
(260, 4, 4, 'Férias'),
(261, 3, 3, 'Férias'),
(262, 2, 2, 'Férias'),
(263, 1, 1, 'Férias'),
(264, 40, 40, 'Holerites'),
(265, 39, 39, 'Holerites'),
(266, 38, 38, 'Holerites'),
(267, 37, 37, 'Holerites'),
(268, 36, 36, 'Holerites'),
(269, 35, 35, 'Holerites'),
(270, 34, 34, 'Holerites'),
(271, 33, 33, 'Holerites'),
(272, 32, 32, 'Holerites'),
(273, 31, 31, 'Holerites'),
(274, 30, 30, 'Holerites'),
(275, 29, 29, 'Holerites'),
(276, 28, 28, 'Holerites'),
(277, 27, 27, 'Holerites'),
(278, 26, 26, 'Holerites'),
(279, 25, 25, 'Holerites'),
(280, 24, 24, 'Holerites'),
(281, 23, 23, 'Holerites'),
(282, 22, 22, 'Holerites'),
(283, 21, 21, 'Holerites'),
(284, 20, 20, 'Holerites'),
(285, 19, 19, 'Holerites'),
(286, 18, 18, 'Holerites'),
(287, 17, 17, 'Holerites'),
(288, 16, 16, 'Holerites'),
(289, 15, 15, 'Holerites'),
(290, 14, 14, 'Holerites'),
(291, 13, 13, 'Holerites'),
(292, 12, 12, 'Holerites'),
(293, 11, 11, 'Holerites'),
(294, 10, 10, 'Holerites'),
(295, 9, 9, 'Holerites'),
(296, 8, 8, 'Holerites'),
(297, 7, 7, 'Holerites'),
(298, 6, 6, 'Holerites'),
(299, 5, 5, 'Holerites'),
(300, 4, 4, 'Holerites'),
(301, 3, 3, 'Holerites'),
(302, 2, 2, 'Holerites'),
(303, 1, 1, 'Holerites'),
(304, 40, 40, 'Ponto'),
(305, 39, 39, 'Ponto'),
(306, 38, 38, 'Ponto'),
(307, 37, 37, 'Ponto'),
(308, 36, 36, 'Ponto'),
(309, 35, 35, 'Ponto'),
(310, 34, 34, 'Ponto'),
(311, 33, 33, 'Ponto'),
(312, 32, 32, 'Ponto'),
(313, 31, 31, 'Ponto'),
(314, 30, 30, 'Ponto'),
(315, 29, 29, 'Ponto'),
(316, 28, 28, 'Ponto'),
(317, 27, 27, 'Ponto'),
(318, 26, 26, 'Ponto'),
(319, 25, 25, 'Ponto'),
(320, 24, 24, 'Ponto'),
(321, 23, 23, 'Ponto'),
(322, 22, 22, 'Ponto'),
(323, 21, 21, 'Ponto'),
(324, 20, 20, 'Ponto'),
(325, 19, 19, 'Ponto'),
(326, 18, 18, 'Ponto'),
(327, 17, 17, 'Ponto'),
(328, 16, 16, 'Ponto'),
(329, 15, 15, 'Ponto'),
(330, 14, 14, 'Ponto'),
(331, 13, 13, 'Ponto'),
(332, 12, 12, 'Ponto'),
(333, 11, 11, 'Ponto'),
(334, 10, 10, 'Ponto'),
(335, 9, 9, 'Ponto'),
(336, 8, 8, 'Ponto'),
(337, 7, 7, 'Ponto'),
(338, 6, 6, 'Ponto'),
(339, 5, 5, 'Ponto'),
(340, 4, 4, 'Ponto'),
(341, 3, 3, 'Ponto'),
(342, 2, 2, 'Ponto'),
(343, 1, 1, 'Ponto'),
(344, 40, 40, 'Sinistro'),
(345, 39, 39, 'Sinistro'),
(346, 38, 38, 'Sinistro'),
(347, 37, 37, 'Sinistro'),
(348, 36, 36, 'Sinistro'),
(349, 35, 35, 'Sinistro'),
(350, 34, 34, 'Sinistro'),
(351, 33, 33, 'Sinistro'),
(352, 32, 32, 'Sinistro'),
(353, 31, 31, 'Sinistro'),
(354, 30, 30, 'Sinistro'),
(355, 29, 29, 'Sinistro'),
(356, 28, 28, 'Sinistro'),
(357, 27, 27, 'Sinistro'),
(358, 26, 26, 'Sinistro'),
(359, 25, 25, 'Sinistro'),
(360, 24, 24, 'Sinistro'),
(361, 23, 23, 'Sinistro'),
(362, 22, 22, 'Sinistro'),
(363, 21, 21, 'Sinistro'),
(364, 20, 20, 'Sinistro'),
(365, 19, 19, 'Sinistro'),
(366, 18, 18, 'Sinistro'),
(367, 17, 17, 'Sinistro'),
(368, 16, 16, 'Sinistro'),
(369, 15, 15, 'Sinistro'),
(370, 14, 14, 'Sinistro'),
(371, 13, 13, 'Sinistro'),
(372, 12, 12, 'Sinistro'),
(373, 11, 11, 'Sinistro'),
(374, 10, 10, 'Sinistro'),
(375, 9, 9, 'Sinistro'),
(376, 8, 8, 'Sinistro'),
(377, 7, 7, 'Sinistro'),
(378, 6, 6, 'Sinistro'),
(379, 5, 5, 'Sinistro'),
(380, 4, 4, 'Sinistro'),
(381, 3, 3, 'Sinistro'),
(382, 2, 2, 'Sinistro'),
(383, 1, 1, 'Sinistro'),
(384, 40, 40, 'Treinamento'),
(385, 39, 39, 'Treinamento'),
(386, 38, 38, 'Treinamento'),
(387, 37, 37, 'Treinamento'),
(388, 36, 36, 'Treinamento'),
(389, 35, 35, 'Treinamento'),
(390, 34, 34, 'Treinamento'),
(391, 33, 33, 'Treinamento'),
(392, 32, 32, 'Treinamento'),
(393, 31, 31, 'Treinamento'),
(394, 30, 30, 'Treinamento'),
(395, 29, 29, 'Treinamento'),
(396, 28, 28, 'Treinamento'),
(397, 27, 27, 'Treinamento'),
(398, 26, 26, 'Treinamento'),
(399, 25, 25, 'Treinamento'),
(400, 24, 24, 'Treinamento'),
(401, 23, 23, 'Treinamento'),
(402, 22, 22, 'Treinamento'),
(403, 21, 21, 'Treinamento'),
(404, 20, 20, 'Treinamento'),
(405, 19, 19, 'Treinamento'),
(406, 18, 18, 'Treinamento'),
(407, 17, 17, 'Treinamento'),
(408, 16, 16, 'Treinamento'),
(409, 15, 15, 'Treinamento'),
(410, 14, 14, 'Treinamento'),
(411, 13, 13, 'Treinamento'),
(412, 12, 12, 'Treinamento'),
(413, 11, 11, 'Treinamento'),
(414, 10, 10, 'Treinamento'),
(415, 9, 9, 'Treinamento'),
(416, 8, 8, 'Treinamento'),
(417, 7, 7, 'Treinamento'),
(418, 6, 6, 'Treinamento'),
(419, 5, 5, 'Treinamento'),
(420, 4, 4, 'Treinamento'),
(421, 3, 3, 'Treinamento'),
(422, 2, 2, 'Treinamento'),
(423, 1, 1, 'Treinamento'),
(424, 40, 40, 'Outros'),
(425, 39, 39, 'Outros'),
(426, 38, 38, 'Outros'),
(427, 37, 37, 'Outros'),
(428, 36, 36, 'Outros'),
(429, 35, 35, 'Outros'),
(430, 34, 34, 'Outros'),
(431, 33, 33, 'Outros'),
(432, 32, 32, 'Outros'),
(433, 31, 31, 'Outros'),
(434, 30, 30, 'Outros'),
(435, 29, 29, 'Outros'),
(436, 28, 28, 'Outros'),
(437, 27, 27, 'Outros'),
(438, 26, 26, 'Outros'),
(439, 25, 25, 'Outros'),
(440, 24, 24, 'Outros'),
(441, 23, 23, 'Outros'),
(442, 22, 22, 'Outros'),
(443, 21, 21, 'Outros'),
(444, 20, 20, 'Outros'),
(445, 19, 19, 'Outros'),
(446, 18, 18, 'Outros'),
(447, 17, 17, 'Outros'),
(448, 16, 16, 'Outros'),
(449, 15, 15, 'Outros'),
(450, 14, 14, 'Outros'),
(451, 13, 13, 'Outros'),
(452, 12, 12, 'Outros'),
(453, 11, 11, 'Outros'),
(454, 10, 10, 'Outros'),
(455, 9, 9, 'Outros'),
(456, 8, 8, 'Outros'),
(457, 7, 7, 'Outros'),
(458, 6, 6, 'Outros'),
(459, 5, 5, 'Outros'),
(460, 4, 4, 'Outros'),
(461, 3, 3, 'Outros'),
(462, 2, 2, 'Outros'),
(463, 1, 1, 'Outros');

-- --------------------------------------------------------

--
-- Estrutura para tabela `status_diario`
--

CREATE TABLE `status_diario` (
  `id` int NOT NULL,
  `data` date NOT NULL,
  `unidade` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `presentes` int DEFAULT '0',
  `ferias` int DEFAULT '0',
  `atestado` int DEFAULT '0',
  `folga` int DEFAULT '0',
  `falta_injustificada` int DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Índices para tabelas despejadas
--

--
-- Índices de tabela `administradores`
--
ALTER TABLE `administradores`
  ADD PRIMARY KEY (`id`);

--
-- Índices de tabela `documentos`
--
ALTER TABLE `documentos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `pasta_id` (`pasta_id`);

--
-- Índices de tabela `funcionarios`
--
ALTER TABLE `funcionarios`
  ADD PRIMARY KEY (`id`);

--
-- Índices de tabela `pastas`
--
ALTER TABLE `pastas`
  ADD PRIMARY KEY (`id`),
  ADD KEY `funcionario_id` (`funcionario_id`);

--
-- Índices de tabela `status_diario`
--
ALTER TABLE `status_diario`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `data_unidade_unique` (`data`,`unidade`);

--
-- AUTO_INCREMENT para tabelas despejadas
--

--
-- AUTO_INCREMENT de tabela `administradores`
--
ALTER TABLE `administradores`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de tabela `documentos`
--
ALTER TABLE `documentos`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `funcionarios`
--
ALTER TABLE `funcionarios`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- AUTO_INCREMENT de tabela `pastas`
--
ALTER TABLE `pastas`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=575;

--
-- AUTO_INCREMENT de tabela `status_diario`
--
ALTER TABLE `status_diario`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- Restrições para tabelas despejadas
--

--
-- Restrições para tabelas `documentos`
--
ALTER TABLE `documentos`
  ADD CONSTRAINT `documentos_ibfk_1` FOREIGN KEY (`pasta_id`) REFERENCES `pastas` (`id`) ON DELETE CASCADE;

--
-- Restrições para tabelas `pastas`
--
ALTER TABLE `pastas`
  ADD CONSTRAINT `pastas_ibfk_1` FOREIGN KEY (`funcionario_id`) REFERENCES `funcionarios` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

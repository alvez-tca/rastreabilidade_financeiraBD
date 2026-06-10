-- ==========================================
-- 1. ESTRUTURA (DDL) - CRIAÇÃO DAS TABELAS
-- ==========================================

CREATE TABLE CLIENTE (
    cpf VARCHAR(11) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    contato VARCHAR(100)
);

CREATE TABLE VENDEDOR (
    matricula INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
);

CREATE TABLE FORNECEDOR (
    cnpj VARCHAR(14) PRIMARY KEY,
    nome_empresa VARCHAR(100) NOT NULL,
    contato VARCHAR(100)
);

CREATE TABLE SERVICO (
    id_servico INT PRIMARY KEY,
    descricao VARCHAR(150) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    cnpj VARCHAR(14) NOT NULL,
    FOREIGN KEY (cnpj) REFERENCES FORNECEDOR(cnpj) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE PACOTE (
    id_pacote INT PRIMARY KEY,
    nome_pacote VARCHAR(100) NOT NULL,
    descricao VARCHAR(200)
);

CREATE TABLE PACOTE_SERVICO (
    id_pacote INT,
    id_servico INT,
    PRIMARY KEY (id_pacote, id_servico),
    FOREIGN KEY (id_pacote) REFERENCES PACOTE(id_pacote) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_servico) REFERENCES SERVICO(id_servico) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE VENDA (
    id_venda INT PRIMARY KEY,
    data_venda DATE NOT NULL,
    valor_total DECIMAL(10,2) NOT NULL,
    cpf VARCHAR(11) NOT NULL,
    matricula INT NOT NULL,
    FOREIGN KEY (cpf) REFERENCES CLIENTE(cpf) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (matricula) REFERENCES VENDEDOR(matricula) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE RECEBIMENTO_CLIENTE (
    id_recebimento INT PRIMARY KEY,
    forma_pagamento VARCHAR(30) NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    status_recebimento VARCHAR(20) NOT NULL,
    id_venda INT NOT NULL UNIQUE,
    FOREIGN KEY (id_venda) REFERENCES VENDA(id_venda) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE COMISSAO (
    id_comissao INT PRIMARY KEY,
    valor DECIMAL(10,2) NOT NULL,
    id_venda INT NOT NULL UNIQUE,
    FOREIGN KEY (id_venda) REFERENCES VENDA(id_venda) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE PAGAMENTO_FORNECEDOR (
    id_pagamento INT PRIMARY KEY,
    valor DECIMAL(10,2) NOT NULL,
    data_limite DATE NOT NULL,
    id_venda INT NOT NULL UNIQUE,
    cnpj VARCHAR(14) NOT NULL,
    FOREIGN KEY (id_venda) REFERENCES VENDA(id_venda) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (cnpj) REFERENCES FORNECEDOR(cnpj) ON DELETE RESTRICT ON UPDATE CASCADE
);


-- ==========================================
-- 2. DADOS INICIAIS (DML) - POPULANDO O BANCO
-- ==========================================

-- Inserindo Clientes, Vendedores e Fornecedores
INSERT INTO CLIENTE VALUES ('11122233344', 'Carlos Silva', 'carlos@email.com');
INSERT INTO VENDEDOR VALUES (5001, 'Ana Costa');
INSERT INTO FORNECEDOR VALUES ('12345678000199', 'Operadora Turística Mundial', 'contato@mundial.com');

-- Inserindo um Serviço associado ao Fornecedor
INSERT INTO SERVICO VALUES (10, 'Tour Completo em Paris', 'Passeio Cultural', '12345678000199');

-- Inserindo uma Venda efetuada
INSERT INTO VENDA VALUES (100, '2026-06-09', 1500.00, '11122233344', 5001);

-- Gerando os lançamentos financeiros obrigatórios da Venda (Rastreabilidade)
INSERT INTO RECEBIMENTO_CLIENTE VALUES (200, 'Cartão de Crédito', 1500.00, 'PAGO', 100);
INSERT INTO COMISSAO VALUES (300, 150.00, 100); -- 10% do valor da venda
INSERT INTO PAGAMENTO_FORNECEDOR VALUES (400, 1100.00, '2026-06-20', 100, '12345678000199');


-- ==========================================
-- 3. CONSULTA (DQL) - RASTREABILIDADE FINANCEIRA
-- ==========================================

SELECT 
    V.data_venda AS "Data da Venda",
    VD.nome AS "Nome do Vendedor",
    C.nome AS "Nome do Cliente",
    RC.valor AS "Valor Total Pago pelo Cliente",
    PF.valor AS "Valor de Custo do Fornecedor",
    CO.valor AS "Valor da Comissão do Consultor"
FROM VENDA V
INNER JOIN VENDEDOR DB_VENDEDOR ON V.matricula = VD.matricula
INNER JOIN CLIENTE C ON V.cpf = C.cpf
INNER JOIN RECEBIMENTO_CLIENTE RC ON V.id_venda = RC.id_venda
INNER JOIN COMISSAO CO ON V.id_venda = CO.id_venda
INNER JOIN PAGAMENTO_FORNECEDOR PF ON V.id_venda = PF.id_venda;

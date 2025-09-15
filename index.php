<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Painel RH - Tranquility Parking Lot</title>
    <link rel="icon" href="assets/imagens/imagens.png" sizes="32x32" />
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body>
    
    <div id="login-container">
        <div class="login-box">
            <img src="assets/imagens/imagens.png" alt="Tranquility Parking Lot Logo" class="login-logo">
            <h2>Painel de Gestão RH</h2>
            <p class="login-subtitle">Acesse com suas credenciais.</p>
            <form id="login-form">
                <div class="input-group">
                    <i class="fas fa-user"></i>
                    <input type="text" id="username" placeholder="Usuário (admin)" required>
                </div>
                <div class="input-group">
                    <i class="fas fa-lock"></i>
                    <input type="password" id="password" placeholder="Senha (admin)" required>
                    <button type="button" id="toggle-password" class="toggle-password-btn">
                        <i class="fas fa-eye"></i>
                    </button>
                </div>
                <button type="submit" class="login-button">Entrar <i class="fas fa-arrow-right"></i></button>
                <p id="login-error" class="login-error-message"></p>
            </form>
            <div class="login-footer-links">
                <a href="#" id="forgot-password-link">Esqueci minha senha</a>
            </div>
        </div>
    </div>

    <div id="app-wrapper" class="hidden">
        <header>
            <div class="container">
                <img src="assets/imagens/imagens.png" alt="Tranquility Parking Lot Logo" class="logo">
                <nav id="main-nav">
                    <ul>
                        <li><a href="#funcionarios" id="nav-funcionarios" class="active">Ativos</a></li>
                        <li><a href="#inativos" id="nav-inativos">Inativos</a></li>
                        <li><a href="#status" id="nav-status">Dashboard</a></li>
                        <li><a href="https://tparking.com.br/" target="_blank" class="home-link">Site Principal</a></li>
                    </ul>
                </nav>
                <div class="header-actions">
                    <button id="theme-toggle" title="Alternar tema">
                        <i class="fas fa-moon"></i>
                    </button>
                    <button id="menu-toggle" class="menu-toggle"><i class="fas fa-bars"></i></button>
                </div>
            </div>
        </header>
        <main>
            <section id="funcionarios-section" class="content-section active">
                <div class="container">
                    <div class="section-header-actions">
                        <div class="section-header"> <i class="fa-solid fa-users"></i> <h2>Colaboradores Ativos</h2></div>
                        <button class="add-btn" data-status="ativo"><i class="fas fa-plus"></i> Adicionar Funcionário</button>
                    </div>
                    <div class="filtros-container">
                        <div class="filtros-principais">
                            <div class="filter-group"><i class="fa-solid fa-magnifying-glass"></i><input type="text" class="search-input" placeholder="Pesquisar por nome..."></div>
                            <div class="filter-group"><i class="fa-solid fa-building"></i><select class="location-filter"></select></div>
                            <button class="advanced-filter-btn">
                                <i class="fas fa-sliders-h"></i> Filtros Avançados <span class="filter-count"></span>
                            </button>
                        </div>
                        <div class="filtros-avancados">
                            <div class="grid">
                                <div class="filter-group">
                                    <label><i class="fas fa-venus-mars"></i> Gênero</label>
                                    <select class="gender-filter">
                                        <option value="">Todos</option><option value="Masculino">Masculino</option><option value="Feminino">Feminino</option><option value="Outro">Outro</option>
                                    </select>
                                </div>
                                <div class="filter-group">
                                    <label><i class="fas fa-child"></i> Filhos</label>
                                    <select class="children-filter">
                                        <option value="">Todos</option><option value="sim">Com Filhos</option><option value="nao">Sem Filhos</option>
                                    </select>
                                </div>
                                <div class="filter-group">
                                    <label><i class="fas fa-exclamation-triangle"></i> Vencimentos</label>
                                    <select class="expiry-filter">
                                        <option value="">Nenhum</option><option value="validade_cnh">CNH Vencida</option><option value="validade_exame_medico">Exame Médico Vencido</option><option value="validade_treinamento">Treinamento Vencido</option><option value="validade_cct">CCT Vencida</option><option value="validade_contrato_experiencia">Contrato Exp. Vencido</option>
                                    </select>
                                </div>
                                <div class="filter-group">
                                    <label><i class="fas fa-birthday-cake"></i> Aniversariantes</label>
                                    <select class="birthday-filter">
                                        <option value="">Qualquer data</option><option value="sim">Aniversariantes do Mês</option>
                                    </select>
                                </div>
                                <div class="filter-group">
                                    <label><i class="fas fa-city"></i> Cidade</label>
                                    <input type="text" class="city-filter" placeholder="Digite a cidade...">
                                </div>
                                <div class="filter-group">
                                    <label><i class="fas fa-map-marked-alt"></i> Estado</label>
                                    <select class="state-filter">
                                        <option value="">Todos</option>
                                        <option value="AC">Acre</option><option value="AL">Alagoas</option><option value="AP">Amapá</option><option value="AM">Amazonas</option><option value="BA">Bahia</option><option value="CE">Ceará</option><option value="DF">Distrito Federal</option><option value="ES">Espírito Santo</option><option value="GO">Goiás</option><option value="MA">Maranhão</option><option value="MT">Mato Grosso</option><option value="MS">Mato Grosso do Sul</option><option value="MG">Minas Gerais</option><option value="PA">Pará</option><option value="PB">Paraíba</option><option value="PR">Paraná</option><option value="PE">Pernambuco</option><option value="PI">Piauí</option><option value="RJ">Rio de Janeiro</option><option value="RN">Rio Grande do Norte</option><option value="RS">Rio Grande do Sul</option><option value="RO">Rondônia</option><option value="RR">Roraima</option><option value="SC">Santa Catarina</option><option value="SP">São Paulo</option><option value="SE">Sergipe</option><option value="TO">Tocantins</option>
                                    </select>
                                </div>
                            </div>
                            <div class="advanced-filters-footer">
                                <button class="clear-filters-btn"><i class="fas fa-times"></i> Limpar Filtros Avançados</button>
                            </div>
                        </div>
                    </div>
                    <div class="funcionarios-grid" id="funcionariosGridAtivos"></div>
                </div>
            </section>
            
            <section id="inativos-section" class="content-section">
                <div class="container">
                     <div class="section-header-actions">
                         <div class="section-header"><i class="fa-solid fa-user-clock"></i><h2>Histórico de Colaboradores</h2></div>
                     </div>
                      <div class="filtros-container">
                         <div class="filtros-principais">
                             <div class="filter-group"><i class="fa-solid fa-magnifying-glass"></i><input type="text" class="search-input" placeholder="Pesquisar por nome..."></div>
                             <div class="filter-group"><i class="fa-solid fa-building"></i><select class="location-filter"></select></div>
                             <button class="advanced-filter-btn">
                                 <i class="fas fa-sliders-h"></i> Filtros Avançados <span class="filter-count"></span>
                             </button>
                         </div>
                         <div class="filtros-avancados">
                             <div class="grid">
                                 <div class="filter-group">
                                     <label><i class="fas fa-venus-mars"></i> Gênero</label>
                                     <select class="gender-filter">
                                         <option value="">Todos</option><option value="Masculino">Masculino</option><option value="Feminino">Feminino</option><option value="Outro">Outro</option>
                                     </select>
                                 </div>
                                 <div class="filter-group">
                                     <label><i class="fas fa-child"></i> Filhos</label>
                                     <select class="children-filter">
                                         <option value="">Todos</option><option value="sim">Com Filhos</option><option value="nao">Sem Filhos</option>
                                     </select>
                                 </div>
                                 <div class="filter-group">
                                     <label><i class="fas fa-birthday-cake"></i> Aniversariantes</label>
                                     <select class="birthday-filter">
                                         <option value="">Qualquer data</option><option value="sim">Aniversariantes do Mês</option>
                                     </select>
                                 </div>
                                 <div class="filter-group">
                                     <label><i class="fas fa-city"></i> Cidade</label>
                                     <input type="text" class="city-filter" placeholder="Digite a cidade...">
                                 </div>
                                 <div class="filter-group">
                                     <label><i class="fas fa-map-marked-alt"></i> Estado</label>
                                     <select class="state-filter">
                                         <option value="">Todos</option>
                                         <option value="AC">Acre</option><option value="AL">Alagoas</option><option value="AP">Amapá</option><option value="AM">Amazonas</option><option value="BA">Bahia</option><option value="CE">Ceará</option><option value="DF">Distrito Federal</option><option value="ES">Espírito Santo</option><option value="GO">Goiás</option><option value="MA">Maranhão</option><option value="MT">Mato Grosso</option><option value="MS">Mato Grosso do Sul</option><option value="MG">Minas Gerais</option><option value="PA">Pará</option><option value="PB">Paraíba</option><option value="PR">Paraná</option><option value="PE">Pernambuco</option><option value="PI">Piauí</option><option value="RJ">Rio de Janeiro</option><option value="RN">Rio Grande do Norte</option><option value="RS">Rio Grande do Sul</option><option value="RO">Rondônia</option><option value="RR">Roraima</option><option value="SC">Santa Catarina</option><option value="SP">São Paulo</option><option value="SE">Sergipe</option><option value="TO">Tocantins</option>
                                     </select>
                                 </div>
                             </div>
                             <div class="advanced-filters-footer">
                                 <button class="clear-filters-btn"><i class="fas fa-times"></i> Limpar Filtros Avançados</button>
                             </div>
                         </div>
                     </div>
                    <div class="funcionarios-grid" id="funcionariosGridInativos"></div>
                </div>
            </section>

            <section id="status-section" class="content-section">
                <div class="container">
                    <div class="section-header">
                        <i class="fas fa-globe-americas"></i>
                        <h2>Visão Geral da Empresa</h2>
                    </div>
                    <div class="status-summary summary-totals">
                        <div class="summary-card total"><div class="card-icon"><i class="fas fa-users"></i></div><div class="info"><h4>Total Ativos</h4><span id="total-ativos">0</span></div></div>
                        <div class="summary-card inativos"><div class="card-icon"><i class="fas fa-user-slash"></i></div><div class="info"><h4>Total Inativos</h4><span id="total-inativos">0</span></div></div>
                    </div>

                    <hr class="section-divider">

                    <div class="section-header">
                        <i class="fa-solid fa-chart-line"></i>
                        <h2>Dashboard de Ponto Diário</h2>
                    </div>
                    <div class="dashboard-controls">
                        <div class="control-group date-navigation"><button id="prev-day-btn" title="Dia Anterior"><i class="fas fa-chevron-left"></i></button><input type="date" id="date-picker"><button id="next-day-btn" title="Próximo Dia"><i class="fas fa-chevron-right"></i></button></div>
                        <div class="control-group unit-filter-container"><label for="unit-filter"><i class="fas fa-building"></i></label><select id="unit-filter"></select></div>
                        
                        <div class="control-group unit-total">
                            <i class="fas fa-users"></i>
                            <span>Total na Unidade: <strong id="unit-total-count">0</strong></span>
                        </div>

                        <div class="control-group action-buttons"><button id="save-data-btn" class="action-btn save"><i class="fas fa-save"></i> Gravar</button><button id="generate-pdf-btn" class="action-btn pdf"><i class="fas fa-file-pdf"></i> Gerar PDF</button></div>
                    </div>
                    
                    <h3 id="dashboard-display-date"></h3>
                    
                    <div class="status-summary">
                        <div class="summary-card presente"><div class="card-icon"><i class="fas fa-user-check"></i></div><div class="info"><h4>Presentes</h4><input type="number" min="0" id="input-presentes"></div></div>
                        <div class="summary-card falta"><div class="card-icon"><i class="fas fa-user-times"></i></div><div class="info"><h4>Faltas (Injus.)</h4><input type="number" min="0" id="input-falta_injustificada"></div></div>
                        <div class="summary-card folga"><div class="card-icon"><i class="fas fa-couch"></i></div><div class="info"><h4>Folga</h4><input type="number" min="0" id="input-folga"></div></div>
                        <div class="summary-card ferias"><div class="card-icon"><i class="fas fa-plane-departure"></i></div><div class="info"><h4>Férias</h4><input type="number" min="0" id="input-ferias"></div></div>
                        <div class="summary-card atestado"><div class="card-icon"><i class="fas fa-file-medical"></i></div><div class="info"><h4>Atestado</h4><input type="number" min="0" id="input-atestado"></div></div>
                    </div>
                    <div id="capture-area">
                        <div class="chart-header">
                            <img src="assets/imagens/imagens.png" alt="Logo Tranquility" class="pdf-logo">
                            <div class="pdf-title-container">
                                <h2 class="pdf-main-title">Relatório de Status Diário</h2>
                                <p class="pdf-subtitle"></p>
                            </div>
                        </div>
                        <div class="report-layout">
                            <div class="chart-container">
                                <canvas id="statusChart"></canvas>
                            </div>
                            <div class="summary-table-container">
                                <h4>Resumo Numérico</h4>
                                <table class="summary-table">
                                    <thead>
                                        <tr>
                                            <th>Status</th>
                                            <th>Quantidade</th>
                                        </tr>
                                    </thead>
                                    <tbody id="pdf-summary-table-body">
                                    </tbody>
                                    <tfoot>
                                        <tr id="pdf-summary-table-total">
                                        </tr>
                                    </tfoot>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </section>
        </main>
        <footer> <div class="container"><p>&copy; 2025 Painel de Gestão Tranquility Parking Lot</p></div> </footer>
    </div>
    <div id="toast"></div>

    <div id="employee-modal" class="modal-overlay hidden">
        <div class="modal-content">
            <div class="modal-header">
                <h2 id="modal-employee-name"></h2>
                <button type="button" class="modal-close-btn">&times;</button>
            </div>
            <div class="modal-body">
                <p id="modal-employee-role"></p>
                <div class="modal-tabs">
                    <button class="tab-btn active" data-tab="tab-validade">Validades</button>
                    <button class="tab-btn" data-tab="tab-pessoal">Informações Pessoais</button>
                    <button class="tab-btn" data-tab="tab-pastas">Pastas</button>
                </div>
                <div class="tab-content-wrapper">
                    <div id="tab-validade" class="tab-content active">
                        <table class="validade-table">
                            <thead> <tr> <th>Item</th> <th>Data de Vencimento</th> </tr> </thead>
                            <tbody id="validade-table-body"></tbody>
                        </table>
                    </div>
                    <div id="tab-pessoal" class="tab-content">
                        </div>
                    <div id="tab-pastas" class="tab-content">
                        <h3>Documentos e Pastas</h3>
                        <div class="folder-grid">
                            <div class="folder"><i class="fas fa-file-signature"></i><span>Contrato</span></div>
                            <div class="folder"><i class="fas fa-file-medical"></i><span>Atestado</span></div>
                            <div class="folder"><i class="fas fa-clock"></i><span>Ponto</span></div>
                            <div class="folder"><i class="fas fa-file-invoice-dollar"></i><span>Holerite</span></div>
                            <div class="folder"><i class="fas fa-exclamation-triangle"></i><span>Advertência</span></div>
                            <div class="folder"><i class="fas fa-id-card"></i><span>Documentos</span></div>
                            <div class="folder"><i class="fas fa-folder-open"></i><span>Outros</span></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <div id="form-modal" class="modal-overlay hidden">
        <div class="modal-content">
            <form id="employee-form" novalidate>
                <div class="form-header">
                    <h2 id="form-modal-title">Adicionar Novo Colaborador</h2>
                    <button type="button" class="modal-close-btn">&times;</button>
                </div>
                <div class="form-progress-bar">
                    <div class="progress-step active" data-step="1">
                        <span>1</span>
                        <p>Principais</p>
                    </div>
                    <div class="progress-line"></div>
                    <div class="progress-step" data-step="2">
                        <span>2</span>
                        <p>Pessoais</p>
                    </div>
                    <div class="progress-line"></div>
                    <div class="progress-step" data-step="3">
                        <span>3</span>
                        <p>Validades</p>
                    </div>
                </div>
                <div class="form-body">
                    <div class="form-wizard">
                        <div class="form-step active" data-step="1">
                            <div class="form-group-divider">Informações Principais</div>
                            <div class="form-grid">
                                <div class="form-group"> <label for="nome">Nome Completo</label> <input type="text" id="nome" name="nome" required> </div>
                                <div class="form-group"> <label for="funcao">Função</label> <input type="text" id="funcao" name="funcao" required> </div>
                                <div class="form-group"> <label for="local">Unidade</label> <input type="text" id="local" name="local" required> </div>
                                <div class="form-group"> <label for="data_movimentacao" id="data_movimentacao_label">Data</label> <input type="date" id="data_movimentacao" name="data_movimentacao" required> </div>
                            </div>
                        </div>
                        <div class="form-step" data-step="2">
                            <div class="form-group-divider">Informações Pessoais</div>
                            <div class="form-grid">
                                <div class="form-group"> <label for="data_nascimento">Data de Nascimento</label> <input type="date" id="data_nascimento" name="data_nascimento"> </div>
                                <div class="form-group"> <label for="genero">Gênero</label> <select id="genero" name="genero"> <option value="Não informar">Não informar</option> <option value="Masculino">Masculino</option> <option value="Feminino">Feminino</option> <option value="Outro">Outro</option> </select> </div>
                                <div class="form-group"> <label for="estado_civil">Estado Civil</label> <select id="estado_civil" name="estado_civil"> <option value="">Selecione...</option> <option value="Solteiro(a)">Solteiro(a)</option> <option value="Casado(a)">Casado(a)</option> <option value="Divorciado(a)">Divorciado(a)</option> <option value="Viúvo(a)">Viúvo(a)</option> </select> </div>
                                
                                <div id="spouse-dynamic-container" class="hidden grid-full-width">
                                    <div class="form-grid">
                                        <div class="form-group">
                                            <label for="conjuge_nome">Nome do Cônjuge</label>
                                            <input type="text" id="conjuge_nome">
                                        </div>
                                        <div class="form-group">
                                            <label for="conjuge_data_nascimento">Data de Nascimento do Cônjuge</label>
                                            <input type="date" id="conjuge_data_nascimento">
                                        </div>
                                    </div>
                                </div>
                                <input type="hidden" id="dados_conjuge" name="dados_conjuge">

                                <div class="form-group"> <label for="rg">RG</label> <input type="text" id="rg" name="rg"> </div>
                                <div class="form-group"> <label for="cpf">CPF</label> <input type="text" id="cpf" name="cpf"> </div>
                                <div class="form-group"> <label for="cnh_numero">Número da CNH</label> <input type="text" id="cnh_numero" name="cnh_numero"> </div>
                                
                                <div class="form-group">
                                    <label for="tem_filhos">Possui Filhos?</label>
                                    <select id="tem_filhos">
                                        <option value="nao">Não</option>
                                        <option value="sim">Sim</option>
                                    </select>
                                </div>
                                <div id="children-dynamic-container" class="hidden grid-full-width">
                                    <div class="form-group-divider" style="margin-top: 10px; margin-bottom: 20px;">Dados dos Filhos</div>
                                    <div id="children-list">
                                    </div>
                                    <button type="button" id="add-child-btn" class="add-child-button"><i class="fas fa-plus"></i> Adicionar Filho</button>
                                </div>
                                <input type="hidden" id="quantidade_filhos" name="quantidade_filhos">
                                <input type="hidden" id="nome_filhos" name="nome_filhos">

                                <div class="form-group"> <label for="email_pessoal">E-mail Pessoal</label> <input type="email" id="email_pessoal" name="email_pessoal"> </div>
                                <div class="form-group"> <label for="telefone_1">Telefone 1 (Principal)</label> <input type="tel" id="telefone_1" name="telefone_1"> </div>
                                <div class="form-group"> <label for="telefone_2">Telefone 2</label> <input type="tel" id="telefone_2" name="telefone_2"> </div>
                                <div class="form-group"> <label for="telefone_3">Telefone 3</label> <input type="tel" id="telefone_3" name="telefone_3"> </div>
                            </div>
                            <div class="form-group-divider">Endereço</div>
                            <div class="form-grid">
                                <div class="form-group"> <label for="cep">CEP</label> <input type="text" id="cep" name="cep" placeholder="Digite o CEP e aguarde"> </div>
                                <div class="form-group grid-full-width"> <label for="rua">Rua / Logradouro</label> <input type="text" id="rua" name="rua"> </div>
                                <div class="form-group"> <label for="numero">Número</label> <input type="text" id="numero" name="numero"> </div>
                                <div class="form-group"> <label for="complemento">Complemento</label> <input type="text" id="complemento" name="complemento" placeholder="Apto, Bloco, etc."> </div>
                                <div class="form-group"> <label for="bairro">Bairro</label> <input type="text" id="bairro" name="bairro"> </div>
                                <div class="form-group"> <label for="cidade">Cidade</label> <input type="text" id="cidade" name="cidade"> </div>
                                <div class="form-group"> <label for="estado">Estado</label> <input type="text" id="estado" name="estado" maxlength="2"> </div>
                            </div>
                        </div>
                        <div class="form-step" data-step="3">
                            <div class="form-group-divider">Validades</div>
                            <div class="form-grid">
                                <div class="form-group"> <label for="validade_cnh">Venc. CNH</label> <input type="date" id="validade_cnh" name="validade_cnh"> </div>
                                <div class="form-group"> <label for="validade_exame_medico">Venc. Exame Médico</label> <input type="date" id="validade_exame_medico" name="validade_exame_medico"> </div>
                                <div class="form-group"> <label for="validade_treinamento">Venc. Treinamento</label> <input type="date" id="validade_treinamento" name="validade_treinamento"> </div>
                                <div class="form-group"> <label for="validade_cct">Venc. CCT</label> <input type="date" id="validade_cct" name="validade_cct"> </div>
                                <div class="form-group"> <label for="validade_contrato_experiencia">Fim Contrato Exp.</label> <input type="date" id="validade_contrato_experiencia" name="validade_contrato_experiencia"> </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="form-footer">
                    <div class="form-navigation">
                        <button type="button" class="form-nav-btn prev" disabled><i class="fas fa-arrow-left"></i> Anterior</button>
                        <button type="button" class="form-nav-btn next">Próximo <i class="fas fa-arrow-right"></i></button>
                    </div>
                    <input type="hidden" id="employee-id" name="id">
                    <input type="hidden" id="employee-status" name="status">
                    <button type="submit" class="form-submit-btn"><i class="fas fa-save"></i> Salvar Colaborador</button>
                </div>
            </form>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chartjs-plugin-datalabels@2.2.0"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
    <script src="https://unpkg.com/imask"></script>
    <script src="assets/js/script.js" defer></script>

</body>
</html>
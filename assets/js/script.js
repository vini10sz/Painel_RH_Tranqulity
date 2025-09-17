// assets/js/script.js - Versão Final Corrigida e Completa

document.addEventListener('DOMContentLoaded', function() {
    
    // =================================================================================
    // 1. SETUP E ELEMENTOS GLOBAIS
    // =================================================================================
    
    const appWrapper = document.getElementById('app-wrapper');
    const employeeModal = document.getElementById('employee-modal');
    const formModal = document.getElementById('form-modal');
    const employeeForm = document.getElementById('employee-form');
    const loginContainer = document.getElementById('login-container');
    const loginForm = document.getElementById('login-form');
    const mainNav = document.getElementById('main-nav');
    const menuToggle = document.getElementById('menu-toggle');
    const sections = document.querySelectorAll('.content-section');
    const navLinks = document.querySelectorAll('#main-nav a');

    let masterEmployeeList = { ativos: [], inativos: [] };
    let statusChartInstance = null;
    let dashboardInitialized = false;
    const API_URL = 'backend/api.php';
    
    let currentEmployeeId = null;
    let currentFolderId = null;
    let breadcrumbHistory = [];

    const empresas = ["Tranquility", "GSM", "Protector", "GS1"];
    const unidades = [
        "Prevent Sênior - Hospital Madri", "IGESP - Hospital Praia Grande", "IGESP - Pronto Atendimento Santos",
        "IGESP - Pronto Atendimento Santo André", "IGESP - Pronto Atendimento Congonhas", "IGESP - Pronto Atendimento Anália Franco",
        "Grupo Santa Marcelina Itaquera - Sede", "Grupo Santa Marcelina Itaquera - AME", "Grupo Santa Marcelina Itaquera - Instituto",
        "Grupo Santa Marcelina Itaquera - Torre", "Grupo Santa Marcelina Itaquera - Faculdade Santa Marcelina",
        "Grupo Santa Marcelina Regionais - Hospital Cidade Tiradentes", "Grupo Santa Marcelina Regionais - Hospital Itaim",
        "Grupo Santa Marcelina Regionais - Hospital Itaquá", "Grupo Santa Marcelina Regionais - Hospital Neomater SBC",
        "Hapvida", "Espaço HAOC", "São Carlos - Santa Casa", "São Carlos - CID", "São Carlos - Onovolab"
    ];

    Chart.register(ChartDataLabels);

    // =================================================================================
    // 2. LÓGICA DO DARK MODE
    // =================================================================================
    
    const themeToggle = document.getElementById('theme-toggle');
    const body = document.body;
    
    function applyTheme(theme) {
        body.classList.toggle('dark-mode', theme === 'dark');
        if (themeToggle) {
            themeToggle.innerHTML = theme === 'dark' ? '<i class="fas fa-sun"></i>' : '<i class="fas fa-moon"></i>';
        }
        localStorage.setItem('theme', theme);
        if (dashboardInitialized) {
            loadDashboardData(); 
        }
    }
    
    // =================================================================================
    // 3. FUNÇÕES HELPERS (API, Toast, etc)
    // =================================================================================

    function getLocalDateAsString(date = new Date()) {
        const offset = date.getTimezoneOffset();
        const localDate = new Date(date.getTime() - (offset * 60 * 1000));
        return localDate.toISOString().split('T')[0];
    }

    async function fetchAddressByCep(cep) {
        const cleanCep = cep.replace(/\D/g, '');
        if (cleanCep.length !== 8) return;
    
        try {
            const response = await fetch(`https://viacep.com.br/ws/${cleanCep}/json/`);
            if (!response.ok) throw new Error('Erro na resposta da API de CEP');
            const data = await response.json();
            if (!data.erro) {
                document.getElementById('rua').value = data.logradouro;
                document.getElementById('bairro').value = data.bairro;
                document.getElementById('cidade').value = data.localidade;
                document.getElementById('estado').value = data.uf;
                document.getElementById('numero').focus();
            } else {
                showToast('CEP não encontrado.', 'error');
            }
        } catch (error) {
            console.error('Erro ao buscar CEP:', error);
            showToast('Não foi possível buscar o CEP.', 'error');
        }
    }

    function calculateAge(birthDateString) {
        if (!birthDateString || birthDateString === '0000-00-00') return 'Idade não informada';
        const birthDate = new Date(birthDateString);
        if (isNaN(birthDate.getTime())) return 'Data inválida';

        const today = new Date();
        let age = today.getFullYear() - birthDate.getFullYear();
        const m = today.getMonth() - birthDate.getMonth();
        if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
            age--;
        }
        return age >= 0 ? `${age} anos` : 'Data inválida';
    }

    async function fetchAPI(params) {
        try {
            const response = await fetch(`${API_URL}?${params}`, { cache: "no-store" });
            if (!response.ok) throw new Error(`Erro de rede: ${response.status}`);
            const result = await response.json();
            if (result.success === false) throw new Error(result.message || 'Erro desconhecido na API.');
            return result;
        } catch (error) {
            console.error("Erro na chamada da API:", error);
            showToast(error.message, 'error');
            return null;
        }
    }

    async function postAPI(formData) {
        try {
            const response = await fetch(API_URL, { method: 'POST', body: formData });
            if (!response.ok) throw new Error(`Erro de rede: ${response.status}`);
            const result = await response.json();
            if (!result.success) throw new Error(result.message || 'Erro ao enviar dados.');
            return result;
        } catch (error) {
            console.error("Erro ao enviar dados para API:", error);
            showToast(error.message, 'error');
            return null;
        }
    }

    function showToast(message, type = 'success') {
        const toast = document.getElementById('toast');
        if (!toast) return;
        toast.textContent = message;
        toast.className = `show ${type === 'error' ? 'error' : ''}`;
        setTimeout(() => { toast.className = toast.className.replace("show", ""); }, 3000);
    }

    function setupInputMasks() {
        const phoneMask = { mask: '(00) 00000-0000' };
        const cpfMask = { mask: '000.000.000-00' };
        const cepMask = { mask: '00000-000' };
    
        IMask(document.getElementById('telefone_1'), phoneMask);
        IMask(document.getElementById('telefone_2'), phoneMask);
        IMask(document.getElementById('telefone_3'), phoneMask);
        IMask(document.getElementById('cpf'), cpfMask);
        IMask(document.getElementById('cep'), cepMask);
    }

    function clearAllFilters() {
        document.querySelectorAll('.filtros-container').forEach(container => {
            container.querySelectorAll('input.search-input, input.city-filter, input[type="number"]').forEach(input => input.value = '');
            container.querySelectorAll('select').forEach(select => select.selectedIndex = 0);
            
            const advancedFilters = container.querySelector('.filtros-avancados');
            if (advancedFilters && advancedFilters.classList.contains('open')) {
                advancedFilters.classList.remove('open');
            }
            container.querySelectorAll('.children-filter').forEach(select => {
                select.dispatchEvent(new Event('change'));
            });
            updateActiveFilterCount(container, 0);
        });
    }

    async function refreshDataAndRender() {
        const result = await fetchAPI('action=get_all_funcionarios');
        if (result && result.data) {
            masterEmployeeList = result.data;
            const fullList = [...masterEmployeeList.ativos, ...masterEmployeeList.inativos];
            
            // Note: Não populamos mais os filtros de unidade aqui, pois eles são estáticos
            filterAndRenderLists(); 
        }
    }

    function createChildEntry(child = {}) {
        const entryDiv = document.createElement('div');
        entryDiv.className = 'child-entry';
        entryDiv.innerHTML = `
            <input type="text" placeholder="Nome do filho(a)" class="child-name" value="${child.nome || ''}">
            <input type="date" class="child-birthdate" value="${child.data_nascimento || ''}">
            <button type="button" class="remove-child-btn"><i class="fas fa-trash"></i></button>
        `;
        document.getElementById('children-list').appendChild(entryDiv);
        entryDiv.querySelector('.remove-child-btn').addEventListener('click', () => {
            entryDiv.remove();
        });
    }
    
    async function handleFileUpload(file) {
        if (!file || !currentEmployeeId || !currentFolderId) return;
        
        const formData = new FormData();
        formData.append('action', 'upload_arquivo');
        formData.append('pasta_id', currentFolderId);
        formData.append('arquivo', file);

        showToast('Enviando arquivo...', 'info');
        const result = await postAPI(formData);
        if (result && result.success) {
            showToast('Arquivo enviado com sucesso!');
            renderFileExplorer(currentEmployeeId, currentFolderId, breadcrumbHistory);
        }
    }

    function populateSelectWithOptions(selector, options, defaultLabel) {
        document.querySelectorAll(selector).forEach(select => {
            if (!select) return;
            select.innerHTML = `<option value="">${defaultLabel}</option>`;
            options.forEach(opt => {
                const optionEl = document.createElement('option');
                optionEl.value = opt;
                optionEl.textContent = opt;
                select.appendChild(optionEl);
            });
        });
    }

    // =================================================================================
    // 4. NAVEGAÇÃO, FILTROS E RENDERIZAÇÃO
    // =================================================================================
    
    function handleRouteChange() {
        const hash = window.location.hash || '#funcionarios';
        
        navLinks.forEach(link => {
            link.classList.toggle('active', link.hash === hash);
        });

        sections.forEach(section => {
            section.classList.toggle('active', `#${section.id}` === `${hash}-section`);
        });
        
        if (mainNav) mainNav.classList.remove('active');
        window.scrollTo(0, 0);
    
        if (hash === '#funcionarios' || hash === '#inativos') {
            filterAndRenderLists();
        }
    
        if (hash === '#status') {
            fetchAPI(`action=get_all_funcionarios`).then(result => {
                if (result && result.data) {
                    masterEmployeeList = result.data;
                    updateDashboardSummary();
                    initializeDashboard();
                }
            });
        }
    }
    
    function filterAndRenderLists() {
        const listMap = { 'ativos': 'funcionarios-section', 'inativos': 'inativos-section' };
    
        for (const [type, sectionId] of Object.entries(listMap)) {
            const section = document.querySelector(`#${sectionId}`);
            if (!section) continue;
            const container = section.querySelector('.filtros-container');
            const grid = section.querySelector('.funcionarios-grid');
            const sourceList = masterEmployeeList[type] || [];
            if (!container || !grid) continue;
    
            const filters = {
                nome: container.querySelector('.search-input').value.toLowerCase(),
                empresa: container.querySelector('.company-filter')?.value,
                unidade: container.querySelector('.location-filter').value,
                genero: container.querySelector('.gender-filter')?.value,
                status_filhos: container.querySelector('.children-filter')?.value,
                idade_filho_min: container.querySelector('.children-age-min-filter')?.value,
                idade_filho_max: container.querySelector('.children-age-max-filter')?.value,
                mes_aniversario: container.querySelector('.birthday-month-filter')?.value,
                cidade: container.querySelector('.city-filter')?.value.toLowerCase(),
                estado: container.querySelector('.state-filter')?.value,
                vencimento: container.querySelector('.expiry-filter')?.value,
                recontratacao: container.querySelector('.rehire-filter')?.value
            };
    
            let filteredList = sourceList;
    
            if (filters.nome) {
                filteredList = filteredList.filter(func => func.nome && func.nome.toLowerCase().includes(filters.nome));
            }
            if (filters.empresa) {
                filteredList = filteredList.filter(func => func.empresa === filters.empresa);
            }
            if (filters.unidade) {
                filteredList = filteredList.filter(func => func.local === filters.unidade);
            }
            if (filters.genero) {
                filteredList = filteredList.filter(func => func.genero === filters.genero);
            }
            if (filters.cidade) {
                filteredList = filteredList.filter(func => func.cidade && func.cidade.toLowerCase().includes(filters.cidade));
            }
            if (filters.estado) {
                filteredList = filteredList.filter(func => func.estado === filters.estado);
            }
            if (filters.mes_aniversario) {
                filteredList = filteredList.filter(func => func.data_nascimento && (new Date(func.data_nascimento + 'T12:00:00').getMonth() + 1) == filters.mes_aniversario);
            }
            if (filters.vencimento && type === 'ativos') {
                filteredList = filteredList.filter(func => func[filters.vencimento] && new Date(func[filters.vencimento] + 'T12:00:00') < new Date());
            }
            if (type === 'inativos' && filters.recontratacao) {
                const normalizedFilter = filters.recontratacao.toLowerCase();
                filteredList = filteredList.filter(func => {
                    if (!func.elegivel_recontratacao) return false;
                    let dbValue = func.elegivel_recontratacao.toLowerCase();
                    if (dbValue === 'não') dbValue = 'nao';
                    return dbValue === normalizedFilter;
                });
            }
    
            if (filters.status_filhos) {
                if (filters.status_filhos === 'sim') {
                    filteredList = filteredList.filter(func => parseInt(func.quantidade_filhos) > 0);
                    
                    const minAge = filters.idade_filho_min ? parseInt(filters.idade_filho_min) : null;
                    const maxAge = filters.idade_filho_max ? parseInt(filters.idade_filho_max) : null;
    
                    if (minAge !== null || maxAge !== null) {
                        filteredList = filteredList.filter(func => {
                            if (!func.nome_filhos) return false;
                            try {
                                const filhos = JSON.parse(func.nome_filhos);
                                const min = minAge !== null ? minAge : 0;
                                const max = maxAge !== null ? maxAge : 999;
                                return filhos.some(filho => {
                                    if (!filho.data_nascimento) return false;
                                    const idade = parseInt(calculateAge(filho.data_nascimento));
                                    return !isNaN(idade) && idade >= min && idade <= max;
                                });
                            } catch (e) {
                                return false;
                            }
                        });
                    }
                } else if (filters.status_filhos === 'nao') {
                    filteredList = filteredList.filter(func => !func.quantidade_filhos || parseInt(func.quantidade_filhos) === 0);
                }
            }
            
            renderList(filteredList, grid);
        }
        updateDashboardSummary();
    }    

    function updateActiveFilterCount(container, count) {
        const countBadge = container.querySelector('.filter-count');
        const advBtn = container.querySelector('.advanced-filter-btn');
        if(!countBadge || !advBtn) return;
        
        if (count > 0) {
            countBadge.textContent = count;
            countBadge.classList.add('active');
            advBtn.classList.add('active');
        } else {
            countBadge.classList.remove('active');
            advBtn.classList.remove('active');
        }
    }

    function renderList(lista, gridElement) {
        if (!gridElement) return;
        gridElement.innerHTML = '';
        if (!lista || lista.length === 0) {
            gridElement.innerHTML = `<p class="not-found">Nenhum colaborador encontrado para os filtros selecionados.</p>`;
            return;
        }
        lista.forEach(func => gridElement.appendChild(createEmployeeCard(func)));
    }

        function createEmployeeCard(func) {
            const card = document.createElement('div');
            card.className = `funcionario-card ${func.status}`;
            card.dataset.id = func.id;

            // Adiciona a classe da empresa para a cor dinâmica
            if (func.empresa) {
                const empresaClass = `empresa-${func.empresa.toLowerCase().replace(/\s+/g, '')}`;
                card.classList.add(empresaClass);
            }
            
            const dataLabel = func.status === 'ativo' ? 'Admissão' : 'Demissão';
            const dataValue = func.status === 'ativo' ? func.data_admissao : func.data_demissao;
            const formattedDate = dataValue && dataValue !== '0000-00-00' ? new Date(dataValue + 'T12:00:00').toLocaleDateString('pt-BR') : 'Não informado';
            
            let seloHtml = '';
            if (func.status === 'inativo' && func.elegivel_recontratacao) {
                let statusClass = func.elegivel_recontratacao.toLowerCase();
                if (statusClass === 'não') statusClass = 'nao';
                seloHtml = `<div class="recontratacao-selo ${statusClass}">${func.elegivel_recontratacao}</div>`;
            }
            
            let seloEmpresaHtml = '';
            if (func.empresa) {
                const empresaClass = func.empresa.toLowerCase().replace(/\s+/g, '');
                seloEmpresaHtml = `<div class="empresa-selo ${empresaClass}">${func.empresa}</div>`;
            }

            card.innerHTML = `
                ${seloHtml}
                ${seloEmpresaHtml}
                <div class="funcionario-card-content" data-action="open-details">
                    <h3>${func.nome}</h3>
                    <p><i class="fas fa-briefcase"></i>${func.funcao || 'Não informado'}</p>
                    <p><i class="fas fa-building"></i>${func.local || 'Não informado'}</p>
                    <p><i class="fas fa-calendar-check"></i>${dataLabel}: ${formattedDate}</p>
                </div>
                <div class="card-actions">
                    <button class="card-btn" data-action="edit" title="Editar"><i class="fas fa-edit"></i></button>
                    ${func.status === 'ativo' ? `<button class="card-btn" data-action="terminate" title="Encerrar Contrato"><i class="fas fa-user-slash"></i></button>` : ''}
                    <button class="card-btn" data-action="delete" title="Excluir"><i class="fas fa-trash"></i></button>
                </div>`;
            return card;
        }
    
    // =================================================================================
    // 5. LÓGICA DE MODAIS E FORMULÁRIO WIZARD
    // =================================================================================
    
    let currentStep = 1;
    const formWizard = formModal.querySelector('.form-wizard');
    const progressBar = formModal.querySelector('.form-progress-bar');
    const formNavNextBtn = formModal.querySelector('.form-nav-btn.next');
    const formNavPrevBtn = formModal.querySelector('.form-nav-btn.prev');
    const formSubmitBtn = formModal.querySelector('.form-submit-btn');

    function validateStep(stepNumber) {
        const step = formWizard.querySelector(`.form-step[data-step="${stepNumber}"]`);
        const inputs = step.querySelectorAll('input[required], select[required]');
        let isValid = true;
        
        inputs.forEach(input => {
            input.classList.remove('invalid');
            if (!input.value.trim()) {
                input.classList.add('invalid');
                isValid = false;
            }
        });

        if (!isValid) {
            showToast('Por favor, preencha todos os campos obrigatórios.', 'error');
        }
        return isValid;
    }

    function updateProgressBar() {
        if(!progressBar) return;
        const progressSteps = progressBar.querySelectorAll('.progress-step');
        const progressLine = progressBar.querySelector('.progress-line');

        progressSteps.forEach((step, index) => {
            step.classList.remove('active', 'completed');
            if (index < currentStep - 1) {
                step.classList.add('completed');
            } else if (index === currentStep - 1) {
                step.classList.add('active');
            }
        });
        const oneStepPercent = 100 / (progressSteps.length - 1);
        progressLine.style.width = ((currentStep - 1) * oneStepPercent) + '%';
    }

    function navigateToStep(step) {
        const formSteps = formWizard.querySelectorAll('.form-step');
        currentStep = step;
        formSteps.forEach(s => s.classList.remove('active'));
        const targetStep = formWizard.querySelector(`.form-step[data-step="${step}"]`);
        if (targetStep) targetStep.classList.add('active');
        
        formNavPrevBtn.disabled = currentStep === 1;

        if (currentStep === formSteps.length) {
            formNavNextBtn.classList.add('final-step');
            formSubmitBtn.style.display = 'inline-flex';
        } else {
            formNavNextBtn.classList.remove('final-step');
            formSubmitBtn.style.display = 'none';
        }
        updateProgressBar();
    }
    
    function openEmployeeModal(func) {
        currentEmployeeId = func.id;
        const tabPessoal = employeeModal.querySelector('#tab-pessoal');
        document.getElementById('modal-employee-name').textContent = func.nome;
        document.getElementById('modal-employee-role').textContent = func.funcao;
        
        document.getElementById('file-explorer-view').classList.add('hidden');
        document.getElementById('main-folder-view').classList.remove('hidden');

        const tableBody = document.getElementById('validade-table-body');
        tableBody.innerHTML = '';
        const hoje = new Date();
        hoje.setHours(0, 0, 0, 0);
        let hasData = false;
        const validades = {
            'CNH': func.validade_cnh, 'Exame Médico': func.validade_exame_medico, 'Treinamento': func.validade_treinamento,
            'CCT': func.validade_cct, 'Contrato de Experiência': func.validade_contrato_experiencia
        };
        for (const [key, value] of Object.entries(validades)) {
            if (value && value !== '0000-00-00') {
                hasData = true;
                const dataAlvo = new Date(value + 'T12:00:00');
                const dataFormatada = dataAlvo.toLocaleDateString('pt-BR');
                let cellClass = '';
                let cellContent = dataFormatada;
                if (dataAlvo < hoje) {
                    cellClass = 'date-overdue';
                    cellContent = `Vencido em ${dataFormatada}`;
                } else if (dataAlvo.getFullYear() === hoje.getFullYear() && dataAlvo.getMonth() === hoje.getMonth()) {
                    cellClass = 'vencendo-mes';
                    cellContent = `Vencendo este mês! (${dataFormatada})`;
                }
                tableBody.insertAdjacentHTML('beforeend', `<tr><td>${key}</td><td class="${cellClass}">${cellContent}</td></tr>`);
            }
        }
        if (!hasData) tableBody.innerHTML = '<tr><td colspan="2" style="text-align:center;">Nenhuma data de validade cadastrada.</td></tr>';

        let filhosHtml = 'Não informado';
        if (parseInt(func.quantidade_filhos) > 0 && func.nome_filhos) {
            try {
                const filhosArray = JSON.parse(func.nome_filhos);
                if (Array.isArray(filhosArray) && filhosArray.length > 0) {
                    filhosHtml = '<ul style="padding-left: 20px; margin: 0;">';
                    filhosArray.forEach(filho => {
                        const idadeFilho = calculateAge(filho.data_nascimento);
                        filhosHtml += `<li>${filho.nome} (${idadeFilho})</li>`;
                    });
                    filhosHtml += '</ul>';
                }
            } catch(e) {
                filhosHtml = func.nome_filhos;
            }
        }

        let conjugeHtml = '';
        if (func.estado_civil === 'Casado(a)' && func.dados_conjuge) {
            try {
                const conjuge = JSON.parse(func.dados_conjuge);
                const idadeConjuge = calculateAge(conjuge.data_nascimento);
                conjugeHtml = `
                    <div class="grid-full-width">
                        <strong>Dados do Cônjuge</strong> 
                        <ul style="padding-left: 20px; margin: 0; list-style-type: none;">
                            <li>${conjuge.nome} (${idadeConjuge})</li>
                        </ul>
                    </div>
                `;
            } catch(e) {}
        }
        
        let historicoDemissaoHtml = '';
        if (func.status === 'inativo') {
            historicoDemissaoHtml = `
                <div class="grid-full-width info-demissao">
                    <strong>Histórico de Desligamento</strong>
                    <p><strong>Data:</strong> ${func.data_demissao ? new Date(func.data_demissao + 'T12:00:00').toLocaleDateString('pt-BR') : 'N/A'}</p>
                    <p><strong>Motivo:</strong> ${func.motivo_demissao || 'Não informado'}</p>
                    <p><strong>Elegível para Recontratação:</strong> ${func.elegivel_recontratacao || 'Não informado'}</p>
                </div>
            `;
        }
        
        const enderecoCompleto = `${func.rua || ''}, ${func.numero || 'S/N'}${func.complemento ? ' - ' + func.complemento : ''}`;

        tabPessoal.innerHTML = `
            <div class="info-pessoal-grid">
                ${historicoDemissaoHtml}
                <div><strong>Idade</strong> ${calculateAge(func.data_nascimento)}</div>
                <div><strong>Gênero</strong> ${func.genero || 'Não informado'}</div>
                <div><strong>Estado Civil</strong> ${func.estado_civil || 'Não informado'}</div>
                ${conjugeHtml}
                <div><strong>Qtd. Filhos</strong> ${parseInt(func.quantidade_filhos) > 0 ? func.quantidade_filhos : 'Nenhum'}</div>
                <div class="grid-full-width"><strong>Dados dos Filhos</strong> ${filhosHtml}</div>
                <div><strong>RG</strong> ${func.rg || 'Não informado'}</div>
                <div><strong>CPF</strong> ${func.cpf || 'Não informado'}</div>
                <div><strong>CNH</strong> ${func.cnh_numero || 'Não informado'}</div>
                <div class="grid-full-width"><strong>E-mail Pessoal</strong> ${func.email_pessoal || 'Não informado'}</div>
                <div class="grid-full-width"><strong>Endereço</strong> 
                    ${enderecoCompleto} <br>
                    ${func.bairro || ''} - ${func.cidade || ''}/${func.estado || ''} <br>
                    CEP: ${func.cep || 'Não informado'}
                </div>
                <div><strong>Telefone Principal</strong> ${func.telefone_1 || 'Não informado'}</div>
                <div><strong>Telefone 2</strong> ${func.telefone_2 || 'Não informado'}</div>
                <div><strong>Telefone 3</strong> ${func.telefone_3 || 'Não informado'}</div>
            </div>
        `;
        
        employeeModal.classList.remove('hidden');
    }

    async function openFormModal(id = null, status = 'ativo') {
        employeeForm.reset();
        navigateToStep(1);
        document.getElementById('form-modal-title').textContent = id ? 'Editar Funcionário' : 'Adicionar Funcionário';
        document.getElementById('employee-id').value = id || '';
        document.getElementById('employee-status').value = status;
        document.getElementById('data_movimentacao_label').textContent = status === 'ativo' ? 'Data de Admissão' : 'Data de Demissão';

        document.getElementById('children-list').innerHTML = '';
        document.getElementById('tem_filhos').value = 'nao';
        document.getElementById('children-dynamic-container').classList.add('hidden');

        document.getElementById('spouse-dynamic-container').classList.add('hidden');
        document.getElementById('conjuge_nome').value = '';
        document.getElementById('conjuge_data_nascimento').value = '';

        if (id) {
            const result = await fetchAPI(`action=get_funcionario&id=${id}`);
            if (result && result.data) {
                const func = result.data;
                const formFields = [
                    'nome', 'funcao', 'empresa', 'local', 'data_movimentacao', 'validade_cnh', 'validade_exame_medico', 
                    'validade_treinamento', 'validade_cct', 'validade_contrato_experiencia', 
                    'data_nascimento', 'rg', 'cpf', 'estado_civil', 'cnh_numero', 'telefone_1', 'telefone_2', 'telefone_3',
                    'email_pessoal', 'genero', 'cep', 'rua', 'numero', 'complemento', 'bairro', 'cidade', 'estado'
                ];
                formFields.forEach(field => {
                    const el = document.getElementById(field);
                    if (el) {
                        if (field === 'data_movimentacao') {
                            el.value = status === 'ativo' ? func.data_admissao : func.data_demissao;
                        } else {
                            el.value = func[field] || '';
                        }
                    }
                });

                if (func.estado_civil === 'Casado(a)' && func.dados_conjuge) {
                    document.getElementById('estado_civil').value = 'Casado(a)';
                    document.getElementById('spouse-dynamic-container').classList.remove('hidden');
                    try {
                        const conjuge = JSON.parse(func.dados_conjuge);
                        document.getElementById('conjuge_nome').value = conjuge.nome || '';
                        document.getElementById('conjuge_data_nascimento').value = conjuge.data_nascimento || '';
                    } catch(e) {}
                }

                if (parseInt(func.quantidade_filhos) > 0 && func.nome_filhos) {
                    document.getElementById('tem_filhos').value = 'sim';
                    document.getElementById('children-dynamic-container').classList.remove('hidden');
                    try {
                        const filhosArray = JSON.parse(func.nome_filhos);
                        if (Array.isArray(filhosArray)) {
                            filhosArray.forEach(filho => createChildEntry(filho));
                        }
                    } catch (e) {}
                }
            }
        }
        formModal.classList.remove('hidden');
    }

    async function renderFileExplorer(funcionarioId, pastaId, breadcrumb) {
        currentEmployeeId = funcionarioId;
        currentFolderId = pastaId;
        breadcrumbHistory = breadcrumb;

        document.getElementById('main-folder-view').classList.add('hidden');
        document.getElementById('file-explorer-view').classList.remove('hidden');
        
        const grid = document.getElementById('file-explorer-grid');
        const breadcrumbNav = document.getElementById('breadcrumb');
        grid.innerHTML = '<p>Carregando...</p>';

        const result = await fetchAPI(`action=listar_pastas_e_arquivos&funcionario_id=${funcionarioId}&parent_id=${pastaId}`);
        
        if (result && result.data) {
            grid.innerHTML = '';
            currentFolderId = result.data.current_folder_id;

            breadcrumbNav.innerHTML = breadcrumb.map((p, i) => 
                i === breadcrumb.length - 1 
                ? `<span>${p.nome}</span>` 
                : `<a href="#" data-folder-id="${p.id}" data-breadcrumb-index="${i}">${p.nome}</a> > `
            ).join('');

            result.data.pastas.forEach(p => {
                const item = document.createElement('div');
                item.className = 'explorer-item folder';
                item.dataset.folderId = p.id;
                item.innerHTML = `
                    <div class="item-actions">
                        <button class="action-btn edit" title="Renomear"><i class="fas fa-pen"></i></button>
                        <button class="action-btn delete" title="Excluir"><i class="fas fa-trash"></i></button>
                    </div>
                    <i class="fas fa-folder"></i>
                    <span>${p.nome_pasta}</span>
                `;
                item.addEventListener('click', (e) => {
                    if (e.target.closest('.item-actions')) return;
                    
                    const newBreadcrumb = [...breadcrumb, { id: p.id, nome: p.nome_pasta }];
                    renderFileExplorer(funcionarioId, p.id, newBreadcrumb);
                });
                grid.appendChild(item);
            });

            result.data.documentos.forEach(d => {
                const item = document.createElement('div');
                item.className = 'explorer-item file';
                item.dataset.documentId = d.id;
                let iconClass = 'fa-file';
                if (d.tipo_arquivo.includes('pdf')) iconClass = 'fa-file-pdf';
                if (d.tipo_arquivo.includes('image')) iconClass = 'fa-file-image';

                item.innerHTML = `
                    <div class="item-actions">
                        <button class="action-btn delete" title="Excluir"><i class="fas fa-trash"></i></button>
                    </div>
                    <i class="fas ${iconClass}"></i>
                    <span>${d.nome_original}</span>
                `;
                item.addEventListener('click', (e) => {
                    if (e.target.closest('.item-actions')) return;
                    window.open(d.caminho_arquivo, '_blank');
                });
                grid.appendChild(item);
            });

            if (grid.innerHTML === '') {
                grid.innerHTML = '<p>Esta pasta está vazia.</p>';
            }
        }
    }

    // =================================================================================
    // 6. LÓGICA DO DASHBOARD
    // =================================================================================
    function updateDashboardSummary() {
        if(document.getElementById('total-ativos')) {
            document.getElementById('total-ativos').textContent = masterEmployeeList.ativos.length;
        }
        if(document.getElementById('total-inativos')) {
            document.getElementById('total-inativos').textContent = masterEmployeeList.inativos.length;
        }
    }
    
    function initializeDashboard() {
        if (!dashboardInitialized) {
            setupDashboardListeners();
            dashboardInitialized = true;
        }
        loadDashboardData();
    }
    
    function setupDashboardListeners() {
        const datePicker = document.getElementById('date-picker');
        if(datePicker && !datePicker.value) {
            datePicker.value = getLocalDateAsString();
        }
        datePicker.addEventListener('change', loadDashboardData);
        document.getElementById('unit-filter').addEventListener('change', loadDashboardData);
        document.getElementById('company-filter-dashboard').addEventListener('change', loadDashboardData);
        document.querySelectorAll('#status-section .summary-card input').forEach(input => {
            input.addEventListener('input', updateChartAndTable);
        });
        document.getElementById('save-data-btn').addEventListener('click', saveData);
        document.getElementById('generate-pdf-btn').addEventListener('click', generatePDF);
        document.getElementById('prev-day-btn').addEventListener('click', () => changeDay(-1));
        document.getElementById('next-day-btn').addEventListener('click', () => changeDay(1));
    }
    
    async function loadDashboardData() {
        const datePicker = document.getElementById('date-picker');
        const companyFilter = document.getElementById('company-filter-dashboard');
        const unitFilter = document.getElementById('unit-filter');
        const displayDate = document.getElementById('dashboard-display-date');
        const data = datePicker.value;
        const empresa = companyFilter.value;
        const unidade = unitFilter.value;
        const dateObj = new Date(data + 'T12:00:00');
        displayDate.textContent = dateObj.toLocaleDateString('pt-BR', { dateStyle: 'full' });
        
        const unitTotalCountEl = document.getElementById('unit-total-count');
        if (unitTotalCountEl) {
            let listToCount = masterEmployeeList.ativos;
            if (empresa) {
                listToCount = listToCount.filter(f => f.empresa === empresa);
            }
            const totalNaUnidade = listToCount.filter(f => !unidade || f.local === unidade).length;
            unitTotalCountEl.textContent = totalNaUnidade;
        }

        const result = await fetchAPI(`action=get_status_diario&data=${data}&unidade=${unidade || 'Todos'}`);
        
        const inputs = {
            presentes: document.getElementById('input-presentes'),
            falta_injustificada: document.getElementById('input-falta_injustificada'),
            folga: document.getElementById('input-folga'),
            ferias: document.getElementById('input-ferias'),
            atestado: document.getElementById('input-atestado'),
        };

        if (result && result.data) {
            for (const key in inputs) {
                if(inputs[key]) inputs[key].value = result.data[key] || 0;
            }
        } else {
             for (const key in inputs) {
                if(inputs[key]) inputs[key].value = 0;
            }
        }
        updateChartAndTable();
    }

    function updateChartAndTable() {
        if (statusChartInstance) statusChartInstance.destroy();
        
        const inputs = {
            presentes: {el: document.getElementById('input-presentes'), label: 'Presentes'},
            falta_injustificada: {el: document.getElementById('input-falta_injustificada'), label: 'Faltas (Injus.)'},
            folga: {el: document.getElementById('input-folga'), label: 'Folga'},
            ferias: {el: document.getElementById('input-ferias'), label: 'Férias'},
            atestado: {el: document.getElementById('input-atestado'), label: 'Atestado'},
        };
        const summaryTableBody = document.getElementById('pdf-summary-table-body');
        const summaryTableTotal = document.getElementById('pdf-summary-table-total');
        if(!summaryTableBody || !summaryTableTotal) return;
        summaryTableBody.innerHTML = '';
        
        const labels = Object.values(inputs).map(item => item.label);
        const dataValues = Object.values(inputs).map(item => parseInt(item.el.value) || 0);
        let total = dataValues.reduce((sum, value) => sum + value, 0);

        dataValues.forEach((value, index) => {
            summaryTableBody.innerHTML += `<tr><td>${labels[index]}</td><td>${value}</td></tr>`;
        });
        summaryTableTotal.innerHTML = `<td><strong>Total</strong></td><td><strong>${total}</strong></td>`;

        const ctx = document.getElementById('statusChart').getContext('2d');
        statusChartInstance = new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: labels,
                datasets: [{
                    data: dataValues,
                    backgroundColor: ['#28a745', '#dc3545', '#17a2b8', '#fd7e14', '#ffc107'],
                    borderColor: body.classList.contains('dark-mode') ? '#1e1e3f' : '#fff', 
                    borderWidth: 4, 
                    hoverOffset: 4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { position: 'bottom', labels: { color: body.classList.contains('dark-mode') ? '#e0e0e0' : '#555' } },
                    datalabels: {
                        formatter: (value, context) => {
                            if (value === 0) return '';
                            const sum = context.chart.data.datasets[0].data.reduce((a, b) => a + b, 0);
                            if (sum === 0) return '0';
                            const percentage = (value / sum * 100).toFixed(0);
                            return `${value} (${percentage}%)`;
                        },
                        color: '#fff',
                        font: { weight: 'bold', size: 14 }
                    }
                }
            }
        });
    }

    async function saveData() {
        const formData = new FormData();
        formData.append('action', 'save_status_diario');
        formData.append('data', document.getElementById('date-picker').value);
        formData.append('unidade', document.getElementById('unit-filter').value || 'Todos');
        formData.append('presentes', document.getElementById('input-presentes').value);
        formData.append('falta_injustificada', document.getElementById('input-falta_injustificada').value);
        formData.append('folga', document.getElementById('input-folga').value);
        formData.append('ferias', document.getElementById('input-ferias').value);
        formData.append('atestado', document.getElementById('input-atestado').value);

        const result = await postAPI(formData);
        if (result && result.success) {
            showToast('Dados do dia salvos com sucesso!');
        } else {
            showToast('Falha ao salvar os dados.', 'error');
        }
    }

    function generatePDF() {
        const { jsPDF } = window.jspdf;
        const captureArea = document.getElementById('capture-area');
        const logoContainer = captureArea.querySelector('#pdf-logo-container');
        
        // Guarda o HTML original para restaurar depois
        const logoOriginalHtml = logoContainer.innerHTML;
        
        const empresaSelecionada = document.getElementById('company-filter-dashboard').value;
        const empresasDisponiveis = ["Tranquility", "GSM", "Protector", "GS1"];

        // Limpa o container de logos
        logoContainer.innerHTML = '';

        if (empresaSelecionada && empresaSelecionada !== 'Todas') {
            // Se UMA empresa foi selecionada
            const nomeLogo = empresaSelecionada.toLowerCase();
            const logoImg = document.createElement('img');
            logoImg.src = `assets/imagens/${nomeLogo}.png`;
            logoImg.alt = `Logo ${empresaSelecionada}`;
            logoImg.className = 'pdf-logo single-logo'; // Classe para um logo único ser maior
            logoContainer.appendChild(logoImg);
        } else {
            // Se "Todas as Empresas" foi selecionado, mostra todos os logos
            empresasDisponiveis.forEach(empresa => {
                const nomeLogo = empresa.toLowerCase();
                const logoImg = document.createElement('img');
                logoImg.src = `assets/imagens/${nomeLogo}.png`;
                logoImg.alt = `Logo ${empresa}`;
                logoImg.className = 'pdf-logo';
                logoContainer.appendChild(logoImg);
            });
        }

        const unit = document.getElementById('unit-filter').value;
        const date = document.getElementById('dashboard-display-date').textContent;
        const pdfSubtitle = captureArea.querySelector('.pdf-subtitle');
        if (pdfSubtitle) pdfSubtitle.textContent = `Empresa: ${empresaSelecionada || 'Todas'} | Unidade: ${unit || 'Todas'} - Data: ${date}`;
        
        showToast('Gerando PDF, por favor aguarde...');

        setTimeout(() => {
            html2canvas(captureArea, {
                scale: 2,
                useCORS: true,
                backgroundColor: body.classList.contains('dark-mode') ? '#1e1e3f' : '#ffffff'
            }).then(canvas => {
                const imgData = canvas.toDataURL('image/png');
                const pdf = new jsPDF({
                    orientation: 'landscape',
                    unit: 'mm',
                    format: 'a4'
                });
                const pdfWidth = pdf.internal.pageSize.getWidth();
                pdf.addImage(imgData, 'PNG', 10, 10, pdfWidth - 20, 0, undefined, 'FAST');
                pdf.save(`Relatorio_Diario_${(empresaSelecionada || 'Geral').replace(' ', '_')}_${document.getElementById('date-picker').value}.pdf`);

                // Restaura o logo original no HTML
                logoContainer.innerHTML = logoOriginalHtml;
            });
        }, 300); // Atraso para garantir o carregamento das imagens
    }

    function changeDay(offset) {
        const datePicker = document.getElementById('date-picker');
        const currentDate = new Date(datePicker.value + 'T12:00:00');
        currentDate.setDate(currentDate.getDate() + offset);
        datePicker.value = getLocalDateAsString(currentDate);
        datePicker.dispatchEvent(new Event('change'));
    }

    // =================================================================================
    // 7. EVENT LISTENERS GERAIS E INICIALIZAÇÃO
    // =================================================================================
    
    function initializeApp() {
        fetchAPI(`action=get_all_funcionarios`).then(result => {
            if (result && result.data) {
                masterEmployeeList = result.data;
                filterAndRenderLists(); 
            }
        });
        setupEventListeners();
    }
    
    function setupEventListeners() {
        setupInputMasks();
        
        populateSelectWithOptions('.company-filter, #empresa, #company-filter-dashboard', empresas, 'Todas as Empresas');
        populateSelectWithOptions('.location-filter, #local, #unit-filter', unidades, 'Todas as Unidades');

        navLinks.forEach(link => {
            link.addEventListener('click', (e) => {
                if (link.hash && !link.target) {
                    e.preventDefault();
                    window.history.pushState(null, '', link.hash);
                    handleRouteChange();
                }
            });
        });
        window.addEventListener('popstate', handleRouteChange);

        document.querySelectorAll('.filtros-container').forEach(container => {
            const inputs = container.querySelectorAll('.search-input, .company-filter, .location-filter, .gender-filter, .children-filter, .children-age-min-filter, .children-age-max-filter, .birthday-month-filter, .expiry-filter, .rehire-filter, .city-filter, .state-filter');
            let timer;
            inputs.forEach(input => {
                const eventType = ['SELECT', 'INPUT'].includes(input.tagName) ? 'change' : 'input';
                input.addEventListener(eventType, () => {
                    clearTimeout(timer);
                    timer = setTimeout(filterAndRenderLists, 350);
                });
            });
            
            const advancedBtn = container.querySelector('.advanced-filter-btn');
            if(advancedBtn) {
                advancedBtn.addEventListener('click', () => {
                    container.querySelector('.filtros-avancados').classList.toggle('open');
                });
            }
    
            const clearBtn = container.querySelector('.clear-filters-btn');
            if(clearBtn) {
                clearBtn.addEventListener('click', () => {
                    const advancedFilters = clearBtn.closest('.filtros-avancados');
                    if (advancedFilters) {
                        advancedFilters.querySelectorAll('input[type="text"], input[type="number"], select').forEach(input => {
                            if (input.tagName === 'SELECT') {
                                input.selectedIndex = 0;
                                if(input.classList.contains('children-filter')) {
                                    input.dispatchEvent(new Event('change'));
                                }
                            }
                            else input.value = '';
                        });
                    }
                    filterAndRenderLists();
                });
            }
        });
    
        const cepInput = document.getElementById('cep');
        if (cepInput) {
            cepInput.addEventListener('blur', (e) => fetchAddressByCep(e.target.value));
        }

        if (formNavNextBtn) {
            formNavNextBtn.addEventListener('click', () => {
                if (!validateStep(currentStep)) return;
                const formSteps = formWizard.querySelectorAll('.form-step');
                if (currentStep < formSteps.length) navigateToStep(currentStep + 1);
            });
        }
        if (formNavPrevBtn) {
            formNavPrevBtn.addEventListener('click', () => {
                if (currentStep > 1) navigateToStep(currentStep - 1);
            });
        }
        
        if (employeeForm) {
            employeeForm.addEventListener('submit', async (e) => {
                e.preventDefault();
    
                const childrenData = [];
                document.querySelectorAll('.child-entry').forEach(entry => {
                    const name = entry.querySelector('.child-name').value;
                    const birthdate = entry.querySelector('.child-birthdate').value;
                    if (name) {
                        childrenData.push({ nome: name, data_nascimento: birthdate });
                    }
                });
                document.getElementById('quantidade_filhos').value = childrenData.length;
                document.getElementById('nome_filhos').value = JSON.stringify(childrenData);

                const conjugeNome = document.getElementById('conjuge_nome').value;
                const conjugeNascimento = document.getElementById('conjuge_data_nascimento').value;
                if (document.getElementById('estado_civil').value === 'Casado(a)' && conjugeNome) {
                    const conjugeData = { nome: conjugeNome, data_nascimento: conjugeNascimento };
                    document.getElementById('dados_conjuge').value = JSON.stringify(conjugeData);
                } else {
                    document.getElementById('dados_conjuge').value = '';
                }
    
                for(let i = 1; i <= 3; i++) {
                    if (!validateStep(i)) {
                        navigateToStep(i);
                        return;
                    }
                }
    
                const id = document.getElementById('employee-id').value;
                const action = id ? 'update_funcionario' : 'add_funcionario';
                const formData = new FormData(employeeForm);
                formData.append('action', action);
                
                if (await postAPI(formData)) {
                    formModal.classList.add('hidden');
                    showToast(`Funcionário ${id ? 'atualizado' : 'adicionado'} com sucesso.`);
                    clearAllFilters();
                    refreshDataAndRender();
                }
            });
        }
    
        if(appWrapper) {
            appWrapper.addEventListener('click', async (e) => {
                const addBtn = e.target.closest('.add-btn');
                if (addBtn) {
                    openFormModal(null, addBtn.dataset.status);
                    return;
                }
                const actionTarget = e.target.closest('[data-action]');
                if(actionTarget) {
                    const card = e.target.closest('.funcionario-card');
                    if (!card) return;
                    const funcId = card.dataset.id;
                    const func = [...masterEmployeeList.ativos, ...masterEmployeeList.inativos].find(f => f.id == funcId);
                    if (!func) return;
        
                    switch (actionTarget.dataset.action) {
                        case 'open-details': openEmployeeModal(func); break;
                        case 'edit': await openFormModal(funcId, func.status); break;
                        case 'delete':
                            if (confirm('Tem certeza que deseja excluir? Esta ação não pode ser desfeita.')) {
                                const formData = new FormData();
                                formData.append('action', 'delete_funcionario');
                                formData.append('id', funcId);
                                if (await postAPI(formData)) {
                                    showToast('Funcionário excluído.');
                                    refreshDataAndRender();
                                }
                            }
                            break;
                        case 'terminate':
                            const dataDemissao = prompt("Insira a data de demissão (AAAA-MM-DD):", getLocalDateAsString());
                            if (dataDemissao && /^\d{4}-\d{2}-\d{2}$/.test(dataDemissao)) {
                                const motivoDemissao = prompt("Insira o motivo do desligamento:", "");
                                const elegivelOptions = ['Sim', 'Não', 'Avaliar'];
                                const elegivelInput = prompt(`O funcionário é elegível para recontratação?\nOpções: ${elegivelOptions.join(', ')}`, "Avaliar");
                                const elegivelRecontratacao = elegivelOptions.includes(elegivelInput) ? elegivelInput : 'Avaliar';

                                const formData = new FormData();
                                formData.append('action', 'terminate_funcionario');
                                formData.append('id', funcId);
                                formData.append('data_demissao', dataDemissao);
                                formData.append('motivo_demissao', motivoDemissao);
                                formData.append('elegivel_recontratacao', elegivelRecontratacao);

                                if (await postAPI(formData)) {
                                    showToast('Contrato encerrado.');
                                    refreshDataAndRender();
                                }
                            } else if (dataDemissao !== null) {
                                alert('Formato de data inválido. Use AAAA-MM-DD.');
                            }
                            break;
                    }
                }
            });
        }
        
        if(employeeModal) {
            employeeModal.addEventListener('click', async (e) => {
                const target = e.target;
                const item = target.closest('.explorer-item');

                const tabBtn = target.closest('.tab-btn');
                const folder = target.closest('#main-folder-view .folder');
                const breadcrumbLink = target.closest('#breadcrumb a');
                const backBtn = target.closest('#back-to-folders-btn');
                const createFolderBtn = target.closest('#create-folder-btn');
                const editFolderBtn = target.closest('.item-actions .edit');
                const deleteFolderBtn = target.closest('.item-actions .delete');

                if (tabBtn) {
                    const tabId = tabBtn.dataset.tab;
                    employeeModal.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
                    employeeModal.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));
                    tabBtn.classList.add('active');
                    document.getElementById(tabId).classList.add('active');
                }
                
                if (folder && currentEmployeeId) {
                    const folderName = folder.dataset.folderName;
                    const result = await fetchAPI(`action=get_folder_id_by_name&funcionario_id=${currentEmployeeId}&folder_name=${folderName}`);
                    
                    if (result.success) {
                        const breadcrumb = [{ id: null, nome: 'Raiz' }, { id: result.folder_id, nome: folderName }];
                        renderFileExplorer(currentEmployeeId, result.folder_id, breadcrumb);
                    } else {
                        showToast('Erro ao encontrar a pasta.', 'error');
                    }
                }

                if (breadcrumbLink) {
                    e.preventDefault();
                    const folderId = breadcrumbLink.dataset.folderId === 'null' ? null : breadcrumbLink.dataset.folderId;
                    const breadcrumbIndex = parseInt(breadcrumbLink.dataset.breadcrumbIndex);
                    const newBreadcrumb = breadcrumbHistory.slice(0, breadcrumbIndex + 1);
                    renderFileExplorer(currentEmployeeId, folderId, newBreadcrumb);
                }

                if (backBtn) {
                    if (breadcrumbHistory.length > 2) {
                        breadcrumbHistory.pop();
                        const previousFolder = breadcrumbHistory[breadcrumbHistory.length - 1];
                        renderFileExplorer(currentEmployeeId, previousFolder.id, breadcrumbHistory);
                    } else {
                        document.getElementById('file-explorer-view').classList.add('hidden');
                        document.getElementById('main-folder-view').classList.remove('hidden');
                    }
                }

                if (createFolderBtn) {
                    const nomePasta = prompt("Digite o nome da nova subpasta:");
                    if (nomePasta && currentEmployeeId && currentFolderId) {
                        const formData = new FormData();
                        formData.append('action', 'criar_pasta');
                        formData.append('funcionario_id', currentEmployeeId);
                        formData.append('parent_id', currentFolderId);
                        formData.append('nome_pasta', nomePasta);
                        if (await postAPI(formData)) {
                            renderFileExplorer(currentEmployeeId, currentFolderId, breadcrumbHistory);
                        }
                    }
                }

                if (editFolderBtn) {
                    const folderId = item.dataset.folderId;
                    const spanNome = item.querySelector('span');
                    const nomeAtual = spanNome.textContent;
                    
                    const novoNome = prompt("Digite o novo nome da pasta:", nomeAtual);
                    if (novoNome && novoNome !== nomeAtual) {
                        const formData = new FormData();
                        formData.append('action', 'renomear_pasta');
                        formData.append('pasta_id', folderId);
                        formData.append('novo_nome', novoNome);
                        if (await postAPI(formData)) {
                            renderFileExplorer(currentEmployeeId, currentFolderId, breadcrumbHistory);
                            showToast('Pasta renomeada com sucesso!');
                        }
                    }
                }
                
                if (deleteFolderBtn) {
                    const folderId = item.dataset.folderId;
                    const documentId = item.dataset.documentId;
                    
                    if (folderId) {
                        const nomePasta = item.querySelector('span').textContent;
                        if (confirm(`Tem certeza que deseja excluir a subpasta "${nomePasta}"?\n\nAVISO: A pasta deve estar vazia.`)) {
                            const formData = new FormData();
                            formData.append('action', 'excluir_pasta');
                            formData.append('pasta_id', folderId);
                            const result = await postAPI(formData);
                            if (result && result.success) {
                                renderFileExplorer(currentEmployeeId, currentFolderId, breadcrumbHistory);
                                showToast('Pasta excluída com sucesso!');
                            }
                        }
                    } else if (documentId) {
                        if (confirm('Tem certeza que deseja excluir este arquivo?')) {
                            const formData = new FormData();
                            formData.append('action', 'excluir_arquivo');
                            formData.append('documento_id', documentId);
                            if (await postAPI(formData)) {
                                renderFileExplorer(currentEmployeeId, currentFolderId, breadcrumbHistory);
                                showToast('Arquivo excluído com sucesso!');
                            }
                        }
                    }
                }
            });
        }
    
        document.getElementById('file-upload-input')?.addEventListener('change', (e) => {
            if (e.target.files.length > 0) {
                handleFileUpload(e.target.files[0]);
                e.target.value = '';
            }
        });

        document.querySelectorAll('.modal-overlay').forEach(modal => {
            modal.addEventListener('click', e => {
                if (e.target === modal || e.target.closest('.modal-close-btn')) {
                    modal.classList.add('hidden');
                }
            });
        });
        
        if(menuToggle) {
            menuToggle.addEventListener('click', () => mainNav.classList.toggle('active'));
        }

        document.querySelectorAll('.children-filter').forEach(select => {
            select.addEventListener('change', (e) => {
                const parent = e.target.closest('.filter-group-dynamic');
                const subFilter = parent.querySelector('.sub-filter');
                if (e.target.value === 'sim') {
                    subFilter.classList.remove('hidden');
                } else {
                    subFilter.classList.add('hidden');
                    // Limpa os campos de idade se o usuário mudar a opção
                    subFilter.querySelector('.children-age-min-filter').value = '';
                    subFilter.querySelector('.children-age-max-filter').value = '';
                }
            });
        });

        const temFilhosSelect = document.getElementById('tem_filhos');
        const childrenContainer = document.getElementById('children-dynamic-container');
        const addChildBtn = document.getElementById('add-child-btn');

        if (temFilhosSelect) {
            temFilhosSelect.addEventListener('change', () => {
                if (temFilhosSelect.value === 'sim') {
                    childrenContainer.classList.remove('hidden');
                    if (document.getElementById('children-list').children.length === 0) {
                        createChildEntry();
                    }
                } else {
                    childrenContainer.classList.add('hidden');
                    document.getElementById('children-list').innerHTML = '';
                }
            });
        }
        
        if (addChildBtn) {
            addChildBtn.addEventListener('click', createChildEntry);
        }

        const estadoCivilSelect = document.getElementById('estado_civil');
        const spouseContainer = document.getElementById('spouse-dynamic-container');

        if (estadoCivilSelect) {
            estadoCivilSelect.addEventListener('change', () => {
                if (estadoCivilSelect.value === 'Casado(a)') {
                    spouseContainer.classList.remove('hidden');
                } else {
                    spouseContainer.classList.add('hidden');
                    document.getElementById('conjuge_nome').value = '';
                    document.getElementById('conjuge_data_nascimento').value = '';
                }
            });
        }
    }
    
    // Inicialização do Login e Tema
    if(loginForm) {
        loginForm.addEventListener('submit', (e) => {
            e.preventDefault();
            const user = document.getElementById('username').value.trim();
            const pass = document.getElementById('password').value.trim();
            if (user === 'admin' && pass === 'admin') {
                loginContainer.style.opacity = 0;
                setTimeout(() => {
                    loginContainer.classList.add('hidden');
                    appWrapper.classList.remove('hidden');
                    initializeApp();
                }, 400);
            } else {
                const loginError = document.getElementById('login-error');
                 loginError.textContent = 'Usuário ou senha inválidos.';
                 loginForm.parentElement.classList.add('shake');
                 setTimeout(() => loginForm.parentElement.classList.remove('shake'), 500);
            }
        });
    }

    const passwordInput = document.getElementById('password');
    const togglePassword = document.getElementById('toggle-password');
    if (togglePassword && passwordInput) {
        togglePassword.addEventListener('click', function() {
            const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
            passwordInput.setAttribute('type', type);
            this.querySelector('i').classList.toggle('fa-eye');
            this.querySelector('i').classList.toggle('fa-eye-slash');
        });
    }

    const forgotPasswordLink = document.getElementById('forgot-password-link');
    if(forgotPasswordLink) {
        forgotPasswordLink.addEventListener('click', function(e){
            e.preventDefault();
            alert('Funcionalidade "Esqueci minha senha" em desenvolvimento.');
        });
    }

    const savedTheme = localStorage.getItem('theme') || 'light';
    applyTheme(savedTheme);
    if(themeToggle) {
        themeToggle.addEventListener('click', () => {
            const newTheme = body.classList.contains('dark-mode') ? 'light' : 'dark';
            applyTheme(newTheme);
        });
    }

});

// assets/js/script.js - Versão Final Atualizada

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
    
    // Elementos de Notificação
    const notificationToggle = document.getElementById('notification-toggle');
    const notificationPanel = document.getElementById('notification-panel');
    const notificationCount = document.getElementById('notification-count');
    const onloadNotificationPopup = document.getElementById('onload-notification-popup');

    // Inicialização das listas de funcionários
    let masterEmployeeList = { ativos: [], afastados: [], inativos: [] };
    
    let statusChartInstance = null;
    let dashboardInitialized = false;
    const API_URL = 'backend/api.php';
    
    let currentEmployeeId = null;
    let currentFolderId = null;
    let breadcrumbHistory = [];

    const empresas = ["Tranquility", "GSM", "Protector", "GS1"];
    const unidades = [
        "Administrativo", "GS1","Prevent Sênior - Hospital Madri", "IGESP - Hospital Praia Grande", "IGESP - Hospital Santo Amaro", "IGESP - Pronto Atendimento Santos",
        "IGESP - Pronto Atendimento Santo André", "IGESP - Pronto Atendimento Congonhas", "IGESP - Pronto Atendimento Anália Franco",
        "Grupo Santa Marcelina Itaquera - Sede", "Grupo Santa Marcelina Itaquera - AME", "Grupo Santa Marcelina Itaquera - Instituto",
        "Grupo Santa Marcelina Itaquera - Torre", "Grupo Santa Marcelina Itaquera - Faculdade Santa Marcelina",
        "Grupo Santa Marcelina Regionais - Hospital Cidade Tiradentes", "Grupo Santa Marcelina Regionais - Hospital Itaim",
        "Grupo Santa Marcelina Regionais - Hospital Itaquá", "Grupo Santa Marcelina Regionais - Hospital Neomater SBC",
        "Hapvida", "Espaço HAOC", "São Carlos - Santa Casa", "São Carlos - CID", "São Carlos - Onovolab" , "Operador (a) Folguista"  , "Faxineiro (a) Rotativo"
    ];

    if (typeof Chart !== 'undefined' && typeof ChartDataLabels !== 'undefined') {
        Chart.register(ChartDataLabels);
    }

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
    // 3. FUNÇÕES HELPERS (API, Toast, Modais, etc)
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
            if (response.status === 401) {
                if (window.location.pathname.includes('index.php')) {
                    window.location.href = 'login.php';
                }
                return null;
            }
            if (!response.ok) throw new Error(`Erro de rede: ${response.status}`);
            const result = await response.json();
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
            if (response.status === 401) {
                if (window.location.pathname.includes('index.php')) {
                    window.location.href = 'login.php';
                }
                return null;
            }
            if (!response.ok) throw new Error(`Erro de rede: ${response.status}`);
            const result = await response.json();
             if (!result.success && formData.get('action') !== 'login' && formData.get('action') !== 'esqueci_senha') {
                 throw new Error(result.message || 'Erro ao enviar dados.');
            }
            return result;
        } catch (error) {
            console.error("Erro ao enviar dados para API:", error);
            showToast(error.message, 'error');
            return { success: false, message: error.message };
        }
    }

    function showToast(message, type = 'success') {
        const toast = document.getElementById('toast');
        if (!toast) return;
        toast.textContent = message;
        toast.className = `show ${type === 'error' ? 'error' : ''}`;
        setTimeout(() => { toast.className = toast.className.replace("show", ""); }, 3000);
    }
    
    function showConfirmationModal({ title, message, keyword, onConfirm }) {
        const modal = document.getElementById('modal-confirmacao');
        if (!modal) return;

        modal.querySelector('#titulo-confirmacao').textContent = title;
        modal.querySelector('#mensagem-confirmacao').innerHTML = message;
        modal.querySelector('#palavra-chave-confirmacao').textContent = keyword;

        const input = modal.querySelector('#input-confirmacao');
        const confirmBtn = modal.querySelector('.confirm-btn');
        const cancelBtn = modal.querySelector('.cancel-btn');
        const closeBtn = modal.querySelector('.modal-close-btn');

        input.value = '';
        confirmBtn.disabled = true;
        
        const newConfirmBtn = confirmBtn.cloneNode(true);
        confirmBtn.parentNode.replaceChild(newConfirmBtn, confirmBtn);
        
        const inputHandler = () => {
            newConfirmBtn.disabled = input.value !== keyword;
        };
        input.addEventListener('input', inputHandler);

        const confirmHandler = () => {
            onConfirm();
            closeModal();
        };
        newConfirmBtn.addEventListener('click', confirmHandler, { once: true });

        const closeModal = () => {
            modal.classList.add('hidden');
            input.removeEventListener('input', inputHandler);
        };

        cancelBtn.onclick = closeModal;
        closeBtn.onclick = closeModal;
        modal.onclick = (e) => {
            if (e.target === modal) {
                closeModal();
            }
        };
        
        modal.classList.remove('hidden');
        input.focus();
    }

    function showInputModal({ title, message, placeholder, onConfirm }) {
        const modal = document.getElementById('modal-input');
        if (!modal) return;

        modal.querySelector('#input-modal-title').textContent = title;
        modal.querySelector('#input-modal-message').textContent = message;
        
        const inputField = modal.querySelector('#input-modal-field');
        inputField.placeholder = placeholder;
        inputField.value = '';

        const confirmBtn = modal.querySelector('.confirm-btn');
        const cancelBtn = modal.querySelector('.cancel-btn');
        const closeBtn = modal.querySelector('.modal-close-btn');

        const newConfirmBtn = confirmBtn.cloneNode(true);
        confirmBtn.parentNode.replaceChild(newConfirmBtn, confirmBtn);

        const confirmHandler = () => {
            const value = inputField.value.trim();
            if (value) {
                onConfirm(value);
                closeModal();
            } else {
                showToast('O nome não pode estar vazio.', 'error');
            }
        };

        const closeModal = () => {
            modal.classList.add('hidden');
        };

        newConfirmBtn.addEventListener('click', confirmHandler, { once: true });
        cancelBtn.addEventListener('click', closeModal, { once: true });
        closeBtn.addEventListener('click', closeModal, { once: true });
        
        modal.classList.remove('hidden');
        inputField.focus();
    }

    function setupInputMasks() {
        if (!window.IMask) return;
        const phoneMask = { mask: '(00) 00000-0000' };
        const cpfMask = { mask: '000.000.000-00' };
        const cepMask = { mask: '00000-000' };
    
        const tel1 = document.getElementById('telefone_1');
        const tel2 = document.getElementById('telefone_2');
        const tel3 = document.getElementById('telefone_3');
        const cpf = document.getElementById('cpf');
        const cep = document.getElementById('cep');

        if(tel1) IMask(tel1, phoneMask);
        if(tel2) IMask(tel2, phoneMask);
        if(tel3) IMask(tel3, phoneMask);
        if(cpf) IMask(cpf, cpfMask);
        if(cep) IMask(cep, cepMask);
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
            filterAndRenderLists(); 
            fetchAndRenderNotifications();
        }
    }

    function createChildEntry(child = {}) {
        const childrenList = document.getElementById('children-list');
        if(!childrenList) return;
        const entryDiv = document.createElement('div');
        entryDiv.className = 'child-entry';
        entryDiv.innerHTML = `
            <input type="text" placeholder="Nome do filho(a)" class="child-name" value="${child.nome || ''}">
            <input type="date" class="child-birthdate" value="${child.data_nascimento || ''}">
            <button type="button" class="remove-child-btn"><i class="fas fa-trash"></i></button>
        `;
        childrenList.appendChild(entryDiv);
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
            const currentValue = select.value;
            select.innerHTML = `<option value="">${defaultLabel}</option>`;
            options.forEach(opt => {
                const optionEl = document.createElement('option');
                optionEl.value = opt;
                optionEl.textContent = opt;
                select.appendChild(optionEl);
            });
            select.value = currentValue;
        });
    }

    // =================================================================================
    // FUNÇÕES DO PAINEL (INDEX.PHP)
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
    
        if (hash === '#funcionarios' || hash === '#inativos' || hash === '#afastados') {
            filterAndRenderLists();
        }
    
        if (hash === '#status') {
            if (!dashboardInitialized) {
                fetchAPI(`action=get_all_funcionarios`).then(result => {
                    if (result && result.data) {
                        masterEmployeeList = result.data;
                        updateDashboardSummary();
                        initializeDashboard();
                    }
                });
            } else {
                 loadDashboardData();
            }
        }
    }
    
    function filterAndRenderLists() {
        const listMap = { 
            'ativos': 'funcionarios-section', 
            'afastados': 'afastados-section', 
            'inativos': 'inativos-section' 
        };
    
        for (const [type, sectionId] of Object.entries(listMap)) {
            const section = document.querySelector(`#${sectionId}`);
            if (!section || !section.classList.contains('active')) continue;
            
            const container = section.querySelector('.filtros-container');
            const grid = section.querySelector('.funcionarios-grid');
            const sourceList = masterEmployeeList[type] || [];
            if (!container || !grid) continue;
    
            const filters = {
                nome: container.querySelector('.search-input').value.toLowerCase(),
                empresa: container.querySelector('.company-filter')?.value,
                unidade: container.querySelector('.location-filter')?.value,
                genero: container.querySelector('.gender-filter')?.value,
                status_filhos: container.querySelector('.children-filter')?.value,
                idade_filho_min: container.querySelector('.children-age-min-filter')?.value,
                idade_filho_max: container.querySelector('.children-age-max-filter')?.value,
                mes_aniversario: container.querySelector('.birthday-month-filter')?.value,
                cidade: container.querySelector('.city-filter')?.value.toLowerCase(),
                estado: container.querySelector('.state-filter')?.value,
                vencimento: container.querySelector('.expiry-filter')?.value,
                recontratacao: container.querySelector('.rehire-filter')?.value,
                transporte: container.querySelector('.transport-filter')?.value
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
            if (filters.transporte) {
                filteredList = filteredList.filter(func => func.opcao_transporte === filters.transporte);
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

        if (func.empresa) {
            const empresaClass = `empresa-${func.empresa.toLowerCase().replace(/\s+/g, '')}`;
            card.classList.add(empresaClass);
        }
        
        const dataLabel = func.status === 'ativo' ? 'Admissão' : (func.status === 'afastado' ? 'Afastamento' : 'Demissão');
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

    async function fetchAndRenderNotifications() {
        const result = await fetchAPI('action=get_notifications');
        if (!notificationCount) return;

        // Resetar estado da UI (checkboxes e botões) antes de renderizar
        resetNotificationUI();

        let notificationStatus = JSON.parse(localStorage.getItem('notificationStatus')) || {};
        let statusChanged = false;

        // Limpeza automática da lixeira (itens com mais de 30 dias na lixeira)
        const thirtyDaysAgo = new Date();
        thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
        for (const id in notificationStatus) {
            const item = notificationStatus[id];
            if (item.status === 'trashed' && new Date(item.trashed_at) < thirtyDaysAgo) {
                item.status = 'deleted';
                statusChanged = true;
            }
        }

        if (result && result.data) {
            const apiNotifications = [
                ...result.data.vencimentos,
                ...result.data.datas_importantes
            ];
            
            // Filtro e Preparação das Notificações Válidas
            const validNotificationIds = new Set();

            apiNotifications.forEach(item => {
                // FILTRO DE CONTRATO DE EXPERIÊNCIA (REGRA DOS 10 DIAS)
                if (item.tipo.includes('Contrato') || item.tipo.includes('contrato')) {
                     const dataEvento = new Date(item.data_evento + 'T12:00:00');
                     const hoje = new Date();
                     hoje.setHours(0,0,0,0);
                     const diffTime = dataEvento - hoje;
                     const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
                     
                     // Se faltar mais de 10 dias, ignora este item (não adiciona ao localStorage)
                     if (diffDays > 10) {
                         return;
                     }
                }

                const notificationId = `${item.tipo}-${item.id}-${item.data_evento}`;
                validNotificationIds.add(notificationId); // Marca como válida

                if (!notificationStatus[notificationId]) {
                    notificationStatus[notificationId] = { status: 'pending', item_data: item, trashed_at: null };
                    statusChanged = true;
                }
            });

            // --- SINCRONIZAÇÃO AUTOMÁTICA (LIMPEZA) ---
            // Se uma notificação estava no localStorage, mas NÃO veio da API agora 
            // (significa que o funcionário foi afastado/inativado ou documento renovado), removemos.
            for (const id in notificationStatus) {
                // Se o ID não está na lista de válidos da API (e não é um item deletado logicamente)
                if (!validNotificationIds.has(id) && notificationStatus[id].status !== 'deleted') {
                    // Remove do objeto local
                    delete notificationStatus[id];
                    statusChanged = true;
                }
            }
        }

        if (statusChanged) {
            localStorage.setItem('notificationStatus', JSON.stringify(notificationStatus));
        }
        
        const pendentesWrapper = document.getElementById('pendentes-list')?.querySelector('.notification-items-wrapper');
        const lidasWrapper = document.getElementById('lidas-list')?.querySelector('.notification-items-wrapper');
        const lixeiraWrapper = document.getElementById('lixeira-list')?.querySelector('.notification-items-wrapper');

        if(!pendentesWrapper || !lidasWrapper || !lixeiraWrapper) return;

        pendentesWrapper.innerHTML = '';
        lidasWrapper.innerHTML = '';
        lixeiraWrapper.innerHTML = '';

        const allStoredNotifications = Object.values(notificationStatus);
        const notificationsToRender = allStoredNotifications.filter(item => item.status !== 'deleted');

        let unreadCount = 0;

        if (notificationsToRender.length === 0) {
            pendentesWrapper.innerHTML = '<p class="no-notifications">Nenhuma notificação pendente.</p>';
            lidasWrapper.innerHTML = '<p class="no-notifications">Nenhuma notificação lida.</p>';
            lixeiraWrapper.innerHTML = '<p class="no-notifications">Lixeira vazia.</p>';
        } else {
            
            // --- ORDENAÇÃO: 1º Aniversário, 2º Vencidos, 3º A Vencer ---
            notificationsToRender.sort((a,b) => {
                if (!a.item_data || !b.item_data) return 0;

                const getPriority = (item) => {
                    const hoje = new Date(); hoje.setHours(0,0,0,0);
                    const dataEvento = new Date(item.data_evento + 'T12:00:00');
                    
                    if (item.tipo === 'Aniversário') return 1; // Prioridade Máxima
                    if (dataEvento <= hoje) return 2;          // Vencidos (ou vence hoje)
                    return 3;                                  // Vencendo futuramente
                };

                const pA = getPriority(a.item_data);
                const pB = getPriority(b.item_data);

                if (pA !== pB) {
                    return pA - pB;
                }
                
                // Se prioridade for igual, ordena por data (mais antigo primeiro)
                return new Date(a.item_data.data_evento) - new Date(b.item_data.data_evento);
            });
            // ---------------------------

            notificationsToRender.forEach(statusInfo => {
                if (!statusInfo || !statusInfo.item_data) return;
                
                const item = statusInfo.item_data;
                const notificationId = `${item.tipo}-${item.id}-${item.data_evento}`;
                const hoje = new Date(); hoje.setHours(0, 0, 0, 0);
                let statusClass = '', metaText = '', icon = '';

                if (item.tipo === 'Aniversário') {
                    const dataOriginal = new Date(item.data_evento + 'T12:00:00');
                    let aniverEsteAno = new Date(hoje.getFullYear(), dataOriginal.getMonth(), dataOriginal.getDate());
                    
                    // Se já passou este ano e não é hoje, calcula para o próximo
                    let targetDate = aniverEsteAno;
                    if (targetDate < hoje) {
                        targetDate = new Date(hoje.getFullYear() + 1, dataOriginal.getMonth(), dataOriginal.getDate());
                    }

                    const diffDays = Math.ceil((targetDate - hoje) / (1000 * 60 * 60 * 24));
                    
                    statusClass = 'aniversario'; icon = 'fa-birthday-cake';
                    if (diffDays === 0) metaText = `Aniversário Hoje!`;
                    else if (diffDays === 1) metaText = `Aniversário Amanhã`;
                    else metaText = `Aniversário em ${diffDays} dias`;

                } else {
                    const dataEvento = new Date(item.data_evento + 'T12:00:00');
                    const diffDays = Math.ceil((dataEvento - hoje) / (1000 * 60 * 60 * 24));
                    
                    if (diffDays < 0) { 
                        statusClass = 'vencido'; 
                        metaText = `Vencido há ${Math.abs(diffDays)} dias`; 
                    } else if (diffDays === 0) { 
                        statusClass = 'vencido'; 
                        metaText = `Vence Hoje!`; 
                    } else { 
                        statusClass = 'vencendo'; 
                        metaText = `Vence em ${diffDays} dias`; 
                    }
                    icon = 'fa-exclamation-triangle';
                }

                const checkboxHTML = `<input type="checkbox" class="notification-item-checkbox" data-notification-id="${notificationId}">`;
                const notificationHTML = `<div class="notification-item ${statusClass}" data-employee-id="${item.id}">${checkboxHTML}<div class="icon"><i class="fas ${icon}"></i></div><div class="notification-item-content"><p><strong>${item.tipo}</strong> de ${item.nome}</p><span class="meta">${metaText}</span></div></div>`;

                switch (statusInfo.status) {
                    case 'read':
                        lidasWrapper.innerHTML += notificationHTML;
                        break;
                    case 'trashed':
                        lixeiraWrapper.innerHTML += notificationHTML;
                        break;
                    case 'pending':
                        pendentesWrapper.innerHTML += notificationHTML;
                        unreadCount++;
                        break;
                }
            });
        }

        if (unreadCount > 0) {
            notificationCount.textContent = unreadCount;
            notificationCount.classList.remove('hidden');
        } else {
            notificationCount.classList.add('hidden');
        }
        
        showOnloadNotificationPopup(unreadCount);
    }

    function resetNotificationUI() {
        const lists = ['pendentes', 'lidas', 'lixeira'];
        lists.forEach(type => {
            const container = document.getElementById(`${type}-list`);
            if(container) {
                const selectAll = container.querySelector('.notification-select-all');
                if(selectAll) selectAll.checked = false;
                const buttons = container.querySelectorAll('.action-btn-lote');
                buttons.forEach(btn => btn.disabled = true);
            }
        });
    }

    function showOnloadNotificationPopup(unreadCount) {
        if (!onloadNotificationPopup) return;
        if (unreadCount > 0) {
            onloadNotificationPopup.classList.remove('hidden');
            onloadNotificationPopup.querySelector('.close-btn').addEventListener('click', () => {
                onloadNotificationPopup.classList.add('hidden');
            });
            setTimeout(() => {
                onloadNotificationPopup.classList.add('hidden');
            }, 10000);
        }
    }

    function removeNotificationsForEmployee(employeeId) {
        let notificationStatus = JSON.parse(localStorage.getItem('notificationStatus')) || {};
        const updatedStatus = Object.fromEntries(
            Object.entries(notificationStatus).filter(([notificationId]) => {
                const parts = notificationId.split('-');
                return parts[1] !== String(employeeId);
            })
        );
        localStorage.setItem('notificationStatus', JSON.stringify(updatedStatus));
    }
    
    // =================================================================================
    // LÓGICA DE MODAIS E FORMULÁRIO WIZARD
    // =================================================================================
    
    let currentStep = 1;

    function validateStep(stepNumber) {
        const formWizard = formModal.querySelector('.form-wizard');
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
        const progressBar = formModal.querySelector('.form-progress-bar');
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
        const formWizard = formModal.querySelector('.form-wizard');
        const formNavNextBtn = formModal.querySelector('.form-nav-btn.next');
        const formNavPrevBtn = formModal.querySelector('.form-nav-btn.prev');
        const formSubmitBtn = formModal.querySelector('.form-submit-btn');

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
        if(!employeeModal) return;
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
            'CNH': func.validade_cnh,
            'Exame Clínico': func.validade_exame_clinico,
            'Audiometria': func.validade_audiometria,
            'Eletrocardiograma': func.validade_eletrocardiograma,
            'Eletroencefalograma': func.validade_eletroencefalograma,
            'Glicemia': func.validade_glicemia,
            'Acuidade Visual': func.validade_acuidade_visual,
            'Treinamento': func.validade_treinamento,
            'Contrato de Experiência': func.validade_contrato_experiencia
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
        
        const transporte = func.opcao_transporte || 'Não Optante';
        let transporteDetalhesHtml = '';

        if (transporte === 'Vale Transporte') {
            transporteDetalhesHtml = `
                <div style="margin-top: 5px; font-size: 0.9em; color: #555; padding-left: 10px; border-left: 2px solid #ccc;">
                    <p style="margin: 2px 0;"><strong>Meio:</strong> ${func.meio_transporte || '-'}</p>
                    <p style="margin: 2px 0;"><strong>Qtd:</strong> ${func.qtd_transporte || '-'}</p>
                    <p style="margin: 2px 0;"><strong>Valor:</strong> ${func.valor_transporte || '-'}</p>
                </div>
            `;
        } else if (transporte === 'Auxílio Combustível') {
             transporteDetalhesHtml = `
                <div style="margin-top: 5px; font-size: 0.9em; color: #555; padding-left: 10px; border-left: 2px solid #ccc;">
                    <p style="margin: 2px 0;"><strong>Valor:</strong> ${func.valor_transporte || '-'}</p>
                </div>
            `;
        }

        const transporteHtml = `<div class="grid-full-width"><strong>Opção de Transporte</strong> ${transporte} ${transporteDetalhesHtml}</div>`;

        const enderecoCompleto = `${func.rua || ''}, ${func.numero || 'S/N'}${func.complemento ? ' - ' + func.complemento : ''}`;

        // Lógica para Data de Início na visualização
        const dataInicioFormatada = func.data_inicio && func.data_inicio !== '0000-00-00' 
            ? new Date(func.data_inicio + 'T12:00:00').toLocaleDateString('pt-BR') 
            : 'Não informado';

        tabPessoal.innerHTML = `
            <div class="info-pessoal-grid">
                ${historicoDemissaoHtml}
                
                <div><strong>Horário</strong> ${func.horario || 'Não informado'}</div>
                <div><strong>Data Início</strong> ${dataInicioFormatada}</div>
                <div><strong>PIS</strong> ${func.pis || 'Não informado'}</div>

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
                ${transporteHtml}
                <div><strong>Telefone Principal</strong> ${func.telefone_1 || 'Não informado'}</div>
                <div><strong>Telefone 2</strong> ${func.telefone_2 || 'Não informado'}</div>
                <div><strong>Telefone 3</strong> ${func.telefone_3 || 'Não informado'}</div>
            </div>
        `;
        
        employeeModal.classList.remove('hidden');
    }

    async function openFormModal(id = null, status = 'ativo') {
        if(!formModal || !employeeForm) return;
        employeeForm.reset();
        navigateToStep(1);
        document.getElementById('form-modal-title').textContent = id ? 'Editar Funcionário' : 'Adicionar Funcionário';
        document.getElementById('employee-id').value = id || '';
        
        // Define o status no select
        const statusSelect = document.getElementById('status');
        if (statusSelect) {
            statusSelect.value = status; 
        }
        
        const labelData = document.getElementById('data_movimentacao_label');
        if (status === 'ativo') labelData.textContent = 'Data de Admissão';
        else if (status === 'afastado') labelData.textContent = 'Data de Admissão'; 
        else labelData.textContent = 'Data de Demissão';

        document.getElementById('children-list').innerHTML = '';
        document.getElementById('tem_filhos').value = 'nao';
        document.getElementById('children-dynamic-container').classList.add('hidden');

        document.getElementById('spouse-dynamic-container').classList.add('hidden');
        document.getElementById('conjuge_nome').value = '';
        document.getElementById('conjuge_data_nascimento').value = '';

        // Esconde detalhes de transporte inicialmente (ATUALIZADO)
        const transportContainer = document.getElementById('transport-options-container');
        if(transportContainer) transportContainer.classList.add('hidden');

        if (id) {
            const result = await fetchAPI(`action=get_funcionario&id=${id}`);
            if (result && result.data) {
                const func = result.data;
                const formFields = [
                    'nome', 'funcao', 'empresa', 'local', 'data_movimentacao',
                    'horario', 'data_inicio', 'pis', // Novos campos adicionados na lista de carga
                    'validade_cnh', 'validade_treinamento', 'validade_contrato_experiencia',
                    'validade_exame_clinico', 'validade_audiometria', 'validade_eletrocardiograma', 
                    'validade_eletroencefalograma', 'validade_glicemia', 'validade_acuidade_visual',
                    'data_nascimento', 'rg', 'cpf', 'estado_civil', 'cnh_numero', 'telefone_1', 'telefone_2', 'telefone_3',
                    'email_pessoal', 'genero', 'cep', 'rua', 'numero', 'complemento', 'bairro', 'cidade', 'estado',
                    'opcao_transporte', 'meio_transporte', 'qtd_transporte', 'valor_transporte',
                    'status'
                ];
                formFields.forEach(field => {
                    const el = document.getElementById(field);
                    if (el) {
                        if (field === 'data_movimentacao') {
                            el.value = (func.status === 'ativo' || func.status === 'afastado') ? func.data_admissao : func.data_demissao;
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
        
        // Força a atualização visual dos detalhes de transporte
        const transportSelectModal = document.getElementById('opcao_transporte');
        if(transportSelectModal) {
            transportSelectModal.dispatchEvent(new Event('change'));
        }

        formModal.classList.remove('hidden');
    }

    function openTerminateModal(func) {
        const modal = document.getElementById('modal-encerrar-contrato');
        if (!modal) return;

        const form = modal.querySelector('#form-encerrar-contrato');
        const confirmInput = modal.querySelector('#input-encerrar-confirmacao');
        const submitBtn = modal.querySelector('button[type="submit"]');

        form.reset();
        form.dataset.employeeId = func.id;
        modal.querySelector('#nome-funcionario-encerrar').textContent = func.nome;

        submitBtn.disabled = true;
        confirmInput.value = ''; 

        const inputHandler = () => {
            if (confirmInput.value === 'CONFIRMAR') {
                submitBtn.disabled = false;
            } else {
                submitBtn.disabled = true;
            }
        };

        confirmInput.removeEventListener('input', inputHandler);
        confirmInput.addEventListener('input', inputHandler);

        modal.classList.remove('hidden');
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
    // LÓGICA DO DASHBOARD
    // =================================================================================
    function updateDashboardSummary() {
        if(document.getElementById('total-ativos')) document.getElementById('total-ativos').textContent = masterEmployeeList.ativos.length;
        if(document.getElementById('total-afastados')) document.getElementById('total-afastados').textContent = masterEmployeeList.afastados.length;
        if(document.getElementById('total-inativos')) document.getElementById('total-inativos').textContent = masterEmployeeList.inativos.length;
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
            let listToCount = [...masterEmployeeList.ativos, ...masterEmployeeList.afastados];
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
            afastados: document.getElementById('input-afastados'),
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
            falta_injustificada: {el: document.getElementById('input-falta_injustificada'), label: 'Faltas'},
            afastados: {el: document.getElementById('input-afastados'), label: 'Afastados'},
            folga: {el: document.getElementById('input-folga'), label: 'Folga'},
            ferias: {el: document.getElementById('input-ferias'), label: 'Férias'},
            atestado: {el: document.getElementById('input-atestado'), label: 'Atestado'},
        };
        const summaryTableBody = document.getElementById('pdf-summary-table-body');
        const summaryTableTotal = document.getElementById('pdf-summary-table-total');
        const chartElement = document.getElementById('statusChart');
        if(!summaryTableBody || !summaryTableTotal || !chartElement) return;

        summaryTableBody.innerHTML = '';
        
        const labels = Object.values(inputs).map(item => item.label);
        const dataValues = Object.values(inputs).map(item => parseInt(item.el.value) || 0);
        let total = dataValues.reduce((sum, value) => sum + value, 0);

        dataValues.forEach((value, index) => {
            summaryTableBody.innerHTML += `<tr><td>${labels[index]}</td><td>${value}</td></tr>`;
        });
        summaryTableTotal.innerHTML = `<td><strong>Total</strong></td><td><strong>${total}</strong></td>`;

        const ctx = chartElement.getContext('2d');
        statusChartInstance = new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: labels,
                datasets: [{
                    data: dataValues,
                    backgroundColor: ['#28a745', '#dc3545', '#6f42c1', '#17a2b8', '#fd7e14', '#ffc107'],
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
        formData.append('afastados', document.getElementById('input-afastados').value);
        formData.append('folga', document.getElementById('input-folga').value);
        formData.append('ferias', document.getElementById('input-ferias').value);
        formData.append('atestado', document.getElementById('input-atestado').value);

        const result = await postAPI(formData);
        if (result && result.success) {
            showToast('Dados do dia salvos com sucesso!');
        }
    }

    function generatePDF() {
        const { jsPDF } = window.jspdf;
        const captureArea = document.getElementById('capture-area');
        const logoContainer = captureArea.querySelector('#pdf-logo-container');
        
        const logoOriginalHtml = logoContainer.innerHTML;
        
        const empresaSelecionada = document.getElementById('company-filter-dashboard').value;
        const empresasDisponiveis = ["Tranquility", "GSM", "Protector", "GS1"];

        logoContainer.innerHTML = '';

        if (empresaSelecionada && empresaSelecionada !== 'Todas') {
            const nomeLogo = empresaSelecionada.toLowerCase();
            const logoImg = document.createElement('img');
            logoImg.src = `assets/imagens/${nomeLogo}.png`;
            logoImg.alt = `Logo ${empresaSelecionada}`;
            logoImg.className = 'pdf-logo single-logo';
            logoContainer.appendChild(logoImg);
        } else {
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

                logoContainer.innerHTML = logoOriginalHtml;
            });
        }, 300);
    }

    function changeDay(offset) {
        const datePicker = document.getElementById('date-picker');
        const currentDate = new Date(datePicker.value + 'T12:00:00');
        currentDate.setDate(currentDate.getDate() + offset);
        datePicker.value = getLocalDateAsString(currentDate);
        datePicker.dispatchEvent(new Event('change'));
    }

    // =================================================================================
    // 5. INICIALIZAÇÃO PRINCIPAL (Decide o que fazer com base na página)
    // =================================================================================

    function initializeApp() {
        fetchAPI(`action=get_all_funcionarios`).then(result => {
            if (result && result.data) {
                masterEmployeeList = result.data;
                filterAndRenderLists(); 
            }
        });
        fetchAndRenderNotifications();
        setupAppEventListeners();
        handleRouteChange();
    }
    
    function setupAppEventListeners() {
        setupInputMasks();

        // --- CORREÇÃO: LÓGICA DO TOGGLE DE NOTIFICAÇÕES ---
        if (notificationToggle) {
            notificationToggle.addEventListener('click', (e) => {
                e.stopPropagation();
                notificationPanel.classList.toggle('hidden');
            });
        }

        // Fecha o painel se clicar fora dele
        document.addEventListener('click', (e) => {
            if (notificationPanel && !notificationPanel.classList.contains('hidden')) {
                if (!notificationPanel.contains(e.target) && !notificationToggle.contains(e.target)) {
                    notificationPanel.classList.add('hidden');
                }
            }
        });
        
        // Lógica para as abas dentro do painel de notificação
        const notifTabs = document.querySelectorAll('.notification-tabs .tab-btn');
        notifTabs.forEach(tab => {
            tab.addEventListener('click', () => {
                notifTabs.forEach(t => t.classList.remove('active'));
                document.querySelectorAll('.notification-list-container').forEach(c => c.classList.remove('active'));
                
                tab.classList.add('active');
                const targetId = tab.dataset.tab + '-list';
                document.getElementById(targetId).classList.add('active');
            });
        });

        // --- LÓGICA DE SELEÇÃO E AÇÕES DAS NOTIFICAÇÕES (CORRIGIDA) ---
        const setupNotificationActions = () => {
            const lists = ['pendentes', 'lidas', 'lixeira'];
            
            lists.forEach(type => {
                const container = document.getElementById(`${type}-list`);
                if (!container) return;
                
                const selectAll = container.querySelector('.notification-select-all');
                
                // Toggle Select All
                if (selectAll) {
                    selectAll.addEventListener('change', (e) => {
                        const checkboxes = container.querySelectorAll('.notification-item-checkbox');
                        checkboxes.forEach(cb => cb.checked = e.target.checked);
                        updateActionButtonsState(container);
                    });
                }
                
                // Event Delegation para checkboxes dinâmicos
                container.addEventListener('change', (e) => {
                    if (e.target.classList.contains('notification-item-checkbox')) {
                        updateActionButtonsState(container);
                        if(selectAll) {
                            const total = container.querySelectorAll('.notification-item-checkbox').length;
                            const checked = container.querySelectorAll('.notification-item-checkbox:checked').length;
                            selectAll.checked = total > 0 && total === checked;
                        }
                    }
                });
            });

            function updateActionButtonsState(container) {
                const checkedCount = container.querySelectorAll('.notification-item-checkbox:checked').length;
                const buttons = container.querySelectorAll('.action-btn-lote');
                buttons.forEach(btn => btn.disabled = checkedCount === 0);
            }

            // Handler Genérico para Ações
            const handleAction = (containerId, newStatus, isPermanentDelete = false) => {
                const container = document.getElementById(containerId);
                const selected = container.querySelectorAll('.notification-item-checkbox:checked');
                if (selected.length === 0) return;

                const executeAction = () => {
                    let notificationStatus = JSON.parse(localStorage.getItem('notificationStatus')) || {};
                    
                    selected.forEach(cb => {
                        const id = cb.dataset.notificationId;
                        if (notificationStatus[id]) {
                            notificationStatus[id].status = newStatus;
                            if (newStatus === 'trashed') {
                                notificationStatus[id].trashed_at = new Date().toISOString();
                            } else if (newStatus === 'read') {
                                notificationStatus[id].trashed_at = null; // Recuperar
                            }
                        }
                    });

                    localStorage.setItem('notificationStatus', JSON.stringify(notificationStatus));
                    fetchAndRenderNotifications();
                    showToast(isPermanentDelete ? 'Notificações excluídas permanentemente.' : 'Status atualizado com sucesso.');
                };

                if (isPermanentDelete) {
                    showConfirmationModal({
                        title: 'Excluir Permanentemente',
                        message: 'Esta ação não pode ser desfeita. As notificações selecionadas não aparecerão novamente.',
                        keyword: 'CONFIRMAR',
                        onConfirm: executeAction
                    });
                } else {
                    executeAction();
                }
            };

            // Vínculo dos botões
            const btnRead = document.getElementById('mark-as-read-btn');
            if(btnRead) btnRead.addEventListener('click', () => handleAction('pendentes-list', 'read'));

            const btnTrash = document.getElementById('move-to-trash-btn');
            if(btnTrash) btnTrash.addEventListener('click', () => handleAction('lidas-list', 'trashed'));
            
            const btnRecover = document.getElementById('recover-from-trash-btn');
            if(btnRecover) btnRecover.addEventListener('click', () => handleAction('lixeira-list', 'read'));

            const btnDelete = document.getElementById('delete-permanently-btn');
            if(btnDelete) btnDelete.addEventListener('click', () => handleAction('lixeira-list', 'deleted', true));
        };
        
        setupNotificationActions();
        // --------------------------------------------------
        
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
            const inputs = container.querySelectorAll('.search-input, .company-filter, .location-filter, .gender-filter, .children-filter, .children-age-min-filter, .children-age-max-filter, .birthday-month-filter, .expiry-filter, .rehire-filter, .city-filter, .state-filter, .transport-filter');
            let timer;
            inputs.forEach(input => {
                const eventType = ['SELECT', 'INPUT'].includes(input.tagName) ? 'change' : 'input';
                input.addEventListener(eventType, () => {
                    clearTimeout(timer);
                    timer = setTimeout(filterAndRenderLists, 350);
                });
            });

            document.querySelectorAll('.children-filter').forEach(select => {
                select.addEventListener('change', (e) => {
                    const parent = e.target.closest('.filter-group-dynamic');
                    if(!parent) return;
                    const subFilter = parent.querySelector('.sub-filter');
                    if (e.target.value === 'sim') {
                        subFilter.classList.remove('hidden');
                    } else {
                        subFilter.classList.add('hidden');
                        subFilter.querySelector('.children-age-min-filter').value = '';
                        subFilter.querySelector('.children-age-max-filter').value = '';
                    }
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

        // Lógica para mostrar/ocultar campos de Transporte (Vale Transporte e Auxílio Combustível)
        const transportSelect = document.getElementById('opcao_transporte');
        const transportContainer = document.getElementById('transport-options-container');
        const vtFields = document.querySelectorAll('.vt-only');
        const valorLabel = document.getElementById('label-valor-transporte');

        if (transportSelect && transportContainer) {
            transportSelect.addEventListener('change', () => {
                const selected = transportSelect.value;
                
                if (selected === 'Vale Transporte' || selected === 'Auxílio Combustível') {
                    transportContainer.classList.remove('hidden');
                    
                    if (selected === 'Vale Transporte') {
                        // Caso VT: Mostra Meio e Quantidade
                        vtFields.forEach(el => el.classList.remove('hidden'));
                        if(valorLabel) valorLabel.textContent = 'Valor Total Diário';
                    } else {
                        // Caso Auxílio Combustível: Esconde Meio e Quantidade
                        vtFields.forEach(el => el.classList.add('hidden'));
                        
                        // Limpa os campos ocultos para não enviar dados errados
                        document.getElementById('meio_transporte').value = '';
                        document.getElementById('qtd_transporte').value = '';
                        
                        if(valorLabel) valorLabel.textContent = 'Valor do Auxílio';
                    }
                } else {
                    // Caso Não Optante
                    transportContainer.classList.add('hidden');
                    document.getElementById('meio_transporte').value = '';
                    document.getElementById('qtd_transporte').value = '';
                    document.getElementById('valor_transporte').value = '';
                }
            });
        }

        const temFilhosSelect = document.getElementById('tem_filhos');
        const childrenContainer = document.getElementById('children-dynamic-container');
        const addChildBtn = document.getElementById('add-child-btn');

        if (temFilhosSelect && childrenContainer) {
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

        if (estadoCivilSelect && spouseContainer) {
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

        const formWizard = formModal ? formModal.querySelector('.form-wizard') : null;
        const formNavNextBtn = formModal ? formModal.querySelector('.form-nav-btn.next') : null;
        const formNavPrevBtn = formModal ? formModal.querySelector('.form-nav-btn.prev') : null;

        if (formNavNextBtn && formWizard) {
            formNavNextBtn.addEventListener('click', () => {
                if (!validateStep(currentStep)) return;
                const formSteps = formWizard.querySelectorAll('.form-step');
                if (currentStep < formSteps.length) navigateToStep(currentStep + 1);
            });
        }
        if (formNavPrevBtn && formWizard) {
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

                for (let i = 1; i <= 3; i++) {
                    if (!validateStep(i)) {
                        navigateToStep(i);
                        return;
                    }
                }
                
                const handleFormSubmission = async () => {
                    const id = document.getElementById('employee-id').value;
                    const action = id ? 'update_funcionario' : 'add_funcionario';
                    const formData = new FormData(employeeForm);
                    formData.append('action', action);
                    
                    const result = await postAPI(formData);
                    if (result && result.success) {
                        formModal.classList.add('hidden');
                        showToast(`Funcionário ${id ? 'atualizado' : 'adicionado'} com sucesso.`);
                        clearAllFilters();
                        refreshDataAndRender();
                    }
                };

                const id = document.getElementById('employee-id').value;

                if (id) {
                    showConfirmationModal({
                        title: 'Confirmar Alterações',
                        message: 'Você confirma as alterações nos dados deste funcionário?',
                        keyword: 'SALVAR',
                        onConfirm: handleFormSubmission
                    });
                } else {
                    handleFormSubmission();
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
                    const func = [...masterEmployeeList.ativos, ...masterEmployeeList.afastados, ...masterEmployeeList.inativos].find(f => f.id == funcId);
                    if (!func) return;

                    switch (actionTarget.dataset.action) {
                        case 'open-details':
                            openEmployeeModal(func);
                            break;
                        case 'edit':
                            await openFormModal(funcId, func.status);
                            break;
                        case 'delete':
                            showConfirmationModal({
                                title: 'Excluir Funcionário',
                                message: `Você está prestes a excluir permanentemente o registro de "<strong>${func.nome}</strong>". Esta ação não pode ser desfeita.`,
                                keyword: 'EXCLUIR',
                                onConfirm: async () => {
                                    const formData = new FormData();
                                    formData.append('action', 'delete_funcionario');
                                    formData.append('id', funcId);
                                    const result = await postAPI(formData);
                                    if (result && result.success) {
                                        showToast('Funcionário excluído com sucesso.');
                                        removeNotificationsForEmployee(funcId);
                                        refreshDataAndRender();
                                    }
                                }
                            });
                            break;
                        case 'terminate':
                            openTerminateModal(func);
                            break;
                    }
                }
            });
        }
        
        if(employeeModal) {
            employeeModal.addEventListener('click', async (e) => {
                const target = e.target;

                const tabBtn = target.closest('.tab-btn');
                if (tabBtn) {
                    const tabName = tabBtn.dataset.tab;
                    employeeModal.querySelectorAll('.tab-btn, .tab-content').forEach(el => el.classList.remove('active'));
                    tabBtn.classList.add('active');
                    document.getElementById(tabName).classList.add('active');
                    return;
                }

                const folder = target.closest('.folder-grid .folder');
                if (folder) {
                    const folderName = folder.dataset.folderName;
                    const result = await fetchAPI(`action=get_folder_id_by_name&funcionario_id=${currentEmployeeId}&folder_name=${encodeURIComponent(folderName)}`);
                    if (result && result.folder_id) {
                        const breadcrumb = [{ id: result.folder_id, nome: folderName }];
                        renderFileExplorer(currentEmployeeId, result.folder_id, breadcrumb);
                    }
                    return;
                }
                
                if (target.closest('#back-to-folders-btn')) {
                    if (breadcrumbHistory.length > 1) {
                        breadcrumbHistory.pop();
                        const parentFolder = breadcrumbHistory[breadcrumbHistory.length - 1];
                        renderFileExplorer(currentEmployeeId, parentFolder.id, breadcrumbHistory);
                    } else {
                        document.getElementById('file-explorer-view').classList.add('hidden');
                        document.getElementById('main-folder-view').classList.remove('hidden');
                    }
                    return;
                }

                const breadcrumbLink = target.closest('#breadcrumb a');
                if (breadcrumbLink) {
                    e.preventDefault();
                    const folderId = breadcrumbLink.dataset.folderId;
                    const breadcrumbIndex = parseInt(breadcrumbLink.dataset.breadcrumbIndex);
                    const newBreadcrumb = breadcrumbHistory.slice(0, breadcrumbIndex + 1);
                    renderFileExplorer(currentEmployeeId, folderId, newBreadcrumb);
                    return;
                }
                
                if (target.closest('#create-folder-btn')) {
                    showInputModal({
                        title: 'Criar Nova Subpasta',
                        message: 'Digite o nome para a nova pasta.',
                        placeholder: 'Ex: Documentos 2025',
                        onConfirm: async (folderName) => {
                            const formData = new FormData();
                            formData.append('action', 'criar_pasta');
                            formData.append('funcionario_id', currentEmployeeId);
                            formData.append('parent_id', currentFolderId);
                            formData.append('nome_pasta', folderName);
                            const result = await postAPI(formData);
                            if (result && result.success) {
                                showToast('Pasta criada com sucesso.');
                                renderFileExplorer(currentEmployeeId, currentFolderId, breadcrumbHistory);
                            }
                        }
                    });
                    return;
                }
                
                const editBtn = target.closest('.action-btn.edit');
                if(editBtn) {
                    const item = editBtn.closest('.explorer-item');
                    if(item.classList.contains('folder')) {
                        const folderId = item.dataset.folderId;
                        const folderName = item.querySelector('span').textContent;
                        showInputModal({
                            title: 'Renomear Pasta',
                            message: `Digite o novo nome para a pasta "${folderName}".`,
                            placeholder: 'Novo nome da pasta',
                            onConfirm: async (newName) => {
                                const formData = new FormData();
                                formData.append('action', 'rename_folder');
                                formData.append('pasta_id', folderId);
                                formData.append('novo_nome', newName);
                                const result = await postAPI(formData);
                                if (result && result.success) {
                                    showToast('Pasta renomeada com sucesso.');
                                    const parentFolder = breadcrumbHistory[breadcrumbHistory.length - 1];
                                    renderFileExplorer(currentEmployeeId, parentFolder.id, breadcrumbHistory);
                                }
                            }
                        });
                    }
                    return;
                }

                const deleteBtn = target.closest('.action-btn.delete');
                if (deleteBtn) {
                    const item = deleteBtn.closest('.explorer-item');
                    if (item.classList.contains('folder')) {
                        const folderId = item.dataset.folderId;
                        const folderName = item.querySelector('span').textContent;
                        showConfirmationModal({
                            title: 'Excluir Pasta', 
                            message: `Tem certeza que deseja excluir a pasta "<strong>${folderName}</strong>"? A pasta só pode ser excluída se estiver vazia.`, 
                            keyword: 'EXCLUIR',
                            onConfirm: async () => {
                                const formData = new FormData();
                                formData.append('action', 'excluir_pasta');
                                formData.append('pasta_id', folderId);
                                const result = await postAPI(formData);
                                if (result && result.success) {
                                    showToast('Pasta excluída com sucesso.');
                                    const parentFolder = breadcrumbHistory[breadcrumbHistory.length - 1];
                                    renderFileExplorer(currentEmployeeId, parentFolder.id, breadcrumbHistory);
                                }
                            }
                        });
                    } else if (item.classList.contains('file')) {
                        const documentId = item.dataset.documentId;
                        const fileName = item.querySelector('span').textContent;
                        showConfirmationModal({
                            title: 'Excluir Arquivo', 
                            message: `Tem certeza que deseja excluir o arquivo "<strong>${fileName}</strong>"?`, 
                            keyword: 'CONFIRMAR',
                            onConfirm: async () => {
                                const formData = new FormData();
                                formData.append('action', 'excluir_arquivo');
                                formData.append('documento_id', documentId);
                                const result = await postAPI(formData);
                                if (result && result.success) {
                                    showToast('Arquivo excluído com sucesso.');
                                    renderFileExplorer(currentEmployeeId, currentFolderId, breadcrumbHistory);
                                }
                            }
                        });
                    }
                }
            });
        }

        const fileUploadInput = document.getElementById('file-upload-input');
        if(fileUploadInput) {
            fileUploadInput.addEventListener('change', (e) => {
                if (e.target.files.length > 0) {
                    handleFileUpload(e.target.files[0]);
                    e.target.value = '';
                }
            });
        }
        
        document.querySelectorAll('.modal-overlay').forEach(modal => {
            modal.addEventListener('click', e => {
                // Verifica se clicou no botão de fechar (O "X")
                if (e.target.closest('.modal-close-btn')) {
                    modal.classList.add('hidden');
                    return;
                }
                
                // Se clicou no overlay (fundo escuro fora do conteúdo)
                if (e.target === modal) {
                    // ALTERAÇÃO AQUI:
                    // Adicionamos "|| modal.id === 'employee-modal'"
                    // Agora ele ignora o clique fora tanto no Formulário quanto nos Detalhes do Funcionário
                    if (modal.id === 'form-modal' || modal.id === 'employee-modal') {
                        return; // Não faz nada, mantendo a janela aberta
                    }
                    // Para outros modais (como confirmações simples), fecha normalmente
                    modal.classList.add('hidden');
                }
            });
        });
        
        if(menuToggle) {
            menuToggle.addEventListener('click', () => mainNav.classList.toggle('active'));
        }
        
        const logoutBtn = document.getElementById('logout-btn');
        if (logoutBtn) {
            logoutBtn.addEventListener('click', () => {
                showConfirmationModal({
                    title: 'Confirmar Saída',
                    message: 'Tem certeza de que deseja sair do sistema? Para confirmar, digite <strong>SAIR</strong> abaixo.',
                    keyword: 'SAIR',
                    onConfirm: async () => {
                        await fetchAPI('action=logout');
                        window.location.href = 'login.php';
                        }
                });
            });
        }
    }

    if (loginForm) {
        // --- Lógica para a PÁGINA DE LOGIN (login.php) ---
        if (loginContainer) loginContainer.classList.remove('hidden');

        loginForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            const formData = new FormData(loginForm);
            formData.append('action', 'login');
            
            const result = await postAPI(formData);

            if (result && result.success && result.redirect_url) {
                window.location.href = result.redirect_url;
            } else {
                const loginError = document.getElementById('login-error');
                 if(loginError) loginError.textContent = result ? result.message : 'E-mail ou senha inválidos.';
                 const loginBox = document.querySelector('.login-box');
                 if(loginBox) {
                    loginBox.classList.add('shake');
                    setTimeout(() => loginBox.classList.remove('shake'), 500);
                 }
            }
        });

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
            forgotPasswordLink.addEventListener('click', async function(e){
                e.preventDefault();
                const emailInput = document.getElementById('email');
                if(!emailInput) return;
                const email = emailInput.value;

                if (!email) {
                    showToast('Por favor, digite seu e-mail para recuperar a senha.', 'error');
                    return;
                }
                const formData = new FormData();
                formData.append('action', 'esqueci_senha');
                formData.append('email', email);
                const result = await postAPI(formData);
                if(result) showToast(result.message);
            });
        }
    } else if (appWrapper) {
        // --- Lógica para o PAINEL PRINCIPAL (index.php) ---
        appWrapper.classList.remove('hidden');
        initializeApp();
    }
    
    // --- Lógica comum a ambas as páginas ---
    const savedTheme = localStorage.getItem('theme') || 'light';
    applyTheme(savedTheme);
    if(themeToggle) {
        themeToggle.addEventListener('click', () => {
            const newTheme = body.classList.contains('dark-mode') ? 'light' : 'dark';
            applyTheme(newTheme);
        });
    }
});

// script.js
document.addEventListener('DOMContentLoaded', async () => {
  // ======== SONS ========
  const correctSound   = new Audio('sounds/correct.mp3');
  const incorrectSound = new Audio('sounds/incorrect.mp3');
  const timeoutSound   = new Audio('sounds/timeout.mp3');
  const hintSound      = new Audio('sounds/hint.mp3');

  // --- Chaves e Funções de Progresso no localStorage ---
  const PROGRESS_KEY = 'quizProgress';
  function getProgress() {
    return JSON.parse(localStorage.getItem(PROGRESS_KEY) || '{}');
  }
  function setProgress(progress) {
    localStorage.setItem(PROGRESS_KEY, JSON.stringify(progress));
  }

  // --- Estado e Dados ---
  let quizData = {};
  let currentCategory = '';
  let currentLevel = '';
  let quizQuestions = [], currentQuestionIndex = 0, score = 0;
  let timerInterval, timeLeft;

  // --- Mapeamento de telas ---
  const screens = {
    welcome:     document.getElementById('welcomeScreen'),
    home:        document.getElementById('homeScreen'),
    settings:    document.getElementById('settingsScreen'),
    about:       document.getElementById('aboutScreen'),
    category:    document.getElementById('categoryScreen'),
    level:       document.getElementById('levelScreen'),
    question:    document.getElementById('questionScreen'),
    result:      document.getElementById('resultScreen'),
    history:     document.getElementById('historyScreen')
  };

  function show(screenKey) {
    Object.values(screens).forEach(s => s.classList.add('hidden'));
    screens[screenKey].classList.remove('hidden');
  }

  // --- Botões principais ---
  const startButton               = document.getElementById('startButton');
  const participantNameInput      = document.getElementById('participantName');
  const nameErrorDisplay          = document.getElementById('nameError');

  const playQuizButton            = document.getElementById('playQuizButton');
  const openSettingsButton        = document.getElementById('openSettingsButton');

  const changeDesignButton        = document.getElementById('changeDesignButton');
  const viewHistoryButton         = document.getElementById('viewHistoryButton');
  const aboutUsButton             = document.getElementById('aboutUsButton');

  const backFromSettings          = document.getElementById('backFromSettings');
  const backFromDesign            = document.getElementById('backFromDesign');

  const themeDefaultBtn           = document.getElementById('themeDefault');
  const themeFlatBtn              = document.getElementById('themeFlat');
  const themeNeonBtn              = document.getElementById('themeNeon');
  const themeStylesheetLink       = document.getElementById('themeStylesheet');

  const backFromAbout             = document.getElementById('backFromAbout');

  const backToHomeFromCategory    = document.getElementById('backToHomeFromCategory');
  const backToCategoryFromLevel   = document.getElementById('backToCategoryFromLevel');
  const backToLevelFromQuestion   = document.getElementById('backToLevelFromQuestion');
  const backFromHistory           = document.getElementById('backFromHistory');

  const playAgainButton           = document.getElementById('playAgainButton');
  const backToHomeFromResult      = document.getElementById('backToHomeFromResult');

  // --- Seletores de container para renderização dinâmica ---
  const categoryGrid              = document.getElementById('categorySelectionGrid');
  const levelGrid                 = document.getElementById('levelSelectionGrid');

  // --- Elementos da tela de perguntas ---
  const questionCategoryLevelTitle = document.getElementById('questionCategoryLevelTitle');
  const timerDisplay               = document.getElementById('timer');
  const questionTextElement        = document.getElementById('questionText');
  const optionsContainer           = document.getElementById('optionsContainer');
  const currentQuestionNumDisplay  = document.getElementById('currentQuestionNum');
  const totalQuestionsNumDisplay   = document.getElementById('totalQuestionsNum');
  const hintButton                 = document.getElementById('hintButton');
  const nextQuestionButton         = document.getElementById('nextQuestionButton');
  const feedbackMessageElement     = document.getElementById('feedbackMessage');

  // --- Tela de Resultado ---
  const finalScoreSpan             = document.getElementById('finalScore');
  const maxScoreSpan               = document.getElementById('maxScore');
  const resultMessageParagraph     = document.getElementById('resultMessage');

  // --- Tela de Histórico ---
  const historyListDiv             = document.getElementById('historyList');

  // ======================================
  // 1) Inicialização da página
  // ======================================
  // Tenta carregar nome salvo
  const savedParticipantName = localStorage.getItem('participantName');
  if (savedParticipantName) {
    participantNameInput.value = savedParticipantName;
  }
  // Salva nome digitado dinamicamente
  participantNameInput.addEventListener('input', () => {
    localStorage.setItem('participantName', participantNameInput.value.trim());
  });

  // Carrega dados do XML de perguntas
  await loadQuizData();

  // Acesso aos botões principais
  startButton.addEventListener('click', () => {
    const name = participantNameInput.value.trim();
    if (name.length < 2) {
      nameErrorDisplay.textContent = 'Por favor, digite um nome válido (mínimo 2 caracteres).';
      participantNameInput.focus();
      return;
    }
    nameErrorDisplay.textContent = '';
    show('home');
  });

  playQuizButton.addEventListener('click', () => {
    if (!quizData || Object.keys(quizData).length === 0) {
      alert('Nenhuma categoria carregada. Verifique o XML em data/perguntas_padrao.xml.');
      return;
    }
    show('category');
    renderCategories();
  });

  openSettingsButton.addEventListener('click', () => {
    show('settings');
    document.getElementById('settingsMenuOptions').classList.remove('hidden');
    document.getElementById('designOptions').classList.add('hidden');
  });

  changeDesignButton.addEventListener('click', () => {
    document.getElementById('settingsMenuOptions').classList.add('hidden');
    document.getElementById('designOptions').classList.remove('hidden');
  });

  backFromDesign.addEventListener('click', () => {
    document.getElementById('designOptions').classList.add('hidden');
    document.getElementById('settingsMenuOptions').classList.remove('hidden');
  });

  viewHistoryButton.addEventListener('click', () => {
    show('history');
    displayHistory();
  });

  aboutUsButton.addEventListener('click', () => {
    show('about');
    loadAboutUs();
  });

  backFromSettings.addEventListener('click', () => {
    show('home');
  });
  backFromAbout.addEventListener('click', () => {
    show('settings');
  });
  backFromHistory.addEventListener('click', () => {
    show('settings');
  });

  // Mudança de temas
  themeDefaultBtn.addEventListener('click', () => {
    themeStylesheetLink.href = 'estilo1.css';
    show('settings');
  });
  themeFlatBtn.addEventListener('click', () => {
    themeStylesheetLink.href = 'estilo2.css';
    show('settings');
  });
  themeNeonBtn.addEventListener('click', () => {
    themeStylesheetLink.href = 'estilo3.css';
    show('settings');
  });

  // Voltar para menu principal após resultado
  backToHomeFromResult.addEventListener('click', () => {
    show('home');
  });

  // Rejogar
  playAgainButton.addEventListener('click', () => {
    show('category');
    renderCategories();
  });

  // Botões de “Voltar” nas telas de seleção
  backToHomeFromCategory.addEventListener('click', () => {
    show('home');
  });
  backToCategoryFromLevel.addEventListener('click', () => {
    show('category');
  });
  backToLevelFromQuestion.addEventListener('click', () => {
    show('level');
  });

  // ======================================
  // 2) Carregar e parsear XML
  // ======================================
  async function loadQuizData() {
    try {
      console.log('Tentando carregar XML de: data/perguntas_padrao.xml');
      const res = await fetch('data/perguntas_padrao.xml', { cache: 'no-cache' });
      console.log('Fetch status:', res.status, res.statusText);
      if (!res.ok) throw new Error(`HTTP ${res.status}: ${res.statusText}`);
      const xmlText = await res.text();
      quizData = parseQuizXML(xmlText);
      console.log('Categorias carregadas:', Object.keys(quizData));
    } catch (err) {
      console.error('Erro em loadQuizData:', err);
      alert('Erro ao carregar perguntas: ' + err.message);
    }
  }

  function parseQuizXML(xmlString) {
    const xml = new DOMParser().parseFromString(xmlString, 'application/xml');
    if (xml.querySelector('parsererror')) throw new Error('XML mal formado');
    const data = {};

    xml.querySelectorAll('quiz > category').forEach(catNode => {
      const cat = catNode.getAttribute('name');
      if (!cat) return;
      data[cat] = {};

      catNode.querySelectorAll(':scope > level').forEach(levelNode => {
        const lv = levelNode.getAttribute('name');
        if (!lv) return;
        const questions = Array.from(levelNode.querySelectorAll('question')).map(qNode => ({
          question:    qNode.querySelector('text')?.textContent.trim()   || '',
          description: qNode.querySelector('description')?.textContent.trim() || '',
          options:     Array.from(qNode.querySelectorAll('option')).map(oNode => ({
            text:      oNode.textContent.trim(),
            isCorrect: oNode.getAttribute('correct') === 'true'
          }))
        }));
        data[cat][lv] = questions;
      });
    });

    return data;
  }

  // ======================================
  // 3) Renderização Dinâmica de Fluxo
  // ======================================
  function renderCategories() {
    categoryGrid.innerHTML = '';
    const icons = {
      trivium:        '📜',
      quadrivium:     '🧮',
      bible:          '📖',
      generalCulture: '🌐',
      mwangole:       '🇦🇴',
      misturaTudo:    '🧩',
      english:        '🗣️',
      environment:    '🌿',
      kimbundu:       '🗨️'
    };

    for (const cat in quizData) {
      const btn = document.createElement('button');
      btn.className = 'btn';
      btn.dataset.category = cat;
      const icon = icons[cat] || '❓';
      btn.innerHTML = `<span class="icon">${icon}</span><br /><h3>${capitalize(cat)}</h3>`;
      btn.addEventListener('click', () => {
        currentCategory = cat;
        show('level');
        renderLevels();
      });
      categoryGrid.appendChild(btn);
    }
  }

  function renderLevels() {
    levelGrid.innerHTML = '';
    const levelsObj = quizData[currentCategory];
    const nivelKeys  = Object.keys(levelsObj).sort((a, b) => parseInt(a) - parseInt(b));
    const prog       = getProgress();
    const baseKey    = `${currentCategory}`;

    nivelKeys.forEach(lv => {
      const lvNum = parseInt(lv, 10);
      const btn   = document.createElement('button');
      btn.className = 'btn';
      btn.dataset.level = lv;
      btn.textContent = `Nível ${lv}`;

      // --- Lógica de desbloqueio no modo Quiz ---
      const prevLvl = lvNum - 1;
      const progressObj = prog[baseKey] || {};
      const isUnlocked = (lvNum === 1) ||
                         (progressObj[`level${prevLvl}`] === 'completed') ||
                         (progressObj[`level${lvNum}`] === 'completed');

      if (!isUnlocked) {
        btn.classList.add('locked-level');
        btn.disabled = true;
        btn.textContent += ' 🔒';
      } else {
        if (progressObj[`level${lvNum}`] === 'completed') {
          btn.textContent += ' ⭐';
        }
      }

      btn.addEventListener('click', () => {
        if (!btn.disabled) {
          currentLevel = lv;
          startQuiz();
        }
      });

      levelGrid.appendChild(btn);
    });
  }

  // ======================================
  // 4) Lógica Principal do Quiz
  // ======================================
  function startQuiz() {
    quizQuestions = quizData[currentCategory][currentLevel].slice();
    shuffleArray(quizQuestions);
    currentQuestionIndex = 0;
    score = 0;

    totalQuestionsNumDisplay.textContent = quizQuestions.length;
    nextQuestionButton.classList.add('hidden');
    hintButton.classList.remove('hidden');
    hintButton.disabled = false;
    feedbackMessageElement.textContent = '';
    feedbackMessageElement.classList.remove('correct', 'incorrect');

    show('question');
    questionCategoryLevelTitle.textContent =
      `${capitalize(currentCategory)} – Nível ${currentLevel}`;
    displayQuestion();
  }

  function displayQuestion() {
    stopTimer();
    const questionObj = quizQuestions[currentQuestionIndex];

    currentQuestionNumDisplay.textContent = currentQuestionIndex + 1;
    questionTextElement.textContent = questionObj.question;

    // Limpa feedback e classes antigas
    feedbackMessageElement.textContent = '';
    feedbackMessageElement.classList.remove('correct', 'incorrect');
    optionsContainer.innerHTML = '';
    nextQuestionButton.classList.add('hidden');
    hintButton.disabled = false;

    // Cria botões de opção
    const shuffledOptions = shuffleArray(questionObj.options.slice());
    shuffledOptions.forEach(opt => {
      const btn = document.createElement('button');
      btn.className = 'btn option-btn';
      btn.textContent = opt.text;
      btn.dataset.correct = opt.isCorrect;
      btn.addEventListener('click', selectOption);
      optionsContainer.appendChild(btn);
    });

    startTimer();
  }

  function selectOption(event) {
    stopTimer();
    const selectedBtn = event.currentTarget;
    const isCorrect   = selectedBtn.dataset.correct === 'true';
    const questionObj = quizQuestions[currentQuestionIndex];
    const correctOptionText = questionObj.options.find(o => o.isCorrect).text;

    // Desabilita todas as opções
    document.querySelectorAll('.option-btn').forEach(b => {
      b.disabled = true;
    });

    if (isCorrect) {
      correctSound.play();  // toca som de acerto
      selectedBtn.classList.add('correct-answer');
      feedbackMessageElement.textContent = 'Certo! 🎉';
      feedbackMessageElement.classList.add('correct');
      score++;
    } else {
      incorrectSound.play();  // toca som de erro
      selectedBtn.classList.add('wrong-answer');
      feedbackMessageElement.textContent = `Errado! A resposta correta é: "${correctOptionText}"`;
      feedbackMessageElement.classList.add('incorrect');
      // Destaca a opção correta em verde
      const correctBtn = Array.from(document.querySelectorAll('.option-btn'))
                                .find(b => b.dataset.correct === 'true');
      if (correctBtn) correctBtn.classList.add('correct-answer');
    }

    nextQuestionButton.classList.remove('hidden');
  }

  nextQuestionButton.addEventListener('click', () => {
    currentQuestionIndex++;
    if (currentQuestionIndex < quizQuestions.length) {
      displayQuestion();
    } else {
      showResult();
    }
  });

  // ======================================
  // 5) Temporizador
  // ======================================
  function startTimer() {
    clearInterval(timerInterval);
    timeLeft = 15;
    timerDisplay.textContent = timeLeft;
    timerInterval = setInterval(() => {
      timeLeft--;
      timerDisplay.textContent = timeLeft;
      if (timeLeft <= 0) {
        clearInterval(timerInterval);
        handleTimeUp();
      }
    }, 1000);
  }

  function stopTimer() {
    clearInterval(timerInterval);
  }

  function handleTimeUp() {
    timeoutSound.play();  // toca som de tempo esgotado
    const questionObj = quizQuestions[currentQuestionIndex];
    const correctOptionText = questionObj.options.find(o => o.isCorrect).text;
    feedbackMessageElement.textContent = `Tempo esgotado! Resposta: "${correctOptionText}" ⏳`;
    feedbackMessageElement.classList.add('incorrect');
    // Desabilita todas as opções e marca a correta
    document.querySelectorAll('.option-btn').forEach(b => {
      b.disabled = true;
      if (b.dataset.correct === 'true') {
        b.classList.add('correct-answer');
      }
    });
    nextQuestionButton.classList.remove('hidden');
  }

  // ======================================
  // 6) Tela de Resultado e Histórico
  // ======================================
  function showResult() {
    stopTimer();

    const totalQ = quizQuestions.length;
    const pct    = (score / totalQ) * 100;

    // Salvar histórico
    saveQuizHistory(
      capitalize(currentCategory),
      currentLevel,
      score,
      totalQ
    );

    // Atualizar progresso
    const progressObj = getProgress();
    const keyBase     = `${currentCategory}`;
    if (!progressObj[keyBase]) progressObj[keyBase] = {};
    const levelKey    = `level${currentLevel}`;
    if (pct >= 80) {
      progressObj[keyBase][levelKey] = 'completed';
      const nextLvlNum = parseInt(currentLevel, 10) + 1;
      if (quizData[currentCategory][nextLvlNum]) {
        progressObj[keyBase][`level${nextLvlNum}`] = 'available';
      }
    }
    setProgress(progressObj);

    let msg = `Você acertou ${pct.toFixed(0)}% das perguntas. `;
    if (pct >= 80) {
      msg += 'Parabéns, nível concluído! 🎉';
    } else {
      msg += `É necessário 80% para liberar o próximo nível.`;
    }

    finalScoreSpan.textContent = score;
    maxScoreSpan.textContent   = totalQ;
    resultMessageParagraph.textContent = msg;
    show('result');
  }

  function saveQuizHistory(category, level, score, totalQuestions) {
    const historyArray = JSON.parse(localStorage.getItem('quizHistory') || '[]');
    const now = new Date().toLocaleString('pt-AO');
    historyArray.push({
      id:          Date.now(),
      participant: participantNameInput.value.trim(),
      category,
      level,
      score,
      totalQuestions,
      timestamp:   now
    });
    localStorage.setItem('quizHistory', JSON.stringify(historyArray));
  }

  function displayHistory() {
    const historyArray = JSON.parse(localStorage.getItem('quizHistory') || '[]');
    historyListDiv.innerHTML = '';
    if (historyArray.length === 0) {
      historyListDiv.innerHTML = '<p>Nenhum quiz jogado ainda.</p>';
    } else {
      historyArray.slice().reverse().forEach(entry => {
        const div = document.createElement('div');
        div.className = 'history-item';
        div.innerHTML = `
          <p><strong>Nome:</strong> ${entry.participant}</p>
          <p><strong>Categoria:</strong> ${entry.category}</p>
          <p><strong>Nível:</strong> ${entry.level}</p>
          <p><strong>Data:</strong> ${entry.timestamp}</p>
          <p><strong>Pontos:</strong> ${entry.score} / ${entry.totalQuestions}</p>
        `;
        historyListDiv.appendChild(div);
      });
    }
  }

  // ======================================
  // 7) Carregar “Sobre Nós”
  // ======================================
  async function loadAboutUs() {
    try {
      const res = await fetch('./data/sobreNos.xml', { cache: 'no-cache' });
      if (!res.ok) throw new Error(`HTTP ${res.status}: ${res.statusText}`);
      const xmlText = await res.text();
      const parser  = new DOMParser().parseFromString(xmlText.trim(), 'application/xml');
      if (parser.querySelector('parsererror')) throw new Error('XML de Sobre Nós mal formado');

      const root = parser.querySelector('welcomeInfo');
      if (!root) throw new Error('Tag <welcomeInfo> não encontrada no XML de Sobre Nós.');

      const contentDiv = document.getElementById('aboutContent');
      contentDiv.innerHTML = '';

      // <title>
      const tituloNode = root.querySelector('title');
      if (tituloNode) {
        const h3 = document.createElement('h3');
        h3.textContent = tituloNode.textContent.trim();
        contentDiv.appendChild(h3);
      }
      // <description>
      const descNode = root.querySelector('description');
      if (descNode) {
        const pDesc = document.createElement('p');
        pDesc.textContent = descNode.textContent.trim();
        contentDiv.appendChild(pDesc);
      }
      // <whoAreWe>
      const whoNode = root.querySelector('whoAreWe');
      if (whoNode) {
        const tituloWho = whoNode.querySelector('title')?.textContent.trim();
        const textWho   = whoNode.querySelector('text')?.textContent.trim();
        if (tituloWho) {
          const h4 = document.createElement('h4');
          h4.textContent = tituloWho;
          contentDiv.appendChild(h4);
        }
        if (textWho) {
          const pWho = document.createElement('p');
          pWho.textContent = textWho;
          contentDiv.appendChild(pWho);
        }
      }
      // <location>
      const locNode = root.querySelector('location');
      if (locNode) {
        const tituloLoc = locNode.querySelector('title')?.textContent.trim();
        if (tituloLoc) {
          const h4 = document.createElement('h4');
          h4.textContent = tituloLoc;
          contentDiv.appendChild(h4);
        }
        locNode.querySelectorAll('text').forEach(txtNode => {
          const pLoc = document.createElement('p');
          pLoc.textContent = txtNode.textContent.trim();
          contentDiv.appendChild(pLoc);
        });
      }
      // <contacts>
      const contNode = root.querySelector('contacts');
      if (contNode) {
        const tituloCont = contNode.querySelector('title')?.textContent.trim();
        if (tituloCont) {
          const h4 = document.createElement('h4');
          h4.textContent = tituloCont;
          contentDiv.appendChild(h4);
        }

        const emailNode       = contNode.querySelector('email');
        const phoneNode       = contNode.querySelector('phone');
        const socialMediaNode = contNode.querySelector('socialMedia');

        if (emailNode) {
          const pEmail = document.createElement('p');
          pEmail.innerHTML = `<strong>Email:</strong> ${emailNode.textContent.trim()}`;
          contentDiv.appendChild(pEmail);
        }
        if (phoneNode) {
          const pPhone = document.createElement('p');
          pPhone.innerHTML = `<strong>Telefone:</strong> ${phoneNode.textContent.trim()}`;
          contentDiv.appendChild(pPhone);
        }
        if (socialMediaNode) {
          const pSM = document.createElement('p');
          pSM.innerHTML = `<strong>Redes Sociais:</strong> ${socialMediaNode.textContent.trim()}`;
          contentDiv.appendChild(pSM);
        }
      }
    } catch (err) {
      console.error('Erro ao carregar Sobre Nós:', err);
      alert('Erro ao carregar informações de Sobre Nós: ' + err.message);
    }
  }

  // ======================================
  // 8) Utilitários
  // ======================================
  function capitalize(str) {
    if (!str) return '';
    return str.charAt(0).toUpperCase() + str.slice(1);
  }

  function shuffleArray(arr) {
    for (let i = arr.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [arr[i], arr[j]] = [arr[j], arr[i]];
    }
    return arr;
  }
});

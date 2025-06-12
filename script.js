// script.js (VERSÃO FINAL CORRIGIDA)
const categoryIcons = {
    'Trivium': '📜',
    'Quadrivium': '🧮',
    'Cultura Mundial': '🌐',
    'Mwangole': '🇦🇴',
    'Bíblia': '📖',
    'Inglês': '🗣️',
    'Kimbundu': '🗨️',
    'Países': '🏳️',
    'default': '🎲' // Um ícone padrão caso a categoria não seja encontrada
  };
document.addEventListener('DOMContentLoaded', () => {
  // ======== SONS ========
  const correctSound = new Audio('sounds/correct.mp3');
  const incorrectSound = new Audio('sounds/incorrect.mp3');
  const timeoutSound = new Audio('sounds/timeout.mp3');
  const hintSound = new Audio('sounds/hint.mp3');
  const reprovouSound = new Audio('sounds/reprovou.mp3');
  const passouSound = new Audio('sounds/passou.mp3');

  // --- Constantes para chaves e estados ---
  const KEYS = {
    PROGRESS: 'quizProgress',
    SETTINGS: 'quizSettings',
    HISTORY: 'quizHistory',
    PARTICIPANT_NAME: 'participantName',
  };
  const STATUS = {
    THREE_STARS: 'three_stars',
    TWO_STARS: 'two_stars',
    ONE_STAR: 'one_star',
    FAILED: 'failed',
    AVAILABLE: 'available',
  };

  // --- Variáveis de Estado da Aplicação ---
  let quizSettings = { time: true, next: true, audio: true };
  let quizData = {};
  let currentCategory = '';
  let currentLevel = '';
  let quizQuestions = [],
    currentQuestionIndex = 0,
    score = 0;
  let timerInterval, timeLeft, autoAdvanceTimeout;

  // --- Mapeamento de telas (IDs do index.html) ---
  const screens = {
    welcome: document.getElementById('welcomeScreen'),
    home: document.getElementById('homeScreen'),
    category: document.getElementById('categoryScreen'),
    settings: document.getElementById('settingsScreen'),
    quizOptions: document.getElementById('quizOptionsScreen'),
    about: document.getElementById('aboutScreen'),
    level: document.getElementById('levelScreen'),
    question: document.getElementById('questionScreen'),
    result: document.getElementById('resultScreen'),
    history: document.getElementById('historyScreen'),
  };

  // --- FUNÇÃO PARA MOSTRAR TELAS (COM ANIMAÇÃO) ---
    let currentVisibleScreen = document.querySelector('.screen.visible');  // Guarda a referência da tela atual

    function showScreen(newScreenKey) {
      if (!screens[newScreenKey]) {
          console.error(`Tentativa de mostrar tela desconhecida: ${newScreenKey}`);
          return;
      }

      const newScreen = screens[newScreenKey];

      // Esconde a tela atualmente visível, se houver uma
      if (currentVisibleScreen) {
          currentVisibleScreen.classList.remove('visible');
      }

      // Mostra a nova tela
      newScreen.classList.remove('hidden'); // Garante que não está com display:none
      newScreen.classList.add('visible');

      // Atualiza a referência da tela atual
      currentVisibleScreen = newScreen;
    }

  // --- Seletores de elementos ---
  const startButton = document.getElementById('startButton');
  const participantNameInput = document.getElementById('participantName');
  const nameErrorDisplay = document.getElementById('nameError');
  const playQuizButton = document.getElementById('playQuizButton');
  const openSettingsButton = document.getElementById('openSettingsButton');
  const changeDesignButton = document.getElementById('changeDesignButton');
  const viewHistoryButton = document.getElementById('viewHistoryButton');
  const aboutUsButton = document.getElementById('aboutUsButton');
  const quizOptionsButton = document.getElementById('quizOptionsButton');
  const backFromSettingsButton = document.getElementById('backFromSettings');
  const backFromDesignButton = document.getElementById('backFromDesign');
  const backFromQuizOptionsButton = document.getElementById('backFromQuizOptions');
  const themeDefaultButton = document.getElementById('themeDefault');
  const themeFlatButton = document.getElementById('themeFlat');
  const themeNeonButton = document.getElementById('themeNeon');
  const themeStylesheetLink = document.getElementById('themeStylesheet');
  const backFromAboutButton = document.getElementById('backFromAbout');
  const backFromHistoryButton = document.getElementById('backFromHistory');
  const playAgainButton = document.getElementById('playAgainButton');
  const changeCategoryButton = document.getElementById('changeCategoryButton');
  const nextLevelButton = document.getElementById('nextLevelButton');
  const nextLevelNumDisplay = document.getElementById('nextLevelNum');
  const backToHomeFromCategoryButton = document.getElementById('backToHomeFromCategory');
  const backToCategoryFromLevelButton = document.getElementById('backToCategoryFromLevel');
  const backToLevelFromQuestionButton = document.getElementById('backToLevelFromQuestion');
  const categoryButtons = document.querySelectorAll('.category-btn');
  const levelSelectionGrid = document.getElementById('levelSelectionGrid');
  const questionCategoryLevelTitle = document.getElementById('questionCategoryLevelTitle');
  const timerDisplay = document.getElementById('timer');
  const questionTextElement = document.getElementById('questionText');
  const optionsContainer = document.getElementById('optionsContainer');
  const currentQuestionNumDisplay = document.getElementById('currentQuestionNum');
  const totalQuestionsNumDisplay = document.getElementById('totalQuestionsNum');
  const hintButton = document.getElementById('hintButton');
  const nextQuestionButton = document.getElementById('nextQuestionButton');
  const feedbackMessageElement = document.getElementById('feedbackMessage');
  const finalScoreSpan = document.getElementById('finalScore');
  const maxScoreSpan = document.getElementById('maxScore');
  const resultMessageParagraph = document.getElementById('resultMessage');
  const historyListDiv = document.getElementById('historyList');
  const chkTime = document.getElementById('chkTime');
  const chkNext = document.getElementById('chkNext');
  const chkAudio = document.getElementById('chkAudio');
  const backgroundMusic = document.getElementById('background-music');
  const volumeBackgroundSlider = document.getElementById('volume-background');
  const volumeEffectsSlider = document.getElementById('volume-effects');

  // Funções de Persistência
  function getProgress() { return JSON.parse(localStorage.getItem(KEYS.PROGRESS) || '{}'); }
  function setProgress(progress) { localStorage.setItem(KEYS.PROGRESS, JSON.stringify(progress)); }
  function saveSettings() {
    quizSettings = {
    time: chkTime.checked,
    next: chkNext.checked,
    audio: chkAudio.checked,
    volumeBackground: volumeBackgroundSlider.value,
    volumeEffects: volumeEffectsSlider.value};
    localStorage.setItem(KEYS.SETTINGS, JSON.stringify(quizSettings));
  }
  function loadSettings() {
      const savedSettings = JSON.parse(localStorage.getItem(KEYS.SETTINGS));

      // Define os valores padrão primeiro
      let defaultSettings = { time: true, next: true, audio: true, volumeBackground: 0.1, volumeEffects: 0.3 };
      quizSettings = { ...defaultSettings, ...savedSettings }; // Junta as configurações salvas com as padrão

      // Aplica as configurações aos elementos HTML
      chkTime.checked = quizSettings.time;
      chkNext.checked = quizSettings.next;
      chkAudio.checked = quizSettings.audio;
      volumeBackgroundSlider.value = quizSettings.volumeBackground;
      volumeEffectsSlider.value = quizSettings.volumeEffects;

      // Aplica o volume aos elementos de áudio
      if (backgroundMusic)
      backgroundMusic.volume = quizSettings.volumeBackground;
      correctSound.volume = quizSettings.volumeEffects;
      incorrectSound.volume = quizSettings.volumeEffects;
      passouSound.volume = quizSettings.volumeEffects;
      reprovouSound.volume = quizSettings.volumeEffects;
      timeoutSound.volume = quizSettings.volumeEffects;
      hintSound.volume = quizSettings.volumeEffects;
      backgroundMusic.muted = !quizSettings.audio;
      correctSound.muted = !quizSettings.audio;
      incorrectSound.muted = !quizSettings.audio;
      timeoutSound.muted = !quizSettings.audio;
      hintSound.muted = !quizSettings.audio;
      passouSound.muted = !quizSettings.audio;
      reprovouSound.muted = !quizSettings.audio;
    }
    if(volumeBackgroundSlider && backgroundMusic) {
        volumeBackgroundSlider.addEventListener('input', (e) => {
          const newVolume = e.target.value;
          backgroundMusic.volume = newVolume;

          // NOVO: Se o utilizador mexe no volume, assumimos que ele quer ouvir o som.
          // Isto torna o controlo mais intuitivo.
          if (newVolume > 0 && backgroundMusic.muted) {
            // Ativa o som mestre e o checkbox correspondente
            chkAudio.checked = true;
            // Dispara o evento 'change' para que toda a lógica de desmutar seja executada
            chkAudio.dispatchEvent(new Event('change'));
          }

          saveSettings(); // Guarda a alteração
        });
      }

      if(volumeEffectsSlider) {
        volumeEffectsSlider.addEventListener('input', (e) => {
          const newVolume = e.target.value;
          correctSound.volume = newVolume;
          incorrectSound.volume = newVolume;
          timeoutSound.volume = newVolume;
          hintSound.volume = newVolume;
          passouSound.volume = newVolume;
          reprovouSound.volume = newVolume;

          // NOVO: Se o utilizador mexe no volume, também ativa o som mestre.
          if (newVolume > 0 && correctSound.muted) {
            chkAudio.checked = true;
            chkAudio.dispatchEvent(new Event('change'));
          }

          saveSettings(); // Guarda a alteração
        });
      }

  // ======================================
  // 1) Inicialização e Navegação
  // ======================================
  loadSettings();

  const savedParticipantName = localStorage.getItem(KEYS.PARTICIPANT_NAME);
  if (savedParticipantName) participantNameInput.value = savedParticipantName;
  participantNameInput.addEventListener('input', () => { localStorage.setItem(KEYS.PARTICIPANT_NAME, participantNameInput.value.trim()); });

  startButton.addEventListener('click', () => {
    if (participantNameInput.value.trim().length < 2) {
      nameErrorDisplay.textContent = 'Por favor, digite um nome válido (mínimo 2 caracteres).';
      participantNameInput.focus();
      return;
    }
    nameErrorDisplay.textContent = '';
    showScreen('home');
  });

  playQuizButton.addEventListener('click', () => showScreen('category'));
  openSettingsButton.addEventListener('click', () => {
    showScreen('settings');
    document.getElementById('settingsMenuOptions').classList.remove('hidden');
    document.getElementById('designOptions').classList.add('hidden');
  });
  changeDesignButton.addEventListener('click', () => {
    document.getElementById('settingsMenuOptions').classList.add('hidden');
    document.getElementById('designOptions').classList.remove('hidden');
  });
  backFromDesignButton.addEventListener('click', () => {
    document.getElementById('designOptions').classList.add('hidden');
    document.getElementById('settingsMenuOptions').classList.remove('hidden');
  });
  viewHistoryButton.addEventListener('click', () => { showScreen('history'); displayHistory(); });
  aboutUsButton.addEventListener('click', () => { showScreen('about'); loadAboutUsContent(); });
  quizOptionsButton.addEventListener('click', () => showScreen('quizOptions'));

  // Botões "Voltar"
  backFromQuizOptionsButton.addEventListener('click', () => showScreen('settings'));
  backFromSettingsButton.addEventListener('click', () => showScreen('home'));
  backFromAboutButton.addEventListener('click', () => showScreen('settings'));
  backFromHistoryButton.addEventListener('click', () => showScreen('settings'));

  // Temas
  themeDefaultButton.addEventListener('click', () => { themeStylesheetLink.href = 'estilo1.css'; });
  themeFlatButton.addEventListener('click', () => { themeStylesheetLink.href = 'estilo2.css'; });
  themeNeonButton.addEventListener('click', () => { themeStylesheetLink.href = 'estilo3.css'; });

  // Navegação do Quiz
  playAgainButton.addEventListener('click', () => startQuiz());
  changeCategoryButton.addEventListener('click', () => showScreen('category'));
  nextLevelButton.addEventListener('click', () => {
    currentLevel = (parseInt(currentLevel, 10) + 1).toString();
    startQuiz();
  });
  backToHomeFromCategoryButton.addEventListener('click', () => showScreen('home'));
  backToCategoryFromLevelButton.addEventListener('click', () => showScreen('category'));
  backToLevelFromQuestionButton.addEventListener('click', () => {
  if (backgroundMusic) {
          backgroundMusic.pause();
          backgroundMusic.currentTime = 0; // Reinicia a música para a próxima vez
        }
    stopQuestionActivities();
    showScreen('level');
  });

  // Checkboxes de Opções do Quiz
  chkTime.addEventListener('change', saveSettings);
  chkNext.addEventListener('change', saveSettings);
  chkAudio.addEventListener('change', () => {
      const isAudioEnabled = chkAudio.checked;

      // Aplica o estado a todos os elementos de áudio
      backgroundMusic.muted = !isAudioEnabled;
      correctSound.muted = !isAudioEnabled;
      incorrectSound.muted = !isAudioEnabled;
      timeoutSound.muted = !isAudioEnabled;
      hintSound.muted = !isAudioEnabled;
      passouSound.muted = !isAudioEnabled;
      reprovouSound.muted = !isAudioEnabled;

      // Se o áudio foi reativado e a música estava parada, tenta tocá-la novamente
      // (Apenas se já estivermos dentro do quiz)
      if (isAudioEnabled && backgroundMusic.paused && currentVisibleScreen === screens.question) {
          backgroundMusic.play();
      } else if (!isAudioEnabled) {
          backgroundMusic.pause();
      }

      saveSettings(); // Guarda a nova configuração (ligado/desligado)
    });

  // --- Funcionalidade de Dica ---
  hintButton.addEventListener('click', useHint);
  function useHint() {
      if (quizSettings.audio) hintSound.play();
      hintButton.disabled = true;
      hintButton.classList.add('disabled-hint');
      const incorrectOptions = Array.from(optionsContainer.querySelectorAll('.option-btn:not([disabled])'))
          .filter(btn => btn.dataset.correct === 'false');
      shuffleArray(incorrectOptions);
      const hintsToRemove = (incorrectOptions.length > 1) ? 2 : 1;
      for (let i = 0; i < Math.min(hintsToRemove, incorrectOptions.length); i++) {
          incorrectOptions[i].classList.add('hint-removed');
          incorrectOptions[i].disabled = true;
      }
  }

  // --- Lógica de Categorias e Níveis ---
  categoryButtons.forEach(btn => {
    btn.addEventListener('click', () => {
    currentCategory = btn.dataset.category;
    const filename = currentCategory.toLowerCase().replace(/\s+/g, '') + '.json';
    fetch(`data/${filename}`, { cache: 'no-cache' })
        .then(response => {
        if (!response.ok) throw new Error(`Não foi possível carregar ${filename}.`);
        return response.json();
        })
        .then(data => {
        quizData = data;
        showScreen('level');
        renderLevelButtons();
        })
        .catch(err => {
        console.error(`Erro ao carregar categoria ${currentCategory}:`, err);
        levelSelectionGrid.innerHTML = `<p class="error" style="width:100%; text-align:center;">Erro ao carregar ‘${currentCategory}’: ${err.message}</p>`;
        });
    });
  });

  function renderLevelButtons() {
    levelSelectionGrid.innerHTML = '';
    const levelKeys = Object.keys(quizData).sort((a, b) => parseInt(a) - parseInt(b));
    const progressData = getProgress();

    if (levelKeys.length === 0) {
        levelSelectionGrid.innerHTML = `<p class="error" style="width:100%; text-align:center;">Nenhum nível encontrado.</p>`;
        return;
    }
    levelKeys.forEach(levelId => {
      const levelButton = document.createElement('button');
      levelButton.className = 'btn';
      levelButton.dataset.level = levelId;
      levelButton.textContent = `Nível ${levelId}`;
      const categoryProgress = progressData[currentCategory] || {};
      const previousLevelKey = `level${parseInt(levelId, 10) - 1}`;
      const previousLevelStatus = categoryProgress[previousLevelKey];
      const previousLevelCompleted = previousLevelStatus && previousLevelStatus !== STATUS.FAILED && previousLevelStatus !== STATUS.AVAILABLE;
      const isUnlocked = parseInt(levelId, 10) === 1 || previousLevelCompleted;

      if (!isUnlocked) {
        levelButton.classList.add('locked-level');
        levelButton.disabled = true;
        levelButton.textContent += ' 🔒';
      } else {
        const currentLevelProgress = categoryProgress[`level${levelId}`];
        if (currentLevelProgress === STATUS.THREE_STARS) levelButton.textContent += ' ⭐⭐⭐';
        else if (currentLevelProgress === STATUS.TWO_STARS) levelButton.textContent += ' ⭐⭐';
        else if (currentLevelProgress === STATUS.ONE_STAR) levelButton.textContent += ' ⭐';
      }
      levelButton.addEventListener('click', () => {
        if (!levelButton.disabled) {
          currentLevel = levelId;
          if (backgroundMusic) {
                    backgroundMusic.play().catch(e => console.error("A reprodução de áudio foi bloqueada:", e));
                  }
          startQuiz();
        }
      });
      levelSelectionGrid.appendChild(levelButton);
    });
  }

  // --- Lógica Principal do Quiz ---
  function startQuiz() {
  if (backgroundMusic) {
              backgroundMusic.play().catch(e => console.error("A reprodução de áudio falhou:", e));
            }
    quizQuestions = shuffleArray([...(quizData[currentLevel] || [])]);
    if (quizQuestions.length === 0) {
      feedbackMessageElement.textContent = 'Nenhuma pergunta encontrada para este nível.';
      showScreen('level');
      return;
    }
    currentQuestionIndex = 0;
    score = 0;
    totalQuestionsNumDisplay.textContent = quizQuestions.length;
    showScreen('question');
    questionCategoryLevelTitle.textContent = `${currentCategory} – Nível ${currentLevel}`;
    displayCurrentQuestion();
  }

  function playBackgroundMusic() {
      if (backgroundMusic && quizSettings.audio) {
            backgroundMusic.play().catch(error => {
              console.log("A reprodução de áudio foi bloqueada pelo navegador.");
         });
      }
    }

  function displayCurrentQuestion() {
    stopQuestionActivities();
    const question = quizQuestions[currentQuestionIndex];
    document.querySelector('.timer-container').style.display = quizSettings.time ? 'block' : 'none';
    currentQuestionNumDisplay.textContent = currentQuestionIndex + 1;
    questionTextElement.textContent = question.pergunta;
    feedbackMessageElement.innerHTML = '';
    optionsContainer.innerHTML = '';
    nextQuestionButton.classList.add('hidden');
    hintButton.disabled = false;
    hintButton.classList.remove('disabled-hint');

    const options = shuffleArray([...question.opcoes]);
    options.forEach(option => {
      const button = document.createElement('button');
      button.className = 'btn option-btn';
      button.textContent = option.texto;
      button.dataset.correct = option.correta;
      button.addEventListener('click', handleOptionSelection);
      optionsContainer.appendChild(button);
    });

    if (quizSettings.time) startTimer();
  }

  // CORRIGIDO: Lógica de progressão do quiz simplificada e corrigida
  function handleOptionSelection(event) {
    stopQuestionActivities();
    const selectedButton = event.currentTarget;
    const isCorrect = selectedButton.dataset.correct === 'true';
    const question = quizQuestions[currentQuestionIndex];

    document.querySelectorAll('.option-btn').forEach(b => { b.disabled = true; });
    hintButton.disabled = true;

    let feedbackHTML;
    if (isCorrect) {
      if (quizSettings.audio) correctSound.play();
      selectedButton.classList.add('correct');
      feedbackHTML = 'Certo! 🎉';
      score++;
    } else {
      if (quizSettings.audio) incorrectSound.play();
      selectedButton.classList.add('wrong');
      const correctButton = optionsContainer.querySelector('[data-correct="true"]');
      correctButton.classList.add('correct');
      feedbackHTML = `Errado! A resposta correta é: "${correctButton.textContent}"`;
    }

    if (question.descricao) {
      feedbackHTML += `<br><span class="question-description">${question.descricao}</span>`;
    }
    feedbackMessageElement.innerHTML = feedbackHTML;

    // Decidir o que fazer a seguir
    if (quizSettings.next) {
        nextQuestionButton.classList.remove('hidden');
    } else {
        autoAdvanceTimeout = setTimeout(proceedToNextStep, 2500);
    }
  }

  // CORRIGIDO: Nova função centralizada para avançar no quiz
  function proceedToNextStep() {
      currentQuestionIndex++;
      if (currentQuestionIndex < quizQuestions.length) {
          displayCurrentQuestion();
      } else {
          showResultScreen();
      }
  }

  // CORRIGIDO: Listener do botão "Próxima" agora chama a função central
  nextQuestionButton.addEventListener('click', proceedToNextStep);

  // --- Temporizador e Atividades ---
  function startTimer() {
    timeLeft = 15;
    timerDisplay.textContent = timeLeft;
    timerInterval = setInterval(() => {
      timeLeft--;
      timerDisplay.textContent = timeLeft;
      if (timeLeft <= 0) {
        handleTimeUp();
      }
    }, 1000);
  }

  function handleTimeUp() {
    stopQuestionActivities();
    if (quizSettings.audio) timeoutSound.play();
    const question = quizQuestions[currentQuestionIndex];
    const correctButton = optionsContainer.querySelector('[data-correct="true"]');
    let feedbackHTML = `Tempo esgotado! Resposta: "${correctButton.textContent}" ⏳`;
    if (question.descricao) {
        feedbackHTML += `<br><span class="question-description">${question.descricao}</span>`;
    }
    feedbackMessageElement.innerHTML = feedbackHTML;
    document.querySelectorAll('.option-btn').forEach(b => {
      b.disabled = true;
      if (b.dataset.correct === 'true') b.classList.add('correct');
    });

    if (quizSettings.next) {
        nextQuestionButton.classList.remove('hidden');
    } else {
        autoAdvanceTimeout = setTimeout(proceedToNextStep, 2500);
    }
  }

  function stopQuestionActivities() {
    clearInterval(timerInterval);
    clearTimeout(autoAdvanceTimeout);
  }

  // --- Tela de Resultado ---
  function showResultScreen() {
  if (backgroundMusic) {
        backgroundMusic.pause();
        backgroundMusic.currentTime = 0; // Reinicia a música para a próxima vez
      }
    stopQuestionActivities();
    const total = quizQuestions.length;
    const percentage = total > 0 ? (score / total) * 100 : 0;
    saveQuizResultToHistory(currentCategory, currentLevel, score, total);
    const newStatus = updateProgress(percentage);

    let message = `Você acertou ${percentage.toFixed(0)}% das perguntas. `;
    if (newStatus === STATUS.THREE_STARS) message += 'UAU! Três Estrelas! Nível Perfeito! ⭐⭐⭐';
    else if (newStatus === STATUS.TWO_STARS) message += 'Excelente! Duas Estrelas! Continue assim! ⭐⭐';
    else if (newStatus === STATUS.ONE_STAR) message += 'Parabéns, nível concluído! Uma Estrela! ⭐';
    else message += `É necessário 80% para liberar o próximo nível.`;

    finalScoreSpan.textContent = score;
    maxScoreSpan.textContent = total;
    resultMessageParagraph.textContent = message;
    const nextLevelExists = quizData[(parseInt(currentLevel, 10) + 1).toString()];
    if (nextLevelExists && newStatus !== STATUS.FAILED) {
      passouSound.play();
      nextLevelButton.classList.remove('hidden');
      nextLevelNumDisplay.textContent = parseInt(currentLevel, 10) + 1;
    } else {
      reprovouSound.play();
      nextLevelButton.classList.add('hidden');
    }
    showScreen('result');
  }

  function updateProgress(percentage) {
    const progress = getProgress();
    if (!progress[currentCategory]) progress[currentCategory] = {};
    let newStatus;
    if (percentage === 100) newStatus = STATUS.THREE_STARS;
    else if (percentage >= 90) newStatus = STATUS.TWO_STARS;
    else if (percentage >= 80) newStatus = STATUS.ONE_STAR;
    else newStatus = STATUS.FAILED;
    const levelKey = `level${currentLevel}`;
    const currentStatus = progress[currentCategory][levelKey];
    const statusOrder = [STATUS.FAILED, STATUS.AVAILABLE, STATUS.ONE_STAR, STATUS.TWO_STARS, STATUS.THREE_STARS];
    if (!currentStatus || statusOrder.indexOf(newStatus) > statusOrder.indexOf(currentStatus)) {
      progress[currentCategory][levelKey] = newStatus;
    }
    const nextLevelKey = `level${parseInt(currentLevel, 10) + 1}`;
    if (newStatus !== STATUS.FAILED && quizData[parseInt(currentLevel, 10) + 1] && !progress[currentCategory][nextLevelKey]) {
        progress[currentCategory][nextLevelKey] = STATUS.AVAILABLE;
    }
    setProgress(progress);
    return newStatus;
  }

  // --- Histórico ---
  function saveQuizResultToHistory(category, level, score, total) {
      const history = JSON.parse(localStorage.getItem(KEYS.HISTORY) || '[]');
      const now = new Date().toLocaleString('pt-AO', { dateStyle: 'short', timeStyle: 'short' });
      history.push({
        id: Date.now(),
        participant: participantNameInput.value.trim() || 'Anónimo',
        category, level, score, total, timestamp: now
      });
      localStorage.setItem(KEYS.HISTORY, JSON.stringify(history));
    }
  function displayHistory() {
      const history = JSON.parse(localStorage.getItem(KEYS.HISTORY) || '[]');
      if (history.length === 0) {
        historyListDiv.innerHTML = '<p style="text-align: center; margin-top: 1rem;">Nenhum quiz jogado ainda.</p>';
        return;
      }

      const historyHTML = history.slice().reverse().map(entry => {
        const icon = categoryIcons[entry.category] || categoryIcons['default'];
        return `
          <div class="history-item">
            <div class="history-item-icon">${icon}</div>
            <div class="history-item-details">
              <h4>${entry.category} - Nível ${entry.level}</h4>
              <p class="history-item-meta">
                <span><i class="fa-solid fa-user"></i> ${entry.participant}</span>
                <span><i class="fa-solid fa-calendar-days"></i> ${entry.timestamp}</span>
              </p>
            </div>
            <div class="history-item-score">
              <strong>${entry.score}</strong>/${entry.total}
            </div>
          </div>
        `;
      }).join('');

      historyListDiv.innerHTML = historyHTML;
    }

  // CORRIGIDO: Função "Sobre Nós" restaurada para a versão original mais robusta
  async function loadAboutUsContent() {
    const aboutContentDiv = document.getElementById('aboutContent');
    if (!aboutContentDiv) return;
    try {
      const response = await fetch('./data/sobreNos.json', { cache: 'no-cache' });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${response.statusText}. Verifique se o ficheiro 'data/sobreNos.json' existe.`);
      const data = await response.json();
      const aboutInfo = data.welcomeInfo;
      if (!aboutInfo) throw new Error("Formato inválido em sobreNos.json: propriedade 'welcomeInfo' não encontrada.");

      aboutContentDiv.innerHTML = '';

      if (aboutInfo.title) {
        const titleElement = document.createElement('h2');
        titleElement.textContent = aboutInfo.title;
        aboutContentDiv.appendChild(titleElement);
      }
      if (aboutInfo.website) {
        const websiteParagraph = document.createElement('p');
        const websiteLink = document.createElement('a');
        websiteLink.href = aboutInfo.website; websiteLink.target = '_blank'; websiteLink.rel = 'noopener';
        websiteLink.textContent = 'Visite nosso site';
        websiteParagraph.appendChild(websiteLink); aboutContentDiv.appendChild(websiteParagraph);
      }
      if (aboutInfo.description) {
        const descriptionParagraph = document.createElement('p');
        descriptionParagraph.textContent = aboutInfo.description;
        aboutContentDiv.appendChild(descriptionParagraph);
      }
      if (aboutInfo.whoAreWe) {
        if (aboutInfo.whoAreWe.title) {
          const whoAreWeTitle = document.createElement('h3');
          whoAreWeTitle.textContent = aboutInfo.whoAreWe.title;
          aboutContentDiv.appendChild(whoAreWeTitle);
        }
        if (aboutInfo.whoAreWe.text) {
          const whoAreWeText = document.createElement('p');
          whoAreWeText.textContent = aboutInfo.whoAreWe.text;
          aboutContentDiv.appendChild(whoAreWeText);
        }
      }
      if (aboutInfo.location) {
        if (aboutInfo.location.title) {
          const locationTitle = document.createElement('h3');
          locationTitle.textContent = aboutInfo.location.title;
          aboutContentDiv.appendChild(locationTitle);
        }
        if (Array.isArray(aboutInfo.location.text)) {
          const locationList = document.createElement('ul');
          aboutInfo.location.text.forEach(line => {
            const listItem = document.createElement('li');
            listItem.textContent = line; locationList.appendChild(listItem);
          });
          aboutContentDiv.appendChild(locationList);
        }
      }
      if (aboutInfo.contacts) {
        if (aboutInfo.contacts.title) {
          const contactsTitle = document.createElement('h3');
          contactsTitle.textContent = aboutInfo.contacts.title;
          aboutContentDiv.appendChild(contactsTitle);
        }
        const contactsList = document.createElement('ul');
        contactsList.style.listStyle = 'none'; contactsList.style.paddingLeft = '0';
        if (aboutInfo.contacts.email) {
          const emailListItem = document.createElement('li');
          emailListItem.innerHTML = `<strong>Email:</strong> ${aboutInfo.contacts.email}`;
          contactsList.appendChild(emailListItem);
        }
        if (aboutInfo.contacts.phone) {
          const phoneListItem = document.createElement('li');
          phoneListItem.innerHTML = `<strong>Telefone:</strong> ${aboutInfo.contacts.phone}`;
          contactsList.appendChild(phoneListItem);
        }
        if (aboutInfo.contacts.socialMedia) {
          const socialMediaListItem = document.createElement('li');
          socialMediaListItem.innerHTML = `<strong>Redes Sociais:</strong> ${aboutInfo.contacts.socialMedia}`;
          contactsList.appendChild(socialMediaListItem);
        }
        aboutContentDiv.appendChild(contactsList);
      }
    } catch (err) {
      console.error('Erro ao carregar sobreNos.json:', err);
      if(aboutContentDiv) aboutContentDiv.innerHTML = `<p style="color: #c00; font-style: italic;">Falha ao carregar informações de “Sobre Nós”.<br>${err.message}</p>`;
    }
  }

  // --- Utilitários ---
  function shuffleArray(array) {
    for (let i = array.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [array[i], array[j]] = [array[j], array[i]];
    }
    return array;
  }
});
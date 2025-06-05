// script.js
document.addEventListener('DOMContentLoaded', () => {
  // ======== SONS ========
  const correctSound = new Audio('sounds/correct.mp3');
  const incorrectSound = new Audio('sounds/incorrect.mp3');
  const timeoutSound = new Audio('sounds/timeout.mp3');
  const hintSound = new Audio('sounds/hint.mp3');

  // --- Chaves, Funções de Progresso e Configurações ---
  const PROGRESS_KEY = 'quizProgress';
  const SETTINGS_KEY = 'quizSettings';

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

  // --- FUNÇÃO SIMPLIFICADA PARA MOSTRAR TELAS (SEM TRANSIÇÃO) ---
  function showScreen(newScreenKey) {
    if (!screens[newScreenKey]) {
        console.error(`Tentativa de mostrar tela desconhecida: ${newScreenKey}`);
        return;
    }
    // Esconde todas as telas adicionando a classe 'hidden'
    Object.values(screens).forEach(screenEl => {
        if(screenEl) screenEl.classList.add('hidden');
    });
    // Mostra apenas a tela desejada removendo a classe 'hidden'
    screens[newScreenKey].classList.remove('hidden');
  }

  // --- Seletores de elementos (IDs do index.html) ---
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

  function getProgress() { return JSON.parse(localStorage.getItem(PROGRESS_KEY) || '{}'); }
  function setProgress(progress) { localStorage.setItem(PROGRESS_KEY, JSON.stringify(progress)); }
  function saveSettings() {
    const timeChecked = chkTime ? chkTime.checked : true;
    const nextChecked = chkNext ? chkNext.checked : true;
    const audioChecked = chkAudio ? chkAudio.checked : true;

    quizSettings = { time: timeChecked, next: nextChecked, audio: audioChecked };
    localStorage.setItem(SETTINGS_KEY, JSON.stringify(quizSettings));
  }
  function loadSettings() {
    const savedSettings = JSON.parse(localStorage.getItem(SETTINGS_KEY));
    if (savedSettings) quizSettings = savedSettings;
    if (chkTime) chkTime.checked = quizSettings.time;
    if (chkNext) chkNext.checked = quizSettings.next;
    if (chkAudio) chkAudio.checked = quizSettings.audio;
  }

  // ======================================
  // 1) Inicialização e Navegação
  // ======================================
  loadSettings();

  // A welcomeScreen já está visível por padrão no HTML.
  // A função showScreen agora irá gerir a visibilidade das outras telas.

  if(participantNameInput){
    const savedParticipantName = localStorage.getItem('participantName');
    if (savedParticipantName) participantNameInput.value = savedParticipantName;
    participantNameInput.addEventListener('input', () => { localStorage.setItem('participantName', participantNameInput.value.trim()); });
  }

  if(startButton) startButton.addEventListener('click', () => {
    const name = participantNameInput ? participantNameInput.value.trim() : "";
    if (name.length < 2) {
      if(nameErrorDisplay) nameErrorDisplay.textContent = 'Por favor, digite um nome válido (mínimo 2 caracteres).';
      if(participantNameInput) participantNameInput.focus();
      return;
    }
    if(nameErrorDisplay) nameErrorDisplay.textContent = '';
    showScreen('home');
  });

  if(playQuizButton) playQuizButton.addEventListener('click', () => showScreen('category'));
  if(openSettingsButton) openSettingsButton.addEventListener('click', () => {
    showScreen('settings');
    const settingsMenu = document.getElementById('settingsMenuOptions');
    const designOptions = document.getElementById('designOptions');
    if(settingsMenu) settingsMenu.classList.remove('hidden');
    if(designOptions) designOptions.classList.add('hidden');
  });
  if(changeDesignButton) changeDesignButton.addEventListener('click', () => {
    const settingsMenu = document.getElementById('settingsMenuOptions');
    const designOptions = document.getElementById('designOptions');
    if(settingsMenu) settingsMenu.classList.add('hidden');
    if(designOptions) designOptions.classList.remove('hidden');
  });
  if(backFromDesignButton) backFromDesignButton.addEventListener('click', () => {
    const settingsMenu = document.getElementById('settingsMenuOptions');
    const designOptions = document.getElementById('designOptions');
    if(designOptions) designOptions.classList.add('hidden');
    if(settingsMenu) settingsMenu.classList.remove('hidden');
  });
  if(viewHistoryButton) viewHistoryButton.addEventListener('click', () => { showScreen('history'); displayHistory(); });
  if(aboutUsButton) aboutUsButton.addEventListener('click', () => { showScreen('about'); loadAboutUsContent(); });
  if(quizOptionsButton) quizOptionsButton.addEventListener('click', () => showScreen('quizOptions'));

  // Botões "Voltar"
  if(backFromQuizOptionsButton) backFromQuizOptionsButton.addEventListener('click', () => showScreen('settings'));
  if(backFromSettingsButton) backFromSettingsButton.addEventListener('click', () => showScreen('home'));
  if(backFromAboutButton) backFromAboutButton.addEventListener('click', () => showScreen('settings'));
  if(backFromHistoryButton) backFromHistoryButton.addEventListener('click', () => showScreen('settings'));

  // Temas
  if(themeDefaultButton && themeStylesheetLink) themeDefaultButton.addEventListener('click', () => { themeStylesheetLink.href = 'estilo1.css'; });
  if(themeFlatButton && themeStylesheetLink) themeFlatButton.addEventListener('click', () => { themeStylesheetLink.href = 'estilo2.css'; });
  if(themeNeonButton && themeStylesheetLink) themeNeonButton.addEventListener('click', () => { themeStylesheetLink.href = 'estilo3.css'; });

  // Navegação do Quiz
  if(playAgainButton) playAgainButton.addEventListener('click', () => startQuiz()); // Adicionado para botão "Jogar Novamente"
  if(changeCategoryButton) changeCategoryButton.addEventListener('click', () => showScreen('category'));
  if(nextLevelButton) nextLevelButton.addEventListener('click', () => {
    const nextLvlNum = parseInt(currentLevel, 10) + 1;
    currentLevel = nextLvlNum.toString();
    startQuiz();
  });
  if(backToHomeFromCategoryButton) backToHomeFromCategoryButton.addEventListener('click', () => showScreen('home'));
  if(backToCategoryFromLevelButton) backToCategoryFromLevelButton.addEventListener('click', () => showScreen('category'));
  if(backToLevelFromQuestionButton) backToLevelFromQuestionButton.addEventListener('click', () => {
    stopQuestionActivities();
    showScreen('level');
  });

  // Checkboxes de Opções do Quiz
  if(chkTime) chkTime.addEventListener('change', saveSettings);
  if(chkNext) chkNext.addEventListener('change', saveSettings);
  if(chkAudio) chkAudio.addEventListener('change', saveSettings);

  // --- Funcionalidade de Dica ---
  if(hintButton) hintButton.addEventListener('click', useHint);

  function useHint() {
      if (quizSettings.audio && hintSound) hintSound.play();
      if(hintButton) {
        hintButton.disabled = true;
        hintButton.classList.add('disabled-hint');
      }

      const availableIncorrectOptions = Array.from(optionsContainer.querySelectorAll('.option-btn:not([disabled])'))
          .filter(btn => btn.dataset.correct === 'false');

      shuffleArray(availableIncorrectOptions);

      let hintsToRemoveCount = 0;
      const totalActiveOptions = optionsContainer ? optionsContainer.querySelectorAll('.option-btn:not([disabled])').length : 0;
      if (availableIncorrectOptions.length > 0 && totalActiveOptions > 2) {
          if (totalActiveOptions === 4 && availableIncorrectOptions.length >=2) hintsToRemoveCount = 2;
          else if (totalActiveOptions === 3 && availableIncorrectOptions.length >=1) hintsToRemoveCount = 1;
          else if (availableIncorrectOptions.length >=1) hintsToRemoveCount = 1;
      }

      for (let i = 0; i < hintsToRemoveCount; i++) {
          if(availableIncorrectOptions[i]){
            availableIncorrectOptions[i].classList.add('hint-removed');
            availableIncorrectOptions[i].disabled = true;
          }
      }
  }

  // --- Lógica de Categorias e Níveis ---
  if (categoryButtons) {
    categoryButtons.forEach(btn => {
        btn.addEventListener('click', () => {
        currentCategory = btn.dataset.category;
        const filename = currentCategory.toLowerCase().replace(/\s+/g, '') + '.json';
        fetch(`data/${filename}`, { cache: 'no-cache' })
            .then(response => {
            if (!response.ok) throw new Error(`Não foi possível carregar ${filename}. Verifique o nome e caminho.`);
            return response.json();
            })
            .then(data => {
            quizData = data;
            showScreen('level');
            renderLevelButtons();
            })
            .catch(err => {
            console.error(`Erro ao carregar categoria ${currentCategory}:`, err);
            const errorContainer = screens.level?.querySelector('#levelSelectionGrid') || screens.category?.querySelector('.grid') || feedbackMessageElement;
            if (errorContainer) {
                errorContainer.innerHTML = `<p class="error" style="width:100%; text-align:center;">Erro ao carregar ‘${currentCategory}’: ${err.message}</p>`;
            } else {
                alert('Erro ao carregar perguntas para ‘' + currentCategory + '’: ' + err.message);
            }
            });
        });
    });
  }


  // --- Renderização Dinâmica dos Níveis ---
  function renderLevelButtons() {
    if(!levelSelectionGrid) return;
    levelSelectionGrid.innerHTML = '';
    const levelsData = quizData || {};
    const levelKeys = Object.keys(levelsData).sort((a, b) => parseInt(a) - parseInt(b));
    const progressData = getProgress();
    const categoryProgressKey = currentCategory;

    if (levelKeys.length === 0) {
        levelSelectionGrid.innerHTML = `<p class="error" style="width:100%; text-align:center;">Nenhum nível encontrado para esta categoria.</p>`;
        return;
    }
    levelKeys.forEach(levelId => {
      const levelNumber = parseInt(levelId, 10);
      const levelButton = document.createElement('button');
      levelButton.className = 'btn';
      levelButton.dataset.level = levelId;
      levelButton.textContent = `Nível ${levelId}`;

      const previousLevelNumber = levelNumber - 1;
      const categoryProgress = progressData[categoryProgressKey] || {};
      const currentLevelProgress = categoryProgress[`level${levelNumber}`];
      const previousLevelCompleted = categoryProgress[`level${previousLevelNumber}`] && categoryProgress[`level${previousLevelNumber}`] !== 'available' && categoryProgress[`level${previousLevelNumber}`] !== 'failed';
      const isUnlocked = levelNumber === 1 || previousLevelCompleted;

      if (!isUnlocked) {
        levelButton.classList.add('locked-level');
        levelButton.disabled = true;
        levelButton.textContent += ' 🔒';
      } else {
        if (currentLevelProgress === 'three_stars') levelButton.textContent += ' ⭐⭐⭐';
        else if (currentLevelProgress === 'two_stars') levelButton.textContent += ' ⭐⭐';
        else if (currentLevelProgress === 'one_star') levelButton.textContent += ' ⭐';
      }
      levelButton.addEventListener('click', () => {
        if (!levelButton.disabled) {
          currentLevel = levelId;
          startQuiz();
        }
      });
      levelSelectionGrid.appendChild(levelButton);
    });
  }

  // --- Lógica Principal do Quiz ---
  function startQuiz() {
    quizQuestions = (quizData[currentLevel] || []).slice();
    if (!quizQuestions.length) {
      const errorDest = screens.question?.querySelector('#feedbackMessage') || screens.level?.querySelector('#levelSelectionGrid');
      if(errorDest){
        errorDest.textContent = 'Nenhuma pergunta encontrada para este nível.';
        errorDest.className = 'error';
      }
      showScreen('level');
      return;
    }
    shuffleArray(quizQuestions);
    currentQuestionIndex = 0;
    score = 0;
    if(totalQuestionsNumDisplay) totalQuestionsNumDisplay.textContent = quizQuestions.length;
    if(nextQuestionButton) nextQuestionButton.classList.add('hidden');

    if(hintButton) {
        hintButton.classList.remove('hidden');
        hintButton.disabled = false;
        hintButton.classList.remove('disabled-hint');
    }

    if(feedbackMessageElement) {
        feedbackMessageElement.textContent = '';
        feedbackMessageElement.className = 'error';
    }

    showScreen('question');

    if(questionCategoryLevelTitle) questionCategoryLevelTitle.textContent = `${currentCategory} – Nível ${currentLevel}`;
    displayCurrentQuestion();
  }

  // --- Display Question ---
  function displayCurrentQuestion() {
    stopQuestionActivities();
    const questionObject = quizQuestions[currentQuestionIndex];
    if (!questionObject) {
        console.error("Objeto da pergunta não encontrado para o índice:", currentQuestionIndex);
        showScreen('level');
        return;
    }

    const timerContainer = document.querySelector('.timer-container');
    if(timerContainer) timerContainer.style.display = quizSettings.time ? 'block' : 'none';
    if(currentQuestionNumDisplay) currentQuestionNumDisplay.textContent = currentQuestionIndex + 1;
    if(questionTextElement) questionTextElement.textContent = questionObject.pergunta;

    if(feedbackMessageElement) {
        feedbackMessageElement.innerHTML = '';
        feedbackMessageElement.className = 'error';
    }
    if(optionsContainer) optionsContainer.innerHTML = '';
    if(nextQuestionButton) nextQuestionButton.classList.add('hidden');

    if(hintButton) {
        hintButton.disabled = false;
        hintButton.classList.remove('disabled-hint');
    }

    const shuffledOptions = shuffleArray(questionObject.opcoes?.slice());
    if (shuffledOptions && optionsContainer) {
        shuffledOptions.forEach(option => {
        const optionButton = document.createElement('button');
        optionButton.className = 'btn option-btn';
        optionButton.textContent = option.texto;
        optionButton.dataset.correct = option.correta;
        optionButton.addEventListener('click', handleOptionSelection);
        optionsContainer.appendChild(optionButton);
        });
    }
    if (quizSettings.time) {
      startTimer();
    }
  }

  // --- Select Option ---
  function handleOptionSelection(event) {
    stopQuestionActivities();
    const selectedButton = event.currentTarget;
    const isCorrect = selectedButton.dataset.correct === 'true';
    const currentQuestionObject = quizQuestions[currentQuestionIndex];
    if (!currentQuestionObject) return;

    const correctOptionText = currentQuestionObject.opcoes?.find(o => o.correta)?.texto || "";

    document.querySelectorAll('.option-btn').forEach(b => { b.disabled = true; });
    if(hintButton) hintButton.disabled = true;

    let feedbackHTML = '';
    if (isCorrect) {
      if (quizSettings.audio && correctSound) correctSound.play();
      selectedButton.classList.add('correct');
      feedbackHTML = 'Certo! 🎉';
      if(feedbackMessageElement) {
        feedbackMessageElement.classList.add('correct');
        feedbackMessageElement.classList.remove('incorrect');
      }
      score++;
    } else {
      if (quizSettings.audio && incorrectSound) incorrectSound.play();
      selectedButton.classList.add('wrong');
      feedbackHTML = `Errado! A resposta correta é: "${correctOptionText}"`;
      if(feedbackMessageElement) {
        feedbackMessageElement.classList.add('incorrect');
        feedbackMessageElement.classList.remove('correct');
      }
      const correctButton = Array.from(document.querySelectorAll('.option-btn')).find(b => b.dataset.correct === 'true');
      if (correctButton) correctButton.classList.add('correct');
    }
    const description = currentQuestionObject.descricao;
    if (description) {
      feedbackHTML += `<br><span class="question-description">${description}</span>`;
    }
    if(feedbackMessageElement) feedbackMessageElement.innerHTML = feedbackHTML;

    if (quizSettings.next) {
      if(nextQuestionButton) nextQuestionButton.classList.remove('hidden');
    } else {
      autoAdvanceTimeout = setTimeout(() => {
        currentQuestionIndex++;
        if (currentQuestionIndex < quizQuestions.length) {
          displayCurrentQuestion();
        } else {
          showResultScreen();
        }
      }, 2500);
    }
  }

  if(nextQuestionButton) {
    nextQuestionButton.addEventListener('click', () => {
        currentQuestionIndex++;
        if (currentQuestionIndex < quizQuestions.length) {
        displayCurrentQuestion();
        } else {
        showResultScreen();
        }
    });
  }

  // --- Temporizador e Atividades ---
  function startTimer() {
    clearInterval(timerInterval);
    timeLeft = 15;
    if(timerDisplay) timerDisplay.textContent = timeLeft;
    timerInterval = setInterval(() => {
      timeLeft--;
      if(timerDisplay) timerDisplay.textContent = timeLeft;
      if (timeLeft <= 0) {
        clearInterval(timerInterval);
        handleTimeUp();
      }
    }, 1000);
  }
  function stopQuestionActivities() {
    clearInterval(timerInterval);
    clearTimeout(autoAdvanceTimeout);
  }
  function handleTimeUp() {
    stopQuestionActivities();
    if (quizSettings.audio && timeoutSound) timeoutSound.play();
    const currentQuestionObject = quizQuestions[currentQuestionIndex];
    if (!currentQuestionObject) return;

    const correctOptionText = currentQuestionObject.opcoes?.find(o => o.correta)?.texto || "";
    let feedbackHTML = `Tempo esgotado! Resposta: "${correctOptionText}" ⏳`;

    if(feedbackMessageElement) {
        feedbackMessageElement.classList.add('incorrect');
        feedbackMessageElement.classList.remove('correct');
    }
    const description = currentQuestionObject.descricao;
    if (description) {
      feedbackHTML += `<br><span class="question-description">${description}</span>`;
    }
    if(feedbackMessageElement) feedbackMessageElement.innerHTML = feedbackHTML;

    document.querySelectorAll('.option-btn').forEach(b => {
      b.disabled = true;
      if (b.dataset.correct === 'true') { b.classList.add('correct'); }
    });
    if(hintButton) hintButton.disabled = true;

    if (quizSettings.next) {
      if(nextQuestionButton) nextQuestionButton.classList.remove('hidden');
    } else {
      autoAdvanceTimeout = setTimeout(() => {
        currentQuestionIndex++;
        if (currentQuestionIndex < quizQuestions.length) {
          displayCurrentQuestion();
        } else {
          showResultScreen();
        }
      }, 2500);
    }
  }

  // --- Tela de Resultado ---
  function showResultScreen() {
    stopQuestionActivities();
    const totalQuestions = quizQuestions.length;
    const percentageScore = totalQuestions > 0 ? (score / totalQuestions) * 100 : 0;

    saveQuizResultToHistory(currentCategory, currentLevel, score, totalQuestions);

    const progressData = getProgress();
    if (!progressData[currentCategory]) progressData[currentCategory] = {};
    const levelKey = `level${currentLevel}`;
    let newProgressStatus;
    if (percentageScore === 100) newProgressStatus = 'three_stars';
    else if (percentageScore >= 90) newProgressStatus = 'two_stars';
    else if (percentageScore >= 80) newProgressStatus = 'one_star';
    else newProgressStatus = 'failed';

    const currentLevelStatus = progressData[currentCategory][levelKey];
    const statusOrder = ['failed', 'available', 'one_star', 'two_stars', 'three_stars'];
    if (!currentLevelStatus || statusOrder.indexOf(newProgressStatus) > statusOrder.indexOf(currentLevelStatus)) {
      progressData[currentCategory][levelKey] = newProgressStatus;
    }

    const nextLevelNumber = parseInt(currentLevel, 10) + 1;
    const nextLevelExists = quizData && quizData[nextLevelNumber.toString()];

    if (newProgressStatus !== 'failed' && nextLevelExists) {
      const nextLevelKey = `level${nextLevelNumber}`;
      if (!progressData[currentCategory][nextLevelKey] || progressData[currentCategory][nextLevelKey] === 'failed') {
        progressData[currentCategory][nextLevelKey] = 'available';
      }
    }
    setProgress(progressData);

    let resultMessage = `Você acertou ${percentageScore.toFixed(0)}% das perguntas. `;
    if (percentageScore === 100) resultMessage += 'UAU! Três Estrelas! Nível Perfeito! ⭐⭐⭐';
    else if (percentageScore >= 90) resultMessage += 'Excelente! Duas Estrelas! Continue assim! ⭐⭐';
    else if (percentageScore >= 80) resultMessage += 'Parabéns, nível concluído! Uma Estrela! ⭐';
    else resultMessage += `É necessário 80% para liberar o próximo nível.`;

    if(finalScoreSpan) finalScoreSpan.textContent = score;
    if(maxScoreSpan) maxScoreSpan.textContent = totalQuestions;
    if(resultMessageParagraph) resultMessageParagraph.textContent = resultMessage;

    showScreen('result');

    if (nextLevelExists && newProgressStatus !== 'failed') {
      if(nextLevelButton) {
        nextLevelButton.classList.remove('hidden');
        nextLevelButton.disabled = false;
      }
      if(nextLevelNumDisplay) nextLevelNumDisplay.textContent = nextLevelNumber.toString();
    } else {
      if(nextLevelButton) {
        nextLevelButton.classList.add('hidden');
        nextLevelButton.disabled = true;
      }
    }
  }

  // --- Histórico ---
  function saveQuizResultToHistory(category, level, currentScore, totalQuestions) {
    const participantNameValue = participantNameInput ? participantNameInput.value.trim() : "Anónimo";
    const historyArray = JSON.parse(localStorage.getItem('quizHistory') || '[]');
    const now = new Date().toLocaleString('pt-AO', {
      year: 'numeric', month: 'numeric', day: 'numeric',
      hour: '2-digit', minute: '2-digit'
    });
    historyArray.push({
      id: Date.now(), participant: participantNameValue,
      category, level, score: currentScore, totalQuestions, timestamp: now
    });
    localStorage.setItem('quizHistory', JSON.stringify(historyArray));
  }
  function displayHistory() {
    if(!historyListDiv) return;
    const historyArray = JSON.parse(localStorage.getItem('quizHistory') || '[]');
    historyListDiv.innerHTML = '';
    if (historyArray.length === 0) {
      historyListDiv.innerHTML = '<p>Nenhum quiz jogado ainda.</p>';
    } else {
      historyArray.slice().reverse().forEach(entry => {
        const historyItemDiv = document.createElement('div');
        historyItemDiv.className = 'history-item';
        historyItemDiv.innerHTML = `
          <p><strong>Nome:</strong> ${entry.participant}</p>
          <p><strong>Categoria:</strong> ${entry.category}</p>
          <p><strong>Nível:</strong> ${entry.level}</p>
          <p><strong>Data:</strong> ${entry.timestamp}</p>
          <p><strong>Pontos:</strong> ${entry.score} / ${entry.totalQuestions}</p>
        `;
        historyListDiv.appendChild(historyItemDiv);
      });
    }
  }

  // --- Sobre Nós ---
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
        websiteParagraph.style.marginTop = '0.25rem';
        const websiteLink = document.createElement('a');
        websiteLink.href = aboutInfo.website; websiteLink.target = '_blank'; websiteLink.rel = 'noopener';
        websiteLink.textContent = 'Visite nosso site'; websiteLink.style.color = '#0057e7';
        websiteParagraph.appendChild(websiteLink); aboutContentDiv.appendChild(websiteParagraph);
      }
      if (aboutInfo.description) {
        const descriptionParagraph = document.createElement('p');
        descriptionParagraph.textContent = aboutInfo.description; descriptionParagraph.style.marginBottom = '1rem';
        aboutContentDiv.appendChild(descriptionParagraph);
      }
      if (aboutInfo.whoAreWe && (aboutInfo.whoAreWe.title || aboutInfo.whoAreWe.text)) {
        if (aboutInfo.whoAreWe.title) {
          const whoAreWeTitle = document.createElement('h3');
          whoAreWeTitle.textContent = aboutInfo.whoAreWe.title; whoAreWeTitle.style.marginTop = '1rem';
          aboutContentDiv.appendChild(whoAreWeTitle);
        }
        if (aboutInfo.whoAreWe.text) {
          const whoAreWeText = document.createElement('p');
          whoAreWeText.textContent = aboutInfo.whoAreWe.text; whoAreWeText.style.marginBottom = '1rem';
          aboutContentDiv.appendChild(whoAreWeText);
        }
      }
      if (aboutInfo.location && (aboutInfo.location.title || Array.isArray(aboutInfo.location.text))) {
        if (aboutInfo.location.title) {
          const locationTitle = document.createElement('h3');
          locationTitle.textContent = aboutInfo.location.title; locationTitle.style.marginTop = '1rem';
          aboutContentDiv.appendChild(locationTitle);
        }
        if (Array.isArray(aboutInfo.location.text)) {
          const locationList = document.createElement('ul');
          locationList.style.listStyle = 'disc'; locationList.style.marginLeft = '1.5rem'; locationList.style.marginBottom = '1rem';
          aboutInfo.location.text.forEach(line => {
            const listItem = document.createElement('li');
            listItem.textContent = line; locationList.appendChild(listItem);
          });
          aboutContentDiv.appendChild(locationList);
        }
      }
      if (aboutInfo.contacts && (aboutInfo.contacts.title || aboutInfo.contacts.email || aboutInfo.contacts.phone || aboutInfo.contacts.socialMedia)) {
        if (aboutInfo.contacts.title) {
          const contactsTitle = document.createElement('h3');
          contactsTitle.textContent = aboutInfo.contacts.title; contactsTitle.style.marginTop = '1rem';
          aboutContentDiv.appendChild(contactsTitle);
        }
        const contactsList = document.createElement('ul');
        contactsList.style.listStyle = 'none'; contactsList.style.paddingLeft = '0'; contactsList.style.marginBottom = '1rem';
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
    if (!Array.isArray(array)) return [];
    for (let i = array.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [array[i], array[j]] = [array[j], array[i]];
    }
    return array;
  }
});

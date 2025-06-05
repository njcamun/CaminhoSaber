// script.js
document.addEventListener('DOMContentLoaded', () => {
  // ======== SONS ========
  const correctSound = new Audio('sounds/correct.mp3');
  const incorrectSound = new Audio('sounds/incorrect.mp3');
  const timeoutSound = new Audio('sounds/timeout.mp3');
  const hintSound = new Audio('sounds/hint.mp3');

  // --- Chaves e Funções de Progresso no localStorage ---
  const PROGRESS_KEY = 'quizProgress';
  function getProgress() {
    return JSON.parse(localStorage.getItem(PROGRESS_KEY) || '{}');
  }
  function setProgress(progress) {
    localStorage.setItem(PROGRESS_KEY, JSON.stringify(progress));
  }

  // --- NOVO: Chave e Estado para as Configurações do Quiz ---
  const SETTINGS_KEY = 'quizSettings';
  let quizSettings = {
    time: true,
    next: true,
    audio: true,
  };

  // --- Estado e Dados ---
  let quizData = {}; // JSON carregado para a categoria atual
  let currentCategory = '';
  let currentLevel = '';
  let quizQuestions = [],
    currentQuestionIndex = 0,
    score = 0;
  let timerInterval, timeLeft;

  // --- Mapeamento de telas (adicionar a nova tela) ---
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

  function show(screenKey) {
    Object.values(screens).forEach(s => s.classList.add('hidden'));
    screens[screenKey].classList.remove('hidden');
  }

  // --- Botões principais ---
  const startButton = document.getElementById('startButton');
  const participantNameInput = document.getElementById('participantName');
  const nameErrorDisplay = document.getElementById('nameError');

  const playQuizButton = document.getElementById('playQuizButton');
  const openSettingsButton = document.getElementById('openSettingsButton');

  const changeDesignButton = document.getElementById('changeDesignButton');
  const viewHistoryButton = document.getElementById('viewHistoryButton');
  const aboutUsButton = document.getElementById('aboutUsButton');
  const quizOptionsButton = document.getElementById('quizOptionsButton');

  const backFromSettings = document.getElementById('backFromSettings');
  const backFromDesign = document.getElementById('backFromDesign');
  const backFromQuizOptions = document.getElementById('backFromQuizOptions');


  const themeDefaultBtn = document.getElementById('themeDefault');
  const themeFlatBtn = document.getElementById('themeFlat');
  const themeNeonBtn = document.getElementById('themeNeon');
  const themeStylesheetLink = document.getElementById('themeStylesheet');

  const backFromAbout = document.getElementById('backFromAbout');
  const backFromHistory = document.getElementById('backFromHistory');

  const playAgainButton = document.getElementById('playAgainButton');
  const changeCategoryButton = document.getElementById('changeCategoryButton');
  const nextLevelButton = document.getElementById('nextLevelButton');
  const nextLevelNumDisplay = document.getElementById('nextLevelNum');


  const backToHomeFromCategory = document.getElementById('backToHomeFromCategory');
  const backToCategoryFromLevel = document.getElementById('backToCategoryFromLevel');
  const backToLevelFromQuestion = document.getElementById('backToLevelFromQuestion');

  const categoryButtons = document.querySelectorAll('.category-btn');
  const levelGrid = document.getElementById('levelSelectionGrid');

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

  // --- Funções para gerenciar as configurações ---
  function saveSettings() {
    quizSettings = {
      time: chkTime.checked,
      next: chkNext.checked,
      audio: chkAudio.checked,
    };
    localStorage.setItem(SETTINGS_KEY, JSON.stringify(quizSettings));
  }

  function loadSettings() {
    const savedSettings = JSON.parse(localStorage.getItem(SETTINGS_KEY));
    if (savedSettings) {
      quizSettings = savedSettings;
    }
    chkTime.checked = quizSettings.time;
    chkNext.checked = quizSettings.next;
    chkAudio.checked = quizSettings.audio;
  }

  // ======================================
  // 1) Inicialização da página
  // ======================================
  loadSettings();

  const savedParticipantName = localStorage.getItem('participantName');
  if (savedParticipantName) {
    participantNameInput.value = savedParticipantName;
  }
  participantNameInput.addEventListener('input', () => {
    localStorage.setItem('participantName', participantNameInput.value.trim());
  });

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
    show('category');
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

  quizOptionsButton.addEventListener('click', () => {
    show('quizOptions');
  });

  backFromQuizOptions.addEventListener('click', () => {
    show('settings');
  });

  chkTime.addEventListener('change', saveSettings);
  chkNext.addEventListener('change', saveSettings);
  chkAudio.addEventListener('change', saveSettings);

  backFromSettings.addEventListener('click', () => {
    show('home');
  });
  backFromAbout.addEventListener('click', () => {
    show('settings');
  });
  backFromHistory.addEventListener('click', () => {
    show('settings');
  });

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

  changeCategoryButton.addEventListener('click', () => {
    show('category');
  });

  nextLevelButton.addEventListener('click', () => {
    const nextLvlNum = parseInt(currentLevel, 10) + 1;
    currentLevel = nextLvlNum.toString();
    startQuiz();
  });

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
  // 2) Quando o usuário clica em uma Categoria
  // ======================================
  categoryButtons.forEach(btn => {
    btn.addEventListener('click', () => {
      const rawCategory = btn.dataset.category;
      currentCategory = rawCategory;
      const filename = rawCategory.toLowerCase().replace(/\s+/g, '') + '.json';

      fetch(`data/${filename}`, {
          cache: 'no-cache'
        })
        .then(response => {
          if (!response.ok) {
            throw new Error(`Não foi possível carregar ${filename}`);
          }
          return response.json();
        })
        .then(data => {
          quizData = data;
          show('level');
          renderLevels();
        })
        .catch(err => {
          console.error(err);
          alert('Erro ao carregar perguntas para ‘' + rawCategory + '’: ' + err.message);
        });
    });
  });

  // ======================================
  // 3) Renderização Dinâmica dos Níveis
  // ======================================
  function renderLevels() {
    levelGrid.innerHTML = '';
    const levelsObj = quizData || {};
    const nivelKeys = Object.keys(levelsObj).sort((a, b) => parseInt(a) - parseInt(b));
    const prog = getProgress();
    const baseKey = currentCategory;

    nivelKeys.forEach(lv => {
      const lvNum = parseInt(lv, 10);
      const btn = document.createElement('button');
      btn.className = 'btn';
      btn.dataset.level = lv;
      btn.textContent = `Nível ${lv}`;

      const prevLvl = lvNum - 1;
      const progressObj = prog[baseKey] || {};
      const levelProgress = progressObj[`level${lvNum}`];
      const prevLevelCompleted = progressObj[`level${prevLvl}`] && progressObj[`level${prevLvl}`] !== 'available' && progressObj[`level${prevLvl}`] !== 'failed';

      const isUnlocked = lvNum === 1 || prevLevelCompleted;

      if (!isUnlocked) {
        btn.classList.add('locked-level');
        btn.disabled = true;
        btn.textContent += ' 🔒';
      } else {
        if (levelProgress === 'three_stars') {
          btn.textContent += ' ⭐⭐⭐';
        } else if (levelProgress === 'two_stars') {
          btn.textContent += ' ⭐⭐';
        } else if (levelProgress === 'one_star') {
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
    quizQuestions = (quizData[currentLevel] || []).slice();
    if (!quizQuestions.length) {
      alert('Nenhuma pergunta encontrada neste nível.');
      return;
    }
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
      `${currentCategory} – Nível ${currentLevel}`;
    displayQuestion();
  }

  function displayQuestion() {
    stopTimer();
    const questionObj = quizQuestions[currentQuestionIndex];

    document.querySelector('.timer-container').style.display = quizSettings.time ? 'block' : 'none';

    currentQuestionNumDisplay.textContent = currentQuestionIndex + 1;
    questionTextElement.textContent = questionObj.pergunta;

    feedbackMessageElement.innerHTML = '';
    feedbackMessageElement.classList.remove('correct', 'incorrect');
    optionsContainer.innerHTML = '';
    nextQuestionButton.classList.add('hidden');
    hintButton.disabled = false;

    const shuffledOptions = shuffleArray(questionObj.opcoes.slice());
    shuffledOptions.forEach(opt => {
      const btn = document.createElement('button');
      btn.className = 'btn option-btn';
      btn.textContent = opt.texto;
      btn.dataset.correct = opt.correta;
      btn.addEventListener('click', selectOption);
      optionsContainer.appendChild(btn);
    });

    if (quizSettings.time) {
      startTimer();
    }
  }

  function selectOption(event) {
    stopTimer();
    const selectedBtn = event.currentTarget;
    const isCorrect = selectedBtn.dataset.correct === 'true';
    const questionObj = quizQuestions[currentQuestionIndex];
    const correctOptionText = questionObj.opcoes.find(o => o.correta).texto;

    document.querySelectorAll('.option-btn').forEach(b => {
      b.disabled = true;
    });

    let feedbackHTML = '';

    if (isCorrect) {
      if (quizSettings.audio) correctSound.play();
      selectedBtn.classList.add('correct');
      feedbackHTML = 'Certo! 🎉';
      feedbackMessageElement.classList.add('correct');
      feedbackMessageElement.classList.remove('incorrect');
      score++;
    } else {
      if (quizSettings.audio) incorrectSound.play();
      selectedBtn.classList.add('wrong');
      feedbackHTML = `Errado! A resposta correta é: "${correctOptionText}"`;
      feedbackMessageElement.classList.add('incorrect');
      feedbackMessageElement.classList.remove('correct');

      const correctBtn = Array.from(document.querySelectorAll('.option-btn'))
        .find(b => b.dataset.correct === 'true');
      if (correctBtn) correctBtn.classList.add('correct');
    }

    const description = questionObj.descricao;
    if (description) {
      feedbackHTML += `<br><span class="question-description">${description}</span>`;
    }

    feedbackMessageElement.innerHTML = feedbackHTML;

    if (quizSettings.next) {
      nextQuestionButton.classList.remove('hidden');
    } else {
      setTimeout(() => {
        currentQuestionIndex++;
        if (currentQuestionIndex < quizQuestions.length) {
          displayQuestion();
        } else {
          showResult();
        }
      }, 2500);
    }
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
    if (quizSettings.audio) timeoutSound.play();
    const questionObj = quizQuestions[currentQuestionIndex];
    const correctOptionText = questionObj.opcoes.find(o => o.correta).texto;

    let feedbackHTML = `Tempo esgotado! Resposta: "${correctOptionText}" ⏳`;
    feedbackMessageElement.classList.add('incorrect');

    const description = questionObj.descricao;
    if (description) {
      feedbackHTML += `<br><span class="question-description">${description}</span>`;
    }

    feedbackMessageElement.innerHTML = feedbackHTML;

    document.querySelectorAll('.option-btn').forEach(b => {
      b.disabled = true;
      if (b.dataset.correct === 'true') {
        b.classList.add('correct');
      }
    });

    if (quizSettings.next) {
      nextQuestionButton.classList.remove('hidden');
    } else {
      setTimeout(() => {
        currentQuestionIndex++;
        if (currentQuestionIndex < quizQuestions.length) {
          displayQuestion();
        } else {
          showResult();
        }
      }, 2500);
    }
  }

  // ======================================
  // 6) Tela de Resultado e Histórico
  // ======================================
  function showResult() {
    stopTimer();

    const totalQ = quizQuestions.length;
    const pct = (score / totalQ) * 100;

    saveQuizHistory(currentCategory, currentLevel, score, totalQ);

    const progressObj = getProgress();
    if (!progressObj[currentCategory]) progressObj[currentCategory] = {};
    const levelKey = `level${currentLevel}`;

    let newProgressStatus;
    if (pct === 100) {
      newProgressStatus = 'three_stars';
    } else if (pct >= 90) {
      newProgressStatus = 'two_stars';
    } else if (pct >= 80) {
      newProgressStatus = 'one_star';
    } else {
      newProgressStatus = 'failed';
    }

    const currentLevelStatus = progressObj[currentCategory][levelKey];
    const statusOrder = ['failed', 'available', 'one_star', 'two_stars', 'three_stars'];

    if (!currentLevelStatus || statusOrder.indexOf(newProgressStatus) > statusOrder.indexOf(currentLevelStatus)) {
      progressObj[currentCategory][levelKey] = newProgressStatus;
    }

    const nextLvlNum = parseInt(currentLevel, 10) + 1;
    const nextLevelExists = !!quizData[nextLvlNum];

    if (newProgressStatus !== 'failed' && nextLevelExists) {
      const nextLevelKey = `level${nextLvlNum}`;
      if (!progressObj[currentCategory][nextLevelKey] || progressObj[currentCategory][nextLevelKey] === 'failed') {
        progressObj[currentCategory][nextLevelKey] = 'available';
      }
    }

    setProgress(progressObj);


    let msg = `Você acertou ${pct.toFixed(0)}% das perguntas. `;
    if (pct === 100) {
      msg += 'UAU! Três Estrelas! Nível Perfeito! ⭐⭐⭐';
    } else if (pct >= 90) {
      msg += 'Excelente! Duas Estrelas! Continue assim! ⭐⭐';
    } else if (pct >= 80) {
      msg += 'Parabéns, nível concluído! Uma Estrela! ⭐';
    } else {
      msg += `É necessário 80% para liberar o próximo nível.`;
    }

    finalScoreSpan.textContent = score;
    maxScoreSpan.textContent = totalQ;
    resultMessageParagraph.textContent = msg;
    show('result');

    if (nextLevelExists && newProgressStatus !== 'failed') {
      nextLevelButton.classList.remove('hidden');
      nextLevelButton.disabled = false;
      nextLevelNumDisplay.textContent = nextLvlNum;
    } else {
      nextLevelButton.classList.add('hidden');
      nextLevelButton.disabled = true;
    }
  }

  function saveQuizHistory(category, level, score, totalQuestions) {
    const historyArray = JSON.parse(localStorage.getItem('quizHistory') || '[]');
    const now = new Date().toLocaleString('pt-AO', {
      year: 'numeric',
      month: 'numeric',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
    historyArray.push({
      id: Date.now(),
      participant: participantNameInput.value.trim(),
      category,
      level,
      score,
      totalQuestions,
      timestamp: now
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
      const res = await fetch('./data/sobreNos.json', {
        cache: 'no-cache'
      });
      if (!res.ok) throw new Error(`HTTP ${res.status}: ${res.statusText}`);
      const data = await res.json();
      const info = data.welcomeInfo;
      const contentDiv = document.getElementById('aboutContent');
      contentDiv.innerHTML = '';

      if (info.title) {
        const h2 = document.createElement('h2');
        h2.textContent = info.title;
        contentDiv.appendChild(h2);
      }

      if (info.website) {
        const pLink = document.createElement('p');
        pLink.style.marginTop = '0.25rem';
        const a = document.createElement('a');
        a.href = info.website;
        a.target = '_blank';
        a.rel = 'noopener';
        a.textContent = 'Visite nosso site';
        a.style.color = '#0057e7';
        pLink.appendChild(a);
        contentDiv.appendChild(pLink);
      }

      if (info.description) {
        const pDesc = document.createElement('p');
        pDesc.textContent = info.description;
        pDesc.style.marginBottom = '1rem';
        contentDiv.appendChild(pDesc);
      }

      if (info.whoAreWe && (info.whoAreWe.title || info.whoAreWe.text)) {
        if (info.whoAreWe.title) {
          const h3 = document.createElement('h3');
          h3.textContent = info.whoAreWe.title;
          h3.style.marginTop = '1rem';
          contentDiv.appendChild(h3);
        }
        if (info.whoAreWe.text) {
          const pWho = document.createElement('p');
          pWho.textContent = info.whoAreWe.text;
          pWho.style.marginBottom = '1rem';
          contentDiv.appendChild(pWho);
        }
      }

      if (info.location && (info.location.title || Array.isArray(info.location.text))) {
        if (info.location.title) {
          const h3Loc = document.createElement('h3');
          h3Loc.textContent = info.location.title;
          h3Loc.style.marginTop = '1rem';
          contentDiv.appendChild(h3Loc);
        }
        if (Array.isArray(info.location.text)) {
          const ulLoc = document.createElement('ul');
          ulLoc.style.listStyle = 'disc';
          ulLoc.style.marginLeft = '1.5rem';
          ulLoc.style.marginBottom = '1rem';
          info.location.text.forEach(linha => {
            const li = document.createElement('li');
            li.textContent = linha;
            ulLoc.appendChild(li);
          });
          contentDiv.appendChild(ulLoc);
        }
      }

      if (info.contacts && (info.contacts.title || info.contacts.email || info.contacts.phone || info.contacts.socialMedia)) {
        if (info.contacts.title) {
          const h3Cont = document.createElement('h3');
          h3Cont.textContent = info.contacts.title;
          h3Cont.style.marginTop = '1rem';
          contentDiv.appendChild(h3Cont);
        }
        const ulCont = document.createElement('ul');
        ulCont.style.listStyle = 'none';
        ulCont.style.paddingLeft = '0';
        ulCont.style.marginBottom = '1rem';

        if (info.contacts.email) {
          const liEmail = document.createElement('li');
          liEmail.innerHTML = `<strong>Email:</strong> ${info.contacts.email}`;
          ulCont.appendChild(liEmail);
        }
        if (info.contacts.phone) {
          const liPhone = document.createElement('li');
          liPhone.innerHTML = `<strong>Telefone:</strong> ${info.contacts.phone}`;
          ulCont.appendChild(liPhone);
        }
        if (info.contacts.socialMedia) {
          const liSM = document.createElement('li');
          liSM.innerHTML = `<strong>Redes Sociais:</strong> ${info.contacts.socialMedia}`;
          ulCont.appendChild(liSM);
        }

        contentDiv.appendChild(ulCont);
      }
    } catch (err) {
      console.error('Erro ao carregar sobreNos.json:', err);
      const contentDiv = document.getElementById('aboutContent');
      contentDiv.innerHTML = `
        <p style="color: #c00; font-style: italic;">
          Falha ao carregar informações de “Sobre Nós”.<br>
          Verifique se <em>data/sobreNos.json</em> existe e tem formato correto.
        </p>
      `;
    }
  }

  // ======================================
  // 8) Utilitários
  // ======================================
  function shuffleArray(arr) {
    for (let i = arr.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [arr[i], arr[j]] = [arr[j], arr[i]];
    }
    return arr;
  }
});

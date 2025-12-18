import { QUESTIONS, CATEGORIES } from "./questions.js";

/**
 * Local storage keys
 */
const LS_STATS = "apt_exam_stats_v1";

/**
 * DOM
 */
const chipsEl = document.getElementById("chips");
const modeEl = document.getElementById("mode");
const countEl = document.getElementById("count");
const focusEl = document.getElementById("focus");
const startBtn = document.getElementById("startBtn");
const resetStatsBtn = document.getElementById("resetStatsBtn");

const bestScoreEl = document.getElementById("bestScore");
const currentModeEl = document.getElementById("currentMode");
const progressEl = document.getElementById("progress");
const examEl = document.getElementById("exam");

/**
 * Default weakness profile (based on your results)
 * Lower score ratio => higher weight.
 */
const DEFAULT_BASELINE = {
  privacy_security: { correct: 19, total: 22 },
  network: { correct: 12, total: 14 },
  setup_backup_restore: { correct: 14, total: 16 },
  apple_account_icloud: { correct: 5, total: 7 },
};

function loadStats() {
  const raw = localStorage.getItem(LS_STATS);
  if (!raw) {
    return {
      best: null, // {score,total}
      history: [], // attempts
      perCategory: structuredClone(DEFAULT_BASELINE), // adaptive
    };
  }
  try {
    const parsed = JSON.parse(raw);
    // backfill missing keys
    parsed.best ??= null;
    parsed.history ??= [];
    parsed.perCategory ??= structuredClone(DEFAULT_BASELINE);
    return parsed;
  } catch {
    return {
      best: null,
      history: [],
      perCategory: structuredClone(DEFAULT_BASELINE),
    };
  }
}

function saveStats(stats) {
  localStorage.setItem(LS_STATS, JSON.stringify(stats));
}

/**
 * Build chips from baseline
 */
function renderChips(stats) {
  chipsEl.innerHTML = "";

  const items = Object.entries(stats.perCategory).map(([key, v]) => {
    const label = CATEGORIES[key] ?? key;
    const pct = v.total > 0 ? Math.round((v.correct / v.total) * 100) : 0;
    return { key, label, correct: v.correct, total: v.total, pct };
  });

  for (const it of items) {
    const div = document.createElement("div");
    div.className = "chip";
    div.innerHTML = `<strong>${it.label}</strong> ${it.correct}/${it.total} <span style="opacity:.85">(${it.pct}%)</span>`;
    chipsEl.appendChild(div);
  }
}

/**
 * Weighted exam builder
 */
function buildExamQuestions({ count, focus, stats }) {
  let pool = QUESTIONS.slice();

  if (focus !== "smart" && focus !== "all") {
    pool = pool.filter(q => q.category === focus);
  }

  // If user forced a category but pool is small, just reuse full pool for the remainder
  if (pool.length < count) {
    pool = QUESTIONS.slice();
  }

  // Smart weighting: choose more from weaker categories using perCategory ratios.
  const weights = {};
  for (const [cat, v] of Object.entries(stats.perCategory)) {
    const ratio = v.total > 0 ? v.correct / v.total : 0.5;
    // weaker => bigger weight. clamp.
    weights[cat] = clamp(1.8 - ratio, 0.6, 1.6);
  }

  // If focus is "all", treat weights normal. If focus is "smart", apply weights.
  // If focus is specific category, pool already filtered.
  const picked = [];
  const usedIds = new Set();

  // We do a weighted random pick without replacement.
  const attemptsLimit = 5000;
  let attempts = 0;

  while (picked.length < count && attempts < attemptsLimit) {
    attempts++;

    const candidates = pool.filter(q => !usedIds.has(q.id));
    if (candidates.length === 0) break;

    const q = weightedPick(candidates, (item) => {
      if (focus === "smart") return weights[item.category] ?? 1;
      return 1;
    });

    usedIds.add(q.id);
    picked.push(q);
  }

  // If still short (shouldn’t happen), fill from remaining pool normally.
  if (picked.length < count) {
    const remaining = pool.filter(q => !usedIds.has(q.id));
    for (const q of remaining.slice(0, count - picked.length)) {
      picked.push(q);
    }
  }

  // Shuffle choices per question but keep correct index accurate
  return picked.map(q => shuffleQuestionChoices(q));
}

function shuffleQuestionChoices(q) {
  const indexed = q.choices.map((text, idx) => ({ text, idx }));
  const shuffled = shuffle(indexed);
  const newChoices = shuffled.map(x => x.text);
  const newAnswerIndex = shuffled.findIndex(x => x.idx === q.answerIndex);
  return { ...q, choices: newChoices, answerIndex: newAnswerIndex };
}

/**
 * Exam State
 */
let state = {
  mode: "exam",
  focus: "smart",
  total: 17,
  questions: [],
  index: 0,
  answers: [], // {id, chosenIndex, correct, category}
  locked: false,
  stats: loadStats(),
};

function renderHeaderStats() {
  currentModeEl.textContent = `Mode: ${state.mode}`;
  const best = state.stats.best;
  bestScoreEl.textContent = best ? `Best score: ${best.score}/${best.total}` : "Best score: --";
  progressEl.textContent = `Question ${Math.min(state.index + 1, state.total)} of ${state.total}`;
}

function startExam() {
  state.mode = modeEl.value;
  state.total = parseInt(countEl.value, 10);
  state.focus = focusEl.value;

  state.questions = buildExamQuestions({
    count: state.total,
    focus: state.focus,
    stats: state.stats,
  });

  state.index = 0;
  state.answers = [];
  state.locked = false;

  renderHeaderStats();
  renderQuestion();
}

function renderQuestion() {
  examEl.innerHTML = "";

  const q = state.questions[state.index];
  if (!q) {
    renderResults();
    return;
  }

  const card = document.createElement("div");
  card.className = "qcard";

  const catLabel = CATEGORIES[q.category] ?? q.category;

  const head = document.createElement("div");
  head.className = "qhead";
  head.innerHTML = `
    <div class="qmeta">
      <div class="badge"><strong>${catLabel}</strong></div>
      <div class="badge">Difficulty <strong>${q.difficulty}</strong></div>
    </div>
    <div class="badge">ID <strong>${q.id}</strong></div>
  `;

  const text = document.createElement("div");
  text.className = "qtext";
  text.textContent = q.question;

  const answers = document.createElement("div");
  answers.className = "answers";

  const prev = state.answers.find(a => a.id === q.id);

  q.choices.forEach((choiceText, idx) => {
    const btn = document.createElement("button");
    btn.type = "button";
    btn.className = "choice";
    btn.textContent = choiceText;

    // If already answered, show markings
    if (prev) {
      btn.disabled = true;
      if (idx === q.answerIndex) btn.classList.add("correct");
      if (idx === prev.chosenIndex && !prev.correct) btn.classList.add("wrong");
    }

    btn.addEventListener("click", () => onChoose(idx));
    answers.appendChild(btn);
  });

  card.appendChild(head);
  card.appendChild(text);
  card.appendChild(answers);

  // feedback section
  const feedback = document.createElement("div");
  feedback.className = "feedback";
  feedback.style.display = "none";
  card.appendChild(feedback);

  // nav
  const nav = document.createElement("div");
  nav.className = "nav";

  const backBtn = document.createElement("button");
  backBtn.type = "button";
  backBtn.className = "btn";
  backBtn.textContent = "Back";
  backBtn.disabled = state.index === 0;
  backBtn.addEventListener("click", () => {
    state.index = Math.max(0, state.index - 1);
    renderHeaderStats();
    renderQuestion();
  });

  const nextBtn = document.createElement("button");
  nextBtn.type = "button";
  nextBtn.className = "btn primary";
  nextBtn.textContent = state.index === state.total - 1 ? "Finish" : "Next";
  nextBtn.addEventListener("click", () => {
    // If in exam mode, require answer before next
    const currentAnswered = state.answers.some(a => a.id === q.id);
    if (state.mode === "exam" && !currentAnswered) return;

    state.index++;
    renderHeaderStats();
    renderQuestion();
  });

  nav.appendChild(backBtn);
  nav.appendChild(nextBtn);

  card.appendChild(nav);
  examEl.appendChild(card);

  // If already answered and practice mode, show feedback
  if (prev && state.mode === "practice") {
    showFeedback(prev.correct, q, feedback);
  }
}

function onChoose(chosenIndex) {
  const q = state.questions[state.index];
  if (!q) return;

  // prevent double answering the same question
  if (state.answers.some(a => a.id === q.id)) return;

  const correct = chosenIndex === q.answerIndex;
  state.answers.push({
    id: q.id,
    chosenIndex,
    correct,
    category: q.category,
  });

  // reveal feedback if practice
  const feedback = examEl.querySelector(".feedback");
  if (state.mode === "practice" && feedback) {
    showFeedback(correct, q, feedback);
  }

  // re-render to lock buttons + show correct/wrong classes
  renderHeaderStats();
  renderQuestion();
}

function showFeedback(correct, q, feedbackEl) {
  feedbackEl.style.display = "block";
  feedbackEl.innerHTML = `
    <div>${correct ? `<span class="ok">Correct.</span>` : `<span class="bad">Incorrect.</span>`}</div>
    <div style="margin-top:6px;">${escapeHtml(q.explanation)}</div>
  `;
}

function renderResults() {
  // Score is based on answered questions. In exam mode you should answer all.
  const total = state.total;
  const correctCount = state.answers.reduce((acc, a) => acc + (a.correct ? 1 : 0), 0);

  // Hard clamp so it can never show 17/16 nonsense.
  const safeCorrect = clampInt(correctCount, 0, total);

  // Update stats
  const attempt = {
    ts: Date.now(),
    score: safeCorrect,
    total,
    mode: state.mode,
    focus: state.focus,
  };
  state.stats.history.push(attempt);

  if (!state.stats.best || safeCorrect > state.stats.best.score || (safeCorrect === state.stats.best.score && total > state.stats.best.total)) {
    state.stats.best = { score: safeCorrect, total };
  }

  // Update per-category adaptive baseline
  for (const a of state.answers) {
    const cat = a.category;
    if (!state.stats.perCategory[cat]) {
      state.stats.perCategory[cat] = { correct: 0, total: 0 };
    }
    state.stats.perCategory[cat].total += 1;
    if (a.correct) state.stats.perCategory[cat].correct += 1;
  }

  saveStats(state.stats);
  renderChips(state.stats);
  renderHeaderStats();

  const breakdown = breakdownByCategory(state.answers);

  examEl.innerHTML = `
    <div class="qcard">
      <div class="qhead">
        <div class="qmeta">
          <div class="badge">Result</div>
          <div class="badge">Score <strong>${safeCorrect}/${total}</strong></div>
        </div>
        <div class="badge">Mode <strong>${escapeHtml(state.mode)}</strong></div>
      </div>

      <div class="qtext" style="margin-top:12px;">
        Breakdown by topic:
      </div>

      <div class="answers" style="margin-top:10px;">
        ${Object.entries(breakdown).map(([cat, v]) => {
          const label = CATEGORIES[cat] ?? cat;
          return `<div class="feedback" style="display:block;">
            <div><strong>${escapeHtml(label)}</strong>: ${v.correct}/${v.total}</div>
          </div>`;
        }).join("")}
      </div>

      <div class="divider"></div>

      <div class="nav">
        <button class="btn" id="reviewBtn">Review Answers</button>
        <button class="btn primary" id="restartBtn">Start New Exam</button>
      </div>
    </div>
  `;

  document.getElementById("restartBtn").addEventListener("click", startExam);
  document.getElementById("reviewBtn").addEventListener("click", () => {
    state.index = 0;
    renderHeaderStats();
    renderReview();
  });
}

function renderReview() {
  examEl.innerHTML = "";
  const wrap = document.createElement("div");
  wrap.className = "qcard";

  const correctCount = state.answers.reduce((acc, a) => acc + (a.correct ? 1 : 0), 0);
  const safeCorrect = clampInt(correctCount, 0, state.total);

  wrap.innerHTML = `
    <div class="qhead">
      <div class="qmeta">
        <div class="badge">Review</div>
        <div class="badge">Score <strong>${safeCorrect}/${state.total}</strong></div>
      </div>
      <div class="badge">Questions <strong>${state.total}</strong></div>
    </div>
  `;

  const list = document.createElement("div");
  list.className = "answers";
  list.style.marginTop = "12px";

  for (const q of state.questions) {
    const a = state.answers.find(x => x.id === q.id);
    const catLabel = CATEGORIES[q.category] ?? q.category;

    const block = document.createElement("div");
    block.className = "feedback";
    block.style.display = "block";
    block.innerHTML = `
      <div style="display:flex; gap:10px; flex-wrap:wrap; align-items:center;">
        <span class="badge"><strong>${escapeHtml(catLabel)}</strong></span>
        <span>${a?.correct ? `<span class="ok">Correct</span>` : `<span class="bad">Wrong</span>`}</span>
      </div>
      <div style="margin-top:8px; color: var(--text);">${escapeHtml(q.question)}</div>
      <div style="margin-top:8px;">
        <div>Correct answer: <strong>${escapeHtml(q.choices[q.answerIndex])}</strong></div>
        ${a ? `<div>Your answer: <strong>${escapeHtml(q.choices[a.chosenIndex])}</strong></div>` : `<div>Your answer: <em>Not answered</em></div>`}
      </div>
      <div style="margin-top:8px;">${escapeHtml(q.explanation)}</div>
    `;
    list.appendChild(block);
  }

  const nav = document.createElement("div");
  nav.className = "nav";
  nav.innerHTML = `
    <button class="btn" id="backToResultsBtn">Back</button>
    <button class="btn primary" id="newExamBtn">New Exam</button>
  `;

  wrap.appendChild(list);
  wrap.appendChild(nav);
  examEl.appendChild(wrap);

  document.getElementById("newExamBtn").addEventListener("click", startExam);
  document.getElementById("backToResultsBtn").addEventListener("click", renderResults);
}

/**
 * Helpers
 */
function breakdownByCategory(answers) {
  const out = {};
  for (const a of answers) {
    if (!out[a.category]) out[a.category] = { correct: 0, total: 0 };
    out[a.category].total += 1;
    if (a.correct) out[a.category].correct += 1;
  }
  // ensure all categories show up
  for (const cat of Object.keys(CATEGORIES)) {
    out[cat] ??= { correct: 0, total: 0 };
  }
  return out;
}

function weightedPick(items, weightFn) {
  const weights = items.map(it => Math.max(0.0001, Number(weightFn(it)) || 1));
  const sum = weights.reduce((a,b)=>a+b,0);
  let r = Math.random() * sum;
  for (let i=0;i<items.length;i++){
    r -= weights[i];
    if (r <= 0) return items[i];
  }
  return items[items.length - 1];
}

function shuffle(arr) {
  const a = arr.slice();
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

function clamp(n, min, max) {
  return Math.max(min, Math.min(max, n));
}
function clampInt(n, min, max) {
  return Math.max(min, Math.min(max, Math.trunc(n)));
}

function escapeHtml(str) {
  return String(str)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}

/**
 * Wire up UI
 */
function boot() {
  state.stats = loadStats();
  renderChips(state.stats);

  currentModeEl.textContent = `Mode: ${modeEl.value}`;
  bestScoreEl.textContent = state.stats.best ? `Best score: ${state.stats.best.score}/${state.stats.best.total}` : "Best score: --";
  progressEl.textContent = "Question -- of --";

  startBtn.addEventListener("click", startExam);

  resetStatsBtn.addEventListener("click", () => {
    localStorage.removeItem(LS_STATS);
    state.stats = loadStats();
    renderChips(state.stats);
    bestScoreEl.textContent = "Best score: --";
    examEl.innerHTML = `<div class="empty">Stats cleared. Click <strong>Start</strong> to generate an exam.</div>`;
  });

  // Optional: auto-start once
  // startExam();
}

boot();

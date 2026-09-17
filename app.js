/* ==========================================================================
   Wallzy — Gallery Logic
   Curated & developed by Muzammil Nawaz
   ========================================================================== */

'use strict';

// ─── State ───────────────────────────────────────────────────────────────────

const STATE = {
  data: null,
  allWallpapers: [],
  filtered: [],
  category: 'all',
  query: '',
  page: 1,
  perPage: 24,
  theme: 'light',
  lightboxIndex: -1,
  revealed: new WeakSet(),
};

// ─── DOM refs ────────────────────────────────────────────────────────────────

const $ = (sel) => document.querySelector(sel);
const $$ = (sel) => document.querySelectorAll(sel);

const DOM = {
  grid: $('#grid'),
  filters: $('#filters'),
  empty: $('#empty'),
  emptyText: $('#emptyText'),
  loading: $('#loading'),
  loadMore: $('#loadMore'),
  loadMoreBtn: $('#loadMoreBtn'),
  searchInput: $('#searchInput'),
  resultsBar: $('#resultsBar'),
  resultsText: $('#resultsText'),
  clearFilters: $('#clearFilters'),
  themeToggle: $('#themeToggle'),
  heroCount: $('#heroCount'),
  heroCategories: $('#heroCategories'),
  lightbox: $('#lightbox'),
  lbImage: $('#lbImage'),
  lbTitle: $('#lbTitle'),
  lbMeta: $('#lbMeta'),
  lbDownload: $('#lbDownload'),
  lbClose: $('#lbClose'),
  lbPrev: $('#lbPrev'),
  lbNext: $('#lbNext'),
  copyInstall: $('#copyInstall'),
  toast: $('#toast'),
  countAll: $('#countAll'),
};

// ─── Theme ───────────────────────────────────────────────────────────────────

function initTheme() {
  const saved = localStorage.getItem('wallzy-theme');
  const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
  STATE.theme = saved || (prefersDark ? 'dark' : 'light');
  applyTheme();
}

function applyTheme() {
  document.documentElement.setAttribute('data-theme', STATE.theme);
  const meta = document.querySelector('meta[name="theme-color"]');
  if (meta) meta.setAttribute('content', STATE.theme === 'dark' ? '#0a0a0b' : '#4d6bfe');
  localStorage.setItem('wallzy-theme', STATE.theme);
}

function toggleTheme() {
  STATE.theme = STATE.theme === 'dark' ? 'light' : 'dark';
  applyTheme();
}

// ─── Toast ───────────────────────────────────────────────────────────────────

let toastTimer = null;

function showToast(message) {
  DOM.toast.textContent = message;
  DOM.toast.hidden = false;
  requestAnimationFrame(() => DOM.toast.classList.add('show'));
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => {
    DOM.toast.classList.remove('show');
    setTimeout(() => { DOM.toast.hidden = true; }, 200);
  }, 2200);
}

// ─── Data loading ────────────────────────────────────────────────────────────

async function loadData() {
  try {
    const res = await fetch('wallpapers.json', { cache: 'no-cache' });
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const data = await res.json();
    STATE.data = data;
    STATE.allWallpapers = flattenWallpapers(data);
    return true;
  } catch (err) {
    console.error('Failed to load wallpapers.json:', err);
    DOM.loading.hidden = true;
    DOM.empty.hidden = false;
    DOM.emptyText.textContent = 'Could not load wallpapers.json. If you opened this file directly, please serve it via a local server (e.g., python3 -m http.server).';
    return false;
  }
}

function flattenWallpapers(data) {
  const out = [];
  if (!data || !data.categories) return out;
  for (const [catId, cat] of Object.entries(data.categories)) {
    for (const wp of cat.wallpapers || []) {
      out.push({
        ...wp,
        category: catId,
        categoryName: cat.name,
        categoryIcon: cat.icon,
      });
    }
  }
  return out;
}

// ─── Filtering ───────────────────────────────────────────────────────────────

function normalize(str) {
  return (str || '').toLowerCase().trim();
}

function applyFilters() {
  let result = STATE.allWallpapers;

  if (STATE.category !== 'all') {
    result = result.filter((w) => w.category === STATE.category);
  }

  if (STATE.query) {
    const q = normalize(STATE.query);
    result = result.filter((w) =>
      normalize(w.name).includes(q) ||
      normalize(w.categoryName).includes(q) ||
      normalize(w.category).includes(q)
    );
  }

  STATE.filtered = result;
  STATE.page = 1;
  renderGrid(true);
  updateResultsBar();
  updateUrl();
}

// ─── Rendering ───────────────────────────────────────────────────────────────

function renderFilters() {
  if (!STATE.data) return;

  const cats = STATE.data.categories || {};
  const total = STATE.data.total || 0;

  DOM.countAll.textContent = total;

  // Remove old chips (keep "All")
  DOM.filters.querySelectorAll('.filter-chip:not([data-category="all"])').forEach((el) => el.remove());

  for (const [catId, cat] of Object.entries(cats)) {
    const btn = document.createElement('button');
    btn.className = 'filter-chip';
    btn.dataset.category = catId;
    btn.innerHTML = `
      <span class="filter-icon">${cat.icon || '📁'}</span>
      <span>${escapeHtml(cat.name)}</span>
      <span class="filter-count">${cat.count}</span>
    `;
    btn.addEventListener('click', () => selectCategory(catId));
    DOM.filters.appendChild(btn);
  }

  // Hero
  if (STATE.heroCount) DOM.heroCount.textContent = formatCount(total);
  if (STATE.heroCategories) DOM.heroCategories.textContent = Object.keys(cats).length;
}

function formatCount(n) {
  if (n >= 1000) return `${(n / 1000).toFixed(n >= 10000 ? 0 : 1)}K+`;
  return n.toString();
}

function selectCategory(catId) {
  STATE.category = catId;
  DOM.filters.querySelectorAll('.filter-chip').forEach((el) => {
    el.classList.toggle('active', el.dataset.category === catId);
  });
  applyFilters();
}

function renderGrid(reset = false) {
  if (reset) DOM.grid.innerHTML = '';

  if (STATE.filtered.length === 0) {
    DOM.grid.innerHTML = '';
    DOM.empty.hidden = false;
    DOM.loadMore.hidden = true;
    return;
  }

  DOM.empty.hidden = true;

  const start = (STATE.page - 1) * STATE.perPage;
  const end = start + STATE.perPage;
  const slice = STATE.filtered.slice(start, end);

  const fragment = document.createDocumentFragment();

  slice.forEach((wp, i) => {
    const card = createCard(wp, start + i);
    fragment.appendChild(card);
  });

  DOM.grid.appendChild(fragment);

  // Lazy reveal
  requestAnimationFrame(() => {
    DOM.grid.querySelectorAll('.card:not(.revealed)').forEach((card) => {
      observer.observe(card);
    });
  });

  // Load more visibility
  DOM.loadMore.hidden = end >= STATE.filtered.length;
}

function createCard(wp, index) {
  const card = document.createElement('article');
  card.className = 'card';
  card.setAttribute('role', 'listitem');
  card.dataset.index = index;

  const thumb = wp.thumbnail || wp.file;

  card.innerHTML = `
    <div class="card-image-wrap">
      <img class="card-image" src="${escapeAttr(thumb)}" alt="${escapeAttr(wp.name)}" loading="lazy" decoding="async"
           onerror="this.onerror=null;this.src='${escapeAttr(wp.file)}';">
      <div class="card-overlay">
        <div class="card-overlay-actions">
          <button class="card-action" data-action="preview" type="button">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="14" height="14">
              <path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="3"/>
            </svg>
            Preview
          </button>
          <a class="card-action" data-action="download" href="${escapeAttr(wp.file)}" download="${escapeAttr(wp.name)}">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="14" height="14">
              <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><path d="m7 10 5 5 5-5"/><path d="M12 15V3"/>
            </svg>
            Download
          </a>
        </div>
      </div>
    </div>
    <div class="card-body">
      <div class="card-info">
        <div class="card-title">${escapeHtml(wp.name)}</div>
        <div class="card-meta">${escapeHtml(wp.dimensions || '')}</div>
      </div>
      <span class="card-category">${escapeHtml(wp.categoryName || wp.category)}</span>
    </div>
  `;

  // Click on image → lightbox
  card.querySelector('.card-image-wrap').addEventListener('click', (e) => {
    if (e.target.closest('[data-action="download"]')) return;
    e.preventDefault();
    openLightbox(index);
  });

  // Preview button
  card.querySelector('[data-action="preview"]').addEventListener('click', (e) => {
    e.stopPropagation();
    openLightbox(index);
  });

  return card;
}

function updateResultsBar() {
  const hasFilters = STATE.category !== 'all' || STATE.query;

  if (!hasFilters) {
    DOM.resultsBar.hidden = true;
    return;
  }

  DOM.resultsBar.hidden = false;
  const n = STATE.filtered.length;
  DOM.resultsText.textContent = `${n} wallpaper${n === 1 ? '' : 's'} found`;
  DOM.clearFilters.hidden = false;
}

// ─── Lightbox ────────────────────────────────────────────────────────────────

function openLightbox(index) {
  STATE.lightboxIndex = index;
  updateLightbox();
  DOM.lightbox.hidden = false;
  document.body.style.overflow = 'hidden';
}

function closeLightbox() {
  DOM.lightbox.hidden = true;
  document.body.style.overflow = '';
  STATE.lightboxIndex = -1;
}

function updateLightbox() {
  const wp = STATE.filtered[STATE.lightboxIndex];
  if (!wp) return;

  DOM.lbImage.src = wp.file;
  DOM.lbImage.alt = wp.name;
  DOM.lbTitle.textContent = wp.name;
  DOM.lbMeta.textContent = `${wp.categoryName} · ${wp.dimensions} · ${wp.sizeHuman || ''}`;
  DOM.lbDownload.href = wp.file;
  DOM.lbDownload.download = wp.name;

  // Nav visibility
  DOM.lbPrev.style.display = STATE.filtered.length > 1 ? '' : 'none';
  DOM.lbNext.style.display = STATE.filtered.length > 1 ? '' : 'none';
}

function navigateLightbox(dir) {
  if (STATE.filtered.length === 0) return;
  STATE.lightboxIndex = (STATE.lightboxIndex + dir + STATE.filtered.length) % STATE.filtered.length;
  updateLightbox();
}

// ─── URL state ───────────────────────────────────────────────────────────────

function updateUrl() {
  const params = new URLSearchParams();
  if (STATE.category !== 'all') params.set('category', STATE.category);
  if (STATE.query) params.set('search', STATE.query);
  const qs = params.toString();
  const url = qs ? `${location.pathname}?${qs}` : location.pathname;
  history.replaceState(null, '', url);
}

function readUrl() {
  const params = new URLSearchParams(location.search);
  const cat = params.get('category');
  const search = params.get('search');
  if (cat) STATE.category = cat;
  if (search) {
    STATE.query = search;
    DOM.searchInput.value = search;
  }
}

// ─── Utilities ───────────────────────────────────────────────────────────────

function escapeHtml(str) {
  return String(str ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

function escapeAttr(str) {
  return escapeHtml(str);
}

function clearAll() {
  STATE.category = 'all';
  STATE.query = '';
  DOM.searchInput.value = '';
  DOM.filters.querySelectorAll('.filter-chip').forEach((el) => {
    el.classList.toggle('active', el.dataset.category === 'all');
  });
  applyFilters();
}
window.clearAll = clearAll;

// ─── Intersection Observer for reveal ────────────────────────────────────────

const observer = new IntersectionObserver((entries) => {
  entries.forEach((entry) => {
    if (entry.isIntersecting) {
      entry.target.classList.add('revealed');
      observer.unobserve(entry.target);
    }
  });
}, { rootMargin: '100px' });

// ─── Event listeners ─────────────────────────────────────────────────────────

let searchTimer = null;

function initEvents() {
  // Theme
  DOM.themeToggle.addEventListener('click', toggleTheme);

  // Search
  DOM.searchInput.addEventListener('input', (e) => {
    clearTimeout(searchTimer);
    const val = e.target.value;
    searchTimer = setTimeout(() => {
      STATE.query = val;
      applyFilters();
    }, 150);
  });

  // Keyboard shortcut: / to focus search
  document.addEventListener('keydown', (e) => {
    if (e.key === '/' && document.activeElement !== DOM.searchInput) {
      e.preventDefault();
      DOM.searchInput.focus();
    }
    if (e.key === 'Escape') {
      if (!DOM.lightbox.hidden) {
        closeLightbox();
      } else if (document.activeElement === DOM.searchInput) {
        DOM.searchInput.blur();
      }
    }
    if (!DOM.lightbox.hidden) {
      if (e.key === 'ArrowLeft') navigateLightbox(-1);
      if (e.key === 'ArrowRight') navigateLightbox(1);
    }
  });

  // Clear filters
  DOM.clearFilters.addEventListener('click', clearAll);

  // Load more
  DOM.loadMoreBtn.addEventListener('click', () => {
    STATE.page += 1;
    renderGrid(false);
  });

  // Lightbox
  DOM.lbClose.addEventListener('click', closeLightbox);
  DOM.lbPrev.addEventListener('click', () => navigateLightbox(-1));
  DOM.lbNext.addEventListener('click', () => navigateLightbox(1));
  DOM.lightbox.addEventListener('click', (e) => {
    if (e.target === DOM.lightbox) closeLightbox();
  });

  // Copy install command
  DOM.copyInstall.addEventListener('click', async () => {
    const cmd = DOM.copyInstall.dataset.command;
    try {
      await navigator.clipboard.writeText(cmd);
      showToast('Install command copied!');
    } catch {
      showToast('Copy failed — select manually.');
    }
  });
}

// ─── Init ────────────────────────────────────────────────────────────────────

async function init() {
  initTheme();
  initEvents();
  readUrl();

  const ok = await loadData();
  if (!ok) return;

  DOM.loading.hidden = true;
  renderFilters();

  // Apply initial category from URL
  if (STATE.category !== 'all') {
    DOM.filters.querySelectorAll('.filter-chip').forEach((el) => {
      el.classList.toggle('active', el.dataset.category === STATE.category);
    });
  }

  applyFilters();
}

init();

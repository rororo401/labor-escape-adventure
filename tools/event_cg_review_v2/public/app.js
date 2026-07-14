const STATUS_LABELS = {
  pending: "미검수",
  approved: "신규 승인",
  needs_edit: "수정 필요",
  remake: "다시 만들기",
};

const PAGE_SIZE = 48;
const state = { manifest: null, items: [], filtered: [], selected: null, page: 0 };
const $ = (id) => document.getElementById(id);

async function fetchJson(path, options) {
  const response = await fetch(path, options);
  if (!response.ok) throw new Error(`${path} ${response.status}`);
  return response.json();
}

async function load() {
  try {
    state.manifest = await fetchJson("/api/manifest");
    const versionLabel = `V${state.manifest.version}`;
    $("appVersion").textContent = versionLabel;
    document.title = `이벤트 CG 재생산 검수 ${versionLabel}`;
    state.items = state.manifest.items;
    buildFilters();
    applyFilters(true);
  } catch (error) {
    $("summary").textContent = `불러오기 실패: ${error.message}`;
  }
}

function buildFilters() {
  fillFilter("scopeFilter", "전체 대상", state.manifest.scopes);
  fillFilter("groupFilter", "전체 그룹", state.manifest.groups);
  fillFilter("variantFilter", "전체 계절", state.manifest.variants);
}

function fillFilter(id, allLabel, values) {
  const select = $(id);
  select.innerHTML = `<option value="all">${escapeHtml(allLabel)}</option>`;
  for (const value of values) {
    select.insertAdjacentHTML("beforeend", `<option value="${escapeAttr(value.id)}">${escapeHtml(value.label)} (${value.count})</option>`);
  }
}

function reviewOf(item) { return item.review || { status: "pending", note: "" }; }
function statusOf(item) { return reviewOf(item).status || "pending"; }

function applyFilters(resetPage = false) {
  const query = $("searchInput").value.trim().toLowerCase();
  const scope = $("scopeFilter").value;
  const group = $("groupFilter").value;
  const variant = $("variantFilter").value;
  const status = $("statusFilter").value;
  const sort = $("sortSelect").value;

  state.filtered = state.items.filter((item) => {
    if (scope !== "all" && item.scope_id !== scope) return false;
    if (group !== "all" && item.group_id !== group) return false;
    if (variant !== "all" && item.variant_id !== variant) return false;
    if (status !== "all" && statusOf(item) !== status) return false;
    if (query && !haystack(item).includes(query)) return false;
    return true;
  });

  state.filtered.sort((a, b) => {
    if (sort === "path") return a.workspace_path.localeCompare(b.workspace_path);
    if (sort === "status") {
      const order = ["pending", "needs_edit", "remake", "approved"];
      const diff = order.indexOf(statusOf(a)) - order.indexOf(statusOf(b));
      if (diff) return diff;
    }
    return `${a.scope_label}/${a.group_label}/${a.variant_label}/${a.workspace_path}`.localeCompare(`${b.scope_label}/${b.group_label}/${b.variant_label}/${b.workspace_path}`, "ko");
  });

  if (resetPage) state.page = 0;
  const pages = pageCount();
  state.page = Math.max(0, Math.min(state.page, Math.max(0, pages - 1)));
  renderSummary();
  renderGrid();
  renderPagination();
}

function haystack(item) {
  return [item.title, item.summary, item.workspace_path, item.group_label, item.variant_label, item.scope_label, ...(item.dialogue || []), ...(item.event_ids || [])].join(" ").toLowerCase();
}

function renderSummary() {
  const counts = { pending: 0, approved: 0, needs_edit: 0, remake: 0 };
  for (const item of state.items) counts[statusOf(item)] += 1;
  $("countTotal").textContent = state.items.length.toLocaleString();
  $("countPending").textContent = counts.pending.toLocaleString();
  $("countApproved").textContent = counts.approved.toLocaleString();
  $("countEdit").textContent = counts.needs_edit.toLocaleString();
  $("countRemake").textContent = counts.remake.toLocaleString();
  $("countVisible").textContent = state.filtered.length.toLocaleString();
  const missing = state.manifest.missing_candidate + state.manifest.missing_original;
  const scopes = state.manifest.scopes.map((scope) => `${scope.label} ${scope.count.toLocaleString()}장`).join(" + ");
  $("summary").textContent = `${scopes} · 비교 대상 ${state.items.length.toLocaleString()}장 · 누락 ${missing}장`;
}

function renderGrid() {
  const grid = $("grid");
  const start = state.page * PAGE_SIZE;
  const items = state.filtered.slice(start, start + PAGE_SIZE);
  const fragment = document.createDocumentFragment();
  for (const item of items) fragment.appendChild(card(item));
  grid.replaceChildren(fragment);
  $("emptyMessage").hidden = state.filtered.length !== 0;
}

function card(item) {
  const article = document.createElement("article");
  const status = statusOf(item);
  article.className = "card";
  article.innerHTML = `
    <div class="thumb-wrap" tabindex="0" role="button" aria-label="${escapeAttr(item.title)} 비교 검수 열기">
      <img loading="lazy" src="${escapeAttr(item.candidate_url)}" alt="${escapeAttr(item.title)} 신규 이미지">
      <div class="badge-row">
        <span class="pill">${escapeHtml(item.group_label)}</span>
        <span class="pill">${escapeHtml(item.variant_label)}</span>
        <span class="pill status-${status}">${escapeHtml(STATUS_LABELS[status])}</span>
      </div>
      <div class="decision-overlay">신규 후보</div>
    </div>
    <div class="card-body">
      <h2>${escapeHtml(item.title)}</h2>
      <p class="path">${escapeHtml(item.workspace_path)}</p>
      <div class="mini-actions">
        <button type="button" data-status="approved">승인</button>
        <button type="button" data-status="needs_edit">수정</button>
        <button type="button" data-status="remake">재생성</button>
      </div>
    </div>`;
  const opener = article.querySelector(".thumb-wrap");
  opener.addEventListener("click", () => openDetail(item));
  opener.addEventListener("keydown", (event) => {
    if (event.key === "Enter" || event.key === " ") openDetail(item);
  });
  for (const button of article.querySelectorAll(".mini-actions button")) {
    button.addEventListener("click", () => saveReview(item, button.dataset.status, reviewOf(item).note || "", false));
  }
  return article;
}

function pageCount() { return Math.ceil(state.filtered.length / PAGE_SIZE); }
function renderPagination() {
  const pages = pageCount();
  $("pageLabel").textContent = `${pages ? state.page + 1 : 0} / ${pages}`;
  $("previousPage").disabled = state.page <= 0;
  $("nextPage").disabled = pages === 0 || state.page >= pages - 1;
}

function changePage(delta) {
  state.page = Math.max(0, Math.min(state.page + delta, pageCount() - 1));
  renderGrid();
  renderPagination();
  window.scrollTo({ top: 0, behavior: "smooth" });
}

function openDetail(item) {
  state.selected = item;
  renderDetail();
  if (!$("detailDialog").open) $("detailDialog").showModal();
}

function renderDetail() {
  const item = state.selected;
  if (!item) return;
  const index = state.filtered.findIndex((row) => row.id === item.id);
  $("detailScope").textContent = item.scope_label;
  $("detailTitle").textContent = item.title;
  $("detailPosition").textContent = `${index + 1} / ${state.filtered.length}`;
  $("originalImage").src = item.original_url;
  $("candidateImage").src = item.candidate_url;
  $("originalCaption").textContent = state.manifest.baseline_label || "현재 게임 이미지";
  $("candidateCaption").textContent = state.manifest.candidate_label || "신규 재생산 이미지";
  $("originalImage").alt = `${item.title} ${state.manifest.baseline_label || "현재 게임 이미지"}`;
  $("candidateImage").alt = `${item.title} ${state.manifest.candidate_label || "신규 재생산 이미지"}`;
  $("detailBadges").innerHTML = [item.group_label, item.variant_label, STATUS_LABELS[statusOf(item)], `레인 ${item.lane}`].map((text) => `<span class="pill">${escapeHtml(text)}</span>`).join("");
  $("detailSummary").textContent = item.summary || item.dialogue?.[0] || "";
  $("detailPlan").textContent = [item.location && `장소: ${item.location}`, item.composition && `구도: ${item.composition}`].filter(Boolean).join(" · ");
  $("detailPath").textContent = item.workspace_path;
  $("detailPrevious").textContent = item.previous_status === "ignored" ? item.previous_note : `기존 판정: ${item.previous_status}${item.previous_note ? ` · ${item.previous_note}` : ""}`;
  $("noteInput").value = reviewOf(item).note || "";
}

async function saveReview(item, status, note, advance) {
  const oldFiltered = [...state.filtered];
  const oldIndex = oldFiltered.findIndex((row) => row.id === item.id);
  const nextItem = oldFiltered[Math.min(oldIndex + 1, oldFiltered.length - 1)];
  const payload = await fetchJson("/api/state", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ id: item.id, status, note }),
  });
  item.review = payload.item;
  toast(`${item.title}: ${STATUS_LABELS[status]}`);
  applyFilters(false);
  if (advance && nextItem && nextItem.id !== item.id) {
    state.selected = state.items.find((row) => row.id === nextItem.id) || nextItem;
    renderDetail();
  } else if (state.selected?.id === item.id) {
    renderDetail();
  }
}

function moveDetail(delta) {
  if (!state.selected || !state.filtered.length) return;
  const index = state.filtered.findIndex((row) => row.id === state.selected.id);
  const next = Math.max(0, Math.min(index + delta, state.filtered.length - 1));
  state.selected = state.filtered[next];
  renderDetail();
}

let toastTimer;
function toast(message) {
  clearTimeout(toastTimer);
  $("toast").textContent = message;
  $("toast").classList.add("show");
  toastTimer = setTimeout(() => $("toast").classList.remove("show"), 1400);
}

function escapeHtml(value) {
  return String(value ?? "").replace(/[&<>'"]/g, (char) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", "'": "&#39;", '"': "&quot;" }[char]));
}
function escapeAttr(value) { return escapeHtml(value); }

for (const id of ["scopeFilter", "groupFilter", "variantFilter", "statusFilter", "sortSelect"]) {
  $(id).addEventListener("change", () => applyFilters(true));
}
$("searchInput").addEventListener("input", () => applyFilters(true));
$("previousPage").addEventListener("click", () => changePage(-1));
$("nextPage").addEventListener("click", () => changePage(1));
$("closeDialog").addEventListener("click", () => $("detailDialog").close());
$("previousItem").addEventListener("click", () => moveDetail(-1));
$("nextItem").addEventListener("click", () => moveDetail(1));
for (const button of document.querySelectorAll(".decision-buttons button")) {
  button.addEventListener("click", () => {
    if (state.selected) saveReview(state.selected, button.dataset.status, $("noteInput").value, true);
  });
}
document.addEventListener("keydown", (event) => {
  if (!$("detailDialog").open || event.target === $("noteInput")) return;
  if (event.key === "ArrowLeft") moveDetail(-1);
  if (event.key === "ArrowRight") moveDetail(1);
  if (["1", "2", "3"].includes(event.key) && state.selected) {
    const status = { "1": "approved", "2": "needs_edit", "3": "remake" }[event.key];
    saveReview(state.selected, status, $("noteInput").value, true);
  }
});

load();

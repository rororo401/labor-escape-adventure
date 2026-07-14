const STATUS_LABELS = { pending: "미검수", approved: "승인", needs_edit: "수정 필요", remake: "다시 만들기" };
const PAGE_SIZE = 48;
const state = { manifest: null, review: { items: {} }, filtered: [], selectedId: "", page: 0 };
const $ = (id) => document.getElementById(id);

async function fetchJson(path, options) {
  const response = await fetch(path, options);
  if (!response.ok) throw new Error(`${path} ${response.status}`);
  return response.json();
}

function itemReview(item) { return state.review.items[item.id] || { status: "pending", note: "" }; }
function statusOf(item) { return itemReview(item).status || "pending"; }
function noteOf(item) { return itemReview(item).note || ""; }
function titleOf(item) { return item.event.name_ko || item.event.id || item.old_path.split("/").pop(); }
function escapeHtml(value) { return String(value).replace(/[&<>'"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", "'": "&#39;", '"': "&quot;" }[c])); }

async function load() {
  [state.manifest, state.review] = await Promise.all([fetchJson("/api/manifest"), fetchJson("/api/state")]);
  buildFilters();
  applyFilters();
}

function populateSelect(id, rows, allText) {
  const select = $(id);
  select.innerHTML = `<option value="all">${escapeHtml(allText)}</option>`;
  for (const row of rows) select.insertAdjacentHTML("beforeend", `<option value="${escapeHtml(row.id)}">${escapeHtml(row.label)} (${row.count})</option>`);
}

function buildFilters() {
  populateSelect("workstreamFilter", state.manifest.workstreams, "전체 작업군");
  populateSelect("groupFilter", state.manifest.groups, "전체 그룹");
  populateSelect("variantFilter", state.manifest.variants, "전체 계절");
}

function haystack(item) {
  return [titleOf(item), item.event.id, item.event.summary_ko, item.old_path, item.new_path, item.group_label, item.variant_label, noteOf(item)].join(" ").toLowerCase();
}

function applyFilters(resetPage = true) {
  const query = $("searchInput").value.trim().toLowerCase();
  const workstream = $("workstreamFilter").value;
  const group = $("groupFilter").value;
  const variant = $("variantFilter").value;
  const status = $("statusFilter").value;
  const sort = $("sortSelect").value;
  state.filtered = state.manifest.items.filter((item) => {
    if (workstream !== "all" && item.workstream_id !== workstream) return false;
    if (group !== "all" && item.group_id !== group) return false;
    if (variant !== "all" && item.variant_id !== variant) return false;
    if (status !== "all" && statusOf(item) !== status) return false;
    return !query || haystack(item).includes(query);
  });
  state.filtered.sort((a, b) => {
    if (sort === "status") {
      const order = ["pending", "needs_edit", "remake", "approved"];
      const diff = order.indexOf(statusOf(a)) - order.indexOf(statusOf(b));
      if (diff) return diff;
    }
    if (sort === "path") return a.old_path.localeCompare(b.old_path);
    return `${a.group_label}/${a.variant_label}/${a.old_path}`.localeCompare(`${b.group_label}/${b.variant_label}/${b.old_path}`, "ko");
  });
  if (resetPage) state.page = 0;
  const maxPage = Math.max(0, Math.ceil(state.filtered.length / PAGE_SIZE) - 1);
  state.page = Math.min(state.page, maxPage);
  render();
}

function render() {
  renderStats();
  const start = state.page * PAGE_SIZE;
  const pageItems = state.filtered.slice(start, start + PAGE_SIZE);
  $("grid").replaceChildren(...pageItems.map(cardElement));
  const pages = Math.ceil(state.filtered.length / PAGE_SIZE);
  $("pageInfo").textContent = `${pages ? state.page + 1 : 0} / ${pages}`;
  $("previousPage").disabled = state.page <= 0;
  $("nextPage").disabled = state.page >= pages - 1;
  $("visibleInfo").textContent = `${state.filtered.length.toLocaleString()}장 중 ${pageItems.length}장 표시`;
}

function renderStats() {
  const counts = { pending: 0, approved: 0, needs_edit: 0, remake: 0 };
  for (const item of state.manifest.items) counts[statusOf(item)] += 1;
  $("countTotal").textContent = state.manifest.total.toLocaleString();
  $("countPending").textContent = counts.pending.toLocaleString();
  $("countApproved").textContent = counts.approved.toLocaleString();
  $("countEdit").textContent = counts.needs_edit.toLocaleString();
  $("countRemake").textContent = counts.remake.toLocaleString();
  $("summary").textContent = `신규 924장 · 회사 기본업무 400장 · 기존 재생성 판정 524장 · 기존/신규 비교 검수`;
}

function cardElement(item) {
  const card = document.createElement("article");
  card.className = `card status-${statusOf(item)}`;
  card.innerHTML = `<button class="card-open" type="button">
    <div class="mini-compare"><span><i>기존</i><img loading="lazy" src="${escapeHtml(item.old_image_url)}" alt=""></span><span><i>신규</i><img loading="lazy" src="${escapeHtml(item.new_image_url)}" alt=""></span></div>
    <div class="card-body"><div class="badges"><em>${escapeHtml(item.group_label)}</em><em>${escapeHtml(item.variant_label)}</em><em class="decision">${escapeHtml(STATUS_LABELS[statusOf(item)])}</em></div><h2>${escapeHtml(titleOf(item))}</h2><p>${escapeHtml(item.old_path)}</p></div>
  </button>`;
  card.querySelector("button").addEventListener("click", () => openDetail(item.id));
  return card;
}

function selectedItem() { return state.manifest.items.find((item) => item.id === state.selectedId); }
function filteredIndex() { return state.filtered.findIndex((item) => item.id === state.selectedId); }

function openDetail(id) {
  state.selectedId = id;
  renderDetail();
  if (!$("detailDialog").open) $("detailDialog").showModal();
}

function renderDetail() {
  const item = selectedItem();
  if (!item) return;
  $("detailTitle").textContent = titleOf(item);
  $("detailSummary").textContent = item.event.summary_ko || item.event.dialogue.join(" ");
  $("detailBadges").innerHTML = `<em>${escapeHtml(item.workstream_label)}</em><em>${escapeHtml(item.group_label)}</em><em>${escapeHtml(item.variant_label)}</em><em>${escapeHtml(STATUS_LABELS[statusOf(item)])}</em>`;
  $("oldImage").src = item.old_image_url;
  $("newImage").src = item.new_image_url;
  $("oldImage").alt = `${titleOf(item)} 기존 이미지`;
  $("newImage").alt = `${titleOf(item)} 신규 이미지`;
  $("oldPath").textContent = item.old_path;
  $("newPath").textContent = item.new_path;
  $("scenePlan").textContent = [item.scene_location, item.scene_composition, `생성 레인 ${item.lane}`].filter(Boolean).join(" · ");
  $("previousDecision").textContent = item.previous_status === "ignored" ? item.previous_note : `${item.previous_status}${item.previous_note ? ` · ${item.previous_note}` : ""}`;
  $("noteInput").value = noteOf(item);
  const index = filteredIndex();
  $("detailPosition").textContent = `${index >= 0 ? index + 1 : "-"} / ${state.filtered.length}`;
  $("previousItem").disabled = index <= 0;
  $("nextItem").disabled = index < 0 || index >= state.filtered.length - 1;
}

async function saveDecision(status, advance = true) {
  const item = selectedItem();
  if (!item) return;
  const oldList = [...state.filtered];
  const oldIndex = oldList.findIndex((row) => row.id === item.id);
  const preferredNext = oldList[oldIndex + 1]?.id || oldList[oldIndex - 1]?.id || "";
  const result = await fetchJson("/api/state", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ id: item.id, status, note: $("noteInput").value.trim() }),
  });
  state.review.items[item.id] = result.item;
  applyFilters(false);
  if (!advance) return renderDetail();
  const nextId = state.filtered.some((row) => row.id === preferredNext) ? preferredNext : state.filtered[Math.min(Math.max(oldIndex, 0), state.filtered.length - 1)]?.id;
  if (nextId) openDetail(nextId); else $("detailDialog").close();
}

function moveDetail(delta) {
  const index = filteredIndex();
  const next = state.filtered[index + delta];
  if (next) openDetail(next.id);
}

for (const id of ["workstreamFilter", "groupFilter", "variantFilter", "statusFilter", "sortSelect"]) $(id).addEventListener("change", () => applyFilters());
$("searchInput").addEventListener("input", () => applyFilters());
$("previousPage").addEventListener("click", () => { state.page -= 1; render(); window.scrollTo({ top: 0, behavior: "smooth" }); });
$("nextPage").addEventListener("click", () => { state.page += 1; render(); window.scrollTo({ top: 0, behavior: "smooth" }); });
$("closeDetail").addEventListener("click", () => $("detailDialog").close());
$("previousItem").addEventListener("click", () => moveDetail(-1));
$("nextItem").addEventListener("click", () => moveDetail(1));
for (const button of document.querySelectorAll(".decision-buttons button")) button.addEventListener("click", () => saveDecision(button.dataset.status));
document.addEventListener("keydown", (event) => {
  if (!$("detailDialog").open || event.target === $("noteInput")) return;
  if (event.key === "ArrowLeft") moveDetail(-1);
  if (event.key === "ArrowRight") moveDetail(1);
  if (event.key === "1") saveDecision("approved");
  if (event.key === "2") saveDecision("needs_edit");
  if (event.key === "3") saveDecision("remake");
  if (event.key === "0") saveDecision("pending");
});

load().catch((error) => { $("summary").textContent = `불러오기 실패: ${error.message}`; console.error(error); });

const STATUS_LABELS = {
  pending: "미검수",
  approved: "검수 완료",
  needs_edit: "수정 필요",
  remake: "다시 만들기",
};

const state = {
  manifest: null,
  review: { items: {} },
  filtered: [],
  selected: null,
};

const $ = (id) => document.getElementById(id);

async function fetchJson(path, options) {
  const response = await fetch(path, options);
  if (!response.ok) throw new Error(`${path} ${response.status}`);
  return response.json();
}

async function load() {
  const [manifest, review] = await Promise.all([
    fetchJson("/api/manifest"),
    fetchJson("/api/state"),
  ]);
  state.manifest = manifest;
  state.review = review;
  buildFilters();
  applyFilters();
}

function itemState(item) {
  return state.review.items[item.id] || { status: "pending", note: "" };
}

function statusOf(item) {
  return itemState(item).status || "pending";
}

function noteOf(item) {
  return itemState(item).note || "";
}

function titleOf(item) {
  const event = item.events[0] || {};
  return event.name_ko || event.id || item.workspace_path.split("/").pop();
}

function haystackOf(item) {
  const events = item.events.map((event) => [
    event.id,
    event.name_ko,
    event.summary_ko,
    event.category_ko,
    event.mode,
    event.source,
  ].join(" ")).join(" ");
  return [
    item.workspace_path,
    item.group_label,
    item.variant_label,
    statusOf(item),
    noteOf(item),
    events,
  ].join(" ").toLowerCase();
}

function buildFilters() {
  const groupFilter = $("groupFilter");
  groupFilter.innerHTML = `<option value="all">전체 그룹</option>`;
  for (const group of state.manifest.groups) {
    groupFilter.insertAdjacentHTML("beforeend", `<option value="${escapeHtml(group.id)}">${escapeHtml(group.label)} (${group.count})</option>`);
  }

  const variantFilter = $("variantFilter");
  variantFilter.innerHTML = `<option value="all">전체 버전</option>`;
  for (const variant of state.manifest.variants) {
    variantFilter.insertAdjacentHTML("beforeend", `<option value="${escapeHtml(variant.id)}">${escapeHtml(variant.label)} (${variant.count})</option>`);
  }
}

function applyFilters() {
  const query = $("searchInput").value.trim().toLowerCase();
  const group = $("groupFilter").value;
  const variant = $("variantFilter").value;
  const status = $("statusFilter").value;
  const sort = $("sortSelect").value;

  let items = state.manifest.items.filter((item) => {
    if (group !== "all" && item.group_id !== group) return false;
    if (variant !== "all" && item.variant_id !== variant) return false;
    if (status !== "all" && statusOf(item) !== status) return false;
    if (query && !haystackOf(item).includes(query)) return false;
    return true;
  });

  items = items.sort((a, b) => {
    if (sort === "status") {
      const statusOrder = ["pending", "needs_edit", "remake", "approved"];
      const diff = statusOrder.indexOf(statusOf(a)) - statusOrder.indexOf(statusOf(b));
      if (diff !== 0) return diff;
    }
    if (sort === "path") return a.workspace_path.localeCompare(b.workspace_path);
    return `${a.group_label}/${a.variant_label}/${a.workspace_path}`.localeCompare(`${b.group_label}/${b.variant_label}/${b.workspace_path}`, "ko");
  });

  state.filtered = items;
  renderSummary();
  renderGrid();
}

function renderSummary() {
  const total = state.manifest.total;
  const counts = { pending: 0, approved: 0, needs_edit: 0, remake: 0 };
  for (const item of state.manifest.items) counts[statusOf(item)] += 1;

  $("summary").textContent = `실제 이미지 ${total}장 · 기본/겨울 ${variantCount("base")}장 · 여름 ${variantCount("summer")}장 · 특수 ${variantCount("special")}장`;
  $("countTotal").textContent = String(total);
  $("countVisible").textContent = String(state.filtered.length);
  $("countApproved").textContent = String(counts.approved);
  $("countEdit").textContent = String(counts.needs_edit);
  $("countRemake").textContent = String(counts.remake);
}

function variantCount(id) {
  return (state.manifest.variants.find((variant) => variant.id === id) || { count: 0 }).count;
}

function renderGrid() {
  const grid = $("grid");
  const fragment = document.createDocumentFragment();
  for (const item of state.filtered) fragment.appendChild(cardElement(item));
  grid.replaceChildren(fragment);
}

function cardElement(item) {
  const card = document.createElement("article");
  const status = statusOf(item);
  const note = noteOf(item);
  card.className = "card";
  card.dataset.status = status;
  card.innerHTML = `
    <div class="thumb-wrap">
      <img loading="lazy" src="${escapeAttr(item.image_url)}" alt="${escapeAttr(titleOf(item))}">
      <div class="decision-overlay"><span>${escapeHtml(STATUS_LABELS[status])}</span></div>
      <div class="badge-row">
        <span class="pill">${escapeHtml(item.group_label)}</span>
        <span class="pill">${escapeHtml(item.variant_label)}</span>
        <span class="pill status-${status}">${escapeHtml(STATUS_LABELS[status])}</span>
      </div>
    </div>
    <div class="card-body">
      <h2 class="card-title">${escapeHtml(titleOf(item))}</h2>
      <p class="path">${escapeHtml(item.workspace_path)}</p>
      ${note ? `<p class="note-preview">${escapeHtml(note)}</p>` : ""}
      <div class="mini-actions">
        <button type="button" data-status="approved">완료</button>
        <button type="button" data-status="needs_edit">수정</button>
        <button type="button" data-status="remake">재생성</button>
      </div>
    </div>
  `;
  card.querySelector(".thumb-wrap").addEventListener("click", () => openDetail(item));
  for (const button of card.querySelectorAll(".mini-actions button")) {
    button.addEventListener("click", async (event) => {
      event.stopPropagation();
      await saveState(item.id, button.dataset.status, noteOf(item));
    });
  }
  return card;
}

function openDetail(item) {
  state.selected = item;
  renderDetail(item);
  if (!$("detailDialog").open) $("detailDialog").showModal();
}

function renderDetail(item) {
  const status = statusOf(item);
  const index = currentFilteredIndex();
  $("detailImage").src = item.image_url;
  $("detailImage").alt = titleOf(item);
  $("detailGroup").textContent = item.group_label;
  $("detailVariant").textContent = item.variant_label;
  $("detailStatus").textContent = STATUS_LABELS[status];
  $("detailStatus").className = `pill status-${status}`;
  $("detailTitle").textContent = titleOf(item);
  $("detailPath").textContent = item.workspace_path;
  $("detailNote").value = noteOf(item);
  $("detailProgress").textContent = index >= 0 ? `${index + 1} / ${state.filtered.length}` : "-";
  $("prevButton").disabled = index <= 0;
  $("nextButton").disabled = index < 0 || index >= state.filtered.length - 1;
  renderDetailEvents(item);
}

function renderDetailEvents(item) {
  const list = $("detailEvents");
  if (item.events.length === 0) {
    list.innerHTML = `<div class="event-row"><strong>연결 이벤트 없음</strong><span>이미지는 존재하지만 현재 JSON 이벤트와 직접 연결되지 않은 항목이야.</span></div>`;
    return;
  }
  list.innerHTML = item.events.map((event) => `
    <div class="event-row">
      <strong>${escapeHtml(event.name_ko || event.id)}</strong>
      <span>${escapeHtml(event.id)} · ${escapeHtml(event.mode || "-")} · ${escapeHtml(event.source || "-")}</span>
      ${event.summary_ko ? `<span>${escapeHtml(event.summary_ko)}</span>` : ""}
    </div>
  `).join("");
}

function currentFilteredIndex() {
  if (!state.selected) return -1;
  return state.filtered.findIndex((item) => item.id === state.selected.id);
}

function adjacentItem(offset) {
  const index = currentFilteredIndex();
  if (index < 0) return null;
  const nextIndex = index + offset;
  if (nextIndex < 0 || nextIndex >= state.filtered.length) return null;
  return state.filtered[nextIndex];
}

function moveDetail(offset) {
  const item = adjacentItem(offset);
  if (item) openDetail(item);
}

async function saveState(id, status, note, options = {}) {
  const nextItem = options.advance ? adjacentItem(1) : null;
  const payload = await fetchJson("/api/state", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ id, status, note }),
  });
  state.review.items[id] = payload.item;
  applyFilters();
  if (state.selected && state.selected.id === id && $("detailDialog").open) {
    if (options.advance && nextItem && state.filtered.some((item) => item.id === nextItem.id)) {
      openDetail(nextItem);
    } else {
      renderDetail(state.selected);
    }
  }
}

function escapeHtml(value) {
  return String(value ?? "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#39;");
}

function escapeAttr(value) {
  return escapeHtml(value);
}

for (const id of ["searchInput", "groupFilter", "variantFilter", "statusFilter", "sortSelect"]) {
  $(id).addEventListener("input", applyFilters);
}

$("reloadButton").addEventListener("click", load);
$("exportButton").addEventListener("click", () => {
  alert("검수 결과는 tools/event_cg_review/review_state.json 에 저장돼.");
});

for (const button of document.querySelectorAll(".review-actions button")) {
  button.addEventListener("click", async () => {
    if (!state.selected) return;
    await saveState(state.selected.id, button.dataset.status, $("detailNote").value, {
      advance: button.dataset.advance === "true",
    });
  });
}

$("prevButton").addEventListener("click", () => moveDetail(-1));
$("nextButton").addEventListener("click", () => moveDetail(1));

document.addEventListener("keydown", async (event) => {
  if (!$("detailDialog").open || !state.selected) return;
  const target = event.target;
  if (
    target instanceof HTMLElement &&
    (target.matches("input, textarea, select") || target.isContentEditable)
  ) {
    return;
  }
  if (event.key === "ArrowLeft") {
    event.preventDefault();
    moveDetail(-1);
  } else if (event.key === "ArrowRight") {
    event.preventDefault();
    moveDetail(1);
  } else if (event.key === "1") {
    event.preventDefault();
    await saveState(state.selected.id, "approved", $("detailNote").value, { advance: true });
  } else if (event.key === "2") {
    event.preventDefault();
    await saveState(state.selected.id, "needs_edit", $("detailNote").value, { advance: true });
  } else if (event.key === "3") {
    event.preventDefault();
    await saveState(state.selected.id, "remake", $("detailNote").value, { advance: true });
  }
});

$("detailNote").addEventListener("change", async () => {
  if (!state.selected) return;
  await saveState(state.selected.id, statusOf(state.selected), $("detailNote").value);
});

load().catch((error) => {
  console.error(error);
  $("summary").textContent = `불러오기 실패: ${error.message}`;
});

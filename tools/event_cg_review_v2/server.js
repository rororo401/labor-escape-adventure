#!/usr/bin/env node

const fs = require("fs");
const path = require("path");
const http = require("http");
const url = require("url");

const ROOT = path.resolve(__dirname, "../..");
const PUBLIC_DIR = path.join(__dirname, "public");
const REVIEW_VERSION = String(process.env.REVIEW_VERSION || "2");
if (!["2", "3", "4"].includes(REVIEW_VERSION)) {
  throw new Error(`Unsupported REVIEW_VERSION: ${REVIEW_VERSION}`);
}
const STATE_PATH = path.join(__dirname, `review_state_v${REVIEW_VERSION}.json`);
const REGEN_ROOT = path.join(ROOT, `tmp/event_cg_regen_v${REVIEW_VERSION}`);
const COMPANY_MANIFEST_PATH = path.join(
  REGEN_ROOT,
  REVIEW_VERSION === "4" ? "manifests/company_review_remake.json" : "manifests/company_work.json",
);
const NONCOMPANY_MANIFEST_PATH = path.join(
  REGEN_ROOT,
  REVIEW_VERSION === "4"
    ? "manifests/noncompany_review_remake.json"
    : REVIEW_VERSION === "3"
      ? "manifests/noncompany_daily.json"
      : "manifests/noncompany_remake.json",
);
const HOST = String(process.env.HOST || "127.0.0.1");
const DEFAULT_PORTS = { "2": 4178, "3": 4179, "4": 4180 };
const PORT = Number(process.env.PORT || DEFAULT_PORTS[REVIEW_VERSION]);

function readJson(filePath, fallback = {}) {
  if (!fs.existsSync(filePath)) return fallback;
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function writeJsonAtomic(filePath, payload) {
  const tempPath = `${filePath}.tmp`;
  fs.writeFileSync(tempPath, JSON.stringify(payload, null, 2), "utf8");
  fs.renameSync(tempPath, filePath);
}

function reviewState() {
  return readJson(STATE_PATH, { version: Number(REVIEW_VERSION), updated_at: "", items: {} });
}

function fileInfo(relativePath) {
  const fullPath = path.resolve(ROOT, relativePath);
  const safe = fullPath === ROOT || fullPath.startsWith(`${ROOT}${path.sep}`);
  if (!safe || !fs.existsSync(fullPath)) return { exists: false, size: 0 };
  const stat = fs.statSync(fullPath);
  return { exists: stat.isFile(), size: stat.isFile() ? stat.size : 0 };
}

function firstEvent(item) {
  return Array.isArray(item.events) && item.events.length > 0 ? item.events[0] : {};
}

function v4CompanyBaseline(target) {
  return target.v3_target_path || target.runtime_path;
}

function v4NoncompanyBaseline(item) {
  return item.v3_target_path || `tmp/event_cg_regen_v3/noncompany/${item.workspace_path}`;
}

function companyItems() {
  const payload = readJson(COMPANY_MANIFEST_PATH, {});
  return (payload.targets || []).map((target) => {
    const baselinePath = REVIEW_VERSION === "4" ? v4CompanyBaseline(target) : target.runtime_path;
    return {
    id: target.runtime_path,
    scope_id: "company_full",
    scope_label: REVIEW_VERSION === "4"
      ? "회사 기본업무 V4 재생성"
      : REVIEW_VERSION === "3"
        ? "회사 기본업무 연령감 교정"
        : "회사 기본업무 전체 재생산",
    workspace_path: target.runtime_path,
    baseline_path: baselinePath,
    candidate_path: target.target_path,
    original_url: `/original/${encodeURI(baselinePath)}`,
    candidate_url: `/candidate/${encodeURI(target.target_path)}`,
    group_id: "company_work",
    group_label: "회사 기본업무",
    variant_id: target.season === "summer" ? "summer" : "base",
    variant_label: target.season === "summer" ? "여름" : "기본/겨울",
    lane: Number(target.lane || 0),
    title: target.name_ko || target.event_id || path.basename(target.runtime_path),
    summary: target.summary_ko || "",
    dialogue: Array.isArray(target.dialogue) ? target.dialogue : [],
    event_ids: [target.event_id].filter(Boolean),
    location: target.location || "",
    composition: target.composition || "",
    previous_status: REVIEW_VERSION === "4" ? target.snapshot_status || "remake" : "ignored",
    previous_note: REVIEW_VERSION === "4"
      ? "V3 검수에서 재생성 대상으로 판정"
      : REVIEW_VERSION === "3"
        ? "V3 연령감 교정 재생산"
        : "회사 기본업무는 이전 판정을 무시하고 전체 재생산",
    };
  });
}

function noncompanyItems() {
  const payload = readJson(NONCOMPANY_MANIFEST_PATH, {});
  return (payload.items || []).map((item) => {
    const event = firstEvent(item);
    const baselinePath = REVIEW_VERSION === "4" ? v4NoncompanyBaseline(item) : item.workspace_path;
    const candidatePath = item.v4_output_path || item.v3_output_path || item.staging_path;
    return {
      id: item.workspace_path,
      scope_id: REVIEW_VERSION === "4" ? "daily_v4_remake" : REVIEW_VERSION === "3" ? "daily_age_fix" : "previous_remake",
      scope_label: REVIEW_VERSION === "4"
        ? "회사 외 일상 V4 재생성"
        : REVIEW_VERSION === "3"
          ? "회사 외 일상 연령감 교정"
          : "기존 재생성 판정",
      workspace_path: item.workspace_path,
      baseline_path: baselinePath,
      candidate_path: candidatePath,
      original_url: `/original/${encodeURI(baselinePath)}`,
      candidate_url: `/candidate/${encodeURI(candidatePath)}`,
      group_id: item.group_id || "other",
      group_label: item.group_label || "기타",
      variant_id: item.variant_id || "base",
      variant_label: item.variant_label || "기본/겨울",
      lane: Number(item.lane || 0),
      title: event.name_ko || event.id || path.basename(item.workspace_path),
      summary: event.summary_ko || "",
      dialogue: Array.isArray(event.dialogue) ? event.dialogue : [],
      event_ids: (item.events || []).map((row) => row.id).filter(Boolean),
      location: item.scene_plan?.location_slot || "",
      composition: item.scene_plan?.camera_slot || "",
      previous_status: item.status_at_frozen_snapshot || item.status_at_snapshot || "remake",
      previous_note: item.review_note_at_frozen_snapshot || item.note_at_snapshot || "",
    };
  });
}

function manifest() {
  const state = reviewState();
  const allItems = [...companyItems(), ...noncompanyItems()];
  const seen = new Set();
  const items = [];
  for (const item of allItems) {
    if (!item.id || seen.has(item.id)) continue;
    seen.add(item.id);
    const original = fileInfo(item.baseline_path || item.workspace_path);
    const candidate = fileInfo(item.candidate_path);
    items.push({
      ...item,
      original_exists: original.exists,
      original_size: original.size,
      candidate_exists: candidate.exists,
      candidate_size: candidate.size,
      review: state.items?.[item.id] || { status: "pending", note: "" },
    });
  }

  items.sort((a, b) => {
    const scopeOrder = a.scope_id.localeCompare(b.scope_id);
    if (scopeOrder !== 0) return scopeOrder;
    const groupOrder = a.group_label.localeCompare(b.group_label, "ko");
    if (groupOrder !== 0) return groupOrder;
    const variantOrder = a.variant_label.localeCompare(b.variant_label, "ko");
    if (variantOrder !== 0) return variantOrder;
    return a.workspace_path.localeCompare(b.workspace_path);
  });

  const groupMap = new Map();
  const variantMap = new Map();
  const scopeMap = new Map();
  const statuses = { pending: 0, approved: 0, needs_edit: 0, remake: 0 };
  let missingOriginal = 0;
  let missingCandidate = 0;
  for (const item of items) {
    incrementFacet(groupMap, item.group_id, item.group_label);
    incrementFacet(variantMap, item.variant_id, item.variant_label);
    incrementFacet(scopeMap, item.scope_id, item.scope_label);
    const status = item.review.status || "pending";
    statuses[status] = (statuses[status] || 0) + 1;
    if (!item.original_exists) missingOriginal += 1;
    if (!item.candidate_exists) missingCandidate += 1;
  }

  return {
    version: Number(REVIEW_VERSION),
    generated_at: new Date().toISOString(),
    total: items.length,
    expected_total: REVIEW_VERSION === "4" ? 113 : REVIEW_VERSION === "3" ? 923 : 924,
    baseline_label: REVIEW_VERSION === "4" ? "이전 후보 (V3)" : "현재 게임 이미지",
    candidate_label: REVIEW_VERSION === "4" ? "신규 후보 (V4)" : "신규 재생산 이미지",
    statuses,
    missing_original: missingOriginal,
    missing_candidate: missingCandidate,
    groups: [...groupMap.values()].sort((a, b) => b.count - a.count),
    variants: [...variantMap.values()].sort((a, b) => b.count - a.count),
    scopes: [...scopeMap.values()].sort((a, b) => b.count - a.count),
    items,
  };
}

function incrementFacet(map, id, label) {
  const current = map.get(id) || { id, label, count: 0 };
  current.count += 1;
  map.set(id, current);
}

function sendJson(res, payload, status = 200) {
  const body = JSON.stringify(payload);
  res.writeHead(status, {
    "Content-Type": "application/json; charset=utf-8",
    "Content-Length": Buffer.byteLength(body),
    "Cache-Control": "no-store",
  });
  res.end(body);
}

function sendFile(res, filePath, contentType) {
  if (!fs.existsSync(filePath) || !fs.statSync(filePath).isFile()) {
    res.writeHead(404);
    res.end("Not found");
    return;
  }
  res.writeHead(200, { "Content-Type": contentType, "Cache-Control": "public, max-age=300" });
  fs.createReadStream(filePath).pipe(res);
}

function serveWorkspaceFile(res, relativePath) {
  const fullPath = path.resolve(ROOT, relativePath);
  if (!(fullPath === ROOT || fullPath.startsWith(`${ROOT}${path.sep}`))) {
    res.writeHead(403);
    res.end("Forbidden");
    return;
  }
  const ext = path.extname(fullPath).toLowerCase();
  const types = { ".png": "image/png", ".jpg": "image/jpeg", ".jpeg": "image/jpeg", ".webp": "image/webp" };
  return sendFile(res, fullPath, types[ext] || "application/octet-stream");
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    let body = "";
    req.on("data", (chunk) => {
      body += chunk;
      if (body.length > 1_000_000) reject(new Error("request body too large"));
    });
    req.on("end", () => resolve(body));
    req.on("error", reject);
  });
}

function updateReview(id, status, note) {
  const state = reviewState();
  state.items ||= {};
  state.items[id] = { status, note, updated_at: new Date().toISOString() };
  state.updated_at = new Date().toISOString();
  writeJsonAtomic(STATE_PATH, state);
  return state.items[id];
}

const server = http.createServer(async (req, res) => {
  const parsed = url.parse(req.url, true);
  const pathname = decodeURIComponent(parsed.pathname || "/");
  try {
    if (req.method === "GET" && pathname === "/api/health") {
      return sendJson(res, { ok: true, version: Number(REVIEW_VERSION) });
    }
    if (req.method === "GET" && pathname === "/api/manifest") {
      return sendJson(res, manifest());
    }
    if (req.method === "GET" && pathname === "/api/state") {
      return sendJson(res, reviewState());
    }
    if (req.method === "POST" && pathname === "/api/state") {
      const body = JSON.parse(await readBody(req));
      const id = String(body.id || "");
      const status = String(body.status || "pending");
      if (!id) return sendJson(res, { ok: false, error: "missing id" }, 400);
      if (!["pending", "approved", "needs_edit", "remake"].includes(status)) {
        return sendJson(res, { ok: false, error: "invalid status" }, 400);
      }
      const known = new Set([...companyItems(), ...noncompanyItems()].map((item) => item.id));
      if (!known.has(id)) return sendJson(res, { ok: false, error: "unknown id" }, 404);
      return sendJson(res, { ok: true, item: updateReview(id, status, String(body.note || "")) });
    }
    if (req.method === "GET" && pathname.startsWith("/original/")) {
      return serveWorkspaceFile(res, pathname.slice("/original/".length));
    }
    if (req.method === "GET" && pathname.startsWith("/candidate/")) {
      const relativePath = pathname.slice("/candidate/".length);
      const fullPath = path.resolve(ROOT, relativePath);
      if (!(fullPath === REGEN_ROOT || fullPath.startsWith(`${REGEN_ROOT}${path.sep}`))) {
        res.writeHead(403);
        res.end("Forbidden");
        return;
      }
      return serveWorkspaceFile(res, relativePath);
    }

    const publicPath = pathname === "/" ? "index.html" : pathname.slice(1);
    const fullPublicPath = path.resolve(PUBLIC_DIR, publicPath);
    if (!(fullPublicPath === PUBLIC_DIR || fullPublicPath.startsWith(`${PUBLIC_DIR}${path.sep}`))) {
      res.writeHead(403);
      res.end("Forbidden");
      return;
    }
    const ext = path.extname(fullPublicPath).toLowerCase();
    const types = { ".html": "text/html; charset=utf-8", ".css": "text/css; charset=utf-8", ".js": "text/javascript; charset=utf-8" };
    return sendFile(res, fullPublicPath, types[ext] || "application/octet-stream");
  } catch (error) {
    console.error(error);
    return sendJson(res, { ok: false, error: error.message }, 500);
  }
});

server.listen(PORT, HOST, () => {
  console.log(`Event CG Review V${REVIEW_VERSION}: http://${HOST}:${PORT}`);
  console.log(`Review state: ${STATE_PATH}`);
});

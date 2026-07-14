#!/usr/bin/env node

const fs = require("fs");
const path = require("path");
const http = require("http");
const url = require("url");

const ROOT = path.resolve(__dirname, "../..");
const PUBLIC_DIR = path.join(__dirname, "public_v2");
const STATE_PATH = path.join(__dirname, "review_state_v2.json");
const COMPANY_MANIFEST_PATH = path.join(ROOT, "tmp/event_cg_regen_v2/manifests/company_work.json");
const NONCOMPANY_MANIFEST_PATH = path.join(ROOT, "tmp/event_cg_regen_v2/manifests/noncompany_remake.json");
const HOST = String(process.env.HOST || "127.0.0.1");
const PORT = Number(process.env.PORT || 4177);
const VALID_STATUSES = new Set(["pending", "approved", "needs_edit", "remake"]);

function readJson(filePath, fallback = {}) {
  if (!fs.existsSync(filePath)) return fallback;
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function writeJsonAtomic(filePath, payload) {
  const tempPath = `${filePath}.tmp`;
  fs.writeFileSync(tempPath, JSON.stringify(payload, null, 2), "utf8");
  fs.renameSync(tempPath, filePath);
}

function statePayload() {
  return readJson(STATE_PATH, { version: 2, updated_at: "", items: {} });
}

function workspaceFileExists(workspacePath) {
  return Boolean(workspacePath) && fs.existsSync(path.join(ROOT, workspacePath));
}

function imageUrl(workspacePath) {
  return `/image/${workspacePath.split("/").map(encodeURIComponent).join("/")}`;
}

function compactEvent(event = {}) {
  return {
    id: String(event.id || ""),
    name_ko: String(event.name_ko || ""),
    summary_ko: String(event.summary_ko || ""),
    dialogue: Array.isArray(event.dialogue) ? event.dialogue.map(String) : [],
    mode: String(event.mode || ""),
    tags: Array.isArray(event.tags) ? event.tags.map(String) : [],
  };
}

function companyItems() {
  const manifest = readJson(COMPANY_MANIFEST_PATH, {});
  return (manifest.targets || []).map((target) => {
    const oldPath = String(target.runtime_path || "");
    const newPath = String(target.target_path || "");
    const variantId = target.season === "summer" ? "summer" : "base";
    return {
      id: oldPath,
      workstream_id: "company",
      workstream_label: "회사 기본업무 전면 재생산",
      group_id: "company_work",
      group_label: "회사 기본업무",
      variant_id: variantId,
      variant_label: variantId === "summer" ? "여름" : "기본/겨울",
      lane: Number(target.lane || 0),
      old_path: oldPath,
      new_path: newPath,
      old_image_url: imageUrl(oldPath),
      new_image_url: imageUrl(newPath),
      old_exists: workspaceFileExists(oldPath),
      new_exists: workspaceFileExists(newPath),
      previous_status: "ignored",
      previous_note: "회사 기본업무는 기존 판정을 무시하고 전면 재생산",
      event: compactEvent({
        id: target.event_id,
        name_ko: target.name_ko,
        summary_ko: target.summary_ko,
        dialogue: target.dialogue,
        mode: target.mode,
      }),
      scene_location: String(target.location || ""),
      scene_composition: String(target.composition || ""),
    };
  });
}

function noncompanyItems() {
  const manifest = readJson(NONCOMPANY_MANIFEST_PATH, {});
  return (manifest.items || []).map((item) => {
    const oldPath = String(item.workspace_path || "");
    const newPath = String(item.staging_path || "");
    const scenePlan = item.scene_plan || {};
    return {
      id: oldPath,
      workstream_id: "noncompany",
      workstream_label: "기존 재생성 판정",
      group_id: String(item.group_id || "other"),
      group_label: String(item.group_label || "기타"),
      variant_id: String(item.variant_id || "base"),
      variant_label: String(item.variant_label || "기본/겨울"),
      lane: Number(item.lane || 0),
      old_path: oldPath,
      new_path: newPath,
      old_image_url: imageUrl(oldPath),
      new_image_url: imageUrl(newPath),
      old_exists: workspaceFileExists(oldPath),
      new_exists: workspaceFileExists(newPath),
      previous_status: String(item.status_at_snapshot || "remake"),
      previous_note: String(item.note_at_snapshot || ""),
      event: compactEvent((item.events || [])[0] || {}),
      scene_location: String(scenePlan.location_slot || ""),
      scene_composition: String(scenePlan.camera_slot || ""),
    };
  });
}

function buildManifest() {
  const items = [...companyItems(), ...noncompanyItems()];
  const seen = new Set();
  for (const item of items) {
    if (!item.id || seen.has(item.id)) throw new Error(`duplicate or empty V2 id: ${item.id}`);
    seen.add(item.id);
  }
  const groups = new Map();
  const variants = new Map();
  const workstreams = new Map();
  for (const item of items) {
    groups.set(item.group_id, { id: item.group_id, label: item.group_label, count: (groups.get(item.group_id)?.count || 0) + 1 });
    variants.set(item.variant_id, { id: item.variant_id, label: item.variant_label, count: (variants.get(item.variant_id)?.count || 0) + 1 });
    workstreams.set(item.workstream_id, { id: item.workstream_id, label: item.workstream_label, count: (workstreams.get(item.workstream_id)?.count || 0) + 1 });
  }
  return {
    version: 2,
    generated_at: new Date().toISOString(),
    total: items.length,
    missing_old: items.filter((item) => !item.old_exists).length,
    missing_new: items.filter((item) => !item.new_exists).length,
    groups: [...groups.values()].sort((a, b) => b.count - a.count),
    variants: [...variants.values()].sort((a, b) => b.count - a.count),
    workstreams: [...workstreams.values()].sort((a, b) => b.count - a.count),
    items,
  };
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
  if (!fs.existsSync(filePath)) {
    res.writeHead(404);
    res.end("Not found");
    return;
  }
  res.writeHead(200, { "Content-Type": contentType });
  fs.createReadStream(filePath).pipe(res);
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    let body = "";
    req.on("data", (chunk) => {
      body += chunk;
      if (body.length > 2_000_000) reject(new Error("request body too large"));
    });
    req.on("end", () => resolve(body));
    req.on("error", reject);
  });
}

function isWithinRoot(filePath, rootPath) {
  return filePath === rootPath || filePath.startsWith(`${rootPath}${path.sep}`);
}

function updateItemState(id, patch) {
  const state = statePayload();
  state.items = state.items || {};
  state.items[id] = {
    ...(state.items[id] || {}),
    ...patch,
    updated_at: new Date().toISOString(),
  };
  state.updated_at = new Date().toISOString();
  writeJsonAtomic(STATE_PATH, state);
  return state.items[id];
}

const server = http.createServer(async (req, res) => {
  const parsed = url.parse(req.url, true);
  const pathname = decodeURIComponent(parsed.pathname || "/");
  try {
    if (req.method === "GET" && pathname === "/api/manifest") return sendJson(res, buildManifest());
    if (req.method === "GET" && pathname === "/api/state") return sendJson(res, statePayload());
    if (req.method === "POST" && pathname === "/api/state") {
      const body = JSON.parse(await readBody(req));
      const id = String(body.id || "");
      const status = String(body.status || "pending");
      if (!VALID_STATUSES.has(status)) return sendJson(res, { ok: false, error: "invalid status" }, 400);
      const validIds = new Set(buildManifest().items.map((item) => item.id));
      if (!validIds.has(id)) return sendJson(res, { ok: false, error: "unknown id" }, 400);
      const item = updateItemState(id, { status, note: String(body.note || "") });
      return sendJson(res, { ok: true, item });
    }
    if (req.method === "GET" && pathname.startsWith("/image/")) {
      const workspacePath = pathname.slice("/image/".length);
      const fullPath = path.resolve(ROOT, workspacePath);
      if (!isWithinRoot(fullPath, ROOT) || !fs.existsSync(fullPath)) {
        res.writeHead(404);
        res.end("Not found");
        return;
      }
      const ext = path.extname(fullPath).toLowerCase();
      const types = { ".png": "image/png", ".jpg": "image/jpeg", ".jpeg": "image/jpeg", ".webp": "image/webp" };
      return sendFile(res, fullPath, types[ext] || "application/octet-stream");
    }

    const publicPath = pathname === "/" ? "index.html" : pathname.slice(1);
    const fullPublicPath = path.resolve(PUBLIC_DIR, publicPath);
    if (!isWithinRoot(fullPublicPath, PUBLIC_DIR)) {
      res.writeHead(403);
      res.end("Forbidden");
      return;
    }
    const ext = path.extname(fullPublicPath);
    const types = { ".html": "text/html; charset=utf-8", ".css": "text/css; charset=utf-8", ".js": "text/javascript; charset=utf-8" };
    return sendFile(res, fullPublicPath, types[ext] || "application/octet-stream");
  } catch (error) {
    console.error(error);
    return sendJson(res, { ok: false, error: error.message }, 500);
  }
});

server.listen(PORT, HOST, () => {
  const manifest = buildManifest();
  console.log(`Event CG review V2: http://${HOST}:${PORT}`);
  console.log(`Items: ${manifest.total}, missing old: ${manifest.missing_old}, missing new: ${manifest.missing_new}`);
  console.log(`Review state: ${STATE_PATH}`);
});

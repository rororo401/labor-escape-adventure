#!/usr/bin/env node

const fs = require("fs");
const path = require("path");
const http = require("http");
const url = require("url");

const ROOT = path.resolve(__dirname, "../..");
const PUBLIC_DIR = path.join(__dirname, "public");
const STATE_PATH = path.join(__dirname, "review_state.json");
const PORT = Number(process.env.PORT || 4177);
const HOST = String(process.env.HOST || "127.0.0.1");

const EVENT_SOURCES = [
  { id: "day_events", path: "data/game/day_events.json", collections: ["day_actions", "weekday_events", "night_events"] },
  { id: "special_annual", path: "data/game/special_annual_events.json", collections: ["day_actions"] },
  { id: "market_fixed", path: "data/game/market_fixed_events.json", collections: ["day_actions"] },
];

const CODE_ONLY_EVENTS = [
  {
    id: "summer_vacation_common_departure",
    name_ko: "여름휴가 출발",
    mode: "annual_special",
    group: "special",
    cg_path: "res://assets/events/special/annual/summer_vacation/common_departure.png",
    source: "code_only",
  },
  {
    id: "summer_vacation_common_return",
    name_ko: "여름휴가 귀국",
    mode: "annual_special",
    group: "special",
    cg_path: "res://assets/events/special/annual/summer_vacation/common_return.png",
    source: "code_only",
  },
  {
    id: "health_resurrection_ghost_summer",
    name_ko: "건강 0 부활 - 유령 여름",
    mode: "health_resurrection",
    group: "special",
    cg_path: "res://assets/events/special/health_resurrection/health_zero_ghost_summer.png",
    source: "code_only",
  },
  {
    id: "health_resurrection_ghost_winter",
    name_ko: "건강 0 부활 - 유령 겨울",
    mode: "health_resurrection",
    group: "special",
    cg_path: "res://assets/events/special/health_resurrection/health_zero_ghost_winter.png",
    source: "code_only",
  },
  {
    id: "health_resurrection_goddess_summer",
    name_ko: "건강 0 부활 - 여신 여름",
    mode: "health_resurrection",
    group: "special",
    cg_path: "res://assets/events/special/health_resurrection/goddess_second_chance_summer.png",
    source: "code_only",
  },
  {
    id: "health_resurrection_goddess_winter",
    name_ko: "건강 0 부활 - 여신 겨울",
    mode: "health_resurrection",
    group: "special",
    cg_path: "res://assets/events/special/health_resurrection/goddess_second_chance_winter.png",
    source: "code_only",
  },
  {
    id: "clear_ending_target_reached",
    name_ko: "10억, 진짜 찍었다!",
    mode: "ending_special",
    group: "ending",
    cg_path: "res://assets/events/special/ending/clear/clear_ending_target_reached.png",
    source: "code_only",
  },
  {
    id: "clear_ending_small_celebration",
    name_ko: "오늘만큼은 축하",
    mode: "ending_special",
    group: "ending",
    cg_path: "res://assets/events/special/ending/clear/clear_ending_small_celebration.png",
    source: "code_only",
  },
  {
    id: "clear_ending_weekday_off",
    name_ko: "일단 오늘은 쉽니다",
    mode: "ending_special",
    group: "ending",
    cg_path: "res://assets/events/special/ending/clear/clear_ending_weekday_off.png",
    source: "code_only",
  },
];

function readJson(relativePath, fallback = {}) {
  const fullPath = path.join(ROOT, relativePath);
  if (!fs.existsSync(fullPath)) return fallback;
  return JSON.parse(fs.readFileSync(fullPath, "utf8"));
}

function writeJsonAtomic(filePath, payload) {
  const tempPath = `${filePath}.tmp`;
  fs.writeFileSync(tempPath, JSON.stringify(payload, null, 2), "utf8");
  fs.renameSync(tempPath, filePath);
}

function statePayload() {
  if (!fs.existsSync(STATE_PATH)) {
    return { version: 1, updated_at: "", items: {} };
  }
  return readJson(path.relative(ROOT, STATE_PATH), { version: 1, updated_at: "", items: {} });
}

function toWorkspacePath(resPath) {
  if (!resPath || !resPath.startsWith("res://")) return "";
  return resPath.slice("res://".length);
}

function toResPath(workspacePath) {
  return `res://${workspacePath.replace(/\\/g, "/")}`;
}

function fileExists(workspacePath) {
  return Boolean(workspacePath) && fs.existsSync(path.join(ROOT, workspacePath));
}

function walkImages(relativeDir) {
  const rootDir = path.join(ROOT, relativeDir);
  const images = [];
  if (!fs.existsSync(rootDir)) return images;
  const stack = [rootDir];
  while (stack.length > 0) {
    const current = stack.pop();
    for (const entry of fs.readdirSync(current, { withFileTypes: true })) {
      const full = path.join(current, entry.name);
      if (entry.isDirectory()) {
        stack.push(full);
      } else if (/\.(png|jpe?g|webp)$/i.test(entry.name)) {
        images.push(path.relative(ROOT, full).replace(/\\/g, "/"));
      }
    }
  }
  return images.sort();
}

function eventRows() {
  const rows = [];
  for (const source of EVENT_SOURCES) {
    const payload = readJson(source.path, {});
    for (const collection of source.collections) {
      for (const row of payload[collection] || []) {
        rows.push({ ...row, source: source.id, source_file: source.path, collection });
      }
    }
  }
  rows.push(...CODE_ONLY_EVENTS);
  return rows;
}

function groupFromPath(workspacePath) {
  if (workspacePath.includes("/company_work/")) return { id: "company_work", label: "회사 기본업무" };
  if (workspacePath.includes("/weekend/stay_home/")) return { id: "weekend_stay_home", label: "주말/집" };
  if (workspacePath.includes("/weekend/go_out/")) return { id: "weekend_go_out", label: "주말/외출" };
  if (workspacePath.includes("/weekday/")) return { id: "weekday_random", label: "출근일 랜덤사건" };
  if (workspacePath.includes("/night/")) return { id: "night", label: "밤/돌발" };
  if (workspacePath.includes("/market_fixed/")) return { id: "market_fixed", label: "시장 고정사건" };
  if (workspacePath.includes("/special/annual/summer_vacation/")) return { id: "summer_vacation", label: "특수/여름휴가" };
  if (workspacePath.includes("/special/annual/new_year/")) return { id: "new_year", label: "특수/신정" };
  if (workspacePath.includes("/special/annual/seollal/")) return { id: "seollal", label: "특수/설날" };
  if (workspacePath.includes("/special/annual/chuseok/")) return { id: "chuseok", label: "특수/추석" };
  if (workspacePath.includes("/special/health_resurrection/")) return { id: "health_resurrection", label: "특수/부활" };
  if (workspacePath.includes("/special/ending/")) return { id: "ending", label: "특수/엔딩" };
  return { id: "other", label: "기타" };
}

function groupFromEvent(row, workspacePath) {
  const pathGroup = groupFromPath(workspacePath);
  if (pathGroup.id !== "other") return pathGroup;

  const mode = String(row.mode || "");
  const category = String(row.category_id || "");
  const group = String(row.group || "");
  if (group === "company_work" || category === "company_work") return { id: "company_work", label: "회사 기본업무" };
  if (category === "stay_home") return { id: "weekend_stay_home", label: "주말/집" };
  if (category === "go_out") return { id: "weekend_go_out", label: "주말/외출" };
  if (mode === "weekday_random") return { id: "weekday_random", label: "출근일 랜덤사건" };
  if (mode === "night_random") return { id: "night", label: "밤/돌발" };
  if (mode === "market_fixed") return { id: "market_fixed", label: "시장 고정사건" };
  if (mode === "annual_special") return { id: "special", label: "특수/연간" };
  return pathGroup;
}

function variantForPath(workspacePath) {
  if (workspacePath.startsWith("assets/events_summer/")) return { id: "summer", label: "여름" };
  if (workspacePath.includes("/special/")) return { id: "special", label: "특수 단일" };
  return { id: "base", label: "기본/겨울" };
}

function compactEvent(row) {
  return {
    id: row.id || "",
    name_ko: row.name_ko || "",
    summary_ko: row.summary_ko || "",
    mode: row.mode || "",
    group: row.group || "",
    category_id: row.category_id || "",
    category_ko: row.category_ko || "",
    source: row.source || "",
    source_file: row.source_file || "",
    collection: row.collection || "",
    tags: Array.isArray(row.tags) ? row.tags : [],
    planned_cg_path: row.planned_cg_path || "",
  };
}

function addEvent(imageMap, workspacePath, row) {
  if (!workspacePath) return;
  const group = groupFromEvent(row, workspacePath);
  const variant = variantForPath(workspacePath);
  const key = workspacePath;
  if (!imageMap.has(key)) {
    imageMap.set(key, {
      id: key,
      workspace_path: workspacePath,
      res_path: toResPath(workspacePath),
      image_url: `/image/${workspacePath}`,
      group_id: group.id,
      group_label: group.label,
      variant_id: variant.id,
      variant_label: variant.label,
      exists: fileExists(workspacePath),
      events: [],
    });
  }
  const entry = imageMap.get(key);
  if (!entry.events.some((event) => event.id === row.id && event.source === row.source)) {
    entry.events.push(compactEvent(row));
  }
}

function buildManifest() {
  const imageMap = new Map();
  const rows = eventRows();

  for (const row of rows) {
    const basePath = toWorkspacePath(row.cg_path);
    addEvent(imageMap, basePath, row);
    if (basePath.startsWith("assets/events/")) {
      const summerPath = `assets/events_summer/${basePath.slice("assets/events/".length)}`;
      if (fileExists(summerPath)) addEvent(imageMap, summerPath, row);
    }
  }

  for (const workspacePath of [...walkImages("assets/events"), ...walkImages("assets/events_summer")]) {
    if (!imageMap.has(workspacePath)) {
      const group = groupFromPath(workspacePath);
      const variant = variantForPath(workspacePath);
      imageMap.set(workspacePath, {
        id: workspacePath,
        workspace_path: workspacePath,
        res_path: toResPath(workspacePath),
        image_url: `/image/${workspacePath}`,
        group_id: group.id,
        group_label: group.label,
        variant_id: variant.id,
        variant_label: variant.label,
        exists: true,
        events: [],
      });
    }
  }

  const items = [...imageMap.values()].sort((a, b) => {
    const group = a.group_label.localeCompare(b.group_label, "ko");
    if (group !== 0) return group;
    const variant = a.variant_label.localeCompare(b.variant_label, "ko");
    if (variant !== 0) return variant;
    return a.workspace_path.localeCompare(b.workspace_path);
  });

  const groups = {};
  const variants = {};
  const statuses = { pending: 0, approved: 0, needs_edit: 0, remake: 0 };
  const state = statePayload();
  for (const item of items) {
    groups[item.group_id] = groups[item.group_id] || { id: item.group_id, label: item.group_label, count: 0 };
    groups[item.group_id].count += 1;
    variants[item.variant_id] = variants[item.variant_id] || { id: item.variant_id, label: item.variant_label, count: 0 };
    variants[item.variant_id].count += 1;
    const itemState = state.items[item.id] || {};
    const status = itemState.status || "pending";
    statuses[status] = (statuses[status] || 0) + 1;
  }

  return {
    generated_at: new Date().toISOString(),
    root: ROOT,
    total: items.length,
    groups: Object.values(groups).sort((a, b) => b.count - a.count),
    variants: Object.values(variants).sort((a, b) => b.count - a.count),
    statuses,
    items,
  };
}

function sendJson(res, payload, status = 200) {
  const body = JSON.stringify(payload);
  res.writeHead(status, {
    "Content-Type": "application/json; charset=utf-8",
    "Content-Length": Buffer.byteLength(body),
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

function updateItemState(id, patch) {
  const payload = statePayload();
  payload.items = payload.items || {};
  payload.items[id] = {
    ...(payload.items[id] || {}),
    ...patch,
    updated_at: new Date().toISOString(),
  };
  payload.updated_at = new Date().toISOString();
  writeJsonAtomic(STATE_PATH, payload);
  return payload.items[id];
}

const server = http.createServer(async (req, res) => {
  const parsed = url.parse(req.url, true);
  const pathname = decodeURIComponent(parsed.pathname || "/");

  try {
    if (req.method === "GET" && pathname === "/api/manifest") {
      return sendJson(res, buildManifest());
    }
    if (req.method === "GET" && pathname === "/api/state") {
      return sendJson(res, statePayload());
    }
    if (req.method === "POST" && pathname === "/api/state") {
      const body = JSON.parse(await readBody(req));
      if (!body.id) return sendJson(res, { ok: false, error: "missing id" }, 400);
      const status = String(body.status || "pending");
      if (!["pending", "approved", "needs_edit", "remake"].includes(status)) {
        return sendJson(res, { ok: false, error: "invalid status" }, 400);
      }
      const item = updateItemState(body.id, {
        status,
        note: String(body.note || ""),
      });
      return sendJson(res, { ok: true, item });
    }
    if (req.method === "GET" && pathname.startsWith("/image/")) {
      const workspacePath = pathname.slice("/image/".length);
      const fullPath = path.resolve(ROOT, workspacePath);
      if (!fullPath.startsWith(ROOT) || !fileExists(workspacePath)) {
        res.writeHead(404);
        res.end("Not found");
        return;
      }
      return sendFile(res, fullPath, "image/png");
    }

    const publicPath = pathname === "/" ? "index.html" : pathname.slice(1);
    const fullPublicPath = path.resolve(PUBLIC_DIR, publicPath);
    if (!fullPublicPath.startsWith(PUBLIC_DIR)) {
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
  console.log(`Event CG review app: http://${HOST}:${PORT}`);
  console.log(`Review state: ${STATE_PATH}`);
});

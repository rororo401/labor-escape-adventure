#!/usr/bin/env node

const crypto = require("crypto");
const fs = require("fs");
const path = require("path");

const ROOT = path.resolve(__dirname, "../..");
const OUTPUT_ROOT = path.join(ROOT, "docs/gameplay/event_cg_situation_audit_batches");
const INPUT_ROOT = path.join(OUTPUT_ROOT, "inputs");
const RESULT_ROOT = path.join(OUTPUT_ROOT, "results");
const MANIFEST_URL = process.env.MANIFEST_URL || "http://127.0.0.1:4180/api/manifest";
const COMPLETED_PREFIX_COUNT = 150;
const SESSION_COUNT = 10;
const AGENTS_PER_SESSION = 4;


function distribute(items, count) {
  const chunks = [];
  const base = Math.floor(items.length / count);
  const remainder = items.length % count;
  let cursor = 0;
  for (let index = 0; index < count; index += 1) {
    const size = base + (index < remainder ? 1 : 0);
    chunks.push(items.slice(cursor, cursor + size));
    cursor += size;
  }
  return chunks;
}


function hashFile(workspacePath) {
  const fullPath = path.join(ROOT, workspacePath);
  if (!fs.existsSync(fullPath)) return "";
  return crypto.createHash("sha256").update(fs.readFileSync(fullPath)).digest("hex");
}


function compactItem(item, globalIndex, duplicatePaths) {
  return {
    global_index: globalIndex,
    id: item.id,
    workspace_path: item.workspace_path,
    res_path: item.res_path,
    group_id: item.group_id,
    group_label: item.group_label,
    variant_id: item.variant_id,
    variant_label: item.variant_label,
    duplicate_paths: duplicatePaths,
    events: item.events,
  };
}


function shardPrompt(batchNumber, agentNumber, shardPath, resultPath, itemCount) {
  return `너는 이벤트 CG 상황 일치 검수 서브에이전트다.\n\n` +
    `작업 루트: ${ROOT}\n` +
    `입력 파일: ${shardPath}\n` +
    `결과 파일: ${resultPath}\n` +
    `검사 수량: ${itemCount}장\n\n` +
    `입력 JSON의 모든 items를 빠짐없이 검사해라. 각 이미지 원본을 view_image로 직접 열고, events의 id/source_file을 기준으로 data/game JSON과 docs/gameplay 문서를 rg 또는 jq로 찾아 실제 dialogue, summary, 제작 프롬프트와 비교해라. duplicate_paths가 있으면 동일 파일이 의도된 공용 CG인지 확인하고, 다른 이벤트 이미지 복사라면 mismatch로 판정해라.\n\n` +
    `이번 검사는 손가락·인체·작화 취향 검수가 아니라 이벤트 상황 일치 검수다. 핵심 행동, 장소, 시간대, 계절, 의상, 소품이 자연스럽게 맞으면 match다. 다른 이벤트 장면, 반대 시간대/장소, 핵심 행동 부재, 여름판의 겨울 의상, 특수 이벤트의 잘못된 여행지·명절은 mismatch다. 근거가 부족하면 억지로 단정하지 말고 recheck로 둔다.\n\n` +
    `결과 JSON 형식은 version, batch_id, agent_id, expected_count, completed_count, items 배열이다. 각 item은 global_index, id, workspace_path, verdict(match|mismatch|recheck), expected_scene, actual_scene, reason, duplicate_paths, suggested_status, note를 가진다. mismatch의 suggested_status는 remake이고 note는 '[자동 상황검수] 기대: ... / 실제: ... / 근거: ...' 형식이다. match와 recheck는 suggested_status를 빈 문자열로 둔다.\n\n` +
    `기존 review_state.json, 마스터 보고서, 다른 에이전트 결과는 절대 수정하지 마라. 결과는 ${resultPath} 하나에만 기록하고 10장마다 중간 저장해라. 마지막에 completed_count가 ${itemCount}인지, global_index 중복/누락이 없는지 검증한 뒤 부모 에이전트에 완료 수, mismatch 수, recheck 수를 보고해라.`;
}


function sessionDocument(batchNumber, shards) {
  const batchId = `batch_${String(batchNumber).padStart(2, "0")}`;
  const total = shards.reduce((sum, shard) => sum + shard.items.length, 0);
  const start = shards[0].items[0].global_index;
  const end = shards.at(-1).items.at(-1).global_index;
  const lines = [
    `# 이벤트 CG 상황 검수 ${batchId}`,
    "",
    `- 전체 범위: manifest ${start}-${end}`,
    `- 전체 수량: ${total}장`,
    `- 서브에이전트: ${shards.length}개`,
    `- 결과 폴더: \`docs/gameplay/event_cg_situation_audit_batches/results/${batchId}/\``,
    "",
    "## 부모 세션 지시",
    "",
    "1. 아래 4개 작업을 각각 별도 서브에이전트에 할당하고 동시에 시작한다.",
    "2. 부모는 이미지를 다시 검사하지 말고, 서브에이전트 결과 형식·수량·중복·누락을 검증한다.",
    "3. 서브에이전트가 없거나 호출할 수 없다면 부모가 4개 shard를 순서대로 처리한다.",
    "4. 공유 `tools/event_cg_review/review_state.json`과 `docs/gameplay/event_cg_situation_mismatch_report.md`는 수정하지 않는다.",
    `5. 4개 결과의 completed_count 합계가 ${total}인지 확인한다.`,
    `6. 검증 결과를 \`docs/gameplay/event_cg_situation_audit_batches/results/${batchId}/summary.md\`에 기록한다.`,
    "",
  ];

  for (const shard of shards) {
    lines.push(`## 서브에이전트 ${shard.agentNumber}`);
    lines.push("");
    lines.push("```text");
    lines.push(shard.prompt);
    lines.push("```");
    lines.push("");
  }
  return `${lines.join("\n")}\n`;
}


function mainSessionPrompt(batchNumber, documentPath) {
  const batchId = `batch_${String(batchNumber).padStart(2, "0")}`;
  return `${ROOT}에서 ${documentPath} 문서의 이벤트 CG 상황 일치 검수를 끝까지 진행해줘. ` +
    `반드시 먼저 서로 겹치지 않는 서브에이전트 4개를 동시에 호출해서 문서에 적힌 shard 4개를 하나씩 맡겨. ` +
    `각 서브에이전트가 실제 이미지 원본을 열어 상황을 비교하고 자기 전용 결과 JSON만 쓰게 해. ` +
    `부모 세션은 4개 결과가 모두 끝날 때까지 기다린 뒤 수량, global_index 중복과 누락, JSON 형식을 검증하고 ` +
    `docs/gameplay/event_cg_situation_audit_batches/results/${batchId}/summary.md를 작성해. ` +
    `공유 review_state.json과 기존 마스터 보고서는 절대 수정하지 말고, 이미지 생성이나 교체도 하지 마.`;
}


function mergePrompt() {
  return `${ROOT}에서 분할 이벤트 CG 상황 검수 결과를 최종 병합해줘.\n\n` +
    `입력은 docs/gameplay/event_cg_situation_audit_batches/results/batch_01부터 batch_10까지의 agent_01.json~agent_04.json, 기존 docs/gameplay/event_cg_situation_mismatch_report.md, tools/event_cg_review/review_state.json이다.\n\n` +
    `먼저 40개 결과 JSON이 모두 존재하는지 확인하고 expected_count와 completed_count가 일치하는지, 전체 global_index 151~1655가 정확히 한 번씩 존재하는지 검증해. 누락이나 중복이 있으면 공유 상태를 수정하지 말고 오류 목록만 보고해.\n\n` +
    `완전성이 확인되면 mismatch 항목만 tools/event_cg_review/review_state.json에 순차 병합해. 기존 note는 보존하고 [자동 상황검수] 내용이 이미 있으면 중복 추가하지 마. mismatch는 remake로 바꾸고, match는 기존 상태를 절대 변경하지 마. recheck도 상태를 변경하지 마. 병렬 쓰기는 금지하고 한 프로세스에서 원자적으로 저장해.\n\n` +
    `마지막으로 docs/gameplay/event_cg_situation_mismatch_report.md를 총 1,655장 기준으로 갱신해. 기존 1~150 검사 결과와 분할 결과를 합쳐 명확한 불일치, 재확인 필요, 동일 파일 복제 목록을 정리하고 최종 검증 수량을 기록해. 이미지 생성, 교체, 이벤트 JSON 수정은 하지 마.`;
}


async function main() {
  const response = await fetch(MANIFEST_URL);
  if (!response.ok) throw new Error(`manifest request failed: ${response.status}`);
  const manifest = await response.json();
  if (!Array.isArray(manifest.items) || manifest.items.length !== manifest.total) {
    throw new Error("invalid manifest payload");
  }
  if (manifest.items.length <= COMPLETED_PREFIX_COUNT) {
    throw new Error("manifest has no remaining items");
  }

  fs.rmSync(OUTPUT_ROOT, { recursive: true, force: true });
  fs.mkdirSync(INPUT_ROOT, { recursive: true });
  fs.mkdirSync(RESULT_ROOT, { recursive: true });

  const pathsByHash = new Map();
  for (const item of manifest.items) {
    const hash = hashFile(item.workspace_path);
    if (!hash) continue;
    if (!pathsByHash.has(hash)) pathsByHash.set(hash, []);
    pathsByHash.get(hash).push(item.workspace_path);
  }

  const remaining = manifest.items.slice(COMPLETED_PREFIX_COUNT).map((item, index) => {
    const hash = hashFile(item.workspace_path);
    const duplicates = (pathsByHash.get(hash) || []).filter((entry) => entry !== item.workspace_path);
    return compactItem(item, COMPLETED_PREFIX_COUNT + index + 1, duplicates);
  });
  const sessionChunks = distribute(remaining, SESSION_COUNT);
  const sessionPromptBlocks = [];
  const indexRows = [];

  for (let sessionIndex = 0; sessionIndex < sessionChunks.length; sessionIndex += 1) {
    const batchNumber = sessionIndex + 1;
    const batchId = `batch_${String(batchNumber).padStart(2, "0")}`;
    const batchResultRoot = path.join(RESULT_ROOT, batchId);
    fs.mkdirSync(batchResultRoot, { recursive: true });
    const agentChunks = distribute(sessionChunks[sessionIndex], AGENTS_PER_SESSION);
    const shards = [];

    for (let agentIndex = 0; agentIndex < agentChunks.length; agentIndex += 1) {
      const agentNumber = agentIndex + 1;
      const inputRelative = `docs/gameplay/event_cg_situation_audit_batches/inputs/${batchId}_agent_${String(agentNumber).padStart(2, "0")}.json`;
      const resultRelative = `docs/gameplay/event_cg_situation_audit_batches/results/${batchId}/agent_${String(agentNumber).padStart(2, "0")}.json`;
      const payload = {
        version: 1,
        manifest_total: manifest.total,
        completed_prefix_count: COMPLETED_PREFIX_COUNT,
        batch_id: batchId,
        agent_id: `agent_${String(agentNumber).padStart(2, "0")}`,
        item_count: agentChunks[agentIndex].length,
        global_index_start: agentChunks[agentIndex][0].global_index,
        global_index_end: agentChunks[agentIndex].at(-1).global_index,
        items: agentChunks[agentIndex],
      };
      fs.writeFileSync(path.join(ROOT, inputRelative), `${JSON.stringify(payload, null, 2)}\n`);
      shards.push({
        agentNumber,
        items: agentChunks[agentIndex],
        prompt: shardPrompt(batchNumber, agentNumber, inputRelative, resultRelative, agentChunks[agentIndex].length),
      });
    }

    const documentRelative = `docs/gameplay/event_cg_situation_audit_batches/${batchId}.md`;
    fs.writeFileSync(path.join(ROOT, documentRelative), sessionDocument(batchNumber, shards));
    sessionPromptBlocks.push(`### ${batchId}\n\n\`\`\`text\n${mainSessionPrompt(batchNumber, documentRelative)}\n\`\`\``);
    indexRows.push(`| ${batchId} | ${sessionChunks[sessionIndex][0].global_index}-${sessionChunks[sessionIndex].at(-1).global_index} | ${sessionChunks[sessionIndex].length} | 4 |`);
  }

  const readme = [
    "# 이벤트 CG 상황검수 분할 배치",
    "",
    `- manifest 전체: ${manifest.total}장`,
    `- 기존 완료: ${COMPLETED_PREFIX_COUNT}장`,
    `- 분할 검사 대상: ${remaining.length}장`,
    `- 상위 세션: ${SESSION_COUNT}개`,
    `- 세션별 서브에이전트: ${AGENTS_PER_SESSION}개`,
    `- 전체 shard: ${SESSION_COUNT * AGENTS_PER_SESSION}개`,
    "",
    "| 배치 | global index | 이미지 수 | 서브에이전트 |",
    "|---|---:|---:|---:|",
    ...indexRows,
    "",
    "각 배치 세션은 자기 결과 폴더만 작성한다. 모든 배치가 끝나기 전에는 `review_state.json`과 마스터 보고서를 수정하지 않는다.",
    "",
  ].join("\n");
  fs.writeFileSync(path.join(OUTPUT_ROOT, "README.md"), readme);
  fs.writeFileSync(path.join(OUTPUT_ROOT, "session_prompts.md"), `# 상위 세션용 프롬프트\n\n${sessionPromptBlocks.join("\n\n")}\n`);
  fs.writeFileSync(path.join(OUTPUT_ROOT, "merge_prompt.md"), `# 최종 병합 세션 프롬프트\n\n\`\`\`text\n${mergePrompt()}\n\`\`\`\n`);

  console.log(JSON.stringify({
    manifest_total: manifest.total,
    completed_prefix_count: COMPLETED_PREFIX_COUNT,
    remaining_count: remaining.length,
    session_count: SESSION_COUNT,
    agents_per_session: AGENTS_PER_SESSION,
    shard_count: SESSION_COUNT * AGENTS_PER_SESSION,
  }, null, 2));
}


main().catch((error) => {
  console.error(error.stack || error.message);
  process.exit(1);
});

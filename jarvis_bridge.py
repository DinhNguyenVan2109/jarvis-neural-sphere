#!/usr/bin/env python3
"""
J.A.R.V.I.S. <-> Antigravity Live Neural Telemetry & Prompt Bridge Daemon (Python)
Zero external dependencies, cross-platform (Linux / macOS / Windows).
Serves:
  - GET  /api/brain   -> Returns real-time connectome telemetry from Antigravity session transcript
  - POST /api/prompt  -> Receives user prompts from 3D interface and queues to pending_prompt.json
  - GET  /*           -> Serves index.html, static assets for full standalone 3D hologram web interface
"""

import sys
import os
import json
import math
import glob
import re
from datetime import datetime
from http.server import HTTPServer, SimpleHTTPRequestHandler

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 18765
REPO_ROOT = os.path.dirname(os.path.abspath(__file__))
FALLBACK_TRANSCRIPT = os.path.join(REPO_ROOT, "conversation_history", "transcript_sanitized.jsonl")
PENDING_PROMPT_FILE = os.path.join(REPO_ROOT, "pending_prompt.json")
HOOK_STATE_FILE = os.path.join(REPO_ROOT, "live_hook_state.json")

def find_latest_transcript():
    # 1. Check user profile / home directory for active transcript
    home = os.path.expanduser("~")
    search_patterns = [
        os.path.join(home, ".gemini", "antigravity", "brain", "*", ".system_generated", "logs", "transcript.jsonl"),
        os.path.join(home, ".gemini", "jetski", "brain", "**", ".system_generated", "logs", "transcript.jsonl"),
        os.path.join(home, ".gemini", "**", "transcript.jsonl"),
    ]
    candidates = []
    for pat in search_patterns:
        for p in glob.glob(pat, recursive=True):
            if os.path.isfile(p):
                candidates.append((os.path.getmtime(p), p))
    
    if candidates:
        candidates.sort(reverse=True)
        return candidates[0][1]

    # 2. Fallback to conversation_history
    if os.path.isfile(FALLBACK_TRANSCRIPT):
        return FALLBACK_TRANSCRIPT
    return None

def get_brain_state():
    transcript_path = find_latest_transcript()
    if not transcript_path or not os.path.isfile(transcript_path):
        return {"ok": False, "error": "No transcript found"}

    conv_id = "892a432f-aae3-45a6-b0ef-94186749a067"
    try:
        parts = os.path.abspath(transcript_path).split(os.sep)
        if ".system_generated" in parts:
            idx = parts.index(".system_generated")
            if idx > 0:
                conv_id = parts[idx - 1]
    except Exception:
        pass

    try:
        mtime = os.path.getmtime(transcript_path)
        last_mod_str = datetime.fromtimestamp(mtime).isoformat()
    except Exception:
        last_mod_str = datetime.now().isoformat()

    lines = []
    try:
        with open(transcript_path, "r", encoding="utf-8", errors="ignore") as f:
            lines = [l.strip() for l in f if l.strip()]
    except Exception as e:
        return {"ok": False, "error": str(e)}

    total_steps = len(lines)
    tool_counts = {
        "read_file": 0,
        "edit_file": 0,
        "write_file": 0,
        "run_command": 0,
        "search_web": 0,
        "invoke_subagent": 0,
        "mcp": 0
    }
    activated_skills = {}
    recent_turns = []

    latest_user_prompt = ""
    latest_thinking = ""
    latest_response = ""
    latest_tool_name = ""
    latest_tool_summary = ""
    latest_step_index = 0
    latest_step_type = ""
    latest_status = "IDLE"
    last_input_tokens = 0
    last_cache_tokens = 0
    last_output_tokens = 0

    turn_counter = 0

    for line in lines:
        try:
            step = json.loads(line)
        except Exception:
            continue

        latest_step_index = step.get("step_index", latest_step_index)
        latest_step_type = step.get("type", latest_step_type)
        latest_status = step.get("status", latest_status)

        if "input_tokens" in step:
            last_input_tokens = step["input_tokens"]
        if "cache_read_tokens" in step:
            last_cache_tokens = step["cache_read_tokens"]
        if "output_tokens" in step:
            last_output_tokens = step["output_tokens"]

        if step.get("type") == "USER_INPUT" and step.get("content"):
            content = step["content"]
            # Clean metadata and tags
            content = re.sub(r"(?s)<ADDITIONAL_METADATA>.*?</ADDITIONAL_METADATA>", "", content)
            content = content.replace("<USER_REQUEST>", "").replace("</USER_REQUEST>", "")
            content = " ".join(content.split()).strip()
            if content:
                latest_user_prompt = content
                turn_counter += 1
                short_summary = (content[:44] + "...") if len(content) > 44 else content
                recent_turns.append({
                    "turn": turn_counter,
                    "step": step.get("step_index", 0),
                    "text": short_summary,
                    "timestamp": step.get("created_at", "")
                })

        if step.get("type") == "PLANNER_RESPONSE":
            if step.get("thinking"):
                ct = " ".join(step["thinking"].split()).strip()
                if ct:
                    latest_thinking = (ct[:190] + "...") if len(ct) > 190 else ct
            if step.get("content"):
                cr = " ".join(step["content"].split()).strip()
                if cr:
                    latest_response = (cr[:190] + "...") if len(cr) > 190 else cr
            
            tool_calls = step.get("tool_calls", [])
            if tool_calls:
                for tc in tool_calls:
                    t_name = tc.get("name", "")
                    if not t_name:
                        continue
                    latest_tool_name = t_name
                    if t_name in tool_counts:
                        tool_counts[t_name] += 1
                    elif t_name.startswith("mcp_") or t_name == "mcp":
                        tool_counts["mcp"] += 1
                    elif "replace_file_content" in t_name:
                        tool_counts["edit_file"] += 1
                    elif "view_file" in t_name or "read" in t_name:
                        tool_counts["read_file"] += 1
                    elif "write" in t_name:
                        tool_counts["write_file"] += 1
                    elif "command" in t_name:
                        tool_counts["run_command"] += 1

                    args_obj = tc.get("args") or tc.get("arguments") or {}
                    if isinstance(args_obj, dict):
                        if args_obj.get("toolSummary"):
                            latest_tool_summary = str(args_obj["toolSummary"]).strip('"')
                        elif args_obj.get("Path") or args_obj.get("AbsolutePath") or args_obj.get("TargetFile"):
                            p_str = str(args_obj.get("Path") or args_obj.get("AbsolutePath") or args_obj.get("TargetFile"))
                            leaf = os.path.basename(p_str)
                            latest_tool_summary = f"{t_name} -> {leaf}"
                            sk_match = re.search(r"skills[\\/]([^\\/]+)[\\/]", p_str)
                            if sk_match:
                                sk_name = sk_match.group(1)
                                activated_skills[sk_name] = activated_skills.get(sk_name, 0) + 1

    # Keep memory ring bounded to 8 slots
    bounded_memory = recent_turns[-8:] if len(recent_turns) > 8 else recent_turns

    active_set = {0, 5}
    # Check tail steps for active regions
    tail_steps = lines[-4:] if len(lines) >= 4 else lines
    current_turn_tools = 0
    for l in tail_steps:
        try:
            s = json.loads(l)
            for tc in s.get("tool_calls", []):
                current_turn_tools += 1
                tn = tc.get("name", "")
                if tn in ("read_file", "view_file"):
                    active_set.add(1)
                elif tn in ("edit_file", "replace_file_content", "write_to_file", "write_file"):
                    active_set.add(2)
                elif tn in ("run_command", "manage_task"):
                    active_set.add(3)
                elif "skill" in tn or "lookup_skill" in tn:
                    active_set.add(4)
                elif tn in ("search_web", "google_search", "invoke_subagent", "mcp"):
                    active_set.add(6)
        except Exception:
            pass

    skill_total = sum(activated_skills.values())

    # Log-Saturated Hebbian Weights (Homeostatic)
    hebbian_weights = [
        round(min(1.55, 0.55 + math.log10(1 + total_steps) * 0.32), 3),
        round(min(1.55, 0.35 + math.log10(1 + tool_counts["read_file"]) * 0.50), 3),
        round(min(1.55, 0.35 + math.log10(1 + tool_counts["edit_file"] + tool_counts["write_file"]) * 0.55), 3),
        round(min(1.55, 0.35 + math.log10(1 + tool_counts["run_command"]) * 0.50), 3),
        round(min(1.55, 0.35 + math.log10(1 + skill_total) * 0.60), 3),
        round(min(1.55, 0.45 + math.log10(1 + turn_counter) * 0.50), 3),
        round(min(1.55, 0.35 + math.log10(1 + tool_counts["search_web"] + tool_counts["invoke_subagent"] + tool_counts["mcp"]) * 0.60), 3)
    ]

    model_name = "Antigravity Active LLM"
    if os.path.isfile(HOOK_STATE_FILE):
        try:
            with open(HOOK_STATE_FILE, "r", encoding="utf-8") as f:
                hk = json.load(f)
                if hk.get("modelName"):
                    model_name = hk["modelName"]
        except Exception:
            pass

    pending_text = ""
    if os.path.isfile(PENDING_PROMPT_FILE):
        try:
            with open(PENDING_PROMPT_FILE, "r", encoding="utf-8") as f:
                pp = json.load(f)
                pending_text = pp.get("prompt", "")
        except Exception:
            pass

    skills_list = [{"name": k, "count": v} for k, v in activated_skills.items()]

    return {
        "ok": True,
        "conversationId": conv_id,
        "modelName": model_name,
        "totalSteps": total_steps,
        "totalTurns": turn_counter,
        "currentTurnToolCalls": current_turn_tools,
        "tokens": {
            "input": last_input_tokens,
            "cache": last_cache_tokens,
            "output": last_output_tokens
        },
        "pendingPrompt": pending_text,
        "lastModified": last_mod_str,
        "latestStep": {
            "index": latest_step_index,
            "type": latest_step_type,
            "status": latest_status,
            "userPrompt": latest_user_prompt,
            "thinking": latest_thinking,
            "toolName": latest_tool_name,
            "toolSummary": latest_tool_summary,
            "response": latest_response
        },
        "activeRegions": sorted(list(active_set)),
        "hebbianWeights": hebbian_weights,
        "toolCounts": tool_counts,
        "activatedSkills": skills_list,
        "memoryRing": bounded_memory
    }

class JarvisBridgeHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=REPO_ROOT, **kwargs)

    def do_OPTIONS(self):
        self.send_response(204)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.end_headers()

    def do_GET(self):
        if self.path == "/api/brain":
            data = get_brain_state()
            body = json.dumps(data).encode("utf-8")
            self.send_response(200)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.send_header("Content-Length", str(len(body)))
            self.send_header("Access-Control-Allow-Origin", "*")
            self.send_header("Cache-Control", "no-store, no-cache, must-revalidate")
            self.end_headers()
            self.wfile.write(body)
        elif self.path == "/":
            self.path = "/index.html"
            return super().do_GET()
        else:
            return super().do_GET()

    def do_POST(self):
        if self.path == "/api/prompt":
            try:
                length = int(self.headers.get("Content-Length", 0))
                raw_body = self.rfile.read(length).decode("utf-8")
                payload = json.loads(raw_body)
                prompt_text = payload.get("prompt", "")
                if prompt_text:
                    with open(PENDING_PROMPT_FILE, "w", encoding="utf-8") as f:
                        json.dump({
                            "prompt": prompt_text,
                            "timestamp": datetime.now().isoformat()
                        }, f, indent=2)
                res_body = b'{"ok":true,"queued":true}'
            except Exception as e:
                res_body = json.dumps({"ok": False, "error": str(e)}).encode("utf-8")

            self.send_response(200)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.send_header("Content-Length", str(len(res_body)))
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(res_body)
        else:
            self.send_response(404)
            self.end_headers()

def run_server():
    server_address = ("0.0.0.0", PORT)
    httpd = HTTPServer(server_address, JarvisBridgeHandler)
    print(f"✦ J.A.R.V.I.S. Neural Bridge running on http://127.0.0.1:{PORT}")
    print(f"✦ Telemetry API: http://127.0.0.1:{PORT}/api/brain")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        httpd.server_close()

if __name__ == "__main__":
    run_server()

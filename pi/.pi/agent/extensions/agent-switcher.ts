import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import type { AutocompleteItem } from "@mariozechner/pi-tui";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { homedir } from "node:os";

type AgentName = "default" | "general" | "writing";

const AGENT_NAMES: AgentName[] = ["default", "general", "writing"];
const AGENT_DIR = join(homedir(), ".pi", "agent");
const STATE_FILE = join(AGENT_DIR, "active-agent.json");
const PROFILE_SYSTEM_FILES: Partial<Record<AgentName, string>> = {
	general: join(AGENT_DIR, "general", "SYSTEM.md"),
	writing: join(AGENT_DIR, "writing", "SYSTEM.md"),
};
const READ_ONLY_TOOLS = ["read", "grep", "find", "ls", "web_search", "websearch", "view_video"];
const DEFAULT_TOOL_FALLBACK = ["read", "bash", "edit", "write", "web_search", "websearch", "view_video"];

function readActiveAgent(): AgentName {
	try {
		const parsed = JSON.parse(readFileSync(STATE_FILE, "utf8")) as { active?: string };
		return AGENT_NAMES.includes(parsed.active as AgentName) ? (parsed.active as AgentName) : "default";
	} catch {
		return "default";
	}
}

function writeActiveAgent(active: AgentName) {
	mkdirSync(dirname(STATE_FILE), { recursive: true });
	writeFileSync(STATE_FILE, `${JSON.stringify({ active }, null, "\t")}\n`, "utf8");
}

function readProfileSystemPrompt(profile: AgentName): string {
	const systemFile = PROFILE_SYSTEM_FILES[profile];
	if (!systemFile) return "";
	if (!existsSync(systemFile)) {
		throw new Error(`Missing ${systemFile}`);
	}
	return readFileSync(systemFile, "utf8");
}

function isReadOnlyProfile(profile: AgentName): boolean {
	return profile !== "default";
}

export default function (pi: ExtensionAPI) {
	let activeAgent = readActiveAgent();
	let defaultActiveTools: string[] | undefined;

	function availableToolNames(names: string[]): string[] {
		const available = new Set(pi.getAllTools().map((tool) => tool.name));
		return names.filter((name) => available.has(name));
	}

	function applyActiveAgentTools() {
		if (isReadOnlyProfile(activeAgent)) {
			const current = pi.getActiveTools();
			if (current.some((name) => !READ_ONLY_TOOLS.includes(name))) {
				defaultActiveTools = current;
			}
			pi.setActiveTools(availableToolNames(READ_ONLY_TOOLS));
			return;
		}

		pi.setActiveTools(availableToolNames(defaultActiveTools ?? DEFAULT_TOOL_FALLBACK));
	}

	function setStatus(ctx: { ui: { setStatus: (key: string, value: string) => void } }) {
		ctx.ui.setStatus("agent", isReadOnlyProfile(activeAgent) ? `agent: ${activeAgent} (read-only)` : `agent: ${activeAgent}`);
	}

	pi.on("session_start", async (_event, ctx) => {
		activeAgent = readActiveAgent();
		applyActiveAgentTools();
		setStatus(ctx);
	});

	pi.on("before_agent_start", async (event) => {
		activeAgent = readActiveAgent();
		applyActiveAgentTools();
		if (!isReadOnlyProfile(activeAgent)) return;

		const profilePrompt = readProfileSystemPrompt(activeAgent).trim();
		return {
			systemPrompt: `${profilePrompt}\n\nThe following Pi runtime, tool, context-file, and safety instructions still apply:\n\n${event.systemPrompt}`,
			message: {
				customType: "agent-switcher",
				content: `Using agent profile: ${activeAgent}`,
				display: false,
			},
		};
	});

	pi.on("tool_call", async (event) => {
		activeAgent = readActiveAgent();
		if (!isReadOnlyProfile(activeAgent)) return;
		if (READ_ONLY_TOOLS.includes(event.toolName)) return;

		return {
			block: true,
			reason: `The ${activeAgent} agent profile is read-only. Allowed tools: ${READ_ONLY_TOOLS.join(", ")}.`,
		};
	});

	pi.registerCommand("agent", {
		description: "Switch agent profile: default, general, or writing",
		getArgumentCompletions: (prefix: string): AutocompleteItem[] | null => {
			const items = AGENT_NAMES.filter((value) => value.startsWith(prefix));
			return items.length ? items.map((value) => ({ value, label: value })) : null;
		},
		handler: async (args, ctx) => {
			await ctx.waitForIdle();

			const requested = args.trim().toLowerCase();
			let next: AgentName | undefined;

			if (AGENT_NAMES.includes(requested as AgentName)) {
				next = requested as AgentName;
			} else if (!requested) {
				const choice = await ctx.ui.select("Select agent profile", AGENT_NAMES);
				if (AGENT_NAMES.includes(choice as AgentName)) next = choice as AgentName;
			} else {
				ctx.ui.notify(`Usage: /agent ${AGENT_NAMES.join("|")}`, "error");
				return;
			}

			if (!next) return;
			const systemFile = PROFILE_SYSTEM_FILES[next];
			if (systemFile && !existsSync(systemFile)) {
				ctx.ui.notify(`Missing ${systemFile}`, "error");
				return;
			}

			activeAgent = next;
			writeActiveAgent(activeAgent);
			applyActiveAgentTools();
			setStatus(ctx);
			ctx.ui.notify(`Switched to ${activeAgent} agent. The next prompt will use it.`, "info");
		},
	});
}

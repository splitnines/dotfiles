import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Type } from "typebox";

const USER_AGENT =
	"Mozilla/5.0 (compatible; pi-web-search/1.0; +https://pi.dev)";

type SearchParams = {
	query: string;
	maxResults?: number;
};

type SearchResult = {
	title: string;
	url: string;
	snippet: string;
};

const searchParameters = Type.Object({
	query: Type.String({ description: "Search query" }),
	maxResults: Type.Optional(
		Type.Integer({
			description: "Maximum number of results to return (1-10). Defaults to 5.",
			minimum: 1,
			maximum: 10,
		}),
	),
});

function decodeHtml(text: string): string {
	return text
		.replace(/&amp;/g, "&")
		.replace(/&lt;/g, "<")
		.replace(/&gt;/g, ">")
		.replace(/&quot;/g, '"')
		.replace(/&#39;|&apos;/g, "'")
		.replace(/&#x([0-9a-f]+);/gi, (_match, hex) => String.fromCodePoint(Number.parseInt(hex, 16)))
		.replace(/&#(\d+);/g, (_match, num) => String.fromCodePoint(Number.parseInt(num, 10)));
}

function stripHtml(html: string): string {
	return decodeHtml(html.replace(/<[^>]*>/g, " "))
		.replace(/\s+/g, " ")
		.trim();
}

function normalizeDuckDuckGoUrl(rawUrl: string): string {
	let url = decodeHtml(rawUrl.trim());
	if (url.startsWith("//")) url = `https:${url}`;

	try {
		const parsed = new URL(url);
		const uddg = parsed.searchParams.get("uddg");
		if (uddg) return uddg;
		return parsed.toString();
	} catch {
		return url;
	}
}

function parseDuckDuckGoHtml(html: string, maxResults: number): SearchResult[] {
	const links = [...html.matchAll(/<a[^>]+class="result__a"[^>]+href="([^"]+)"[^>]*>([\s\S]*?)<\/a>/g)];
	const snippets = [...html.matchAll(/<a[^>]+class="result__snippet"[^>]*>([\s\S]*?)<\/a>/g)];
	const results: SearchResult[] = [];
	const seen = new Set<string>();

	for (let i = 0; i < links.length && results.length < maxResults; i++) {
		const link = links[i];
		const url = normalizeDuckDuckGoUrl(link[1] ?? "");
		if (!url || seen.has(url)) continue;
		seen.add(url);

		results.push({
			title: stripHtml(link[2] ?? "Untitled"),
			url,
			snippet: stripHtml(snippets[i]?.[1] ?? ""),
		});
	}

	return results;
}

async function duckDuckGoSearch(query: string, maxResults: number, signal?: AbortSignal): Promise<SearchResult[]> {
	const url = `https://html.duckduckgo.com/html/?${new URLSearchParams({ q: query }).toString()}`;
	const response = await fetch(url, {
		signal,
		headers: {
			"user-agent": USER_AGENT,
			accept: "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
		},
	});

	if (!response.ok) {
		throw new Error(`DuckDuckGo search failed: HTTP ${response.status}`);
	}

	return parseDuckDuckGoHtml(await response.text(), maxResults);
}

function formatResults(results: SearchResult[]): string {
	if (results.length === 0) return "No search results found.";
	return results
		.map((result, index) => {
			const snippet = result.snippet ? `\n   ${result.snippet}` : "";
			return `${index + 1}. ${result.title}\n   ${result.url}${snippet}`;
		})
		.join("\n\n");
}

export default function (pi: ExtensionAPI) {
	async function executeSearch(_toolCallId: string, params: SearchParams, signal?: AbortSignal) {
		const query = params.query.trim();
		if (!query) throw new Error("Query must not be empty.");

		const maxResults = Math.min(Math.max(params.maxResults ?? 5, 1), 10);
		const results = await duckDuckGoSearch(query, maxResults, signal);

		return {
			content: [{ type: "text" as const, text: formatResults(results) }],
			details: { query, maxResults, results, provider: "duckduckgo-html" },
		};
	}

	const common = {
		label: "Web Search",
		description: "Search the web for current information. Returns a concise list of result titles, URLs, and snippets.",
		promptSnippet: "Search the web for current or external information",
		promptGuidelines: [
			"Use web_search when the user asks for current, recent, or external information that may not be in local files or model knowledge.",
			"Cite URLs from web_search results when using web search information in the final answer.",
		],
		parameters: searchParameters,
	};

	pi.registerTool({
		...common,
		name: "web_search",
		async execute(toolCallId, params: SearchParams, signal) {
			return executeSearch(toolCallId, params, signal);
		},
	});

	// Backwards-compatible alias for existing agent profiles/configs that allow "websearch".
	pi.registerTool({
		...common,
		name: "websearch",
		async execute(toolCallId, params: SearchParams, signal) {
			return executeSearch(toolCallId, params, signal);
		},
	});
}

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Type } from "typebox";
import { execFile } from "node:child_process";
import { mkdtemp, readFile, rm, stat } from "node:fs/promises";
import { homedir, tmpdir } from "node:os";
import { basename, isAbsolute, join, resolve } from "node:path";

const videoParameters = Type.Object({
	path: Type.String({ description: "Path to the video file to inspect (relative, absolute, or ~/...)" }),
	sampleCount: Type.Optional(
		Type.Integer({
			description: "Number of representative frames to extract. Defaults to 8. Maximum 20.",
			minimum: 1,
			maximum: 20,
		}),
	),
	startSeconds: Type.Optional(
		Type.Number({ description: "Start sampling at this timestamp in seconds. Defaults to 0.", minimum: 0 }),
	),
	durationSeconds: Type.Optional(
		Type.Number({ description: "Only sample this many seconds from startSeconds. Defaults to the rest of the video.", minimum: 0.1 }),
	),
	maxWidth: Type.Optional(
		Type.Integer({ description: "Maximum extracted frame width in pixels. Defaults to 768. Maximum 1280.", minimum: 160, maximum: 1280 }),
	),
});

type VideoParams = {
	path: string;
	sampleCount?: number;
	startSeconds?: number;
	durationSeconds?: number;
	maxWidth?: number;
};

type ProbeInfo = {
	format?: { duration?: string; format_name?: string; bit_rate?: string };
	streams?: Array<{
		codec_type?: string;
		codec_name?: string;
		width?: number;
		height?: number;
		duration?: string;
		avg_frame_rate?: string;
	}>;
};

function resolveInputPath(input: string, cwd: string): string {
	const expanded = input === "~" ? homedir() : input.startsWith("~/") ? join(homedir(), input.slice(2)) : input;
	return isAbsolute(expanded) ? expanded : resolve(cwd, expanded);
}

function execFileText(command: string, args: string[], signal?: AbortSignal, timeout = 30_000): Promise<string> {
	return new Promise((resolvePromise, reject) => {
		execFile(command, args, { encoding: "utf8", signal, timeout, maxBuffer: 10 * 1024 * 1024 }, (error, stdout, stderr) => {
			if (error) {
				const message = stderr?.trim() || error.message;
				reject(new Error(`${command} failed: ${message}`));
				return;
			}
			resolvePromise(stdout);
		});
	});
}

function parseDuration(info: ProbeInfo): number | undefined {
	const candidates = [
		info.format?.duration,
		...(info.streams ?? []).map((stream) => stream.duration),
	];
	for (const candidate of candidates) {
		const value = candidate === undefined ? Number.NaN : Number(candidate);
		if (Number.isFinite(value) && value > 0) return value;
	}
	return undefined;
}

function clamp(value: number, min: number, max: number): number {
	return Math.min(Math.max(value, min), max);
}

function formatSeconds(value: number): string {
	return `${value.toFixed(2)}s`;
}

function frameTimes(duration: number | undefined, start: number, requestedDuration: number | undefined, count: number): number[] {
	if (!duration) {
		return Array.from({ length: count }, (_unused, index) => start + index);
	}

	const safeStart = clamp(start, 0, Math.max(duration - 0.05, 0));
	const available = Math.max(duration - safeStart, 0.05);
	const span = clamp(requestedDuration ?? available, 0.05, available);
	const end = Math.min(safeStart + span, Math.max(duration - 0.05, safeStart));
	if (count === 1) return [safeStart + (end - safeStart) / 2];

	return Array.from({ length: count }, (_unused, index) => safeStart + ((end - safeStart) * index) / (count - 1));
}

function describeVideo(path: string, info: ProbeInfo, times: number[], maxWidth: number): string {
	const video = (info.streams ?? []).find((stream) => stream.codec_type === "video");
	const audio = (info.streams ?? []).find((stream) => stream.codec_type === "audio");
	const duration = parseDuration(info);
	const dimensions = video?.width && video?.height ? `${video.width}x${video.height}` : "unknown dimensions";
	const sampled = times.map(formatSeconds).join(", ");
	return [
		`Video frame sample for ${path}`,
		`File: ${basename(path)}`,
		`Duration: ${duration ? formatSeconds(duration) : "unknown"}`,
		`Video: ${video?.codec_name ?? "unknown codec"}, ${dimensions}${video?.avg_frame_rate ? `, avg_frame_rate ${video.avg_frame_rate}` : ""}`,
		`Audio: ${audio?.codec_name ?? "none/unknown"}`,
		`Extracted ${times.length} JPEG frame(s), resized to max width ${maxWidth}px, at: ${sampled}`,
		"Use these image frames to answer the user's question about the video content. Mention that the description is based on sampled frames if temporal detail is uncertain.",
	].join("\n");
}

export default function (pi: ExtensionAPI) {
	pi.registerTool({
		name: "view_video",
		label: "View Video",
		description: "Inspect video content by extracting representative frames with ffmpeg and returning them as image attachments for visual analysis.",
		promptSnippet: "Extract representative frames from video files and view them as images",
		promptGuidelines: [
			"Use view_video when the user asks to watch, view, inspect, summarize, or describe a video file.",
			"After using view_video, describe visible content from the sampled frames and note uncertainty for motion or moments between frames.",
		],
		parameters: videoParameters,
		async execute(_toolCallId, params: VideoParams, signal, onUpdate, ctx) {
			const inputPath = resolveInputPath(params.path, ctx?.cwd ?? process.cwd());
			const sampleCount = clamp(Math.floor(params.sampleCount ?? 8), 1, 20);
			const startSeconds = Math.max(params.startSeconds ?? 0, 0);
			const maxWidth = clamp(Math.floor(params.maxWidth ?? 768), 160, 1280);

			const fileStat = await stat(inputPath);
			if (!fileStat.isFile()) throw new Error(`Not a file: ${inputPath}`);

			onUpdate?.({ content: [{ type: "text", text: `Probing video: ${inputPath}` }] });
			const probeJson = await execFileText(
				"ffprobe",
				["-v", "error", "-print_format", "json", "-show_format", "-show_streams", inputPath],
				signal,
			);
			const probe = JSON.parse(probeJson) as ProbeInfo;
			const times = frameTimes(parseDuration(probe), startSeconds, params.durationSeconds, sampleCount);

			const tempDir = await mkdtemp(join(tmpdir(), "pi-view-video-"));
			try {
				const content: Array<{ type: "text"; text: string } | { type: "image"; data: string; mimeType: string }> = [
					{ type: "text", text: describeVideo(inputPath, probe, times, maxWidth) },
				];
				const frames: Array<{ timestamp: number; file: string }> = [];

				for (let index = 0; index < times.length; index++) {
					const timestamp = Math.max(times[index], 0);
					const frameFile = join(tempDir, `frame-${String(index + 1).padStart(3, "0")}.png`);
					onUpdate?.({ content: [{ type: "text", text: `Extracting frame ${index + 1}/${times.length} at ${formatSeconds(timestamp)}` }] });
					await execFileText(
						"ffmpeg",
						[
							"-hide_banner",
							"-loglevel",
							"error",
							"-ss",
							timestamp.toFixed(3),
							"-i",
							inputPath,
							"-frames:v",
							"1",
							"-vf",
							`scale='min(${maxWidth},iw)':-2`,
							"-f",
							"image2",
							"-vcodec",
							"png",
							"-y",
							frameFile,
						],
						signal,
					);
					const image = await readFile(frameFile);
					content.push({ type: "text", text: `Frame ${index + 1} at ${formatSeconds(timestamp)}` });
					content.push({ type: "image", data: image.toString("base64"), mimeType: "image/png" });
					frames.push({ timestamp, file: frameFile });
				}

				return {
					content,
					details: {
						path: inputPath,
						bytes: fileStat.size,
						sampleCount: times.length,
						maxWidth,
						probe,
						frames: frames.map((frame) => ({ timestamp: frame.timestamp })),
					},
				};
			} finally {
				await rm(tempDir, { recursive: true, force: true });
			}
		},
	});
}

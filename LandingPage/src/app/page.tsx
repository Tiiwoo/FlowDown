import Image from "next/image";
import Link from "next/link";

export default function Home() {
  return (
    <main className="relative min-h-screen overflow-hidden">
      {/* Background gradient */}
      <div className="pointer-events-none fixed inset-0 -z-10">
        <div className="absolute inset-0 bg-gradient-to-br from-slate-50 via-blue-50/30 to-indigo-50/50 dark:from-slate-950 dark:via-slate-900 dark:to-indigo-950/30" />
        <div className="absolute top-0 right-0 h-[600px] w-[600px] rounded-full bg-gradient-to-br from-blue-400/20 to-purple-500/20 blur-3xl dark:from-blue-500/10 dark:to-purple-600/10" />
        <div className="absolute bottom-0 left-0 h-[500px] w-[500px] rounded-full bg-gradient-to-tr from-emerald-400/20 to-cyan-500/20 blur-3xl dark:from-emerald-500/10 dark:to-cyan-600/10" />
      </div>

      {/* Navigation */}
      <nav className="fixed top-0 right-0 left-0 z-50 border-b border-slate-200/50 bg-white/70 backdrop-blur-xl dark:border-slate-800/50 dark:bg-slate-950/70">
        <div className="mx-auto flex h-16 max-w-6xl items-center justify-between px-6">
          <Link href="/" className="flex items-center gap-2">
            <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-gradient-to-br from-blue-500 to-indigo-600 shadow-lg shadow-blue-500/25">
              <span className="text-lg font-bold text-white">F</span>
            </div>
            <span className="text-xl font-semibold tracking-tight text-slate-900 dark:text-white">
              FlowDown
            </span>
          </Link>

          <div className="flex items-center gap-6">
            <Link
              href="#features"
              className="text-sm font-medium text-slate-600 transition-colors hover:text-slate-900 dark:text-slate-400 dark:hover:text-white"
            >
              Features
            </Link>
            <Link
              href="#privacy"
              className="text-sm font-medium text-slate-600 transition-colors hover:text-slate-900 dark:text-slate-400 dark:hover:text-white"
            >
              Privacy
            </Link>
            <Link
              href="https://github.com/aspect-apps/FlowDown"
              target="_blank"
              rel="noopener noreferrer"
              className="text-sm font-medium text-slate-600 transition-colors hover:text-slate-900 dark:text-slate-400 dark:hover:text-white"
            >
              GitHub
            </Link>
            <Link
              href="#download"
              className="rounded-full bg-slate-900 px-4 py-2 text-sm font-medium text-white shadow-lg shadow-slate-900/25 transition-all hover:scale-105 hover:bg-slate-800 dark:bg-white dark:text-slate-900 dark:shadow-white/25 dark:hover:bg-slate-100"
            >
              Download
            </Link>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <section className="flex min-h-screen flex-col items-center justify-center px-6 pt-16">
        <div className="mx-auto max-w-4xl text-center">
          {/* Badge */}
          <div className="mb-8 inline-flex items-center gap-2 rounded-full border border-slate-200 bg-white/80 px-4 py-1.5 text-sm shadow-sm backdrop-blur dark:border-slate-800 dark:bg-slate-900/80">
            <span className="h-2 w-2 animate-pulse rounded-full bg-emerald-500" />
            <span className="text-slate-600 dark:text-slate-400">
              Available on iOS & macOS
            </span>
          </div>

          {/* Headline */}
          <h1 className="mb-6 bg-gradient-to-br from-slate-900 via-slate-800 to-slate-700 bg-clip-text text-5xl leading-tight font-bold tracking-tight text-transparent sm:text-6xl lg:text-7xl dark:from-white dark:via-slate-200 dark:to-slate-400">
            AI Chat,
            <br />
            <span className="bg-gradient-to-r from-blue-600 via-indigo-600 to-purple-600 bg-clip-text text-transparent">
              Privacy First
            </span>
          </h1>

          {/* Subheadline */}
          <p className="mx-auto mb-10 max-w-2xl text-lg leading-relaxed text-slate-600 sm:text-xl dark:text-slate-400">
            A beautiful, native AI client for Apple platforms. Connect to
            multiple providers, run models locally with MLX, and keep your
            conversations private.
          </p>

          {/* CTA Buttons */}
          <div className="flex flex-col items-center justify-center gap-4 sm:flex-row">
            <Link
              href="#download"
              className="group flex items-center gap-2 rounded-2xl bg-slate-900 px-8 py-4 text-lg font-semibold text-white shadow-2xl shadow-slate-900/30 transition-all hover:scale-105 hover:shadow-slate-900/40 dark:bg-white dark:text-slate-900 dark:shadow-white/20"
            >
              <svg className="h-6 w-6" fill="currentColor" viewBox="0 0 24 24">
                <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z" />
              </svg>
              Download for Free
              <svg
                className="h-5 w-5 transition-transform group-hover:translate-x-1"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M17 8l4 4m0 0l-4 4m4-4H3"
                />
              </svg>
            </Link>

            <Link
              href="https://github.com/aspect-apps/FlowDown"
              target="_blank"
              rel="noopener noreferrer"
              className="flex items-center gap-2 rounded-2xl border border-slate-200 bg-white/80 px-8 py-4 text-lg font-semibold text-slate-700 backdrop-blur transition-all hover:scale-105 hover:border-slate-300 hover:bg-white dark:border-slate-800 dark:bg-slate-900/80 dark:text-slate-300 dark:hover:border-slate-700 dark:hover:bg-slate-900"
            >
              <svg className="h-6 w-6" fill="currentColor" viewBox="0 0 24 24">
                <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z" />
              </svg>
              View on GitHub
            </Link>
          </div>
        </div>

        {/* App Preview */}
        <div className="relative mt-16 w-full max-w-5xl px-6">
          <div className="relative overflow-hidden rounded-3xl border border-slate-200/50 bg-gradient-to-b from-white to-slate-50 p-2 shadow-2xl shadow-slate-900/10 dark:border-slate-800/50 dark:from-slate-900 dark:to-slate-950 dark:shadow-black/30">
            <div className="aspect-[16/10] w-full overflow-hidden rounded-2xl bg-gradient-to-br from-slate-100 to-slate-200 dark:from-slate-800 dark:to-slate-900">
              {/* Placeholder for app screenshot */}
              <div className="flex h-full w-full items-center justify-center">
                <p className="text-lg text-slate-400 dark:text-slate-600">
                  App Screenshot
                </p>
              </div>
            </div>
          </div>
          {/* Glow effect */}
          <div className="absolute -inset-4 -z-10 rounded-[2rem] bg-gradient-to-r from-blue-500/20 via-purple-500/20 to-pink-500/20 opacity-50 blur-2xl" />
        </div>
      </section>

      {/* Features Section */}
      <section id="features" className="py-32">
        <div className="mx-auto max-w-6xl px-6">
          <div className="mb-16 text-center">
            <h2 className="mb-4 text-4xl font-bold tracking-tight text-slate-900 sm:text-5xl dark:text-white">
              Everything you need
            </h2>
            <p className="mx-auto max-w-2xl text-lg text-slate-600 dark:text-slate-400">
              Powerful features designed for privacy-conscious users who want
              the best AI experience.
            </p>
          </div>

          <div className="grid gap-8 md:grid-cols-2 lg:grid-cols-3">
            {/* Feature 1 */}
            <div className="group rounded-3xl border border-slate-200/50 bg-white/50 p-8 backdrop-blur transition-all hover:border-slate-300 hover:bg-white hover:shadow-xl hover:shadow-slate-900/5 dark:border-slate-800/50 dark:bg-slate-900/50 dark:hover:border-slate-700 dark:hover:bg-slate-900">
              <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-2xl bg-gradient-to-br from-blue-500 to-indigo-600 shadow-lg shadow-blue-500/25">
                <svg
                  className="h-6 w-6 text-white"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"
                  />
                </svg>
              </div>
              <h3 className="mb-2 text-xl font-semibold text-slate-900 dark:text-white">
                Privacy First
              </h3>
              <p className="text-slate-600 dark:text-slate-400">
                Your API keys stay on your device. No accounts, no tracking,
                just pure privacy.
              </p>
            </div>

            {/* Feature 2 */}
            <div className="group rounded-3xl border border-slate-200/50 bg-white/50 p-8 backdrop-blur transition-all hover:border-slate-300 hover:bg-white hover:shadow-xl hover:shadow-slate-900/5 dark:border-slate-800/50 dark:bg-slate-900/50 dark:hover:border-slate-700 dark:hover:bg-slate-900">
              <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-2xl bg-gradient-to-br from-emerald-500 to-teal-600 shadow-lg shadow-emerald-500/25">
                <svg
                  className="h-6 w-6 text-white"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"
                  />
                </svg>
              </div>
              <h3 className="mb-2 text-xl font-semibold text-slate-900 dark:text-white">
                Local Inference
              </h3>
              <p className="text-slate-600 dark:text-slate-400">
                Run models locally with Apple MLX. Complete offline capability
                for sensitive work.
              </p>
            </div>

            {/* Feature 3 */}
            <div className="group rounded-3xl border border-slate-200/50 bg-white/50 p-8 backdrop-blur transition-all hover:border-slate-300 hover:bg-white hover:shadow-xl hover:shadow-slate-900/5 dark:border-slate-800/50 dark:bg-slate-900/50 dark:hover:border-slate-700 dark:hover:bg-slate-900">
              <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-2xl bg-gradient-to-br from-purple-500 to-pink-600 shadow-lg shadow-purple-500/25">
                <svg
                  className="h-6 w-6 text-white"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M4 5a1 1 0 011-1h14a1 1 0 011 1v2a1 1 0 01-1 1H5a1 1 0 01-1-1V5zM4 13a1 1 0 011-1h6a1 1 0 011 1v6a1 1 0 01-1 1H5a1 1 0 01-1-1v-6zM16 13a1 1 0 011-1h2a1 1 0 011 1v6a1 1 0 01-1 1h-2a1 1 0 01-1-1v-6z"
                  />
                </svg>
              </div>
              <h3 className="mb-2 text-xl font-semibold text-slate-900 dark:text-white">
                Multi-Provider
              </h3>
              <p className="text-slate-600 dark:text-slate-400">
                OpenAI, Claude, Gemini, and more. Switch between providers
                seamlessly.
              </p>
            </div>

            {/* Feature 4 */}
            <div className="group rounded-3xl border border-slate-200/50 bg-white/50 p-8 backdrop-blur transition-all hover:border-slate-300 hover:bg-white hover:shadow-xl hover:shadow-slate-900/5 dark:border-slate-800/50 dark:bg-slate-900/50 dark:hover:border-slate-700 dark:hover:bg-slate-900">
              <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-2xl bg-gradient-to-br from-orange-500 to-red-600 shadow-lg shadow-orange-500/25">
                <svg
                  className="h-6 w-6 text-white"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M7 21a4 4 0 01-4-4V5a2 2 0 012-2h4a2 2 0 012 2v12a4 4 0 01-4 4zm0 0h12a2 2 0 002-2v-4a2 2 0 00-2-2h-2.343M11 7.343l1.657-1.657a2 2 0 012.828 0l2.829 2.829a2 2 0 010 2.828l-8.486 8.485M7 17h.01"
                  />
                </svg>
              </div>
              <h3 className="mb-2 text-xl font-semibold text-slate-900 dark:text-white">
                Native Experience
              </h3>
              <p className="text-slate-600 dark:text-slate-400">
                Built with Swift for iOS and macOS. Fast, beautiful, and feels
                right at home.
              </p>
            </div>

            {/* Feature 5 */}
            <div className="group rounded-3xl border border-slate-200/50 bg-white/50 p-8 backdrop-blur transition-all hover:border-slate-300 hover:bg-white hover:shadow-xl hover:shadow-slate-900/5 dark:border-slate-800/50 dark:bg-slate-900/50 dark:hover:border-slate-700 dark:hover:bg-slate-900">
              <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-2xl bg-gradient-to-br from-cyan-500 to-blue-600 shadow-lg shadow-cyan-500/25">
                <svg
                  className="h-6 w-6 text-white"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M8 9l3 3-3 3m5 0h3M5 20h14a2 2 0 002-2V6a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"
                  />
                </svg>
              </div>
              <h3 className="mb-2 text-xl font-semibold text-slate-900 dark:text-white">
                MCP Support
              </h3>
              <p className="text-slate-600 dark:text-slate-400">
                Model Context Protocol support for advanced tool use and
                integrations.
              </p>
            </div>

            {/* Feature 6 */}
            <div className="group rounded-3xl border border-slate-200/50 bg-white/50 p-8 backdrop-blur transition-all hover:border-slate-300 hover:bg-white hover:shadow-xl hover:shadow-slate-900/5 dark:border-slate-800/50 dark:bg-slate-900/50 dark:hover:border-slate-700 dark:hover:bg-slate-900">
              <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-2xl bg-gradient-to-br from-rose-500 to-pink-600 shadow-lg shadow-rose-500/25">
                <svg
                  className="h-6 w-6 text-white"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"
                  />
                </svg>
              </div>
              <h3 className="mb-2 text-xl font-semibold text-slate-900 dark:text-white">
                Rich Editor
              </h3>
              <p className="text-slate-600 dark:text-slate-400">
                Markdown support, code highlighting, and a beautiful editing
                experience.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Privacy Section */}
      <section
        id="privacy"
        className="border-y border-slate-200/50 bg-gradient-to-b from-slate-50 to-white py-32 dark:border-slate-800/50 dark:from-slate-900 dark:to-slate-950"
      >
        <div className="mx-auto max-w-6xl px-6">
          <div className="grid items-center gap-16 lg:grid-cols-2">
            <div>
              <h2 className="mb-6 text-4xl font-bold tracking-tight text-slate-900 sm:text-5xl dark:text-white">
                Your data stays
                <span className="bg-gradient-to-r from-emerald-600 to-teal-600 bg-clip-text text-transparent">
                  {" "}
                  yours
                </span>
              </h2>
              <p className="mb-8 text-lg leading-relaxed text-slate-600 dark:text-slate-400">
                We believe privacy is a fundamental right. FlowDown is designed
                from the ground up with privacy in mind:
              </p>
              <ul className="space-y-4">
                {[
                  "API keys stored securely in your device's Keychain",
                  "No analytics, no tracking, no telemetry",
                  "Conversations stored locally with encryption",
                  "Optional iCloud sync with end-to-end encryption",
                  "Open source - verify our claims yourself",
                ].map((item, i) => (
                  <li key={i} className="flex items-start gap-3">
                    <svg
                      className="mt-1 h-5 w-5 flex-shrink-0 text-emerald-500"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth={2}
                        d="M5 13l4 4L19 7"
                      />
                    </svg>
                    <span className="text-slate-700 dark:text-slate-300">
                      {item}
                    </span>
                  </li>
                ))}
              </ul>
            </div>
            <div className="relative">
              <div className="aspect-square overflow-hidden rounded-3xl border border-slate-200/50 bg-gradient-to-br from-emerald-50 to-teal-50 p-8 dark:border-slate-800/50 dark:from-emerald-950/30 dark:to-teal-950/30">
                <div className="flex h-full items-center justify-center">
                  <svg
                    className="h-32 w-32 text-emerald-500/50"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={1}
                      d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"
                    />
                  </svg>
                </div>
              </div>
              <div className="absolute -inset-4 -z-10 rounded-[2rem] bg-gradient-to-r from-emerald-500/20 to-teal-500/20 opacity-50 blur-2xl" />
            </div>
          </div>
        </div>
      </section>

      {/* Download Section */}
      <section id="download" className="py-32">
        <div className="mx-auto max-w-4xl px-6 text-center">
          <h2 className="mb-6 text-4xl font-bold tracking-tight text-slate-900 sm:text-5xl dark:text-white">
            Ready to get started?
          </h2>
          <p className="mx-auto mb-10 max-w-2xl text-lg text-slate-600 dark:text-slate-400">
            Download FlowDown for free and experience AI chat the way it should
            be — private, powerful, and beautifully designed.
          </p>

          <div className="flex flex-col items-center justify-center gap-6 sm:flex-row">
            {/* App Store Badge */}
            <Link
              href="#"
              className="group relative overflow-hidden rounded-xl bg-black px-8 py-4 transition-transform hover:scale-105"
            >
              <div className="flex items-center gap-3">
                <svg
                  className="h-10 w-10 text-white"
                  fill="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z" />
                </svg>
                <div className="text-left">
                  <p className="text-xs text-slate-400">Download on the</p>
                  <p className="text-xl font-semibold text-white">App Store</p>
                </div>
              </div>
            </Link>

            {/* Mac App Store Badge */}
            <Link
              href="#"
              className="group relative overflow-hidden rounded-xl bg-black px-8 py-4 transition-transform hover:scale-105"
            >
              <div className="flex items-center gap-3">
                <svg
                  className="h-10 w-10 text-white"
                  fill="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z" />
                </svg>
                <div className="text-left">
                  <p className="text-xs text-slate-400">Download on the</p>
                  <p className="text-xl font-semibold text-white">
                    Mac App Store
                  </p>
                </div>
              </div>
            </Link>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="border-t border-slate-200/50 py-12 dark:border-slate-800/50">
        <div className="mx-auto max-w-6xl px-6">
          <div className="flex flex-col items-center justify-between gap-6 sm:flex-row">
            <div className="flex items-center gap-2">
              <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-gradient-to-br from-blue-500 to-indigo-600">
                <span className="text-sm font-bold text-white">F</span>
              </div>
              <span className="font-semibold text-slate-900 dark:text-white">
                FlowDown
              </span>
            </div>

            <div className="flex items-center gap-6">
              <Link
                href="#"
                className="text-sm text-slate-600 transition-colors hover:text-slate-900 dark:text-slate-400 dark:hover:text-white"
              >
                Privacy Policy
              </Link>
              <Link
                href="#"
                className="text-sm text-slate-600 transition-colors hover:text-slate-900 dark:text-slate-400 dark:hover:text-white"
              >
                Terms of Service
              </Link>
              <Link
                href="https://github.com/aspect-apps/FlowDown"
                target="_blank"
                rel="noopener noreferrer"
                className="text-slate-600 transition-colors hover:text-slate-900 dark:text-slate-400 dark:hover:text-white"
              >
                <svg
                  className="h-5 w-5"
                  fill="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z" />
                </svg>
              </Link>
            </div>

            <p className="text-sm text-slate-500 dark:text-slate-500">
              © {new Date().getFullYear()} FlowDown. All rights reserved.
            </p>
          </div>
        </div>
      </footer>
    </main>
  );
}


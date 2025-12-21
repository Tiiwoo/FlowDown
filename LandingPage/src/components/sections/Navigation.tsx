import Link from "next/link";

export default function Navigation() {
  return (
    <nav className="fixed top-0 left-0 right-0 bg-[#f6f6f6] z-50 h-[72px]">
      <div className="max-w-[1280px] mx-auto flex items-center justify-between px-6 h-full">
        {/* Logo */}
        <Link href="/" className="flex items-center gap-2">
          <img
            src="/icon-primary.png"
            alt="FlowDown"
            className="w-[38px] h-[38px] rounded-full"
          />
          <span className="text-base font-semibold text-[#242424]">
            FlowDown
          </span>
        </Link>

        {/* Nav items */}
        <div className="flex items-center gap-8">
          <Link
            href="#docs"
            className="text-base font-medium text-[#242424] hover:opacity-70 transition-opacity"
          >
            Documentation
          </Link>
          <Link
            href="https://github.com/aspect-apps/FlowDown"
            target="_blank"
            className="text-base font-medium text-[#242424] hover:opacity-70 transition-opacity"
          >
            Get Source Code
          </Link>
          <Link
            href="#models"
            className="text-base font-medium text-[#242424] hover:opacity-70 transition-opacity"
          >
            Add Models
          </Link>
          <Link
            href="#download"
            className="btn-primary text-white text-sm font-medium px-5 py-2.5 rounded-lg shadow-sm hover:opacity-90 transition-opacity"
          >
            Download
          </Link>
        </div>
      </div>
    </nav>
  );
}


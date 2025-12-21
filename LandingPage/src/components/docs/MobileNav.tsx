"use client";

import { useState, useRef, useEffect } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { NavItem } from "@/lib/docs-config";

interface MobileNavProps {
  items: NavItem[];
  locale: string;
}

const languages = [
  { code: "en", label: "English" },
  { code: "zh", label: "中文" },
];

export function MobileNav({ items, locale }: MobileNavProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [isLangOpen, setIsLangOpen] = useState(false);
  const pathname = usePathname();
  const dropdownRef = useRef<HTMLDivElement>(null);

  const currentLang = languages.find((l) => l.code === locale) || languages[0];

  // Get the equivalent path in the other locale
  const getLocalePath = (targetLocale: string) => {
    return pathname.replace(`/docs/${locale}`, `/docs/${targetLocale}`);
  };

  // Close dropdown when clicking outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (
        dropdownRef.current &&
        !dropdownRef.current.contains(event.target as Node)
      ) {
        setIsLangOpen(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  return (
    <>
      {/* Mobile menu button */}
      <button
        onClick={() => setIsOpen(true)}
        className="lg:hidden fixed bottom-6 right-6 z-40 bg-[#242424] text-white p-4 rounded-full shadow-lg hover:opacity-90 transition-opacity"
        aria-label="Open navigation menu"
      >
        <svg
          className="w-5 h-5"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeWidth={2}
            d="M4 6h16M4 12h16M4 18h16"
          />
        </svg>
      </button>

      {/* Overlay */}
      {isOpen && (
        <div
          className="lg:hidden fixed inset-0 z-50 bg-black/30"
          onClick={() => setIsOpen(false)}
        />
      )}

      {/* Sidebar drawer */}
      <div
        className={`lg:hidden fixed inset-y-0 left-0 z-50 w-72 bg-[#f6f6f6] transform transition-transform duration-300 ease-in-out shadow-xl flex flex-col ${
          isOpen ? "translate-x-0" : "-translate-x-full"
        }`}
      >
        {/* Close button */}
        <button
          onClick={() => setIsOpen(false)}
          className="absolute top-6 right-4 p-2 text-[#828282] hover:text-[#242424] transition-colors z-10"
          aria-label="Close navigation menu"
        >
          <svg
            className="w-5 h-5"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M6 18L18 6M6 6l12 12"
            />
          </svg>
        </button>

        {/* Navigation */}
        <nav className="flex-1 overflow-y-auto py-6 px-4 pt-16 space-y-6">
          {items.map((section, idx) => (
            <div key={idx}>
              <h4 className="font-semibold text-[#242424] text-sm mb-2 px-2">
                {section.title}
              </h4>
              {section.items && (
                <ul className="space-y-0.5">
                  {section.items.map((item, itemIdx) => {
                    const isActive = pathname === item.href;
                    return (
                      <li key={itemIdx}>
                        <Link
                          href={item.href || "#"}
                          onClick={() => setIsOpen(false)}
                          className={`block text-sm py-2 px-3 rounded-lg transition-all ${
                            isActive
                              ? "bg-[#ebebeb] text-[#242424] font-medium"
                              : "text-[#828282] hover:bg-[#ebebeb]/50 hover:text-[#242424]"
                          }`}
                        >
                          {item.title}
                        </Link>
                      </li>
                    );
                  })}
                </ul>
              )}
            </div>
          ))}
        </nav>

        {/* Language Switcher at bottom */}
        <div className="shrink-0 px-4 py-4 border-t border-[#e6e6e6]">
          <div className="relative" ref={dropdownRef}>
            <button
              onClick={() => setIsLangOpen(!isLangOpen)}
              className="w-full flex items-center gap-2 px-3 py-2.5 bg-[#ebebeb] hover:bg-[#e0e0e0] rounded-lg transition-colors text-sm text-[#242424]"
            >
              {/* Globe icon */}
              <svg
                className="w-4 h-4 text-[#828282]"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <circle cx="12" cy="12" r="10" strokeWidth="1.5" />
                <path
                  strokeWidth="1.5"
                  d="M2 12h20M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"
                />
              </svg>
              <span className="flex-1 text-left">{currentLang.label}</span>
              {/* Chevron */}
              <svg
                className={`w-4 h-4 text-[#828282] transition-transform ${
                  isLangOpen ? "rotate-180" : ""
                }`}
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M19 9l-7 7-7-7"
                />
              </svg>
            </button>

            {/* Dropdown menu */}
            {isLangOpen && (
              <div className="absolute bottom-full left-0 right-0 mb-1 bg-white rounded-lg shadow-lg border border-[#e6e6e6] overflow-hidden">
                {languages.map((lang) => (
                  <Link
                    key={lang.code}
                    href={getLocalePath(lang.code)}
                    onClick={() => {
                      setIsLangOpen(false);
                      setIsOpen(false);
                    }}
                    className={`block px-3 py-2.5 text-sm transition-colors ${
                      lang.code === locale
                        ? "bg-[#ebebeb] text-[#242424] font-medium"
                        : "text-[#454545] hover:bg-[#f6f6f6]"
                    }`}
                  >
                    {lang.label}
                  </Link>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    </>
  );
}

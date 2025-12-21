import { redirect } from "next/navigation";

export default function DocsIndexPage() {
  // Redirect to English docs by default
  redirect("/docs/en");
}


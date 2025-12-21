import { Metadata } from "next";
import { notFound } from "next/navigation";
import { getDocBySlug, getAllDocPaths, fixImagePaths } from "@/lib/docs";
import { MDXRemote } from "next-mdx-remote/rsc";
import remarkGfm from "remark-gfm";
import rehypeSlug from "rehype-slug";
import rehypeAutolinkHeadings from "rehype-autolink-headings";
import { useMDXComponents } from "../../../../../../mdx-components";

interface PageProps {
  params: Promise<{
    locale: string;
    slug: string[];
  }>;
}

export async function generateStaticParams() {
  const paths = getAllDocPaths();
  return paths.map(({ locale, slug }) => ({
    locale,
    slug,
  }));
}

export async function generateMetadata({
  params,
}: PageProps): Promise<Metadata> {
  const { locale, slug } = await params;
  const doc = getDocBySlug(locale, slug);

  if (!doc) {
    return {
      title: "Not Found",
    };
  }

  const fullPath = `/docs/${locale}/documents/${slug.join("/")}`;
  const alternateLocale = locale === "en" ? "zh" : "en";
  const alternatePath = `/docs/${alternateLocale}/documents/${slug.join("/")}`;

  return {
    title: doc.title,
    description: doc.description,
    alternates: {
      canonical: fullPath,
      languages: {
        [locale]: fullPath,
        [alternateLocale]: alternatePath,
      },
    },
    openGraph: {
      title: `${doc.title} | FlowDown Docs`,
      description: doc.description,
      type: "article",
      locale: locale === "zh" ? "zh_CN" : "en_US",
    },
  };
}

export default async function DocPage({ params }: PageProps) {
  const { locale, slug } = await params;
  const doc = getDocBySlug(locale, slug);

  if (!doc) {
    notFound();
  }

  // Fix image paths and remove VitePress-specific frontmatter display
  const processedContent = fixImagePaths(doc.content);

  const components = useMDXComponents({});

  return (
    <div>
      <MDXRemote
        source={processedContent}
        options={{
          mdxOptions: {
            remarkPlugins: [remarkGfm],
            rehypePlugins: [
              rehypeSlug,
              [rehypeAutolinkHeadings, { behavior: "wrap" }],
            ],
          },
        }}
        components={components}
      />
    </div>
  );
}


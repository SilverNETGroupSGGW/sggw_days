import { mkdir, readdir, readFile, unlink, writeFile } from "node:fs/promises";
import { join } from "node:path";

const WIKI_DIR = join(import.meta.dir, "data", "wiki_articles");

// Ensure wiki directory exists
await mkdir(WIKI_DIR, { recursive: true });

export interface WikiArticle {
  id: string;
  title: string;
  content: string;
  category: string;
  imageUrl: string | null;
  tags: string[];
}

export async function listWikiArticles(): Promise<WikiArticle[]> {
  try {
    const files = await readdir(WIKI_DIR);
    const mdFiles = files.filter((f) => f.endsWith(".md"));

    const articles: WikiArticle[] = [];

    for (const file of mdFiles) {
      const content = await readFile(join(WIKI_DIR, file), "utf-8");
      const article = parseMarkdownFile(file, content);
      if (article) articles.push(article);
    }

    return articles;
  } catch (error) {
    return [];
  }
}

export async function getWikiArticle(id: string): Promise<WikiArticle | null> {
  try {
    const content = await readFile(join(WIKI_DIR, `${id}.md`), "utf-8");
    return parseMarkdownFile(`${id}.md`, content);
  } catch {
    return null;
  }
}

export async function createWikiArticle(
  article: Omit<WikiArticle, "id">
): Promise<WikiArticle> {
  const id = crypto.randomUUID();
  const newArticle = { ...article, id };
  await writeWikiArticle(newArticle);
  return newArticle;
}

export async function updateWikiArticle(article: WikiArticle): Promise<void> {
  await writeWikiArticle(article);
}

export async function deleteWikiArticle(id: string): Promise<boolean> {
  try {
    await unlink(join(WIKI_DIR, `${id}.md`));
    return true;
  } catch {
    return false;
  }
}

async function writeWikiArticle(article: WikiArticle): Promise<void> {
  const content = generateMarkdownFile(article);
  await writeFile(join(WIKI_DIR, `${article.id}.md`), content, "utf-8");
}

function parseMarkdownFile(
  filename: string,
  content: string
): WikiArticle | null {
  const id = filename.replace(".md", "");

  // Parse frontmatter
  const frontmatterMatch = content.match(/^---\n([\s\S]*?)\n---\n([\s\S]*)$/);
  if (!frontmatterMatch) return null;

  const [, frontmatter, markdownContent] = frontmatterMatch;

  const metadata: Record<string, any> = {};
  frontmatter.split("\n").forEach((line) => {
    const [key, ...valueParts] = line.split(":");
    if (key && valueParts.length > 0) {
      const value = valueParts.join(":").trim();
      metadata[key.trim()] = value;
    }
  });

  return {
    id,
    title: metadata.title || "",
    content: markdownContent.trim(),
    category: metadata.category || "",
    imageUrl: metadata.imageUrl === "null" ? null : metadata.imageUrl || null,
    tags: metadata.tags
      ? metadata.tags.split(",").map((t: string) => t.trim())
      : [],
  };
}

function generateMarkdownFile(article: WikiArticle): string {
  const frontmatter = [
    "---",
    `title: ${article.title}`,
    `category: ${article.category}`,
    `imageUrl: ${article.imageUrl || "null"}`,
    `tags: ${article.tags.join(", ")}`,
    "---",
    "",
  ].join("\n");

  return frontmatter + article.content;
}

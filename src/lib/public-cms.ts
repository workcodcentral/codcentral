import { createClient } from '@supabase/supabase-js';

type CmsContent = Record<string, unknown>;

const supabaseUrl = import.meta.env.PUBLIC_SUPABASE_URL;
const supabaseKey = import.meta.env.PUBLIC_SUPABASE_ANON_KEY;

const getValue = (source: unknown, path: string): unknown =>
  path === '.' || path === ''
    ? source
    : path.split('.').reduce<unknown>((value, key) => {
    if (value && typeof value === 'object' && key in value) {
      return (value as Record<string, unknown>)[key];
    }
    return undefined;
  }, source);

const setAttribute = (element: Element, attribute: string, value: unknown) => {
  if (typeof value !== 'string') return;
  const normalized = value.trim();
  if (!normalized) {
    element.removeAttribute(attribute);
    if (attribute === 'src') {
      const wrapper = element.closest<HTMLElement>('[data-cms-image]');
      if (wrapper) wrapper.hidden = true;
    }
    return;
  }
  if (
    attribute === 'href' &&
    /^[a-z][a-z\d+.-]*:/i.test(normalized) &&
    !/^(https?:|mailto:|tel:)/i.test(normalized)
  ) return;
  if (attribute === 'src' && /^(javascript|vbscript|data):/i.test(normalized)) return;
  element.setAttribute(attribute, normalized);
  if (attribute === 'src') {
    const wrapper = element.closest<HTMLElement>('[data-cms-image]');
    if (wrapper) wrapper.hidden = false;
  }
};

const bindContent = (root: ParentNode, content: CmsContent, item?: unknown) => {
  const textElements = [...root.querySelectorAll<HTMLElement>('[data-cms-text]')];
  if (root instanceof HTMLElement && root.matches('[data-cms-text]')) textElements.unshift(root);
  textElements.forEach((element) => {
    const path = element.dataset.cmsText;
    const value = path ? getValue(item ?? content, path) : undefined;
    if (typeof value === 'string' || typeof value === 'number') {
      element.textContent = String(value);
      if (element.dataset.cmsOptional !== undefined) {
        element.hidden = String(value).trim() === '';
      }
      if (element instanceof HTMLOptionElement) element.value = String(value);
    }
  });

  const attributeSelector =
    '[data-cms-src], [data-cms-href], [data-cms-alt], [data-cms-target], [data-cms-suffix], [data-cms-placeholder]';
  const attributeElements = [...root.querySelectorAll<HTMLElement>(attributeSelector)];
  if (root instanceof HTMLElement && root.matches(attributeSelector)) attributeElements.unshift(root);
  attributeElements.forEach((element) => {
    for (const [binding, attribute] of [
      ['cmsSrc', 'src'],
      ['cmsHref', 'href'],
      ['cmsAlt', 'alt'],
      ['cmsTarget', 'data-target'],
      ['cmsSuffix', 'data-suffix'],
      ['cmsPlaceholder', 'placeholder'],
    ] as const) {
      const path = element.dataset[binding];
      const value = path ? getValue(item ?? content, path) : undefined;
      if (binding === 'cmsHref' && typeof value === 'string') {
        element.hidden = value.trim() === '';
      }
      if (binding === 'cmsPlaceholder') {
        if (typeof value === 'string') (element as HTMLInputElement).placeholder = value;
      } else {
        setAttribute(element, attribute, value);
      }
      if (binding === 'cmsHref' && element instanceof HTMLAnchorElement) {
        const target = new URL(element.href, window.location.origin);
        const active = target.origin === window.location.origin &&
          (target.pathname === '/' ? window.location.pathname === '/' : window.location.pathname.startsWith(target.pathname));
        if (element.classList.contains('nav-link')) {
          element.classList.remove('text-red-400', 'after:w-full');
          element.classList.add('text-navy-500/80', 'hover:text-red-400', 'after:w-0', 'hover:after:w-full');
          if (active) {
            element.classList.remove('text-navy-500/80', 'after:w-0', 'hover:after:w-full');
            element.classList.add('text-red-400', 'after:w-full');
          }
        } else if (element.classList.contains('mobile-nav-link')) {
          element.classList.remove('text-red-400');
          element.classList.add('text-navy-500', 'hover:text-red-400');
          if (active) {
            element.classList.remove('text-navy-500');
            element.classList.add('text-red-400');
          }
        }
        if (active) element.setAttribute('aria-current', 'page');
        else element.removeAttribute('aria-current');
      }
    }
  });

  const lists = [...root.querySelectorAll<HTMLElement>('[data-cms-list]')];
  if (root instanceof HTMLElement && root.hasAttribute('data-cms-list')) lists.unshift(root);
  lists
    .filter((list) => !list.parentElement?.closest('[data-cms-list]'))
    .forEach((list) => {
      const path = list.dataset.cmsList;
      const values = path ? getValue(item ?? content, path) : undefined;
      if (!Array.isArray(values)) return;

      const listTemplate = list.querySelector<HTMLTemplateElement>(':scope > template[data-cms-template]');
      const existingEntry = [...list.children].find((child) => !(child instanceof HTMLTemplateElement));
      const template = existingEntry ?? listTemplate?.content.firstElementChild;
      if (!template && values.length) return;

      const entries = values.map((value) => {
        const entry = template!.cloneNode(true) as HTMLElement;
        bindContent(entry, content, value);
        return entry;
      });
      list.replaceChildren(...(listTemplate ? [listTemplate] : []), ...entries);
    });
};

const pageName = () => {
  const path = window.location.pathname.replace(/\/+$/, '');
  if (!path) return 'home';
  return path.slice(1).replaceAll('/', '_');
};

const applyGlobalSettings = (settings: Record<string, unknown>) => {
  document.querySelectorAll<HTMLElement>('[data-cms-setting]').forEach((element) => {
    const path = element.dataset.cmsSetting;
    const value = path ? getValue(settings, path) : undefined;
    if (typeof value === 'string' || typeof value === 'number') {
      element.textContent = String(value);
      if (element instanceof HTMLAnchorElement && element.href.startsWith('mailto:')) {
        element.href = `mailto:${value}`;
      }
      if (element instanceof HTMLAnchorElement && element.href.startsWith('tel:')) {
        element.href = `tel:${String(value).replace(/[^\d+]/g, '')}`;
      }
    }
  });

  document.querySelectorAll<HTMLAnchorElement>('[data-cms-setting-href]').forEach((element) => {
    const key = element.dataset.cmsSettingHref;
    const value = key ? settings[key] : undefined;
    if (typeof value === 'string' && /^(https?:\/\/|mailto:|tel:)/i.test(value)) {
      element.href = value;
    }
  });

  document.querySelectorAll<HTMLElement>('[data-cms-setting-src], [data-cms-setting-alt]').forEach((element) => {
    const srcKey = element.dataset.cmsSettingSrc;
    const altKey = element.dataset.cmsSettingAlt;
    if (srcKey) setAttribute(element, 'src', settings[srcKey]);
    if (altKey) setAttribute(element, 'alt', settings[altKey]);
  });

  const phone = settings.whatsapp_number;
  if (typeof phone === 'string' && phone) {
    const digits = phone.replace(/\D/g, '');
    document.querySelectorAll<HTMLAnchorElement>('[data-cms-whatsapp]').forEach((element) => {
      const current = new URL(element.href);
      current.pathname = `/${digits}`;
      element.href = current.toString();
    });
  }

  if (typeof settings.site_name === 'string' && settings.site_name) {
    const title = document.title;
    document.title = title.includes(settings.site_name) ? title : `${title} | ${settings.site_name}`;
  }
  if (typeof settings.meta_description === 'string' && settings.meta_description) {
    document.querySelector('meta[name="description"]')?.setAttribute('content', settings.meta_description);
  }
  if (typeof settings.favicon_url === 'string' && settings.favicon_url) {
    document.querySelector('link[rel="icon"]')?.setAttribute('href', settings.favicon_url);
  }
  if (settings.whatsapp_widget === false) {
    document.getElementById('wa-root')?.setAttribute('hidden', '');
  }
  if (settings.show_insights === false) {
    document.querySelectorAll<HTMLAnchorElement>('a[href^="/insights"]').forEach((element) => {
      element.hidden = true;
    });
  }
  if (settings.show_shop === false) {
    document.querySelectorAll<HTMLAnchorElement>('a[href^="/shop"]').forEach((element) => {
      element.hidden = true;
    });
  }
};

const applyPageMetadata = (content: CmsContent) => {
  if (typeof content.seo_title === 'string' && content.seo_title) {
    document.title = content.seo_title;
  }
  if (typeof content.seo_description === 'string' && content.seo_description) {
    document.querySelector('meta[name="description"]')?.setAttribute('content', content.seo_description);
    document.querySelector('meta[property="og:description"]')?.setAttribute('content', content.seo_description);
  }
  if (typeof content.seo_image === 'string' && content.seo_image) {
    document.querySelector('meta[property="og:image"]')?.setAttribute('content', content.seo_image);
  }
};

const loadPublishedArticles = async (supabase: ReturnType<typeof createClient>) => {
  const [{ data: blogs, error: blogsError }, { data: news, error: newsError }] = await Promise.all([
    supabase
      .from('blogs')
      .select('title, tag, read_time, excerpt, author, image_url, created_at')
      .eq('status', 'published')
      .order('created_at', { ascending: false }),
    supabase
      .from('news_articles')
      .select('title, category, excerpt, author, image_url, created_at')
      .eq('status', 'published')
      .order('created_at', { ascending: false }),
  ]);
  if (blogsError) throw blogsError;
  if (newsError) throw newsError;

  return [
    ...(blogs ?? []).map((article) => ({
      tag: article.tag || 'Blog',
      readTime: article.read_time || '',
      title: article.title,
      excerpt: article.excerpt || '',
      author: article.author || 'Codcentral Studios',
      authorRole: '',
      image: article.image_url || '',
      date: new Date(article.created_at).toLocaleDateString('en-GB', {
        day: 'numeric',
        month: 'short',
        year: 'numeric',
      }),
      _timestamp: new Date(article.created_at).getTime(),
    })),
    ...(news ?? []).map((article) => ({
      tag: article.category || 'News',
      readTime: '',
      title: article.title,
      excerpt: article.excerpt || '',
      author: article.author || 'Codcentral Studios',
      authorRole: '',
      image: article.image_url || '',
      date: new Date(article.created_at).toLocaleDateString('en-GB', {
        day: 'numeric',
        month: 'short',
        year: 'numeric',
      }),
      _timestamp: new Date(article.created_at).getTime(),
    })),
  ].sort((a, b) => b._timestamp - a._timestamp);
};

const syncPublicContent = async () => {
  if (!supabaseUrl || !supabaseKey || supabaseUrl === 'your_supabase_project_url') return;

  const supabase = createClient(supabaseUrl, supabaseKey);
  const currentPage = pageName();
  const [pageResult, homeResult, navbarResult, footerResult, settingsResult] = await Promise.all([
    supabase.from('page_content').select('content').eq('page', currentPage).maybeSingle(),
    currentPage === 'home'
      ? Promise.resolve({ data: null, error: null })
      : supabase.from('page_content').select('content').eq('page', 'home').maybeSingle(),
    supabase.from('page_content').select('content').eq('page', 'navbar').maybeSingle(),
    supabase.from('page_content').select('content').eq('page', 'footer').maybeSingle(),
    supabase.from('settings').select('value').eq('key', 'global').maybeSingle(),
  ]);

  if (pageResult.error) throw pageResult.error;
  if (homeResult.error) throw homeResult.error;
  if (navbarResult.error) throw navbarResult.error;
  if (footerResult.error) throw footerResult.error;
  if (settingsResult.error) throw settingsResult.error;

  if (pageResult.data?.content) {
    const pageContent = pageResult.data.content as CmsContent;
    if (currentPage === 'about') {
      pageContent.about_hero_eyebrow ??= pageContent.hero_eyebrow;
      pageContent.about_hero_line1 ??= pageContent.hero_line1 ?? pageContent.hero_headline;
      pageContent.about_hero_line2 ??= pageContent.hero_line2;
      pageContent.about_hero_sub ??= pageContent.hero_sub;
    }
    bindContent(document, pageContent);
    applyPageMetadata(pageContent);
  }
  if (currentPage !== 'home' && homeResult.data?.content) {
    bindContent(document, homeResult.data.content as CmsContent);
  }
  if (navbarResult.data?.content) {
    bindContent(document, navbarResult.data.content as CmsContent);
  }
  if (footerResult.data?.content) {
    bindContent(document, footerResult.data.content as CmsContent);
  }
  if (settingsResult.data?.value) {
    applyGlobalSettings(settingsResult.data.value as Record<string, unknown>);
  }
  if (currentPage === 'home' || currentPage === 'insights') {
    const articles = await loadPublishedArticles(supabase);
    if (currentPage === 'home') {
      bindContent(document, { latestArticles: articles.slice(0, 4) });
      const section = document.getElementById('news');
      if (section) section.hidden = articles.length === 0;
    } else {
      bindContent(document, { articles });
      const articleList = document.querySelector<HTMLElement>('[data-cms-list="articles"]');
      if (articleList) articleList.hidden = articles.length === 0;
    }
  }
  window.dispatchEvent(new CustomEvent('codcentral:cms-updated'));
};

syncPublicContent().catch((error: unknown) => {
  console.error('Could not load live site content from Supabase:', error);
});

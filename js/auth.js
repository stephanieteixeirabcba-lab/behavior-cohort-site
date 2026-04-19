// ============================================================================
// Shared auth utilities — used across every page that needs login state
// ============================================================================

// Import the Supabase JS client from CDN
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const config = window.SUPABASE_CONFIG;

if (!config || config.url.startsWith('PASTE_')) {
  console.error('Supabase not configured — edit assets/js/supabase-config.js');
}

export const supabase = createClient(config.url, config.anonKey);

// ---------------------------------------------------------------------------
// Get the current user (or null if not logged in)
// ---------------------------------------------------------------------------
export async function getUser() {
  const { data: { user } } = await supabase.auth.getUser();
  return user;
}

// ---------------------------------------------------------------------------
// Get the current user's profile row (includes role)
// ---------------------------------------------------------------------------
export async function getProfile() {
  const user = await getUser();
  if (!user) return null;
  const { data, error } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', user.id)
    .single();
  if (error) {
    console.error('Error loading profile:', error);
    return null;
  }
  return data;
}

// ---------------------------------------------------------------------------
// Update the nav bar to reflect login state
// Adds "Log in" / "Log out" link based on current auth
// ---------------------------------------------------------------------------
export async function updateNavAuth(basePath = '') {
  const user = await getUser();
  const nav = document.querySelector('.nav');
  if (!nav) return;

  const existing = nav.querySelector('.auth-nav-item');
  if (existing) existing.remove();

  const li = document.createElement('li');
  li.className = 'auth-nav-item';

  if (user) {
    const profile = await getProfile();
    const name = profile?.full_name?.split(' ')[0] || 'Account';
    li.innerHTML = `<a href="#" id="logout-link">Log out (${escapeHtml(name)})</a>`;
    nav.appendChild(li);
    document.getElementById('logout-link').addEventListener('click', async (e) => {
      e.preventDefault();
      await supabase.auth.signOut();
      window.location.href = `${basePath}index.html`;
    });
  } else {
    li.innerHTML = `<a href="${basePath}login.html">Log in</a>`;
    nav.appendChild(li);
  }
}

// ---------------------------------------------------------------------------
// Redirect to login if not authenticated
// Use at the top of protected pages
// ---------------------------------------------------------------------------
export async function requireAuth(basePath = '') {
  const user = await getUser();
  if (!user) {
    window.location.href = `${basePath}login.html`;
    return null;
  }
  return user;
}

// ---------------------------------------------------------------------------
// Simple HTML-escape for safely inserting user-controlled strings into DOM
// ---------------------------------------------------------------------------
export function escapeHtml(str) {
  if (str == null) return '';
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

const { ok, fail } = require('../utils/http');
const { requireAuth } = require('../middleware/auth');
const { publicResource } = require('../utils/presenters');
const { RESOURCE_CATALOG } = require('../catalogs/resourceCatalog');
const { readResourceFavorites, insertResourceFavorite, deleteResourceFavorite } = require('../storage/localDatabase');

async function favoriteIdsForUser(userId) {
  const favs = await readResourceFavorites();
  return favs.filter(f => f.userId === userId).map(f => f.resourceId);
}

function filterResourcesForRequest(resources, url, favoriteIds = []) {
  let filtered = [...resources];
  const search = String(url.searchParams.get('search') || '').trim().toLowerCase();
  const thematic = String(url.searchParams.get('thematic') || '').trim();
  const format = String(url.searchParams.get('format') || '').trim();
  const level = String(url.searchParams.get('level') || '').trim();
  const favoritesOnly = String(url.searchParams.get('favoritesOnly') || '').toLowerCase() === 'true';
  if (search) filtered = filtered.filter(r => [r.title, r.thematic, r.format, r.description, r.content].join(' ').toLowerCase().includes(search));
  if (thematic && thematic !== 'Todos') filtered = filtered.filter(r => r.thematic === thematic || r.thematic.includes(thematic));
  if (format && format !== 'Todos') filtered = filtered.filter(r => r.format === format || r.format.includes(format));
  if (level && level !== 'Todos') filtered = filtered.filter(r => r.level === level);
  if (favoritesOnly) filtered = filtered.filter(r => favoriteIds.includes(r.id));
  return filtered;
}

async function getArticles(req, res, url) {
  const user = requireAuth(req, res);
  if (!user) return;
  const favorites = await favoriteIdsForUser(user.id);
  const resources = filterResourcesForRequest(RESOURCE_CATALOG, url, favorites).map(r => ({ ...publicResource(r), isFavorite: favorites.includes(r.id) }));
  ok(res, { resources, favoriteIds: favorites }, 'Recursos cargados');
}

async function getCategories(req, res) {
  const user = requireAuth(req, res);
  if (!user) return;
  const thematics = [...new Set(RESOURCE_CATALOG.flatMap(r => String(r.thematic).split('/')).map(t => t.trim()).filter(Boolean))].sort();
  const formats = [...new Set(RESOURCE_CATALOG.map(r => r.format))].sort();
  const levels = [...new Set(RESOURCE_CATALOG.map(r => r.level))].sort();
  ok(res, { thematics, formats, levels }, 'Categorías cargadas');
}

async function getDetail(req, res, resourceId) {
  const user = requireAuth(req, res);
  if (!user) return;
  const favorites = await favoriteIdsForUser(user.id);
  const resource = RESOURCE_CATALOG.find(r => r.id === resourceId);
  if (!resource) return fail(res, 404, 'Recurso no encontrado');
  ok(res, { resource: { ...publicResource(resource), isFavorite: favorites.includes(resource.id) } }, 'Detalle de recurso cargado');
}

async function getFavorites(req, res) {
  const user = requireAuth(req, res);
  if (!user) return;
  const ids = await favoriteIdsForUser(user.id);
  ok(res, { favoriteIds: ids }, 'Favoritos cargados');
}

async function addFavorite(req, res, resourceId) {
  const user = requireAuth(req, res);
  if (!user) return;
  const resource = RESOURCE_CATALOG.find(r => r.id === resourceId);
  if (!resource) return fail(res, 404, 'Recurso no encontrado');
  await insertResourceFavorite(user.id, resourceId);
  const ids = await favoriteIdsForUser(user.id);
  ok(res, { resourceId, isFavorite: true, favoriteIds: ids }, 'Recurso agregado a favoritos');
}

async function removeFavorite(req, res, resourceId) {
  const user = requireAuth(req, res);
  if (!user) return;
  await deleteResourceFavorite(user.id, resourceId);
  const ids = await favoriteIdsForUser(user.id);
  ok(res, { resourceId, isFavorite: false, favoriteIds: ids }, 'Recurso removido de favoritos');
}

module.exports = { getArticles, getCategories, getDetail, getFavorites, addFavorite, removeFavorite };
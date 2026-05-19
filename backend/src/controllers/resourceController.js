const { ok, fail } = require('../utils/http');
const { requireAuth } = require('../middleware/auth');
const { publicResource } = require('../utils/presenters');
const { RESOURCE_CATALOG } = require('../catalogs/resourceCatalog');
const { readResourceFavorites, writeResourceFavorites } = require('../storage/localDatabase');

function favoriteIdsForUser(userId) {
  return readResourceFavorites().filter(item => item.userId === userId).map(item => item.resourceId);
}

function filterResourcesForRequest(resources, url, favoriteIds = []) {
  let filtered = [...resources];
  const search = String(url.searchParams.get('search') || '').trim().toLowerCase();
  const thematic = String(url.searchParams.get('thematic') || '').trim();
  const format = String(url.searchParams.get('format') || '').trim();
  const level = String(url.searchParams.get('level') || '').trim();
  const favoritesOnly = String(url.searchParams.get('favoritesOnly') || '').toLowerCase() === 'true';

  if (search) {
    filtered = filtered.filter(resource => [resource.title, resource.thematic, resource.format, resource.description, resource.content].join(' ').toLowerCase().includes(search));
  }
  if (thematic && thematic !== 'Todos') filtered = filtered.filter(resource => resource.thematic === thematic || resource.thematic.includes(thematic));
  if (format && format !== 'Todos') filtered = filtered.filter(resource => resource.format === format || resource.format.includes(format));
  if (level && level !== 'Todos') filtered = filtered.filter(resource => resource.level === level);
  if (favoritesOnly) filtered = filtered.filter(resource => favoriteIds.includes(resource.id));
  return filtered;
}

function getArticles(req, res, url) {
  const user = requireAuth(req, res);
  if (!user) return;
  const favorites = favoriteIdsForUser(user.id);
  const resources = filterResourcesForRequest(RESOURCE_CATALOG, url, favorites).map(resource => ({ ...publicResource(resource), isFavorite: favorites.includes(resource.id) }));
  ok(res, { resources, favoriteIds: favorites }, 'Recursos cargados');
}

function getCategories(req, res) {
  const user = requireAuth(req, res);
  if (!user) return;
  const thematics = [...new Set(RESOURCE_CATALOG.flatMap(resource => String(resource.thematic).split('/')).map(item => item.trim()).filter(Boolean))].sort();
  const formats = [...new Set(RESOURCE_CATALOG.map(resource => resource.format))].sort();
  const levels = [...new Set(RESOURCE_CATALOG.map(resource => resource.level))].sort();
  ok(res, { thematics, formats, levels }, 'Categorías cargadas');
}

function getDetail(req, res, resourceId) {
  const user = requireAuth(req, res);
  if (!user) return;
  const favorites = favoriteIdsForUser(user.id);
  const resource = RESOURCE_CATALOG.find(item => item.id === resourceId);
  if (!resource) return fail(res, 404, 'Recurso no encontrado');
  ok(res, { resource: { ...publicResource(resource), isFavorite: favorites.includes(resource.id) } }, 'Detalle de recurso cargado');
}

function getFavorites(req, res) {
  const user = requireAuth(req, res);
  if (!user) return;
  const ids = favoriteIdsForUser(user.id);
  ok(res, { favoriteIds: ids }, 'Favoritos cargados');
}

function addFavorite(req, res, resourceId) {
  const user = requireAuth(req, res);
  if (!user) return;
  const resource = RESOURCE_CATALOG.find(item => item.id === resourceId);
  if (!resource) return fail(res, 404, 'Recurso no encontrado');
  const favorites = readResourceFavorites();
  const exists = favorites.some(item => item.userId === user.id && item.resourceId === resourceId);
  if (!exists) favorites.push({ userId: user.id, resourceId, createdAt: new Date().toISOString() });
  writeResourceFavorites(favorites);
  ok(res, { resourceId, isFavorite: true, favoriteIds: favoriteIdsForUser(user.id) }, 'Recurso agregado a favoritos');
}

function removeFavorite(req, res, resourceId) {
  const user = requireAuth(req, res);
  if (!user) return;
  const favorites = readResourceFavorites().filter(item => !(item.userId === user.id && item.resourceId === resourceId));
  writeResourceFavorites(favorites);
  ok(res, { resourceId, isFavorite: false, favoriteIds: favoriteIdsForUser(user.id) }, 'Recurso removido de favoritos');
}

module.exports = { getArticles, getCategories, getDetail, getFavorites, addFavorite, removeFavorite };

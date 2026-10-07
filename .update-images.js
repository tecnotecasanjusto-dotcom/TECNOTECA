const fs = require('fs');
const originalPath = 'index.html';
const alternativePath = 'index (4).html';
const original = fs.readFileSync(originalPath, 'utf8');
const alternative = fs.readFileSync(alternativePath, 'utf8');
const imagePattern = /<img\b[^>]*\bsrc="([^"]+)"/gi;
const originalSources = [...original.matchAll(imagePattern)].map((match) => match[1]);
const alternativeSources = [...alternative.matchAll(imagePattern)].map((match) => match[1]);
const newSources = alternativeSources.filter((source) => !originalSources.includes(source));
if (newSources.length !== 3) throw new Error(`Expected 3 new image sources, found ${newSources.length}.`);

const gridMarker = '    <div class="mt-9 grid grid-cols-2 md:grid-cols-4 gap-3">';
if (!original.includes(gridMarker)) throw new Error('Grid not found.');

const cardPattern = /<a\b[^>]*class="[^"]*igtile[^"]*"[^>]*>\s*<img\b[^>]*>/is;
const insertion = [...alternative.matchAll(cardPattern)]
  .map((match) => {
    const tag = match[0];
    const sourceMatch = tag.match(/\bsrc="([^"]+)"/i);
    const source = sourceMatch?.[1];
    if (!newSources.includes(source)) return '';
    const hrefMatch = tag.match(/\bhref="([^"]+)"/i);
    return `\n      <a href="${hrefMatch?.[1] ?? ''}" target="_blank" rel="noopener" class="igtile glass card rounded-2xl aspect-square flex items-end p-4"><img src="${source}"></a>`;
  })
  .join('');

if (!insertion.includes('<img src="data:image/jpeg;base64,')) throw new Error('New images were not extracted.');
fs.writeFileSync(originalPath, original.replace(gridMarker, gridMarker + insertion), 'utf8');
console.log(`Inserted ${newSources.length} new images.`);

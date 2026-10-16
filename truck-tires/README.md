# Погрузка шин — зацикленное видео-баннер

Мультяшная сцена (тёплая «осенняя» палитра, сосновый лес, жирный контур, большие глаза):
три грузчика по цепочке передают шины из сарая в кузов грузовика, в кабине сидит пёс.

| Файл | Формат | Размер |
|---|---|---|
| `truck-tires.webm` | VP9, 2400×600, 30 fps, 8 с, без звука | ~2.3 МБ |
| `truck-tires.mp4` | H.264 (запасной), 2400×600, 30 fps, 8 с | ~1.1 МБ |
| `truck-tires-poster.jpg` | постер (первый кадр до загрузки) | ~0.2 МБ |

Цикл бесшовный: все движения периодичны (шина передаётся каждые 2 с, ролик — 8 с).

## Вставка на сайт (1200×300 на экране)

```html
<video width="1200" height="300" autoplay muted loop playsinline
       poster="truck-tires-poster.jpg" style="width:100%;max-width:1200px;height:auto;aspect-ratio:4/1">
  <source src="truck-tires.webm" type="video/webm">
  <source src="truck-tires.mp4" type="video/mp4">
</video>
```

## Исходники

- `src/scene.html` — сцена на canvas; откройте в браузере, чтобы увидеть живой предпросмотр.
- `src/render.mjs` — рендер кадров через Playwright/Chromium.

Пересборка:

```bash
node src/render.mjs frames 30
ffmpeg -framerate 30 -i frames/f%04d.png -c:v libvpx-vp9 -b:v 2400k -maxrate 3000k -pass 1 -an -f null /dev/null
ffmpeg -framerate 30 -i frames/f%04d.png -c:v libvpx-vp9 -b:v 2400k -maxrate 3000k -pass 2 -an truck-tires.webm
ffmpeg -framerate 30 -i frames/f%04d.png -c:v libx264 -preset slow -crf 23 -pix_fmt yuv420p -movflags +faststart -an truck-tires.mp4
```

# Реалистичная версия баннера

Фотореалистичных людей кодом не нарисуешь: нужен либо AI-видеогенератор
(Veo, Kling, Runway, Sora, Hailuo), либо стоковое видео (Pexels, Pixabay, Shutterstock).
Исходник делаете там, а этот скрипт доводит его до требований баннера.

## 1. Сгенерировать исходник

Генерируйте в **16:9** и с запасом по высоте: потом из середины вырежется полоса 4:1.
Важное (грузовик, люди, шины) должно быть в средней трети кадра по высоте.

**Промпт (EN, генераторы лучше понимают английский):**

```
Static wide shot, locked-off camera on a tripod, no camera movement. A white box truck
with its rear roller door fully open is parked at a tire warehouse loading dock, side
view of the truck. Three workers in dark work uniforms with high-visibility vests and
work gloves form a chain: one takes a car tire from a tall stack near the warehouse,
passes it to the second, who tosses it up to the third worker standing inside the truck,
who stacks it neatly inside the truck. Inside the truck rows of stacked black tires.
Warm late-afternoon sunlight, soft long shadows, light dust in the air, pine trees in
the background. Photorealistic, natural motion, 35mm lens, shallow depth of field,
commercial video look, 4K.
```

**Negative prompt (если есть поле):**
`text, logos, watermark, camera shake, zoom, cuts, distorted hands, extra fingers, warped tires`

Советы:
- Статичная камера обязательна — иначе цикл не склеится.
- Повторяющееся действие (цепочка передаёт шины) — тоже ради цикла.
- Сделайте 3–4 генерации и выберите ту, где руки и шины без артефактов.

## 2. Превратить в баннер

```bash
./make-banner.sh source.mp4 [start_sec] [duration_sec] [crop_y] [out_name]
# пример: фрагмент с 1.5 с, длиной 7 с, полоса чуть ниже центра
./make-banner.sh source.mp4 1.5 7 0.6 truck-tires-real
```

На выходе:
- `truck-tires-real.webm` (VP9) и `truck-tires-real.mp4` (H.264): 2400×600, 30 fps,
  каждый ≤ 3 МБ (битрейт подбирается автоматически);
- `truck-tires-real-poster.jpg` — постер.

Цикл бесшовный: последние 0.8 с плавно перетекают в начало ролика.
Вставка на сайт — так же, как у мультяшной версии (см. `../README.md`).

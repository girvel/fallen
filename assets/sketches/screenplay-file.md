```
---
narrative: О
engineer_1: Н
player: П
---

! Первая версия просто разделяет текст и код, позволяя решать две задачи:
! 1. Переводить игру на другие языки
! 2. Не надо копировать текст в скрипты

О: Когда ты подходишь ближе, измазанный сажей полуэльф всё так же не оборачивается.
О: Его глаза, не отрываясь, смотрят прямо на приборы.
О: Полуповисшая рука мертвой хваткой сжимает газовый ключ.

1. Какую работу ты выполняешь?
    Н: Главный инженер
    ! крутые спецэффекты
    Н: Моя работа — наблюдать за приборами
    Н: ...

2. Наблюдал что-то необычное в последнее время?
    Н: Бла-бла-бла

3. Бла-бла?
    Н: Бла-бла

4. *уйти*
    ! конец
```

Применяться это должно как-то так:

```lua
local screenplay = screenplayer.create("/assets/sketches/screenplay-file.txt", characters, ...)
screenplay:lines()
while true do
  screenplay:push_options()
  if screenplay.branch_index == 4 then break end
  screenplay:lines()
  if screenplay.branch_index == 1 then
    cool_fx()
  end
  screenplay:pop()
end
screenplay:pop()
```

Or it should be just loaded in lua data structure:

```lua
local screenplay = screenplayer.load("assets/sketches/screenplay-file.txt")
assert.same(screenplay, {
  {type = "lines", lines = {
    {source = "narrative", text = "Когда ты подходишь ближе, измазанный сажей полуэльф всё так же не оборачивается."},
    {source = "narrative", text = "Его глаза, не отрываясь, смотрят прямо на приборы."},
    {source = "narrative", text = "Полуповисшая рука мертвой хваткой сжимает газовый ключ."},
  }},

  {type = "options", options = {
    {text = "Какую работу ты выполняешь?", branch = {
      {type = "lines", lines = {
        {source = "engineer_1", text = "Главный инженер"},
      }},
      {type = "code", comment = "крутые спецэффекты"},
      {type = "lines", lines = {
        {source = "engineer_1", text = "Моя работа — наблюдать за приборами"},
        {source = "engineer_1", text = "..."},
      }},
    }},
    ...
  }},
})
```

Maybe it should do text substitution

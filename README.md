### Улучшение функционального подхода к разработке на Elm.

Меня периодически удручает ситуация с функцией update.
Как-то выглядит совсем не по-функциональному этот монстро-case.

Я наткнулся на интересную библиотеку (https://github.com/joneshf/elm-comonad) и меня поразила простота идеи.

Мне правда еще не получается перестроить мышление, чтобы до конца понять подход, но я буду честно стараться.

В данном примере update вообще нигде не нужен.
Показан пример наследования в view, commands и subscription.

[Пример](stage03.html)

### Що далі

Я хочу спробувати додати Lens (Optics)
Ще треба глянути на http://package.elm-lang.org/packages/chrilves/elm-io/latest

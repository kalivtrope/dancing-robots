# Programování na dance padech

## Přehled hry

Cílem hry je naprogramovat robota Eralka pomocí sekvence příkazů, které má provádět.
Podle těchto příkazů bude Eralk procházet herní plán (bludiště)
a zároveň s ním interagovat podle zadání problému.

Až napíšete program (sekvenci příkazů pro robota Eralka),
tak můžete program do robota nahrát a spustit ho, aby vyřešil daný problém.
Robot Eralk je velice high-end robot a nepoužívá
žádné baterie, ale je poháněn tanečním vibem. Bohužel taneční energii nejde
nijak uchovat, proto je nutné tančit během běhu programu. Ale na druhou
stranu je to zelená, obnovitelná energie!

Taneční energie může být napadena špatnou náladou, která robota poškozuje.
Pokud robota příliš dlouho krmíte špatnou náladou, tak se robot začne
odklánět od svého programu a začne provádět náhodné pohyby.

Abyste nemuseli debugovat program přímo na produkčním robotovi, který
stojí spoustu peněz, tak je program nejdříve zkontrolován, jestli
je korektní a až poté můžete program spustit na robotovi.

Hra se tedy skládá ze dvou fází: programovací a tančící.

Libovolný program můžete odtančit vícekrát za účelem zlepšeních statistik.
Všechny odtančené hry se pamatují, tedy můžete nejdříve zlepšovat jednu
statistiku a poté druhou.

Můžete odtančit vždy naposledy odevzdanou validní verzi programu, pokud chcete odtančit
jinou verzi (např. kvůli tomu, že si chcete zlepšit jinou statistiku pro daný problém),
musíte nejdříve odevzdat novou verzi programu.

## Programovací fáze

Pro každy problém máte k dispozici jeden ?dynamicky? generovaný vstup, který po
nějaké době vyprší.

Stáhnutí vstupu a následné odevzdání provedete na následující
webové stránce: **TODO_URL**. Přihlašovací údaje dostanete od orga na začátku hry.

Pro všechny problémy platí, že robot Eralk se nachází na čtverečkové mapě.
Po konci programu musí robot Eralk skončit na cílovém políčku.
Natočení robota na cílovém políčku není důležité, pokud není specifikováno jinak.
Pro každý problém chcete napsat program, který vyřeší daný problém.

Za každý správně naprogramovaný problém dostanete ihned XX bodů.

Jak bylo řečeno, program se skládá ze sekvence příkazů.
Následující příkazy dokáže robot Eralk provést:

- `NOP` - tento příkaz nic nedělá
- `TURN_LEFT` - otočí robota o 90 stupňů doleva
- `TURN_RIGHT` - otočí robota o 90 stupňů doprava
- `COLLECT` - Eralk se pokusí sebrat jeden předmět z políčka na kterém se právě nachází a přidá si ho do inventáře. Pokud se na políčku nenachází žádný předmět, tak se tato instrukce chová jako `NOP` s tím rozdílem, že se vypíše varování. Varování můžete zcela ignorovat.
- `DROP` - Eralk se pokusí položit jeden předmět ze svého inventáře na políčko na kterém právě stojí. Pokud je inventář prázdný, tak se tato instrukce chová jako `NOP` s tím rozdílem, že se vypíše varování. Varování můžete zcela ignorovat.
- `MOVE_TO_WALL` - Eralk se posune k nejbližší zdi ve směru, kterým je právě otočen. Tato instrukce může provést nula či více kroků, dokud Eralk nedojde ke zdi.
- `MOVE_TO_ITEM` - Eralk se posune na nejbližší předmět ve směru, kterým je právě otočen. Pokud žádný předmět není v daném směru nebo se mezi předmětem a Eralkem nachází zeď, tak se tato instrukce chová jako `MOVE_TO_WALL`. Jinak Eralk udělá **minimálně** jeden krok a zastaví se na nejbližším políčku s předmětem.
- `MOVE_TO_START` - Eralk se posune směrem, kterým je právě otočen, dokud nedojde na startovní políčko `S`, či než nedojde ke zdi. Pokud se Eralk již nachází na startovním políčku, tak neprovede žádné kroky.
- `MOVE_TO_END` - Eralk se posune směrem, kterým je právě otočen, dokud nedojde na cílové políčko `E`, či než nedojde ke zdi. Pokud se Eralk již nachází na cílovém políčku, tak neprovede žádné kroky.

Každý vstup má tuto podobu: Na prvním řádku se nachází jméno/kód řešené
úlohy. Na dalším řádku se nachází 2 čísla specifikující velikost mapy/mřížky.
První číslo $h$ specifikuje výšku a druhé číslo $w$ specifikuje šířku mřížky.
Poté následuje $h$ řádků vstupu. Na každém řádku se nachází $w$ buněk oddělených mezerou.
Každá buňka je specifikována sekvencí jednoho či více znaků:

- `S` - označuje startovní políčko (nachází se na plánu právě jedno políčko s tímto znakem)
- `E` - označuje cílové políčko (nachází se na plánu právě jedno políčko s tímto znakem)
- `I` - označuje, že na tomto políčku se nachází předmět
- `#` - na daném políčku se nachází zeď
- `.` - na daném políčku nic není

Např. políčko `SIIIE` říká, že pole je startovní i cílové a zároveň se zde nachází 3 předměty.

Ve výpisech na webu můžete najít dodatečné informace, že se něco událo na políčku $[y, x]$. Neboli na řádku $y$ a ve sloupci $x$ se stalo něco stalo. Pozice $[1, 1]$ se nachází v levém horním rohu mapy.

```
row/col 1  2  3 4 5 6   7   8
   1    #  #  # # # #   #   #
   2    #  .  . # . .   E   #
   3    #  .  . I . .   #   #
   4    #  #  . . . .   .   #
   5    #  .  . I # I (5,7) #
   6    #  .  . . . #   .   #
   7    #  IS # I . I   #   #
   8    #  #  # # # #   #   #
```

Robot Eralk se na začátku programu nachází na startovním políčku `S` a je otočen na sever (tj. směr nahoru).

### Problémy:

#### Hřeben

V této úloze máte posbírat všechny předměty a přesunout je na cílové políčko.
Všechny předměty **musí být položeny** na cílovém políčku před koncem programu!

Ukázka vstupu:
```
comb
13 11
# # # # # # # # # # #
# S # . . . # . I . #
# . # . # . # . # . #
# . # . # . # . # . #
# . # . # . # . # . #
# . # . # . # . # . #
# . # . # . # . # . #
# . # . # . # . # . #
# . # . # . # . # . #
# . # . # . # . # . #
# . # . # . # . # . #
# . I . # . I . # E #
# # # # # # # # # # #
```

#### Graf

Eralk se nachází v navigační centrále pro navigaci raket. Tato navigační centrála funguje
velmi zvláštně. Naviguje se pomocí speciálních květin - hrochzmatenek.
Po utržení květiny na pozici $[y, x]$ se vyšle signál raketoplánu, že pokud se nachází na planetě
$x$, tak se má přesunout na planetu $y$.
Počáteční pozice raketoplánu a její cílová destinace raketoplánu je zakódována ve vstupní pozice
Eralka. Pokud se Eralk nachází na pozici $[sy, sx]$, tak raketoplán se nachází na planetě $sy$
a destinace raketoplánu je $sx$.

Tato navigace je velice ekologická, ale zároveň nechceme trhat květiny zbytečně, protože
dlouho rostou a zároveň chceme navigovat více raketoplánu než jen tuto jednu. Proto najděte plán
raketoplánu, který je nejkratší možný.

Zároveň se kytky musí dát do vázy, aby hned neuvadli, proto na cílovém políčku všechny květiny
musí být **položeny**.

#### Permutace

Eralk sesbíral vzorky hornin, ale pro správnou analýzu vzorků je potřebuje setřídit.
Na vstupu dostane mapu, kde se na různých políčkách nachází vzorky hornin (předměty).
Eralk musí vzorky roztřídit tak, že ve sloupci $2i$ se musí nacházet $i$ hornin vzorků.

Ukázkový vstup:
```
sortp
10 10
# # # # # # # # # #
# . . . . # . . E #
# . . . . I . . # #
# . . # . . . . . #
# . . I . I # . . #
# # . . . . . # . #
# . . I # I . I # #
# . . . . # . . . #
# IS # I . I # I . #
# # # # # # # # # #
```

Jeden možný finální stav po konci programu:
```
# # # # # # # # # #
# . . . . # . . eE #
# . . . . . . I # #
# . . # . . . . . #
# . . . . I # I . #
# # . . . . . # . #
# . . I # I . I # #
# . . . . # . . . #
# IS # I . I # I . #
# # # # # # # # # #
```

Malé `e` označuje natočení Eralka (`e` -- east neboli východ).

#### Spirála

Projděte sprirálou od startu do cíle. Na této mapě se nenachází žádné předměty.

Ukázkový vstup:
```
spiral
6 5
# # # # #
# . . S #
# . # # #
# . # E #
# . . . #
# # # # #
```

#### Vlna

Eralk se nachází v epicentru vlny. Pomožte Eralkovi dostat se z epicentra a zároveň posbírat všechny předměty.

Ukázkový vstup:
```
wave
15 15
# # # # # # # # # # # # # # #
# . . . . # # # # # . . . . #
# . . . # . . . . . # . . . #
# . . # . . # # # . . # . . #
# . # . . # . . . # . . # . #
# # . . # . . . . . # . . # #
# # . # . . # I # . . # . # #
# # . # . # . S . # I . . # #
# # . # . . # . # . . # . # #
# # . . # . . # . . # . . # #
# . # . . # . . . # . . # . #
# . . # . . # # # . . # . . #
# . . . # . . I . . # . . . #
# . . . . # # E # # . . . . #
# # # # # # # # # # # # # # #
```
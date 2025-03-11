# ALT Packages Assistant

**ALT Packages Assistant** – это инструмент для управления пакетами в дистрибутиве ALT Linux. Он предоставляет удобный интерфейс для выполнения различных операций с пакетами.

## Фичи

- Поиск пакета при помощи нечёткого поиска, если пакет не был найден при установке
- Удобная работа с тасками в репозиториях
- ALT Packages Assistant объединяет функциональность нескольких стандартных утилит ALT Linux, предоставляя единый удобный интерфейс.

## Установка

### Из репозитория

```bash
su -
apt-get install apa
```

### Из исходного кода

#### Зависимости

```bash
su -
apt-get install meson vala gettext-tools \
                libgee0.8-devel libgee0.8-gir-devel \
                libjson-glib-devel libjson-glib-gir-devel \
                gobject-introspection-devel
```

#### Сборка и установка

```bash
git clone https://github.com/alt-gnome/apa.git
cd apa
meson setup _build
su - -c "ninja install -C `pwd`/_build"
```

## Удаление

Чтобы удалить **ALT Packages Assistant**, выполните следующую команду:

```bash
su -
ninja uninstall -C _build
```

## Помощь в переводе

Для того, чтобы предложить свой вариант перевода, выполните следующие действия:

> [!WARNING]
> Если вашего языка ещё нет, то предварительно добавьте его в файл [`po/LINGUAS`](./po/LINGUAS).

1. Проделайте операции, описанные в разделе [«Из исходного кода»](#из-исходного-кода).

2. Выполните следующие команды для обновления PO-файлов (файлов перевода):

> Исполнять из корня склонированного репозитория

```shell
./po/update_potfiles.sh
meson compile -C _build apa-pot
meson compile -C _build apa-update-po
```

3. Отредактируйте файл перевода в директории `po`.

> [!TIP]
> Рекомендуется использовать утилиту GTranslator

## Развитие проекта

Этот проект распространяется под лицензией GPLv3. См. файл [LICENSE](./LICENSE) для подробной информации.

Если вы хотите предложить свои изменения, нововведения или сообщить о баге, вы всегда можете посетить раздел Issues.

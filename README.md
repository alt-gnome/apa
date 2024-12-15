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
apt-get install meson vala  gettext-tools \
                libgee0.8-devel libgee0.8-gir-devel \
                libjson-glib-devel libjson-glib-gir-devel \
                libpackagekit-glib-devel gobject-introspection-devel
```

#### Сборка и установка

```bash
su -
git clone https://github.com/alt-gnome/apa.git
cd apa
meson setup _build
ninja install -C _build
```

## Удаление

Чтобы удалить **ALT Packages Assistant**, выполните следующую команду:

```bash
su -
ninja uninstall -C _build
```

## Развитие проекта

Этот проект распространяется под лицензией GPLv3. См. файл LICENSE для подробной информации.

Если вы хотите предложить свои изменения, нововведения или сообщить о баге, вы всегда можете посетить раздел Issues.

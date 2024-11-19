# ALT Packages Assistant

Помощник для работы с пакетами в ваших дистрибутивах ALT.

Используйте `apa help` для получения дополнительной информации.

## Зависимости

```shell
su -
apt-get install meson vala libgee-devel libgee0.8-gir-devel libjson-glib-devel libjson-glib-gir-devel libpackagekit-glib-devel gobject-introspection-devel
```

## Установка из исходников

> [!NOTE]
> Выполнять от имени обычного пользователя
```shell
meson setup _build -Dprefix=/usr
ninja install -C _build
```

### Удаление

```shell
su -
ninja uninstall -C _build
```

# ALT Packages Assistant

Помощник для работы с пакетами в ваших дистрибутивах ALT.

Используйте `apa help` для получения дополнительной информации.

## Установка

#### Установка из исходников

```shell
su -
apt-get install meson vala libgee-devel libpackagekit-glib-devel
meson setup _build -Dprefix=/usr
ninja install -C _build
```

#### Удаление

```shell
sudo ninja uninstall -C _build
```

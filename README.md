# ALT Packages Assistant

Помощник для работы с пакетами в ваших дистрибутивах ALT.

Используйте `apa help` для получения дополнительной информации.

## Установка

#### Установка из исходников

```shell
su -
apt-get install vala libgee-devel libpackagekit-glib-devel
meson setup _build
ninja install -C _build
```

#### Удаление

```shell
sudo ninja uninstall -C _build
```

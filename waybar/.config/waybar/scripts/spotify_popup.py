#!/usr/bin/env python3
import subprocess
import urllib.request
import gi
import cairo

gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")
from gi.repository import Gtk, Gdk, GdkPixbuf, GLib, Pango

GLib.set_prgname("spotify_popup")
CACHE_IMG = "/tmp/spotify_popup_cover.png"

def get_metadata():
    def query(prop):
        try:
            return subprocess.check_output(
                ["playerctl", "-p", "spotify", "metadata", prop],
                stderr=subprocess.DEVNULL
            ).decode().strip()
        except Exception:
            return ""

    art_url = query("mpris:artUrl")
    title = query("xesam:title") or "Sem reprodução"
    artist = query("xesam:artist") or "Spotify"

    try:
        status = subprocess.check_output(
            ["playerctl", "-p", "spotify", "status"],
            stderr=subprocess.DEVNULL
        ).decode().strip()
    except Exception:
        status = "Paused"

    return art_url, status, title, artist

def make_rounded_pixbuf(pixbuf, radius=8):
    """Aplica cantos arredondados subtis à capa do álbum."""
    try:
        w, h = pixbuf.get_width(), pixbuf.get_height()
        surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
        ctx = cairo.Context(surface)
        deg = 3.14159265 / 180.0

        ctx.new_sub_path()
        ctx.arc(w - radius, radius, radius, -90 * deg, 0 * deg)
        ctx.arc(w - radius, h - radius, radius, 0 * deg, 90 * deg)
        ctx.arc(radius, h - radius, radius, 90 * deg, 180 * deg)
        ctx.arc(radius, radius, radius, 180 * deg, 270 * deg)
        ctx.close_path()
        ctx.clip()

        Gdk.cairo_set_source_pixbuf(ctx, pixbuf, 0, 0)
        ctx.paint()
        return Gdk.pixbuf_get_from_surface(surface, 0, 0, w, h)
    except Exception:
        return pixbuf

class SpotifyPopup(Gtk.Window):
    def __init__(self):
        super().__init__(title="Spotify Popup")
        self.set_default_size(230, -1)
        self.set_resizable(False)
        self.set_decorated(False)

        self.has_entered = False
        self.connect("enter-notify-event", self.on_enter)
        self.connect("leave-notify-event", self.on_leave)
        GLib.timeout_add_seconds(4, self.timeout_check)

        art_url, self.status, title, artist = get_metadata()

        # Contentor principal perfeitamente centrado
        card = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        card.set_name("main-card")
        card.set_halign(Gtk.Align.CENTER)
        card.set_valign(Gtk.Align.CENTER)
        self.add(card)

        # Capa do álbum
        self.image_widget = Gtk.Image()
        self.image_widget.set_halign(Gtk.Align.CENTER)
        self.load_cover(art_url)
        card.pack_start(self.image_widget, False, False, 0)

        # Informação da faixa
        info_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=2)
        info_box.set_halign(Gtk.Align.CENTER)

        self.title_label = Gtk.Label()
        self.title_label.set_name("track-title")
        self.title_label.set_text(title)
        self.title_label.set_justify(Gtk.Justification.CENTER)
        self.title_label.set_ellipsize(Pango.EllipsizeMode.END)
        self.title_label.set_max_width_chars(22)
        info_box.pack_start(self.title_label, False, False, 0)

        self.artist_label = Gtk.Label()
        self.artist_label.set_name("track-artist")
        self.artist_label.set_text(artist)
        self.artist_label.set_justify(Gtk.Justification.CENTER)
        self.artist_label.set_ellipsize(Pango.EllipsizeMode.END)
        self.artist_label.set_max_width_chars(24)
        info_box.pack_start(self.artist_label, False, False, 0)

        card.pack_start(info_box, False, False, 0)

        # Botões de reprodução
        ctrl_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=24)
        ctrl_box.set_halign(Gtk.Align.CENTER)
        ctrl_box.set_margin_top(4)

        btn_prev = Gtk.Button(label="󰒮")
        btn_prev.set_name("ctrl-btn")
        btn_prev.set_relief(Gtk.ReliefStyle.NONE)
        btn_prev.connect("clicked", self.on_prev)
        ctrl_box.pack_start(btn_prev, False, False, 0)

        play_icon = "󰏤" if self.status == "Playing" else "󰐊"
        self.btn_play = Gtk.Button(label=play_icon)
        self.btn_play.set_name("play-btn")
        self.btn_play.set_relief(Gtk.ReliefStyle.NONE)
        self.btn_play.connect("clicked", self.on_play_pause)
        ctrl_box.pack_start(self.btn_play, False, False, 0)

        btn_next = Gtk.Button(label="󰒭")
        btn_next.set_name("ctrl-btn")
        btn_next.set_relief(Gtk.ReliefStyle.NONE)
        btn_next.connect("clicked", self.on_next)
        ctrl_box.pack_start(btn_next, False, False, 0)

        card.pack_start(ctrl_box, False, False, 0)

        # CSS com padding uniforme interior
        css = Gtk.CssProvider()
        css.load_from_data(b"""
            window {
                background-color: transparent;
            }
            #main-card {
                background-color: #21222c;
                border: 1px solid #44475a;
                border-radius: 14px;
                padding: 14px 14px 12px 14px;
            }
            #track-title {
                color: #f8f8f2;
                font-family: "JetBrainsMono Nerd Font", monospace;
                font-size: 13px;
                font-weight: bold;
            }
            #track-artist {
                color: #9299a9;
                font-family: "JetBrainsMono Nerd Font", monospace;
                font-size: 11px;
            }
            button {
                background: transparent;
                border: none;
                box-shadow: none;
                padding: 0;
                margin: 0;
            }
            #ctrl-btn {
                color: #7a8296;
                font-family: "JetBrainsMono Nerd Font", monospace;
                font-size: 20px;
            }
            #ctrl-btn:hover {
                color: #f8f8f2;
            }
            #play-btn {
                color: #f8f8f2;
                font-family: "JetBrainsMono Nerd Font", monospace;
                font-size: 24px;
            }
            #play-btn:hover {
                color: #50fa7b;
            }
        """)
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(),
            css,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

    def load_cover(self, url):
        if url:
            try:
                if url.startswith("http"):
                    urllib.request.urlretrieve(url, CACHE_IMG)
                    path = CACHE_IMG
                elif url.startswith("file://"):
                    path = url[7:]
                else:
                    path = url
                pixbuf = GdkPixbuf.Pixbuf.new_from_file_at_scale(path, 140, 140, True)
                pixbuf = make_rounded_pixbuf(pixbuf, radius=8)
                self.image_widget.set_from_pixbuf(pixbuf)
                return
            except Exception:
                pass
        self.image_widget.set_from_icon_name("audio-x-generic", Gtk.IconSize.DIALOG)

    def on_enter(self, widget, event):
        self.has_entered = True

    def on_leave(self, widget, event):
        if event.detail == Gdk.NotifyType.INFERIOR:
            return False
        if self.has_entered:
            Gtk.main_quit()

    def timeout_check(self):
        if not self.has_entered:
            Gtk.main_quit()
        return False

    def on_prev(self, btn):
        subprocess.run(["playerctl", "-p", "spotify", "previous"])
        GLib.timeout_add(200, self.update_state)

    def on_play_pause(self, btn):
        subprocess.run(["playerctl", "-p", "spotify", "play-pause"])
        GLib.timeout_add(200, self.update_state)

    def on_next(self, btn):
        subprocess.run(["playerctl", "-p", "spotify", "next"])
        GLib.timeout_add(200, self.update_state)

    def update_state(self):
        art_url, self.status, title, artist = get_metadata()
        self.load_cover(art_url)
        self.title_label.set_text(title)
        self.artist_label.set_text(artist)
        self.btn_play.set_label("󰏤" if self.status == "Playing" else "󰐊")
        return False

if __name__ == "__main__":
    win = SpotifyPopup()
    win.show_all()
    Gtk.main()

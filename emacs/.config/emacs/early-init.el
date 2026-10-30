;; -*- lexical-binding: t; -*-
;;; early-init.el --- Corre antes da GUI inicializar

;; 1. Garbage Collector máximo no arranque absoluto
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

;; 2. Desativa a interface gráfica e decorações ANTES da janela ser desenhada
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(push '(undecorated . t) default-frame-alist)

(setq inhibit-startup-screen t
      inhibit-startup-message t)

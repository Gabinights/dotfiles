;; -*- lexical-binding: t; -*-

;; Desligar alguns avisos de compilação desnecessários
(setq ad-redefinition-action 'accept)

;; Carregar o Org-mode
(require 'org)

;; Dizer ao Org-babel para carregar o ficheiro config.org
;; (Ele vai ler o config.org, extrair o código para um config.el e executá-lo)
(org-babel-load-file (expand-file-name "config.org" user-emacs-directory))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
